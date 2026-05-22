function [OutputError,OPTRONIS_vid] = PIVlab_capture_OPTRONIS_bitflow_synced_capture(OPTRONIS_vid,nr_of_images,do_realtime,ROI_live,frame_nr_display,bitmode)
fix_Optronis_skipped_frame=0;
hgui=getappdata(0,'hgui');
image_handle_OPTRONIS=getappdata(hgui,'image_handle_OPTRONIS');
OutputError=0;
OPTRONIS_src = getselectedsource(OPTRONIS_vid);

OPTRONIS_frames_to_capture = nr_of_images*2+fix_Optronis_skipped_frame;
set(frame_nr_display,'backgroundcolor','k');
%% capture data
while OPTRONIS_vid.FramesAcquired < (OPTRONIS_frames_to_capture+2) &&  getappdata(hgui,'cancel_capture') ~=1
    %% Stop camera the instant enough frames are in — do this at the TOP of
    %% the loop body, before any slow display operations (drawnow, histogram,
    %% sharpness) that would otherwise let the camera fire hundreds of extra
    %% frames into the DMA ring during the final loop iteration.
    if ~isinf(OPTRONIS_frames_to_capture) && OPTRONIS_vid.FramesAcquired >= (OPTRONIS_frames_to_capture+2)
        %OPTRONIS_src.BFGTLNodeName     = 'AcquisitionStop';
        %OPTRONIS_src.BFGTLNodeValueStr = '1';
        break;
    end
    ima = image_handle_OPTRONIS.CData;

	if ~isinf(OPTRONIS_frames_to_capture)
		if OPTRONIS_vid.FramesAcquired == 0
			set(frame_nr_display,'String','Waiting for trigger...')
		else
			set(frame_nr_display,'String',['Image nr.: ' int2str(round(OPTRONIS_vid.FramesAcquired/2))]);
		end
	else
		set(frame_nr_display,'String','PIV preview');
	end

	%% sharpness indicator
	sharpness_enabled = getappdata(hgui,'sharpness_enabled');
	if sharpness_enabled == 1
        [~,~] = PIVlab_capture_sharpness_indicator (ima,1);
    else
        delete(findobj('tag','sharpness_display_text'));
    end
    crosshair_enabled = getappdata(hgui,'crosshair_enabled');
    if crosshair_enabled == 1
        %% cross-hair
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
            if ~exist ('old_hist_y_limits','var')
                old_hist_y_limits =[0 35000];
            else
                if isvalid(hist_obj)
                    old_hist_y_limits=get(hist_obj.Parent,'YLim');
                end
            end
            parent_ax= findall(hist_fig,'type','axes');
            hist_obj=histogram(ima(1:2:end,1:2:end),'Parent',parent_ax,'binlimits',[0 2^bitmode]);
        end
        if ~exist ('new_hist_y_limits','var')
            new_hist_y_limits =[0 35000];
        end
        new_hist_y_limits=get(hist_obj.Parent,'YLim');
        if isempty (new_hist_y_limits)
            new_hist_y_limits =[0 35000];
        end
        if isempty (old_hist_y_limits)
            old_hist_y_limits =[0 35000];
        end
        set(hist_obj.Parent,'YLim',(new_hist_y_limits*0.5 + old_hist_y_limits*0.5))
    else
        hist_fig=findobj('tag','hist_fig');
        if ~isempty(hist_fig)
            close(hist_fig)
        end
    end
    drawnow limitrate;
    %% Autofocus
    autofocus_enabled = getappdata(hgui,'autofocus_enabled');

    if autofocus_enabled == 1
        delaycounter=delaycounter+1;
    else
        delaycounter=0;
        delaycounter2=0;
        delay_time_1=tic;
    end

    delay_time= 0.5;
    if autofocus_enabled == 1
        if delaycounter>10
            focus_start = getappdata(hgui,'focus_servo_lower_limit');
            focus_end = getappdata(hgui,'focus_servo_upper_limit');
            amount_of_raw_steps=20;
            fine_step_resolution_increase = 8;
            focus_step_raw=round(abs(focus_end - focus_start)/amount_of_raw_steps);
            focus_step_fine=round(1/fine_step_resolution_increase*(abs(focus_end - focus_start)/amount_of_raw_steps));
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
                        [sharpness,~] = PIVlab_capture_sharpness_indicator (ima,0);
                        sharpness_focus_table(sharp_loop_cnt,1)=focus;
                        sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                        focus=focus+focus_step_raw;
                        PIVlab_capture_lensctrl(focus,aperture,lighting)
                        autofocus_notification(1)
                    else
                        %do nothing
                    end
                else
                    [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                    focus_peak=sharpness_focus_table(r(1),1);
                    disp(['Best raw focus: ' num2str(focus_peak)])
                    raw_finished=1;
                    focus_start_fine=focus_peak-6*focus_step_raw;
                    focus_end_fine=focus_peak+3*focus_step_raw;
                    if focus_start_fine < focus_start
                        focus_start_fine = focus_start;
                    end
                    if focus_end_fine > focus_end
                        focus_end_fine = focus_end;
                    end
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
                    if focus < focus_end_fine
                        if toc(delay_time_1)>=delay_time
                            delay_time_1=tic;
                            sharp_loop_cnt=sharp_loop_cnt+1;
                            [sharpness,~] = PIVlab_capture_sharpness_indicator (ima,0);
                            sharpness_focus_table(sharp_loop_cnt,1)=focus;
                            sharpness_focus_table(sharp_loop_cnt,2)=sharpness;
                            focus=focus+focus_step_fine;
                            PIVlab_capture_lensctrl(focus,aperture,lighting)
                            autofocus_notification(1)
                        else
                            %do nothing
                        end
                    else
                        [r,~]=find(sharpness_focus_table == max(sharpness_focus_table(:,2)));
                        focus_peak=sharpness_focus_table(r(1),1);
                        disp(['Best fine focus: ' num2str(focus_peak)])
                        PIVlab_capture_lensctrl(focus_end_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_start_fine,aperture,lighting)
                        pause(0.5)
                        PIVlab_capture_lensctrl(focus_peak,aperture,lighting)

                        setappdata(hgui,'autofocus_enabled',0);

                        lens_control_window = getappdata(0,'hlens');
                        focus_edit_field=getappdata(lens_control_window,'handle_to_focus_edit_field');
                        set(focus_edit_field,'String',num2str(focus_peak));
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
end
%OPTRONIS_src.BFGTLNodeName     = 'AcquisitionStop';
%OPTRONIS_src.BFGTLNodeValueStr = '1';
pause(0.05);
OPTRONIS_src.BFGTLNodeName     = 'EnableFan';
OPTRONIS_src.BFGTLNodeValueStr = 'On';
stop(OPTRONIS_vid);
stoppreview(OPTRONIS_vid)


if ~isinf(OPTRONIS_frames_to_capture)
    set(frame_nr_display,'String',['Image nr.: ' int2str(round(OPTRONIS_vid.FramesAcquired/2))]);
else
    set(frame_nr_display,'String','PIV preview stopped.');
end
drawnow;

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1
    hgui=getappdata(0,'hgui');
    PIVlab_axis = findobj(hgui,'Type','Axes');
    postix=get(PIVlab_axis,'XLim');
    postiy=get(PIVlab_axis,'YLim');
    bg_col=get(auto_focus_active_hint,'BackgroundColor');

    if ~isempty(bg_col)
        if  sum(bg_col)==0.75
            bg_col = [0.05 0.05 0.05];
        else
            bg_col = [0.25 0.25 0.25];
        end
        set(auto_focus_active_hint,'BackgroundColor',bg_col);
    else
        bg_col= [0.25 0.25 0.25];
        axes(PIVlab_axis);
        text(postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24, 'BackgroundColor', bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');
    end
else
    delete(auto_focus_active_hint);
end

function HistWindow_CloseRequestFcn(hObject,~)
try
    hgui=getappdata(0,'hgui');
    setappdata(hgui,'hist_enabled',0);
catch
end
try
    delete(hObject);
catch
    delete(gcf);
end
