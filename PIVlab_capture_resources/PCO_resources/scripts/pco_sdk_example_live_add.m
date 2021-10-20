function [errorCode] = pco_sdk_example_live_add(looptime,exposure_time,triggermode)
% grab and display images in a loop
%
%   [errorCode] = pco_sdk_example_live_add(looptime,triggermode)
%
% * Input parameters :
%    looptime                time the loop is running (default=10 seconds)
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%
%grab images from a recording pco.camera 
%using functions PCO_AddBufferEx and PCO_WaitforBuffer
%display the grabbed images
%
%
%break loop either after waittime or nr_of_images images are done
%

glvar=struct('do_libunload',1,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('looptime','var'))
 looptime = 10;   
end

if(~exist('exposure_time','var'))
 exposure_time = 10;   
end

if(~exist('triggermode','var'))
 triggermode = 0;   
end

%reduce_display_size=1: display only top-left corner 800x600Pixel
reduce_display_size=1;

pco_camera_load_defines();
subfunc=pco_camera_subfunction();

[errorCode,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',errorCode); 
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(errorCode~=PCO_NOERROR)
 commandwindow;
 return;
end 

out_ptr=glvar.out_ptr;

try

act_recstate = uint16(10); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
if(errorCode)
  pco_errdisp('PCO_GetRecordingState',errorCode);   
else
 disp(['actual recording state is ',int2str(act_recstate)]);   
end

%stop camera
subfunc.fh_stop_camera(out_ptr);

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
cam_desc
pco_errdisp('PCO_GetCameraDescription',errorCode);   

bitpix=uint16(cam_desc.wDynResDESC);

%set bitalignment LSB
bitalign=uint16(BIT_ALIGNMENT_LSB);
errorCode = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', out_ptr,bitalign);
pco_errdisp('PCO_SetBitAlignment',errorCode);   

errorCode = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode',out_ptr,RECORDER_SUBMODE_RINGBUFFER);
pco_errdisp('PCO_SetRecorderSubmode',errorCode);   

%enable ASCII and binary timestamp
if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(out_ptr,TIMESTAMP_MODE_BINARYANDASCII);
end

%enable MetaData if available
if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_METADATA))
 subfunc.fh_set_metadata_mode(out_ptr,0);
end

	%{
	%Pixel Binning
	%binning funktioniert nur wenn gleichzeitig ROI gesetzt wird.
	h_binning=1; %1,2,4
	v_binning=1; %1,2,4
	
	v_ROI_reduction = 4
	[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetBinning', out_ptr,h_binning,v_binning); %2,4, etc.
	%ROI selection
	[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetROI', out_ptr,1,1,5120/h_binning/4,5120/v_binning/v_ROI_reduction); %does this work for the panda...?
	

%}


%set default Pixelrate
subfunc.fh_set_pixelrate(out_ptr,2);

subfunc.fh_set_triggermode(out_ptr,triggermode);
subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2);

%if PCO_ArmCamera does fail no images can be grabbed
errorCode = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode~=PCO_NOERROR)
 pco_errdisp('PCO_ArmCamera',errorCode);   
 ME = MException('PCO_ERROR:ArmCamera','Cannot continue script with not armed camera');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 

%adjust transfer parameter if necessary
subfunc.fh_set_transferparameter(out_ptr);

triggermode=subfunc.fh_get_triggermode(out_ptr);

%display actual image time and maximal frequency
imatime=subfunc.fh_show_frametime(out_ptr)

%% 
%% Measure time to acquire 1 image
		dwSec=uint32(0);
		dwNanoSec=uint32(0);
		[errorCode,~,dwSec,dwNanoSec] = calllib('PCO_CAM_SDK', 'PCO_GetCOCRuntime', out_ptr,dwSec,dwNanoSec);
		if(errorCode)
			pco_errdisp('PCO_GetCOCRuntime',errorCode);
		end
		disp(['Max double image capture freq: ' num2str(round(1/(double(dwNanoSec)/1000/1000/1000),3)) ' Hz.'])
