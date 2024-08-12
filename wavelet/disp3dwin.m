function disp3dwin(option)
%DISP3DWIN Display the 3D view in DW3DTOOL.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Jun-2009.
%   Last Revision: 20-Nov-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

[hObj,hFig] = gcbo;
if isequal(option,'close') , close(hFig); return; end
fig_Handles = guihandles(hFig);
Sli_E = fig_Handles.Sli_E;
Sli_A = fig_Handles.Sli_A;
Edi_E = fig_Handles.Edi_EL;
Edi_A = fig_Handles.Edi_AZ;

axecur = findobj(hFig,'Type','axe');
v = get(axecur,'View');
maxi = 1;
val = get(hObj,'Value');
plus = round(maxi*val);
new_v = v;
Min_Elev = -89.999;

switch option
    case 'sli_e'
        if (plus<=-90) , plus = Min_Elev; end 
        new_v(2)= plus;
        set(Edi_E,'String',sprintf('%5.1f',plus));
        
    case 'edi_e'
        tmp = str2double(get(Edi_E,'String'));
        OK = ~isnan(tmp);
        if OK , OK = (tmp<=90) && (-90<=tmp); end
        if (tmp<=-90) , tmp = Min_Elev; end 
        if ~OK
            valE = get(Sli_E,'Value');
            set(Edi_E,'String',sprintf('%5.1f',valE));
            return
        end
        set(Edi_E,'String',sprintf('%5.1f',tmp))
        if (tmp<=-90) , tmp = Min_Elev; end 
        set(Sli_E,'Value',tmp)
        new_v(2)= tmp;
        
    case 'sli_a'
        new_v(1)= plus;
        set(Edi_A,'String',sprintf('%5.1f',plus));
        
    case 'edi_a'
        tmp = str2double(get(Edi_A,'String'));
        OK = ~isnan(tmp);
        if OK , OK = (tmp<=180) && (-180<=tmp); end
        if ~OK
            valA = get(Sli_A,'Value');
            set(Edi_A,'String',sprintf('%5.1f',valA));
            return
        end
        set(Edi_A,'String',sprintf('%5.1f',tmp))
        set(Sli_A,'Value',tmp)
        new_v(1)= tmp;
        
end
set(axecur,'View',new_v);

