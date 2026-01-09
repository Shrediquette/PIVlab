function var = retr(name)
try
    hgui=getappdata(0,'hgui');
    var=getappdata(hgui, name);
catch
    hgui=gcf();
    var=getappdata(hgui, name);
    disp('bug in retr')
end