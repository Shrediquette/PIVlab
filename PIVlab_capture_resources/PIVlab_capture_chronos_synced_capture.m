%synchronizer befehl: FREQ:2;CAM:0;ENER:0;ener%:100;F1EXP:0;INTERF:10000;EXTDLY:0;EXTSKP:0;LASER:enable{013}
% nur freq und ener% --> pulslänge in us und interf wird verwendet

function [OutputError,ima,frame_nr_display] = PIVlab_capture_chronos_synced_capture(cameraIP,nr_of_images,exposure_time,framerate,do_realtime,ROI_live)

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
delay_time_1=tic;
while elapsed_time<(nr_of_images/framerate) && getappdata(hgui,'cancel_capture') ~=1 %wait until time for n images has passed...
	
	%update live display
	ima=(webread([cameraURL '/cgi-bin/screenCap']));
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
	%elapsed_time=toc(delay_time_1);
	if getappdata(hgui,'laser_running')==1
		elapsed_time = elapsed_time + toc(delay_time_1);
	end
	delay_time_1=tic;

	set(frame_nr_display,'String',['Image nr.: ' int2str(elapsed_time*framerate)]);
	drawnow limitrate
end
response=webread([cameraURL '/control/stopRecording']);
pause(0.5)
response=webread([cameraURL '/control/startPlayback']);
pause(0.1)

