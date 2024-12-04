function shortcuts_Callback (~, ~)
try
	if ispc
		winopen(which('PIVlab_shortcuts.pdf'))
	else
		open(which('PIVlab_shortcuts.pdf'))
	end
catch
	msgbox('Could not open "help\PIVlab_Shortcuts.pdf".')
end