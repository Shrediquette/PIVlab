function displogo(~)
try
	%logoimg=imread(fullfile('images','PIVlablogo.jpg'));
	[logoimg, ~, alphachannel] = imread(fullfile('images','PIVlablogo.png'));
catch
	[filepath,name,ext]=  fileparts(which('PIVlab_GUI.m'));
	cd (filepath); %if current directory is not where PIVlab_GUI.m is located, then change directory.
	%logoimg=imread(fullfile('images','PIVlablogo.jpg'));
	[logoimg, ~, alphachannel] = imread(fullfile('images','PIVlablogo.png'));
	%image(img, 'AlphaData', alphachannel);
end
%{
if zoom==1
	h=image(logoimg+255, 'parent', gca);
	axis image;
	set(gca,'ytick',[])
	set(gca,'xtick',[])
	set(gca, 'xlim', [1 size(logoimg,2)]);
	set(gca, 'ylim', [1 size(logoimg,1)]);
	set(gca, 'ydir', 'reverse');
	set(gca, 'xcolor', [0.94 0.94 0.94], 'ycolor', [0.94 0.94 0.94]) ;
	for i=0.5:0.1:1
		RGB2=logoimg*i;
		try
			set (h, 'cdata', RGB2);
			pause(0.01)
		catch %#ok<*CTCH>
			disp('..')
		end
		drawnow %limitrate;
	end
end
%}

try
	pivlab_axis=gui.retr('pivlab_axis');
	image(logoimg, 'parent', pivlab_axis,'interpolation','bilinear', 'AlphaData', alphachannel);
catch
	pivlab_axis=gui.retr('pivlab_axis');
	image(logoimg, 'parent', pivlab_axis, 'AlphaData', alphachannel);
end
set(gca, 'xcolor', 'none', 'ycolor', 'none') ;
set(gca,'Color','none')
axis image;
set(gca,'ytick',[])
set(gca,'xtick',[])
set(gca, 'xlim', [1 size(logoimg,2)]);
set(gca, 'ylim', [1 size(logoimg,1)]);

set(gca, 'ydir', 'reverse'); %750%582
text (1025,800,['version: ' gui.retr('PIVver')], 'fontsize', 10,'horizontalalignment','right');
text (1025,800,['   ' sprintf('\n') gui.retr('update_msg')], 'fontsize', 10,'fontangle','italic','horizontalalignment','right','Color',gui.retr('update_msg_color'),'verticalalignment','top');
imgproctoolbox=gui.retr('imgproctoolbox');
gui.put('imgproctoolbox',[]);
if imgproctoolbox==0
	text (90,200,'Image processing toolbox not found!', 'fontsize', 16, 'color', [1 0 0], 'backgroundcolor', [0 0 0]);
end

