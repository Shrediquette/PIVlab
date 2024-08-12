function varargout = utnbcfs(option,fig,varargin)
%UTNBCFS Utilities for Coefficients Selection 1-D and 2-D tool.
%   VARARGOUT = UTNBCFS(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jun-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.10.4.20 $  $Date: 2013/07/05 04:30:29 $

% Default values.
%----------------
max_lev_anal = 9;
def_lev_anal = 5;

% Tag property of objects.
%-------------------------
tag_fra_tool = 'Fra_CFS_Tool';

switch option
  case {'create','apply','select','unselect'}

  otherwise
    % Memory Blocs of stored values.
    %===============================
    % MB0.
    %-----
    n_membloc0 = 'MB0';
    % ind_sig    = 1;
    ind_coefs  = 2;
    ind_longs  = 3;
    ind_first  = 4;
    ind_last   = 5;
    ind_sort   = 6;
    ind_By_Lev = 7;
    ind_sizes  = 8;   % 2D Only
    % nb0_stored = 8;

    if ~ishandle(fig) , varargout{1} = []; return; end
    uic = findobj(get(fig,'Children'),'flat','Type','uicontrol');
    fra = findobj(uic,'Style','frame','Tag',tag_fra_tool);
    if isempty(fra) , return; end
    ud  = get(fra,'UserData');
    toolOPT = ud.toolOPT;
    handlesUIC = ud.handlesUIC;
    h_CMD_SIG  = ud.h_CMD_SIG;
    h_CMD_APP  = ud.h_CMD_APP;
    h_CMD_LVL  = ud.h_CMD_LVL;
    if isequal(option,'handles')
        handles = [handlesUIC(:);h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:)];
        varargout{1} = handles(ishandle(handles));
        return;
    end
    Hdls_toolPos = utanapar('handles',fig,'all');
    ind          = 2;
    txt_top      = handlesUIC(ind); ind = ind+1;
    pop_met      = handlesUIC(ind); ind = ind+1;
    txt_app      = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    pop_app      = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    txt_cfs      = handlesUIC(ind); ind = ind+1;
    txt_tit(1:4) = handlesUIC(ind:ind+3); ind = ind+4;
    tog_res      = handlesUIC(ind); ind = ind+1;
    pus_act      = handlesUIC(ind);

    % Get stored structure.
    %----------------------
    Hdls_Sel = wfigmngr('getValue',fig,'Hdls_Sel');
    Hdls_Mov = wfigmngr('getValue',fig,'Hdls_Mov');
 
    % Get UIC Handles.
    %-----------------
    pus_sel = Hdls_Sel.pus_sel;
    pus_uns = Hdls_Sel.pus_uns;
    [fra_mov,~,txt_app,pop_app,~,edi_min_mov,~,edi_stp_mov, ...
     txt_max_mov,edi_max_mov,...
     chk_mov_aut,pus_mov_sta,pus_mov_sto,pus_mov_can] = deal(Hdls_Mov{:});

    switch option
      case {'clean','enable','Enable','Init_Movie','Mngr_Movie'}
        toolATTR = wfigmngr('getValue',fig,'ToolATTR');
        hdl_UIC  = toolATTR.hdl_UIC;
        pus_ana  = hdl_UIC.pus_ana;
        switch toolOPT
          case 'cf1d' , chk_sho = hdl_UIC.chk_sho;
          case 'cf2d' , chk_sho = [];
        end

      otherwise
    end
end

