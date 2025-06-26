function straddling_graph_oltsync(timing_table,frame_time,cam_delay,camera_principle,camera_type)
%zeilen: die verschiedenen pins; spalten:die zeiten
bot_cam = 0.45;
bot_las = 0.2;
amp = 0.2;
num_reps=2;

triggermode=gui.retr('oltSync_triggermode');
if isempty(triggermode)
	triggermode='internal'; %%internal activehigh %singlerising
	gui.put('oltSync_triggermode',triggermode)
end

straddling_figure=findobj('tag','straddling_figure');
if isempty(straddling_figure)
	hf = figure('numbertitle','off','MenuBar','figure','DockControls','off','Name',['Camera exposure and pulse timing visualization - ' camera_type],'Toolbar','figure','CloseRequestFcn', @straddling_figure_CloseRequestFcn,'tag','straddling_figure','visible','on');
else
	hf = figure(straddling_figure);
	clf(hf)
end
drawnow %drawing the annotations below takes ages.... Therefore directly display the empty figure to show some progress...
pause(1)
axh=axes(hf);
axis tight
%xlim([0 period*num_exposures_to_show])
ylim([0 1])
xlabel('time in µs')
ylabel([])
yticks([])

%remove unnecessary Toolbar stuff
% Get a handle to the standard plot toolbar.
tbh = findall(hf,'Type','uitoolbar');
% Get handles to each button we don't want on the standard toolbar and DELETE
ptPlotToolsOn    = findall(hf,'Tag','Plottools.PlottoolsOn');     delete(ptPlotToolsOn);
ptPlotToolsOff   = findall(hf,'Tag','Plottools.PlottoolsOff');    delete(ptPlotToolsOff);
ttInsertLegend   = findall(hf,'Tag','Annotation.InsertLegend');   delete(ttInsertLegend);
ttInsertColorbar = findall(hf,'Tag','Annotation.InsertColorbar'); delete(ttInsertColorbar);
ttLinking        = findall(hf,'Tag','DataManager.Linking');       delete(ttLinking);
ttRotate         = findall(hf,'Tag','Exploration.Rotate');        delete(ttRotate);
ttEditPlot       = findall(hf,'Tag','Standard.EditPlot');         delete(ttEditPlot);
ttEditPlot       = findall(hf,'Tag','Standard.PropertyInspector');         delete(ttEditPlot);
ttEditPlot       = findall(hf,'Tag','Standard.OpenInspector');         delete(ttEditPlot);
ptPrintFigure    = findall(hf,'Tag','Standard.PrintFigure');      delete(ptPrintFigure);
ptSaveFigure     = findall(hf,'Tag','Standard.SaveFigure');       delete(ptSaveFigure);
ptFileOpen       = findall(hf,'Tag','Standard.FileOpen');         delete(ptFileOpen);
ptNewFigure      = findall(hf,'Tag','Standard.NewFigure');        delete(ptNewFigure);
delete(findall(hf,'Tag','figMenuHelp'))
delete(findall(hf,'Tag','figMenuWindow'))
delete(findall(hf,'Tag','figMenuDesktop'))
delete(findall(hf,'Tag','figMenuTools'))
delete(findall(hf,'Tag','figMenuInsert'))
delete(findall(hf,'Tag','figMenuView'))
delete(findall(hf,'Tag','figMenuEdit'))
hold on;
%% cycle
%plot([0 0],[0 1],'k--')
%plot([frame_time frame_time],[0 1],'k--')

%% camera
if strcmp(camera_principle,'double_shutter') %double shutter camera triggers second frame internally. This isn't included in the timing_table, so wee add this behaviour here
	timing_table{1,2}=timing_table{1,2}-cam_delay; % the graph below will add cam delay to all camera signals. But the falling edge of the cam doesn't have a delay, so I am removing it here.
	timing_table{1,3}=timing_table{1,2}+1;
	timing_table{1,4}=timing_table{1,3}+5000; %actually the length of the second exposure depends on the read out time of the frames. This is something only the camera knows, so we guess a time. It is for illustration only anyway.
