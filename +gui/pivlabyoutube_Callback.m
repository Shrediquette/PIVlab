function pivlabyoutube_Callback(~, ~, ~)
try
	web('https://www.youtube.com/playlist?list=PLm0qHGfFNU28vvBsj15M0S0ujb1Xt2kgr')
catch
	%why does 'web' not work in v 7.1.0.246 ...?
	disp('Ooops, MATLAB couldn''t open the website.')
	disp('You''ll have to open the website manually:')
	disp('https://www.youtube.com/playlist?list=PLm0qHGfFNU28vvBsj15M0S0ujb1Xt2kgr')
end

