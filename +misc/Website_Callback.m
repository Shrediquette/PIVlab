function Website_Callback(~, ~, ~)
try
	web('http://pivlab.de/','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('http://PIVlab.de/')
end

