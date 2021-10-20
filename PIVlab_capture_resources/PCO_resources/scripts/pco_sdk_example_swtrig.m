function [errorCode] = pco_sdk_example_swtrig(exposure_time)
% set variables grab and display a single image
%
%   [errorCode] = pco_sdk_example_swtrig(exposure_time)
%
% * Input parameters :
%    exposure_time          camera exposure time (default=10ms)
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%
%grab single image from a recording pco.camera 
%using functions PCO_AddBufferEx and PCO_WaitforBuffer
%display the grabbed image
%
%function workflow
%open camera
%set variables 
%start camera
%grab image
%show image
%stop camera
%close camera
%

glvar=struct('do_libunload',1,'do_close',0,'camera_open',0,'out_ptr',[]);

if(~exist('exposure_time','var'))
 exposure_time = 10;   
end

%reduce_display_size=1: display only top-left corner 800x600Pixel
reduce_display_size=0;

pco_camera_load_defines();
subfunc=pco_camera_subfunction();
subfunc.fh_lasterr(0);

[errorCode,glvar]=pco_camera_open_close(glvar);
pco_errdisp('pco_camera_setup',errorCode); 
disp(['camera_open should be 1 is ',int2str(glvar.camera_open)]);
if(errorCode~=PCO_NOERROR)
 commandwindow;
 return;
end 

out_ptr=glvar.out_ptr;

try
    
subfunc.fh_stop_camera(out_ptr);

cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,out_ptr,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
if(errorCode)
 pco_errdisp('PCO_GetCameraDescription',errorCode);   
end

bitpix=uint16(cam_desc.wDynResDESC);
 
cam_type=libstruct('PCO_CameraType');
set(cam_type,'wSize',cam_type.structsize);
[errorCode,out_ptr,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
if(errorCode)
 pco_errdisp('PCO_GetCameraType',errorCode);   
end

interface=uint16(cam_type.wInterfaceType);
subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2)
subfunc.fh_set_triggermode(out_ptr,TRIGGER_MODE_SOFTWARETRIGGER);

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(out_ptr,TIMESTAMP_MODE_BINARYANDASCII);
end 

%set bitalignment LSB
bitalign=uint16(BIT_ALIGNMENT_LSB);
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetBitAlignment', out_ptr,bitalign);
 pco_errdisp('PCO_SetBitAlignment',errorCode);   

%save actual RecoderSubmode
prev_rec_submode=uint16(10);
[errorCode,out_ptr,prev_rec_submode] = calllib('PCO_CAM_SDK', 'PCO_GetRecorderSubmode', out_ptr,prev_rec_submode);
pco_errdisp('PCO_GetRecorderSubmode',errorCode);   

