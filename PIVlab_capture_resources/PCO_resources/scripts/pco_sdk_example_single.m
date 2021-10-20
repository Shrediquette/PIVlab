function [errorCode, ima] = pco_sdk_example_single(exposure_time,triggermode)
% set variables grab and display a single images
%
%   [errorCode] = pco_sdk_example_single(exposure_time,triggermode)
%
% * Input parameters :
%    exposure_time           camera exposure time (default=10ms)
%    triggermode             camera trigger mode (default=AUTO)
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%
%grab images from a recording pco camera 
%using script function pco_camera_stack
%display the grabbed images
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

glvar=struct('do_libunload',0,'do_close',0,'camera_open',0,'out_ptr',[]);

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
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_TIMESTAMP)==0)
 subfunc.fh_enable_timestamp(out_ptr,TIMESTAMP_MODE_BINARYANDASCII);
end 

%enable MetaData if available
if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_METADATA))
 subfunc.fh_set_metadata_mode(out_ptr,1);
end

subfunc.fh_set_exposure_times(out_ptr,exposure_time,2,0,2)
subfunc.fh_set_triggermode(out_ptr,triggermode);

%if PCO_ArmCamera does fail no images can be grabbed

hwio_sig=libstruct('PCO_Signal');
set(hwio_sig,'wSize',hwio_sig.structsize);
[errorCode,~,hwio_sig] = calllib('PCO_CAM_SDK', 'PCO_GetHWIOSignal', out_ptr,0,hwio_sig);
pco_errdisp('PCO_GetHWIOSignal',errorCode);
hwio_sig.wEnabled = 1;
[errorCode,~,~] = calllib('PCO_CAM_SDK', 'PCO_SetHWIOSignal', out_ptr,0,hwio_sig);
pco_errdisp('PCO_SetHWIOSignal',errorCode);



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

disp('get single image');
%subfunc.fh_start_camera(out_ptr);
[errorCode,ima,metadata,glvar]=pco_camera_stack(1,glvar);
if(errorCode==PCO_NOERROR)
 if(reduce_display_size~=0)
  [ys,xs]=size(ima);
  xmax=800;
  ymax=600;
  if((xs>xmax)&&(ys>ymax))
   imar=ima(1:ymax,1:xmax);
  elseif(xs>xmax)
   imar=ima(:,1:xmax);
  elseif(ys>ymax)
   imar=ima(1:ymax,:);
  end        
 else
  imar=ima;   
 end 
 m=max(max(imar(10:end-10,10:end-10)));
% imshow(ima',[0,m+100]);
 draw_image(imar,[0 m+100]);
 disp(['found max ',int2str(m)]);
end 

subfunc.fh_stop_camera(out_ptr);

if(~isempty(metadata))
 [metadatasize,~]=size(metadata);   
 [errorCode_m,metastruct]=subfunc.fh_get_struct_metadata(metadata,metadatasize);
 if(errorCode_m)
  pco_errdisp('get_struct_metadata',errorCode_m);   
 else    
  txt=subfunc.fh_print_meta_timestamp(metastruct);
  disp(['Timestamp of meta (',num2str(1,'%04d'),'):  ',txt]);
  subfunc.fh_print_meta_struct(metastruct);
 end 
end

disp('Press "Enter" to proceed')
pause();
close()


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

clearvars -except glvar ima errorCode;

if(glvar.camera_open==1)
 glvar.do_close=1;
 glvar.do_libunload=1;
 pco_camera_open_close(glvar);
end   

clearvars glvar;
commandwindow;
end

