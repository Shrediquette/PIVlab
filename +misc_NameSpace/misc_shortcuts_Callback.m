function misc_shortcuts_Callback (~, ~)
try
	open('PIVlab_shortcuts.pdf')
catch
	msgbox('Could not open "PIVlab_Shortcuts.pdf".')
end
