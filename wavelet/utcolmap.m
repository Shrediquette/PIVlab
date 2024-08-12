function varargout = utcolmap(option,fig,varargin)
%UTCOLMAP Wavelet colormap utilities.
%   VARARGOUT = UTCOLMAP(OPTION,FIG,VARARGIN)
%   option = 'create' or 'handles'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-98.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.6.4.14 $  $Date: 2013/07/05 04:30:27 $

% Tagged Objects.
%----------------
tag_col_par = 'Fra_ColPar';

switch option
    case {'Install_V3','Install_V3_CB','create'}
        % Default Values.
        %----------------
        min_nbcolors = 2;
        def_nbcolors = 128;

        % Defaults Inputs.
        %----------------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; yloc = Inf;
        ybottom = NaN;
        bkColor = NaN;
        briFlag = 1;
        enaVAL  = 'off';
        max_nbcolors = 256;

        % Parsing Inputs.
        %----------------        
        nbarg = nargin-2;
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
              case 'briflag' , briFlag = varargin{k+1};
              case 'enable'  , enaVAL  = varargin{k+1};
              case 'maxnbcol', max_nbcolors = varargin{k+1};
            end
        end
        
        switch option
            case 'Install_V3'
                % Get Handles.
                %-------------
                handles = guihandles(fig);
                Fra_ColPar  = handles.Fra_ColPar;
                Txt_NBC = handles.Txt_NBC;
                Edi_NBC = handles.Edi_NBC;
                Sli_NBC = handles.Sli_NBC;
                Txt_PAL = handles.Txt_PAL;
                Pop_PAL = handles.Pop_PAL;
                try
                    Txt_BRI   = handles.Txt_BRI; 
                    Pus_BRI_M = handles.Pus_BRI_M;
                    Pus_BRI_P = handles.Pus_BRI_P;
                catch %#ok<CTCH>
                    briFlag = false;
                end
                if ~briFlag
                    Txt_BRI = NaN;  Pus_BRI_M = NaN; Pus_BRI_P = NaN;
                end
                
            case 'create'
                % Temporary change of units.
                %---------------------------
                old_units  = get(fig,'Units');
                fig_units  = 'pixels';
                if ~isequal(old_units,fig_units), set(fig,'Units',fig_units); end  
                
                % Get globals.
                %-------------
                [...
                Def_Txt_Height,Def_Btn_Height,Def_Btn_Width, ...
                X_Spacing,Y_Spacing,sliYProp,~,Def_EdiBkColor,Def_ShadowColor] = ...
                    mextglob('get',...
                    'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                    'X_Spacing','Y_Spacing','Sli_YProp', ...
                    'Lst_ColorMap','Def_EdiBkColor','Def_ShadowColor'  ...
                    );
                
                % Positions utilities.
                %---------------------
                dx = X_Spacing; bdx = 3;
                dy = Y_Spacing; bdy = 4;        
                d_txt  = (Def_Btn_Height-Def_Txt_Height);
                deltaY = Def_Btn_Height+2;
                sli_hi = floor(Def_Btn_Height*sliYProp);
                sli_dy = 0.5*(Def_Btn_Height-sli_hi);
                
                % Defaults Inputs.
                %----------------
                if isnan(ybottom)
                    pos_close = wfigmngr('get',fig,'pos_close');
                    if ~isempty(pos_close)
                        ybottom = pos_close(2)+pos_close(4)+2*dy;
                    end
                end
                if isnan(bkColor) , bkColor = mextglob('get','Def_FraBkColor'); end
                
                % Setting frame position.
                %------------------------                
                w_fra   = mextglob('get','Fra_Width');
                h_fra   = Def_Btn_Height+(1+briFlag)*deltaY+1.3*bdy; %2*bdy high DPI
                xleft   = utposfra(xleft,xright,xloc,w_fra);
                ybottom = utposfra(ybottom,ytop,yloc,h_fra);
                pos_fra = [xleft,ybottom,w_fra,h_fra];
                
                % String property of objects.
                %----------------------------
                str_txt_pal = getWavMSG('Wavelet:commongui:Str_PAL');
                str_txt_nbc = getWavMSG('Wavelet:commongui:Str_NBC');
                str_pop_pal = wtranslate('lstcolormap');
                str_edi_nbc = sprintf('%.0f',size(get(fig,'Colormap'),1));
                if briFlag , str_txt_bri = getWavMSG('Wavelet:commongui:Str_BRI'); end
                
                % Position property of objects.
                %------------------------------
                wBASE = 1.1*Def_Btn_Width;  %high DPI 1.3
                while (2.5*wBASE>w_fra) , wBASE = wBASE-0.01; end
                xleft          = xleft+bdx;
                ylow           = ybottom+h_fra-Def_Btn_Height-bdy;               
                pos_txt_pal    = [xleft,ylow+d_txt/2,wBASE,Def_Txt_Height];
                pos_pop_pal    = [xleft,ylow,wBASE,Def_Btn_Height];
                pos_pop_pal(1) = pos_pop_pal(1)+pos_txt_pal(3);
                ylow           = ylow-deltaY;
                
                pos_txt_nbc    = pos_txt_pal;
                pos_txt_nbc(2) = pos_txt_nbc(2)-deltaY;
                xl             = pos_txt_nbc(1)+pos_txt_nbc(3);
                pos_sli_nbc    = [xl, ylow+sli_dy, Def_Btn_Width, sli_hi];
                xl             = pos_sli_nbc(1)+pos_sli_nbc(3)+dx;
                pos_edi_nbc    = [xl, ylow, wBASE/2, Def_Btn_Height];
                if briFlag
                    ylow           = ylow-deltaY;
                    pos_txt_bri    = pos_txt_nbc;
                    pos_txt_bri(2) = pos_txt_bri(2)-deltaY;
                    xl             = pos_txt_bri(1)+pos_txt_bri(3);
                    pos_p_M_bri    = [xl, ylow, wBASE/2, Def_Btn_Height];
                    xl             = xl+wBASE/2;
                    pos_p_P_bri    = [xl, ylow, wBASE/2, Def_Btn_Height];
                end
                
                % Create objects.
                %----------------
                Fra_ColPar = uicontrol('Parent',fig, ...
                    'Style','frame', ...
                    'Units',fig_units, ...
                    'Position',pos_fra, ...
                    'BackgroundColor',bkColor, ...
                    'ForegroundColor',Def_ShadowColor,  ...
                    'Tag',tag_col_par, ...
                    'TooltipString',getWavMSG('Wavelet:commongui:Lab_CMapSet') ...
                    );
                
                Txt_PAL = uicontrol('Parent',fig,...
                    'Style','Text',...
                    'Units',fig_units,...
                    'Position',pos_txt_pal,...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',bkColor,...
                    'Tag','Txt_PAL',...                                                                                
                    'String',str_txt_pal...
                    );
                
                Pop_PAL = uicontrol('Parent',fig,...
                    'Style','Popup',...
                    'Units',fig_units,...
                    'Position',pos_pop_pal,...
                    'String',str_pop_pal,...
                    'Tag','Pop_PAL',...                                                            
                    'Enable',enaVAL...
                    );
                
                Txt_NBC = uicontrol('Parent',fig,...
                    'Style','Text',...
                    'Units',fig_units,...
                    'Position',pos_txt_nbc,...
                    'HorizontalAlignment','left',...
                    'BackgroundColor',bkColor,...
                    'Tag','Txt_NBC',...                                        
                    'String',str_txt_nbc...
                    );
                
                Sli_NBC = uicontrol('Parent',fig,...
                    'Style','Slider',...
                    'Units',fig_units,...
                    'Position',pos_sli_nbc,...
                    'Min',min_nbcolors,...
                    'Max',max_nbcolors,...
                    'Value',def_nbcolors,...
                    'Tag','Sli_NBC',...                    
                    'Enable',enaVAL...
                    );
                
                Edi_NBC = uicontrol('Parent',fig,...
                    'Style','Edit',...
                    'Units',fig_units,...
                    'BackgroundColor',Def_EdiBkColor,...
                    'Position',pos_edi_nbc,...
                    'String',str_edi_nbc,...
                    'Tag','Edi_NBC',...
                    'Enable',enaVAL ...
                );
                              
                if briFlag
                    Txt_BRI = uicontrol('Parent',fig,...
                        'Style','Text',...
                        'Units',fig_units,...
                        'Position',pos_txt_bri,...
                        'HorizontalAlignment','left',...
                        'BackgroundColor',bkColor,...
                        'Tag','Txt_BRI',...
                        'String',str_txt_bri...
                        );
                    
                    Pus_BRI_M = uicontrol('Parent',fig,...
                        'Style','pushbutton',...
                        'String','-',...
                        'Units',fig_units,...
                        'FontSize',12,...
                        'FontWeight','bold',...
                        'Position',pos_p_M_bri,...
                        'Tag','Pus_BRI_M',...
                        'Enable',enaVAL ...
                    );
                    
                    Pus_BRI_P = uicontrol('Parent',fig,...
                        'Style','pushbutton',...
                        'String','+',...
                        'Units',fig_units,...
                        'FontSize',12,...
                        'FontWeight','bold',...
                        'Position',pos_p_P_bri,...
                        'Tag','Pus_BRI_P',...                        
                        'Enable',enaVAL ...
                    );
                else
                    Txt_BRI = NaN;  Pus_BRI_M = NaN; Pus_BRI_P = NaN;
                end
                if ~isequal(old_units,fig_units)
                    set([fig;ud.handles],'Units',old_units); %#ok<NODEF>
                end       
                drawnow;        
        end
        
        % Callbacks update.
        %------------------
        switch option
            case {'Install_V3'} 
            case {'Install_V3_CB','create'}

                cba_pop_pal = @(~,~)cbcolmap('pal', fig);
                cba_edi_nbc = @(~,~)cbcolmap('nbc', fig, Edi_NBC);
                cba_sli_nbc = @(~,~)cbcolmap('nbc', fig, Sli_NBC);
                set(Pop_PAL,'Callback',cba_pop_pal);
                set(Edi_NBC,'Callback',cba_edi_nbc);
                set(Sli_NBC,'Callback',cba_sli_nbc);
                if briFlag
                    cba_p_M_bri = @(~,~)cbcolmap('bri',fig,-1);
                    set(Pus_BRI_M,'Callback',cba_p_M_bri);
                    cba_p_P_bri = @(~,~)cbcolmap('bri',fig,+1);
                    set(Pus_BRI_P,'Callback',cba_p_P_bri);
                end
        end
        
        % Store Handles.
        %----------------
        ud.handles = {Fra_ColPar; ...
                Txt_PAL;Pop_PAL;Txt_NBC;Sli_NBC;Edi_NBC; ...
                Txt_BRI;Pus_BRI_M;Pus_BRI_P};
        set(Fra_ColPar,'UserData',ud);
        
        if nargout>0
            varargout{1} = {Pop_PAL,Sli_NBC,Edi_NBC,Pus_BRI_M,Pus_BRI_P};
            varargout{2} = {Fra_ColPar,Txt_PAL,Txt_NBC,Txt_BRI};
        end

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		wfighelp('add_ContextMenu',fig,ud.handles,'UT_COLMAP');
		%-------------------------------------
        
    case 'handles'
        fra = wfindobj(fig,'Tag',tag_col_par);
        ud  = get(fra,'UserData');
        handles = ud.handles;
        nbarg = length(varargin);
        idx = 0;
        for k=1:length(handles)
            tmp = handles{k};
            if ishandle(tmp)
                idx = idx + 1;
                OUT{idx,1} = tmp;
            end
        end
        switch nbarg
            case 0 , varargout = {OUT};
            case 1
                type = varargin{1};
                switch type
                    case 'cell' , varargout{1} = cat(1,OUT{:});
                    case 'act'  , varargout = handles([3 5 6 8 9]);
                    % [Pop_PAL,Sli_NBC,Edi_NBC,Pus_BRI_M,Pus_BRI_P] 
                    case 'all'  , varargout = handles;
                end
        end        
        
    case 'position'
        fra = findobj(fig,'Style','frame','Tag',tag_col_par);
        varargout = get(fra,{'Position','Units'});

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
