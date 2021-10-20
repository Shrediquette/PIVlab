function [errorCode,glvar] = pco_camera_info(glvar)
% Display some information about connected camera
%
% [errorCode,glvar] = pco_camera_info(glvar)
%
% * Input parameters :
%    glvar                   structure to hold status info
%
% * Output parameters :
%    errorCode               ErrorCode returned from pco.camera SDK-functions  
%    glvar                   structure to hold status info
%
%does retrieve and display some information of the connected camera
%especially type of interface
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
%function workflow
%camera information is readout
%errorCode and if available glvar is returned
%

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
% make sure the dll and h file specified below resides in your current
% folder
%	 [notfound,warnings]= ...
    loadlibrary('SC2_Cam','SC2_CamMatlab.h' ...
                ,'addheader','SC2_common.h' ...
                ,'addheader','SC2_CamExport.h' ...
                ,'alias','PCO_CAM_SDK' ...
                );
            
%            ,'mfilename','sc2_cam_proto' ...

%    if(~isempty(notfound))        
%     disp('PCO_CAM_SDK library not found functions:');
%     disp(notfound);
%    end 
%     
%    if(~isempty(warnings))        
%     disp('PCO_CAM_SDK library warnings:');
%     disp(warnings);
%    end 
%    libfunctionsview('PCO_CAM_SDK');        
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

pco_camera_load_defines();

%Declaration of variable CameraHandle 
%out_ptr is the CameraHandle, which must be used in all other libcalls
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
  commandwindow;
  return ;   
 end
else
 if(isfield(glvar,'out_ptr'))
  out_ptr=glvar.out_ptr;   
 end 
end

text=blanks(100);
[errorCode,~,text] = calllib('PCO_CAM_SDK','PCO_GetInfoString',out_ptr,1,text,100);
pco_errdisp('PCO_GetInfoString',errorCode);   

%test camera recording state and stop camera, if camera is recording
act_recstate = uint16(0); 
[errorCode,~,act_recstate] = calllib('PCO_CAM_SDK', 'PCO_GetRecordingState',out_ptr,act_recstate);
pco_errdisp('PCO_GetRecordingState',errorCode);   

cam_type=libstruct('PCO_CameraType');
set(cam_type,'wSize',cam_type.structsize);

[errorCode,~,cam_type] = calllib('PCO_CAM_SDK', 'PCO_GetCameraType', out_ptr,cam_type);
pco_errdisp('PCO_GetCameraType',errorCode);   
interface=uint16(cam_type.wInterfaceType);

disp(['Name          : ',strtrim(text)]);
disp(['SerialNumber  : ',int2str(cam_type.dwSerialNumber)]);
disp(['interface     : ',int2str(interface)]);
disp(['record state  : ',int2str(act_recstate)]);
clear text;

disp(' ');
disp('Camera Hardware versions:');
z=uint16(cam_type.strHardwareVersion.BoardNum);
for n=1:z
 s=cam_type.strHardwareVersion.(strcat('Board',num2str(n)));
 b=char(s.szName);
 batch=uint16(s.wBatchNo);
 rev=uint16(s.wRevision);
 var=uint16(s.wVariant);
 disp([b,': ',int2str(batch),'.',int2str(rev),'.',int2str(var)]);
end


disp(' ');
disp('Camera Firmware versions:');
z=uint16(cam_type.strFirmwareVersion.DeviceNum);
for n=1:z
 s=cam_type.strFirmwareVersion.(strcat('Device',num2str(n)));
 b=char(s.szName);
 major=uint16(s.bMajorRev);
 minor=uint16(s.bMinorRev);
 var=uint16(s.wVariant);
 disp([b,': ',int2str(major),'.',int2str(minor),'.',int2str(var)]);
end

if((do_close==1)&&(cam_open==1))
 [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
 if(errorCode)
  pco_errdisp('PCO_CloseCamera',errorCode);   
 else
  disp('PCO_CloseCamera done');  
  cam_open=0;
  if((exist('glvar','var'))&& ...
    (isfield(glvar,'out_ptr')))
   glvar.out_ptr=[];
  end
 end    
end

if((unload==1)&&(cam_open==0))
 unloadlibrary('PCO_CAM_SDK');
 disp('PCO_CAM_SDK unloadlibrary done');
end 


if((exist('glvar','var'))&& ...
   (isfield(glvar,'camera_open')))
 glvar.camera_open=cam_open;
end

clearvars ;
commandwindow;
end