function varargout = utstats(option,fig,varargin)
%UTSTATS Utilities for statistics tools.
%   VARARGOUT = UTSTATS(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-May-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.4.4.9 $  $Date: 2013/07/05 04:30:30 $

% Tag property of objects.
%-------------------------
tag_sta_val = 'Fra_StaVal';

switch option
    case 'create'

        % Get Globals.
        %--------------
        [Def_Btn_Height,X_Spacing,Y_Spacing, ...
         Def_FraBkColor,EdiBkColor,uicFontSize,Def_ShadowColor] = ...
            mextglob('get',...
                'Def_Btn_Height','X_Spacing','Y_Spacing', ...
                'Def_FraBkColor','Def_Edi_InActBkColor','Def_UicFontSize', ...
                'Def_ShadowColor');
         minFontSize = wtbutils('utSTATS_PREFS');
         uicFontSize = min([uicFontSize,minFontSize]);

        % General graphical parameters initialization.
        %--------------------------------------------
        % Borders and double borders.
        dx = X_Spacing;  dx2 = 2*dx;
        dy = Y_Spacing;  dy2 = 2*dy;

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor; %#ok<NASGU>

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
              case 'bkcolor' , bkColor = varargin{k+1}; %#ok<NASGU>
            end 
        end  
        old_units  = get(fig,'Units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'Units',fig_units); end

        % Setting frame position.
        %------------------------
        [win_width,cmd_width] = mextglob('get','Win_Width','Cmd_Width');        
        w_fra   = win_width-cmd_width-2*dx2;
        h_fra   = 3*Def_Btn_Height+8*dy;
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fra = [xleft,ybottom,w_fra,h_fra];

        % Position property of objects.
        %------------------------------
        yd_ini  = pos_fra(2)+h_fra-Def_Btn_Height-dy2;
        wx      = (pos_fra(3)-5*dx)/10;
        ecx     = 7*wx/5;
        %----------------------------------------------------------
        xl            = pos_fra(1) + 1.5*dx;
        yd            = yd_ini;
        wtxt          = 8*wx/10;
        pos_mean_txt  = [xl yd wtxt Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_med_txt   = [xl yd wtxt Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_mode_txt  = [xl yd wtxt Def_Btn_Height];
        %----------------------------------------------------------
        xl            = pos_mean_txt(1)+pos_mean_txt(3)+dx+ecx;
        yd            = yd_ini;
        pos_max_txt   = [xl yd wx Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_min_txt   = [xl yd wx Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_range_txt = [xl yd wx Def_Btn_Height];
        %----------------------------------------------------------
        xl            = pos_max_txt(1)+pos_max_txt(3)+dx+ecx;
        yd            = yd_ini;
        wtxt          = 8*wx/5;
        pos_std_txt   = [xl yd wtxt Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_mad_txt   = [xl yd wtxt Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_madm_txt  = [xl yd wtxt Def_Btn_Height];
        %----------------------------------------------------------
        xl            = pos_std_txt(1)+pos_std_txt(3)+dx+ecx;
        yd            = yd_ini;
        wtxt          = 5*wx/5;
        pos_L1_txt    = [xl yd wtxt Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_L2_txt    = [xl yd wtxt Def_Btn_Height];

        yd            = yd-Def_Btn_Height-dy2;
        pos_LM_txt    = [xl yd wtxt Def_Btn_Height];       
        %----------------------------------------------------------
        wtxt          = 6.5*wx/5 ;
        pos_mean_val  = [ pos_mean_txt(1)+pos_mean_txt(3)   ,...
                          pos_mean_txt(2)                   ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_med_val   = [ pos_med_txt(1)+pos_med_txt(3)     ,...
                          pos_med_txt(2)                    ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_mode_val  = [ pos_mode_txt(1)+pos_mode_txt(3)   ,...
                          pos_mode_txt(2)                   ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_max_val   = [ pos_max_txt(1)+pos_max_txt(3)     ,...
                          pos_max_txt(2)                    ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_min_val   = [ pos_min_txt(1)+pos_min_txt(3)     ,...
                          pos_min_txt(2)                    ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_range_val = [ pos_range_txt(1)+pos_range_txt(3) ,...
                          pos_range_txt(2)                  ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_std_val   = [ pos_std_txt(1)+pos_std_txt(3)     ,...
                          pos_std_txt(2)                    ,...
                          wtxt                            ,...
                          Def_Btn_Height                    ];
        pos_mad_val   = [ pos_mad_txt(1)+pos_mad_txt(3)     ,...
                          pos_mad_txt(2)                    ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_madm_val  = [ pos_madm_txt(1)+pos_madm_txt(3)   ,...
                          pos_madm_txt(2)                   ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_L1_val   = [ pos_L1_txt(1)+pos_L1_txt(3)     ,...
                          pos_L1_txt(2)                    ,...
                          wtxt                            ,...
                          Def_Btn_Height                    ];
        pos_L2_val   = [ pos_L2_txt(1)+pos_L2_txt(3)     ,...
                          pos_L2_txt(2)                    ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];
        pos_LM_val  = [ pos_LM_txt(1)+pos_LM_txt(3)   ,...
                          pos_LM_txt(2)                   ,...
                          wtxt                              ,...
                          Def_Btn_Height                    ];                      

        % String property of objects.
        %----------------------------
        str_mean_txt  = getWavMSG('Wavelet:commongui:Str_mean_txt');
        str_med_txt   = getWavMSG('Wavelet:commongui:Str_med_txt');
        str_mode_txt  = getWavMSG('Wavelet:commongui:Str_mean_txt');
        str_max_txt   = getWavMSG('Wavelet:commongui:Str_max_txt');
        str_min_txt   = getWavMSG('Wavelet:commongui:Str_min_txt');
        str_range_txt = getWavMSG('Wavelet:commongui:Str_range_txt');
        str_std_txt   = getWavMSG('Wavelet:commongui:Str_std_txt');
        str_mad_txt   = getWavMSG('Wavelet:commongui:Str_mad_txt');
        str_madm_txt  = getWavMSG('Wavelet:commongui:Str_madm_txt');
        str_L1_txt    = getWavMSG('Wavelet:commongui:Str_L1_txt');
        str_L2_txt    = getWavMSG('Wavelet:commongui:Str_L2_txt');
        str_LM_txt    = getWavMSG('Wavelet:commongui:Str_LM_txt');

        % Frame Stats construction.
        %--------------------------
        txt_color = Def_FraBkColor;
        val_color = EdiBkColor;

        fra_utl = uicontrol('Parent',fig,...
            'Style','frame',...
            'Units',fig_units,...
            'Position',pos_fra,...
            'Visible','off',...
            'BackgroundColor',txt_color,...
            'Foregroundcolor',Def_ShadowColor,...
            'Tag',tag_sta_val ...
            );

        commonPropTxt = {...
             'Parent',fig,...
             'Style','Text',...
             'Units',fig_units,...
             'FontSize',uicFontSize, ...             
             'HorizontalAlignment','left',...
             'Visible','off',...
             'BackgroundColor',txt_color...
             };

        commonPropVal = {...
             'Parent',fig,...
             'Style','Edit',...
             'Units',fig_units,...
             'FontSize',uicFontSize, ...
             'HorizontalAlignment','center',...
             'Visible','off',...
             'Enable','inactive',...
             'BackgroundColor',val_color...
             };

        txt_mean_txt  = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_mean_txt,'String',str_mean_txt);
        txt_mean_val  = uicontrol(commonPropVal{:},'Position',pos_mean_val);

        txt_med_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_med_txt,'String',str_med_txt);
        txt_med_val   = uicontrol(commonPropVal{:},'Position',pos_med_val);

        txt_mode_txt  = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_mode_txt,'String',str_mode_txt);
        txt_mode_val  = uicontrol(commonPropVal{:},'Position',pos_mode_val);

        txt_max_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_max_txt,'String',str_max_txt);
        txt_max_val   = uicontrol(commonPropVal{:},'Position',pos_max_val);

        txt_min_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_min_txt,'String',str_min_txt);
        txt_min_val   = uicontrol(commonPropVal{:},'Position',pos_min_val);

        txt_range_txt = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_range_txt,'String',str_range_txt);
        txt_range_val = uicontrol(commonPropVal{:},'Position',pos_range_val);

        txt_std_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_std_txt,'String',str_std_txt);
        txt_std_val   = uicontrol(commonPropVal{:},'Position',pos_std_val);

        txt_mad_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_mad_txt,'String',str_mad_txt);
        txt_mad_val   = uicontrol(commonPropVal{:},'Position',pos_mad_val);

        txt_madm_txt  = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_madm_txt,'String',str_madm_txt);
        txt_madm_val  = uicontrol(commonPropVal{:},'Position',pos_madm_val);
        
        txt_L1_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_L1_txt,'String',str_L1_txt);
        txt_L1_val   = uicontrol(commonPropVal{:},'Position',pos_L1_val);

        txt_L2_txt   = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_L2_txt,'String',str_L2_txt);
        txt_L2_val   = uicontrol(commonPropVal{:},'Position',pos_L2_val);

        txt_LM_txt  = uicontrol(commonPropTxt{:}, ...
                            'Position',pos_LM_txt,'String',str_LM_txt);
        txt_LM_val  = uicontrol(commonPropVal{:},'Position',pos_LM_val);
        drawnow
        

        % Sets of handles.
        %-----------------
        ud.handles = [...
            fra_utl; ...
            txt_mean_txt; txt_med_txt; txt_mode_txt;  ...
            txt_max_txt ; txt_min_txt; txt_range_txt; ...
            txt_std_txt ; txt_mad_txt; txt_madm_txt;  ...
            txt_L1_txt  ; txt_L2_txt ; txt_LM_txt;    ...
            txt_mean_val; txt_med_val; txt_mode_val;  ...
            txt_max_val;  txt_min_val; txt_range_val; ...
            txt_std_val;  txt_mad_val; txt_madm_val;  ...
            txt_L1_val;   txt_L2_val;  txt_LM_val     ...
            ];
        set(fra_utl,'UserData',ud);
        if nargout>0
            varargout{1} = ud.handles;               
            varargout{2} = h_fra;
        end

    case 'display'
        val_handles = utstats('handles',fig,'val');
        tab_values  = varargin{1};
        tab_values(abs(tab_values)<eps) = 0;
        for k=1:length(val_handles)
            set(val_handles(k),'String',sprintf('%1.4g',tab_values(k)));
        end

    case 'handles'
        fra = findobj(fig,'Style','frame','Tag',tag_sta_val);
        ud  = get(fra,'UserData');
        varargout{1} = ud.handles;
        if ~isempty(varargin)
           type = varargin{1};
           switch type
             case 'all' 
             case 'val' , varargout{1}((1:13)) = [];
             case 'txt' , varargout{1}([1,14:end]) = [];
           end
        end 

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