%set RECORDER_SUBMODE_RING_BUFFER
[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode', out_ptr,RECORDER_SUBMODE_RINGBUFFER);
pco_errdisp('PCO_SetRecorderSubmode',errorCode);   

%set highest Pixelrate 
index=1;
for n=2:4  
 if(cam_desc.dwPixelRateDESC(n)>cam_desc.dwPixelRateDESC(index))
  index=n;
 end
end

[errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_SetPixelRate', out_ptr,cam_desc.dwPixelRateDESC(index));
if(errorCode)
 pco_errdisp('PCO_SetPixelRate',errorCode);   
else
 disp(['PixelRate set to ',int2str(cam_desc.dwPixelRateDESC(index))]);   
end

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

subfunc.fh_get_triggermode(out_ptr);
subfunc.fh_show_frametime(out_ptr);

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



act_xsize=uint16(0);
act_ysize=uint16(0);
ccd_xsize=uint16(0);
ccd_ysize=uint16(0);

%use PCO_GetSizes because this always returns accurate image size for next recording
[errorCode,out_ptr,act_xsize,act_ysize]  = calllib('PCO_CAM_SDK', 'PCO_GetSizes', out_ptr,act_xsize,act_ysize,ccd_xsize,ccd_ysize);
if(errorCode)
 pco_errdisp('PCO_GetSizes',errorCode);   
end

disp(['sizes: horizontal ',int2str(act_xsize),' vertical ',int2str(act_ysize)]);

lineadd=0;   
if(metadatasize>0)
 xs=uint32(fix((double(bitpix)+7)/8));
 xs=xs*uint32(act_xsize);
 i=uint16(floor(metadatasize/double(xs)));
 lineadd=i+1;
end

imasize= uint32(fix((double(bitpix)+7)/8)) * uint32(act_ysize+lineadd)* uint32(act_xsize);   

%only for firewire add always some lines
%to ensure enough memory is allocated for the transfer
if(interface==INTERFACE_FIREWIRE)
  imas=uint32(fix((double(bitpix)+7)/8));
  imas= imas*uint32(act_ysize+lineadd)* uint32(act_xsize);   
  i=floor(double(imas)/4096);
  i=i+1;
  i=i*4096;
  imasize=i;
  i=i-double(imas);
  xs=uint32(fix((double(bitpix)+7)/8));
  xs=xs*uint32(act_xsize);
  i=floor(i/double(xs));
  i=i+1;
  lineadd=lineadd+i;
 disp(['imasize is: ',int2str(imas),' aligned: ',int2str(imasize)]); 
end
disp([int2str(lineadd),' additional lines must be allocated ']);

%Allocate data array for images
image_stack=ones(act_xsize,(act_ysize+lineadd),'uint16');

sBufNr=int16(-1);
im_ptr = libpointer('uint16Ptr',image_stack(:,:));
ev_ptr = libpointer('voidPtr');

%Allocate a SDK buffer and set address of buffer from data array image_stack
[errorCode,out_ptr,sBufNr]  = calllib('PCO_CAM_SDK','PCO_AllocateBuffer', out_ptr,sBufNr,imasize,im_ptr,ev_ptr);
if(errorCode)
 pco_errdisp('PCO_AllocateBuffer',errorCode);   
 clear image_stack;
 commandwindow;
 return;
end

disp(['bufnr: ',int2str(sBufNr)]);

subfunc.fh_start_camera(out_ptr);

disp('get image');
tic;
%add the allocated buffer    
[errorCode]  = calllib('PCO_CAM_SDK','PCO_AddBufferEx', out_ptr,0,0,sBufNr,act_xsize,act_ysize,bitpix);
if(errorCode)
 pco_errdisp('PCO_AddBufferEx',errorCode);   
end

trigdone=int16(1);
[errorCode,out_ptr,trigdone]  = calllib('PCO_CAM_SDK','PCO_ForceTrigger',out_ptr,trigdone);
if(errorCode)
 pco_errdisp('PCO_ForceTrigger',errorCode);   
else
 disp(['trigger done return: ',int2str(trigdone)]);   
end

buflist=libstruct('PCO_Buflist');
buflist.sBufnr_1=uint16(sBufNr);
[errorCode,out_ptr,buflist]  = calllib('PCO_CAM_SDK','PCO_WaitforBuffer', out_ptr,1,buflist,1000);
if(errorCode)
 pco_errdisp('PCO_WaitforBuffer',errorCode);   
else
 disp('PCO_WaitforBuffer done');   
end 

if(errorCode==PCO_NOERROR)
%disp(['statusdll: ',num2str(buflist_1.dwStatusDll,'%08X'),' statusdrv: ',num2str(buflist_1.dwStatusDrv,'%08X')]);   
%test and display buffer 
 if((bitand(buflist.dwStatusDll_1,hex2dec('00008000')))&&(buflist.dwStatusDrv_1==0))
  disp(['Event for buffer done, StatusDrv ',num2str(buflist.dwStatusDrv_1,'%08X')]);
%show image   
  ima=im_ptr.Value;
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
  m=max(max(ima(10:end-10,10:end-10)));
  imshow(ima,[0,m+100]);
  disp(['found max ',int2str(m)]);
 end
end 

subfunc.fh_stop_camera(out_ptr);

%this will remove all pending buffers in the queue
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_CancelImages', out_ptr);
if(errorCode)
 pco_errdisp('PCO_CancelImages',errorCode);   
end
 
disp('Press "Enter" to close window and proceed')
pause();
close();

%set changed values back
subfunc.fh_set_triggermode(out_ptr,TRIGGER_MODE_AUTOTRIGGER);
%set saved RecoderSubmode
[errorCode] = calllib('PCO_CAM_SDK', 'PCO_SetRecorderSubmode', out_ptr,prev_rec_submode);
if(errorCode)
 pco_errdisp('PCO_SetRecorderSubmode',errorCode);   
end

[errorCode] = calllib('PCO_CAM_SDK', 'PCO_ArmCamera', out_ptr);
if(errorCode)
 pco_errdisp('PCO_ArmCamera',errorCode);   
end

[errorCode]  = calllib('PCO_CAM_SDK','PCO_FreeBuffer',out_ptr,sBufNr);
if(errorCode)
 pco_errdisp('PCO_FreeBuffer',errorCode);   
else 
 disp('PCO_FreeBuffer done ');   
end

subfunc.fh_stop_camera(out_ptr);

catch ME
 errorCode=subfunc.fh_lasterr();
 txt=blanks(101);
 txt=calllib('PCO_CAM_SDK','PCO_GetErrorTextSDK',pco_uint32err(errorCode),txt,100);
 
 clearvars -except ME glvar;

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
  clearvars;
  commandwindow;
  return;
 else
  clearvars -except ME;
  rethrow(ME)
 end
end    

clearvars -except glvar;

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clearvars glvar;
commandwindow;
end
 
