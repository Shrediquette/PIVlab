function MainWindow_ResizeFcn(hObject, ~)
handles=guihandles(hObject);
originalunits=get(hObject,'units');
set(hObject,'Units','Characters');
Figure_Size = get(hObject, 'Position');
set(hObject,'Units',originalunits);
margin=1.5;
panelwidth=gui.retr('panelwidth');
%panelwidth=37;
panelheighttools=12;
panelheightpanels=35;
quickwidth=gui.retr('quickwidth');
quickheight=gui.retr('quickheight');
%coordinate system starts lower left
try
	colorbarpos=get(handles.colorbarpos,'value');
catch
	colorbarpos=1;
end

if colorbarpos==1
	width_reduct=0;x_shift=0;
	height_reduct=0;y_shift=0;
else
	posichoice = get(handles.colorbarpos,'String');
	if strcmp(posichoice{get(handles.colorbarpos,'Value')},'EastOutside')
		width_reduct=25;x_shift=0;
		height_reduct=0;y_shift=0;
	end
	if strcmp(posichoice{get(handles.colorbarpos,'Value')},'WestOutside')
		width_reduct=25;x_shift=25;
		height_reduct=0;y_shift=0;
	end
	if strcmp(posichoice{get(handles.colorbarpos,'Value')},'NorthOutside')
		width_reduct=6;x_shift=3;
		height_reduct=4;y_shift=0;
	end
	if strcmp(posichoice{get(handles.colorbarpos,'Value')},'SouthOutside')
		width_reduct=6;x_shift=3;
		height_reduct=4;y_shift=5;
	end
end
if (panelheighttools+panelheightpanels+margin*0.25+margin*0.25+quickheight*2 ) <= Figure_Size(4)
	%panels + tools DO fit vertically
	try
		set (findobj('-regexp','Tag','multip'), 'position', [0+margin*0.5 Figure_Size(4)-panelheightpanels-margin*0.25 panelwidth panelheightpanels]);
		set (handles.tools, 'position', [0+margin*0.5 0+margin*0.5 panelwidth panelheighttools]);
		set (gca, 'position', [x_shift+panelwidth+margin   y_shift+margin  Figure_Size(3)-panelwidth-margin-width_reduct   Figure_Size(4)-quickheight-height_reduct]);
		set (handles.quick,'Visible','on');
		set (handles.quick, 'position',[0+margin*0.5 0+margin*0.5+panelheighttools+quickheight quickwidth quickheight])
		set (handles.toolprogress,'Visible','on');
		set (handles.toolprogress, 'position',[0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight])
	catch ME
		disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
		disp('https://groups.google.com/forum/#!forum/pivlab ')
		disp(ME)
	end
else
	%panels + tools DO NOT fit vertically
	%--> put them side by side
	%first: disable quickaccess
	%then put them side by side
	if (panelheighttools+panelheightpanels+margin*0.25+margin*0.25+quickheight ) <= Figure_Size(4)
		set (handles.quick,'Visible','off');
		try
			set (findobj('-regexp','Tag','multip'), 'position', [0+margin*0.5 Figure_Size(4)-panelheightpanels-margin*0.25 panelwidth panelheightpanels]);
			set (handles.tools, 'position', [0+margin*0.5 0+margin*0.5 panelwidth panelheighttools]);
			set(handles.quick, 'position',[0+margin*0.5  0+margin*0.5+panelheighttools+quickheight quickwidth quickheight])
			set (handles.toolprogress, 'position',[0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight])
			set (gca, 'position', [x_shift+panelwidth+margin   y_shift+margin  Figure_Size(3)-panelwidth-margin-width_reduct   Figure_Size(4)-quickheight-height_reduct]);
		catch ME
			disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
			disp('https://groups.google.com/forum/#!forum/pivlab ')
			disp(ME)
		end
	else
		try
			set (findobj('-regexp','Tag','multip'), 'position', [0+margin*0.5 Figure_Size(4)-panelheightpanels-margin*0.25 panelwidth panelheightpanels]);
			set (handles.tools, 'position', [0+margin*0.5+panelwidth+margin 0+margin*0.5 panelwidth panelheighttools]);
			set(handles.quick, 'position',[0+margin*0.5+panelwidth+margin  0+margin*0.5+panelheighttools+quickheight quickwidth quickheight])
			set (handles.toolprogress, 'position',[0+margin*0.5+panelwidth+margin 0+margin*0.5+panelheighttools quickwidth quickheight])
			set (gca, 'position', [x_shift+margin+panelwidth+margin+panelwidth y_shift+margin Figure_Size(3)-panelwidth-panelwidth-margin-margin-width_reduct Figure_Size(4)-margin-quickheight-height_reduct]);
		catch ME
			disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
			disp('https://groups.google.com/forum/#!forum/pivlab ')
			disp(ME)
		end
	end
end