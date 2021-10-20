function [errorCode,glvar] = pco_camera_resetmem(glvar,segment)
%reset memory size to 0 of all or distinct segment
%
%   [errorCode,glvar] = pco_camera_resetmem(glvar,segment)
%
% * Input parameters :
%    glvar                   structure to hold status info
%    segment                 segment to reset  
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%    glvar                   structure to hold status info
%
%structure glvar is used to set different modes for
%load/unload library
%open/close camera SDK
%
%glvar.do_libunload: 1 unload lib at end
%glvar.do_close:     1 close camera SDK at end
%glvar.camera_open:  open status of camera SDK
%glvar.out_ptr:      libpointer to camera SDK handle
%
%if glvar does not exist,
%the library is loaded at begin and unloaded at end
%the SDK is opened at begin and closed at end
%
%if segment does not exist all camera memory is set to segment 1
%
%function workflow
%parameters are checked
%set camera memory structure
%return

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
	loadlibrary('SC2_Cam','SC2_CamMatlab.h' ...
                ,'addheader','SC2_CamExport.h' ...
                ,'alias','PCO_CAM_SDK');
	disp('PCO_CAM_SDK library is loaded!');
end

if((exist('glvar','var'))&& ...
   (isfield(glvar,'do_libunload'))&& ...
   (isfield(glvar,'do_close'))&& ...
   (isfield(glvar,'camera_open'))&& ...
   (isfield(glvar,'out_ptr')))
 unload=glvar.do_libunload;    
 cam_open=glvar.camera_open;
 do_close=glvar.do_close;
else
 unload=1;   
 cam_open=0;
 do_close=1;
end

ph_ptr = libpointer('voidPtrPtr');

%libcall PCO_OpenCamera
if(cam_open==0)
 [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_OpenCamera', ph_ptr, 0);
 if(errorCode == 0)
  disp('PCO_OpenCamera done');
  cam_open=1;
  if((exist('glvar','var'))&& ...
     (isfield(glvar,'camera_open'))&& ...
     (isfield(glvar,'out_ptr')))
   glvar.camera_open=1;
   glvar.out_ptr=out_ptr;
  end 
 else
   pco_errdisp('PCO_OpenCamera',errorCode);   
  if(unload)
   unloadlibrary('PCO_CAM_SDK');
   disp('PCO_CAM_SDK unloadlibrary done');
  end 
  return ;   
 end
else
 if(isfield(glvar,'out_ptr'))
  out_ptr=glvar.out_ptr;   
 end
end

pco_camera_load_defines();

%get Camera Description to test if camera has internal memory
cam_desc=libstruct('PCO_Description');
set(cam_desc,'wSize',cam_desc.structsize);
[errorCode,~,cam_desc] = calllib('PCO_CAM_SDK', 'PCO_GetCameraDescription', out_ptr,cam_desc);
pco_errdisp('PCO_GetCameraDescription',errorCode);   

if(bitand(cam_desc.dwGeneralCapsDESC1,GENERALCAPS1_NO_RECORDER)~=0)
 errorCode=PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED;
 disp('function is not supported because the selected camera does not have internal memory');
 return;
end    

act_recstate = uint16(10); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

if(act_recstate~=0)
 errorCode=PCO_ERROR_APPLICATION_FUNCTIONNOTSUPPORTED;
 disp('function is not supported while camera is in recording state ON');
 return;
end 

dwSegment=uint32(zeros(1,4));

if(exist('segment','var'))
 if((segment<1)||(segment>4))
  errorCode=PCO_ERROR_APPLICATION|PCO_ERROR_WRONGVALUE;
  disp('value of segment must be in the range from 1 to 4');
  return;
 end 
 
 wActSeg=uint16(0);
 [errorCode,~,wActSeg]=calllib('PCO_CAM_SDK', 'PCO_GetActiveRamSegment',out_ptr,wActSeg);
 if(segment==wActSeg)
  errorCode=PCO_ERROR_APPLICATION|PCO_ERROR_WRONGVALUE;
  disp('cannot clear active segment ',int2str(segment));
  return;
 end 
 
 disp(['clear segment ',int2str(segment)]);   
 if(errorCode==PCO_NOERROR)
  [errorCode,~,dwSegment]=calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSegmentSize',out_ptr,dwSegment);
  pco_errdisp('PCO_GetCameraRamSegmentSize',errorCode);   
 end
 dwSegment(segment)=0;
else
 disp('reset all segments to default state');   
end

if((dwSegment(1)==0)&&(dwSegment(2)==0)&&(dwSegment(3)==0)&&(dwSegment(4)==0))
 dwRamSize=uint32(0);
 wPageSize=uint16(0);
 if(errorCode==PCO_NOERROR)
  [errorCode,~,dwRamSize]=calllib('PCO_CAM_SDK', 'PCO_GetCameraRamSize',out_ptr,dwRamSize,wPageSize);
  pco_errdisp('PCO_GetCameraRamSize',errorCode);   
 end
 dwSegment(1)=dwRamSize;   
 if(errorCode==PCO_NOERROR)
  [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetActiveRamSegment',out_ptr,1);
  pco_errdisp('PCO_SetActiveRamSegment',errorCode);    
 end
end    


if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_SetCameraRamSegmentSize',out_ptr,dwSegment);
 pco_errdisp('PCO_SetCameraRamSegmentSize',errorCode);   
end

if(errorCode==PCO_NOERROR)
 [errorCode,~]=calllib('PCO_CAM_SDK', 'PCO_ArmCamera',out_ptr);
 pco_errdisp('PCO_ArmCamera',errorCode);   
end 

if(exist('glvar','var'))
 glvar = close_camera(out_ptr,unload,do_close,cam_open,glvar);
else
 close_camera(out_ptr,unload,do_close,cam_open);   
end

end

function [glvar] = close_camera(out_ptr,unload,do_close,cam_open,glvar)
 if((do_close==1)&&(cam_open==1))
  errorCode = calllib('PCO_CAM_SDK', 'PCO_CloseCamera',out_ptr);
  if(errorCode)
   pco_errdisp('PCO_CloseCamera',errorCode);   
  else
   disp('PCO_CloseCamera done');
   cam_open=0;
   if((exist('glvar','var'))&& ...
      (isfield(glvar,'camera_open'))&& ...
      (isfield(glvar,'out_ptr')))
    glvar.out_ptr=[];
    glvar.camera_open=0;
   end
  end    
 end
 if((unload==1)&&(cam_open==0))
  unloadlibrary('PCO_CAM_SDK');
  disp('PCO_CAM_SDK unloadlibrary done');
  commandwindow;
 end 
end
