function pluginsdescription_Callback(~,~,~)
string = ["By this menu, plugins installed by user will be accessible.", ...
    strcat("This is part of fork PIVlab-extras, version ", gui.pivlab_version)];
gui.custom_msgbox('msg',getappdata(0,'hgui'),'About',string,'modal',{'OK'},'OK');
end