end
x_var=[];
y_var=[];
for i=0:num_reps-1
	x_var= [x_var (i*frame_time +[timing_table{1,1} timing_table{1,1} timing_table{1,2} timing_table{1,2} timing_table{1,3} timing_table{1,3} timing_table{1,4} timing_table{1,4}])];
	y_var= [y_var [bot_cam bot_cam+amp bot_cam+amp bot_cam bot_cam bot_cam+amp bot_cam+amp bot_cam]];
	% if numel(y_var)>numel(x_var)
	% 	y_var(numel(x_var)+1:end)=[];
	% end
end
if strcmp(camera_principle,'double_shutter') %frame_time in dbl shutter doesnt have two exposures, therefore line at the end is missing
	x_var(end+1)=frame_time*num_reps;
	y_var(end+1)=bot_cam;
end
%add low signal before start
pretriggerx=[-frame_time/10 0];
pretriggery=[bot_cam bot_cam];

plot([pretriggerx round(x_var+cam_delay)] ,[pretriggery y_var],'b-') %cam_delay is subtracted, to show the true camera exposure instead of the trigger signal



%% laser
x_var=[];
y_var=[];
for i=0:num_reps-1
	x_var=[x_var (i*frame_time +[0         timing_table{2,1} timing_table{2,1} timing_table{2,2} timing_table{2,2} timing_table{2,3} timing_table{2,3} timing_table{2,4} timing_table{2,4} frame_time])];
	y_var =[y_var [bot_las    bot_las              bot_las+amp      bot_las+amp        bot_las         bot_las       bot_las+amp        bot_las+amp       bot_las         bot_las]];
end
%add low signal before start
pretriggerx=[-frame_time/10 0];
pretriggery=[bot_las bot_las];

plot([pretriggerx round(x_var)] ,[pretriggery y_var])

%% display trigger position
if strcmpi(triggermode,'internal')
	%do nothing
elseif strcmpi(triggermode,'activehigh') || strcmpi(triggermode,'startrising')
	plot([0 0],[0 1],'k--')
	text(0,0.05,'trigger','Rotation',90,'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',8)
elseif strcmpi(triggermode,'singlerising')
	plot([0 0],[0 1],'k--')
	plot([frame_time  frame_time],[0 1],'k--')
	text(0,0.05,'ext. trigger 1','Rotation',90,'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',8)
	text(frame_time,0.05,'ext. trigger 2','Rotation',90,'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',8)
end


%% Pulse_length
start_of_pulse1 = timing_table{2,1};
end_of_pulse1 = timing_table{2,2};
start_of_pulse2 = timing_table{2,3};
end_of_pulse2 = timing_table{2,4};
start_of_pulse3 = timing_table{2,1} + frame_time;
end_of_pulse3 = timing_table{2,2} + frame_time;
start_of_pulse4 = timing_table{2,3} + frame_time;
end_of_pulse4 = timing_table{2,4} + frame_time;
pulse_length = end_of_pulse1 - start_of_pulse1;
pulse_distance = start_of_pulse2 - start_of_pulse1;

ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
ha.Parent=hf.CurrentAxes;