%% 


metadatasize=0;
if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_METADATA))
 wMetaDataMode=uint16(0);
 wMetaDataSize=uint16(0);
 wMetaDataVersion=uint16(0);

 [errorCode,~,wMetaDataMode,wMetaDataSize,wMetaDataVersion] = calllib('PCO_CAM_SDK', 'PCO_GetMetaDataMode',out_ptr,wMetaDataMode,wMetaDataSize,wMetaDataVersion);
 pco_errdisp('PCO_GetMetaDataMode',errorCode);
 if(errorCode)
  pco_errdisp('PCO_GetMetaDataMode',errorCode);   
  return;
 end

 disp(['Camera supports Metadata Version: ',num2str(wMetaDataVersion)]);    

 if(wMetaDataMode~=0)
  metadatasize=wMetaDataSize;
  disp(['Metadata is enabled. Number of Bytes: ',num2str(metadatasize)]);   
 end
end

%calculate images to grab
nr_of_images=uint32(fix(looptime/imatime)+1);
disp(['maximal ',num2str(nr_of_images),' images will be grabbed in ',num2str(looptime),' seconds' ]);   

act_xsize=uint16(0);
act_ysize=uint16(0);
ccd_xsize=uint16(0);
ccd_ysize=uint16(0);

%use PCO_GetSizes because this always returns accurate image size for next recording
[errorCode,~,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,ccd_xsize,ccd_ysize);
if(errorCode)
 pco_errdisp('PCO_GetSizes',errorCode);   
end

disp(['sizes: horizontal ',int2str(act_xsize),' vertical ',int2str(act_ysize)]);

flags=2; %IMAGEPARAMETERS_READ_WHILE_RECORDING;
errorCode = calllib('PCO_CAM_SDK', 'PCO_SetImageParameters', out_ptr,act_xsize,act_ysize,flags,[],0);
pco_errdisp('PCO_SetImageParameters',errorCode);   

lineadd=0;   
if(metadatasize>0)
 xs=uint32(fix((double(bitpix)+7)/8));
 xs=xs*uint32(act_xsize);
 i=uint16(floor((metadatasize*2)/double(xs)));
 lineadd=i+1;
end

disp(['lines added: ',int2str(lineadd)]);

%allocate memory for display, 4 buffers are used 
bufcount=4;
bufnum=zeros(4,1,'int16');

imas=uint32(fix((double(bitpix)+7)/8));
imas= imas*uint32(act_xsize)* uint32(act_ysize); 
imasize=imas;

image_stack=zeros(act_xsize,(act_ysize+lineadd),bufcount,'uint16');

%Allocate 4 SDK buffer and set address of buffers from image_stack
ev_ptr(bufcount) = libpointer('voidPtr');
im_ptr(bufcount) = libpointer('voidPtr');
 
buflist=libstruct('PCO_Buflist');
names=fieldnames(buflist);
x=1:4:length(names);
bufnr=names(x);
x=3:4:length(names);
statusdll=names(x);
x=4:4:length(names);
statusdrv=names(x);

for n=1:bufcount   
 sBufNri=int16(-1);
 im_ptr(n) = libpointer('uint16Ptr',image_stack(:,:,n));
 ev_ptr(n) = libpointer('voidPtr');
 
 [errorCode,~,sBufNri]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNri,imasize,im_ptr(n),ev_ptr(n));
 if(errorCode~=PCO_NOERROR)
  pco_errdisp('PCO_AllocateBuffer',errorCode);   
  ME = MException('PCO_ERROR:AllocateBuffer','Cannot continue script without allocated Buffers');
  subfunc.fh_lasterr(errorCode);
  throw(ME);   
 end
 buflist.(bufnr{n})=int16(sBufNri);
 bufnum(n)=int16(sBufNri);
 e=bitor(buflist.(statusdll{n}),uint32(PCO_BUFFER_EVAUTORES),'uint32');
 buflist.(statusdll{n})=e;
