function hardware_Ad(~)
cam_info=findobj('tag','cam_info_box'); %if information was shown on the detected camera, then save this information
if ~isempty(cam_info)
props = get(cam_info);
end
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

set(pivlab_axis, 'xcolor', 'none', 'ycolor', 'none') ;
set(pivlab_axis,'Color','none')
axis image;
set(pivlab_axis,'ytick',[])
set(pivlab_axis,'xtick',[])
set(pivlab_axis, 'xlim', [1 size(logoimg,2)]);
set(pivlab_axis, 'ylim', [1 size(logoimg,1)]);
set(pivlab_axis, 'ydir', 'reverse'); %750%582

if ~isempty(cam_info) %display information on detected camerea again
    new_text = text( ...
        props.Position(1), ...
        props.Position(2), ...
        props.String, ...
        'Parent', props.Parent,'color',props.Color,'BackgroundColor',props.BackgroundColor,'FontSize',props.FontSize,'FontWeight',props.FontWeight);
    % Restore remaining properties
    set(new_text,props)
end