function [OutputError,ima,frame_nr_display] = PIVlab_capture_OPTRONIS_bitflow_calibration_image(img_amount,exposure_time,ROI_OPTRONIS)
%disp(['ROI_OPTRONIS is ' num2str(ROI_OPTRONIS)])
OutputError=0;
hgui=getappdata(0,'hgui');

%% Prepare camera
try
    delete(imaqfind);
    warning off
    hwinf = imaqhwinfo; %#ok<NASGU>
    warning on
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.','modal');
    disp('Error: Image Acquisition Toolbox not available! This camera needs the image acquisition toolbox.')
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
    OutputError=1;
    ima=[];
    frame_nr_display=[];
    return
end

%% Create videoinput
bfml_dir  = fileparts(mfilename('fullpath'));

OPTRONIS_bits = gui.retr('OPTRONIS_bits');
if isempty(OPTRONIS_bits) || ~isnumeric(OPTRONIS_bits)
    OPTRONIS_bits=8;
    gui.put('OPTRONIS_bits', OPTRONIS_bits);
end
bitmode = OPTRONIS_bits;

OPTRONIS_gain = gui.retr('OPTRONIS_gain');
if isempty(OPTRONIS_gain)
    OPTRONIS_gain=1;
end
%% Create videoinput
%% select bitmode
if isempty(bitmode) || ~isnumeric(bitmode)
    bitmode=8;
end
if bitmode==8
    camfilemode='PIVMode8bit'; % funktioniert ohne Fehlermeldung, timing + dropped frames nicht kontrolliert.
else
    camfilemode='PIVMode10bit';
end
%% select cam subtype
camera_sub_type = gui.retr('camera_sub_type');
if contains(camera_sub_type, '25-150')
    bfml_name = 'Optronis-Cyclone-25-150-M_OLT.bfml'; %does not exist yet
    exposure_gap = 24;
    minexpo = 12;
elseif contains(camera_sub_type, '2-2000')
    bfml_name = 'Optronis-Cyclone-2-2000-M_OLT.bfml';
    exposure_gap = 3;
    minexpo = 2;
elseif contains(camera_sub_type, '1HS-3500')
    bfml_name = 'Optronis-Cyclone-1HS-3500-M_OLT.bfml'; %does not exist yet
    exposure_gap = 3;
    minexpo = 2;
else
    disp('bfml file does not exist for this camera type')
    return
end
if bitmode > 8
    exposure_gap = exposure_gap + 1; %maximum exposure issmaller at 10 bit
end

bfml_dir  = fileparts(mfilename('fullpath'));
bfml_path = fullfile(bfml_dir, [camfilemode '@' bfml_name]);
OPTRONIS_vid = videoinput('bitflow', 1, [bfml_path ';BuffersToUse=4']);
OPTRONIS_src = getselectedsource(OPTRONIS_vid);

%% Read camera model to determine per-model exposure gap
try
    OPTRONIS_src.BFGTLNodeName = 'AcquisitionStop';
    OPTRONIS_src.BFGTLNodeValueStr = '1';
    OPTRONIS_src.BFGTLNodeName = 'DeviceModelName';
    OPTRONIS_name = OPTRONIS_src.BFGTLNodeValueStr;
catch
    OPTRONIS_name = 'Cyclone-2-2000-M';
end

if contains(OPTRONIS_name,'2000')
    disp(['Found camera: Cyclone-2-2000-M'])
    exposure_gap=2;
elseif contains(OPTRONIS_name,'3500') || contains(OPTRONIS_name,'1HS')
    disp(['Found camera: Cyclone-1HS-3500-M'])
    exposure_gap=2;
elseif contains(OPTRONIS_name,'25-150') || contains(OPTRONIS_name,'25150')
    disp(['Found camera: Cyclone-25-150-M'])
    exposure_gap=24;
else
    disp(['camera type unknown: ' OPTRONIS_name])
    exposure_gap=2;
end
if bitmode > 8
    exposure_gap = exposure_gap + 1;
end

%% Stop acquisition before changing parameters
bf_set(OPTRONIS_src, 'AcquisitionStop', '1');
pause(0.05)

%% Pixel format
if bitmode==8
    bf_set(OPTRONIS_src, 'PixelFormat', 'Mono8');
elseif bitmode==10
    bf_set(OPTRONIS_src, 'PixelFormat', 'Mono10');
end

