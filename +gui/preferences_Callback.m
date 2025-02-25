function preferences_Callback (~,~)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
panelwidth=gui.retr('panelwidth');
set(handles.panelslider,'Value',panelwidth);
gui.switchui('multip21')
if ~verLessThan('Matlab','25')
	if ispref('PIVlab_ad','dark_mode_theme')
		gui.put('darkmode',getpref('PIVlab_ad','dark_mode_theme'));
		MainWindow=getappdata(0,'hgui');
		if getpref('PIVlab_ad','dark_mode_theme') == 1
			MainWindow.Theme = 'dark';
		else
			MainWindow.Theme = 'light';
		end
	end
	pause(0.25)
	current_theme = hgui.Theme.BaseColorStyle;
	if strcmpi(current_theme, 'Dark')
		set( handles.matlab_theme,'Value',1);
	elseif strcmpi(current_theme, 'Light')
		set( handles.matlab_theme,'Value',2);
	end
end