function shortcuts_Callback(~, ~, ~)
%SHORTCUTS_CALLBACK Opens the keyboard shortcut list of the PIVlab manual.
% The page is the only shortcut documentation (there is no printable PDF any more, it went stale).
url = 'https://www.pivlab.de/manual/pages/shortcuts.html';
try
	web(url,'-browser')
catch
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp(url)
end
