%synchronizer befehl: FREQ:2;CAM:0;ENER:0;ener%:100;F1EXP:0;INTERF:10000;EXTDLY:0;EXTSKP:0;LASER:enable{013}
% nur freq und ener% --> pulslänge in us und interf wird verwendet

function [OutputError,ima,frame_nr_display] = PIVlab_capture_chronos_synced_capture(cameraIP,nr_of_images,framerate,do_realtime,ROI_live)

cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});


%% Get data from main GUI
hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');


OutputError=0;
PIVlab_axis = findobj(hgui,'Type','Axes');
ima=zeros(1024,1280);
image_handle_chronos=imagesc(ima,'Parent',PIVlab_axis,[0 2^16]);

setappdata(hgui,'image_handle_chronos',image_handle_chronos);
frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0],'Interpreter','none');
colormap default %reset colormap steps
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar
drawnow;

elapsed_time=0;
delay_time_frametime=tic;
while elapsed_time<(nr_of_images/framerate) && getappdata(hgui,'cancel_capture') ~=1 %wait until time for n images has passed...

	%update live display
	warning off
	ima=(webread([cameraURL '/cgi-bin/screenCap']));
	warning on
	ima=double(ima(:,:,1))/255*65535;
	set(image_handle_chronos,'CData',ima);
	sharpness_enabled = getappdata(hgui,'sharpness_enabled');
	if sharpness_enabled == 1 % sharpness indicator
		textx=1240;
		texty=950;
		[~,~] = PIVlab_capture_sharpness_indicator (ima,textx,texty);
	else
		delete(findobj('tag','sharpness_display_text'));
	end



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
						[sharpness,~] = PIVlab_capture_sharpness_indicator (ima,[],[]);
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
							[sharpness,~] = PIVlab_capture_sharpness_indicator (ima,[],[]);
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
						figure;plot(raw_data(:,1),raw_data(:,2))
						hold on;plot(sharpness_focus_table(:,1),normalize(sharpness_focus_table(:,2),'range'));hold off
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




	if getappdata(hgui,'laser_running')==1
		elapsed_time = elapsed_time + toc(delay_time_frametime);
	end
	delay_time_frametime=tic;

	set(frame_nr_display,'String',['Image nr.: ' int2str(elapsed_time*framerate)]);
	drawnow limitrate
end
response=webread([cameraURL '/control/stopRecording']);
pause(0.5)
response=webread([cameraURL '/control/startPlayback']);
pause(0.1)

function autofocus_notification(running)
auto_focus_active_hint=findobj('tag', 'auto_focus_active');
if running == 1

	hgui=getappdata(0,'hgui');
	PIVlab_axis = findobj(hgui,'Type','Axes');
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
		axes(PIVlab_axis);
		text(postix(2)/2,postiy(2)/2,'Autofocus running, please wait...','HorizontalAlignment','center','VerticalAlignment','middle','color','y','fontsize',24, 'BackgroundColor', bg_col,'tag','auto_focus_active','margin',10,'Clipping','on');

	end
else
	delete(auto_focus_active_hint);
end
