function displogo(~)
try
    [logoimg, ~, alphachannel] = imread(fullfile('images','hardware_Ad.png'));
catch
    [filepath,~,~]=  fileparts(which('PIVlab_GUI.m'));
    cd (filepath); %if current directory is not where PIVlab_GUI.m is located, then change directory.
    [logoimg, ~, alphachannel] = imread(fullfile('images','hardware_Ad.png'));
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