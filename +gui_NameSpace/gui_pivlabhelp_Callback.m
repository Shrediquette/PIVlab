function gui_pivlabhelp_Callback(~, ~, ~)
try
	web('http://pivlab.blogspot.de/p/blog-page_19.html','-browser')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('http://pivlab.blogspot.de/p/blog-page_19.html')
end
