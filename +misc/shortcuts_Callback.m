function shortcuts_Callback (~, ~)
try
	open(fullfile('help','PIVlab_shortcuts.pdf'))
catch
	msgbox('Could not open "help\PIVlab_Shortcuts.pdf".')
end

