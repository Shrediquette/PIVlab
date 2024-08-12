function varargout = cbthrw1d(option,in2,in3,in4,in5,in6)
%CBTHRW1D Callbacks for threshold utilities 1-D.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-97.
%   Last Revision 06-Aug-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.10.4.12 $  $Date: 2013/08/23 23:44:51 $

% MB1 of stored values.
%----------------------
n_membloc1   = 'ReturnTHR_Bloc';
% ind_ret_fig  = 1;
% ind_tog_thr  = 2;
ind_status   = 3;
% nb1_stored   = 3;

% Same bloc in utthrw1d.
%-----------------------
n_memblocTHR   = 'MB_ThrStruct';
ind_thr_struct = 1;
% ind_int_thr    = 2;

% Tag property.
%--------------
tag_lineH_up   = 'LH_u';
tag_lineH_down = 'LH_d';
tag_lineV      = 'LV';

% First test DYNVTOOL Select Option.
%----------------------------------
if ~ischar(option)
    varargout = {[],[]};
    x   = option;
    % y   = in2;
    axe = in3;
    ok  = find(axe==in4, 1);
    if isempty(ok) , return; end
    %-------------------------------
    lines = findobj(axe,'Type','line');
    lHu   = findobj(lines,'Tag',tag_lineH_up);
    lHd   = findobj(lines,'Tag',tag_lineH_down);
    ll    = findobj(lines,'Tag',tag_lineV);
    NB_LV = length(ll);
    tol   = 0.01;
    xh    = get(lHu,'XData');
    i_inf = find(xh<=x,1,'last' );
    i_sup = find(xh>x,1);
    if ~isequal(i_sup,i_inf+1) , return; end
    yh = get(lHu,'YData');
    [ecx,ii] = min([x-xh(i_inf),xh(i_sup)-x]);
    xlim = get(axe,'XLim');
    dlim = xlim(2)-xlim(1);
    ecx  = ecx/dlim;
    fig = get(axe,'Parent');
    if ecx>tol              % Create line
        if NB_LV>=10 , return; end
        xh = [xh(1:i_inf)  x          NaN  x          xh(i_sup:end)];
        yh = [yh(1:i_inf)  yh(i_inf)  NaN  yh(i_inf)  yh(i_sup:end)];
        set(lHu,'XData',xh,'YData',yh)
        set(lHd,'XData',xh,'YData',-yh)
        ylim = get(axe,'YLim');
        cbthrw1d('plotLV',[fig ; lHu ; lHd],[x x NaN; ylim NaN]);
    else
        if NB_LV==0
            return
        end
        xval = get(ll,'XData');
        if NB_LV>1
            xval = cat(1,xval{:});
        end
        xval = xval(:,1);
        if ii==1
            i_suppress = i_inf-2:i_inf;
        else
            i_suppress = i_sup:i_sup+2;
        end
        ind_lv = find((abs(xval-x)/dlim)<tol);
        if ~isempty(ind_lv)
            lv = ll(ind_lv);
            delete(lv);
            drawnow
        else
            return
        end
        xh(i_suppress) = [];
        ynew = (yh(i_suppress(1))+yh(i_suppress(3)))/2;
        yh(i_suppress(1)-1) = ynew;
        yh(i_suppress(3)+1) = ynew;
        yh(i_suppress) = [];
        set(lHu,'XData',xh,'YData',yh)
        set(lHd,'XData',xh,'YData',-yh)
    end
    cbthrw1d('upd_thrStruct',fig,lHu);
    pause(0.5)
    return
end

