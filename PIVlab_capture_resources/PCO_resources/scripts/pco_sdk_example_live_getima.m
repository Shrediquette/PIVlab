function [errorCode] = pco_sdk_example_live_getima(looptime,exposure_time,triggermode)
% grab and display images in a loop using simple image function
%
%   [errorCode] =  pco_sdk_example_live_getima(looptime,triggermode)
%
% * Input parameters :
%    looptime                time the loop is running (default=10 seconds)
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%
%grab images from a recording pco.edge camera 
%using function PCO_GetImageEx 
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

if(triggermode==1)
 disp('sorry this example does not run with triggermode=1 (SW-Trigger)');
 disp('triggermode is set to 0 (Auto-Trigger)');
 triggermode=0;
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

subfunc.fh_stop_camera(out_ptr);

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
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
 subfunc.fh_set_metadata_mode(out_ptr,1);
end

%set default Pixelrate
subfunc.fh_set_pixelrate(out_ptr,1);

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
imatime=subfunc.fh_show_frametime(out_ptr);

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

%allocate memory for display, a single buffer is used 
imas=uint32(fix((double(bitpix)+7)/8));
imasize= imas*uint32(act_xsize)* uint32(act_ysize+lineadd); 

image_stack=zeros(act_xsize,(act_ysize+lineadd),'uint16');

%Allocate single SDK buffer and set address of this buffer from image_stack
sBufNr=int16(-1);
ev_ptr = libpointer('voidPtr');
im_ptr = libpointer('uint16Ptr',image_stack(:,:));
 
[errorCode,~,sBufNr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
if(errorCode~=PCO_NOERROR)
 pco_errdisp('PCO_AllocateBuffer',errorCode);   
 ME = MException('PCO_ERROR:AllocateBuffer','Cannot continue script without allocated Buffers');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end
 
%show figure
ima=image_stack(:,1:act_ysize);
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

pause(0.5);

%grab preimage to get actual image value range and set limits
errorCode=subfunc.fh_start_camera(out_ptr);
if(errorCode~=PCO_NOERROR)
 ME = MException('PCO_ERROR:StartCamera','Cannot continue script with stopped camera');
 subfunc.fh_lasterr(errorCode);
 throw(ME);   
end 
if(triggermode>=2)
 disp('send external trigger pulse within 3 seconds');   
 pause(0.0001); 
end 

errorCode = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,1,0,0,sBufNr,act_xsize,act_ysize,bitpix);
if(errorCode)
 pco_errdisp('PCO_GetImageEx',errorCode);   
else
 disp('GetImageEx done');
%get data and show image   
 ima=im_ptr.Value;
 if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
  [imanum,~]=subfunc.fh_get_timestamp(ima,bitalign,bitpix);
  disp(['get_timestamp imacount: ',int2str(imanum),' done ']);
  txt=subfunc.fh_print_timestamp(ima,bitalign,bitpix);
  disp(['Timestamp of image(',num2str(1,'%04d'),'): ',txt]);
 end 
  
 if(metadatasize>0)
  metaline=ima(1:metadatasize,act_ysize+1:end);
  metaline=metaline';
  [errorCode_m,metastruct]=subfunc.fh_get_struct_metadata(metaline,metadatasize);
  if(errorCode_m)
   pco_errdisp('get_struct_metadata',errorCode_m);   
  else
   txt=subfunc.fh_print_meta_timestamp(metastruct);
   disp(['Timestamp of meta (',num2str(1,'%04d'),'): ',txt]);
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

if(triggermode>=2)
 disp('send external trigger pulses within 3 seconds');   
 pause(0.0001); 
end 

[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',glvar.out_ptr,act_recstate);
if(errorCode)
  pco_errdisp('PCO_GetRecordingState',errorCode);   
else
 disp(['Actual recording state is ',int2str(act_recstate)]);   
end

if(act_recstate==1)
 disp('get images');
 tic;

 for ima_nr=1:nr_of_images   
  errorCode = calllib('PCO_CAM_SDK','PCO_GetImageEx',out_ptr,1,0,0,sBufNr,act_xsize,act_ysize,bitpix);
  if(errorCode)
   pco_errdisp('PCO_GetImageEx',errorCode);   
  else
%get data and show image   
   ima=get(im_ptr,'Value');
   if(rem(ima_nr,d)==0)
    disp(['GetImageEx ',int2str(ima_nr),' done']);
    if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
     txt=subfunc.fh_print_timestamp(ima,bitalign,bitpix);
     disp(['Timestamp of image(',num2str(ima_nr,'%04d'),'): ',txt]);
    end 
    if(metadatasize>0)
     metaline=ima(1:metadatasize,act_ysize+1:end);
     metaline=metaline';
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
  end
  t=toc;
  if(t>looptime)
   break;
  end 
 end

 disp(['Last image ',int2str(ima_nr),' done ']);
 disp([int2str(ima_nr),' images done in ',num2str(t),' seconds. time per image is ',num2str(t/double(ima_nr),'%.3f'),'s']);  
 if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
  txt=subfunc.fh_print_timestamp_t(ima,1,bitpix); %image is already shifted
  disp(['Timestamp of image(',num2str(ima_nr,'%04d'),'): ',txt]);
 end
 
%this will remove all pending buffers in the queue
 errorCode = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
 pco_errdisp('PCO_CancelImages',errorCode);   

 
 disp('Press "Enter" to close window and proceed')
 pause();
 close();
 pause(1);
end

subfunc.fh_stop_camera(out_ptr);
 
errorCode = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
if(errorCode)
 pco_errdisp('PCO_FreeBuffer',errorCode);   
else 
 disp('PCO_FreeBuffer done ');   
end    

catch ME
 errorCode=subfunc.fh_lasterr();
 txt=blanks(101);
 txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);

 calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);

 clearvars -except ME glvar errorCode txt;

 if(glvar.camera_open==1)
  glvar.do_close=1;
  glvar.do_libunload=1;
  pco_camera_open_close(glvar);
 end

 if strfind(ME.identifier,'PCO_ERROR:')
  msg=[ME.identifier,' ',ME.message];
  disp(txt); 
  warning('off','backtrace')
  warning(msg)    
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


if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clearvars
commandwindow;

end
   
