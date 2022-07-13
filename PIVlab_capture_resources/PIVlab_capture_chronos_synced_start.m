%synchronizer befehl: FREQ:2;CAM:0;ENER:0;ener%:100;F1EXP:0;INTERF:10000;EXTDLY:0;EXTSKP:0;LASER:enable{013}
% nur freq und ener% --> pulslänge in us und interf wird verwendet

function [OutputError] = PIVlab_capture_chronos_synced_start(cameraIP,frameRate)
cmd_delays=0.1;
cameraURL = ['http://' cameraIP];
options = weboptions('MediaType','application/json','HeaderFields',{'Content-Type' 'application/json'});
ima_nr=0;


%% Get data from main GUI
hgui=getappdata(0,'hgui');

OutputError=0;
PIVlab_axis = findobj(hgui,'Type','Axes');

resx=getappdata(hgui,'Chronos_resx');
resy=getappdata(hgui,'Chronos_resy');
bitdepth=getappdata(hgui,'Chronos_bits');


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
response = webwrite([cameraURL '/control/getResolutionTimingLimits'],struct('hRes',1280,'vRes',1024),options);
max_exp=response.exposureMax;
max_fr=1/(response.minFramePeriod/1000/1000/1000);
response2 = webwrite([cameraURL '/control/p'],struct('exposureMode','shutterGating','exposurePeriod', floor(max_exp),'frameRate',max_fr),options);
response = webwrite([cameraURL '/control/set'],struct('ioMapping',struct('shutter',struct('shutterTriggersFrame',0,'source','io1','debounce',0,'invert',0))),options);
% swapped the two above.
pause(cmd_delays)

if strcmp(response2.exposureMode,'shutterGating')
	set(frame_nr_display,'String',['setting external trigger OK!']);drawnow;
else
	set(frame_nr_display,'String',['Error: External trigger could not be set!']);drawnow;
end
response=webread([cameraURL '/control/startLivedisplay']);
pause(cmd_delays)
response=webread([cameraURL '/control/flushRecording']);
pause(cmd_delays)
response=webread([cameraURL '/control/startRecording']);
pause(cmd_delays)

if strcmp(response.state,'recording')
	set(frame_nr_display,'String',['Start record OK!']);drawnow;
else
	set(frame_nr_display,'String',['Error: Recording could not be started!!']);drawnow;
end
delete(frame_nr_display)
