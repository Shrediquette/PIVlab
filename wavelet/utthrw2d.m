function varargout = utthrw2d(option,fig,varargin)
%UTTHRW2D Utilities for wavelet thresholding 2-D.F
%   VARARGOUT = UTTHRW2D(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.8.4.19 $  $Date: 2013/07/05 04:30:34 $ 

% Default values.
%----------------
max_lev_anal = 5;
def_lev_anal = 2;

% Tag property.
%--------------
tag_fra_tool = ['Fra_' mfilename];

switch option
  case {'create'}

  otherwise
    uic = findobj(get(fig,'Children'),'flat','Type','uicontrol');
    fra = findobj(uic,'Style','frame','Tag',tag_fra_tool);
    if isempty(fra) , return; end
    calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
    ud = get(fra,'UserData');
    toolOPT = ud.toolOPT;
    toolStatus = ud.status;
    handlesUIC = ud.handlesUIC;
    h_CMD_LVL  = ud.h_CMD_LVL;
    h_GRA_LVL  = ud.h_GRA_LVL;
    if isequal(option,'handles')
        handles = [handlesUIC(:);h_CMD_LVL(:)];
        varargout{1} = handles(ishandle(handles));
        return;
    end
    ind = 2;
    txt_top = handlesUIC(ind); ind = ind+1; %#ok<NASGU>
    pop_met = handlesUIC(ind); ind = ind+1;
    rad_sof = handlesUIC(ind); ind = ind+1;
    rad_har = handlesUIC(ind); ind = ind+1;
    txt_noi = handlesUIC(ind); ind = ind+1;
    pop_noi = handlesUIC(ind); ind = ind+1;
    txt_BMS = handlesUIC(ind); ind = ind+1;  
    sli_BMS = handlesUIC(ind); ind = ind+1;
    pop_dir = handlesUIC(ind); ind = ind+1;
    txt_tit(1:3) = handlesUIC(ind:ind+2); ind = ind+3; %#ok<NASGU>
    txt_nor = handlesUIC(ind); ind = ind+1;
    edi_nor = handlesUIC(ind); ind = ind+1;
    txt_npc = handlesUIC(ind); ind = ind+1;
    txt_zer = handlesUIC(ind); ind = ind+1;
    edi_zer = handlesUIC(ind); ind = ind+1;
    txt_zpc = handlesUIC(ind); ind = ind+1;
    tog_res = handlesUIC(ind); ind = ind+1;
    pus_est = handlesUIC(ind);
end

switch option
    case 'create'
        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         sliYProp,Def_FraBkColor,Def_EdiBkColor,Def_ShadowColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width',   ...
                'Pop_Min_Width','Sli_YProp','Def_FraBkColor',...
                'Def_EdiBkColor','Def_ShadowColor');

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor;
        enaVal  = 'Off';
        %------------------------
        ydir   = -1;
        levmin = 1;
        levmax = def_lev_anal;
        levmaxMAX = max_lev_anal;
        levANAL = def_lev_anal;
        visVal = 'On';        
        isbior = 0;
        statusINI = 'On';
        toolOPT   = 'deno';
        %------------------------

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
              case 'isbior'   , isbior    = varargin{k+1};
              case 'ydir'     , ydir      = varargin{k+1};
              case 'levmin'   , levmin    = varargin{k+1};
              case 'levmax'   , levmax    = varargin{k+1};
              case 'levmaxmax', levmaxMAX = varargin{k+1};
              case 'levanal'  , levANAL   = varargin{k+1};
              case 'status'   , statusINI = varargin{k+1};
              case 'toolopt'  , toolOPT   = varargin{k+1};
            end 
        end

        % Structure initialization.
        %--------------------------
        % h_CMD_LVL: [txt_lev ; sli_lev ; edi_lev] x Level
        % h_GRA_LVL: [axe_thr ; lin_min ; lin_max] x Dir x Level
        h_CMD_LVL = NaN*ones(3,levmaxMAX);        
        h_GRA_LVL = NaN*ones(3,3,levmaxMAX);
        threshDEF = NaN*ones(3,levmaxMAX);
        thrStruct = struct('Value',threshDEF,'max',threshDEF);
        ud = struct(...
                'toolOPT',toolOPT, ...
                'status',statusINI,...
                'levmin',levmin,   ...
                'levmax',levmax,   ...
                'levmaxMAX',levmaxMAX, ...
                'levANAL',levANAL, ...
                'thrStruct',thrStruct, ...            
                'visible',lower(visVal),...
                'ydir', ydir,          ...
                'isbior',isbior,       ...
                'handlesUIC',[],       ...
                'h_CMD_LVL',h_CMD_LVL, ...
                'h_GRA_LVL',h_GRA_LVL, ...
                'handleORI' ,[],       ... 
                'handleTHR',[],        ... 
                'handleRES' ,[]        ... 
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
        sli_hi = Def_Btn_Height*sliYProp;
        sli_dy = 0.5*Def_Btn_Height*(1-sliYProp);
        [bdy,d_lev] = wtbutils('deno2D_PREFS','params');


        % Setting frame position.
        %------------------------
        switch  toolOPT
          case {'deno','esti'} , NB_Height = 7;
          case {'comp'}        , NB_Height = 8;
        end
        w_fra   = mextglob('get','Fra_Width');
        h_fra   = (levmaxMAX+NB_Height)*Def_Btn_Height+...
                   levmaxMAX*d_lev+ (NB_Height-2)*bdy;
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % String property of objects.
        %----------------------------
        str_txt_top = getWavMSG('Wavelet:dw2dRF:Sel_Thr_Met');
        str_txt_BMS = getWavMSG('Wavelet:dw2dRF:Sparsity');
        str_pop_dir = {...
            getWavMSG('Wavelet:dw2dRF:Str_pop_dir_1'), ...
            getWavMSG('Wavelet:dw2dRF:Str_pop_dir_2'), ...
            getWavMSG('Wavelet:dw2dRF:Str_pop_dir_3')  ...
            };
        str_txt_tit = {...
            getWavMSG('Wavelet:dw2dRF:Str_txt_tit_1'), ...
            getWavMSG('Wavelet:dw2dRF:Str_txt_tit_2'), ...
            getWavMSG('Wavelet:dw2dRF:Str_txt_tit_3')  ...
            };
        
        str_tog_res = getWavMSG('Wavelet:dw2dRF:Str_tog_res');
        str_pop_met = wthrmeth(toolOPT,'names');
        switch  toolOPT
          case {'deno','esti'}
            str_rad_sof = getWavMSG('Wavelet:commongui:Str_Soft');
            str_rad_har = getWavMSG('Wavelet:commongui:Str_Hard');
            str_txt_noi = getWavMSG('Wavelet:commongui:Str_NoiStruc');
            str_pop_noi = {...
                getWavMSG('Wavelet:commongui:Str_UWNoise'), ...
                getWavMSG('Wavelet:commongui:Str_SWNoise'), ...
                getWavMSG('Wavelet:commongui:Str_NWNoise')  ...
                };

          case 'comp'
              if ud.isbior
                  str_txt_nor = getWavMSG('Wavelet:commongui:Str_NormRec');
              else
                  str_txt_nor = getWavMSG('Wavelet:commongui:Str_RetEner');
              end
              str_txt_zer = getWavMSG('Wavelet:commongui:Str_ZerNb');
        end
        switch  toolOPT
            case 'deno' 
                str_pus_est = getWavMSG('Wavelet:commongui:Str_DENO');
                estOPT = 'denoise';
            case 'comp' 
                str_pus_est = getWavMSG('Wavelet:commongui:Str_COMP');
                estOPT = 'compress';
            case {'esti','esti_REG','esti_DEN'} 
                str_pus_est = getWavMSG('Wavelet:commongui:Str_ESTI');
                estOPT = 'estimate';
                
        end

        % Position properties.
        %---------------------
        txt_width   = Def_Btn_Width;
        dy_lev      = Def_Btn_Height+d_lev;
        xleft       = xleft+bdx;
        w_rem       = w_fra-2*bdx;
        ylow        = ybottom+h_fra-Def_Btn_Height-bdy;

        w_uic       = (5*txt_width)/2;
        x_uic       = xleft+(w_rem-w_uic)/2;
        y_uic       = ylow;
        pos_txt_top = [x_uic, y_uic+d_txt/2, w_uic, Def_Txt_Height];

        y_uic       = y_uic-Def_Btn_Height;
        pos_pop_met = [x_uic, y_uic, w_uic, Def_Btn_Height];
        y_uic       = y_uic-Def_Btn_Height;
        switch  toolOPT
          case {'deno','esti'}
            y_uic       = y_uic-bdy;
            w_rad       = Pop_Min_Width;
            w_sep       = (w_uic-2*w_rad)/3;
            x_rad       = x_uic+w_sep;
            pos_rad_sof = [x_rad, y_uic, w_rad, Def_Btn_Height];
            x_rad       = x_rad+w_rad+w_sep;
            pos_rad_har = [x_rad, y_uic, w_rad, Def_Btn_Height];

            y_uic       = y_uic-Def_Btn_Height;
            y_BMS       = y_uic;
            pos_txt_noi = [x_uic, y_uic, w_uic, Def_Txt_Height];
            y_uic       = y_uic-Def_Btn_Height;
            pos_pop_noi = [x_uic, y_uic, w_uic, Def_Btn_Height];

          case 'comp'
            y_BMS       = y_uic;
            y_uic       = y_uic-Def_Btn_Height;
        end

        pos_txt_BMS = [x_uic, y_BMS, w_uic, Def_Txt_Height];
        y_BMS       = y_BMS-Def_Btn_Height;
        w_BMS       = (w_uic-bdx)/3;
        pos_sli_BMS = [x_uic+w_BMS/2, y_BMS+sli_dy, 2*w_BMS, sli_hi];

        y_uic       = y_uic-Def_Btn_Height-bdy;
        pos_pop_dir = [x_uic, y_uic, w_uic, Def_Btn_Height];

        wx          = 2;
        wbase       = 2*(w_rem-4*wx)/5;
        w_lev       = [6*wbase ; 15*wbase ; 9*wbase]/12;
        x_uic       = xleft+wx;
        y_uic       = y_uic-Def_Btn_Height-bdy;
        pos_lev_tit = [x_uic, y_uic, w_lev(1), Def_Txt_Height];
        pos_lev_tit = pos_lev_tit(ones(1,3),:);
        pos_lev_tit(:,3) = w_lev; 
        for k=1:2 , pos_lev_tit(k+1,1) = pos_lev_tit(k,1)+pos_lev_tit(k,3); end
        y_uic = pos_lev_tit(1,2)-levmaxMAX*(Def_Btn_Height+d_lev);
        for k = 1:3 , pos_lev_tit(k,2) = pos_lev_tit(k,2)+1; end

        switch  toolOPT
          case {'deno','esti'}
          case {'comp'}
            wid1 = (15*w_rem)/26;
            wid2 = (8*w_rem)/26;
            wid3 = (2*w_rem)/26;
            wx   = (w_rem-wid1-wid2-wid3)/4;
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
        end

        w_uic = w_fra/2-bdx;
        x_uic = pos_fra(1);
        h_uic = (3*Def_Btn_Height)/2;
        y_uic = pos_fra(2)-h_uic-Def_Btn_Height/2;
        pos_pus_est = [x_uic, y_uic, w_uic, h_uic]; 
        x_uic = x_uic+w_uic+2*bdx;
        pos_tog_res = [x_uic, y_uic, w_uic, h_uic]; 

        % Create UIC.
        %------------
        comProp = {...
           'Parent',fig,    ...
           'Units',fig_units ...
           'Visible','On'  ...
           };
        comTxtProp = [comProp, ...
           'Style','Text',...
           'HorizontalAlignment','center', ...
           'BackgroundColor',bkColor ...
           ];

        fra_utl = uicontrol(comProp{:}, ...
                            'Style','frame', ...
                            'Position',pos_fra, ...
                            'BackgroundColor',bkColor, ...
                            'ForeGroundColor',Def_ShadowColor, ...
                            'Tag',tag_fra_tool ...
                            );

        txt_top = uicontrol(comProp{:}, ...
                            'Style','Text', ...
                            'Position',pos_txt_top,   ...
                            'String',str_txt_top,     ...
                            'BackgroundColor',bkColor, ...
                            'Tag','Txt_Sel_THR_METH' ...
                            );

        cba = @(~,~)utthrw2d('update_methName', fig );
        pop_met = uicontrol(comProp{:}, ...
                            'Style','Popup',...
                            'Position',pos_pop_met,...
                            'Enable',statusINI, ...
                            'String',str_pop_met,...
                            'HorizontalAlignment','center',...
                            'UserData',1,...
                            'Callback',cba, ...
                            'Tag','Pop_THR_METH' ...
                            );

        switch  toolOPT
          case {'deno','esti'}
            rad_sof = uicontrol(comProp{:}, ...
                                'Style','RadioButton',...
                                'Position',pos_rad_sof,...
                                'Enable',statusINI, ...
                                'HorizontalAlignment','center',...
                                'String',str_rad_sof,...
                                'Value',1,'UserData',1, ...
                                'Tag','soft_Rad' ...                                
                                );

            rad_har = uicontrol(comProp{:}, ...
                                'Style','RadioButton',...
                                'Position',pos_rad_har,...
                                'Enable',statusINI, ...
                                'HorizontalAlignment','center',...
                                'String',str_rad_har,...
                                'Value',0,'UserData',0, ...
                                'Tag','hard_Rad'...                                
                                );
            cba = @(~,~)utthrw2d('update_thrType', fig );
            set(rad_sof,'Callback',cba);
            set(rad_har,'Callback',cba);

            txt_noi = uicontrol(comProp{:}, ...
                                'Style','Text',...
                                'Position',pos_txt_noi,...
                                'BackgroundColor',bkColor,...
                                'String',str_txt_noi,...
                                'Tag','Txt_Sel_NOI_STRUC' ...
                                );

            cba = @(~,~)utthrw2d('update_by_Caller', fig );
            pop_noi = uicontrol(comProp{:}, ...
                                'Style','Popup',...
                                'Position',pos_pop_noi,...
                                'Enable',statusINI, ...
                                'String',str_pop_noi,...
                                'HorizontalAlignment','center',...
                                'UserData',1,...
                                'Callback',cba, ...
                                'Tag','Pop_NOI_STRUC' ...                                
                                );
          case {'comp'}
        end

        txt_BMS = uicontrol(comProp{:}, ...
                            'Style','Text',...
                            'Position',pos_txt_BMS,...
                            'BackgroundColor',bkColor,...
                            'String',str_txt_BMS,...
                            'Tag','Txt_Sparsity' ...
                            );

        cba = @(~,~)utthrw2d('update_by_Caller', fig );
        sli_BMS = uicontrol(comProp{:}, ...
                            'Style','Slider',...
                            'Position',pos_sli_BMS,...
                            'Enable',statusINI,    ...
                            'Min',1+sqrt(eps),     ...
                            'Max',5-sqrt(eps),     ...
                            'Value',1.5,           ...
                            'BackgroundColor',bkColor, ...
                            'Callback',cba,         ...
                            'Tag','Sli_Sparsity' ...                            
                            );

        cba = @(~,~)utthrw2d('update_DIR', fig );
        pop_dir = uicontrol(comProp{:}, ...
                            'Style','Popup',...
                            'Position',pos_pop_dir,...
                            'Enable',statusINI,    ...
                            'String',str_pop_dir,  ...
                            'UserData',1,          ...
                            'Callback',cba,        ...
                            'Tag','Pop_Direction'   ...                                                        
                            );
        txt_tit = zeros(3,1);
        for k=1:3
            txt_tit(k) = uicontrol(...
                                   comTxtProp{:}, ...
                                   'Position',pos_lev_tit(k,:), ...
                                   'String',str_txt_tit{k}, ...
                                   'Tag',['Txt_title_' int2str(k)] ...
                                   );
        end
        xbtn0 = xleft;
        ybtn0 = pos_lev_tit(1,2)-Def_Btn_Height;
        xbtn  = xbtn0;
        ybtn  = ybtn0;
        if ud.ydir==1
            index = (1:levmaxMAX);
        else
            index = (levmaxMAX:-1:1);
            ybtn  = ybtn0+(levmaxMAX-levmax)*dy_lev;
        end
        for j=1:length(index)
            i = index(j);
            max_lev = 1;
            val_lev = 0.5;
            pos_lev = [xbtn ybtn+d_txt/2 w_lev(1) Def_Txt_Height];
            str_lev = sprintf('%.0f',i);
            txt_lev = uicontrol(...
                              comTxtProp{:},     ...
                              'Position',pos_lev,...
                              'String',str_lev,  ...
                              'UserData',i,       ...
                              'Tag',['Txt_lev_' str_lev] ...
                              );

            xbtn    = xbtn+w_lev(1)+wx;
            pos_lev = [xbtn, ybtn+sli_dy, w_lev(2), sli_hi];
            sli_lev = uicontrol(...
                              comProp{:},         ...
                              'Style','Slider',   ...
                              'Enable',enaVal,    ...
                              'Position',pos_lev, ...
                              'Min',0,            ...
                              'Max',max_lev,      ...
                              'Value',val_lev,    ...
                              'UserData',i,       ...
                              'Tag',['Sli_lev_' str_lev] ...                              
                              );

            xbtn    = xbtn+w_lev(2)+wx;
            pos_lev = [xbtn ybtn w_lev(3) Def_Btn_Height];
            str_val = sprintf('%1.4g',val_lev);
            edi_lev = uicontrol(...
                              comProp{:},         ...
                              'Style','Edit',     ...
                              'Enable',enaVal,    ...
                              'Position',pos_lev, ...
                              'String',str_val,   ...
                              'HorizontalAlignment','center',...
                              'BackgroundColor',Def_EdiBkColor,...
                              'UserData',i,       ...
                              'Tag',['Edi_lev_' str_lev] ...                              
                              );

            cba_sli = @(~,~)utthrw2d('update_by_UIC', fig , i,'sli');
            cba_edi = @(~,~)utthrw2d('update_by_UIC', fig , i,'edi');
            set(sli_lev,'Callback',cba_sli);
            set(edi_lev,'Callback',cba_edi);
            h_CMD_LVL(:,i) = [txt_lev ; sli_lev ; edi_lev];
            xbtn = xbtn0;
            ybtn = ybtn-dy_lev;
        end

        switch  toolOPT
          case {'deno','esti'}
          case {'comp'}
            comEdiProp = [comProp, ...
                'Style','Edit',...
                'String',' ',...
                'Enable','Inactive', ...
                'BackgroundColor',bkColor,...
                'HorizontalAlignment','center'...
                ];
            txt_nor = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_nor,...
                                'HorizontalAlignment','left',...
                                'String',str_txt_nor...
                                );

            cba_nor = @(~,~)utthrw2d('updateTHR', fig ,'nor');
            edi_nor = uicontrol(comEdiProp{:}, ...
                                'Position',pos_edi_nor,...
                                'Callback',cba_nor ...
                                );

            txt_npc = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_npc,...
                                'String','%'...
                                );

            txt_zer = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_zer,...
                                'HorizontalAlignment','left',...
                                'String',str_txt_zer...
                                );

            cba_zer = @(~,~)utthrw2d('updateTHR', fig ,'zer');
            edi_zer = uicontrol(comEdiProp{:}, ...
                                'Position',pos_edi_zer,...
                                'Callback',cba_zer ...
                                );

            txt_zpc = uicontrol(comTxtProp{:}, ...
                                'Position',pos_txt_zpc,...
                                'String','%'...
                                );
        end

        cba = @(~,~)utthrw2d('residuals', fig);
        tip = getWavMSG('Wavelet:commongui:Tip_MoreOnRes');
        tog_res = uicontrol(...
                            comProp{:},             ...
                            'Style','Togglebutton', ...
                            'Position',pos_tog_res, ...
                            'String',str_tog_res,   ...
                            'Enable','off',         ...
                            'Callback',cba,         ...
                            'TooltipString',tip,    ...
                            'Interruptible','Off',  ...
                            'Tag','Tog_Residuals'   ...
                            );

        cba_pus_est = @(~,~)utthrw2d(estOPT, fig );
        pus_est = uicontrol(comProp{:},             ...
                            'Style','pushbutton',   ...
                            'Position',pos_pus_est, ...
                            'String',str_pus_est,   ...
                            'Enable',enaVal,        ...
                            'Tag','Pus_Estimate',   ...
                            'Callback',cba_pus_est  ...
                            );

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------							
        switch  toolOPT
          case {'deno','esti'}
			hdl_DENO_SOFTHARD   = [rad_sof,rad_har];
			hdl_DENO_NOISSTRUCT = [txt_noi,pop_noi];
			wfighelp('add_ContextMenu',fig,hdl_DENO_SOFTHARD,'DENO_SOFTHARD');
			wfighelp('add_ContextMenu',fig,hdl_DENO_NOISSTRUCT,'DENO_NOISSTRUCT');
		
          case {'comp'}
			hdl_COMP_SCORES = [...
				txt_nor,edi_nor,txt_npc,txt_zer,edi_zer,txt_zpc ...
				];			  
			wfighelp('add_ContextMenu',fig,hdl_COMP_SCORES,'COMP_SCORES');

        end
        hdl_COMP_DENO_STRA = [...
			fra_utl,txt_top,pop_met,txt_BMS,sli_BMS,  ...
			];				
		wfighelp('add_ContextMenu',fig,hdl_COMP_DENO_STRA,'COMP_DENO_STRA');
		%-------------------------------------

		% Store handles.
		%--------------
        switch  toolOPT
          case {'deno','esti'}
            ud.handlesUIC = ...
                [double([fra_utl;txt_top;pop_met;...
                rad_sof;rad_har;txt_noi;pop_noi; ...
                txt_BMS;sli_BMS;pop_dir]);txt_tit(1:3);...
                NaN(6,1);double([tog_res;pus_est])];
          case {'comp'}
            ud.handlesUIC = ...
                [double([fra_utl;txt_top;pop_met]); NaN(4,1);...
                double([txt_BMS;sli_BMS;pop_dir]);txt_tit(1:3);...
                double([txt_nor;edi_nor;txt_npc;txt_zer;edi_zer; ...
                txt_zpc;tog_res;pus_est])];
        end        
        ud.h_CMD_LVL = h_CMD_LVL;
        ud.h_GRA_LVL = h_GRA_LVL;
        set(fra_utl,'UserData',ud);
        varargout{1} = utthrw2d('set',fig,'position',{levmin,levmax});

    case 'status'
      if ~isempty(varargin)
         toolStatus = varargin{1};
         ud.status  = toolStatus;
         set(fra,'UserData',ud);
         set([pop_met;rad_sof;rad_har;...
              pop_noi;sli_BMS;pop_dir],'Enable',toolStatus)
         if isequal(lower(toolStatus),'off')
             utthrw2d('Enable',fig,'off')
         end       
      end
      varargout{1} = toolStatus;

    case {'enable','Enable'}
        enaVal = varargin{1};
        if length(varargin)>1
            levs = varargin{2};
        else
            levs = ud.levmin:ud.levmax;
        end
        uic = h_CMD_LVL(2:3,:);
        set([uic(:);tog_res;pus_est],'Enable','off');
        if isequal(lower(enaVal),'on')
            uic = h_CMD_LVL(2:3,levs);
            set([uic(:);pus_est],'Enable',enaVal);
        end

    case 'enable_tog_res'
        enaVal = varargin{1};
        set(tog_res,'Enable',enaVal);

    case 'visible'
        visVal     = lower(varargin{1});
        ud.visible = visVal;
        handlesAXE = h_GRA_LVL(1,:,ud.levmin:ud.levmax);
        handlesAXE = findobj(handlesAXE(ishandle(handlesAXE(:))));
        if isequal(visVal,'on')
            h_CMD_LVL = h_CMD_LVL(1:3,ud.levmin:ud.levmax);
            numMeth = get(pop_met,'Value');
            switch toolOPT
              case {'deno','esti'}
                switch numMeth
                  case {1,5}   , invis = [txt_BMS;sli_BMS];
                  case {2,3,4} , invis = [txt_noi;pop_noi];
                end

              case {'comp'}
                switch numMeth
                   case {1,2,3} , invis = [];
                   case {4,5,6} , invis = [txt_BMS;sli_BMS];
                end 
            end
            handlesUIC = setdiff(handlesUIC,invis);
        end
        handles = [h_CMD_LVL(:);double(handlesAXE(:));handlesUIC(:)];
        set(handles(ishandle(handles)),'Visible',visVal);

    case 'set'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:2:nbarg
           argType = lower(varargin{k});
           argVal  = varargin{k+1};
           switch argType
               case 'position_bis'
                 [levmin,levmax] = deal(argVal{:});
                 ud.levmin = levmin;
                 ud.levmax = levmax;
                 set(fra,'UserData',ud);
                 visVal     = ud.visible;
                 if isequal(visVal,'on')
                     numMeth = get(pop_met,'Value');
                     switch numMeth
                         case {1,5}   , invis = [txt_BMS;sli_BMS];
                         case {2,3,4} , invis = [txt_noi;pop_noi];
                     end
                     handlesUIC = setdiff(handlesUIC,invis);
                 end
                 h_CMD_ACT = h_CMD_LVL(1:3,levmin:levmax);
                 h_CMD_INACT = h_CMD_LVL(1:3,levmax+1:end);
                 set(h_CMD_ACT(:),'Enable','On')
                 set(h_CMD_INACT(:),'Enable','Off')
               
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
                 tmpHandles = [h_CMD_LVL(:);handlesUIC(:)];
                 tmpHandles = tmpHandles(ishandle(tmpHandles));
                 set(tmpHandles,'Visible','off');
                 set([fig;tmpHandles],'Units','pixels');
                 
                 % Check if figure has full screen size
                 posFIG = get(fig,'Position');
                 scrSIZ = getMonitorSize;
                 fullSIZE = posFIG(3)==scrSIZ(3);
                 [bdy,d_lev,btnHeight] = wtbutils('deno2D_PREFS','params');
                 if fullSIZE
                     pop = findobj(fig,'Tag','Pop_THR_METH');
                     pos_pop = get(pop,'Position');
                     mulFULL = pos_pop(4)/btnHeight;
                 else
                     mulFULL = 1;
                 end
                 btnHeight = btnHeight*mulFULL;
                 bdy = bdy*mulFULL;
                 d_lev = d_lev*mulFULL;
                 pos_fra = get(fra,'Position');
                 top_fra = pos_fra(2)+pos_fra(4);
                 switch  toolOPT
                     case {'deno','esti'} , NB_Height = 7;
                     case {'comp'}        , NB_Height = 8;
                 end
                 h_ini   = (NB_Height-2)*bdy+NB_Height*btnHeight;
                 h_fra   = h_ini+ nblevs*(btnHeight+d_lev);
                 pos_fra(2) = top_fra-h_fra;
                 pos_fra(4) = h_fra;
                 dy_lev = d_lev+btnHeight;
                 y_est  = pos_fra(2)-2*btnHeight;
                 y_res  = y_est;
                 
                 set(fra,'Position',pos_fra);
                 ytrans = dnum_lev*dy_lev;
                 [row,col] = size(h_CMD_LVL);
                 for j=1:col
                     for kk = 1:row
                         p = get(h_CMD_LVL(kk,j),'Position');
                         set(h_CMD_LVL(kk,j),'Position',[p(1),p(2)+ytrans,p(3:4)]);
                     end
                 end
                 p = get(tog_res,'Position');
                 set(tog_res,'Position',[p(1),y_res,p(3:4)]);
                 ytrans = y_res-p(2);
                 p = get(pus_est,'Position');
                 set(pus_est,'Position',[p(1),y_est,p(3:4)]);
                 switch toolOPT
                   case {'comp'}
                     tmpHDL = [txt_nor;edi_nor;txt_npc;txt_zer;edi_zer;txt_zpc];
                     for kk = 1:length(tmpHDL)
                         p = get(tmpHDL(kk),'Position');
                         set(tmpHDL(kk),'Position',[p(1),p(2)+ytrans,p(3:4)]);
                     end                  
                 end
                 set([fig;tmpHandles],'Units',old_units);
                 utthrw2d('visible',fig,ud.visible);
                 if nargout>0
                     varargout{1} = [pos_fra(1) , y_est , pos_fra([3 4])];
                 end

               case 'axes'
                 [row,col] = size(argVal);
                 ud.h_GRA_LVL(1,1:row,1:col) = argVal;
                 set(fra,'UserData',ud);

               case 'handleori' , ud.handleORI = argVal; set(fra,'UserData',ud);
               case 'handlethr' , ud.handleTHR = argVal; set(fra,'UserData',ud);
               case 'handleres' , ud.handleRES = argVal; set(fra,'UserData',ud);
               case 'perfos'  
                 switch toolOPT
                   case {'comp'}
                     set(edi_nor,'String',sprintf('%5.2f',argVal{1}));
                     set(edi_zer,'String',sprintf('%5.2f',argVal{2}));
                 end
               case {'valthr','maxthr'}
                 threshDEF = NaN*ones(3,ud.levmaxMAX);
                 sizARG = size(argVal);
                 NB_old = ud.levmax-ud.levmin+1;
                 if (sizARG(1)==3) && (sizARG(2)>NB_old)
                    Cbeg = 1; Cend = sizARG(2);
                 else
                    Cbeg = ud.levmin; Cend = ud.levmax;
                 end
                 threshDEF(:,Cbeg:Cend) = argVal;
                 if isequal(argType,'valthr')
                     ud.thrStruct.value = threshDEF;
                 else
                     ud.thrStruct.max = threshDEF;
                 end
                 set(fra,'UserData',ud);
           end
        end

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        for k = 1:nbarg
           outType = lower(varargin{k});
           switch outType
               case 'position'
                 pos_fra = get(fra,'Position');
                 pos_est = get(pus_est,'Position');
                 varargout{k} = [pos_fra(1) , pos_est(2) , pos_fra([3 4])]; %#ok<*AGROW>

               case 'valthr' 
                 varargout{k} = ud.thrStruct.value(:,ud.levmin:ud.levmax);

               case 'allvalthr' , varargout{k} = ud.thrStruct.value;                 
               case 'maxthr'    , varargout{k} = ud.thrStruct.max;

               case {'pus_den','pus_est','pus_com'} , varargout{k} = pus_est;
               case 'handleori' , varargout{k} = ud.handleORI;
               case 'handlethr' , varargout{k} = ud.handleTHR;
               case 'handleres' , varargout{k} = ud.handleRES;
           end
        end

    case 'update_methName'
        numMeth = get(pop_met,'Value');
        switch toolOPT
          case {'deno','esti'}
            HDL_1 = [txt_BMS;sli_BMS];
            HDL_2 = [txt_noi;pop_noi];
            switch numMeth
              case {1,5}
                invis  = HDL_1;   vis = HDL_2;
                radDef = rad_sof; radNoDef = rad_har;
              case {2,3,4}
                invis  = HDL_2;   vis = HDL_1;
                radDef = rad_har; radNoDef = rad_sof;
            end
            set(sli_BMS,'Value',3)
            set(invis,'Visible','off')
            set(vis,'Visible','on')
            set(radDef,'Value',1,'UserData',1);
            set(radNoDef,'Value',0,'UserData',0);

          case {'comp'}
            HDL_1 = [txt_BMS;sli_BMS];
            HDL_2 = [];
            switch numMeth
              case {1,2,3} , invis = HDL_2; vis = HDL_1;
              case {4,5,6} , invis = HDL_1; vis = HDL_2;
            end
            set(sli_BMS,'Value',1.5);
            set(invis,'Visible','off')
            set(vis,'Visible','on')
        end
        utthrw2d('update_by_Caller',fig)

    case 'update_DIR'
        newDIR = get(pop_dir,'Value');
        oldDIR = get(pop_dir,'UserData');
        if isequal(newDIR,oldDIR) , return; end
        set(pop_dir,'UserData',newDIR)
        valTHR = ud.thrStruct.value(newDIR,:);
        maxTHR = ud.thrStruct.max(newDIR,:);
        for k = ud.levmin:ud.levmax
            set(h_CMD_LVL(2,k),'Min',0,'Max',maxTHR(k),'Value',valTHR(k));
            set(h_CMD_LVL(3,k),'String',sprintf('%1.4g',valTHR(k)));
        end

    case 'update_by_UIC'
        level    = varargin{1};
        type_hdl = varargin{2};
        sli = h_CMD_LVL(2,level);
        edi = h_CMD_LVL(3,level);
        dir = get(pop_dir,'Value');
        lHu = h_GRA_LVL(2,dir,level);
        lHd = h_GRA_LVL(3,dir,level);

        % Updating threshold.
        %---------------------
        switch type_hdl
            case 'sli'
              thresh = get(sli,'Value');
              set(edi,'String',sprintf('%1.4g',thresh));

            case 'edi'
              valstr = get(edi,'String');
              [thresh,count,err] = sscanf(valstr,'%f');
              if (count~=1) || ~isempty(err)
                  thresh = get(sli,'Value');
                  set(edi,'String',sprintf('%1.4g',thresh));
                  return
              else
                  mi = get(sli,'Min');
                  ma = get(sli,'Max');
                  if     thresh<mi , thresh = mi;
                  elseif thresh>ma , thresh = ma;
                  end
                  set(sli,'Value',thresh);
                  set(edi,'String',sprintf('%1.4g',thresh));
              end
        end
        xdata = [thresh thresh];
        set(lHu,'XData', xdata);
        if thresh<sqrt(eps) , xdata = [NaN NaN]; end
        set(lHd,'XData',-xdata);
        feval(calledFUN,'clear_GRAPHICS',fig);
        utthrw2d('update_thrStruct',fig,dir,level,thresh);
        if isequal(toolOPT,'comp') , utthrw2d('show_LVL_perfos',fig); end

    case 'update_thrType'
        rad = gcbo;
        old = get(rad,'UserData');
        if old==1 , set(rad,'Value',1); return; end
        if isequal(double(rad),rad_sof)
           other = rad_har;
        else
           other = rad_sof;           
        end
        set(other,'Value',0,'UserData',0);
        set(rad,'Value',1,'UserData',1);
        feval(calledFUN,'clear_GRAPHICS',fig);

    case 'update_by_Caller'
        feval(calledFUN,'update_LVL_meth',fig);

    case 'get_LVL_par'
        numMeth = get(pop_met,'Value');
        meth    = wthrmeth(toolOPT,'shortnames',numMeth);
        switch  toolOPT
          case {'deno','esti'}             
             valType = get(rad_sof,'Value');
             if valType==1 , sorh = 's'; else sorh = 'h'; end
             switch numMeth
               case {1,5}
                 valNoise = get(pop_noi,'Value');
                 switch valNoise
                   case 1 , scal = 'one';
                   case 2 , scal = 'sln';
                   case 3 , scal = 'mln';
                 end
               case {2,3,4}, scal = get(sli_BMS,'Value');
             end
             varargout = {numMeth,meth,scal,sorh};

          case {'comp'}
             sorh = 'h';
             switch numMeth
               case {1,2,3} , scal = get(sli_BMS,'Value');
               case {4,5,6} , scal = get(sli_BMS,'Value'); % Not Used           
             end
             varargout = {numMeth,meth,scal,sorh};
        end

    case 'update_LVL_meth'
        % called by : calledFUN('update_LVL_meth', ...)
        %-------------------------------------------
        valTHR = varargin{1};
        NB_lev = size(valTHR,2);
        maxTHR = utthrw2d('get',fig,'maxTHR');
        maxTHR = maxTHR(:,ud.levmin:NB_lev);        
        valTHR = min(valTHR,maxTHR);
        
        utthrw2d('set',fig,'valTHR',valTHR);
        direct = get(pop_dir,'Value'); 
        sli_lev = h_CMD_LVL(2,1:NB_lev);
        edi_lev = h_CMD_LVL(3,1:NB_lev);        
        for k = 1:NB_lev
            thr  = valTHR(direct,k);
            set(sli_lev(k),'Value',thr);
            set(edi_lev(k),'String',sprintf('%1.4g',thr));            
        end
        for k = 1:NB_lev
            for d=1:3
                thr = valTHR(d,k);
                thr = [thr thr]; 
                set(h_GRA_LVL(2,d,k),'XData', thr);
                set(h_GRA_LVL(3,d,k),'XData',-thr);
            end
        end

    case 'show_LVL_perfos'
        if isequal(toolOPT,'comp')
            feval(calledFUN,'show_LVL_perfos',fig);
        end

    case 'update_thrStruct'
        % called by : cbthrw2d
        %----------------------
        dir   = varargin{1};
        level = varargin{2};
        thr   = varargin{3};
        ud.thrStruct.value(dir,level) = thr;
        set(fra,'UserData',ud);

    case {'denoise','compress','estimate'}
        feval(calledFUN,option,fig);

    case 'clean_thr'
        set(h_CMD_LVL(2,:),'Min',0,'Max',1,'Value',0.5);  % sli_lev;
        set(h_CMD_LVL(3,:),'String','');                  % edi_lev
        switch toolOPT
          case {'deno','esti'}  
          case {'comp'} 
        end

    case 'residuals'
        wmoreres('create',fig,tog_res,ud.handleRES,ud.handleORI,ud.handleTHR,'blocPAR');

    case 'plot_dec'
        dirDef = get(pop_dir,'Value');
        [thr_max,thr_val,ylim,direct,level,axeAct] = deal(varargin{2}{:});
        if direct==dirDef
            set(h_CMD_LVL(2,level),'Min',0,'Max',thr_max,'Value',thr_val);
            set(h_CMD_LVL(3,level),'String',sprintf('%1.4g',thr_val));
        end
        colTHR = wtbutils('colors','linTHR');
        l_min = line('LineStyle','--',...
                  'Color',colTHR,...
                  'XData',[thr_val thr_val],...
                  'YData',ylim,...
                  'Parent',axeAct);
        l_max = line('LineStyle','--',...
                  'Color',colTHR,...
                  'XData',[-thr_val -thr_val],...
                  'YData',ylim,...
                  'Parent',axeAct);
        setappdata(l_min,'selectPointer','V');
        setappdata(l_max,'selectPointer','V');
        if thr_val==0 , set(l_max,'Visible','Off'); end
        maxval  = thr_max;
        hdl_str = [double(fig);   pop_dir ; direct ; level ; ...
                     double(l_min); double(l_max); double(h_CMD_LVL(2:3,level))];
        cba_thr_min = @(~,~)cbthrw2d('down', hdl_str , ...
                                +1 , maxval );
        cba_thr_max = @(~,~)cbthrw2d('down', hdl_str , ...
                                -1 , maxval );
        set(l_min,'ButtonDownFcn',cba_thr_min)
        set(l_max,'ButtonDownFcn',cba_thr_max)
        h_GRA_LVL(2:3,direct,level) = [l_min , l_max];
        ud.h_GRA_LVL = h_GRA_LVL;
        set(fra,'UserData',ud);

    case 'demo'
    % SPECIAL for DEMOS
    %------------------
    [tool,den_Meth,thr_Val] = deal(varargin{:}); %#ok<ASGLU>
    shortnames = wthrmeth(toolOPT,'shortnames');
    par = deblank(den_Meth);
    ind = find(strncmp(par, num2cell(shortnames,2),length(par)));
    if isempty(ind) , return; end
    set(pop_met,'Value',ind)
    utthrw2d('update_methName',fig)
    if ~isnan(thr_Val)
        utthrw2d('set',fig,'valTHR',thr_Val);
        thr_Val = utthrw2d('get',fig,'valTHR');
        utthrw2d('update_LVL_meth',fig,thr_Val);
    end

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
  case {'deno','esti'}
    thrMethods = {...
        getWavMSG('Wavelet:moreMSGRF:Fixed_form'),   'sqtwolog',    1; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_high'),   'penalhi',     2; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_medium'), 'penalme',     3; ...
        getWavMSG('Wavelet:moreMSGRF:Penal_low'),    'penallo',     4; ...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm_SQRT'),'sqrtbal_sn',  5  ...
        };

  case 'comp'
    thrMethods = {...
        getWavMSG('Wavelet:moreMSGRF:Scarce_high'),     'scarcehi',   1; ...
        getWavMSG('Wavelet:moreMSGRF:Scarce_medium'),   'scarceme',   2; ...
        getWavMSG('Wavelet:moreMSGRF:Scarce_low'),      'scarcelo',   3; ...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm'),  'bal_sn',     4; ...
        getWavMSG('Wavelet:moreMSGRF:Remove_near_0'),   'rem_n0',     5; ...
        getWavMSG('Wavelet:moreMSGRF:Bal_SparseNorm_SQRT'), 'sqrtbal_sn', 6  ...
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
