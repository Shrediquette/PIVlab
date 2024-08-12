function [out1,out2,out3] = ...
                wboxtitl(option,in2,in3,in4,in5,in6,in7,in8,in9,in10)
%WBOXTITL Box title for axes.
%   [OUT1,OUT2,OUT3] = ...
%       WBOXTITL(OPTION,IN2,IN3,IN4,IN5,IN6,IN7,IN8,IN9,IN10)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

tag_boxtitle   = 'Box_Title';
tag_axefigutil = 'Axe_FigUtil';

switch option
    case 'create'
        % in2  = parent axes    (invisible)
        % in3  = axes;
        % in4  = color
        % in5  = title          (optional)
        % in6  = visible        (optional)
        % in7  = fontsize       (optional)
        % in8  = hy_title/2     (optional)
        % in9  = bdx            (optional)
        % in10 = bdy            (optional)
        % out1 = line
        % out2 = text
        %-----------------------------
        Def_AxeFontSize = mextglob('get','Def_AxeFontSize');
        if nargin<5
            in5 = '';     in6 = 'off';    in7  = Def_AxeFontSize;
            in8 = 9;      in9 = 2*in8;    in10 = 2*in8;
        elseif nargin<6
            in6 = 'off';  in7 = Def_AxeFontSize;
            in8 = 9;      in9 = 2*in8;    in10 = 2*in8;
        elseif nargin<7
            in7 = Def_AxeFontSize;
            in8 = 9;      in9 = 2*in8;    in10 = 2*in8;
        elseif nargin<8
            in8 = 9;      in9 = 2*in8;    in10 = 2*in8;
        elseif nargin<9
            in9 = 2*in8;  in10 = 2*in8;
        elseif nargin<10
            in10 = 2*in9;
        end     

        if ~ishandle(in2)
            f = get(in3,'Parent');
            in2 = findobj(f,'Type','axes','Tag',tag_axefigutil);
            if isempty(in2)
                in2 = axes(...
                        'Parent',f,               ...
                        'Units','normalized',     ...
                        'Position',[0 0 1 1],     ...
                        'XLim',[0 1],'YLim',[0 1],...
                        'Visible','off',          ...
                        'Tag',tag_axefigutil      ...
                        );
            end
        end
        commonProp = {...
           'Parent',in2,     ...
           'Visible','off',  ...
           'Color',in4,      ...
           'UserData',in3,   ...
           'Tag',tag_boxtitle...
           };
        out1 = line(commonProp{:});
        out2 = text(commonProp{:}, ...
                    'String',in5,                ...
                    'FontSize',in7,              ...
                    'HorizontalAlignment','left' ...
                    );

        [xdata,ydata,pos_txt] = wboxtitl('compute_pos',...
                                        in3,out1,out2,in8,in9,in10);
        set(out1,'XData',xdata,'YData',ydata,'Visible',in6);
        set(out2,'Position',pos_txt,'Visible',in6);

    case 'pos'
        % in2 = axes
        % in3 = visible (optional)
        % in4 = hy_title/2 (optional)
        % in5 = bdx        (optional)
        % in6 = bdy        (optional)
        %-----------------------------
        f = get(in2,'Parent');
        l = findobj(f,'Type','line','UserData',in2,'Tag',tag_boxtitle);
        t = findobj(f,'Type','text','UserData',in2,'Tag',tag_boxtitle);
        if nargin<3
            in3 = get(l,'Visible');
            in4 = 9;     in5 = 2*in4;  in6 = 2*in4;
        elseif nargin<4
            in4 = 9;     in5 = 2*in4;  in6 = 2*in4;
        elseif nargin<5
            in5 = 2*in4; in6 = 2*in4;
        elseif nargin<6
            in6 = 2*in4;
        end
        [xdata,ydata,pos_txt] = wboxtitl('compute_pos',in2,l,t,in4,in5,in6);
        set(l,'XData',xdata,'YData',ydata,'Visible',in3);
        set(t,'Position',pos_txt,'Visible',in3);

    case 'vis'
        % in2 = axes
        % in3 = visible
        %------------
        f = get(in2,'Parent');
        l = findobj(f,'Type','line','UserData',in2,'Tag',tag_boxtitle);
        t = findobj(f,'Type','text','UserData',in2,'Tag',tag_boxtitle);
        set([l t],'Visible',in3);

    case 'compute_pos'
        % in2 = axes
        % in3 = line
        % in4 = text
        % in5 = hy_title/2 (optional)
        % in6 = bdx        (optional)
        % in7 = bdy        (optional)
        % out1 = xdata
        % out2 = ydata
        % out3 = pos_txt
        %------------
        if nargin<5
            in5 = 9;      in6 = 2*in5;  in7 = 2*in5;
        elseif nargin<6
            in6 = 2*in5;  in7 = 2*in5;
        elseif nargin<7
            in7 = 2*in5;
        end     
        f    = get(in2,'Parent');
        pos  = get(in2,'Position');
        xmin = pos(1);  xmax = xmin+pos(3);
        ymin = pos(2);  ymax = ymin+pos(4);
        [xpixl,ypixl] = wfigutil('prop_size',f,1,1);
        hy    = in5*ypixl;
        dx    = in6*xpixl;
        dy    = in7*ypixl;
        ext   = get(in4,'Extent');
        l4    = (xmax-xmin+2*dx)/4;
        mul1  = 1.1;
        res   =((xmax-xmin+2*dx)-mul1*ext(3))/2;
        l4    = min(res,l4);
        mul2  = 1.4;
        xdata = [xmin-dx+l4,xmin-dx,xmin-dx,xmax+dx,xmax+dx,xmax+dx-l4];
        ydata = [ymax+dy,ymax+dy,ymin-mul2*dy,ymin-mul2*dy,ymax+dy,ymax+dy];
        out1  = [xdata,xmax+dx-l4,xmin-dx+l4,xmin-dx+l4,xmax+dx-l4,xmax+dx-l4];
        out2  = [ydata,ymax+dy+hy,ymax+dy+hy,ymax+dy-hy,ymax+dy-hy,ymax+dy+hy];
        out3  = [(xmin+xmax)/2-ext(3)/2,ymax+dy];

    case 'FontSize'
        % in2 = axes
        % in3 = fontsize
        %----------------
        f = get(in2,'Parent');
        t = findobj(f,'Type','text','UserData',in2,'Tag',tag_boxtitle);
        set(t,'FontSize',in3);

    case 'set'
        % in2 = axes
        % in3 = title
        % in4 = fontsize   (optional)
        % in5 = hy_title/2 (optional)
        % in6 = bdx        (optional)
        % in7 = bdy        (optional)
        % in8 = visible    (optional)
        %----------------------------
        f = get(in2,'Parent');
        l = findobj(f,'Type','line','UserData',in2,'Tag',tag_boxtitle);
        t = findobj(f,'Type','text','UserData',in2,'Tag',tag_boxtitle);
        vis = get(t,'Visible');
        if nargin<4 , in4 = get(t,'FontSize'); end
        set(t,'String',in3,'FontSize',in4);
        if nargin<5
            in5 = 9;      in6 = 2*in5;  in7 = 2*in5;  in8 = vis;
        elseif nargin<6
            in6 = 2*in5;  in7 = 2*in5;  in8 = vis;
        elseif nargin<7
            in7 = 2*in5;  in8 = vis;
        elseif nargin<8
            in8 = vis;
        end
        [xdata,ydata,pos_txt] = wboxtitl('compute_pos',in2,l,t,in5,in6,in7);
        set(l,'XData',xdata,'YData',ydata,'Visible',in8);
        set(t,'Position',pos_txt,'Visible',in8);
end
