function SetFullScreen
MainWindow=getappdata(0,'hgui');
if verLessThan('matlab','9.4') %r2018a
	if verLessThan('matlab','9.2') %dont know exactly in which release this was supported, 9.2 is a safe assumption
		set (MainWindow,'Units','pixels');
		set(0,'Units','pixels')
		scnsize = get(0,'ScreenSize');
		position = get(MainWindow,'Position');
		outerpos = get(MainWindow,'OuterPosition');
		borders = outerpos - position;
		edge = -borders(1)/2;
		pos1 = [edge, edge+25, scnsize(3) - edge,scnsize(4)-25];
		set(MainWindow,'OuterPosition',pos1)
		set (MainWindow,'Units','Characters');
	else
		try
			warning off
			frame_h = get(handle(gcf),'JavaFrame'); %#ok<*JAVFM>
			set(frame_h,'Maximized',1);
		catch
		end
	end
else
	try
		if ~isunix %unfortunately, setting the figure to fullscreen doesn't work properly in matlab online...
			set(MainWindow,'WindowState','maximized');
		end
	catch
	end
end
warning on

