function straddling_graph(blind_time,frame_rate,pulse_distance,laser_energy,num_exposures_to_show,is_dbl_shutter,f1exp_cam)
if is_dbl_shutter % a double shutter camera like the pco panda and pixelfly capture 2 images for each frame.
	frame_rate=frame_rate*2;
end
period = 1/frame_rate*1000^2; % µs
cam_on = period-blind_time; % µs
pulse_length = laser_energy/100*pulse_distance; % µs
max_possible_pulse_distance = pulse_distance - (1/frame_rate*1000^2-cam_on); % µs
if pulse_length > max_possible_pulse_distance
	pulse_length = max_possible_pulse_distance;
end
duty_cycle=pulse_length/period;
if duty_cycle > 0.5
	pulse_length = period / 2;
	duty_cycle=pulse_length/period;
end

exposure_active_x=[];
exposure_active_y=[];
laser_active_x=[];
laser_active_y=[];

start_of_pulse1 = period-pulse_distance/2-pulse_length/2-blind_time/2;
end_of_pulse1 = period-pulse_distance/2-pulse_length/2-blind_time/2+pulse_length;

start_of_pulse2 = period-pulse_distance/2-pulse_length/2-blind_time/2+pulse_distance;
end_of_pulse2 = period-pulse_distance/2-pulse_length/2-blind_time/2+pulse_distance+pulse_length;

bot_cam = 0.45;
bot_las = 0.2;
amp = 0.2;

if is_dbl_shutter
	for i=0:2:num_exposures_to_show+4
		exposure_active_y= [exposure_active_y  [  bot_cam  bot_cam      bot_cam                            bot_cam+amp                    bot_cam+amp                        bot_cam                         bot_cam                      bot_cam+amp                 bot_cam+amp       bot_cam          ]];
		exposure_active_x =[exposure_active_x  [  0           0     start_of_pulse1-blind_time  start_of_pulse1-blind_time  start_of_pulse1+f1exp_cam-blind_time  start_of_pulse1+f1exp_cam-blind_time  start_of_pulse1+f1exp_cam-blind_time   start_of_pulse1+f1exp_cam-blind_time   end_of_pulse2+5000  end_of_pulse2+5000    ] +  period* i];
	end
else
	for i=0:num_exposures_to_show+4
		exposure_active_y=[exposure_active_y  [  bot_cam   bot_cam+amp       bot_cam+amp                      bot_cam               bot_cam    ]];
		exposure_active_x =[exposure_active_x [  0              0          period-blind_time            period-blind_time            period    ] +  period* i];
	end
end


for i=0:2:num_exposures_to_show+4
	laser_active_y= [laser_active_y  [  bot_las  bot_las      bot_las        bot_las+amp    bot_las+amp       bot_las         bot_las         bot_las+amp      bot_las+amp       bot_las          ]];
	laser_active_x =[laser_active_x  [  0           0     start_of_pulse1  start_of_pulse1  end_of_pulse1  end_of_pulse1  start_of_pulse2   start_of_pulse2   end_of_pulse2   end_of_pulse2    ] +  period* i];
end

straddling_figure=findobj('tag','straddling_figure');
if isempty(straddling_figure)
	hf = figure('numbertitle','off','MenuBar','figure','DockControls','off','Name','Camera exposure and pulse timing visualization','Toolbar','figure','CloseRequestFcn', @straddling_figure_CloseRequestFcn,'tag','straddling_figure','visible','on');
else
	hf = figure(straddling_figure);
	clf(hf)
end

plot(exposure_active_x,exposure_active_y,'linewidth',2)
hold on
plot(laser_active_x,laser_active_y,'linewidth',2)
axis tight
xlim([0 period*num_exposures_to_show])
%xlim([-period period*(num_cycles_to_show)+period])
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
ptPrintFigure    = findall(hf,'Tag','Standard.PrintFigure');      delete(ptPrintFigure);
ptSaveFigure     = findall(hf,'Tag','Standard.SaveFigure');       delete(ptSaveFigure);
ptFileOpen       = findall(hf,'Tag','Standard.FileOpen');         delete(ptFileOpen);
ptNewFigure      = findall(hf,'Tag','Standard.NewFigure');        delete(ptNewFigure);

