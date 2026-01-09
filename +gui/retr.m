function var = retr(name)
try
    hgui=getappdata(0,'hgui');
    var=getappdata(hgui, name);
catch
    hgui=gcf();
    var=getappdata(hgui, name);
    disp('bug in retr')
end

%%check from where this function is called:
%{
st = dbstack;
if numel(st) >= 2
    caller = st(2).name;
    disp(['Called from: ' caller])
else
    disp('Called from base workspace')
end
%}