if strcmp(camera_principle,'normal_shutter')
	ha.X=[start_of_pulse2 end_of_pulse2];
	ha.Y=[bot_las-0.01 bot_las-0.01];
	plot ([start_of_pulse1 start_of_pulse1], [bot_las-0.01 bot_las],'LineStyle','--','Color',[1 0.7 0.7])
	plot ([end_of_pulse1 end_of_pulse1], [bot_las-0.01 bot_las],'LineStyle','--','Color',[1 0.7 0.7])
	text((start_of_pulse1+end_of_pulse1)/2,bot_las-0.01,{'Pulse length' [num2str(pulse_length) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
elseif strcmp(camera_principle,'double_shutter')
	ha.X=[start_of_pulse3 end_of_pulse3];
	ha.Y=[bot_las-0.01 bot_las-0.01];
	plot ([start_of_pulse3 start_of_pulse3], [bot_las-0.01 bot_las],'LineStyle','--','Color',[1 0.7 0.7])
	plot ([end_of_pulse3 end_of_pulse3], [bot_las-0.01 bot_las],'LineStyle','--','Color',[1 0.7 0.7])
	text((start_of_pulse3+end_of_pulse3)/2,bot_las-0.01,{'Pulse length' [num2str(pulse_length) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
end

%% Pulse distance
ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
ha.Parent=hf.CurrentAxes;
if strcmp(camera_principle,'normal_shutter')
	ha.X=[(start_of_pulse1+end_of_pulse1)/2 (start_of_pulse2+end_of_pulse2)/2];
	ha.Y=[bot_las-0.1 bot_las-0.1];
	plot ([(start_of_pulse1+end_of_pulse1)/2 (start_of_pulse1+end_of_pulse1)/2], [bot_las-0.1 bot_las+amp-0.01],'LineStyle','--','Color',[1 0.7 0.7])
	plot ([(start_of_pulse2+end_of_pulse2)/2 (start_of_pulse2+end_of_pulse2)/2], [bot_las-0.1 bot_las+amp-0.01],'LineStyle','--','Color',[1 0.7 0.7])
	text(((start_of_pulse1+end_of_pulse1)/2 + (start_of_pulse2+end_of_pulse2)/2)/2,bot_las-0.1,{'Pulse distance' [num2str(pulse_distance) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
elseif strcmp(camera_principle,'double_shutter')
	ha.X=[(start_of_pulse3+end_of_pulse3)/2 (start_of_pulse4+end_of_pulse4)/2];
	ha.Y=[bot_las-0.1 bot_las-0.1];
	plot ([(start_of_pulse3+end_of_pulse3)/2 (start_of_pulse3+end_of_pulse3)/2], [bot_las-0.1 bot_las+amp-0.01],'LineStyle','--','Color',[1 0.7 0.7])
	plot ([(start_of_pulse4+end_of_pulse4)/2 (start_of_pulse4+end_of_pulse4)/2], [bot_las-0.1 bot_las+amp-0.01],'LineStyle','--','Color',[1 0.7 0.7])
	text(((start_of_pulse3+end_of_pulse3)/2 + (start_of_pulse4+end_of_pulse4)/2)/2,bot_las-0.1,{'Pulse distance' [num2str(pulse_distance) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
end

%% frame rate annotation
if strcmp(camera_principle,'normal_shutter')
	period=frame_time/2;
	frame_rate=1/frame_time*1000^2*2;
	ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
	ha.Parent=hf.CurrentAxes;
	ha.X=[period+cam_delay period*2+cam_delay];
	ha.Y=[bot_cam-0.01 bot_cam-0.01];
	plot ([period+cam_delay period+cam_delay], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	plot ([period*2+cam_delay period*2+cam_delay], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	text(period*1.5+cam_delay,bot_cam-0.01,{'Frame rate' [num2str(frame_rate) ' Hz'] [num2str(period) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
elseif strcmp(camera_principle,'double_shutter')
	period=frame_time;
	frame_rate=1/frame_time*1000^2;
	ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
	ha.Parent=hf.CurrentAxes;
	ha.X=[start_of_pulse1  start_of_pulse1+period];
	ha.Y=[bot_cam-0.01 bot_cam-0.01];
	plot ([start_of_pulse1 start_of_pulse1], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	plot ([start_of_pulse1+period start_of_pulse1+period], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	text(period*0.5,bot_cam-0.01,{'Double frame rate' [num2str(frame_rate) ' Hz'] [num2str(period) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
end

%% info top left
duty_cycle=pulse_length*2/(frame_time);
if strcmp(camera_principle,'normal_shutter')
	text(period/10,0.99,{['Laser duty cycle: ' num2str(round(duty_cycle*100,4)) ' %'] ['PIV data rate: ' num2str(frame_rate/2) ' Hz']},'HorizontalAlignment','left','VerticalAlignment','top')
	%info top right
	infotxt=text((num_reps+2)*period,0.99,{' Use zoom buttons to see the details '},'HorizontalAlignment','right','VerticalAlignment','top');
	margin=period/20*0;
	smallmargin=margin/2*0;
	for i=0:2:num_reps+1
		ha=annotation('textbox',[0,0,0,0],'String',['Image Pair ' num2str(i/2+1)],'HorizontalAlignment','center','VerticalAlignment','top','BackgroundColor','k','FaceAlpha',0.1);
		ha.Parent=hf.CurrentAxes;
		ha.Position=[0+margin+  period* i           bot_cam+amp+0.04              period*2-margin*2                 0.175];

		ha=annotation('textbox',[0,0,0,0],'String',{'Image A' ['PIVlab_' sprintf('%3.3d',i/2) '_A.tif']},'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor','k','FaceAlpha',0.1,'LineStyle','-','FontSize',8,'Interpreter','none');
		ha.Parent=hf.CurrentAxes;
		ha.Position=[0+margin+smallmargin + period* i              bot_cam+amp+0.05                period-margin*2-smallmargin*2               0.1];

		ha=annotation('textbox',[0,0,0,0],'String',{'Image B' ['PIVlab_' sprintf('%3.3d',i/2) '_B.tif']},'HorizontalAlignment','center','VerticalAlignment','middle','BackgroundColor','k','FaceAlpha',0.1,'LineStyle','-','FontSize',8,'Interpreter','none');
		ha.Parent=hf.CurrentAxes;
		ha.Position=[period+margin+smallmargin + period* i                    bot_cam+amp+0.05              period-margin*2-smallmargin*2              0.1];
	end
elseif strcmp(camera_principle,'double_shutter')
	text(period/10,0.99,{['Laser duty cycle: ' num2str(round(duty_cycle*100,4)) ' %'] ['PIV data rate: ' num2str(frame_rate) ' Hz']},'HorizontalAlignment','left','VerticalAlignment','top')
	%info top right
	infotxt=text((num_reps+2)*period*0.5,0.99,{' Use zoom buttons to see the details '},'HorizontalAlignment','right','VerticalAlignment','top');
	margin=period/20*0;
	smallmargin=margin/2*0;
	for i=0:2:num_reps+1
		ha=annotation('textbox',[0,0,0,0],'String',['Image Pair ' num2str(i/2+1)],'HorizontalAlignment','center','VerticalAlignment','top','BackgroundColor','k','FaceAlpha',0.1);
		ha.Parent=hf.CurrentAxes;
		ha.Position=[0+margin+  period* i*0.5           bot_cam+amp+0.04              period*1-margin*2                 0.175];
	end
end
if strcmpi(triggermode,'singlerising')
	newtxt=get(infotxt,'String');
	%text((num_reps+2)*period,0.99,['Max. trigger rate = ' num2str(round(1/(frame_time/1000^2)))],'Rotation',0,'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',8)
	newtxt{2}=['Max. trigger rate = ' num2str(round(1/(frame_time/1000^2))) ' Hz '];
	set(infotxt,'String',newtxt);
end

hold off;
legend({'Camera Exposure', 'Laser Active'},'Location','southeast')
set(gca,'InnerPosition',[0.01 0.1 0.98 0.9])
end

function straddling_figure_CloseRequestFcn(hObject, ~, ~)
try
	handles=guihandles(getappdata(0,'hgui')); %#ok<*NASGU>
	set(handles.ac_enable_straddling_figure,'Value',0);
	delete(hObject);
catch
	delete(gcf);
end
end
