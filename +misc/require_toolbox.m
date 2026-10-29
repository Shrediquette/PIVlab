function ok = require_toolbox(name, feature)
% Checks a toolbox for a GUI feature. When it is missing, a message box tells the user so.
% name: toolbox name (see misc.has_toolbox), feature: what needs it, e.g. 'Stereo-PIV'
ok = misc.has_toolbox(name);
if ~ok
    text = {[feature ' requires the ' name '.'] ...
        ['The ' name ' is not installed or not licensed in this MATLAB.'] ...
        'The standalone version of PIVlab (http://PIVlab.de) includes it.'};
    disp(['Warning: ' strjoin(text, ' ')])
    hgui = getappdata(0, 'hgui');
    if ~isempty(hgui) && ishghandle(hgui)
        gui.custom_msgbox('error', hgui, 'Toolbox missing', text, 'modal');
    end
end
end
