function varargout = utthrwpd(option,fig,varargin)
%UTTHRWPD Utilities for thresholding (Wavelet Packet De-noising).
%   VARARGOUT = UTTHRWPD(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Sep-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.8.4.16 $  $Date: 2013/07/05 04:30:35 $

% Tag property.
%--------------
tag_fra_tool = ['Fra_' mfilename];

switch option
  case {'move','up','create'}  
  otherwise
    wfigPROP = wtbxappdata('get',fig,'WfigPROP');
    if ~isempty(wfigPROP)
        calledFUN = wfigPROP.MakeFun;
    else
        calledFUN = wdumfun;    
    end
    if ~isequal(option,'down')
        % ud.handlesUIC = ...
        %    [fra_utl;txt_top;rad_sof;rad_har; ...
        %     sli_sel;edi_sel;txt_bin;edi_bin; ...
        %     tog_res;pus_est];
        %-----------------------------
        uic = findobj(get(fig,'Children'),'flat','Type','uicontrol');
        fra = findobj(uic,'Style','frame','Tag',tag_fra_tool);
        if isempty(fra) , return; end
        ud = get(fra,'UserData');
        toolOPT = ud.toolOPT;
        handlesUIC = ud.handlesUIC;
        handlesOBJ = ud.handlesOBJ;
        ind = 2;
        txt_top = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
        pop_met = handlesUIC(ind); ind = ind+1;
        rad_sof = handlesUIC(ind); ind = ind+1;
        rad_har = handlesUIC(ind); ind = ind+1;
        txt_sel = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
        sli_sel = handlesUIC(ind); ind = ind+1;
        edi_sel = handlesUIC(ind); ind = ind+1;
        txt_bin = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
        edi_bin = handlesUIC(ind); ind = ind+1;
        tog_res = handlesUIC(ind); ind = ind+1;
        pus_est = handlesUIC(ind); 
    end
end

switch option
    case 'down'
        % in2 = [axe_perfo ; axe_histo; ...
        %        lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        % in3 = 1  for lin_perfo and in3 = 2 for lin_perfh
        %--------------------------------------------------------------
        sel_type = get(fig,'SelectionType');
        if strcmp(sel_type,'open') , return; end
        opt = varargin{2};   
        if opt==1 , axe = varargin{1}(1); else axe = varargin{1}(2); end
        if (axe~=gca) , axes(axe); end 
    
        % Setting the thresholded coefs axes invisible.
        %----------------------------------------------
        feval(calledFUN,'clear_GRAPHICS',fig);
        lin_perfo = varargin{1}(3);
        lin_perfh = varargin{1}(4);
        set([lin_perfo lin_perfh],'Color','g');
        drawnow
        argCbstr = {fig , varargin{1} ...
                     , varargin{2}};
        cba_move = @(~,~)utthrwpd('move', argCbstr{:} );
        cba_up   = @(~,~)utthrwpd('up',  argCbstr{:} );
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);

    case 'move'
        % in2 = [axe_perfo ; axe_histo; ...
        %        lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        % in3 = 1  for lin_perfo and in3 = 2 for lin_perfh
        %--------------------------------------------------------------
        opt = varargin{2};   
        if opt==1 , axe = varargin{1}(1); else axe = varargin{1}(2); end
        p = get(axe,'CurrentPoint');
        new_thresh = p(1,1);
        sli_sel = varargin{1}(5);
        min_sli = get(sli_sel,'Min');
        max_sli = get(sli_sel,'Max');
        new_thresh = max(min_sli,min(new_thresh,max_sli));
        xnew = [new_thresh new_thresh];
        xold = get(varargin{1}(3),'XData');
        if isequal(xold,xnew) , return; end
        set(varargin{1}(3:4),'XData',xnew);
        set(sli_sel,'Value',new_thresh);
        set(varargin{1}(6),'String',sprintf('%1.4g',new_thresh));

    case 'up'
        % in2 = [axe_perfo ; axe_histo; ...
        %        lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        %--------------------------------------------------------------
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        ax = wfindobj(fig,'Type','axes');
        set(fig,'WindowButtonMotionFcn',wtmotion(ax),...
			'WindowButtonUpFcn',save_WindowButtonUpFcn);
        set(varargin{1}(3:4),'Color',wtbutils('colors','linTHR'));
        drawnow;

    case 'create'
        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         sliYProp,Def_FraBkColor,Def_EdiBkColor] = mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
                'Pop_Min_Width','Sli_YProp', ...
                'Def_FraBkColor','Def_EdiBkColor');

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor;

        visVal = 'on';
        toolOPT = 'wpdeno1';

        % Inputs.
        %--------        
        nbarg = length(varargin);
        for k=1:2:nbarg
            arg = lower(varargin{k});
            switch arg
              case 'left'     , xleft   = varargin{k+1};
              case 'right'    , xright  = varargin{k+1};
              case 'xloc'     , xloc    = varargin{k+1};
              case 'bottom'   , ybottom = varargin{k+1};
              case 'top'      , ytop    = varargin{k+1};
              case 'yloc'     , yloc    = varargin{k+1};
              case 'bkcolor'  , bkColor = varargin{k+1};
              case 'visible'  , visVal  = varargin{k+1};
              case 'toolopt'  , toolOPT = varargin{k+1};
            end 
        end

        % Structure initialization.
        %--------------------------
        colHIST = wtbutils('colors','wp1d','hist');
        ud = struct(...
                'toolOPT',toolOPT, ...
                'visible',lower(visVal),...
                'handlesUIC',[], ...
                'handlesOBJ',[], ...
                'handleORI',     ...
                'handleTHR',     ...                 
                'histColor',colHIST ...
                );

        % Figure units.
        %--------------
        old_units  = get(fig,'Units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'Units',fig_units); end       

        % String property.
        %-----------------
        default_bins = 50;
        str_txt_top = getWavMSG('Wavelet:commongui:Str_SelThr');
        str_txt_sel = getWavMSG('Wavelet:commongui:Str_SelGlbThr');
        str_pop_met = wthrmeth(toolOPT,'names');
        str_rad_sof = getWavMSG('Wavelet:commongui:Str_Soft');
        str_rad_har = getWavMSG('Wavelet:commongui:Str_Hard');
        str_txt_bin = getWavMSG('Wavelet:commongui:Str_NbBins');
        str_edi_bin = sprintf('%.0f',default_bins);
        str_tog_res = getWavMSG('Wavelet:commongui:Str_Residuals');
        str_pus_est = getWavMSG('Wavelet:commongui:Str_DENO');

        % Positions utilities.
        %---------------------
        bdx = 3;
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);

        % Setting frame position.
        %------------------------
        bdy = wtbutils('utthrwpd_PREFS','params');        
        w_fra   = mextglob('get','Fra_Width');
        h_fra   = 6*Def_Btn_Height+6*bdy;              
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % Position property.
        %-------------------
        txt_width = Def_Btn_Width;

        xleft = xleft+bdx;
        w_rem = w_fra-2*bdx;
        ylow  = ybottom+h_fra-Def_Btn_Height-bdy;

        w_uic       = 3*txt_width;
        while w_uic>w_rem , w_uic = w_uic-1; end
        x_uic       = xleft+(w_rem-w_uic)/2;
        y_uic       = ylow;
        pos_txt_top = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;
        w_rad       = 1.5*Pop_Min_Width;
        w_sep       = (w_uic-2*w_rad)/6;
        x_rad       = x_uic+w_sep;
        pos_rad_sof = [x_rad, y_uic, w_rad, Def_Btn_Height];
        x_rad       = x_rad+w_rad+2*w_sep;
        pos_rad_har = [x_rad, y_uic, w_rad, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;
        pos_txt_sel = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        wid1        = (15*w_rem)/26;
        wid2        = (8*w_rem)/26;
        wx          = (w_rem-wid1-wid2)/4;
        
        pos_sli_sel = [xleft+wx, y_uic+sli_dy, wid1-wx, sli_hi];
        x_uic       = pos_sli_sel(1)+pos_sli_sel(3)+wx;
        pos_edi_sel = [x_uic, y_uic, wid2, Def_Btn_Height];

        y_uic       = y_uic-Def_Btn_Height-bdy;        
        pos_txt_bin = [xleft+wx, y_uic+d_txt/2, wid1-wx, Def_Txt_Height];
        x_uic       = pos_txt_bin(1)+pos_txt_bin(3)+wx;
        pos_edi_bin = [x_uic, y_uic, wid2, Def_Btn_Height];

        w_uic = w_fra/2-bdx;
        x_uic = pos_fra(1);
        h_uic = (3*Def_Btn_Height)/2;
        y_uic = pos_fra(2)-h_uic-Def_Btn_Height;     
        pos_pus_est = [x_uic, y_uic, w_uic, h_uic];
        x_uic = x_uic+w_uic+2*bdx;
        pos_tog_res = [x_uic, y_uic, w_uic, h_uic];

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
            'Tag',tag_fra_tool ...
            );

        txt_top = uicontrol(commonTxtProp{:},      ...
            'Position',pos_txt_top,...
            'HorizontalAlignment','center',...
            'String',str_txt_top   ...
            );

        cba = @(~,~)utthrwpd('update_methName', fig );
        pop_met = uicontrol(comProp{:}, ...
            'Style','Popup',...
            'Position',pos_pop_met,...
            'String',str_pop_met,...
            'HorizontalAlignment','center',...
            'UserData',1,...
            'Callback',cba ...
            );

        rad_sof = uicontrol(comProp{:}, ...
            'Style','RadioButton',...
            'Position',pos_rad_sof,...
            'HorizontalAlignment','center',...
            'String',str_rad_sof,...
            'Value',1,'UserData',1 ...
            );

        rad_har = uicontrol(comProp{:}, ...
            'Style','RadioButton',...
            'Position',pos_rad_har,...
            'HorizontalAlignment','center',...
            'String',str_rad_har,...
            'Value',0,'UserData',0 ...
            );
        cba = @(~,~)utthrwpd('update_thrType', fig );
        set(rad_sof,'Callback',cba);
        set(rad_har,'Callback',cba);

        txt_sel = uicontrol(commonTxtProp{:},      ...
            'Position',pos_txt_sel,...
            'HorizontalAlignment','center',...
            'String',str_txt_sel   ...
            );

        cba_sli = @(~,~)utthrwpd('updateTHR', fig ,'sli');
        sli_sel = uicontrol(comProp{:}, ...
            'Style','Slider',...
            'Position',pos_sli_sel,...
            'Min',0,...
            'Max',1,...
            'Value',0.5, ...
            'Callback',cba_sli ...
            );

        cba_edi = @(~,~)utthrwpd('updateTHR', fig ,'edi');
        edi_sel = uicontrol(commonEdiProp{:}, ...
            'Position',pos_edi_sel,...
            'Callback',cba_edi ...
            );

        txt_bin = uicontrol(commonTxtProp{:}, ...
            'Position',pos_txt_bin,...
            'HorizontalAlignment','left',...
            'String',str_txt_bin...
            );

        cba_bin = @(~,~)utthrwpd('updateBIN', fig ,'bin');
        edi_bin = uicontrol(commonEdiProp{:}, ...
            'Position',pos_edi_bin,...
            'String',str_edi_bin,   ...
            'Callback',cba_bin ...
            );

        cba = @(~,~)utthrwpd('residuals', fig );
        tip = 'More on Residuals';
        tog_res = uicontrol(comProp{:},   ...
            'Style','Togglebutton', ...
            'Position',pos_tog_res, ...
            'String',str_tog_res,   ...
            'Enable','off',         ...
            'Callback',cba,         ...
            'TooltipString',tip,          ...
            'Interruptible','On'    ...
            );

        cba_pus_est = @(~,~)utthrwpd('denoise', fig );
        pus_est = uicontrol(comProp{:}, ...
            'Style','pushbutton',   ...
            'Position',pos_pus_est, ...
            'String',str_pus_est,   ...
            'Callback',cba_pus_est  ...
            );

        % Add Context Sensitive Help (CSHelp).
        %-------------------------------------
        hdl_COMP_DENO_STRA = [...
            fra_utl,txt_top,pop_met, ...
            txt_sel,sli_sel,edi_sel];
        hdl_DENO_SOFTHARD = [rad_sof,rad_har];
        wfighelp('add_ContextMenu',fig,hdl_COMP_DENO_STRA,'COMP_DENO_STRA');
        wfighelp('add_ContextMenu',fig,hdl_DENO_SOFTHARD,'DENO_SOFTHARD');
        %-------------------------------------

        % Store handles.
        %--------------
        ud.handlesUIC = ...
            [fra_utl;txt_top;pop_met;...
            rad_sof;rad_har;txt_sel;sli_sel;edi_sel;...
            txt_bin;edi_bin;tog_res;pus_est];
        set(fra_utl,'UserData',ud);
        if nargout>0
            varargout{1} = [pos_fra(1) , pos_pus_est(2) , pos_fra([3 4])];
        end

    case 'displayPerf'
        % Displaying perfos.
        %-------------------
        [pos_axe_perfo,pos_axe_histo,cfs] = deal(varargin{:});
        cfs = sort(abs(cfs));
        fig_units = get(fig,'Units');
        suggthr = get(sli_sel,'Value');
        nb_cfs  = length(cfs);
        if nb_cfs==0
            xlim = [0 1];
            ylim = [0 1];
        else
            sigmax = cfs(end);
            if abs(sigmax)<eps , sigmax = 0.01; end
            xlim = [0 sigmax];
            ylim = [0 nb_cfs];
        end
        comAxeProp = {...
          'Parent',fig, ...
          'Units',fig_units, ...
          'Box','On'};
        colTHR = wtbutils('colors','linTHR');
        axe_perfo = axes(comAxeProp{:},...
                         'Position',pos_axe_perfo,...
                         'XLim',xlim,'YLim',ylim);

        % Set a text as a super title.
        %-----------------------------
        wtitle(getWavMSG('Wavelet:commongui:SortedAbsCfs'),'Parent',axe_perfo)
        lin_thres = line('XData',cfs,...
            'YData',1:nb_cfs,...
            'Color',ud.histColor,...
            'LineWidth',1.5,...
            'Parent',axe_perfo);
        lin_perfo = line(...
            'XData',[suggthr suggthr],...
            'YData',[0       nb_cfs],...
            'Color',colTHR,...
            'LineWidth',1.5,...
            'LineStyle',':', ...
            'Parent',axe_perfo);
        setappdata(lin_perfo,'selectPointer','V')
        set(axe_perfo,'UserData',lin_perfo);

        % Displaying histogram.
        %----------------------
        default_bins = 50;
        nb_bins = str2num(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2) , nb_bins = default_bins; end
        set(edi_bin,'String',sprintf('%.0f',nb_bins));
        
        axe_histo = axes(comAxeProp{:},...
                         'Position',pos_axe_histo,...
                         'NextPlot','Replace');
        his       = wgethist(cfs,nb_bins,'left');
        % [xx,imod] = max(his(2,:)); %#ok<ASGLU>
        % mode_val  = (his(1,imod)+his(1,imod+1))/2;
        his(2,:)  = his(2,:)/nb_cfs;
        his       = AdjustHist(his,axe_perfo);

        % axes(axe_histo);
        wplothis(axe_histo,his,ud.histColor);
        ylim      = get(axe_histo,'YLim');
        lin_perfh = line(...
                         'XData',[suggthr suggthr],...
                         'YData',[ylim(1)+eps ylim(2)-eps],...
                         'Color',colTHR,...
                         'LineStyle',':', ...
                         'LineWidth',1.5,...
                         'Parent',axe_histo);
        setappdata(lin_perfh,'selectPointer','V')
        wtitle(getWavMSG('Wavelet:commongui:HistAbsCfs'),'Parent',axe_histo);

        handles = [axe_perfo ; axe_histo; ...
                   lin_perfo ; lin_perfh ; sli_sel ; edi_sel; edi_bin];
        argCbstr = {fig , handles};
        cba_lin_perfo = @(~,~)utthrwpd('down', argCbstr{:} ,1);
        set(lin_perfo,'ButtonDownFcn',cba_lin_perfo);
        cba_lin_perfh = @(~,~)utthrwpd('down', argCbstr{:} ,2);
        set(lin_perfh,'ButtonDownFcn',cba_lin_perfh);
        ud.handlesOBJ.axes  = [axe_perfo ; axe_histo]; 
        ud.handlesOBJ.lines = [lin_perfo ; lin_perfh; lin_thres];
        set(fra,'UserData',ud);

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = lower(varargin{k});
           argVal  = varargin{k+1};
           switch argType
               case 'handleori' , ud.handleORI = argVal;
               case 'handlethr' , ud.handleTHR = argVal;
           end
        end
        set(fra,'UserData',ud);

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

    case 'enable_tog_res'
        enaVal = varargin{1};        
        try 
            Pus_SigDorC = wfindobj(fig,'Tag','Pus_SigDorC');
        catch %#ok<CTCH>
            Pus_SigDorC = [];
        end
        set([tog_res,Pus_SigDorC],'Enable',enaVal);                

    case 'denoise'
        feval(calledFUN,'denoise',fig);

    case 'setThresh'
        sliVal = varargin{1};
        set(sli_sel,'Min',sliVal(1),'Value',sliVal(2),'Max',sliVal(3));
        set(edi_sel,'String',sprintf('%1.4g',sliVal(2)));

    case 'get_GBL_par'
        numMeth = get(pop_met,'Value');
        meth    = wthrmeth(toolOPT,'shortnames',numMeth);
        valType = get(rad_sof,'Value');
        if valType==1 , sorh = 's'; else sorh = 'h'; end
        valSli  = get(sli_sel,'Value');
        varargout = {numMeth,meth,valSli,sorh};

    case 'update_GBL_meth'
        % called by : calledFUN('update_GBL_meth', ...)
        %------------------------------------------------
        suggthr = varargin{1};
        utthrwpd('updateTHR',fig,'meth',suggthr);

    case 'update_methName'
        feval(calledFUN,'update_GBL_meth',fig);

    case 'updateBIN'
        % Check the bins number.
        %-----------------------
        default_bins = 50; max_bins = 500;
        nb_bins = str2num(get(edi_bin,'String'));
        if isempty(nb_bins) || (nb_bins<2)
            nb_bins = default_bins;
            set(edi_bin,'String',sprintf('%.0f',nb_bins));
            return
        elseif (nb_bins>max_bins)
            nb_bins = max_bins;
            set(edi_bin,'String',sprintf('%.0f',nb_bins));
        end
        axe_perfo = handlesOBJ.axes(1);
        axe_histo = handlesOBJ.axes(2);
        lin_perfh = handlesOBJ.lines(2);
        lin_thres = handlesOBJ.lines(3);
        thresVal  = get(lin_thres,'XData');
        his       = wgethist(thresVal,nb_bins,'left');
        his(2,:)  = his(2,:)/length(thresVal);
        his       = AdjustHist(his,axe_perfo);
        child = findobj(axe_histo,'Parent',axe_histo);
        child(child==lin_perfh) = [];
        delete(child)
        set(axe_histo,'nextplot','add');
        wplothis(axe_histo,his,ud.histColor);
        ylim = get(axe_histo,'YLim');
        set(lin_perfh,'YData',[ylim(1)+eps ylim(2)-eps]);
        wtitle(getWavMSG('Wavelet:commongui:HistAbsCfs'),'Parent',axe_histo);

    case 'updateTHR'
        upd_orig = varargin{1};
        switch upd_orig
          case 'sli'
            new_thresh = get(sli_sel,'Value');

          case 'edi'
            new_thresh = str2num(get(edi_sel,'String'));
            if isempty(new_thresh)
                new_thresh = get(sli_sel,'Value');
            else
                ma = get(sli_sel,'Max');
                if new_thresh>ma
                    new_thresh = ma;
                else
                    mi = get(sli_sel,'Min');
                    if new_thresh<mi , new_thresh = mi; end
                end
            end

          case 'meth'
            new_thresh = varargin{2};

        end
        set(sli_sel,'Value',new_thresh);
        set(edi_sel,'String',sprintf('%1.4g',new_thresh));
        lin_perfo = handlesOBJ.lines(1);
        lin_perfh = handlesOBJ.lines(2);
        xold = get(lin_perfo,'XData');
        xnew = [new_thresh new_thresh];
        if ~isequal(xold,xnew)
            set([lin_perfo lin_perfh],'XData',xnew);
            feval(calledFUN,'clear_GRAPHICS',fig);
        end

    case 'update_thrType'
        rad = gcbo;
        old = get(rad,'UserData');
        if old==1 , set(rad,'Value',1); return; end
        if isequal(rad,rad_sof)
           other = rad_har;
        else
           other = rad_sof;           
        end
        set(other,'Value',0,'UserData',0);
        set(rad,'Value',1,'UserData',1);
        feval(calledFUN,'clear_GRAPHICS',fig);

    case 'residuals'
        wmoreres('create',fig,tog_res,[],ud.handleORI,ud.handleTHR,'blocPAR');

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
  case {'wpdeno1'}
    thrMethods = {...
        getWavMSG('Wavelet:moreMSGRF:Fix_form_UnScWn'),'sqtwologuwn', 1; ...
        getWavMSG('Wavelet:moreMSGRF:Fix_form_ScWn'),  'sqtwologswn', 2; ...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm'), 'bal_sn', 3; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_high'),   'penalhi',  4; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_medium'), 'penalme',  5; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_low'),    'penallo',  6  ...

        };

  case {'wpdeno2'}
    thrMethods = {...
        getWavMSG('Wavelet:moreMSGRF:Fix_form_UnScWn'), 'sqtwologuwn',   1; ...
        getWavMSG('Wavelet:moreMSGRF:Fix_form_ScWn'),   'sqtwologswn',   2; ...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm_SQRT'), 'sqrtbal_sn',3; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_high'),   'penalhi',  4; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_medium'), 'penalme',  5; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_low'),    'penallo',  6  ...
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
function his = AdjustHist(his,axe)

xlim = get(axe,'XLim');
d    = his(1,:)-his(1,1);
his(1,:) = xlim(2)*(d/max(d));
%-----------------------------------------------------------------------------%
%=============================================================================%
