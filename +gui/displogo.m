function displogo(~)
try
    [logoimg, ~, alphachannel] = imread(fullfile('images','PIVlablogo.png'));
catch
    [filepath,~,~]=  fileparts(which('PIVlab_GUI.m'));
    cd (filepath); %if current directory is not where PIVlab_GUI.m is located, then change directory.
    [logoimg, ~, alphachannel] = imread(fullfile('images','PIVlablogo.png'));
end

try
    pivlab_axis=gui.retr('pivlab_axis');
    image(logoimg, 'parent', pivlab_axis,'interpolation','bilinear', 'AlphaData', alphachannel,'AlphaDataMapping','scaled');
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