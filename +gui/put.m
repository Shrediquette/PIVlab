function put(name, what)
try
    hgui=getappdata(0,'hgui');
    setappdata(hgui, name, what);
catch
    hgui=gcf();
    setappdata(hgui, name, what);
    disp('bug in put')
end