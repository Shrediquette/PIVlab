function preferences_Callback (~,~)
hgui=getappdata(0,'hgui');
handles=gui.gethand;
panelwidth=gui.retr('panelwidth');
set(handles.panelslider,'Value',panelwidth);
gui.switchui('multip21')
if ~verLessThan('Matlab','25')
	current_theme = hgui.Theme.BaseColorStyle;
	if strcmpi(current_theme, 'Dark')
		set( handles.matlab_theme,'Value',1);
	elseif strcmpi(current_theme, 'Light')
		set( handles.matlab_theme,'Value',2);
	end
end

