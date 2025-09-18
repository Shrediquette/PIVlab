function camera_info (~, ~, ~)
gui.toolsavailable(0,'Busy, please wait...')
imaqreset
pause(0.5)
% Create a device structure enumerating all devices available in the
% current producer configuration. When this is run by runGenTLSuite or any
% individual test point, only one producer will be specified in the
% GENICAM_GENTL64_PATH environment variable.
% Copyright 2024 The MathWorks, Inc.
try
    % Get list of all connected gentl hardware
    hwinfo = imaqhwinfo("gentl");
catch ME
    % Error out if imaqhwinfo fails
    gui.toolsavailable(1)
    msgbox(['No cameras found.' newline newline 'Please verify the correct installation of drivers and Addons following the instructions on' newline newline 'https://www.pivlab.de/wiki/5-camera-setup/'],'Available Devices')
    error("Error while collecting information on connected GenTL hardware");
end
if isempty(hwinfo.DeviceIDs)
    % Error out if no devices found
    gui.toolsavailable(1)
    disp("No GenTL hardware detected.");
end
deviceInfo = hwinfo.DeviceInfo;
deviceList = cell(1, numel(deviceInfo));
for k=1:numel(deviceInfo)
    deviceList{k}.DEVICENAME = deviceInfo(k).DeviceName;
    % DeviceID can change depending on producer
    deviceList{k}.IMAQHWID = deviceInfo(k).DeviceID;
    deviceList{k}.SUPPORTEDFORMATS = deviceInfo(k).SupportedFormats;
    deviceList{k}.CurrentFormat = deviceInfo(k).DefaultFormat;
    hwSpecFileName = regexprep( ...
        ['gentl_', deviceInfo(k).DeviceName, '_', deviceInfo(k).DefaultFormat], ...
        '\W', '_');
    % Note that this only defines what the hw spec file SHOULD be
    % named, it does not guarantee that it has been created.
    deviceList{k}.hwSpecFileName = hwSpecFileName;
end

cam_name = pco_camera_info_pivlab;

deviceListStr='';
if ~isempty(hwinfo.DeviceIDs)
    deviceNames = {deviceInfo.DeviceName};
    deviceListStr = strjoin(deviceNames, newline);
end

if ~isempty(cam_name)
    deviceListStr=[deviceListStr newline cam_name];
end


if isempty(hwinfo.DeviceIDs) && isempty(cam_name)
    msgbox(['No cameras found.' newline newline 'Please verify the correct installation of drivers and Addons following the instructions on' newline newline 'https://www.pivlab.de/wiki/5-camera-setup/'],'Available Devices')
else
    msgbox(['Detected cameras:' newline deviceListStr],'Available Devices')
end
gui.toolsavailable(1)

end

function cam_name=pco_camera_info_pivlab(glvar)
if(strcmp(computer('arch'),'win64'))
    sdkLibName = 'sc2_cam';
elseif(strcmp(computer('arch'),'glnxa64'))
    sdkLibName = 'libpco_sc2cam';
else
    error('This platform is not supported.');
end

% Test if library is loaded
if (~libisloaded('PCO_CAM_SDK'))
    % make sure the dll and h file specified below resides in your current
    % folder
    if(strcmp(computer('arch'),'win64'))
        if ~exist('sc2_cam_mfile.m','file') %if prototype file not exists
            loadlibrary('sc2_cam', 'sc2_cammatlab.h','addheader','sc2_common.h','addheader','sc2_camexport.h','alias','PCO_CAM_SDK', 'mfilename', 'sc2_cam_mfile');
            disp('Making prototype file')
        end
        loadlibrary('sc2_cam', @sc2_cam_mfile,'alias','PCO_CAM_SDK') %loadlibrary with prototype file --> required for compiled apps. Does it work for non-compiled apps...?
        %loadlibrary( 'sc2_cam','sc2_cammatlab.h','addheader','sc2_common.h'  ,'addheader','sc2_camexport.h'  ,'alias','PCO_CAM_SDK');
    else
        error('This platform is not supported.');
    end
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
    cam_name=[];
end

pco_camera_load_defines();

%Declaration of variable CameraHandle
%out_ptr is the CameraHandle, which must be used in all other libcalls
ph_ptr = libpointer('voidPtrPtr');

%libcall PCO_OpenCamera
if(cam_open==0)
    [errorCode,out_ptr] = calllib('PCO_CAM_SDK', 'PCO_OpenCamera', ph_ptr, 0);
    if(errorCode == 0)

        cam_open=1;
        if((exist('glvar','var'))&& ...
                (isfield(glvar,'camera_open'))&& ...
                (isfield(glvar,'out_ptr')))
            glvar.camera_open=1;
            glvar.out_ptr=out_ptr;
        end
    else

        if(unload)
            unloadlibrary('PCO_CAM_SDK');
        end
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


cam_name=strtrim(text);

clear text;


z=uint16(cam_type.strHardwareVersion.BoardNum);
for n=1:z
    s=cam_type.strHardwareVersion.(strcat('Board',num2str(n)));
    b=char(s.szName);
    batch=uint16(s.wBatchNo);
    rev=uint16(s.wRevision);
    var=uint16(s.wVariant);
end



z=uint16(cam_type.strFirmwareVersion.DeviceNum);
for n=1:z
    s=cam_type.strFirmwareVersion.(strcat('Device',num2str(n)));
    b=char(s.szName);
    major=uint16(s.bMajorRev);
    minor=uint16(s.bMinorRev);
    var=uint16(s.wVariant);
end

if((do_close==1)&&(cam_open==1))
    [errorCode] = calllib('PCO_CAM_SDK', 'PCO_CloseCamera', out_ptr);
    if(errorCode)
        pco_errdisp('PCO_CloseCamera',errorCode);
    else
        cam_open=0;
        if((exist('glvar','var'))&& ...
                (isfield(glvar,'out_ptr')))
            glvar.out_ptr=[];
        end
    end
end

if((unload==1)&&(cam_open==0))
    unloadlibrary('PCO_CAM_SDK');
end


if((exist('glvar','var'))&& ...
        (isfield(glvar,'camera_open')))
    glvar.camera_open=cam_open;
end
end