end
 
%show figure
ima=image_stack(:,1:act_ysize,1);
if(reduce_display_size~=0)
 [xs,ys]=size(ima);
 xmax=800;
 ymax=600;
 if((xs>xmax)&&(ys>ymax))
  ima=ima(1:xmax,1:ymax);
 elseif(xs>xmax)
  ima=ima(1:xmax,:);
 elseif(ys>ymax)
  ima=ima(:,1:ymax);
 end        
end 
ima=ima';

imah=draw_image(ima,[0 100]);
axish=gca;
set(axish,'CLim',[0 1000]);

pause(0.0001);

%grab preimage to get actual image value range and set limits
errorCode=subfunc.fh_start_camera(out_ptr);
if(errorCode~=PCO_NOERROR)
 ME = MException('PCO_ERROR:StartCamera','Cannot continue script with stopped camera');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 

errorCode  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,bufnum(1),act_xsize,act_ysize,bitpix);
if(errorCode~=PCO_NOERROR)
 pco_errdisp('PCO_AddBufferEx',errorCode);   
 ME = MException('PCO_ERROR:AddBufferEx','Cannot continue script without added Buffers');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end

disp('get pre images');
trigdone=int16(1);
if((triggermode==1)||(triggermode==2))
 [errorCode,~,trigdone]  = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
 if(errorCode)
  pco_errdisp('PCO_ForceTrigger',errorCode);   
 else
  disp([int2str(trigdone),' trigger done return: ',int2str(trigdone)]);   
 end
elseif(triggermode>2)
 disp('send external trigger pulse within 1 second');   
 pause(0.001); 
end 

[errorCode,~,buflist]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,1,buflist,1000);
if(errorCode)
 pco_errdisp('PCO_WaitforBuffer',errorCode);   
else
 disp(['PCO_WaitforBuffer done bufnr: ',int2str(bufnum(1))]);   
end 

if((bitand(buflist.dwStatusDll_1,hex2dec('00008000')))&&(buflist.dwStatusDrv_1==0))
 disp(['Event buf',int2str(1),' pre image done, StatusDrv 0x',num2str(buflist.dwStatusDrv_1,'%08X'),' Statusdll 0x',num2str(buflist.dwStatusDll_1,'%08X')]);
%get data and show image   
 ima=get(im_ptr(1),'Value');
 if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
  [imanum,~]=subfunc.fh_get_timestamp(ima,bitalign,bitpix);
  disp(['get_timestamp imacount: ',int2str(imanum),' done ']);
  txt=subfunc.fh_print_timestamp(ima,bitalign,bitpix);
  disp(['timestamp ima:  ',txt]);
  str_time=subfunc.fh_get_struct_timestamp(ima,bitalign,bitpix);
  txt=subfunc.fh_print_struct_timestamp(str_time);
  disp(['timestamp str:  ',txt]);
 end
 
 if(metadatasize>0)
  metaline=ima(1:metadatasize,act_ysize+1:end);
  [errorCode_m,metastruct]=subfunc.fh_get_struct_metadata(metaline,metadatasize);
  if(errorCode_m)
   pco_errdisp('get_struct_metadata',errorCode_m);   
  else
   txt=subfunc.fh_print_meta_timestamp(metastruct);
   disp(['timestamp meta: ',txt]);
  end
 end

 if(metadatasize>0)
  ima=ima(:,1:act_ysize);
 end 
 
 if(reduce_display_size~=0)
  [xs,ys]=size(ima);
  xmax=800;
  ymax=600;
  if((xs>xmax)&&(ys>ymax))
   ima=ima(1:xmax,1:ymax);
  elseif(xs>xmax)
   ima=ima(1:xmax,:);
  elseif(ys>ymax)
   ima=ima(:,1:ymax);
  end        
 end 
 ima=ima';
 if(bitalign==BIT_ALIGNMENT_MSB)
  s=int16(16-bitpix);
  s=s*-1;   
  ima=bitshift(ima,s);
 end
     
 m=max(max(ima(10:end-10,10:end-10)));
 set(axish,'CLim',[0 m+100]);
 disp(['pre image done maxvalue: ',int2str(m)]);   
 set(imah,'CData',ima,'CDataMapping','scaled'); 
 pause(0.0001);