%% Set ROI
ROI_OPTRONIS=[ROI_OPTRONIS(1)-1, ROI_OPTRONIS(2)-1, ROI_OPTRONIS(3), ROI_OPTRONIS(4)];
ROI_OPTRONIS(3) = max(64, floor(ROI_OPTRONIS(3)/64)*64); % width must be multiple of 64 (4 CXP links × 16-pixel quantum)
bf_set(OPTRONIS_src, 'OffsetX', '0');   % zero offsets before changing size to avoid constraint violations
bf_set(OPTRONIS_src, 'OffsetY', '0');
bf_set(OPTRONIS_src, 'Width',   num2str(ROI_OPTRONIS(3)));
bf_set(OPTRONIS_src, 'Height',  num2str(ROI_OPTRONIS(4)));
bf_set(OPTRONIS_src, 'OffsetX', num2str(ROI_OPTRONIS(1)));
bf_set(OPTRONIS_src, 'OffsetY', num2str(ROI_OPTRONIS(2)));
% VideoResolution stays at the BFML default (1920×1080); clip to the actual frame size
OPTRONIS_vid.ROIPosition = [0 0 ROI_OPTRONIS(3) ROI_OPTRONIS(4)];

%% Acquisition mode and frame rate
bf_set(OPTRONIS_src, 'AcquisitionMode', 'Continuous');

preview_framerate=20;

%% Clamp exposure time to valid range for preview frame rate
if exposure_time > 1/preview_framerate*1000^2-exposure_gap
    exposure_time = 1/preview_framerate*1000^2-exposure_gap;
    disp(['Exposure time adjusted to ' num2str(exposure_time) ' µs (' num2str(exposure_time/1000) ' ms)'])
end
if exposure_time < 500
    exposure_time = 500;
    disp(['Exposure time adjusted to ' num2str(exposure_time) ' µs (' num2str(exposure_time/1000) ' ms)'])
end

%% Counter off for calibration
bf_set(OPTRONIS_src, 'CounterInformation', 'Off');

bf_set(OPTRONIS_src, 'AGain', num2str(OPTRONIS_gain));

%% Exposure and trigger
bf_set(OPTRONIS_src, 'ExposureMode',         'Timed');
bf_set(OPTRONIS_src, 'AcquisitionFrameRate',  num2str(preview_framerate));
bf_set(OPTRONIS_src, 'ExposureTime',          num2str(exposure_time));

%% Configure external trigger via camera Sync In connector
bf_set(OPTRONIS_src, 'SyncInActivation', 'RisingEdge');

OPTRONIS_src.TriggerMode = 'Free Run';

%% Prepare axis
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
%PIVlab_axis = findobj(hgui,'Type','Axes');
PIVlab_axis = gui.retr('pivlab_axis');
image_handle_OPTRONIS=imagesc(zeros(ROI_OPTRONIS(4),ROI_OPTRONIS(3)),'Parent',PIVlab_axis,[0 2^bitmode]);
setappdata(hgui,'image_handle_OPTRONIS',image_handle_OPTRONIS);
frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
colormap default
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gui.retr('pivlab_axis'),'ytick',[])
set(gui.retr('pivlab_axis'),'xtick',[])
colorbar

%% Restart camera acquisition and start preview
pause(0.05)
OPTRONIS_src.BFGTLNodeName = 'AcquisitionStart';
OPTRONIS_src.BFGTLNodeValueStr = '1';
pause(0.05)
OPTRONIS_vid.FramesPerTrigger = 1;
if bitmode > 8
    set(OPTRONIS_vid, 'PreviewFullBitDepth', 'on');
end
set(frame_nr_display,'String','');
preview(OPTRONIS_vid, image_handle_OPTRONIS)
tmp=get(image_handle_OPTRONIS,'CData');
tmp=size(tmp(:,:,1));
set(image_handle_OPTRONIS,'CData',ones(tmp)*35);
pause(0.1) %let the preview draw the camera image before reading it back.

%% Re-apply frame rate and exposure after preview start
%probably not required in bitflow
%bf_set(OPTRONIS_src, 'AcquisitionFrameRate', num2str(preview_framerate));
%bf_set(OPTRONIS_src, 'ExposureTime',         num2str(exposure_time));

caxis([0 2^bitmode]);
displayed_img_amount=0;