switch option
  case 'create'
    % Get Globals.
    %--------------
    [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width, ...
     X_Spacing,Y_Spacing,sliYProp,Def_ShadowColor,...
     Def_FraBkColor,ediActBkColor,ediInActBkColor] = ...
        mextglob('get',...
            'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
            'X_Spacing','Y_Spacing','Sli_YProp','Def_ShadowColor', ...
            'Def_FraBkColor','Def_EdiBkColor','Def_Edi_InActBkColor'   ...
            );

    % Defaults.
    %----------
    xleft = Inf; xright  = Inf; xloc = Inf;
    ytop  = Inf; ybottom = Inf; yloc = Inf;
    bkColor = Def_FraBkColor;
    ydir   = -1;
    levmin = 1;
    levmax = def_lev_anal;
    levmaxMAX = max_lev_anal;
    visVal  = 'On';
    enaVal  = 'Off';
    toolOPT = 'cf1d';

    % Inputs.
    %--------
    nbarg = length(varargin);
    for k=1:2:nbarg
        arg = lower(varargin{k});
        switch arg
          case 'left'     , xleft     = varargin{k+1};
          case 'right'    , xright    = varargin{k+1};
          case 'xloc'     , xloc      = varargin{k+1};
          case 'bottom'   , ybottom   = varargin{k+1};
          case 'top'      , ytop      = varargin{k+1};
          case 'yloc'     , yloc      = varargin{k+1};
          case 'bkcolor'  , bkColor   = varargin{k+1};
          case 'visible'  , visVal    = varargin{k+1};
          case 'enable'   , enaVal    = varargin{k+1};
          case 'ydir'     , ydir      = varargin{k+1};
          case 'levmin'   , levmin    = varargin{k+1};
          case 'levmax'   , levmax    = varargin{k+1};
          case 'levmaxMAX', levmaxMAX = varargin{k+1};
          case 'toolopt'  , toolOPT   = varargin{k+1};
        end
    end

    % Structure initialization.
    %--------------------------
    h_CMD_SIG = NaN*ones(4,1);
    h_CMD_APP = NaN*ones(4,1);
    h_CMD_LVL = NaN*ones(4,levmaxMAX);
    ud = struct(...
            'toolOPT',toolOPT, ...
            'levmin',levmin, ...
            'levmax',levmax, ...
            'levmaxMAX',levmaxMAX, ...
            'visible',lower(visVal),...
            'ydir', ydir,    ...
            'handlesUIC',[], ...
            'h_CMD_SIG',h_CMD_SIG, ...
            'h_CMD_APP',h_CMD_APP, ...
            'h_CMD_LVL',h_CMD_LVL, ...
            'handleORI' ,[], ...
            'handleTHR',[], ...
            'handleRES' ,[]  ...
            );

    % Figure units.
    %--------------
    old_units  = get(fig,'Units');
    fig_units  = 'pixels';
    if ~isequal(old_units,fig_units), set(fig,'Units',fig_units); end

    % Positions utilities.
    %---------------------
    dx = X_Spacing; dx2 = 2*dx; bdx = 3;
    dy = Y_Spacing; dy2 = 2*dy;
    d_txt  = (Def_Btn_Height-Def_Txt_Height);
    sli_hi = Def_Btn_Height*sliYProp;
    sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);

    % Setting frame position.
    %------------------------
    [bdy,d_lev,mulHeight] = wtbutils('utnbCFS_PREFS');
    btnHeight = Def_Btn_Height*mulHeight;
    NB_Height = 6;
    w_fra   = mextglob('get','Fra_Width');
    h_fra   = (levmaxMAX+NB_Height)*Def_Btn_Height+...
               levmaxMAX*d_lev+ btnHeight+(NB_Height-1)*bdy;
    x_fra   = utposfra(xleft,xright,xloc,w_fra);
    y_fra   = utposfra(ybottom,ytop,yloc,h_fra);
    pos_fra = [x_fra,y_fra,w_fra,h_fra];

    % String properties.
    %-------------------
    str_txt_top = getWavMSG('Wavelet:divGUIRF:Str_Txt_Top');
    str_txt_tit = {' ';getWavMSG('Wavelet:divGUIRF:Str_Initial'); ...
        ' '; getWavMSG('Wavelet:divGUIRF:Str_Kept')};
    str_tog_res = getWavMSG('Wavelet:commongui:Str_Residuals');
    if isequal(toolOPT,'cf2d') 
        str_pop_met = {...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_G'), ...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_B'), ...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_S') ...            
            };
    else
        str_pop_met = {...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_G'), ...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_B'), ...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_M'), ...
            getWavMSG('Wavelet:divGUIRF:Str_Pop_Met_S') ...            
            };
    end
    str_txt_app = getWavMSG('Wavelet:divGUIRF:Str_Txt_App');
    str_pop_app = getWavMSG('Wavelet:divGUIRF:Str_Pop_App');
    
    str_pus_sel = getWavMSG('Wavelet:divGUIRF:Str_Select');
    str_pus_uns = getWavMSG('Wavelet:divGUIRF:Str_UnSelect');
    str_txt_cfs = getWavMSG('Wavelet:divGUIRF:Str_SelBIG');
    str_pus_act = getWavMSG('Wavelet:commongui:Str_Apply');
 
    str_txt_mov     = getWavMSG('Wavelet:divGUIRF:SetStpMov');
    str_txt_min_mov = getWavMSG('Wavelet:divGUIRF:Txt_Min_Mov');
    str_edi_min_mov = '';
    str_txt_stp_mov = getWavMSG('Wavelet:divGUIRF:Txt_Stp_Mov');
    str_edi_stp_mov = '';
    str_txt_max_mov = getWavMSG('Wavelet:divGUIRF:Txt_Max_Mov');
    str_edi_max_mov = '';
    str_chk_mov_aut = getWavMSG('Wavelet:divGUIRF:Str_AutoPlay');
    str_pus_mov_sta = getWavMSG('Wavelet:divGUIRF:Str_Start');
    str_pus_mov_sto = getWavMSG('Wavelet:divGUIRF:Str_Stop');
    str_pus_mov_can = getWavMSG('Wavelet:divGUIRF:Str_Quit_Movie');

    % Position properties.
    %---------------------
    txt_width   = Def_Btn_Width;
    dy_lev      = Def_Btn_Height+d_lev;
    xleft       = x_fra+bdx;
    w_rem       = w_fra-2*bdx;
    ylow        = y_fra+h_fra-Def_Btn_Height-bdy;

    w_uic       = (5*txt_width)/2;
    x_uic       = xleft+(w_rem-w_uic)/2;
    y_uic       = ylow;
    pos_txt_top = [x_uic, y_uic-d_txt/1.5, w_uic, Def_Btn_Height];

    w_uic       = (7*w_fra)/12;
    x_uic       = x_fra+(w_fra-w_uic)/2;
    y_uic       = y_uic-Def_Btn_Height;
    pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];

    y_uic       = y_uic-Def_Btn_Height-bdy;
    w_txt       = w_fra/2.5;
    w_uic       = w_fra/2;
    x_uic       = x_fra+(w_fra-w_uic-w_txt)/2;
    pos_txt_app = [x_uic, y_uic-d_txt/1.5, w_txt, Def_Btn_Height];
    
    x_uic       = x_uic+w_txt;
    pos_pop_app = [x_uic, y_uic, w_uic, Def_Btn_Height];        

    w_uic       = ((2*w_fra)/3-2*bdx)/2;
    x_uic       = x_fra+(w_fra-(2*w_fra)/3)/2;    
    pos_pus_sel = [x_uic, y_uic, w_uic, Def_Btn_Height];
    x_uic       = x_uic+w_uic+2*bdx;
    pos_pus_uns = [x_uic, y_uic, w_uic, Def_Btn_Height];

    y_uic       = y_uic-Def_Btn_Height-bdy;
    w_uic       = w_fra/1.5;
    x_uic       = xleft+(w_rem-w_uic)/2;
    pos_txt_cfs = [x_uic, y_uic-Def_Btn_Height/3, w_uic, Def_Btn_Height];

    wx          = 2;
    wbase       = 2*(w_rem-5*wx)/5;
    w_lev       = [4*wbase ; 7*wbase ; 12*wbase ; 7*wbase]/12;
    x_uic       = xleft+wx;
    y_uic       = y_uic-Def_Btn_Height;
    pos_lev_tit = [x_uic, y_uic, w_lev(1), Def_Txt_Height+d_txt/2];
    pos_lev_tit = pos_lev_tit(ones(1,4),:);
    pos_lev_tit(:,3) = w_lev;
    for k=1:3 , pos_lev_tit(k+1,1) = pos_lev_tit(k,1)+pos_lev_tit(k,3); end

    w_uic       = w_fra/2-bdx;
    x_uic       = pos_fra(1);
    h_uic       = (3*Def_Btn_Height)/2;
    y_uic       = pos_fra(2)-h_uic-Def_Btn_Height/2;
    pos_pus_act = [x_uic, y_uic, w_uic, h_uic];
    x_uic       = x_uic+w_uic+2*bdx;
    pos_tog_res = [x_uic, y_uic, w_uic, h_uic];

    d_h_mov     = 3*Def_Btn_Height/4;
    h_txt       = Def_Txt_Height;
    h_uic       = Def_Btn_Height;
    y_fra_top   = pos_pop_app(2)+pos_pop_app(4)+h_txt+d_h_mov;
    dXPop       = 2;
    x_uic       = x_fra+dXPop;
    w_uic       = w_fra-2*dXPop;
    y_uic       = y_fra_top-h_txt-dy2;
    pos_txt_mov = [x_uic, y_uic+d_txt/2, w_uic, h_txt];

    y_uic       = pos_pop_app(2)-d_h_mov-h_uic;
    x_uic_1     = x_fra+dx2;
    x_uic_2     = x_fra+w_fra/2+dx;
    w_uic_1     = txt_width+dx2;
    w_uic_2     = w_fra/2-3*dx2/2;

    pos_txt_min_mov = [x_uic_1, y_uic+d_txt/2, w_uic_1, h_txt];
    pos_edi_min_mov = [x_uic_2, y_uic, w_uic_2, h_uic];
    y_uic           = y_uic-(h_uic+d_h_mov/2);
    pos_txt_stp_mov = [x_uic_1, y_uic+d_txt/2, w_uic_1, h_txt];
    pos_edi_stp_mov = [x_uic_2, y_uic, w_uic_2, h_uic];
    y_uic           = y_uic-(h_uic+d_h_mov/2);
    pos_txt_max_mov = [x_uic_1, y_uic+d_txt/2, w_uic_1, h_txt];
    pos_edi_max_mov = [x_uic_2, y_uic, w_uic_2, h_uic];

    w_bas           = (w_fra-6*bdx)/12;
    w_uic           = 5*w_bas;
    x_uic           = x_fra+2*bdx;    
    h_uic           = 1.5*Def_Btn_Height;
    y_uic           = y_uic-h_uic-d_h_mov;    
    pos_chk_mov_aut = [x_uic, y_uic, w_uic, h_uic];

    x_uic           = x_uic+w_uic+bdx;
    w_uic           = 3.5*w_bas;
    pos_pus_mov_sta = [x_uic, y_uic, w_uic, h_uic];

    x_uic           = x_uic+w_uic+bdx;
    pos_pus_mov_sto = [x_uic, y_uic, w_uic, h_uic];

    y_uic           = y_uic-h_uic-2*bdy;    
    w_uic           = w_fra/2;
    x_uic           = x_fra+(w_fra-w_fra/2)/2;    
    pos_pus_mov_can = [x_uic, y_uic, w_uic, h_uic];

    y_fra_mov       = y_uic-2*bdy;
    h_fra_mov       = y_fra_top-y_fra_mov;
    pos_fra_mov     = [x_fra,y_fra_mov,w_fra,h_fra_mov];

    % Create UIC.
    %------------
    commonProp = {...
        'Parent',fig,     ...
        'Units',fig_units  ...
        'Visible','Off'   ...
        };
    comTxtProp = [commonProp, ...
        'Style','Text',                 ...
        'HorizontalAlignment','center', ...
        'BackgroundColor',bkColor       ...
        ];
    comEdiProp = [commonProp, ...
        'ForegroundColor','k',            ...
        'HorizontalAlignment','center',   ...
        'Style','Edit'                    ...
        ];
    comFraProp = [commonProp, ...
        'BackgroundColor',Def_FraBkColor, ...
        'ForegroundColor',Def_ShadowColor,...
        'Style','frame'                   ...
        ];
    comPusProp = [commonProp,'Style','pushbutton'];
    comPopProp = [commonProp,'Style','Popupmenu'];
    comChkProp = [commonProp,'Style','CheckBox'];

    fra_utl = uicontrol(comFraProp{:}, ...
        'Style','frame',    ...
        'Position',pos_fra, ...
        'Tag',tag_fra_tool  ...
        );

    fra_mov = uicontrol(comFraProp{:},  ...
        'Style','frame',        ...
        'Position',pos_fra_mov  ...
        );

    txt_top = uicontrol(comTxtProp{:}, ...
        'Position',pos_txt_top, ...
        'String',str_txt_top    ...
        );
    cba     = @(~,~)utnbcfs('update_methode', fig);
    pop_met = uicontrol(comPopProp{:},                  ...
        'Position',pos_pop_met,         ...
        'String',str_pop_met,           ...
        'HorizontalAlignment','center', ...
        'Enable',enaVal,                ...
        'UserData',0,                   ...
        'Tag','Pop_Met',                ...
        'Callback',cba                  ...
        );

    txt_app = uicontrol(comTxtProp{:}, ...
        'Position',pos_txt_app, ...
        'HorizontalAlignment','center', ...
        'String',str_txt_app    ...
        );
    pop_app = uicontrol(comPopProp{:}, ...
        'Position',pos_pop_app,         ...
        'HorizontalAlignment','center', ...
        'String',str_pop_app,           ...
        'Enable',enaVal,                ...
        'Value',1,'UserData',0,         ...
        'Tag','Pop_APP_CFS'             ...
        );

    cba = @(~,~)utnbcfs('update_AppFlag', fig);
    set(pop_app,'Callback',cba);

    tip     = getWavMSG('Wavelet:divGUIRF:Str_TipSel');
    cba     = @(~,~)utnbcfs('select', fig);
    pus_sel = uicontrol(comPusProp{:},          ...
        'Position',pos_pus_sel, ...
        'String',str_pus_sel,   ...
        'Visible','Off',        ...
        'TooltipString',tip,    ...
        'Callback',cba          ...
        );

    tip     = getWavMSG('Wavelet:divGUIRF:Str_TipUnSel');
    cba     = @(~,~)utnbcfs('unselect', fig);
    pus_uns = uicontrol(comPusProp{:},          ...
        'Position',pos_pus_uns, ...
        'String',str_pus_uns,   ...
        'TooltipString',tip,    ...
        'Visible','Off',        ...
        'Callback',cba          ...
        );
    txt_cfs = uicontrol(comTxtProp{:},  ...
        'Position',pos_txt_cfs, ...
        'String',str_txt_cfs    ...
        );

    txt_tit = zeros(4,1);
    for k=1:4
        txt_tit(k) = uicontrol(...
            comTxtProp{:}, ...
            'Position',pos_lev_tit(k,:),  ...
            'String',str_txt_tit{k} ...
            );
    end

    xbtn0 = xleft;
    ybtn0 = pos_lev_tit(1,2)-Def_Btn_Height;
    xbtn  = xbtn0;
    ybtn  = ybtn0;
    if ud.ydir==1
        index = [1:levmaxMAX,-levmax,0];
    else
        index = [-levmax,levmaxMAX:-1:1,0];
        ybtn  = ybtn0+(levmaxMAX-levmax)*dy_lev;
    end
    for j=1:length(index)
        i = index(j);
        pos_lev = [xbtn ybtn+d_txt/2 w_lev(1) Def_Txt_Height];
        switch i
            case 0
                str_lev = sprintf('S');
                col = wtbutils('colors','sig');
            case -levmax
                str_lev = sprintf('A%.0f',-i);
                col = wtbutils('colors','app','text');
            otherwise
                str_lev = sprintf('D%.0f',i);
                col = wtbutils('colors','det','text');
        end
        uicProp = [commonProp,'Enable','inactive','UserData',i];
        ediIniProp = [uicProp,'BackgroundColor',ediInActBkColor];
        txt_lev = uicontrol(...
            comTxtProp{:},     ...
            'Position',pos_lev,...
            'String',str_lev,  ...
            'ForegroundColor',col, ...
            'Tag','Txt_Lev',   ...
            'UserData',i       ...
            );
        xbtn    = xbtn+w_lev(1)+wx;
        pos_lev = [xbtn ybtn w_lev(2) Def_Btn_Height];
        edi_ini = uicontrol(...
            ediIniProp{:}, ...
            'Style','Edit',...
            'Position',pos_lev,...
            'Tag','Edi_Ini',   ...            
            'String','' ...
            );

        xbtn    = xbtn+w_lev(2)+wx;
        pos_lev = [xbtn, ybtn+sli_dy, w_lev(3), sli_hi];
        sliProp = [uicProp,'BackgroundColor',bkColor];
        sli_lev = uicontrol(...
            sliProp{:},         ...
            'Style','Slider',   ...
            'Position',pos_lev, ...
            'Tag','Sli_Lev',    ...                        
            'Min',0,'Max',2,'Value',1 ...
            );

        xbtn    = xbtn+w_lev(3)+wx;
        pos_lev = [xbtn ybtn w_lev(4) Def_Btn_Height];
        ediLevProp = [uicProp,'BackgroundColor',ediInActBkColor];
        edi_lev = uicontrol(...
            ediLevProp{:},      ...
            'Style','Edit',     ...
            'Position',pos_lev, ...
            'String','',        ...
            'Tag','Edi_Lev',    ...                                    
            'HorizontalAlignment','center'...
            );
        set([edi_ini,sli_lev,edi_lev],'UserData',j);
        sHdl  = [edi_ini,sli_lev,edi_lev];

        cba_sli = @(~,~)utnbcfs('update_by_UIC', fig, sHdl ,'sli', i);
        cba_edi = @(~,~)utnbcfs('update_by_UIC', fig, sHdl ,'edi', i);
        set(sli_lev,'Callback',cba_sli);
        set(edi_lev,'Callback',cba_edi);
        switch i
            case 0
                h_CMD_SIG = [txt_lev;edi_ini;sli_lev;edi_lev];
                set(edi_lev,'BackgroundColor',ediActBkColor);
            case -levmax
                h_CMD_APP = [txt_lev;edi_ini;sli_lev;edi_lev];
            otherwise
                h_CMD_LVL(:,i) = [txt_lev;edi_ini;sli_lev;edi_lev];
        end
        xbtn = xbtn0;
        ybtn = ybtn-dy_lev;
    end

    cba     = @(~,~)utnbcfs('residuals', fig);
    tip     = getWavMSG('Wavelet:commongui:Tip_MoreOnRes');
    tog_res = uicontrol(...
        commonProp{:},          ...
        'Style','Togglebutton', ...
        'Position',pos_tog_res, ...
        'String',str_tog_res,   ...
        'Enable','off',         ...
        'Callback',cba,         ...
        'TooltipString',tip,    ...
        'Tag','Tog_Res',        ...                                
        'Interruptible','Off'   ...
        );

    cba     = @(~,~)utnbcfs('apply', fig);
    pus_act = uicontrol(comPusProp{:},          ...
        'Position',pos_pus_act, ...
        'String',str_pus_act,   ...
        'Enable',enaVal,        ...
        'Tag','Pus_Apply',      ...
        'Callback',cba          ...
        );

    txt_mov = uicontrol(comTxtProp{:},  ...
        'Position',pos_txt_mov, ...
        'String',str_txt_mov,   ...
        'Visible','Off'         ...
        );

    txt_min_mov = uicontrol(comTxtProp{:},  ...
        'Position',pos_txt_min_mov,  ...
        'HorizontalAlignment','left',...
        'String',str_txt_min_mov,    ...
        'Visible','Off'              ...
        );

    cba = @(~,~)utnbcfs('update_Edi_Movie', fig ,'Min');
    edi_min_mov = uicontrol(comEdiProp{:},                   ...
        'Position',pos_edi_min_mov,      ...
        'String',str_edi_min_mov,        ...
        'Callback',cba,                  ...
        'BackgroundColor',ediActBkColor,...
        'Visible','Off'                  ...
        );
    txt_stp_mov = uicontrol(comTxtProp{:},  ...
        'Position',pos_txt_stp_mov,      ...
        'HorizontalAlignment','left',    ...
        'String',str_txt_stp_mov,        ...
        'Visible','Off'                  ...
        );
    cba = @(~,~)utnbcfs('update_Edi_Movie', fig ,'Stp');
    edi_stp_mov = uicontrol(comEdiProp{:},                    ...
        'Position',pos_edi_stp_mov,       ...
        'String',str_edi_stp_mov,         ...
        'Callback',cba,                   ...
        'BackgroundColor',ediActBkColor, ...
        'Visible','Off'                   ...
        );
    txt_max_mov = uicontrol(comTxtProp{:},  ...
        'Position',pos_txt_max_mov,   ...
        'HorizontalAlignment','left', ... 
        'String',str_txt_max_mov,     ...
        'Visible','Off'               ...
        );

    cba = @(~,~)utnbcfs('update_Edi_Movie', fig ,'Max');
    edi_max_mov = uicontrol(comEdiProp{:},  ...
        'Position',pos_edi_max_mov,       ...
        'String',str_edi_max_mov,         ...
        'Callback',cba,                   ...
        'BackgroundColor',ediActBkColor, ...
        'Visible','Off'                   ...
        );

    cba = @(~,~)utnbcfs('Mngr_Movie', fig);
    chk_mov_aut = uicontrol(comChkProp{:},   ...
        'Position',pos_chk_mov_aut, ...
        'String',str_chk_mov_aut,   ...
        'Value',1,                  ...
        'Callback',cba,             ...
        'Visible','Off'             ...
        );

    cba = @(~,~)utnbcfs('Mngr_Movie', fig);
    pus_mov_sta = uicontrol(comPusProp{:}, ...
        'Position',pos_pus_mov_sta, ...
        'String',str_pus_mov_sta,   ...
        'Callback',cba,             ...
        'Visible','Off'             ...
        );

    cba = @(~,~)utnbcfs('Mngr_Movie', fig);
    pus_mov_sto = uicontrol(comPusProp{:},  ...
        'Position',pos_pus_mov_sto, ...
        'String',str_pus_mov_sto,   ...
        'Callback',cba,             ...
        'Enable','Off',             ...
        'Visible','Off'             ...
        );

    cba = @(~,~)utnbcfs('Mngr_Movie', fig);
    pus_mov_can = uicontrol(comPusProp{:},  ...
        'Position',pos_pus_mov_can, ...
        'String',str_pus_mov_can,   ...
        'Callback',cba,             ...
        'Tag','Pus_Mov_Can',        ...
        'Visible','Off'             ...
        );
    ud.handlesUIC = [...
        fra_utl;txt_top;pop_met;      ...
        txt_app;pop_app;txt_cfs;txt_tit(1:4); ...
        tog_res;pus_act;              ...
        ];

    ud.h_CMD_SIG = h_CMD_SIG;
    ud.h_CMD_APP = h_CMD_APP;
    ud.h_CMD_LVL = h_CMD_LVL;
    set(fra_utl,'UserData',ud);

    % Store values.
    %--------------
    Hdls_Sel = struct(...
        'pus_sel', pus_sel, ...
        'pus_uns', pus_uns, ...
        'pop_met', pop_met  ...
        );
    Hdls_Mov = {...
        fra_mov,txt_mov,txt_app,pop_app, ...
        txt_min_mov,edi_min_mov, ...
        txt_stp_mov,edi_stp_mov, ...
        txt_max_mov,edi_max_mov, ...
        chk_mov_aut,pus_mov_sta,pus_mov_sto,pus_mov_can ...
        };
    wfigmngr('storeValue',fig,'Hdls_Sel',Hdls_Sel);
    wfigmngr('storeValue',fig,'Hdls_Mov',Hdls_Mov);

    % Add Context Sensitive Help (CSHelp).
    %-------------------------------------
    hdl_CSHelp  = [...
        fra_utl,txt_top,pop_met,      				...
        txt_app,pop_app,txt_cfs,txt_tit(:)', 		...
        h_CMD_SIG(:)',h_CMD_APP(:)',h_CMD_LVL(:)', 	...
        pus_sel,pus_uns,							...
        cat(2,Hdls_Mov{:}) 							...
        ];
    switch toolOPT
        case 'cf1d' , helpName = 'CF1D_GUI';
        case 'cf2d' , helpName = 'CF2D_GUI';
    end
    wfighelp('add_ContextMenu',fig,hdl_CSHelp,helpName);
    %-------------------------------------

    varargout{1} = utnbcfs('set',fig,'position',{levmin,levmax});

  case 'visible'
    visVal     = lower(varargin{1});
    ud.visible = visVal;
    if isequal(visVal,'on')
        h_CMD_LVL = h_CMD_LVL(1:4,ud.levmin:ud.levmax);
    end
    handles = [h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:);handlesUIC(:)];
    set(handles(ishandle(handles)),'Visible',visVal);

  case 'clean'
    identMeth = utnbcfs('get',fig,'identMeth');
    switch identMeth
      case 'Stepwise' , utnbcfs('Mngr_Movie',fig,pus_mov_can);
      case {'ByLevel','Manual'}   , utnbcfs('update_methode',fig,'clean');
    end
    dum1 = h_CMD_SIG([2,4],:);
    dum2 = h_CMD_APP([2,4],:);
    dum3 = h_CMD_LVL([2,4],:);
    dummy = [dum1(:);dum2(:);dum3(:)];
    set(dummy,'String','');
    dummy = [h_CMD_SIG(3,:),h_CMD_APP(3,:),h_CMD_LVL(3,:)];
    set(dummy,'Min',0,'Value',1,'Max',2);
    h_CMD_SIG = h_CMD_SIG(3:4,:);
    h_CMD_APP = h_CMD_APP(3:4,:);
    h_CMD_LVL = h_CMD_LVL(3:4,:);
    uic = [pop_met;pop_app;pus_act;tog_res;chk_sho; ...
           h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:)];
    set(uic,'Enable','Off');
    vis_ON  = [txt_app,pop_app];
    vis_OFF = [pus_sel,pus_uns];
    set(vis_ON,'Visible','On')
    set(vis_OFF,'Visible','Off')

  case {'enable','Enable'}
    mode   = varargin{1};
    switch mode      
      case 'anal'
        uic = [pop_met;pop_app;pus_act;tog_res;chk_sho];
        set(uic','Enable','On');
    end

   case 'get'
    nbarg = length(varargin);
    if nbarg<1 , return; end
    for k = 1:nbarg
       outType = lower(varargin{k});
       switch outType
           case 'position'
             pos_fra = get(fra,'Position');
             pos_est = get(pus_act,'Position');
             varargout{k} = [pos_fra(1) , pos_est(2) , pos_fra([3 4])]; %#ok<*AGROW>

           case 'nbori'
             hdl = [h_CMD_APP(2),...
                    h_CMD_LVL(2,ud.levmax:-1:ud.levmin),h_CMD_SIG(2)];
             val = get(hdl,'Value');
             varargout{k} = cat(2,val{:});

           case 'nbkept'
             hdl = [h_CMD_APP(3),...
                    h_CMD_LVL(3,ud.levmax:-1:ud.levmin),h_CMD_SIG(3)];
             val = get(hdl,'Value');
             varargout{k} = round(cat(2,val{:}));

           case 'namemeth'
             tmp = get(pop_met,{'Value','String'});
             % ini = tmp{2}(tmp{1},:);
             ini = tmp{2}{tmp{1}};
             switch ini(1)
               case 'G' , varargout{k} = 'Global';
               case 'B' , varargout{k} = 'ByLevel';
               case 'M' , varargout{k} = 'Manual';
               case 'S' , varargout{k} = 'Stepwise';
             end

           case 'nummeth'   , varargout{k} = get(pop_met,'Value');
               
           case 'identmeth'
             num = get(pop_met,'Value');
             if isequal(length(get(pop_met,'String')),4)
                 tool = 'cf1dtool';
             else
                 tool = 'cf2dtool';
             end
             switch tool
                 case 'cf1dtool'
                     switch num
                         case 1 , varargout{k} = 'Global';
                         case 2 , varargout{k} = 'ByLevel';
                         case 3 , varargout{k} = 'Manual';
                         case 4 , varargout{k} = 'Stepwise';
                     end
                 case 'cf2dtool'
                     switch num                     
                         case 1 , varargout{k} = 'Global';
                         case 2 , varargout{k} = 'ByLevel';
                         case 3 , varargout{k} = 'Stepwise';
                     end
             end
               
           case 'appflag'   , varargout{k} = get(pop_app,'Value');
           case 'tog_res'   , varargout{k} = tog_res;
           case 'pus_act'   , varargout{k} = pus_act;
           case 'handleori' , varargout{k} = ud.handleORI;
           case 'handlethr' , varargout{k} = ud.handleTHR;
           case 'handleres' , varargout{k} = ud.handleRES;
       end
    end
 
  case 'set'
    nbarg = length(varargin);
    if nbarg<1 , return; end
    for k = 1:2:nbarg
       argType = lower(varargin{k});
       argVal  = varargin{k+1};
       switch argType
           case 'position'
             [levmin,levmax] = deal(argVal{:});
             nblevs = levmax-levmin+1;
             if ud.ydir==1
                 dnum_lev = (levmin-ud.levmin);
             else
                 dnum_lev = (ud.levmax-levmax);
             end
             ud.levmin = levmin;
             ud.levmax = levmax;
             set(fra,'UserData',ud);
             old_units = get(fig,'Units');
             tmpHandles = [h_CMD_SIG(:);h_CMD_APP(:);h_CMD_LVL(:); ...
                           handlesUIC(:)];
             tmpHandles = tmpHandles(ishandle(tmpHandles));
             set(tmpHandles,'Visible','off');
             set([fig;tmpHandles],'Units','pixels');
             
             % Check if figure has full screen size
             posFIG = get(fig,'Position');
             scrSIZ = getMonitorSize;
             fullSIZE = posFIG(3)==scrSIZ(3);
             [bdy,d_lev,mulHeight] = wtbutils('utnbCFS_PREFS');
             Def_Btn_Height = mextglob('get','Def_Btn_Height');
             if fullSIZE
                 pop = findobj(fig,'Tag','Pop_APP_CFS');
                 pos_pop = get(pop,'Position');
                 mulFULL = pos_pop(4)/Def_Btn_Height;
             else
                 mulFULL = 1;
             end
             Def_Btn_Height = Def_Btn_Height*mulFULL;
             bdy   = bdy*mulFULL;
             d_lev = d_lev*mulFULL;
             btnHeight = mulHeight*Def_Btn_Height;
             pos_fra = get(fra,'Position');
             top_fra = pos_fra(2)+pos_fra(4);
             NB_Height = 6;
             h_ini   = (NB_Height-1)*bdy+NB_Height*Def_Btn_Height;
             h_fra   = h_ini+ nblevs*(Def_Btn_Height+d_lev)+ btnHeight;
             pos_fra(2) = top_fra-h_fra;
             pos_fra(4) = h_fra;
             dy_lev = d_lev+Def_Btn_Height;
             y_est  = pos_fra(2)-2*Def_Btn_Height;
             y_res  = y_est;                          
             set(fra,'Position',pos_fra);
             ytrans = dnum_lev*dy_lev;
             for j=1:size(h_CMD_LVL,2)
                 for kk = 1:4
                     p = get(h_CMD_LVL(kk,j),'Position');
                     set(h_CMD_LVL(kk,j),'Position',[p(1),p(2)+ytrans, ...
                         p(3:4)]);
                 end
             end
             ydir = ud.ydir;
             pbase = get(h_CMD_LVL(1,levmax),'Position');
             y = pbase(2)-ydir*dy_lev;
             p = get(h_CMD_APP(1,1),'Position');
             ytrans = y-p(2);
             for kk = 1:4
                 p = get(h_CMD_APP(kk,1),'Position');
                 set(h_CMD_APP(kk,1),'Position',[p(1),p(2)+ytrans,p(3:4)]);
             end
             set(h_CMD_APP(1,1),'String',sprintf('A%.0f',levmax));

             if ydir==1
                pbase = get(h_CMD_APP(1,1),'Position');
             else
                pbase = get(h_CMD_LVL(1,1),'Position');
             end
             y = pbase(2)-dy_lev;
             p = get(h_CMD_SIG(1,1),'Position');
             ytrans = y-p(2)-(dy_lev-p(4));
             for kk = 1:4
                 p = get(h_CMD_SIG(kk,1),'Position');
                 set(h_CMD_SIG(kk,1),'Position',[p(1),p(2)+ytrans,p(3:4)]);
             end

             p = get(tog_res,'Position');
             set(tog_res,'Position',[p(1),y_res,p(3:4)]);
             p = get(pus_act,'Position');
             set(pus_act,'Position',[p(1),y_est,p(3:4)]);
             set([fig;tmpHandles],'Units',old_units);
             utnbcfs('visible',fig,ud.visible);
             if nargout>0
                 varargout{1} = [pos_fra(1) , y_est , pos_fra([3 4])];
             end

           case 'nbkept'
             hdl_sli = [h_CMD_APP(3),...
                        h_CMD_LVL(3,ud.levmax:-1:ud.levmin),h_CMD_SIG(3)];
             hdl_edi = [h_CMD_APP(4),...
                        h_CMD_LVL(4,ud.levmax:-1:ud.levmin),h_CMD_SIG(4)];
             for kk=1:length(hdl_sli)
                 nbk = argVal(kk);
                 set(hdl_sli(kk),'Value',nbk);
                 set(hdl_edi(kk),'Value',nbk,'String',sprintf('%.0f',nbk));
             end
 
           case 'handleori' , ud.handleORI = argVal; set(fra,'UserData',ud);
           case 'handlethr' , ud.handleTHR = argVal; set(fra,'UserData',ud);
           case 'handleres' , ud.handleRES = argVal; set(fra,'UserData',ud);
       end
    end

  case 'update_NbCfs'
    typeUpd = varargin{1};
    switch typeUpd
       case 'clean'
          len = size(h_CMD_LVL,2);
          HDL = zeros(3,len+2);
          for j = 2:4
              HDL(j-1,:) = [h_CMD_APP(j,1),h_CMD_LVL(j,:),h_CMD_SIG(j,1)];
          end
          set(HDL([1 3],:),'Value',0,'String','');
          set(HDL(2,:),'Min',0,'Value',0,'Max',2);

       case 'anal'
          levels = (ud.levmax:-1:ud.levmin);
          longs = wmemtool('rmb',fig,n_membloc0,ind_longs);
          longs(end) = sum(longs(1:end-1));
          len = length(longs);
          HDL = zeros(3,len);
          for j = 2:4
              HDL(j-1,:) = ...
                [h_CMD_APP(j,1),h_CMD_LVL(j,levels),h_CMD_SIG(j,1)];
          end
          for k = 1:len
              nbk = longs(k);
              txt = sprintf('%.0f',nbk);
              set(HDL([1 3],k),'Value',nbk,'String',txt);
              set(HDL(2,k),'Min',0,'Value',nbk,'Max',nbk);
          end
    end

  case 'update_methode'
    resetFLAG = 0;
    if ~isempty(varargin)
        numMeth = 1; identMeth = 'Global';
        set(pop_met,'Value',numMeth);
        resetMODE = varargin{1};
        if isequal(resetMODE,'reset') , resetFLAG = 1; end
    else
        [numMeth,identMeth] = utnbcfs('get',fig,'numMeth','identMeth');
        user = get(pop_met,'UserData');
        if isequal(user{1},numMeth) , return; end
        if isequal(user{2},'Manual') , resetFLAG = 1; end
    end    
    set(pop_met,'UserData',{numMeth,identMeth});
    set(txt_cfs,'String',getWavMSG('Wavelet:divGUIRF:Str_SelBIG'));

    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    if isequal(toolOPT,'cf1d')
        feval(calledFUN,'set_Stems_HDL',fig,'reset',identMeth);
    end
 
    [ediActBkColor,ediInActBkColor] = ...
        mextglob('get','Def_Edi_ActBkColor','Def_Edi_InActBkColor');
    switch identMeth
      case 'Global'
        if resetFLAG
            set(pop_app,'Value',1);
            nbKept = utnbcfs('get',fig,'nbOri');
        end
        ena_INA = [h_CMD_APP(3:4)',h_CMD_LVL(3,:),h_CMD_LVL(4,:)];
        ena_ON  = h_CMD_SIG(3:4)';
        vis_ON  = [txt_app,pop_app];
        vis_OFF = [pus_sel,pus_uns];
        bkc_FRA = [h_CMD_APP(4),h_CMD_LVL(4,:)];
        bkc_EDI = h_CMD_SIG(4);

      case 'ByLevel'
        if resetFLAG
            set(pop_app,'Value',1);
            nbKept = utnbcfs('get',fig,'nbOri');
        end
        app_Val = get(pop_app,'Value');
        ena_INA = h_CMD_SIG(3:4)';
        ena_ON  = [h_CMD_LVL(3,:),h_CMD_LVL(4,:)];
        vis_ON  = [txt_app,pop_app];
        vis_OFF = [pus_sel,pus_uns];
        bkc_FRA = h_CMD_SIG(4);
        bkc_EDI = h_CMD_LVL(4,:);
        switch app_Val
          case {1,3}
            ena_INA = [ena_INA , h_CMD_APP(3:4)'];
            bkc_FRA = [bkc_FRA , h_CMD_APP(4)];
          case 2
            ena_ON  = [ena_ON ,h_CMD_APP(3:4)'];
            bkc_EDI = [bkc_EDI , h_CMD_APP(4)];
        end

      case 'Manual'
        set(txt_cfs,'String',getWavMSG('Wavelet:commongui:SelCfs'));
        resetFLAG = 1;
        set(pop_app,'Value',2);
        nbKept = zeros(1,ud.levmax + 2);
        ena_INA = [h_CMD_APP(3:4)',h_CMD_LVL(3,:),h_CMD_LVL(4,:), ...
                   h_CMD_SIG(3:4)'];
        ena_ON  = [];
        vis_OFF = [txt_app,pop_app];
        vis_ON  = [pus_sel,pus_uns];
        bkc_FRA = [h_CMD_APP(4),h_CMD_LVL(4,:),h_CMD_SIG(4)];
        bkc_EDI = [];

      case {'Stepwise','StepWise'}
        utnbcfs('Init_Movie',fig);
    end

    switch identMeth
      case {'Global','Manual','ByLevel'}
        set(bkc_FRA,'BackgroundColor',ediInActBkColor);
        set(bkc_EDI,'BackgroundColor',ediActBkColor);
        set(ena_ON, 'Enable','On');
        set(ena_INA,'Enable','Inactive');
        set(vis_OFF,'Visible','Off');
        set(vis_ON, 'Visible','On');
        if resetFLAG
            utnbcfs('update_AppFlag',fig,pop_app);
            utnbcfs('set',fig,'nbKept',nbKept);
            feval(calledFUN,'apply',fig);
        end

      case {'Stepwise','StepWise'}
    end

  case 'update_AppFlag'
    if ~isempty(varargin)
        uic = varargin{1};
    else
        uic = gcbo;
    end
    appFlag = get(uic,'Value');
    [identMeth,nbOri] = utnbcfs('get',fig,'identMeth','nbOri');

    switch identMeth
      case {'Global','ByLevel','Manual'}
        if isequal(identMeth,'ByLevel') && (appFlag==2)
            BkColor = mextglob('get','Def_Edi_ActBkColor');
            ena_val = 'On';
        else
            BkColor = mextglob('get','Def_Edi_InActBkColor');
            ena_val = 'inactive';
        end
        set(h_CMD_APP(3:4),'Enable',ena_val);
        set(h_CMD_APP(4),'BackgroundColor',BkColor);
        switch appFlag
          case {1,3}
            switch appFlag
              case 1 , App_Len = nbOri(1); maxVal = nbOri(end);
              case 3 , App_Len = 0;        maxVal = nbOri(end)-nbOri(1);
            end  
            set(h_CMD_APP(3),'Value',App_Len);
            set(h_CMD_SIG(3),'Min',App_Len,'Value',maxVal,'Max',maxVal)
            hgfeval(h_CMD_APP(3).Callback);
            
          case 2
            maxVal = nbOri(end);
            set(h_CMD_SIG(3),'Min',0,'Max',maxVal)
        end

      case {'Stepwise'}
        %--------------------------%
        % Option: UPDATE_APP_MOVIE %
        %--------------------------%
        Nb_Coefs = nbOri(end);
        App_Len  = nbOri(1);
        Min_Val  = str2double(get(edi_min_mov,'String'));
        Max_Val  = str2double(get(edi_max_mov,'String'));
        switch appFlag
          case 1 , Min_Val = App_Len; Max_Val = Nb_Coefs;
          case 2 , Min_Val = 1;       Max_Val = Nb_Coefs;
          case 3 , Min_Val = 1;       Max_Val = Nb_Coefs-App_Len;
        end
        dif_Val = min([30,Max_Val-Min_Val,round(0.05*Nb_Coefs)]);
        def_Max_Val = Min_Val+dif_Val;
        set(edi_min_mov,'String',sprintf('%.0f',Min_Val));
        set(edi_max_mov,'String',sprintf('%.0f',def_Max_Val));
        set(txt_max_mov,'String', ...
            getWavMSG('Wavelet:divGUIRF:Txt_Max_Bound','<',Max_Val+1));
    end

  case 'update_by_UIC'
    obj = gcbo;
    usr = get(obj,'UserData');
    typHdl = get(obj,'Type');
    notOK = true;
    if isequal(typHdl,'uicontrol')
        StyleHdl = get(obj,'Style');  
        StyleHdl = StyleHdl(1:3);
        if isequal(StyleHdl,'edi') || isequal(StyleHdl,'sli')
            hdl_UTIL = findobj(fig,'UserData',usr);
            edi_0 = findobj(hdl_UTIL,'Tag','Edi_Ini');
            sli   = findobj(hdl_UTIL,'Tag','Sli_Lev');
            edi   = findobj(hdl_UTIL,'Tag','Edi_Lev');
            notOK = false;
        end
    elseif isequal(typHdl,'uimenu')
        notOK = true;
        StyleHdl = 'none';
    end
    if notOK
        edi_0 = findobj(gcbf,'Tag','Edi_Ini');
        num = get(edi_0,'UserData');
        [~,idx] = max(cat(num{:}));
        edi_0 = edi_0(idx);
        sli   = findobj(gcbf,'Tag','Sli_Lev');
        num   = get(sli,'UserData');
        [~,idx] = max(cat(num{:}));
        sli = sli(idx);
        edi = findobj(gcbf,'Tag','Edi_Lev');
        num = get(edi,'UserData');
        [~,idx] = max(cat(num{:}));
        edi = edi(idx);
    end
    idx   = get(edi_0,'UserData');
    [identMeth,nbOri] = utnbcfs('get',fig,'identMeth','nbOri');
    appFlag = get(pop_app,'Value');
    sliValues = get(sli,{'Min','Value','Max'});
    sliValues = round(cat(2,sliValues{:}));
    switch StyleHdl
      case 'sli' , nbcfs = sliValues(2);
      case 'edi'
        valstr = get(edi,'String');
        [nbcfs,count,err] = sscanf(valstr,'%f');
        if (count~=1) || ~isempty(err)
            nbcfs = sliValues(2);
            set(edi,'Value',nbcfs,'String',sprintf('%.0f',nbcfs));
            return;
        else
            if     nbcfs<sliValues(1) , nbcfs = sliValues(1);
            elseif nbcfs>sliValues(3) , nbcfs = sliValues(3);
            end
        end
        otherwise % Push Cancel Movie or Pop_Met
            nbcfs = sliValues(2);
    end 
    set(sli,'Value',nbcfs);
    set(edi,'Value',nbcfs,'String',sprintf('%.0f',nbcfs));

    switch identMeth
      case 'Global'
        if idx>=0
            [first,last,idxsort,idxByLev] = ...
                 wmemtool('rmb',fig,n_membloc0, ...
                        ind_first,ind_last,...
                        ind_sort,ind_By_Lev);
            len = length(idxByLev);
            switch toolOPT
              case 'cf1d'
                nbKept = zeros(1,len+1);
                switch appFlag
                  case {1,3}
                    if appFlag==1 , nbKept(1) = nbOri(1); end
                    idxsort(idxByLev{1}) = [];
                    nbcfs = nbcfs-nbKept(1);
                    kBeg = 2;

                  case 2 , kBeg = 1;

                end
                idxsort = idxsort(end-nbcfs+1:end);
                for k=kBeg:len
                    idxByLev{k} = find((first(k)<=idxsort) & ...
                                       (idxsort<=last(k)));
                    nbKept(k) = length(idxByLev{k});
                end

              case 'cf2d'
                nbLev  = (len-1)/3;
                nbKept = zeros(1,2+nbLev);
                switch appFlag
                  case {1,3}
                    if appFlag==1 , nbKept(1) = nbOri(1); end
                    idxsort(idxByLev{1}) = [];
                    nbcfs = nbcfs-nbKept(1);
                    kBeg = 2;

                  case 2 , kBeg = 1;

                end
                idxsort  = idxsort(end-nbcfs+1:end);
                for k=kBeg:len
                    idxByLev{k} = find((first(k)<=idxsort) & ...
                                       (idxsort<=last(k)));
                end
                if appFlag==2 , nbKept(1) = length(idxByLev{1}); end
                iBeg = 2;
                for jj = 1:nbLev
                    iEnd = iBeg+2;
                    nbKept(jj+1) = length(cat(2,idxByLev{iBeg:iEnd}));
                    iBeg = iEnd+1;
                end
            end
        else   % For approximation case.
            nbKept = utnbcfs('get',fig,'nbKept');
        end
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);

      case 'ByLevel'
        nbKept = utnbcfs('get',fig,'nbKept');
        nbKept(end) = sum(nbKept(1:end-1));
        utnbcfs('set',fig,'nbKept',nbKept);

      case 'Manual'

      case 'Stepwise'

    end

  case 'residuals'
    [handleORI,handleTHR,handleRES] = ...
        utnbcfs('get',fig,'handleORI','handleTHR','handleRES');
    wmoreres('create',fig,tog_res,handleRES,handleORI,handleTHR,'blocPAR');

  case {'apply','select','unselect'}
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    feval(calledFUN,option,fig);
    msgFLG = true;
    if msgFLG && isequal(option,'select')
        nbKept = utnbcfs('get',fig,'nbKept');
        if sum(nbKept)==0
            WarnString = getWavMSG('Wavelet:divGUIRF:MSG_Select_Cfs_0');
            wwarndlg(WarnString,getWavMSG('Wavelet:divGUIRF:WarnUTCFS'),'bloc')
        end
    end
 
  case 'Init_Movie'
    %--------------------%
    % Option: INIT_MOVIE %
    %--------------------%
    [Txt_Data_NS,Edi_Data_NS,Pop_Wav_Fam,Pop_Wav_Num,pop_lev] = ...
            utanapar('handles',fig); %#ok<ASGLU>
    level   = get(pop_lev,'Value');
    h_CMD_LVL = h_CMD_LVL(:,1:level);
    hdl_OFF = [...
              fra;txt_top;pop_met;txt_cfs;txt_tit(:); ...
              h_CMD_LVL(:);h_CMD_APP(:);h_CMD_SIG(:); ...
              pus_act;tog_res;pus_ana                 ...
              ];

    if ~isempty(chk_sho)
       pos_chk = get(chk_sho,'Position');
       pos_fra = get(fra_mov,'Position');
       pos_chk(2) = pos_fra(2)-1.5*pos_chk(4);
       set(chk_sho,'Position',pos_chk);
    end

    hdl_OFF = hdl_OFF(ishandle(hdl_OFF));
    set(pus_mov_can,'UserData',hdl_OFF);
    set([hdl_OFF;pus_sel;pus_uns],'Visible','Off');
    if iscell(Hdls_toolPos) , Hdls_toolPos = cat(1,Hdls_toolPos{:});end
    set(Hdls_toolPos,'Enable','Inactive');
    set([Pop_Wav_Fam,Pop_Wav_Num,pop_lev],'Enable','Off')
    set(cat(1,Hdls_Mov{:}),'Visible','On');
    drawnow
    app_val = get(pop_app,'Value');
    longs   = wmemtool('rmb',fig,n_membloc0,ind_longs);
    Stp_Val = 1;
    Nb_Coefs = sum(longs(1:end-1));
    App_Len  = longs(1);
    switch app_val
      case 1 , Min_Val = App_Len; Max_Val = Nb_Coefs;
      case 2 , Min_Val = 1;       Max_Val = Nb_Coefs;
      case 3 , Min_Val = 1;       Max_Val = Nb_Coefs-App_Len;
    end
    dif_Val = min([30,Max_Val-Min_Val,round(0.05*Nb_Coefs)]);
    def_Max_Val = Min_Val+dif_Val;
    set(edi_stp_mov,'String',sprintf('%.0f',Stp_Val),'UserData',Stp_Val);
    set(edi_min_mov,'String',sprintf('%.0f',Min_Val),'UserData',Min_Val);
    set(edi_max_mov,'String',sprintf('%.0f',def_Max_Val),'UserData',Max_Val);
    set(txt_max_mov,'String', ...
            getWavMSG('Wavelet:divGUIRF:Txt_Max_Bound','<',Max_Val+1));

    % Initialize plot.
    %-----------------
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    feval(calledFUN,'Apply_Movie',fig,[]);

  case 'Mngr_Movie'
    %--------------------%
    % Option: MNGR_MOVIE %
    %--------------------%
    if ~isempty(varargin)
        uic = varargin{1};
    else
        uic = gcbo;
    end
    hdl = [chk_mov_aut ; pus_mov_sta ; pus_mov_sto ; pus_mov_can];
    idx = find(uic==hdl);
    okAuto = get(chk_mov_aut,'Value');

    if (idx==2) || (idx==3 && ~okAuto)
        Min_Val = str2double(get(edi_min_mov,'String'));
        Stp_Val = str2double(get(edi_stp_mov,'String'));
        Max_Val = str2double(get(edi_max_mov,'String'));
        movieSET = (Min_Val:Stp_Val:Max_Val);
        nbInSet  = length(movieSET);
        App_Val = get(pop_app,'Value');
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        setIDX = get(chk_mov_aut,'UserData');
    end
   
    switch idx
      case 1    % Option: AUTOPLAY_MOVIE %
        if okAuto
           set(pus_mov_sta,'String', ...
               getWavMSG('Wavelet:divGUIRF:Str_Start'),'Enable','On')
           set(pus_mov_sto,'String', ...
              getWavMSG('Wavelet:divGUIRF:Str_Stop'),'Enable','Off','UserData',[])
        else
           set(chk_mov_aut,'UserData',0);
           set(pus_mov_sta,'String', ...
               ['<< ' getWavMSG('Wavelet:divGUIRF:Str_Prev')],'Enable','Off')
           set(pus_mov_sto,'String', ...
               getWavMSG('Wavelet:divGUIRF:Str_Next'),'Enable','On')
        end

      case 2    % Option: START_MOVIE or PREVIOUS %
        if okAuto
           set([chk_mov_aut,pus_mov_sta,pus_mov_can],'Enable','Off');
           set(pus_mov_sto,'Enable','On');
           feval(calledFUN,'Apply_Movie',fig,movieSET,App_Val,pus_mov_sto);
           set(pus_mov_sto,'Enable','Off');    
           set([chk_mov_aut,pus_mov_sta,pus_mov_can],'Enable','On');
        else
            setIDX = setIDX-1;
        end

      case 3    % Option: STOP_MOVIE or NEXT %
        if okAuto
           set(pus_mov_sto,'UserData',1);
        else
            setIDX = setIDX+1;          
        end

      case 4    % Option: CANCEL_MOVIE %
        set(cat(1,Hdls_Mov{:}),'Visible','Off');
        if ~okAuto
           set(chk_mov_aut,'Value',1,'UserData',[])
           set(pus_mov_sta,'String',getWavMSG('Wavelet:divGUIRF:Str_Start'), ...
               'Enable','On')
           set(pus_mov_sto,'String',getWavMSG('Wavelet:divGUIRF:Str_Stop'), ...
               'Enable','Off','UserData',[])
        end

        if ~isempty(chk_sho)
            pos_chk = get(chk_sho,'Position');
            pos_tog = get(tog_res,'Position');
            pos_chk(2) = pos_tog(2)-1.5*pos_chk(4);
            set(chk_sho,'Position',pos_chk);
        end

        hdl_ON = get(pus_mov_can,'UserData');
        set(hdl_ON,'Visible','On');
        if iscell(Hdls_toolPos) , Hdls_toolPos = cat(1,Hdls_toolPos{:});end
        set(Hdls_toolPos,'Enable','On');
        utnbcfs('update_methode',fig,'reset');       
    end

    if ~okAuto && (idx==2 || idx==3)
        if (0<=setIDX) && (setIDX<=nbInSet)
            if setIDX>0
                enaSTA = 'On';
            else
                enaSTA = 'Off';
            end
            if setIDX<nbInSet
                enaSTO = 'On';
            else
                enaSTO = 'Off';
            end
            set([chk_mov_aut,pus_mov_can,pus_mov_sta,pus_mov_sto],...
                'Enable','Inactive');
            set(chk_mov_aut,'UserData',setIDX)
            if setIDX==0
                CFS = [];
            else
                CFS = movieSET(setIDX);
            end
            feval(calledFUN,'Apply_Movie',fig,CFS ,App_Val,pus_mov_sto);
            set([chk_mov_aut,pus_mov_can],'Enable','On');
            set(pus_mov_sta,'Enable',enaSTA);
            set(pus_mov_sto,'Enable',enaSTO);                       
        end
    end

  case 'update_Edi_Movie'
  %--------------------------%
  % Option: UPDATE_EDI_MOVIE %
  %--------------------------%
    Edi_Val = varargin{1};
 
    % Get stored structure.
    %----------------------
    longs = wmemtool('rmb',fig,n_membloc0,ind_longs); 
    app_val  = get(pop_app,'Value');
    Nb_Coefs = sum(longs(1:end-1));
    App_Len  = longs(1);
    switch app_val
      case 1 , minPos = App_Len; maxPos = Nb_Coefs;
      case 2 , minPos = 1;       maxPos = Nb_Coefs;
      case 3 , minPos = 1;       maxPos = Nb_Coefs-App_Len;
    end
    Max_Val = str2double(get(edi_max_mov,'String'));
    Min_Val = str2double(get(edi_min_mov,'String'));
    Stp_Val = str2double(get(edi_stp_mov,'String'));
 
    switch Edi_Val
      case 'Min'
        if  isempty(Min_Val)
            Min_Val = get(edi_min_mov,'UserData');        
        else
            if     Min_Val > maxPos , Min_Val = maxPos;
            elseif Min_Val < minPos , Min_Val = minPos;
            end
            set(edi_min_mov,'UserData',Min_Val);
            if Min_Val > Max_Val
                set(edi_max_mov,...
                    'String',sprintf('%.0f',Min_Val),'UserData',Min_Val);
            end   
        end
        set(edi_min_mov,'String',sprintf('%.0f',Min_Val));
        if Min_Val > Max_Val
            set(edi_max_mov,...
                'String',sprintf('%.0f',Min_Val),'UserData',Min_Val);
        end

      case 'Stp'
        if  isempty(Stp_Val) || Stp_Val < 1 || ...
            Stp_Val > Nb_Coefs || Stp_Val > Max_Val
            Stp_Val = get(edi_stp_mov,'UserData');
        else
            set(edi_stp_mov,'UserData',Stp_Val);
        end
        set(edi_stp_mov,'String',sprintf('%.0f',Stp_Val));

      case 'Max'
        if  isempty(Max_Val)
            Max_Val = get(edi_max_mov,'UserData');
        else
            if     Max_Val > maxPos , Max_Val = maxPos;
            elseif Max_Val < minPos , Max_Val = minPos;
            end
            set(edi_max_mov,'UserData',Max_Val);            
        end
        set(edi_max_mov,'String',sprintf('%.0f',Max_Val));
        if Max_Val < Min_Val
            set(edi_min_mov,...
                'String',sprintf('%.0f',Max_Val),'UserData',Max_Val);
        end
    end 

  case 'demo'
  %--------------%
  % Option: DEMO %
  %--------------%
  parDemo  = varargin{1};
  identMeth = parDemo{1};
  if length(parDemo)==1
      parDemo = [];
  else
      parDemo = parDemo{2};
  end
  switch identMeth
    case 'Global' 
      switch toolOPT
        case 'cf1d'
          [coefs,longs] = wmemtool('rmb',fig,n_membloc0, ...
                                   ind_coefs,ind_longs);
          [~,nkeep] = wdcbm(coefs,longs,3);
          nkeep  = fliplr(nkeep);
          lkeep  = length(nkeep);
          nbKept = longs;
          nbKept(2:1+lkeep) = nkeep;
          nbKept(end) = sum(nbKept(1:end-1));
          utnbcfs('set',fig,'nbKept',nbKept);
          cf1dtool('apply',fig);
          cf1dtool('show_ori_sig',fig,'On');

        case 'cf2d'
          [coefs,sizes] = wmemtool('rmb',fig,n_membloc0, ...
                                   ind_coefs,ind_sizes);
          [~,nkeep] = wdcbm2(coefs,sizes,1.5);
          nkeep  = fliplr(nkeep);
          lkeep  = length(nkeep);
          nbKept = utnbcfs('get',fig,'nbKept');
          nbKept(2:1+lkeep) = nkeep;
          nbKept(end) = sum(nbKept(1:end-1));
          utnbcfs('set',fig,'nbKept',nbKept);
          cf2dtool('apply',fig);
      end
      
    case 'Stepwise' 
      switch toolOPT
        case 'cf1d'
          numMeth = 4;
          Stp_Val = 10;
          nb_Step = 15;
        case 'cf2d'
          numMeth = 3;
          Stp_Val = 20;
          nb_Step = 15;
      end
      nbOri = utnbcfs('get',fig,'nbOri');
      set(pop_met,'Value',numMeth);
      utnbcfs('update_methode',fig)
      if isempty(parDemo)
          set(edi_min_mov,'String',sprintf('%.0f',1));
          utnbcfs('update_Edi_Movie',fig,'Min');
          Min_Val = str2double(get(edi_min_mov,'String'));
          Max_Val = min(Min_Val+nb_Step*Stp_Val,nbOri(end));
      else
          Min_Val = parDemo(1);
          Stp_Val = parDemo(2);
          Max_Val = parDemo(3);
      end
      set(edi_min_mov,'String',sprintf('%.0f',Min_Val));
      set(edi_stp_mov,'String',sprintf('%.0f',Stp_Val));
      set(edi_max_mov,'String',sprintf('%.0f',Max_Val));
      utnbcfs('update_Edi_Movie',fig,'Max')
      utnbcfs('update_Edi_Movie',fig,'Stp')
      pause(1)
      utnbcfs('Mngr_Movie',fig,pus_mov_sta);
  end

end


