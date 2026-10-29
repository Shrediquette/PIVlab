function [OutputError,ima_out,frame_nr_display] = PIVlab_capture_OPTOcam_20_9_calibration_image(img_amount,exposure_time,ROI_OPTOcam)
% Calibration / live image for the OPTOcam 20/9: single frames, manual trigger, continuous preview,
% normal single (non-double) frame. The bit depth follows the OPTOcam 20/9 settings (same pixel format
% as the PIV capture, so the opened camera can be reused, see PIVlab_capture_OPTOcam_20_9_open).
% ima_out is always stretched to the full uint16 range.
% CPU load: the camera sends at most 10 frames/s, the frames are drawn at a limited rate
% (PIVlab_capture_rate_limited_preview, about 40 megapixels per second) and the overlays are computed at
% that rate, not for every camera frame.
OutputError=0;
hgui=getappdata(0,'hgui');
bitmode = gui.camera_setting('OPTOcam_20_9_bits');
if isempty(bitmode)
    bitmode = 8;
end
%% Prepare camera
[OPTOcam_vid,imaq_error] = PIVlab_capture_OPTOcam_20_9_open(bitmode);
if imaq_error~=0
    OutputError=1;
    ima_out=[];
    frame_nr_display=[];
    return
end
OPTOcam_settings = get(OPTOcam_vid);
%Sensor power management (standby/active) intentionally NOT used for now:
%putting the sensor to standby increases its reaction time to software triggers. The sensor is
%left in its default active state.
try
    OPTOcam_settings.Source.DeviceLinkThroughputLimitMode = 'Off';
catch
end
OPTOcam_settings.PreviewFullBitDepth='On';
OPTOcam_vid.PreviewFullBitDepth='On';

triggerconfig(OPTOcam_vid, 'manual');
OPTOcam_settings.TriggerMode ='manual';
try
    OPTOcam_settings.Source.mvShutterMode = 'mvGlobalShutter'; %calibration uses a normal single (non-double) frame
catch
end

%% Line0 = ExposureActive output (used to measure timings/delays on the rig)
OPTOcam_settings.Source.LineSelector = 'Line0';
OPTOcam_settings.Source.LineSource   = 'ExposureActive';
OPTOcam_settings.Source.LineInverter = 'False';

%% Line1 = AcquisitionActive output (used to signal activity on the camera LED and to turn off the fan)
OPTOcam_settings.Source.LineSelector = 'Line1';
OPTOcam_settings.Source.LineSource   = 'AcquisitionActive';
OPTOcam_settings.Source.LineInverter = 'False';

%% Binning (set with the "Binning" button). Must be set BEFORE the ROI: the ROI is in binned pixels.
binning = getappdata(hgui,'binning');
if isempty(binning)
    binning = 1;
end
if OPTOcam_settings.Source.BinningHorizontal ~= binning || OPTOcam_settings.Source.BinningVertical ~= binning
    try
        OPTOcam_vid.ROIPosition = [0 0 OPTOcam_vid.VideoResolution]; %full frame first, so the (reused) camera accepts the new binning
    catch
    end
    OPTOcam_settings.Source.BinningHorizontalMode = 'Average'; %no changes to bitmode, max and min stays the same
    OPTOcam_settings.Source.BinningVerticalMode = 'Average';
    OPTOcam_settings.Source.BinningHorizontal = binning; %1, 2 or 4
    OPTOcam_settings.Source.BinningVertical = binning;
    %MATLAB updates VideoResolution only when an acquisition starts (measured). Without this, a larger
    %ROI is rejected after reducing the binning ("VideoResolution width exceeded").
    start(OPTOcam_vid); stop(OPTOcam_vid);
end

OPTOcam_settings.Source.TriggerMode ='Off';
OPTOcam_settings.Source.ExposureMode ='Timed';
OPTOcam_settings.Source.ExposureTime =exposure_time;
try %at most 10 frames/s from the camera: a live image does not need more, and less data means less CPU load
    OPTOcam_settings.Source.AcquisitionFrameRateEnable = 'True';
    OPTOcam_settings.Source.AcquisitionFrameRate = min(10, 1e6/exposure_time);
catch
end

ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)]; %unfortunaletly different definitions of ROI in pco and OPTOcam.
OPTOcam_vid.ROIPosition=ROI_OPTOcam;

OPTOcam_settings.Source.ReverseX = 'False'; %orientation of the OPTOcam 20/9; change to 'True' if image is mirrored
OPTOcam_settings.Source.ReverseY = 'False';
OPTOcam_gain = gui.camera_setting('OPTOcam_20_9_gain');
if isempty (OPTOcam_gain)
    OPTOcam_gain=0;
