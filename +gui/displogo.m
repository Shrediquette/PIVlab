function displogo(~)
try
	[logoimg, ~, alphachannel] = imread(fullfile('images','PIVlablogo.png'));
catch
	[filepath,~,~]=  fileparts(which('PIVlab_GUI.m'));
	cd (filepath); %if current directory is not where PIVlab_GUI.m is located, then change directory.
	[logoimg, ~, alphachannel] = imread(fullfile('images','PIVlablogo.png'));
end
target_axis=gui.retr('pivlab_axis');
try
	image(logoimg, 'parent', target_axis,'interpolation','bilinear', 'AlphaData', alphachannel,'AlphaDataMapping','scaled');
catch
	image(logoimg, 'parent', target_axis, 'AlphaData', alphachannel);
end

set(target_axis, 'xcolor', 'none', 'ycolor', 'none') ;
set(target_axis,'Color','none')
set(target_axis, 'DataAspectRatio', [1 1 1], 'PlotBoxAspectRatioMode', 'auto');
set(target_axis,'ytick',[])
set(target_axis,'xtick',[])
set(target_axis, 'xlim', [1 size(logoimg,2)]);
set(target_axis, 'ylim', [1 size(logoimg,1)]);
set(target_axis, 'ydir', 'reverse'); %750%582
text (1025,800,['version: ' gui.retr('PIVver')], 'fontsize', 10,'horizontalalignment','right');
text (1025,800,['   ' sprintf('\n') gui.retr('update_msg')], 'fontsize', 10,'fontangle','italic','horizontalalignment','right','Color',gui.retr('update_msg_color'),'verticalalignment','top');
imgproctoolbox=gui.retr('imgproctoolbox');
gui.put('imgproctoolbox',[]);
if imgproctoolbox==0
	text (90,200,'Image processing toolbox not found!', 'fontsize', 16, 'color', [1 0 0], 'backgroundcolor', [0 0 0]);
end