function var = retr(name)
try
    hgui=getappdata(0,'hgui');
    var=getappdata(hgui, name);
catch
    var=[];
    disp('bug in retr')
end