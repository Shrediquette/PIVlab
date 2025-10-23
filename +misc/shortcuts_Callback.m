function shortcuts_Callback (~, ~)
try
	if ispc
		winopen(which('PIVlab_shortcuts.pdf'))
	else
		open(which('PIVlab_shortcuts.pdf'))
	end
catch
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Could not open "help\PIVlab_Shortcuts.pdf".','modal');
end