function [OutputError,camera_sub_type] = PIVlab_capture_OPTRONIS_cam_detect(~)
OutputError=0;
delete(findobj('tag','cam_info_box'))

%% Prepare camera
try
    delete(imaqfind); %clears all previous videoinputs
    warning off
    hwinf = imaqhwinfo;
    warning on
    warning('off','imaq:gentl:hardwareTriggerTriggerModeOff'); %trigger property of OPTRONIS cannot be set in Matlab.
    warning('off','MATLAB:JavaEDTAutoDelegation'); %strange warning
    imaqreset
catch
    errordlg('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','Error!','modal')
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
    if ~isdeployed
            end
end
found_correct_adaptor=0;
for adaptorID=1:numel(hwinf.InstalledAdaptors)
    info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
    if strcmp(info.AdaptorName,'gentl')
        disp(['gentl adaptor found with ID: ' num2str(adaptorID)])
        found_correct_adaptor=1;
        break
    end
end

if found_correct_adaptor~=1
	disp('ERROR: gentl adaptor not found. Please install the GenICam / GenTL support package from here:')
	disp('https://de.mathworks.com/matlabcentral/fileexchange/45180')
    errordlg({'ERROR: gentl adaptor not found. Please got to Matlab file exchange and search for "GenICam Interface " to install it.' 'Link: https://de.mathworks.com/matlabcentral/fileexchange/45180'},'Error, support package missing','modal')
end

try
    %Getting camera device ID when multiple cameras are connected
    for CamID = 1: size(info.DeviceInfo,2)
        camName=info.DeviceInfo(CamID).DeviceName;
        if contains(camName,'Cyclone')
            break
        end
    end
    OPTRONIS_name = info.DeviceInfo(CamID).DeviceName;
catch
    errordlg('Error: Camera not found! Is it connected?','Error!','modal')
end

if contains(OPTRONIS_name,'Cyclone-2-2000-M')
    camera_sub_type='Cyclone-2-2000-M';
elseif contains (OPTRONIS_name,'Cyclone-1HS-3500-M')
    camera_sub_type='Cyclone-1HS-3500-M';
elseif contains (OPTRONIS_name,'Cyclone-25-150-M')
    camera_sub_type='Cyclone-25-150-M';
else
    disp (OPTRONIS_name)
    disp('--> camera type unknown!')
    camera_sub_type='unknown';
end
disp(['Found camera: ' camera_sub_type])
Kinder=get(gca,'Children');
for k=1:size(Kinder,1)
    if isprop(Kinder(k),'CData')
        img_size1=size(Kinder(k).CData,1);
        img_size2=size(Kinder(k).CData,2);
        break
    end
end
if contains(OPTRONIS_name,'Cyclone-2-2000-M') || contains (OPTRONIS_name,'Cyclone-1HS-3500-M') || contains (OPTRONIS_name,'Cyclone-25-150-M')
    text(img_size2*0.75,img_size1*0.95,['Connected to: '  camera_sub_type],'tag','cam_info_box','Color','black','BackgroundColor','green','VerticalAlignment','bottom','interpreter','none');
end