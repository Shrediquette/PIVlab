function var = retr(name)
try
    hgui=getappdata(0,'hgui');
    var=getappdata(hgui, name);
catch
    hgui=gcf();
    var=getappdata(hgui, name);
    disp('bug in retr')
end

%%check from where this function is called for debugging purposes:
%{
if strcmpi(name,'expected_image_size')
    if ~isempty(var)
        disp([num2str(var(1)) ' ; ' num2str(var(2))])
    else
        disp ('empty expected_image_size')
    end
    st = dbstack;
    if numel(st) >= 2
        caller = st(2).name;
        disp(['Called from: ' caller])
    else
        disp('Called from base workspace')
    end

end
%}