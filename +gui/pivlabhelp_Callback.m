function pivlabhelp_Callback(~, ~, ~)
try
	web('https://shrediquette.github.io/PIVlab/wiki/1-quickstart/','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('https://shrediquette.github.io/PIVlab/wiki/1-quickstart/')
end