switch option
    case 'downH'
        % in2 = [fig ; lin_max ; lin_min]
        %     in2(4:6) =  [pop_int ; sli_lev ; edi_lev] (optional)
        % in3 = +1 or -1
        %---------------------------------------------------------
        flag_HDL = (length(in2)>3);
        axe = get(in2(2),'Parent');
        if (axe~=gca) , axes(axe); end 
        fig   = in2(1);
        p     = get(axe,'CurrentPoint');
        xold  = get(in2(2),'XData');
        i_inf = find(xold<p(1,1),1,'last');
        i_sup = find(xold>p(1,1),1);
        if ~isequal(i_sup,i_inf+1) , return; end
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        feval(calledFUN,'clear_GRAPHICS',fig);
        if flag_HDL
            num_int = fix(i_inf/3)+1;
            val_pop = get(in2(4),'Value');
            if num_int~=val_pop
                yold = get(in2(2),'YData');
                thr  = abs(yold(i_inf));
                set(in2(4),'Value',num_int)
                set(in2(5),'Value',thr);
                set(in2(6),'String',sprintf('%1.4g',thr));
            end
        end
        set(in2(2:3),'Color','g');
        drawnow

        cba_move = @(~,~)cbthrw1d('moveH', in2, in3, i_inf );
        cba_up   = @(~,~)cbthrw1d('upH',in2);
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        setptr(fig,'uddrag');

    case 'moveH'
        % in2 = [fig ; lin_max ; lin_min]
        %      in2(4:6) =  [pop_int ; sli_lev ; edi_lev] (optional)
        % in3 = +1 or -1
        % in4 = index point
        %-----------------------------------------------------------
        flag_HDL = (length(in2)>3);
        lin_max  = in2(2);
        axe = get(lin_max,'Parent'); 
        p   = get(axe,'CurrentPoint');
        new_thresh = p(1,2)*in3;
        if flag_HDL
            min_sli = get(in2(5),'Min');
            max_sli = get(in2(5),'Max');
            new_thresh = max([min_sli,min([new_thresh,max_sli])]);
        else
            lineUD = get(lin_max,'UserData');
            new_thresh = min([max([new_thresh,0]),lineUD.max]);
        end

        yold = get(lin_max,'YData');
        if isequal(yold(in4),new_thresh)
            return;
        end

        ynew = yold;
        ynew([in4 in4+1]) = [new_thresh new_thresh];
        set(lin_max,'YData',ynew);
        if new_thresh<sqrt(eps)
            ynew([in4 in4+1]) = [NaN NaN];
        end
    
        set(in2(3),'YData',-ynew);
        if flag_HDL
            set(in2(5),'Value',new_thresh);
            set(in2(6),'String',sprintf('%1.4g',new_thresh));
        end

    case 'upH'
        % in2 = [fig ; lin_max ; lin_min]
        %      in2(4:6) =  [pop_int ; sli_lev ; edi_lev] (optional)
        %----------------------------------------------------------- 
        fig = in2(1);
        lHu = in2(2);
        lHd = in2(3);
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        ax = wfindobj(fig,'Type','axes');
        set(fig,'WindowButtonMotionFcn',wtmotion(ax), ...
            'WindowButtonUpFcn',save_WindowButtonUpFcn);
        cbthrw1d('upd_thrStruct',fig,lHu);
        figDef = get(fig,'Default');
        try
          linCol  = figDef.defaultAxesColorOrder(1,:);
        catch %#ok<CTCH>
          linCol  = figDef.axesColorOrder(1,:);
        end
        set([lHu;lHd],'Color',linCol);
        drawnow;
        utthrw1d('show_LVL_perfos',fig);
        setptr(fig,'arrow');

    case 'plotLH'
        % in2 = ax_hdl or...
        % in2 = [pop_ind ; sli_lev ; edi_lev ; ax_hdl] (optional)
        % in3 = xHOR
        % in4 = yHOR
        % in5 = ind_lev
        % in6 = max(abs(sig))
        %--------------------
        LW = 1;
        flg_HDL = (length(in2)>1);
        if flg_HDL==0 , ax_hdl = in2(1); else ax_hdl = in2(4); end
        xHOR    = in3;
        yHOR    = in4;
        ind_lev = in5;  
        fig     = get(ax_hdl,'Parent');
        figDef  = get(fig,'Default');
        try
          linCol  = figDef.defaultAxesColorOrder(1,:);
        catch %#ok<CTCH>
          linCol  = figDef.axesColorOrder(1,:);
        end
        lineUD.lev = ind_lev;
        lineUD.hdl = in2;
        lineUD.max = in6;
        vis = get(ax_hdl,'Visible');
        commonProp = {...
            'Parent',ax_hdl,   ...
            'Visible',vis,     ...
            'XData',xHOR,      ...
            'LineStyle','--',  ...
            'LineWidth',LW,     ...
            'Color',linCol,    ...
            'UserData',lineUD  ...
            };
        lHu = line(commonProp{:},'YData',yHOR,'Tag',tag_lineH_up);
        ind = find(abs(yHOR)<sqrt(eps));
        if ~isempty(ind)
            yHOR(ind) = NaN;
        end
        lHd = line(commonProp{:},'YData',-yHOR,'Tag',tag_lineH_down);
        handles = [fig ;lHu ;lHd];
        if flg_HDL
            handles = [handles ; in2(1:3)];
        end

        cba_thr_max = @(~,~)cbthrw1d('downH',handles, +1);
        cba_thr_min = @(~,~)cbthrw1d('downH',handles, -1);
        set(lHu,'ButtonDownFcn',cba_thr_max)
        set(lHd,'ButtonDownFcn',cba_thr_min)
        varargout = {lHu,lHd};
        setappdata(lHu,'selectPointer','H')
        setappdata(lHd,'selectPointer','H')

    case 'downV'
        % in2 = [fig ; lin_ver ; lin_max ; lin_min]
        %------------------------------------------
        fig   = in2(1);
        setptr(fig,'arrow');
        lin_ver = in2(2); 
        axe = get(lin_ver,'Parent');
        if (axe~=gca), axes(axe); end 
        % p     = get(axe,'CurrentPoint');
        xv    = get(lin_ver,'XData');
        xv    = xv(1);
        xh    = get(in2(3),'XData');
        i_inf = find(xh==xv,1);
        i_sup = find(xh==xv,1,'last');
        if ~isequal(i_sup,i_inf+2) , return; end
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        feval(calledFUN,'clear_GRAPHICS',fig);
        set(lin_ver,'Color','g');
        drawnow

        % Getting memory blocks.
        %-----------------------

        cba_move = @(~,~)cbthrw1d('moveV', in2 , ...
                        [i_inf i_sup]);
        cba_up   = @(~,~)cbthrw1d('upV', in2);
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        setptr(fig,'lrdrag');

    case 'moveV'
        % in2 = [fig ; lin_ver ; lin_max ; lin_min]
        % in3 = point indices
        %------------------------------------------
        lin_ver = in2(2);
        if ~ishandle(lin_ver) , return; end    
        axe = get(lin_ver,'Parent');
        p   = get(axe,'CurrentPoint');
        new_thresh = p(1,1);
        xold = get(lin_ver,'XData');
        xnew = [new_thresh new_thresh];
        if isequal(xold,xnew) , return; end
        xh = get(in2(3),'XData');
        if (new_thresh<=xh(in3(1)-1)+sqrt(eps)) || ...
           (new_thresh>=xh(in3(2)+1)-sqrt(eps))
           return
        end    
        xh(in3) = xnew;
        set(lin_ver,'XData',xnew);
        set(in2(3),'XData',xh);
        set(in2(4),'XData',xh);

    case 'upV'
        % in2 = [fig ; lin_ver ; lin_max ; lin_min]
        %------------------------------------------- 
        fig = in2(1);
        lv  = in2(2);
        lHu = in2(3);
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        ax = wfindobj(fig,'Type','axes');
        set(fig,'WindowButtonMotionFcn',wtmotion(ax),...
			'WindowButtonUpFcn',save_WindowButtonUpFcn);
        if ~ishandle(lv) , return; end
        cbthrw1d('upd_thrStruct',fig,lHu);
        set(lv,'Color','r');
        drawnow;
        utthrw1d('show_LVL_perfos',fig);
        setptr(fig,'arrow');

    case 'plotLV'
        % in2 = [fig ; lin_max ; lin_min]
        % in3 = [xHOR ; yHOR]
        % in4 = yVMin (optional)
        %--------------------------------
        fig  = in2(1);
        lHu  = in2(2);
        lHd  = in2(3);
        xHOR = in3(1,:);
        yHOR = in3(2,:);
        if nargin<4
            yVMin   = 0;
        else
            yVMin   = in4;
        end
        ax_hdl = get(lHu,'Parent');
        vis    = get(ax_hdl,'Visible');
        NB_int = fix(length(xHOR)/3)+ 1;
        for k=1:NB_int-1
            x    = xHOR(3*k-1);
            xVER = [x x];
            y    = max(abs([yHOR(3*k-1),yVMin]));
            yVER = [-y y];
            lv   = line(...
                        'Parent',ax_hdl,   ...
                        'Visible',vis,     ...
                        'XData',xVER,      ...
                        'YData',yVER,      ...
                        'LineStyle','--',  ...
                        'MarkerSize',2,    ...
                        'LineWidth',2,     ...
                        'Color','r',       ...
                        'Tag',tag_lineV    ...
                        );
            hdl_str = [fig ; lv ; lHu ; lHd];
            cba_LV  = @(~,~)cbthrw1d('downV',hdl_str);
            set(lv,'ButtonDownFcn',cba_LV)
            setappdata(lv,'selectPointer','V')
        end

    case 'upd_thrStruct'
        % in2 = fig
        % in3 = lHu
        %-----------
        fig     = in2;
        lHu     = in3;
        x       = get(lHu,'XData');
        y       = get(lHu,'YData');
        lineUD  = get(lHu,'UserData');
        level   = lineUD.lev;
        handles = lineUD.hdl;
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        thrParams = getparam(x,y);
        thrStruct(level).thrParams = thrParams;
        if length(handles)>1
            pop_int = handles(1);
            nb_int  = size(thrParams,1);
            nb_val  = size(get(pop_int,'String'),1);
            if nb_int~=nb_val
                set(pop_int,'String',int2str((1:nb_int)'),'Value',1)
                thr = thrParams(1,3);
                set(handles(2),'Value',thr);                    % Slider
                set(handles(3),'String',sprintf('%1.4g',thr));  % Edit
            end
        end
        wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,thrStruct);
        hmb = wmemtool('hmb',fig,n_membloc1);
        if ~isempty(hmb) , wmemtool('wmb',fig,n_membloc1,ind_status,1); end

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end

%--------------------------------------%
function param = getparam(x,y)

lx    = length(x);
x_beg = x(1:3:lx);
x_end = x(2:3:lx);
y     = y(1:3:lx);
param = [x_beg(:) , x_end(:) , y(:)];
%--------------------------------------%
