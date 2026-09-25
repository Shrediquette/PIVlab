function [OutputError,ima_out,frame_nr_display] = PIVlab_capture_OPTOcam_20_9_calibration_image(img_amount,exposure_time,ROI_OPTOcam)
% Calibration / live image for the OPTOcam 20/9: single frames, manual trigger, continuous preview,
% normal single (non-double) frame. The bit depth follows the OPTOcam 20/9 settings (same pixel format
% as the PIV capture, so the opened camera can be reused, see PIVlab_capture_OPTOcam_20_9_open).
% ima_out is always stretched to the full uint16 range.
OutputError=0;
hgui=getappdata(0,'hgui');
bitmode = getappdata(hgui,'OPTOcam_20_9_bits');
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

OPTOcam_settings.Source.TriggerMode ='Off';
OPTOcam_settings.Source.ExposureMode ='Timed';
OPTOcam_settings.Source.ExposureTime =exposure_time;

ROI_OPTOcam=[ROI_OPTOcam(1)-1,ROI_OPTOcam(2)-1,ROI_OPTOcam(3),ROI_OPTOcam(4)]; %unfortunaletly different definitions of ROI in pco and OPTOcam.
OPTOcam_vid.ROIPosition=ROI_OPTOcam;

OPTOcam_settings.Source.ReverseX = 'False'; %orientation of the OPTOcam 20/9; change to 'True' if image is mirrored
OPTOcam_settings.Source.ReverseY = 'False';
OPTOcam_gain = getappdata(hgui,'OPTOcam_20_9_gain');
if isempty (OPTOcam_gain)
    OPTOcam_gain=0;
end
OPTOcam_settings.Source.Gain = OPTOcam_gain;

%% prapare axis

crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
PIVlab_axis = gui.retr('pivlab_axis');

%image_handle_OPTOcam=imagesc(zeros(OPTOcam_settings.VideoResolution(2),OPTOcam_settings.VideoResolution(1)),'Parent',PIVlab_axis,[0 2^8]);

image_handle_OPTOcam=imagesc(zeros(ROI_OPTOcam(4),ROI_OPTOcam(3)),'Parent',PIVlab_axis,[0 2^bitmode]);

setappdata(hgui,'image_handle_OPTOcam_20_9',image_handle_OPTOcam);

frame_nr_display=text(PIVlab_axis,100,100,'Initializing...','Color',[1 1 0]);
colormap(ancestor(PIVlab_axis,'figure'),'default') %reset colormap steps
new_map=colormap(ancestor(PIVlab_axis,'figure'),'gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(ancestor(PIVlab_axis,'figure'),new_map);axis(PIVlab_axis,'image');
set(PIVlab_axis,'ytick',[])
set(PIVlab_axis,'xtick',[])
colorbar(PIVlab_axis)


%% get images
OPTOcam_vid.FramesPerTrigger = 1;
set(frame_nr_display,'String','');
%preview() first shows a placeholder image until the first camera frame arrives (~1.5 s at full frame).
%The callback only receives real frames, so it counts them: needed for the single-image grab (ROI selection).
setappdata(image_handle_OPTOcam,'frames_shown',0);
setappdata(image_handle_OPTOcam,'UpdatePreviewWindowFcn',@PIVlab_capture_count_preview_frames);
preview(OPTOcam_vid,image_handle_OPTOcam)
caxis([0 2^bitmode]); %seems to be a workaround to force preview to show full data range...
displayed_img_amount=0;
while getappdata(hgui,'cancel_capture') ~=1 && displayed_img_amount < img_amount
    frames_shown = getappdata(image_handle_OPTOcam,'frames_shown'); %read BEFORE CData: ima is then a real frame if frames_shown >= 1
    ima = image_handle_OPTOcam.CData;
    ima_out = bitshift(uint16(ima),16-bitmode); %stretch 8 or 12 bit to the full 16 bit range
    %% live charuco
    do_charuco_detection = gui.retr('do_charuco_detection');
    if isempty(do_charuco_detection)
        do_charuco_detection=0;
    end
    if do_charuco_detection
        PIVlab_capture_charuco_detector(ima_out,PIVlab_axis,image_handle_OPTOcam);
    end

    %% sharpness indicator
    sharpness_enabled = getappdata(hgui,'sharpness_enabled');
    if sharpness_enabled == 1 % sharpness indicator
        [~,~] = PIVlab_capture_sharpness_indicator (ima,1);
    else
        delete(findobj('tag','sharpness_display_text'));
    end
    crosshair_enabled = getappdata(hgui,'crosshair_enabled');
    if crosshair_enabled == 1 %cross-hair
        %% cross-hair
        locations=[0.15 0.5 0.85];
        half_thickness=1;
        brightness_incr=round(101/2^(12-bitmode)); %101 at 12 bit
        ima_ed=ima;
        old_max=max(ima(:));
        for loca=locations
            %vertical
            ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)=ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)+brightness_incr;
            %horizontal
            ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)=ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)+brightness_incr;
        end
        ima_ed(ima_ed>old_max)=old_max;
        set(image_handle_OPTOcam,'CData',ima_ed);
    end
    %% HISTOGRAM
    if getappdata(hgui,'hist_enabled')==1
        if isvalid(image_handle_OPTOcam)
            hist_fig=findobj('tag','hist_fig');
            if isempty(hist_fig)
                hist_fig=figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Live histogram','Toolbar','none','tag','hist_fig','CloseRequestFcn', @HistWindow_CloseRequestFcn);
            end
            if ~exist ('old_hist_y_limits','var')
                old_hist_y_limits =[0 35000];
            else
                if isvalid(hist_obj)
                    old_hist_y_limits=get(hist_obj.Parent,'YLim');
                end
            end
            hist_obj=histogram(ima(1:2:end,1:2:end),'Parent',hist_fig,'binlimits',[0 2^bitmode]);
        end
        %lowpass hist y limits for better visibility
        if ~exist ('new_hist_y_limits','var')
            new_hist_y_limits =[0 35000];
        end
        new_hist_y_limits=get(hist_obj.Parent,'YLim');
        set(hist_obj.Parent,'YLim',(new_hist_y_limits*0.5 + old_hist_y_limits*0.5))
    else
        hist_fig=findobj('tag','hist_fig');
        if ~isempty(hist_fig)
            close(hist_fig)
        end
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

function HistWindow_CloseRequestFcn(hObject,~)
hgui=getappdata(0,'hgui');
setappdata(hgui,'hist_enabled',0);
try
    delete(hObject);
catch
end
