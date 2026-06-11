function [OutputError,camera_sub_type] = PIVlab_capture_OPTRONIS_bitflow_cam_detect(~)
OutputError=0;
delete(findobj('tag','cam_info_box'))

%% Prepare camera
try
    delete(imaqfind); %clears all previous videoinputs
    warning off
    hwinf = imaqhwinfo;
    warning on
    warning('off','MATLAB:JavaEDTAutoDelegation');
    warning('off','imaq:gentl:noSupportedPixelFormat')
    imaqreset
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
    if ~isdeployed
    end
end

found_correct_adaptor=0;
for adaptorID=1:numel(hwinf.InstalledAdaptors)
    info = imaqhwinfo(hwinf.InstalledAdaptors{adaptorID});
    if strcmp(info.AdaptorName,'bitflow')
        disp(['bitflow adaptor found with ID: ' num2str(adaptorID)])
        found_correct_adaptor=1;
        break
    end
end

if found_correct_adaptor~=1
    disp('ERROR: bitflow adaptor not found. Please install the BitFlow MATLAB adaptor.')
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error, adaptor missing','ERROR: bitflow adaptor not found. Please install the BitFlow MATLAB IMAQ adaptor.','modal');
    camera_sub_type='unknown';
    return
end

%% Create temporary videoinput to identify camera
try
    bfml_dir  = fileparts(mfilename('fullpath'));
    bfml_path = fullfile(bfml_dir, 'Optronis-Cyclone-2-2000-M_OLT.bfml');
    OPTRONIS_vid = videoinput('bitflow', 1, [bfml_path ';BuffersToUse=4']);
    OPTRONIS_src = getselectedsource(OPTRONIS_vid);

    OPTRONIS_src.BFGTLNodeName = 'AcquisitionStop';
    OPTRONIS_src.BFGTLNodeValueStr = '1';

    OPTRONIS_src.BFGTLNodeName = 'DeviceModelName';
    OPTRONIS_name = OPTRONIS_src.BFGTLNodeValueStr;
    disp(['BitFlow: camera model name = ' OPTRONIS_name])

    delete(OPTRONIS_vid);
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Camera not found! Is it connected?','modal');
    camera_sub_type='unknown';
    return
end

if contains(OPTRONIS_name,'Cyclone-2-2000') || contains(OPTRONIS_name,'Cyclone2-2000')
    camera_sub_type='Cyclone-2-2000-M';
elseif contains(OPTRONIS_name,'Cyclone-25-150') || contains(OPTRONIS_name,'Cyclone25-150')
    camera_sub_type='Cyclone-25-150-M';
else
    disp(OPTRONIS_name)
    disp('--> No cam detected on bitflow grabber')
    camera_sub_type='unknown';
end
disp(['Found camera: ' camera_sub_type])

target_axis=gui.retr('pivlab_axis');
Kinder=get(target_axis,'Children');
for k=1:size(Kinder,1)
    if isprop(Kinder(k),'CData')
        img_size1=size(Kinder(k).CData,1);
        img_size2=size(Kinder(k).CData,2);
        break
    end
end
if ~strcmp(camera_sub_type,'unknown')
    text(img_size2*0.75,img_size1*0.95,['Connected to: ' camera_sub_type ' via Bitflow grabber.'],'tag','cam_info_box','Color','black','BackgroundColor','green','VerticalAlignment','bottom','interpreter','none');
    drawnow;
end