while getappdata(hgui,'cancel_capture') ~=1 && displayed_img_amount < img_amount
    ima = image_handle_OPTRONIS.CData;

    %% live charuco
    do_charuco_detection = gui.retr('do_charuco_detection');
    if isempty(do_charuco_detection)
        do_charuco_detection=0;
    end
    if do_charuco_detection
        PIVlab_capture_charuco_detector(ima,PIVlab_axis,image_handle_OPTRONIS);
    end

    %% sharpness indicator
    sharpness_enabled = getappdata(hgui,'sharpness_enabled');
    if sharpness_enabled == 1
        [~,~] = PIVlab_capture_sharpness_indicator(ima,1);
    else
        delete(findobj('tag','sharpness_display_text'));
    end
    crosshair_enabled = getappdata(hgui,'crosshair_enabled');
    if crosshair_enabled == 1
        locations=[0.15 0.5 0.85];
        half_thickness=1;
        brightness_incr=101;
        ima_ed=ima;
        old_max=max(ima(:));
        for loca=locations
            ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)=ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)+brightness_incr;
            ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)=ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)+brightness_incr;
        end
        ima_ed(ima_ed>old_max)=old_max;
        set(image_handle_OPTRONIS,'CData',ima_ed);
    end
    %% HISTOGRAM
    if getappdata(hgui,'hist_enabled')==1
        if isvalid(image_handle_OPTRONIS)
            hist_fig=findobj('tag','hist_fig');
            if isempty(hist_fig)
                hist_fig=figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Live histogram','Toolbar','none','tag','hist_fig','CloseRequestFcn', @HistWindow_CloseRequestFcn);
                hist_obj=histogram(ima(1:2:end,1:2:end),'binlimits',[0 2^bitmode]);
            end
            if ~exist('old_hist_y_limits','var')
                old_hist_y_limits=[0 35000];
            else
                if isvalid(hist_obj)
                    old_hist_y_limits=get(hist_obj.Parent,'YLim');
                end
            end
            parent_ax=findall(hist_fig,'type','axes');
            hist_obj=histogram(ima(1:2:end,1:2:end),'Parent',parent_ax,'binlimits',[0 2^bitmode]);
        end
        if ~exist('new_hist_y_limits','var')
            new_hist_y_limits=[0 35000];
        end
        new_hist_y_limits=get(hist_obj.Parent,'YLim');
        if isempty(new_hist_y_limits);  new_hist_y_limits=[0 35000];  end
        if isempty(old_hist_y_limits);  old_hist_y_limits=[0 35000];  end
        set(hist_obj.Parent,'YLim',(new_hist_y_limits*0.5 + old_hist_y_limits*0.5))
    else
        hist_fig=findobj('tag','hist_fig');
        if ~isempty(hist_fig)
            close(hist_fig)
        end
    end
    drawnow limitrate

    %% Autofocus
    autofocus_enabled = getappdata(hgui,'autofocus_enabled');

    if autofocus_enabled == 1
        delaycounter=delaycounter+1;
    else
        delaycounter=0;
        delaycounter2=0;
        delay_time_1=tic;
    end

    delay_time=0.5;
    if autofocus_enabled == 1
        if delaycounter>10
            focus_start = getappdata(hgui,'focus_servo_lower_limit');
            focus_end   = getappdata(hgui,'focus_servo_upper_limit');
            amount_of_raw_steps=20;
            fine_step_resolution_increase=8;
            focus_step_raw=round(abs(focus_end-focus_start)/amount_of_raw_steps);
            focus_step_fine=round(1/fine_step_resolution_increase*(abs(focus_end-focus_start)/amount_of_raw_steps));
            if ~exist('sharpness_focus_table','var') || isempty(sharpness_focus_table) || isempty(sharp_loop_cnt)
                sharpness_focus_table=zeros(1,2);
                sharp_loop_cnt=0;
                focus=focus_start;
                raw_finished=0;
                aperture=getappdata(hgui,'aperture');
                lighting=getappdata(hgui,'lighting');
                PIVlab_capture_lensctrl(focus,aperture,lighting)
            end
            if raw_finished==0
                if focus < focus_end
                    if toc(delay_time_1)>=delay_time
                        delay_time_1=tic;
                        sharp_loop_cnt=sharp_loop_cnt+1;
                        [sharpness,~]=PIVlab_capture_sharpness_indicator(ima,0);
                        sharpness_focus_table(sharp_loop_cnt,1)=focus;
                        sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                        focus=focus+focus_step_raw;
                        PIVlab_capture_lensctrl(focus,aperture,lighting)
                        autofocus_notification(1)
                    end
                else
                    [r,~]=find(sharpness_focus_table==max(sharpness_focus_table(:,2)));
                    focus_peak=sharpness_focus_table(r(1),1);
                    disp(['Best raw focus: ' num2str(focus_peak)])
                    raw_finished=1;
                    focus_start_fine=focus_peak-6*focus_step_raw;
                    focus_end_fine=focus_peak+3*focus_step_raw;
                    if focus_start_fine < focus_start; focus_start_fine=focus_start; end
                    if focus_end_fine   > focus_end;   focus_end_fine=focus_end;     end
                    focus=focus_start_fine;
                    PIVlab_capture_lensctrl(focus,aperture,lighting)
                    sharp_loop_cnt=0;
                    raw_data=[sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range')];
                    sharpness_focus_table=zeros(1,2);
                end
            end
            if raw_finished==1; delaycounter2=delaycounter2+1; else; delaycounter2=0; end
            if raw_finished==1
                delay_time=0.35;
                if delaycounter2>10
                    if focus < focus_end_fine
                        if toc(delay_time_1)>=delay_time
                            delay_time_1=tic;
                            sharp_loop_cnt=sharp_loop_cnt+1;
                            [sharpness,~]=PIVlab_capture_sharpness_indicator(ima,0);
                            sharpness_focus_table(sharp_loop_cnt,1)=focus;
                            sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                            focus=focus+focus_step_fine;
                            PIVlab_capture_lensctrl(focus,aperture,lighting)
                            autofocus_notification(1)
                        end
                    else
                        [r,~]=find(sharpness_focus_table==max(sharpness_focus_table(:,2)));
                        focus_peak=sharpness_focus_table(r(1),1);
                        disp(['Best fine focus: ' num2str(focus_peak)])
                        PIVlab_capture_lensctrl(focus_end_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_start_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_peak,aperture,lighting)
                        setappdata(hgui,'autofocus_enabled',0);
                        lens_control_window=getappdata(0,'hlens');
                        focus_edit_field=getappdata(lens_control_window,'handle_to_focus_edit_field');
                        set(focus_edit_field,'String',num2str(focus_peak));
                        figure;plot(raw_data(:,1),raw_data(:,2),'Linewidth',2)
                        hold on;plot(sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range'),'Linewidth',2);hold off
                        title('Focus search');xlabel('Pulsewidth us');ylabel('Sharpness')
                        legend('Coarse search','Fine search');grid on
                    end
                end
            end
        end
    else
        autofocus_notification(0)
        sharpness_focus_table=[];
        sharp_loop_cnt=[];
    end

    if img_amount == 1
        if sum(ima(1:10,1,1)) ~=10
            displayed_img_amount=displayed_img_amount+1;
        end
    end
end
try
    stoppreview(OPTRONIS_vid)
catch ME
    fprintf('BitFlow cleanup warning (non-fatal): %s\n', ME.message);
end

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1
    hgui=getappdata(0,'hgui');
    PIVlab_axis=findobj(hgui,'Type','Axes');
    postix=get(PIVlab_axis,'XLim');
    postiy=get(PIVlab_axis,'YLim');
    bg_col=get(auto_focus_active_hint,'BackgroundColor');
    if ~isempty(bg_col)
        if sum(bg_col)==0.75
            bg_col=[0.05 0.05 0.05];
        else
            bg_col=[0.25 0.25 0.25];
        end
        set(auto_focus_active_hint,'BackgroundColor',bg_col);
    else
        bg_col=[0.25 0.25 0.25];
        axes(PIVlab_axis);
        text(postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24,'BackgroundColor',bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');
    end
else
    delete(auto_focus_active_hint);
end

function HistWindow_CloseRequestFcn(hObject,~)
hgui=getappdata(0,'hgui');
setappdata(hgui,'hist_enabled',0);
try
    delete(hObject);
catch
    delete(gcf);
end

function bf_set(src, name, value)
lastwarn('');
src.BFGTLNodeName     = name;
src.BFGTLNodeValueStr = value;
[w, wid] = lastwarn;
if ~isempty(w)
    fprintf('*** BFGTLNode warning: %-30s = %-20s  [%s]\n', name, value, wid);
end
