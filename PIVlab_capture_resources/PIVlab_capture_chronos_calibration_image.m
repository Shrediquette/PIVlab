%synchronizer befehl: FREQ:2;CAM:0;ENER:0;ener%:100;F1EXP:0;INTERF:10000;EXTDLY:0;EXTSKP:0;LASER:enable{013}
% nur freq und ener% --> pulslänge in us und interf wird verwendet

function [OutputError,ima,frame_nr_display] = PIVlab_capture_chronos_calibration_image(cameraIP,exposure_time)

cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});
ima_nr=0;

hgui=getappdata(0,'hgui');
resx=getappdata(hgui,'Chronos_resx');
resy=getappdata(hgui,'Chronos_resy');
bitdepth=getappdata(hgui,'Chronos_bits');

%% Get data from main GUI
hgui=getappdata(0,'hgui');
crosshair_enabled = getappdata(hgui,'crosshair_enabled');


OutputError=0;
PIVlab_axis = findobj(hgui,'Type','Axes');

image_handle_chronos=imagesc(zeros(resy,resx),'Parent',PIVlab_axis,[0 2^16]);
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

%% prepare camera
response=webread([cameraURL '/control/stopRecording']); %stop in any case
pause(0.1)
response=webread([cameraURL '/control/flushRecording']); %discard data in RAM
% set to max resolution
disp('schien ganz gut zu gehen ohne jedesmal resolution zu setzen...?')
%%{


dataInside = struct('hRes', resx, 'vRes', resy, 'bitDepth', bitdepth);
dataOutside = struct('resolution', dataInside);
% Change resolution via an HTTP POST request.
response = webwrite([cameraURL '/control/p'],dataOutside,options);
if response.resolution.hRes==resx && response.resolution.vRes==resy && response.resolution.bitDepth==bitdepth
	set(frame_nr_display,'String',['Setting resolution OK!']);drawnow;
else
	set(frame_nr_display,'String',['Error: Resolution could not be set!']);drawnow;
end
%%}

%% live display with 2.2Hz, 8 bit for calibration images
%set to internal trigger
exposure_us=exposure_time;
exposureNormalized=1.0;
frameRate = 1/(exposure_us/1000/1000);
if frameRate > 1000
	exposureNormalized = 1000/frameRate;
	frameRate=1000;
end


response = webwrite([cameraURL '/control/set'],struct('ioMapping',struct('shutter',struct('shutterTriggersFrame',0,'source','none','debounce',0,'invert',0))),options);
response = webwrite([cameraURL '/control/p'],struct('exposureMode','normal','exposureNormalized', exposureNormalized,'frameRate',frameRate),options); %needs to be set twice to work properly...
if strcmp(response.exposureMode,'normal')
	set(frame_nr_display,'String',['Setting calibration image mode OK!']);drawnow;
else
	set(frame_nr_display,'String',['Error: calibration image mode could not be set!']);drawnow;
end
response=webread([cameraURL '/control/startLivedisplay']); %set to live display mode
while getappdata(hgui,'cancel_capture') ~=1
	ima=webread([cameraURL '/cgi-bin/screenCap']);
	set(image_handle_chronos,'CData',ima);
	set(frame_nr_display,'String','');
	sharpness_enabled = getappdata(hgui,'sharpness_enabled');
	if sharpness_enabled == 1 % sharpness indicator
		textx=1240;
		texty=950;
		[~,~] = PIVlab_capture_sharpness_indicator (ima,textx,texty);
	else
		delete(findobj('tag','sharpness_display_text'));
	end
	drawnow limitrate
	ima_nr=ima_nr+1;
end
