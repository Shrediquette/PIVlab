function installplugins_Callback(item)
% Check Python environment -->
if pyenv().Version == ""
    if ispc
        % TODO
    elseif isunix
        [~, cmdout] = system("which python3");
        % [https://www.mathworks.com/matlabcentral/answers/587288-system-function-cmdout-has-to-the-end]
        cmdout(cmdout==newline)='';
        try
            pyenv('Version',cmdout);
        catch ME
            disp("Error setting Python environment")
            disp(ME.message)
        end
    end
end
% <--
% pyrunfile('+misc/generate_fill_plugins.py +plugins');
filelist = pyrunfile("+misc/generate_fill_plugins.py", "filelist", workdir="+plugins");
filelist = string(filelist);
try
    % TODO: clean the menu before running fill_plugins to avoid duplicates
    plugins.fill_plugins(item);
    answer = ["Plugins installation finished", "", "The following files found:", ...
        filelist];
    gui.custom_msgbox('msg',getappdata(0,'hgui'),'About',answer,'modal',{'OK'},'OK');
catch ME
    disp("Error installing plugins")
    disp(ME.message)
end
end