%Pulse_length
ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
ha.Parent=hf.CurrentAxes;
ha.X=[start_of_pulse1 end_of_pulse1];
ha.Y=[bot_las-0.01 bot_las-0.01];
plot ([start_of_pulse1 start_of_pulse1], [bot_las-0.01 bot_las],'LineStyle','--','Color',[1 0.7 0.7])
plot ([end_of_pulse1 end_of_pulse1], [bot_las-0.01 bot_las],'LineStyle','--','Color',[1 0.7 0.7])
text((start_of_pulse1+end_of_pulse1)/2,bot_las-0.01,{'Pulse length' [num2str(pulse_length) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)

%Pulse distance
ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
ha.Parent=hf.CurrentAxes;
ha.X=[(start_of_pulse1+end_of_pulse1)/2 (start_of_pulse2+end_of_pulse2)/2];
ha.Y=[bot_las-0.1 bot_las-0.1];
plot ([(start_of_pulse1+end_of_pulse1)/2 (start_of_pulse1+end_of_pulse1)/2], [bot_las-0.1 bot_las+amp-0.01],'LineStyle','--','Color',[1 0.7 0.7])
plot ([(start_of_pulse2+end_of_pulse2)/2 (start_of_pulse2+end_of_pulse2)/2], [bot_las-0.1 bot_las+amp-0.01],'LineStyle','--','Color',[1 0.7 0.7])
text(((start_of_pulse1+end_of_pulse1)/2 + (start_of_pulse2+end_of_pulse2)/2)/2,bot_las-0.1,{'Pulse distance' [num2str(pulse_distance) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)


%frame rate annotation
ha = annotation('doublearrow','Head1Style','plain','Head2Style','plain','Head1Length',5,'Head1Width',5,'Head2Length',5,'Head2Width',5);
ha.Parent=hf.CurrentAxes;
if is_dbl_shutter
	%frame rate double shutter cameras
	ha.X=[start_of_pulse1-blind_time  start_of_pulse1-blind_time+period*2];
	ha.Y=[bot_cam-0.01 bot_cam-0.01];
	plot ([start_of_pulse1-blind_time start_of_pulse1-blind_time], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	plot ([start_of_pulse1-blind_time+period*2 start_of_pulse1-blind_time+period*2], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	text(period*1.5,bot_cam-0.01,{'Double frame rate' [num2str(frame_rate/2) ' Hz'] [num2str(period*2) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
else
	%frame rate non-double shutter cameras
	ha.X=[period period*2];
	ha.Y=[bot_cam-0.01 bot_cam-0.01];
	plot ([period period], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	plot ([period*2 period*2], [bot_cam bot_cam-0.01],'LineStyle','--','Color',[0.7 0.7 1])
	text(period*1.5,bot_cam-0.01,{'Frame rate' [num2str(frame_rate) ' Hz'] [num2str(period) ' µs']},'Rotation',0,'HorizontalAlignment','center','VerticalAlignment','top','FontSize',8)
end

%info top left
text(period/10,0.99,{['Laser duty cycle: ' num2str(round(duty_cycle*100,4)) ' %'] ['PIV data rate: ' num2str(frame_rate/2) ' Hz']},'HorizontalAlignment','left','VerticalAlignment','top')
%info top right
text(num_exposures_to_show*period,0.99,{' Use zoom buttons to see the details '},'HorizontalAlignment','right','VerticalAlignment','top')

margin=period/20*0;
smallmargin=margin/2*0;
for i=0:2:num_exposures_to_show-1

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

legend({'Camera Exposure', 'Laser Active'},'Location','southeast')
set(gca,'InnerPosition',[0.01 0.1 0.98 0.9])
%grid on
%set(gca,'YGrid','off')
%set(gcf,'handlevisibility','callback')
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