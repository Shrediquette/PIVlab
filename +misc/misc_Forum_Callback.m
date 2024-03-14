function misc_Forum_Callback(~, ~, ~)
try
	web('http://pivlab.blogspot.de/p/forum.html','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('http://pivlab.blogspot.de/p/forum.html')
end

