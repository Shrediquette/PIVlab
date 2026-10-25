function [OutputError,OPTOcam_vid] = PIVlab_capture_OPTOcam_synced_capture(OPTOcam_vid,nr_of_images,do_realtime,ROI_live,frame_nr_display,bitmode) %#ok<INUSD>
%Waits until one OPTOcam 2/80, or both cameras of a stereo setup, captured nr_of_images image pairs (Inf = PIV
%preview until Stop) and shows the latest frames.
%OPTOcam_vid: cell array with one videoinput per camera (PIVlab_capture_OPTOcam_synced_start).
%preview() is not used: the latest frame of each camera is shown with peekdata, 5 times per second while
%recording and 10 times per second in PIV preview, downsampled to about 1280 pixels width per camera. Drawing
%every frame in the PIVlab window causes a high CPU load and skipped frames (same approach as the OPTRONIS driver).
if ~iscell(OPTOcam_vid)
	OPTOcam_vid = {OPTOcam_vid};
end
n_cameras = numel(OPTOcam_vid);
warning('off','imaq:gentl:noSupportedPixelFormat')
hgui=getappdata(0,'hgui');
image_handles=getappdata(hgui,'image_handles_OPTOcam');
OutputError=0;
OPTOcam_frames_to_capture = nr_of_images*2;
set(frame_nr_display,'backgroundcolor','k');
is_preview = isinf(OPTOcam_frames_to_capture); %PIV preview: endless acquisition, frames are discarded with flushdata
if ~is_preview
	update_interval = 1/5;
else
	update_interval = 1/10;
end
t0 = tic;
next_update = 0;
delaycounter=0; %autofocus state
delaycounter2=0;
delay_time_1=tic;
sharpness_focus_table=[];
sharp_loop_cnt=[];
%% capture data
while frames_acquired(OPTOcam_vid) < OPTOcam_frames_to_capture && getappdata(hgui,'cancel_capture') ~=1
	if toc(t0) < next_update
		if is_preview
			for k=1:n_cameras
				if OPTOcam_vid{k}.FramesAvailable > 50
					flushdata(OPTOcam_vid{k}); %keep RAM usage low when the loop was blocked for a while
				end
			end
		end
		pause(0.01); %sleep and process GUI callbacks instead of spinning
		continue
	end
	next_update = toc(t0) + update_interval;
	acquired = frames_acquired(OPTOcam_vid);
	for k=1:n_cameras
		if OPTOcam_vid{k}.FramesAvailable > 0
			ima = peekdata(OPTOcam_vid{k},1); %full resolution for the overlays
			if is_preview
				flushdata(OPTOcam_vid{k}); %frames are not saved in PIV preview
			end
			ds = max(1,ceil(size(ima,2)/1280)); %downsampling factor of the displayed image
			acquisition.show_frame(image_handles{k},ima,ds);
		end
	end
	if is_preview
		set(frame_nr_display,'String','PIV preview');
	elseif acquired == 0
		set(frame_nr_display,'String','Waiting for trigger...')
	else
		set(frame_nr_display,'String',['Image nr.: ' int2str(round(acquired/2))]);
	end
	acquisition.live_overlays(image_handles,'capture'); %sharpness, grid
	ima = getappdata(image_handles{1},'frame');
	if n_cameras == 1 && ~isempty(ima) %autofocus: one camera (one lens controller)
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
	end
	drawnow limitrate;
end

for k=1:n_cameras
	stop(OPTOcam_vid{k});
	try
		executeCommand(OPTOcam_vid{k}.Source,"BslSensorOff")
	catch %not available with the 'mwgentlimaq' adaptor
	end
end
disp('Sending sensor to sleep mode.')

if ~is_preview
    set(frame_nr_display,'String',['Image nr.: ' int2str(round(frames_acquired(OPTOcam_vid)/2))]);
else
    set(frame_nr_display,'String','PIV preview stopped.');
end
drawnow;

function acquired = frames_acquired(OPTOcam_vid)
%frames of the slower camera
acquired = inf;
for k=1:numel(OPTOcam_vid)
	acquired = min(acquired,OPTOcam_vid{k}.FramesAcquired);
end

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1
    hgui=getappdata(0,'hgui');
    PIVlab_axis = gui.retr('pivlab_axis');
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
