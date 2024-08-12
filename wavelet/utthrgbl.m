function varargout = utthrgbl(option,fig,varargin)
%UTTHRGBL Utilities for global thresholding (compression).
%   VARARGOUT = UTTHRGBL(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Sep-98.
%   Last Revision: 29-May-2014.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.7.4.18 $  $Date: 2013/09/14 19:39:04 $

% Tag property.
%--------------
tag_fra_tool = ['Fra_' mfilename];

switch option
  case {'move','up','down','create'}  

  otherwise
    % ud.handlesUIC = ...
    %   [fra_utl;txt_top;pop_met; ...
    %    txt_sel;sli_sel;edi_sel; ...
    %    txt_nor;edi_nor;txt_npc; ...
    %    txt_zer;edi_zer;txt_zpc; ...
    %    tog_res;pus_est];
    %---------------------------------
    uic = findobj(get(fig,'Children'),'flat','Type','uicontrol');
    fra = findobj(uic,'Style','frame','Tag',tag_fra_tool);
    if isempty(fra) , return; end
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    ud = get(fra,'UserData');
    toolOPT = ud.toolOPT;
    handlesUIC = ud.handlesUIC;
    handlesOBJ = ud.handlesOBJ;
    switch option
      case 'handles'
        handles = [handlesUIC(:);handlesOBJ(:)];
        varargout{1} = handles(ishandle(handles));
        return;
      case {'handlesUIC','handlesuic'}
        varargout{1} = handlesUIC;
        return;
    end
    ind = 2;
    txt_top = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    pop_met = handlesUIC(ind); ind = ind+1;
    txt_sel = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    sli_sel = handlesUIC(ind); ind = ind+1;
    edi_sel = handlesUIC(ind); ind = ind+1;
    txt_nor = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    edi_nor = handlesUIC(ind); ind = ind+1;
    txt_npc = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    txt_zer = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    edi_zer = handlesUIC(ind); ind = ind+1;
    txt_zpc = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    tog_res = handlesUIC(ind); ind = ind+1;
    pus_est = handlesUIC(ind);              
end

switch option
    case 'down'
        % in2 = [ axe_perf ;  
        %         lin_norm ; lin_zero ; lin_perf ; ...
        %         sli_sel ;  edi_sel ; edi_nor ; edi_zer ];
        %--------------------------------------------------------------
        sel_type = get(fig,'SelectionType');
        if strcmp(sel_type,'open') , return; end
        axe = varargin{1}(1);
        if (axe~=gca) , axes(axe); end 
    
        % Setting the thresholded coefs axes invisible.
        %----------------------------------------------
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        feval(calledFUN,'clear_GRAPHICS',fig);
        lin_perf = varargin{1}(4);
        set(lin_perf,'Color','g');
        drawnow

        cba_move = @(~,~)utthrgbl('move', fig, varargin{1});
        cba_up   = @(~,~)utthrgbl('up', fig, varargin{1});
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);

    case 'move'
        % in2 = [ axe_perf ;  
        %         lin_norm ; lin_zero ; lin_perf ; ...
        %         sli_sel ;  edi_sel ; edi_nor ; edi_zer ];
        %--------------------------------------------------
        axe = varargin{1}(1);
        p = get(axe,'CurrentPoint');
        new_thresh = p(1,1);
        sli_sel = varargin{1}(5);
        min_sli = get(sli_sel,'Min');
        max_sli = get(sli_sel,'Max');
        new_thresh = max(min_sli,min(new_thresh,max_sli));
        xnew = [new_thresh new_thresh];
        xold = get(varargin{1}(4),'XData');
        if isequal(xold,xnew) , return; end
        [new_rl2scr,new_n0scr,new_thresh_BIS] = ...
                key2info(varargin{1}(2),varargin{1}(3),new_thresh,'T');
        if new_rl2scr~=100 ,  new_thresh = new_thresh_BIS; end
        set(varargin{1}(4),'XData',xnew);
        set(sli_sel,'Value',new_thresh);
        set(varargin{1}(6),'String',sprintf('%1.4g',new_thresh));
        set(varargin{1}(7),'String',sprintf('%5.2f',new_rl2scr));
        set(varargin{1}(8),'String',sprintf('%5.2f',new_n0scr));

    case 'up'
        % in2 = [ axe_perf ;  
        %         lin_norm ; lin_zero ; lin_perf ; ...
        %         sli_sel ;  edi_sel ; edi_nor ; edi_zer ];
        %--------------------------------------------------
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        ax = wfindobj(fig,'Type','axes');
        set(fig,'WindowButtonMotionFcn',wtmotion(ax),...
			'WindowButtonUpFcn',save_WindowButtonUpFcn);
        set(varargin{1}(4),'Color',wtbutils('colors','Col_THR_GBL'));
        drawnow;

    case 'create'

        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width, ...
         sliYProp,Def_FraBkColor,Def_EdiBkColor,Def_ShadowColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
                'Sli_YProp', ...
                'Def_FraBkColor','Def_EdiBkColor','Def_ShadowColor');

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor;
        visVal = 'on';
        isbior = 0;
        toolOPT = 'dw1dcomp';

        % Inputs.
        %--------        
        nbarg = length(varargin);
        for k=1:2:nbarg
            arg = lower(varargin{k});
            switch arg
              case 'left'    , xleft   = varargin{k+1};
              case 'right'   , xright  = varargin{k+1};
              case 'xloc'    , xloc    = varargin{k+1};
              case 'bottom'  , ybottom = varargin{k+1};
              case 'top'     , ytop    = varargin{k+1};
              case 'yloc'    , yloc    = varargin{k+1};
              case 'bkcolor' , bkColor = varargin{k+1};
              case 'visible' , visVal  = varargin{k+1};
              case 'isbior'  , isbior  = varargin{k+1};
              case 'toolopt' , toolOPT = varargin{k+1};
            end 
        end

        % Structure initialization.
        %--------------------------
        ud = struct(...
                'toolOPT',toolOPT, ...
                'visible',lower(visVal),...
                'isbior',isbior, ...
                'handlesUIC',[], ...
                'handlesOBJ',[], ...
                'handleORI' ,[], ... 
                'handleTHR' ,[], ... 
                'handleRES' ,[]  ... 
                );

        % Figure units.
        %--------------

        old_units  = get(fig,'Units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'Units',fig_units); end       

        % Positions utilities.
        %---------------------        
        bdx = 3;
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        bdy = wtbutils('utthrgbl_PREFS');
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);
        txt_width = Def_Btn_Width;

        % Setting frame position.
        %------------------------
        w_fra   = mextglob('get','Fra_Width');
        h_fra   = 6*Def_Btn_Height+6.5*bdy;
                   
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % Position property.
        %-------------------
        xleft = xleft+bdx;
        w_rem = w_fra-2*bdx;
        ylow  = ybottom+h_fra-Def_Btn_Height-bdy;

        w_uic       = (5*txt_width)/2;
        x_uic       = xleft+(w_rem-w_uic)/2;
        y_uic       = ylow;
        pos_txt_top = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-2*bdy;
        pos_txt_sel = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        wid1        = (15*w_rem)/26;
        wid2        = (8*w_rem)/26;
        wid3        = (2*w_rem)/26;
        wx          = (w_rem-wid1-wid2-wid3)/4;
        
        pos_sli_sel = [xleft+wx, y_uic+sli_dy, wid1-wx, sli_hi];
        x_uic       = pos_sli_sel(1)+pos_sli_sel(3)+wx;
        pos_edi_sel = [x_uic, y_uic, wid2, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;        
        pos_txt_nor = [xleft, y_uic+d_txt/2, wid1, Def_Txt_Height];
        x_uic       = pos_txt_nor(1)+pos_txt_nor(3)+wx;
        pos_edi_nor = [x_uic, y_uic, wid2, Def_Btn_Height];
        x_uic       = pos_edi_nor(1)+pos_edi_nor(3)+wx;
        pos_txt_npc = [x_uic, y_uic+d_txt/2, wid3, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;       
        pos_txt_zer = [xleft, y_uic+d_txt/2, wid1, Def_Txt_Height];
        x_uic       = pos_txt_zer(1)+pos_txt_zer(3)+wx;
        pos_edi_zer = [x_uic, y_uic, wid2, Def_Btn_Height];
        x_uic       = pos_edi_zer(1)+pos_edi_zer(3)+wx;
        pos_txt_zpc = [x_uic, y_uic+d_txt/2, wid3, Def_Txt_Height];

        w_uic = w_fra/2-bdx;
        x_uic = pos_fra(1);
        h_uic = (3*Def_Btn_Height)/2;
        y_uic = pos_fra(2)-h_uic-Def_Btn_Height;     
        pos_pus_est = [x_uic, y_uic, w_uic, h_uic];
        x_uic = pos_fra(1)+w_uic+2*bdx;
        pos_tog_res = [x_uic, y_uic, w_uic, h_uic];

        % String property.
        %-----------------
        str_txt_top = getWavMSG('Wavelet:commongui:Str_SelThrMet');
        str_pop_met = wthrmeth(toolOPT,'names');
        if ud.isbior
            str_txt_nor = getWavMSG('Wavelet:commongui:Str_NormRec');
        else
            str_txt_nor = getWavMSG('Wavelet:commongui:Str_RetEner');
        end
        str_txt_sel = getWavMSG('Wavelet:commongui:Str_SelGlbThr');
        str_txt_zer = getWavMSG('Wavelet:commongui:Str_ZerNb');
        str_tog_res = getWavMSG('Wavelet:commongui:Str_Residuals');
        str_pus_est = getWavMSG('Wavelet:commongui:Str_Compress');

        % Create UIC.
        %------------
        comProp = {...
           'Parent',fig,    ...
           'Units',fig_units ...
           'Visible',visVal ...
           };

        commonTxtProp = [comProp, ...
            'Style','Text',...
            'BackgroundColor',Def_FraBkColor...
            ];        

        commonEdiProp = [comProp, ...
            'Style','Edit',...
            'String',' ',...
            'BackgroundColor',Def_EdiBkColor,...
            'HorizontalAlignment','center'...
            ];        

        fra_utl = uicontrol(comProp{:}, ...
            'Style','frame', ...
            'Position',pos_fra, ...
            'BackgroundColor',bkColor, ...
            'ForeGroundColor',Def_ShadowColor,...
            'Tag',tag_fra_tool ...
            );

        txt_top = uicontrol(commonTxtProp{:},      ...
            'Position',pos_txt_top,...
            'HorizontalAlignment','center',...
            'String',str_txt_top   ...
            );

        cba = @(~,~)utthrgbl('update_methName', fig );
        pop_met = uicontrol(comProp{:}, ...
            'Style','Popup',...
            'Position',pos_pop_met,...
            'String',str_pop_met,...
            'HorizontalAlignment','center',...
            'UserData',1,...
            'Callback',cba ...
            );

        txt_sel = uicontrol(commonTxtProp{:},      ...
            'Position',pos_txt_sel,...
            'HorizontalAlignment','center',...
            'String',str_txt_sel   ...
            );

        cba_sli = @(~,~)utthrgbl('updateTHR', fig ,'sli');
        sli_sel = uicontrol(comProp{:}, ...
            'Style','Slider',...
            'Position',pos_sli_sel,...
            'Min',0,...
            'Max',1,...
            'Value',0.5, ...
            'Callback',cba_sli, ...
            'Tag', 'sli_sel' ...
            );


        cba_edi = @(~,~)utthrgbl('updateTHR', fig ,'edi');
        edi_sel = uicontrol(commonEdiProp{:}, ...
            'Position',pos_edi_sel,...
            'Callback',cba_edi, ...
            'Tag', 'edi_sel' ...
            );

        txt_nor = uicontrol(commonTxtProp{:}, ...
            'Position',pos_txt_nor,...
            'HorizontalAlignment','left',...
            'String',str_txt_nor...
            );

        cba_nor = @(~,~)utthrgbl('updateTHR', fig ,'nor');
        edi_nor = uicontrol(commonEdiProp{:}, ...
            'Position',pos_edi_nor,...
            'Callback',cba_nor ...
            );

        txt_npc = uicontrol(commonTxtProp{:}, ...
            'Position',pos_txt_npc,...
            'HorizontalAlignment','center',...
            'String','%'...
            );

        txt_zer = uicontrol(commonTxtProp{:}, ...
            'Position',pos_txt_zer,...
            'HorizontalAlignment','left',...
            'String',str_txt_zer...
            );

        cba_zer = @(~,~)utthrgbl('updateTHR', fig ,'zer');
        edi_zer = uicontrol(commonEdiProp{:}, ...
            'Position',pos_edi_zer,...
            'Callback',cba_zer ...
            );

        txt_zpc = uicontrol(commonTxtProp{:}, ...
            'Position',pos_txt_zpc,...
            'HorizontalAlignment','center',...
            'String','%'...
            );

        cba = @(~,~)utthrgbl('residuals', fig);
        tip = getWavMSG('Wavelet:commongui:Tip_MoreOnRes');
        tog_res = uicontrol(comProp{:}, ...
            'Style','Togglebutton', ...
            'Position',pos_tog_res, ...
            'String',str_tog_res,   ...
            'Enable','off',         ...
            'Callback',cba,         ...
            'TooltipString',tip,    ...
            'Interruptible','On'    ...
            );

        cba_pus_est = @(~,~)utthrgbl('compress', fig);
        pus_est = uicontrol(comProp{:},             ...
            'Style','pushbutton',   ...
            'Position',pos_pus_est, ...
            'String',str_pus_est,   ...
            'Tag','Pus_Estimate', ...
            'Callback',cba_pus_est  ...
            );

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
        hdl_COMP_DENO_STRA = [...
			fra_utl,txt_top,pop_met; ...
            txt_sel,sli_sel,edi_sel  ...		
			];
        hdl_COMP_SCORES = [...			
             txt_nor,edi_nor,txt_npc, ...
             txt_zer,edi_zer,txt_zpc  ...
	 		];
		wfighelp('add_ContextMenu',fig,hdl_COMP_DENO_STRA,'COMP_DENO_STRA');
		wfighelp('add_ContextMenu',fig,hdl_COMP_SCORES,'COMP_SCORES');
		%-------------------------------------

		% Store handles.
		%--------------
		ud.handlesUIC = ...
            [fra_utl;txt_top;pop_met; ...
             txt_sel;sli_sel;edi_sel; ...
             txt_nor;edi_nor;txt_npc; ...
             txt_zer;edi_zer;txt_zpc; ...
             tog_res;pus_est];
        set(fra_utl,'UserData',ud);
        if nargout>0
            varargout{1} = [pos_fra(1) , pos_pus_est(2) , pos_fra([3 4])];
        end

    case 'displayPerf'
        % Displaying perfos.
        %-------------------
        [pos_axe_perf,pos_axe_legend, ...
            thresh,n0scr,rl2scr,suggthr] = deal(varargin{:});
        fig_units = get(fig,'Units');
        comAxeProp = {...
          'Parent',fig, ...
          'Units',fig_units, ...
          'Box','On' ...
          };
        [Col_LinTHR,Col_LinNOR,Col_LinZER] = wtbutils('colors','Col_THR_GBL');
        axe_perf = axes(comAxeProp{:},'Position',pos_axe_perf);
        epsx = 0.0001;
        xlim = [-epsx    1.01*max(thresh)+epsx];
        set(axe_perf,'XLim',xlim,'YLim',[0 104]);
        lin_zero = line('XData',thresh,...
            'YData',n0scr,...
            'Color',Col_LinZER,...
            'LineWidth',1.5,...
            'Parent',axe_perf);
        lin_norm = line('XData',thresh,...
            'YData',rl2scr,...
            'Color',Col_LinNOR,...
            'LineWidth',1.5,...            
            'Parent',axe_perf);
        if max(n0scr)==min(n0scr)   , set(lin_zero,'LineWidth',2); end
        if max(rl2scr)==min(rl2scr) , set(lin_norm,'LineWidth',2); end
        lin_perf = line('XData',[suggthr suggthr],...
            'YData',[0.5 104],...
            'Color',Col_LinTHR,...
            'LineStyle',':',...
            'LineWidth',1.5,...            
            'Parent',axe_perf);
        setappdata(lin_perf,'selectPointer','V')
        handles = [axe_perf ; lin_norm ; lin_zero ; lin_perf; ...
                   sli_sel ; edi_sel ; edi_nor ; edi_zer        ...
                   ];

        cba_lin_perf = @(~,~)utthrgbl('down', fig, handles);
        set(lin_perf,'ButtonDownFcn',cba_lin_perf);

        % Displaying legend.
        %-------------------
        ftnsize = get(0,'DefaultAxesFontSize');
        ud.dynvzaxe.enable = 'off';
        axe_legend  = axes(comAxeProp{:}, ...
            'Position',pos_axe_legend,       ...
            'XTickLabelMode','manual',       ...
            'YTickLabelMode','manual',       ...
            'XTicklabel',[],'YTickLabel',[], ...
            'XTick',[],'YTick',[],           ...
            'XLim',[0 180],                  ...
            'YLim',[0 20],                   ...
            'Fontsize',ftnsize,              ...
            'UserData',ud                    ...
            );
        
        line(...
             'Parent',axe_legend,...
             'XData',11:25,...
             'YData',ones(1,15)*15,...
             'LineStyle',':',...
             'Color',Col_LinTHR);

        line(...
             'Parent',axe_legend,...
             'XData',11:25,...
             'YData',ones(1,15)*10,...
             'Color',Col_LinNOR);

        line(...
             'Parent',axe_legend,...
             'XData',11:25,...
             'YData',ones(1,15)*5,...
             'Color',Col_LinZER);

        text(30,15,getWavMSG('Wavelet:commongui:Str_GlbThr'),'Parent',axe_legend);
        if ud.isbior
            str_norm_txt = getWavMSG('Wavelet:commongui:Str_PerNR');
        else
            str_norm_txt = getWavMSG('Wavelet:commongui:Str_PerRE');
        end
        text(30,10,str_norm_txt,'Parent',axe_legend);
        text(30,5,getWavMSG('Wavelet:commongui:Str_PerZER'),'Parent',axe_legend);
        ud.handlesOBJ.axes  = [axe_perf ; axe_legend]; 
        ud.handlesOBJ.lines = [lin_norm ; lin_zero ; lin_perf]; 
        set(fra,'UserData',ud);

    case 'visible'
        visVal     = lower(varargin{1});
        ud.visible = visVal;
        axe_datas = ud.handlesOBJ.axes;
        handles = [findobj(axe_datas(:));handlesUIC(:)];
        set(handles(ishandle(handles)),'Visible',visVal);

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:nbarg
           outType = lower(varargin{k});
           switch outType
             case 'position'  , varargout{k} = get(fra,'Position'); %#ok<*AGROW>
             case 'valthr'    , varargout{k} = get(sli_sel,'Value');
             case 'handleori' , varargout{k} = ud.handleORI;
             case 'handlethr' , varargout{k} = ud.handleTHR;
             case 'handleres' , varargout{k} = ud.handleRES;
             case 'handlesuic', varargout{k} = ud.handlesUIC;
             case 'tog_res'   , varargout{k} = tog_res;
             case 'pus_est'   , varargout{k} = pus_est;
           end
        end

    case 'getPerfo'
       lin_norm  = handlesOBJ.lines(1);
       lin_zero  = handlesOBJ.lines(2);
       threshold = get(sli_sel,'Value');
       [varargout{1},varargout{2}] = key2info(lin_norm,lin_zero,threshold,'T');

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = lower(varargin{k});
           argVal  = varargin{k+1};
           switch argType
             case 'handleori' , ud.handleORI = argVal; set(fra,'UserData',ud);
             case 'handlethr' , ud.handleTHR = argVal; set(fra,'UserData',ud);
             case 'handleres' , ud.handleRES = argVal; set(fra,'UserData',ud);
             case 'thrbounds'
               argVal(3) = max(argVal(3),sqrt(eps));  
               set(sli_sel,'Min',argVal(1),'Value',argVal(2), ...
                   'Max',argVal(3),'UserData',argVal(2));
               set(edi_sel,'String',sprintf('%1.4g',argVal(2)));
             case 'perfo'
               set(edi_nor,'String',sprintf('%5.2f',argVal(1)));
               set(edi_zer,'String',sprintf('%5.2f',argVal(2)));
           end
        end

    case 'compress'
        feval(calledFUN,'compress',fig);

    case 'update_by_Caller'
        feval(calledFUN,'update_GBL_meth',fig);

    case 'get_GBL_par'
        numMeth = get(pop_met,'Value');
        meth    = wthrmeth(toolOPT,'shortnames',numMeth);
        varargout = {numMeth , meth , get(sli_sel,'Value')};

    case 'update_GBL_meth'
        % called by : calledFUN('update_GBL_meth', ...)
        %------------------------------------------------
        valTHR = varargin{1};
        utthrgbl('updateTHR',fig,'meth',valTHR);

    case 'enable_tog_res'
        enaVal = varargin{1};        
        try 
            Pus_SigDorC = wfindobj(fig,'Tag','Pus_SigDorC');
        catch %#ok<CTCH>
            Pus_SigDorC = [];
        end
        set([tog_res,Pus_SigDorC],'Enable',enaVal);        

    case 'update_methName'
        utthrgbl('update_by_Caller',fig)

    case 'updateTHR'
        upd_orig = varargin{1};
        lin_norm = handlesOBJ.lines(1);
        lin_zero = handlesOBJ.lines(2);
        lin_perf = handlesOBJ.lines(3);

        % Updating compression information.
        %----------------------------------
        count = 0; err = '';
        valstr_SEL = get(edi_sel,'String');
        [keyval_SEL,count_SEL,err_SEL] = sscanf(valstr_SEL,'%f');
        valstr_NOR = get(edi_nor,'String');
        [keyval_NOR,count_NOR,err_NOR] = sscanf(valstr_NOR,'%f');
        valstr_ZER = get(edi_zer,'String');
        [keyval_ZER,count_ZER,err_ZER] = sscanf(valstr_ZER,'%f');
        keyval_SLI = get(sli_sel,'Value');
        
        switch upd_orig
           case 'sli'  % Default

           case 'edi'
             keytype = 'T';
             keyval = keyval_SEL; count = count_SEL; err = err_SEL;

           case 'nor'
             keytype = 'N';
             keyval = keyval_NOR; count = count_NOR; err = err_NOR;

           case 'zer'
             keytype = 'Z';
             keyval = keyval_ZER; count = count_ZER; err = err_ZER;

           case 'meth'
             keytype = 'T';
             keyval  = varargin{2};
             count   = 1;
        end
        delta_before = keyval_SEL-keyval_SLI;
        if (count~=1) || ~isempty(err)
            keytype = 'T';
            keyval = keyval_SLI;
        end
        [new_rl2scr,new_n0scr,new_thresh] = ...
                        key2info(lin_norm,lin_zero,keyval,keytype);
        if isequal(keytype,'T') && ~isequal(upd_orig,'meth')
        %g1254214
            min_sli = get(sli_sel,'Min');
            max_sli = get(sli_sel,'Max');
                if (new_thresh < min_sli || new_thresh > max_sli)
                    new_thresh = keyval_SLI;
                 end
        end
        
        set(sli_sel,'Value',new_thresh);
        set(edi_sel,'String',sprintf('%2.4g',new_thresh));
        set(edi_nor,'String',sprintf('%5.2f',new_rl2scr));
        set(edi_zer,'String',sprintf('%5.2f',new_n0scr));
        xold = get(lin_perf,'XData');
        xnew = [new_thresh new_thresh];
        if ~isequal(xold,xnew)
            set(lin_perf,'XData',xnew);
            feval(calledFUN,'clear_GRAPHICS',fig);
        end

    case 'residuals'
        [handleORI,handleTHR,handleRES] = ...
            utthrgbl('get',fig,'handleORI','handleTHR','handleRES');
        wmoreres('create',fig,tog_res,handleRES,handleORI,handleTHR,'blocPAR');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function varargout = wthrmeth(toolOPT,varargin)

switch toolOPT
  case {'dw1dcomp','wp1dcomp'}
    thrMethods = {...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm') , 'bal_sn',       1; ...
        getWavMSG('Wavelet:moreMSGRF:Remove_near_0')  , 'rem_n0',       2  ...
        };

  case {'dw2dcomp','wp2dcomp'}
    thrMethods = {...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm') , 'bal_sn',       1; ...
        getWavMSG('Wavelet:moreMSGRF:Remove_near_0')  , 'rem_n0',       2; ...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm_SQRT'),'sqrtbal_sn',3  ...
        };
end
nbin = length(varargin);
if nbin==0 , varargout{1} = thrMethods; return; end

option = varargin{1};
switch option
  case 'names'
     varargout{1} = char(thrMethods{:,1});
     if nbin==2
         num = varargin{2};
         varargout{1} = deblank(varargout{1}(num,:));
     end

  case 'shortnames'
     varargout{1} = char(thrMethods{:,2});
     if nbin==2
         num = varargin{2};
         varargout{1} = deblank(varargout{1}(num,:));
     end

  case 'nums'
     varargout{1} = cat(1,thrMethods{:,3});
end
%-----------------------------------------------------------------------------%
%=============================================================================%
