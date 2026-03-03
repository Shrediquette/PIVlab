function exitpivlab_Callback(~, ~, ~)
try
    hgui=getappdata(0,'hgui');
    gui.MainWindow_CloseRequestFcn(hgui)
catch
    close(gcf,'force')
end