end

subfunc.fh_stop_camera(out_ptr);

%this will remove all pending buffers in the queue and does reset grabber
errorCode = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
pco_errdisp('PCO_CancelImages',errorCode);   

pause(0.01);
%variable to reduce amount of messages
d=10;
if(nr_of_images>100)
 if(nr_of_images<500)
  d=50;
 else
  d=100;
 end 
end
 
  
errorCode=subfunc.fh_start_camera(out_ptr);
if(errorCode~=PCO_NOERROR)
 ME = MException('PCO_ERROR:StartCamera','Cannot continue script with stopped camera');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 
 
 
%setup loop
for n=1:bufcount   
 errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,bufnum(n),act_xsize,act_ysize,bitpix);
 if(errorCode~=PCO_NOERROR)
  pco_errdisp('PCO_AddBufferEx',errorCode);   
  ME = MException('PCO_ERROR:AddBufferEx','Cannot continue script without added buffers');
  subfunc.fh_lasterr(errorCode);
  throw(ME);   
 end 
end 

[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',glvar.out_ptr,act_recstate);
if(errorCode)
  pco_errdisp('PCO_GetRecordingState',errorCode);   
else
 disp(['Actual recording state is ',int2str(act_recstate)]);   
end

if(act_recstate==1)
 disp('get images');

 trigdone=int16(1);
 trigcount=0;
 if(triggermode==1)
  [errorCode,~,trigdone]  = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
  if(errorCode)
   pco_errdisp('PCO_ForceTrigger',errorCode);   
  else
   trigcount=trigcount+1;  
   disp(['first trigger done return: ',int2str(trigdone)]);   
  end
 elseif(triggermode>=2)
  disp('send external trigger pulses within 1 second');   
 end 
 pause(0.0001);
 tic;

%grab and display loop 
 ima_nr=0;
 last_ok=0;
 while(ima_nr<nr_of_images)   
%wait for buffers    
  [errorCode,~,buflist]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,bufcount,buflist,1000);
  if(errorCode)
   pco_errdisp('PCO_WaitforBuffer',errorCode);   
   break;
  end 
%  disp(['After wait image ',int2str(ima_nr),' last_ok ',num2str(last_ok)]);
%first image done trigger next
  if(triggermode==1)
   [errorCode,~,trigdone]  = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
   if(errorCode)
    pco_errdisp('PCO_ForceTrigger',errorCode);   
   else
    trigcount=trigcount+1;  
   end 
  end 
  
%test and display buffer 
  next=last_ok+1;
  multi=0;  
  for n=1:bufcount
   if(next>bufcount)
    next=1;
   end 
%   disp(['Status buf',int2str(next),' StatusDll ',num2str(buflist.(statusdll{next}),'%08X'),' StatusDrv ',num2str(buflist.(statusdrv{next}),'%08X')]);
   if((bitand(buflist.(statusdll{next}),hex2dec('00008000')))&&(buflist.(statusdrv{next})==0))