end
OPTOcam_settings.Source.Gain = OPTOcam_gain;

%% prepare axis
PIVlab_axis = gui.retr('pivlab_axis');
[image_handles,frame_nr_display] = acquisition.live_images(1,[ROI_OPTOcam(3) ROI_OPTOcam(4)],2^bitmode);
image_handle_OPTOcam = image_handles{1};
setappdata(hgui,'image_handle_OPTOcam_20_9',image_handle_OPTOcam);

%% get images
display_rate = min(10, 40e6/(ROI_OPTOcam(3)*ROI_OPTOcam(4))); %frames per second drawn (full frame: 2/s)
OPTOcam_vid.FramesPerTrigger = 1;
set(frame_nr_display,'String','');
%preview() first shows a placeholder image until the first camera frame arrives (~1.5 s at full frame).
%The callback only receives real frames, so it counts them: needed for the single-image grab (ROI selection).
setappdata(image_handle_OPTOcam,'frames_shown',0);
setappdata(image_handle_OPTOcam,'max_display_rate',display_rate);
setappdata(image_handle_OPTOcam,'UpdatePreviewWindowFcn',@PIVlab_capture_rate_limited_preview);
preview(OPTOcam_vid,image_handle_OPTOcam)
caxis(PIVlab_axis,[0 2^bitmode]); %#ok<CAXIS> seems to be a workaround to force preview to show full data range...
displayed_img_amount=0;
delaycounter=0; %autofocus state
delaycounter2=0;
delay_time_1=tic;
sharpness_focus_table=[];
sharp_loop_cnt=[];
t0 = tic;
next_update = 0;
while getappdata(hgui,'cancel_capture') ~=1 && displayed_img_amount < img_amount
    if toc(t0) < next_update
        pause(0.01); %sleep and process GUI callbacks instead of spinning
        continue
    end
    rate = display_rate;
    if getappdata(hgui,'autofocus_enabled') == 1
        rate = max(display_rate,5); %autofocus: a new frame is needed after each focus step (0.35 s)
    end
    setappdata(image_handle_OPTOcam,'max_display_rate',rate);
    next_update = toc(t0) + 1/rate;
    frames_shown = getappdata(image_handle_OPTOcam,'frames_shown'); %read BEFORE the frame: it is then a real frame if frames_shown >= 1
    acquisition.live_overlays(image_handles,'live'); %sharpness, grid, ChArUco detection
    ima = getappdata(image_handle_OPTOcam,'frame');
    if isempty(ima) %no camera frame yet
        drawnow limitrate;
        continue
    end
    drawnow limitrate;
    %% Autofocus
    %% Lens control
    %Sowieso machen: Nicht lineare schritte für die anzufahrenden fokuspositionen. Diese Liste vorher ausrechnen und dann nur index anspringen

    autofocus_enabled = getappdata(hgui,'autofocus_enabled');

    if autofocus_enabled == 1
        delaycounter=delaycounter+1;
    else
        delaycounter=0;
        delaycounter2=0;
        delay_time_1=tic;
    end
    %immer mehrere Bilder abfragen nachdem fokus verstellt wurde.... nicht nur eins, sondern z.B. drei Davon nur das letzte per sharpness beurteilen

    delay_time= 0.5; %1 seconds delay between measurements %350000 / exposure_time;
    if autofocus_enabled == 1
        if delaycounter>10 %wait 10 images before starting autofocus. Needed so that servo can reach target position
            focus_start = getappdata(hgui,'focus_servo_lower_limit');
            focus_end = getappdata(hgui,'focus_servo_upper_limit');
            amount_of_raw_steps=20;
            fine_step_resolution_increase = 8;
            focus_step_raw=round(abs(focus_end - focus_start)/amount_of_raw_steps);% in microseconds)
            focus_step_fine=round(1/fine_step_resolution_increase*(abs(focus_end - focus_start)/amount_of_raw_steps));% in microseconds)
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
                if focus < focus_end % maxialer focus = endanschlag. Bis zu dem wert wird von null gefahren
                    if toc(delay_time_1)>=delay_time %only every second image is taken for analysis. This gives more time to the servo to reach position
                        delay_time_1=tic;
                        sharp_loop_cnt=sharp_loop_cnt+1;
                        [sharpness,~] = PIVlab_capture_sharpness_indicator (ima,0);
                        sharpness_focus_table(sharp_loop_cnt,1)=focus;
                        sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                        focus=focus+focus_step_raw;
                        PIVlab_capture_lensctrl(focus,aperture,lighting)		%kann steuern und aktuelle position ausgeben
                        autofocus_notification(1)
                    else
                        %do nothing
                    end
                else
                    %assignin('base','sharpness_focus_table',sharpness_focus_table)
                    %find best focus
                    [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                    focus_peak=sharpness_focus_table(r(1),1);
                    disp(['Best raw focus: ' num2str(focus_peak)])
                    raw_finished=1;
                    %focus vs. distance is not linear!
                    focus_start_fine=focus_peak-6*focus_step_raw; %start of finer focussearch
                    focus_end_fine=focus_peak+3*focus_step_raw;
                    if focus_start_fine < focus_start
                        focus_start_fine = focus_start;
                    end
                    if focus_end_fine > focus_end
                        focus_end_fine = focus_end;
                    end
                    %original focus=focus_end_fine;
                    focus=focus_start_fine;
                    PIVlab_capture_lensctrl(focus,aperture,lighting)
                    sharp_loop_cnt=0;
                    raw_data=[sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range')];
                    sharpness_focus_table=zeros(1,2);
                end
            end

            if raw_finished == 1
                delaycounter2=delaycounter2+1;
            else
                delaycounter2=0;
            end


            if raw_finished == 1
                delay_time= 0.35;
                if delaycounter2>10
                    %repeat with finer steps
                    %original if focus > focus_start_fine % maxialer focus = endanschlag. Bis zu dem wert wird von null gefahren
                    if focus < focus_end_fine % maxialer focus = endanschlag. Bis zu dem wert wird von null gefahren
                        if toc(delay_time_1)>=delay_time %only every second image is taken for analysis. This gives more time to the servo to reach position
                            delay_time_1=tic;
                            sharp_loop_cnt=sharp_loop_cnt+1;
                            [sharpness,~] = PIVlab_capture_sharpness_indicator (ima,0);
                            sharpness_focus_table(sharp_loop_cnt,1)=focus;
                            sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                            %original focus=focus-focus_step_fine;
                            focus=focus+focus_step_fine;
                            PIVlab_capture_lensctrl(focus,aperture,lighting)		%kann steuern und aktuelle position ausgeben
                            autofocus_notification(1)
                        else
                            %do nothing
                        end
                    else %fine focus search finished
                        %assignin('base','sharpness_focus_table',sharpness_focus_table)
                        %find best focus
                        [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                        focus_peak=sharpness_focus_table(r(1),1);
                        disp(['Best fine focus: ' num2str(focus_peak)])
                        PIVlab_capture_lensctrl(focus_end_fine,aperture,lighting)%backlash compensation
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_start_fine,aperture,lighting) %backlash compensation
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_peak,aperture,lighting) %set to best focus

                        setappdata(hgui,'autofocus_enabled',0); %autofocus am ende ausschalten

                        lens_control_window = getappdata(0,'hlens');
                        focus_edit_field=getappdata(lens_control_window,'handle_to_focus_edit_field');
                        set(focus_edit_field,'String',num2str(focus_peak)); %update
                        %setappdata(hgui,'cancel_capture',1); %stop recording....?
                        figure;plot(raw_data(:,1),raw_data(:,2),'Linewidth',2)
                        hold on;plot(sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range'),'Linewidth',2);hold off
                        title('Focus search')
                        xlabel('Pulsewidth us')
                        ylabel('Sharpness')
                        legend('Coarse search','Fine search')
                        grid on

                    end
                end
            end
        end
    else
        autofocus_notification(0)
        sharpness_focus_table=[];
        sharp_loop_cnt=[];
    end
    displayed_img_amount = frames_shown; %real camera frames (placeholder not counted)
end
stoppreview(OPTOcam_vid)
ima_out = bitshift(uint16(getappdata(image_handle_OPTOcam,'frame')),16-bitmode); %stretch 8 or 12 bit to the full 16 bit range

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1

    hgui=getappdata(0,'hgui');
    PIVlab_axis = gui.retr('pivlab_axis');
    %image_handle_OPTOcam=getappdata(hgui,'image_handle_OPTOcam');
    postix=get(PIVlab_axis,'XLim');
    postiy=get(PIVlab_axis,'YLim');
    bg_col=get(auto_focus_active_hint,'BackgroundColor'); % Toggle background color while autofocus is active

    if ~isempty(bg_col)
        if  sum(bg_col)==0.75 %hint is currently displayed
            bg_col = [0.05 0.05 0.05];
        else
            bg_col = [0.25 0.25 0.25];
        end
        set(auto_focus_active_hint,'BackgroundColor',bg_col);
    else
        bg_col= [0.25 0.25 0.25];
        text(PIVlab_axis,postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24, 'BackgroundColor', bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');

    end
else
    delete(auto_focus_active_hint);
end
