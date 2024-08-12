function wtxttitl(axe,txtStr,tag)
%WTXTTITL Set a text as a super title in an axes.
%    WTXTTITL(AXE,TXTSTR,TAG)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin==2 , tag = ''; end
newtxt = 1;
if ~isempty(tag)
    h_txt = findobj(axe,'Type','text','Tag',tag);
    if ~isempty(h_txt) , newtxt = 0; end
end
if newtxt
    [ColTitle,FontWeight,FontName] = wtbutils('title_PREFS');
    u_axe = get(axe,'Units');
    h_tit = get(axe,'title');
    u_txt = 'pixels';
    set(h_tit,'Units',u_txt);
    h_txt  = text(0,0,txtStr,                  ...
               'Parent',axe,                   ...
               'Units',u_txt,                  ...
               'Color',ColTitle,               ...
               'FontWeight',FontWeight,        ...
               'FontName',FontName,            ...               
               'HorizontalAlignment','center', ...
               'Visible','off',                ...
               'Tag',tag                       ...
               );
    e_tit  = get(h_tit,'Extent');
    p_tit  = get(h_tit,'Position');
    px_txt = p_tit(1);
    if e_tit(4)>0
        py_txt = e_tit(2)+1.33*e_tit(4);
    else
        py_txt = e_tit(2)-0.32*e_tit(4);
    end
    set(h_txt,'Position',[px_txt py_txt+3],'Visible','on');
    set([h_txt,h_tit],'Units',u_axe);
else
    set(h_txt,'String',txtStr,'Visible','on');
end
drawnow