%get data and show image   
    last_ok=next;
    ima=get(im_ptr(next),'Value');
    ima_nr=ima_nr+1;
    multi=multi+1;     
   
    if(rem(ima_nr,d)==0)
     disp(['Status buf',int2str(next),' ok  image ',int2str(ima_nr),' done, last_ok ',num2str(last_ok)]);
     if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
      txt=subfunc.fh_print_timestamp(ima,bitalign,bitpix);
      disp(['Timestamp of image(',num2str(ima_nr,'%04d'),'): ',txt]);
     end
     
     if(metadatasize>0)
      metaline=ima(1:metadatasize,act_ysize+1:end);
      [errorCode_m,metastruct]=subfunc.fh_get_struct_metadata(metaline,metadatasize);
      if(errorCode_m)
       pco_errdisp('get_struct_metadata',errorCode_m);   
      else
       txt=subfunc.fh_print_meta_timestamp(metastruct);
       disp(['Timestamp of meta (',num2str(ima_nr,'%04d'),'): ',txt]);
      end
     end
    end 
    
    if(metadatasize>0)
     ima=ima(:,1:act_ysize);
    end 
    
    if(reduce_display_size~=0)
     [xs,ys]=size(ima);
     xmax=800;
     ymax=600;
     if((xs>xmax)&&(ys>ymax))
      ima=ima(1:xmax,1:ymax);
     elseif(xs>xmax)
      ima=ima(1:xmax,:);
     elseif(ys>ymax)
      ima=ima(:,1:ymax);
     end        
    end 
    ima=ima';
    if(bitalign==BIT_ALIGNMENT_MSB)
     s=int16(16-bitpix);
     s=s*-1;   
     ima=bitshift(ima,s);
    end
    set(imah,'CData',ima,'CDataMapping','scaled'); 
	pause(0.0001);
	assignin('base','letztes_bild',ima);
    
    errorCode = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,bufnum(next),act_xsize,act_ysize,bitpix);
    if(errorCode)
     pco_errdisp('PCO_AddBufferEx',errorCode);   
     break;
    end
   end
   next=next+1;
  end
  
  if(multi>1)
   disp(['Multi Buffers found after wait:',num2str(multi)]);
  end 
  t=toc;
  if(t>looptime)
   break;
  end 
 end

 disp(['Last image ',int2str(ima_nr),' done ']);
 disp([int2str(ima_nr),' images done in ',num2str(t),' seconds. time per image is ',num2str(t/double(ima_nr),'%.3f'),'s']);  
 if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
  subfunc.fh_print_timestamp_t(ima,1,bitpix); %image is already shifted
 end
 
%this will remove all pending buffers in the queue
 errorCode = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
 pco_errdisp('PCO_CancelImages',errorCode);   

 [errorCode,~,buflist] = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,bufcount,buflist,500);
 pco_errdisp('PCO_WaitforBuffer',errorCode);   
 
 for next=1:bufcount
  disp(['Event buf',int2str(next),' StatusDll ',num2str(buflist.(statusdll{next}),'%08X'),' StatusDrv ',num2str(buflist.(statusdrv{next}),'%08X')]);
 end

 
 %disp('Press "Enter" to close window and proceed')
 %pause();
 %close();
 %pause(1);
end

subfunc.fh_stop_camera(out_ptr);
 
for n=1:bufcount
 errorCode = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,bufnum(n));
 if(errorCode)
  pco_errdisp('PCO_FreeBuffer',errorCode);   
 else 
  disp(['PCO_FreeBuffer',num2str(n),' done ']);   
 end
end    


catch ME
 errorCode=subfunc.fh_lasterr();
 txt=blanks(101);
 txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);
 
 calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
 for n=1:bufcount
  calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,bufnum(n));
 end
 
 clearvars -except ME glvar errorCode txt;

 if(glvar.camera_open==1)
  glvar.do_close=1;
  glvar.do_libunload=1;
  pco_camera_open_close(glvar);
 end

 if strfind(ME.identifier,'PCO_ERROR:')
  msg=[ME.identifier,' ',ME.message];
  warning('off','backtrace')
  warning(msg)    
  disp(txt); 
  for k=1:length(ME.stack)
    disp(['from file ',ME.stack(k).file,' at line ',num2str(ME.stack(k).line)]);
  end
  close();
  clearvars -except errorCode;
  commandwindow;
  return;
 else
  close();
  clearvars -except ME;
  rethrow(ME)
 end
end    

clearvars -except glvar errorCode;

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clearvars glvar;
commandwindow;

end
   
