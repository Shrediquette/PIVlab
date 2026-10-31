function installplugins_Callback(item)
% Check Python environment -->
if pyenv().Version == ""
    if ispc
        % TODO
    elseif isunix
        [~, cmdout] = system("which python3.11");
        % [https://www.mathworks.com/matlabcentral/answers/587288-system-function-cmdout-has-to-the-end]
        cmdout(cmdout==newline)='';
        pyenv('Version',cmdout);
    end
end
% <--
pyrunfile('+misc/generate_fill_plugins.py +plugins');
try
    plugins.fill_plugins(item);
catch ME
    disp("Error installing plugins")
    disp(ME.message)
end
end