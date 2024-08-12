function out1 = dw2dimgs(option,in2,in3,in4)
%DW2DIMGS Discrete wavelet 2-D image selection.
%   OUT1 = DW2DIMGS(OPTION,IN2,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.14.4.8 $

% Tag property of objects.
%-------------------------
tag_imgsel = 'Img_Select';
tag_imgdec = 'Img_Dec';

% Miscellaneous values.
%----------------------
if isequal(option,'get_img')
    win_dw2dtool = get(0,'CurrentFigure');
	SelectType = get(win_dw2dtool,'SelectionType');
	if ~isequal(SelectType,'normal') , return; end 
else
    win_dw2dtool = in2;
end
dw2d_PREFS = wtbutils('dw2d_PREFS');
Col_BoxAxeSel   = dw2d_PREFS.Col_BoxAxeSel;
Col_BoxTitleSel = dw2d_PREFS.Col_BoxTitleSel;
Wid_LineSel   = dw2d_PREFS.Wid_LineSel;

img_hdl = findobj(win_dw2dtool,'Type','image');
switch option
    case 'get_img'
        sel_obj = get(win_dw2dtool,'currentobject');
        Img_Dec = findobj(img_hdl,'Tag',tag_imgdec);
        obj_sel = findobj(img_hdl,'Tag',tag_imgsel);
        ind     = find(sel_obj==[Img_Dec;obj_sel],1);
        if ~isempty(ind)
            if ~isempty(obj_sel)
                set(obj_sel,'Tag',tag_imgdec);
                axe = get(obj_sel,'Parent');
                set(axe,'XColor',Col_BoxAxeSel, ...
                        'YColor',Col_BoxAxeSel, ...
                        'LineWidth',0.5         ...
                        );
                col_lab = get(win_dw2dtool,'DefaultAxesXColor');
                set(get(axe,'xlabel'),'Color',col_lab);
                if obj_sel==sel_obj
                    if nargout>0 , out1 = []; end
                    return; 
                end
            end
            axe = get(sel_obj,'Parent');
            set(axe,...
                    'XColor',Col_BoxTitleSel,   ...
                    'YColor',Col_BoxTitleSel,   ...
                    'LineWidth',Wid_LineSel,    ...
                    'Box','On'                  ...
                    );
            pause(0.01); axes(axe)
            set(sel_obj,'Tag',tag_imgsel);
            if nargout>0 , out1 = sel_obj; end
        end

    case 'clean'
        obj_sel = findobj(img_hdl,'Tag',tag_imgsel);
        if ~isempty(obj_sel)
            set(obj_sel,'Tag',tag_imgdec);
            axe = get(obj_sel,'Parent');
            set(axe,'XColor',Col_BoxAxeSel, ...
                    'YColor',Col_BoxAxeSel, ...
                    'LineWidth',0.5         ...
                    );
            col_lab = get(win_dw2dtool,'DefaultAxesXColor');
            set(get(axe,'xlabel'),'Color',col_lab);
            if nargout>0 , out1 = []; end
        end

    case 'cleanif'
        % for view_dec
        % in3 = new_lev_dec
        % in4 = old_lev_dec
        %----------------------------
        obj_sel = findobj(img_hdl,'Tag',tag_imgsel);
        if ~isempty(obj_sel)
            us = get(obj_sel,'UserData');
            %---------------------------%
            %- us = [0;k;m]
            %- k = level ;
            %- m = 1 : v ; m = 2 : d ;             
            %- m = 3 : h ; m = 4 : a ;     
            %----------------------------%
            if (us(2)<=in3)
                if (in4>in3) || (us(3)<4) , return; end
            end
            set(obj_sel,'Tag',tag_imgdec);
            axe = get(obj_sel,'Parent');
            set(axe,'XColor',Col_BoxAxeSel, ...
                    'YColor',Col_BoxAxeSel, ...
                    'LineWidth',0.5         ...
                    );
            col_lab = get(win_dw2dtool,'DefaultAxesXColor');
            set(get(axe,'xlabel'),'Color',col_lab);
        end

    case 'get'
        out1 = findobj(img_hdl,'Tag',tag_imgsel);

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
