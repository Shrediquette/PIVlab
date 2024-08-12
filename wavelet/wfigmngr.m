function varargout = wfigmngr(option,varargin)
%WFIGMNGR Wavelet Toolbox Utilities for creating figures.
%   VARARGOUT = WFIGMNGR(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Copyright 1995-2020 The MathWorks, Inc.


% Tool Memory Block.
%-------------------
n_toolMemB  = 'Tool_Params';

% Tag property of objects.
%------------------------
tag_m_files = 'figMenuFile';
tag_cmd_frame = 'Cmd_Frame';

% Test inputs.
%-------------
if nargin==0
    fig = gcf;
    option  = 'extfig';
elseif ~ischar(option)
    fig     = option;
    option  = 'extfig';
elseif strcmp(option,'extfig')
    if nargin<2
        fig = gcf;
    else
        fig = varargin{1};
    end
end

switch option
    case 'getmenus'
        %***********************************************************%
        %** OPTION = 'getmenus' : get the handles of main menus.  **%
        %***********************************************************%
        fig = varargin{1};
        if ~ishandle(fig) , fig = gcbf; end
        lst_Main = findall(fig,'Type','uimenu','Parent',fig);
		m_files  = findall(lst_Main,'Tag',tag_m_files);
		nbIn = length(varargin);
        if nbIn==1
            varargout{1} = m_files;
            varargout{2} = lst_Main;
            return
        end

		% Search in menu Files First.
		%----------------------------
        varargout = cell(1,nbIn-1);
        for k = 2:nbIn
            menuName = lower(varargin{k});
            switch menuName
                case 'file'  , tag = 'figMenuFile';
                case 'load'  , tag = 'figMenuLoad';
                case 'save'  , tag = 'figMenuSave';
                case 'close' , tag = 'figMenuClose';
                case 'view'  , tag = 'figMenuView';
                case 'help'  , tag = 'figMenuHelp';
            end
            varargout{k-1} = findall(fig,'Type','uimenu','Tag',tag);
        end

    case 'init'
        %*************************************************************%
        %** OPTION = 'init' :  init a figure - with default values  **%
        %*************************************************************%
        % varargin contains figure properties.
        %-------------------------------------      

        % Get Globals.
        %-------------
        [...
        Def_FigColor,Def_DefColor,                      ...
        Def_AxeXColor,Def_AxeYColor,Def_AxeZColor,      ...
        Def_UicFontSize, ...
        Def_AxeFontSize,Def_TxtColor,Def_TxtFontSize,   ...
        Def_UicFtWeight,Def_AxeFtWeight,Def_TxtFtWeight,...
        Def_FraBkColor] = ...
            mextglob('get',...
                'Def_FigColor','Def_DefColor',...
                'Def_AxeXColor','Def_AxeYColor','Def_AxeZColor',        ...
                'Def_UicFontSize', ...
                'Def_AxeFontSize','Def_TxtColor','Def_TxtFontSize',     ...
                'Def_UicFtWeight','Def_AxeFtWeight','Def_TxtFtWeight',  ...
                'Def_FraBkColor'                                        ...
                );
        varargout{1} = colordef('new',Def_DefColor);
        set(varargout{1},'WindowStyle','Normal');
        figProperties = {...
            'IntegerHandle','On', ...
            'MenuBar','none',...
            'DefaultUicontrolBackgroundcolor',Def_FraBkColor,...
            'DefaultUicontrolFontSize',Def_UicFontSize, ...
            'DefaultUicontrolFontWeight',Def_UicFtWeight,...
            'DefaultAxesFontWeight',Def_AxeFtWeight,...
            'DefaultTextFontWeight',Def_TxtFtWeight,...
            'Color',Def_FigColor,...
            'NumberTitle','Off',...
            'DefaultAxesFontSize',Def_AxeFontSize,...
            'DefaultAxesXColor',Def_AxeXColor,...
            'DefaultAxesYColor',Def_AxeYColor,...
            'DefaultAxesZColor',Def_AxeZColor,...
            'DefaultTextColor',Def_TxtColor,...
            'DefaultTextFontSize',Def_TxtFontSize,...
            'Name','',...
            'Visible','On',...
            'Position',get(0,'DefaultFigurePosition'),...
            'Units',get(0,'DefaultFigureUnits'),...
            'WindowStyle','Normal', ...
            varargin{:}  ...
            }; %#ok<CCAT>

        set(varargout{1}, figProperties{:});
        s = dbstack; defineWfigPROP(varargout{1},s)

    case 'init_called_FIG'
        called_FIG = varargin{1};
        % set(varargout{1}, figProperties{:});
        s = dbstack; defineWfigPROP(called_FIG,s)

    case 'beg_GUIDE_FIG'
        fig = varargin{1};
        wfigmngr('extfig',fig,'ExtFig_GUIDE')
        wfigmngr('attach_close',fig);
        
        % Get Globals.
        %-------------
        [...
        Def_FigColor,Def_AxeColor,                      ...
        Def_AxeXColor,Def_AxeYColor,Def_AxeZColor,      ...
        Def_UicFontSize, ...
        Def_AxeFontSize,Def_TxtColor,Def_TxtFontSize,   ...
        Def_UicFtWeight,Def_AxeFtWeight,Def_TxtFtWeight,...
        Def_FraBkColor,Def_ShadowColor] = ...
            mextglob('get',...
                'Def_FigColor','Def_AxeColor',...
                'Def_AxeXColor','Def_AxeYColor','Def_AxeZColor',        ...
                'Def_UicFontSize', ...
                'Def_AxeFontSize','Def_TxtColor','Def_TxtFontSize',     ...
                'Def_UicFtWeight','Def_AxeFtWeight','Def_TxtFtWeight',  ...
                'Def_FraBkColor','Def_ShadowColor'     ...
                );
        figProperties = {...
            'DefaultUicontrolBackgroundcolor',Def_FraBkColor,...
            'DefaultUicontrolFontSize',Def_UicFontSize, ...
            'DefaultUicontrolFontWeight',Def_UicFtWeight,...
            'DefaultAxesFontWeight',Def_AxeFtWeight,...
            'DefaultTextFontWeight',Def_TxtFtWeight,...
            'Color',Def_FigColor,...
            'NumberTitle','Off',...
            'DefaultAxesFontSize',Def_AxeFontSize,...
            'DefaultAxesColor',Def_AxeColor,...
            'DefaultAxesXColor',Def_AxeXColor,...
            'DefaultAxesYColor',Def_AxeYColor,...
            'DefaultAxesZColor',Def_AxeZColor,...
            'DefaultTextColor',Def_TxtColor,...
            'DefaultTextFontSize',Def_TxtFontSize...
            };
        axesProperties = {...
            'Color',Def_AxeColor,...
            'FontWeight',Def_AxeFtWeight,...
            'FontSize',Def_AxeFontSize,...
            'XColor',Def_AxeXColor,...
            'YColor',Def_AxeYColor,...
            'ZColor',Def_AxeZColor,...
            'DefaultTextFontWeight',Def_TxtFtWeight,...
            'DefaultTextColor',Def_TxtColor,...
            'DefaultTextFontSize',Def_TxtFontSize...
            };
        set(fig,figProperties{:});
        axesInFig = findobj(fig,'Type','axes');
        set(axesInFig,axesProperties{:})
        frameInFig = findobj(fig,'Style','frame');
        set(frameInFig,'ForegroundColor',Def_ShadowColor);
        panInFig = findobj(fig,'Type','uipanel');
        set(panInFig,'ShadowColor',Def_ShadowColor);
        set(fig,'HandleVisibility','On')
        % set(varargout{1}, figProperties{:});
        % s = dbstack; defineWfigPROP(varargout{1},s)
        
    case 'end_GUIDE_FIG'
        fig = varargin{1};
        toolName = varargin{2};
        wtranslate(toolName,fig); 
        if length(varargin)<3 
            redimfig('On',fig);
            wfigmngr('set_WTBX_Fig_POS',fig);
        end
        wfigmngr('set_FigATTRB',fig,toolName);
        set(fig,'HandleVisibility','Callback')
        tag_msg = 'Txt_Message';
        txt_msg = findobj(fig,'Style','text','Tag',tag_msg);
        if ~isempty(txt_msg)
            BkColor = mextglob('get','Def_MsgBkColor');
            set(txt_msg,'BackgroundColor',BkColor)
        end
        
    case 'attach_close'
        %******************************************************%
        %** OPTION = 'attach_close' :  attach close function **%
        %******************************************************%
        % in2 = fig
        % in3 = funct name (optional)
        % in4 = conditional closing (optional)
        %-------------------------------------
        fig     = varargin{1};
        m_close = wfigmngr('getmenus',fig,'close');
        set(m_close,'Interruptible','on');
        oldCallBack = get(m_close,'Callback');

        varargout{1} = @(~,~)appendClose(oldCallBack, varargin{:});

        set(m_close,'Callback',varargout{1});
        set(fig,'CloseRequestFcn',varargout{1})

    case 'close'
        fig = varargin{1};
        if ishandle(fig)
            figChild = wfigmngr('getWinPROP',fig,'FigChild');
            figChild = figChild(ishandle(figChild));
            for k = 1:length(figChild)
                try
                    hgfeval(figChild(k).CloseRequestFcn);

                    if ishandle(figChild(k))
                        delete(figChild(k));
                    end
                catch ME  %#ok<NASGU>
                end
            end
            FigParent = wfigmngr('getWinPROP',fig,'FigParent');
            if ishandle(FigParent)
                WP = wfigmngr('getWinPROP',FigParent);
                if ~isempty(WP)
                    WP.FigChild = setdiff(WP.FigChild,fig);
                    wtbxappdata('set',FigParent,'WfigPROP',WP);
                end
            end
        else
            [obj,fig] = gcbo; %#ok<ASGLU>
            delete(fig);
        end

    case 'extfig'
        %******************************************%
        %** OPTION = 'extfig' :figure extension  **%
        %******************************************%
        set(fig,'IntegerHandle','On');
        m_file =  wfindobj(fig,'type','uimenu','Tag',tag_m_files);
        delete(m_file);
		createMenus(fig,varargin{2:end});

    case 'create'
        %******************************************%
        %** OPTION = 'create' :  create a window **%
        %******************************************%
        % in2 = win_name
        % in3 = color (1...8)
        % in4 = extmode (number or strmat)
        %   
        % in5 = closemode (strmat)
        %   if size(in5,1) = 2 , conditional close
        %-----------------------------------------
        % in6 = flag dynvisu   (optional)
        % in7 = flag close btn (optional)
        % in8 = flag txttitl   (optional)
        %-----------------------------------------
        % out1 = win_hld
        % out2 = frame_hdl
        % out3 = graphic_area
        % out4 = pus_close
        %-------------------------
        nbin = length(varargin);
        
        % Defaults Values
        %-----------------
        figName     = '';
        extMode     = '';
        closeMode   = '';
        flgDynV     = 1;
        flgCloseBtn = 1;
        flgTitle    = 1;

        switch nbin
            case 1 , figName = varargin{1};
            case 2 , [figName,valColor] = deal(varargin{:});         %#ok<ASGLU>
            case 3 , [figName,valColor,extMode] = deal(varargin{:}); %#ok<ASGLU>
            case 4 , [figName,valColor,extMode,closeMode] = deal(varargin{:}); %#ok<ASGLU>
            case 5 , [figName,valColor,extMode,closeMode,...
                      flgDynV] = deal(varargin{:});             %#ok<ASGLU>
            case 6 , [figName,valColor,extMode,closeMode,...
                      flgDynV,flgCloseBtn] = deal(varargin{:}); %#ok<ASGLU>
            case 7 , [figName,valColor,extMode,closeMode,...
                      flgDynV,flgCloseBtn,flgTitle] = deal(varargin{:}); %#ok<ASGLU>
        end

        % Get Globals.
        %-------------
        [...
        Def_Btn_Height,X_Graph_Ratio,X_Spacing,Y_Spacing,...
        Def_FraBkColor,ediInActBkColor,Def_ShadowColor] = ...
            mextglob('get',...
                'Def_Btn_Height','X_Graph_Ratio', ...
                'X_Spacing','Y_Spacing',          ...
                'Def_FraBkColor','Def_Edi_InActBkColor','Def_ShadowColor' ...
                );

        % Creating extended figure.
        %--------------------------
        win_units = 'pixels';
        [pos_win,win_width,win_height,cmd_width] = wfigmngr('figsizes'); %#ok<ASGLU>
        win_hld   = wfigmngr('init', ...
            'Name',figName,...
            'Units',win_units,...
            'Position',pos_win, ...
            'Visible','Off' ...
            );

        % Figure Extension (add menus).
        %-----------------------------
        if ~isempty(extMode) , wfigmngr('extfig',win_hld,extMode); end
        s = dbstack; defineWfigPROP(win_hld,s,'replace')
        if ~isempty(closeMode)
            if ~iscell(closeMode)   % OLD Version
                namefunc = deblank(closeMode(1,:));
                flagCOND = size(closeMode,1)>1;
            else
                namefunc = closeMode{1};
                flagCOND = length(closeMode)>1;
            end
            if flagCOND
                cba_close = wfigmngr('attach_close',win_hld,namefunc,'cond');
            else
                cba_close = wfigmngr('attach_close',win_hld,namefunc);
            end
            
        else
            cba_close = wfigmngr('attach_close',win_hld);   
        end
        x_frame   = pos_win(3)-cmd_width+1;
        pos_frame = [x_frame,0,cmd_width,pos_win(4)+5];
        frame_hdl = uicontrol(...
            'Parent',win_hld,               ...
            'Style','frame',                ...
            'Units',win_units,               ...
            'Position',pos_frame,           ...
            'BackgroundColor',Def_FraBkColor, ...
            'ForegroundColor',Def_ShadowColor,  ...            
            'Tag',tag_cmd_frame             ...
            );
        drawnow;

        if flgDynV
            % Dynamic visualization tool.
            %----------------------------
            pos_dyn_visu = dynvtool('create',win_hld,X_Graph_Ratio);
            ylow = pos_dyn_visu(4);
            pos_gra = [0,pos_dyn_visu(4),x_frame,pos_win(4)-ylow];
        else
            pos_gra = [0,0,x_frame,pos_win(4)];
        end
        if flgCloseBtn
           % Close Button.
           %--------------
            push_width  = (cmd_width-4*X_Spacing)/2;
            xl = x_frame+(cmd_width-7*push_width/4)/2;
            yl = pos_frame(2)+2*Y_Spacing;
            wi = 7*push_width/4;
            scrSize = getMonitorSize;
            if scrSize(4)<700
                he = Def_Btn_Height; 
            else
                he = 3*Def_Btn_Height/2;
            end
            pos_close = [xl , yl , wi , he/1.5]; %he/2 High DPI  
            pus_close = uicontrol(...
                'Parent',win_hld,    ...
                'Style','pushbutton',...
                'Units',win_units,    ...
                'Position',pos_close,...
                'String',getWavMSG('Wavelet:wfigmngr:figMenuClose'), ...
                'Interruptible','on',...
                'UserData',0,        ...
                'Callback',cba_close,...
                'Tag','Pus_Close_Win', ...
                'TooltipString',getWavMSG('Wavelet:wfigmngr:CloseWin')...
                );
        else
            pus_close = [];
        end
        wfigmngr('storeValue',win_hld,'pus_close',pus_close);

        if flgTitle
            % Figure Title.
            %--------------
            wfigtitl('set',win_hld,X_Graph_Ratio,'','off',ediInActBkColor);
            pos_gra(4) = pos_gra(4)-Def_Btn_Height;
        end

        % Waiting Text construction.
        %---------------------------
        wwaiting('create',win_hld,X_Graph_Ratio);

        switch nargout
            case 1 , varargout = {win_hld};
            case 4 , varargout = {win_hld,frame_hdl,pos_gra,pus_close};
            otherwise
                varargout = {...
                    win_hld,pos_win,win_units,handle2str(win_hld), ...
                    pos_frame,pos_gra,pus_close,frame_hdl...
                    };
        end
        
        % Set WindowButtonMotionFcn for special cases.
        %---------------------------------------------
        if isequal(extMode,'ExtFig_CompDeno') || ...
                isequal(extMode,'ExtFig_Tool_1') || ...
                isequal(extMode,'ExtFig_WTMOTION')
            ax = wfindobj(win_hld,'Type','axes');
        	set(win_hld,'WindowButtonMotionFcn',wtmotion(ax));
        end

        drawnow

    case 'normalize'
        %************************************************%
        %** OPTION = 'normalize' :  normalize a window **%
        %************************************************%
        % varargin{1} = win_hdl
        % varargin{2} = pos_gra (optional)
        % varargin{3} = Visibility
        %----------------------------------
        % out1 = pos_gra (optional)
        fig = varargin{1};
        pos_win = get(fig,'Position');
        if nargin>2
            varargout{1} = varargin{2}./[pos_win(3:4),pos_win(3:4)];
        end
        hdl = [wfindobj(fig,'Units','pixels');wfindobj(fig,'Units','data')];
        unchanged = findall(hdl,'type','uicontrol','style','text','handlevisibility','off');
        hdl = setdiff(hdl,unchanged);
        set(hdl,'Units','normalized');

        % Resizing the Figure.
        %---------------------
        if ~isequal(get(0,'DefaultFigureWindowStyle'),'docked')
            RatScrPixPerInch = wtbxmngr('get','ResizeRatioWTBX_Fig');
            if ~isequal(RatScrPixPerInch,1.0)
                pos_winNOR = get(fig,'Position');
                pos_winNEW = RatScrPixPerInch*pos_winNOR;
                DeltaDIM = pos_winNEW-pos_winNOR;
                pos_win = [pos_winNOR(1:2)-DeltaDIM(3:4),pos_winNEW(3:4)];
                set(fig,'Position',pos_win);
            end
        end

        if ispc
            pop = wfindobj(fig,'Style','pop');
            sli = wfindobj(fig,'Style','slider');
            set(pop,'BackgroundColor','w')
            set(sli,'BackgroundColor',0.9*[1 1 1])
        end
        if length(varargin)>2
            vis = varargin{3};
        else
            vis = get(fig,'Visible');
        end

        set(fig,'Visible',vis);
        %%%--------------------------------%%%

    case 'handlevis'
        %***************************************************************%
        %** OPTION = 'handlevis' :  set HandleVisibility for a window **%
        %***************************************************************%
        % in2 = win_hdl
        % in3 = handleVisibility value
        %------------------------------
        fig    = varargin{1};
        flgVis = lower(varargin{2});
        switch flgVis
          case {'on','off','Callback'}
            set(fig,'HandleVisibility',flgVis);
          otherwise
            errargt(mfilename,...
                getWavMSG('Wavelet:moreMSGRF:Invalid_Val_HdlVis'),'msg');
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end

    case 'get_activeHDL'
        % in2 = win_hdl
        % in3 = type
        %---------------
        fig  = varargin{1};
        type = varargin{2};
        switch type
            case 'uimenu'
                m0 = findall(get(fig,'Children'),'flat','Type','uimenu');
                m1 = findall(m0,'Tag',tag_m_files);
                m0(m0==m1) = [];
                c1 = findall(m1,'Parent',m1);
                p1 = get(c1,'Position');
                p1 = cat(1,p1{:});
                [nul,I1] = sort(p1); %#ok<ASGLU>
                n  = length(I1);
                I1 = I1(n-2:n);
                varargout{1} = [findall(m0) ; m1; c1(I1)];

            case 'close'
                cba  = get(fig,'CloseRequestFcn');
                varargout{1} = wfindobj(fig,'Style','pushbutton','Callback',cba);
                varargout{2} = wfindobj(fig,'Type','uimenu','Callback',cba);
        end

    case 'figsizes'
        [Win_Position,Cmd_Width] = ...
            mextglob('get','Win_Position','Cmd_Width');
        varargout = {Win_Position , ...
            Win_Position(3) , Win_Position(4) , Cmd_Width};

    case 'dynv'
        %**************************************%
        %** OPTION = 'dynv' :  dynv ON /OFF  **%
        %**************************************%
        % in2 = fig
        %------------------------------------------
        fig    = varargin{1};
        menu   = gcbo;
        oldVal = get(menu,'checked');
        switch oldVal
          case 'on'  , newVal = 'off';
          case 'off' , newVal = 'on';
        end
        set(menu,'Checked',newVal);
        dynvtool('visible',fig,newVal)

	case {'storeValue','storevalue'}
        % varargin{2} = name
        % varargin{3} = value
        %--------------------
        fig  = varargin{1};
        memB = wfigmngr('rmb',fig);
        memB.(varargin{2}) = varargin{3};
        wfigmngr('wmb',fig,memB);
        if nargout>0 , varargout = {memB}; end

    case {'getValue','getvalue'}
        fig  = varargin{1};
        memB = wfigmngr('rmb',fig);
        try
            varargout{1} = memB.(varargin{2});
        catch ME  %#ok<NASGU>
            varargout{1} = [];
        end

    case 'getWinPROP'
        fig = varargin{1};
        nbarg = length(varargin);
        wfigPROP = wtbxappdata('get',fig,'WfigPROP');        
        if nbarg<2 , varargout{1} = wfigPROP; return; end
        notEmpty = ~isempty(wfigPROP);             
        for k = 2:nbarg
           outType = lower(varargin{k});
           switch outType
             case {'makefun','calledfun'}
               if notEmpty
                   varargout{k-1} = wfigPROP.MakeFun; %#ok<*AGROW>
               else
                   varargout{k-1} = wdumfun;
               end

             case 'figparent'
               if notEmpty
                   varargout{k-1} = wfigPROP.FigParent;
               else
                   varargout{k-1} = [];
               end

             case 'figchild'
               if notEmpty
                   varargout{k-1} = wfigPROP.FigChild;
               else
                   varargout{k-1} = [];
               end
           end
        end

    case 'get'
        fig  = varargin{1};
        nbarg = length(varargin);
        if nbarg<2 , return; end
        for k = 2:nbarg
           outType = lower(varargin{k});
           switch outType
             case 'pos_close'
               pus_close = wfigmngr('getValue',fig,'pus_close');
               if isempty(pus_close)
                   varargout{k-1} = [];
               else
                   varargout{k-1} = get(pus_close,'Position');
               end
             case 'cmd_width' 
                 varargout{k-1} = mextglob('get','Cmd_Width');
             case 'fra_width' 
                 varargout{k-1} = mextglob('get','Fra_Width');
           end
        end

    case 'cmb'
        %***********************************************%
        %** OPTION = 'cmb' - create Tool Memory Block **%
        %***********************************************%
        fig = varargin{1};
        wmemtool('ini',fig,n_toolMemB,1);

    case 'wmb'
        %**********************************************%
        %** OPTION = 'wmb' - write Tool Memory Block **%
        %**********************************************%
        fig = varargin{1};
        varargout{1} = wmemtool('wmb',fig,n_toolMemB,1,varargin{2});

    case 'rmb'
        %*********************************************%
        %** OPTION = 'rmb' - read Tool Memory Block **%
        %*********************************************%
        fig = varargin{1};
        varargout{1} = wmemtool('rmb',fig,n_toolMemB,1);

	case 'add_CCM_Menu'	
        fig  = varargin{1};		
        m_view = wfigmngr('getmenus',fig,'view');
        m_disp = uimenu(m_view,...
			'Label',getWavMSG('Wavelet:wfigmngr:CCM'), ...
			'Separator','On' ...
			);
        m_sub(1) = uimenu(m_disp,...
					'Label',getWavMSG('Wavelet:wfigmngr:CCMabs'), ...
                    'Checked','On','Tag','CCMabs');
        m_sub(2) = uimenu(m_disp,...
					'Label',getWavMSG('Wavelet:wfigmngr:CCMnor'), ...
                    'Checked','Off','Tag','CCMnor');
		set(m_sub,'UserData',m_sub,'Callback',@cb_Default_Color_Mode);

	case 'get_CCM_Menu'
        fig  = varargin{1};
        m_view = wfigmngr('getmenus',fig,'view');
        if isequal(m_view,0) || isempty(m_view)
            varargout{1} = 1;
            return;
        end
		m_CCM = [wfindobj(m_view,'Tag','CCMabs');...
            wfindobj(m_view,'Tag','CCMnor')];
        chk = get(m_CCM,'Checked');
        idx = find(strcmpi(chk,'on'));
		switch idx 
            case 1 , varargout{1} = 1;
			case 2 , varargout{1} = 0;
		end
        
    case 'modify_FigChild'
        fig = varargin{1};
        wfigPROP = wtbxappdata('get',fig,'WfigPROP');
        wfigPROP.FigChild = unique([wfigPROP.FigChild,varargin{2}]);
        idx = ~ishandle(wfigPROP.FigChild);
        wfigPROP.FigChild(idx) = [];
        wtbxappdata('set',fig,'WfigPROP',wfigPROP);
        
    case 'set_FigATTRB'
        fig = varargin{1};
        attrb_MODE = varargin{2};
        UICInFig = findall(fig,'Type','uicontrol');
        UICInFig =  UICInFig(strcmp(get(UICInFig,'HandleVisibility'),'on'));        
        PanelInFig = findall(fig,'Type','uipanel');
        WTBX_Preferences = mextglob('get','WTBX_Preferences');
        figColor   = WTBX_Preferences.figColor;
        fraBkColor = WTBX_Preferences.fraBkColor;
        ediActBkColor = WTBX_Preferences.ediActBkColor;
        ediInActBkColor = WTBX_Preferences.ediInActBkColor;
        shadowColor = WTBX_Preferences.shadowColor;
        set(fig,'Color',figColor);
        set(UICInFig,...
            'FontUnits','points',...
            'FontSize',WTBX_Preferences.uicFontSize,...
            'FontWeight',WTBX_Preferences.uicFontWeight);
        switch attrb_MODE
            case 'wavemenu'
                TextInPan = findall(PanelInFig,'Style','text');
                StrTXT = get(TextInPan,'String');
                idx = strcmp(StrTXT,'');
                TextInPan = TextInPan(~idx);
                Pan_Text_Color = figColor.^1.15;
                %--------------------------------------
                % Compatibility with previous Version
                % if WTBX_Preferences.oldPrefDef
                %    Pan_Text_Color = (fraBkColor).^2.5;
                %    set(fig,'Color',fraBkColor);
                % end
                %--------------------------------------
                set(UICInFig,'Units','Pixels');
                set(PanelInFig,'BackgroundColor',Pan_Text_Color,...
                    'ForegroundColor',shadowColor);
                set(TextInPan, ...
                    'BackgroundColor',Pan_Text_Color, ...
                    'FontWeight',WTBX_Preferences.panFontWeight);
                if ~strncmpi(get(0, 'language'), 'ja', 2)
                    set(TextInPan, 'FontName',WTBX_Preferences.panFontName);
                end
                if isunix
                    PusInFig = findall(UICInFig,'Style','pushbutton');
                    set(PusInFig,'BackgroundColor',ediInActBkColor);
                end
                set(UICInFig,'Units','Normalized');
            
            case {'wavemenu_OLD','wavedemo'}
                TextInPan = findall(PanelInFig,'Style','text');
                StrTXT = get(TextInPan,'String');
                idx = strcmp(StrTXT,'');
                TextInPan = TextInPan(~idx);
                Pan_Text_Color = figColor;
                %--------------------------------------
                % Compatibility with previous Version
                if WTBX_Preferences.oldPrefDef
                    Pan_Text_Color = fraBkColor;
                    set(fig,'Color',fraBkColor);
                end
                %--------------------------------------
                set(UICInFig,'Units','Pixels');
                set(PanelInFig,'BackgroundColor',Pan_Text_Color);
                set(TextInPan, ...
                    'BackgroundColor',Pan_Text_Color, ...
                    'FontWeight',WTBX_Preferences.panFontWeight);
                if ~strncmpi(get(0, 'language'), 'ja', 2)
                    set(TextInPan, 'FontName',WTBX_Preferences.panFontName);
                end
                if isunix
                    PusInFig = findall(UICInFig,'Style','pushbutton');
                    set(PusInFig,'BackgroundColor',ediInActBkColor);
                end
                set(UICInFig,'Units','Normalized');
                if isequal(attrb_MODE,'wavemenu')
                    txtColor = WTBX_Preferences.panTitleForColor;
                    set(TextInPan,'ForegroundColor',txtColor);
                end
                
            otherwise
                UIC_toChange_CHG = [...
                    findall(UICInFig,'Style','frame'); ...
                    findall(UICInFig,'Style','text');  ...
                    findall(UICInFig,'Style','rad');   ...
                    findall(UICInFig,'Style','check'); ...
                    findall(UICInFig,'Style','tog');   ...
                    PanelInFig ...
                    ];
                set(UIC_toChange_CHG,'Units','Pixels');
                set(UIC_toChange_CHG,'BackgroundColor',fraBkColor);
                EDI_InFig = findall(UICInFig,'Style','edit');
                EDI_On_InFig = findall(EDI_InFig,'Enable','On');                
                EDI_Ina_InFig = findall(EDI_InFig,'Enable','Inactive');
                set(EDI_On_InFig,'BackgroundColor',ediActBkColor);
                set(EDI_Ina_InFig,'BackgroundColor',ediInActBkColor);
                set(UIC_toChange_CHG,'Units','Normalized');
        end

    case 'set_WTBX_Fig_POS'
        if ~isequal(get(0,'DefaultFigureWindowStyle'),'docked')            
            fig = varargin{1};
            wtbx_WinPOS = mextglob('get','Win_Position');
            oldUnits = get(fig,'Units');
            set(fig,'Units','Pixels');
            set(fig,'Position',wtbx_WinPOS);
            set(fig,'Units',oldUnits);
            drawnow
        end
        
    case 'changechild'
        fig   = varargin{1};
        child = varargin{2};
        type  = varargin{3};
        wfigPROP = wtbxappdata('get',fig,'WfigPROP');
        switch type
            case 'add'
                wfigPROP.FigChild = unique([wfigPROP.FigChild,child]);
            case 'del'
                wfigPROP.FigChild = setdiff(wfigPROP.FigChild,child);
        end
        idx = ~ishandle(wfigPROP.FigChild);
        wfigPROP.FigChild(idx) = [];
        wtbxappdata('set',fig,'WfigPROP',wfigPROP);
        
    case 'print'
        item = varargin{1};
        switch item
            case {1,2}
                fig = gcbf;
                uic = wfindobj(fig,'Type','Uicontrol','Visible','On');
                par = get(uic,'Parent');
                par = cat(1,par{:});
                [P1,I,J] = unique(par);
                bool = strcmpi(get(P1,'Visible'),'off');
                figDBL = waveletFigNumber(fig);
                P1 = waveletFigNumber(P1);
                while ~all(eq(P1,figDBL*ones(size(I))))
                    P1 = get(P1,'Parent');
                    if iscell(P1) , P1 = cat(1,P1{:}); end
                    P1(P1==0) = figDBL;
                    bool = bool | strcmpi(get(P1,'Visible'),'off');
                end
                bool = bool(J);                
                set(uic(bool),'Visible','Off');
                uit = wfindobj(gcbf,'Type','Uitable','Visible','On');
                par = get(uit,'Parent');
                if iscell(par) , par =  cat(1,par{:}); end
                bool_uit = strcmpi(get(par,'Visible'),'off');
                set(uit(bool_uit),'Visible','Off');

                %-----  BEG - Change BackgroundColor in cwtfttool ----%
                txt = uic(strcmp(get(uic,'style'),'text'));
                txt2CHG_1 = wfindobj(txt,'Tag','Txt_BigTitle');
                txt2CHG_2 = wfindobj(txt,'Tag','Txt_Xlab_AL');                    
                if ~isempty(txt2CHG_1)
                    oldBGC_1 = get(txt2CHG_1(1),'BackgroundColor');
                    set(txt2CHG_1,'BackgroundColor',[1 1 1]);
                end
                if ~isempty(txt2CHG_2) 
                    oldBGC_2 = get(txt2CHG_2(1),'BackgroundColor');
                    set(txt2CHG_2,'BackgroundColor',[1 1 1]);
                end
                %-----  END - Change BackgroundColor in cwtfttool ----%
                
                switch item
                    case 1 , printdlg(gcbf)
                    case 2 , printpreview(gcbf)
                end
                set(uic(bool),'Visible','On');
                set(uit(bool_uit),'Visible','On');
                %-----  BEG - Change BackgroundColor in cwtfttool ----%
                if ~isempty(txt2CHG_1)
                    set(txt2CHG_1,'BackgroundColor',oldBGC_1);
                end
                if ~isempty(txt2CHG_2) 
                    set(txt2CHG_2,'BackgroundColor',oldBGC_2);
                end
                %-----  END - Change BackgroundColor in cwtfttool ----%
                
            case 3 , printdlg('-setup');
        end
        
    case 'export'
        exportsetupdlg(gcbf);
        
	otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
%=======================================================================%


%=======================================================================%
%   CREATION AND MANAGEMENT OF THE MENUS								%
%=======================================================================%
%=======================================================================%
function createMenus(fig,varargin)

% Tag(s)
%------
tag_m_files = 'figMenuFile';

% Get Default StandardMenus.
%---------------------------
% DefaultStandardMenus = GetDefaultFigureMenus;
% DefaultStandardMenus = {'F' 'E' 'V' 'I' 'T' 'D' 'W' 'H'};
%---------------------------------------------------
% We suppress the "Edit" menu in all windows ...
%---------------------------------------------------
% Kept_StandardMenus = {'V','I','T','W','H'};  
% Suppress insert menus.
Kept_StandardMenus = {'V','T','W','H'};

nbin = length(varargin);
switch nbin
case 0
	win_type = 'None';
	StandardMenus = Kept_StandardMenus;
	WTBXMenus     = {};
	
otherwise
	win_type = varargin{1};
    if isequal(win_type,'ExtFig_Show') ||  ...
            isequal(win_type,'ExtMainFig_WTBX') 
        m_file =  wfindobj(fig,'type','uimenu','Tag',tag_m_files);
        delete(m_file);
    end
    
	if ischar(win_type)
		switch win_type
			case {'ExtMainFig_WTBX','ExtFig_WH','ExtFig_Show'}
				WTBXMenus     = {'F'};					
				StandardMenus = {'W','H'};

			case {'ExtFig_DynV'}
				WTBXMenus     = {'F'};
				StandardMenus = {'W'};

			case {'ExtFig_More'}
				WTBXMenus     = {};
				StandardMenus = {'W','H'};

			case {'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2',...
                  'ExtFig_Tool_3','ExtFig_WTMOTION','ExtFig_GUIDE', ...
				  'ExtFig_CompDeno','ExtFig_WDisp','ExtFig_ThrSet'}
				WTBXMenus     = {'F','O'};
				StandardMenus = Kept_StandardMenus;
				
			case {'ExtFig_HistStat'}
				WTBXMenus     = {'F'};
				StandardMenus = Kept_StandardMenus;
                
            case {'ExtFig_Demos'}
				WTBXMenus     = {'F'};  
				StandardMenus = Kept_StandardMenus;
                
            case {'Empty','ExtFig_NoMenu'}
				WTBXMenus     = {};
				StandardMenus = {};
		end
		
	elseif iscell(win_type)
		win_type = win_type{1};
		
	else
		win_type = 'ExtFig_Gen';  
		StandardMenus = varargin{end-1};
		if ~iscell(StandardMenus)
			StandardMenus = num2cell(StandardMenus);
		end
		WTBXMenus = varargin{end};
		if ~iscell(WTBXMenus)
			WTBXMenus = num2cell(WTBXMenus);
		end	
	end
end
if ~ishandle(fig) || isempty(findobj(fig, 'flat', 'Type', 'Figure'))
    fig = gcf;
end
s = dbstack; defineWfigPROP(fig,s)

% Adding Menus.
%==============
if ~isempty(WTBXMenus) || ~isempty(StandardMenus)
	showHiddenVal = get(0,'ShowHiddenHandles');
	set(0,'ShowHiddenHandles','on');
	fig_TEMPO = figure('Visible','off');
	lst_Menus = [];

	% Add Files Menu.
	%----------------
    ind = find(strncmpi(WTBXMenus,'F',1),1);
    if ~isempty(ind)
        LstMenusInFig = findall(get(fig,'Children'),'flat','Type','uimenu');
        lstTagsInFig = get(LstMenusInFig,'Tag');
        idxMenuFile = find(strcmp('figMenuFile',lstTagsInFig));
        if isempty(idxMenuFile)
            h = addMenuFilesWTBX(fig,win_type,tag_m_files);
        else
            h = LstMenusInFig(idxMenuFile);
        end
        lst_Menus = [h ; lst_Menus];
    end
	
	% Add Standard Menus.
	%--------------------
	if ~isempty(StandardMenus)
		addMenu = {};
		for k = 1:length(Kept_StandardMenus)
			letter = Kept_StandardMenus{k};
			ind = find(strncmpi(StandardMenus,letter,1),1);
			if ~isempty(ind) , addMenu = [addMenu ,letter]; end 
		end
		h = addStandardMenus(fig,fig_TEMPO,addMenu{:});
		lst_Menus = [lst_Menus ; h];
	end

	switch win_type 
		case {'ExtMainFig_WTBX','ExtFig_WH','ExtFig_DynV',   ...
			  'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2', ...
              'ExtFig_Tool_3','ExtFig_WTMOTION','ExtFig_GUIDE', ...
		      'ExtFig_ThrSet','ExtFig_WDisp','ExtFig_More','ExtFig_Gen', ...
			  'ExtFig_CompDeno','ExtFig_HistStat', ...
              'ExtFig_Demos','ExtFig_Show' ...
			  }
	
			% If necessary modify some Menus.
			%--------------------------------
            tags =  get(lst_Menus,'tag');
			
			% Modify View Menu.
			%------------------
			ind = find(strcmp('figMenuView',tags));
			if ~isempty(ind)
				m_View = lst_Menus(ind);
				add_DynV_Tool = 0;
				if ~isempty(WTBXMenus)
					ok_DynV = find(strncmpi(WTBXMenus,'O',1),1);
					if ~isempty(ok_DynV) , add_DynV_Tool = 1; end
				end
				setMenuView(m_View,add_DynV_Tool);
			end
			
			% Modify Insert Menu.
			%--------------------
            ind = find(strcmp('figMenuInsert',tags));
			if ~isempty(ind) , setMenuInsert(lst_Menus(ind)); end
			
			% Modify Tools Menu.
			%------------------
            ind = find(strcmp('figMenuTools',tags));
			if ~isempty(ind) , setMenuTools(lst_Menus(ind)); end
			
			% Modify Help Menu.
			%------------------
			ind = find(strcmp('figMenuHelp',tags));
            if ~isempty(ind)
                wfighelp('set',lst_Menus(ind),win_type);
            end
	end
		
	delete(fig_TEMPO)
	set(0,'ShowHiddenHandles',showHiddenVal);
end

% Set Default 'WindowButtonMotionFcn'.
%-------------------------------------
set(fig,'WindowButtonMotionFcn','');

% Prevent extrat plots.
set(fig,'HandleVisibility','Callback')

% End Of WTBMENUS
%=======================================================================%

%====================  ADDING and SETTING MENUS ========================%
%---------------------------------------------------------------------%
function h = addMenuFilesWTBX(fig,win_type,tag_m_files)

% Tags of Standard main menus.
%-----------------------------
%     'figMenuHelp'
%     'figMenuWindow'
%     'figMenuDesktop'
%     'figMenuTools'
%     'figMenuInsert'
%     'figMenuView'
%     'figMenuEdit'
%     'figMenuFile'
%---------------------------------------------------------------------
% Configuration of standard "Files" menu label -- Tag (reverse order).
%--------------------------------------------------------
%     '&Exit MATLAB'           --     'figMenuFileExitMatlab'
%     '&Print...'              --     ''
%     'Print Pre&view...'      --     'figMenuFilePrintPreview'
%     'Expo&rt Setup...'       --     'figMenuFileExportSetup'
%     'Pre&ferences...'        --     'figMenuFilePreferences'
%     'Save &Workspace As...'  --     'figMenuFileSaveWorkspaceAs'
%     '&Import Data...'        --     'figMenuFileImportData'
%     'Generate Code...'       --     'figMenuGenerateCode'
%     'Save &As...'            --     'figMenuFileSaveAs'
%     '&Save'                  --     'figMenuFileSave'
%     '&Close'                 --     'figMenuFileClose'
%     '&Open...'               --     ''
%     '&New'                   --     'figMenuUpdateFileNew'
%---------------------------------------------------------------------
lab_child = {...
    getWavMSG('Wavelet:wfigmngr:figMenuPrint'), ...
    getWavMSG('Wavelet:wfigmngr:figMenuFilePrintPreview'), ...
    getWavMSG('Wavelet:wfigmngr:figMenuFilePrintSetup'), ...
    getWavMSG('Wavelet:wfigmngr:figMenuFilePreferences'), ...
    getWavMSG('Wavelet:wfigmngr:figMenuFileExportSetup')  ...
    };
cb_child = {...
    @(~,~)wfigmngr('print',1)
    @(~,~)wfigmngr('print',2)
    @(~,~)wfigmngr('print',3)
    @(~,~)preferences
    @(~,~)wfigmngr('export',1)
    };
h = uimenu(fig,'Label',getWavMSG('Wavelet:wfigmngr:figMenuFile'),...
    'Position',1,'Tag',tag_m_files);								

switch win_type
	case {'ExtFig_Tool'}
		ok_Load = 1; ok_Save = 1;
		
	case {'ExtFig_Tool_1'}
		ok_Load = 1; ok_Save = 0;
		
	case {'ExtFig_Tool_2',...
		  'ExtFig_CompDeno'}
		ok_Load = 0; ok_Save = 1;

	case {'ExtFig_Tool_3','ExtFig_WTMOTION','ExtFig_GUIDE', ...
		  'ExtFig_HistStat','ExtFig_ThrSet','ExtFig_WDisp'}
		ok_Load = 0; ok_Save = 0;
		
	otherwise
		ok_Load = 0; ok_Save = 0;		
end

% Add Load Menu.
%---------------
if ok_Load
    uimenu(h,'Label',getWavMSG('Wavelet:wfigmngr:figMenuLoad'),...
        'Position',1,'Tag','figMenuLoad'); 
end

% Add Save Menu and SubMenus.
%----------------------------
if ok_Save
    if ok_Load
        pos = 2;
    else
        pos = 1;
    end
	uimenu(h,'Label',getWavMSG('Wavelet:wfigmngr:figMenuSave'),...
        'Position',pos,'Tag','figMenuSave');
end

% Add Open & Export Menus.
%-------------------------
flag_Open_Export = 1;
if flag_Open_Export
    switch win_type			
		case {'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2', ...
              'ExtFig_Tool_3','ExtFig_WTMOTION','ExtFig_GUIDE', ...
			  'ExtFig_WH','ExtFig_ThrSet','ExtFig_WDisp', ...
			  'ExtFig_CompDeno','ExtFig_HistStat','ExtFig_Demos'}
            idx_child = 5;      %  'Export'
            sep_child = {'On'};	
			if isequal(win_type,'ExtFig_WH'), sep_child{1} = 'Off'; end
			addChildren(h,lab_child(idx_child),sep_child,cb_child(idx_child));
    end
end

% Add Print Menus.
%-----------------
if isequal(win_type,'ExtMainFig_WTBX')
    idx_child = 4;
    sep_child = {'Off'};
    m_Parent = h;
    addChildren(m_Parent,lab_child(idx_child),sep_child,cb_child(idx_child));
end
switch win_type
	case {'ExtFig_Tool','ExtFig_Tool_1','ExtFig_Tool_2', ...
          'ExtFig_Tool_3','ExtFig_WTMOTION','ExtFig_GUIDE', ...
		  'ExtFig_WH','ExtFig_WDisp','ExtFig_CompDeno','ExtFig_HistStat', ...
		  'ExtFig_ThrSet','ExtFig_Demos','ExtFig_Show','ExtMainFig_WTBX'}
		idx_child = [3,2,1];
		sep_child = {'Off','Off','Off'};		
		sep_close = 'On';
        del_ON = true;
		m_Parent = uimenu(h,...
            'Label',getWavMSG('Wavelet:wfigmngr:figMenuPrintTools'), ...
            'Separator','On');
	otherwise
		sep_close = 'Off';
        del_ON = false;
		idx_child = []; sep_child = []; 
		m_Parent = h;
end
addChildren(m_Parent,lab_child(idx_child),sep_child,cb_child(idx_child));
if del_ON
    child = get(m_Parent,'Children'); delete(child(3));
end

% Add Close Menu.
%----------------
cb_Close = @(~,~)tryDelete(fig);

uimenu(h,'Label',getWavMSG('Wavelet:wfigmngr:figMenuClose'), ...
    'Separator',sep_close,'CallBack',cb_Close, ...
    'Tag','figMenuClose');
%---------------------------------------------------------------------%
function addChildren(par,lab_child,sep_child,cb_child)

for k = 1:length(lab_child)
	uimenu(par,'Label',lab_child{k}, 'Separator',sep_child{k}, ...
            'CallBack',cb_child{k});
end		
%---------------------------------------------------------------------%
function liste = addStandardMenus(fig,fig_TEMPO,varargin)

LstMenusInFig = findall(get(fig,'Children'),'flat','Type','uimenu');
lstTagsInFig = get(LstMenusInFig,'Tag');
if ~isempty(lstTagsInFig)
    if ~iscell(lstTagsInFig) , lstTagsInFig = {lstTagsInFig}; end
    nb   = length(lstTagsInFig);
    TagsInFig = cell(1,nb);
    for k = 1:nb , TagsInFig{k} = lstTagsInFig{k}(8); end
else
    TagsInFig = {};
end
lstMenus  = findall(get(fig_TEMPO,'Children'),'flat','Type','uimenu');
lstTags = get(lstMenus,'Tag');
nb   = length(lstTags);
Tags = cell(1,nb);
for k = 1:nb , Tags{k} = lstTags{k}(8); end
liste = [];
for k=1:length(varargin)
    tag = varargin{k};
    ind = find(strncmp(tag,TagsInFig,length(tag)),1);
    if isempty(ind)
        ind = find(strncmp(tag,Tags,length(tag)),1);
        if ~isempty(ind)
            liste = [liste ; lstMenus(ind)]; 
        end
        % Translation of Labels
        switch tag
            case 'V' , lab = getWavMSG('Wavelet:wfigmngr:figMenuView');
            case 'I' , lab = getWavMSG('Wavelet:wfigmngr:figMenuInsert');
            case 'T' , lab = getWavMSG('Wavelet:wfigmngr:figMenuTools');
            case 'W' , lab = getWavMSG('Wavelet:wfigmngr:figMenuWindow');
            case 'H' , lab = getWavMSG('Wavelet:wfigmngr:figMenuHelp');
        end
        set(lstMenus(ind),'label',lab)
    end
end

% Suppression of submenu '&Find Files...'
if ~isempty(liste)
    tag = get(liste,'tag');
    idx = strcmp(tag,'figMenuEdit');
    child = get(liste(idx),'Children');
    tag = get(child,'tag');
    idx = strcmp(tag,'figMenuEditFindFiles');
    delete(child(idx));
end

if ~isempty(liste) , liste = copyMenu(liste,fig); end		
%---------------------------------------------------------------------%
%================== GENERAL SETTINGS FOR MAIN MENUS ====================%
%---------------------------------------------------------------------%
function setMenuView(h,Add_DynV_Tool)

% Tag and Label for DynVTool.
%----------------------------
tag_m_dynv = 'M_Zoom';

% Get information and ...
%------------------------
c = get(h,'Children');
tag = get(c,'tag');
%---------------------------
% 'figMenuPropertyEditor'
% 'figMenuPlotBrowser'
% 'figMenuFigurePalette'
% 'figMenuPloteditToolbar'
% 'figMenuCameraToolbar'
% 'figMenuFigureToolbar'
%---------------------------
idx_Fig = strcmp('figMenuFigureToolbar',tag);
set(c(idx_Fig),...
    'Label',getWavMSG('Wavelet:wfigmngr:figMenuFigureToolbar'), ...
    'Checked','Off','Callback',@cb_FigToolBar);

if ~Add_DynV_Tool
    idx = strcmp(tag,tag_m_dynv);
	m_dynv = c(idx);
	if ~isempty(m_dynv) , Add_DynV_Tool = 0; end
end
%%%-----------------------------------------%%%
% Suppress SubMenus.
%-----------------------
idx2Del = [];
idx = find(strcmp('figMenuPropertyEditor',tag));
idx2Del = [idx2Del;idx];
idx = find(strcmp('figMenuPlotBrowser',tag));
idx2Del = [idx2Del;idx];
idx = find(strcmp('figMenuFigurePalette',tag));
idx2Del = [idx2Del;idx];
idx = find(strcmp('figMenuPloteditToolbar',tag));
idx2Del = [idx2Del;idx];
idx = find(strcmp('figMenuCameraToolbar',tag));
idx2Del = [idx2Del;idx];
if ~isempty(idx2Del) , delete(c(idx2Del)); end
%%%-----------------------------------------%%%

% Add DynVTool if necessary.
%---------------------------
if Add_DynV_Tool
	uimenu(h,...
           'Label',getWavMSG('Wavelet:wfigmngr:figMenuDynV'), ...
		   'Separator','On',   ...
           'Checked','on',     ...
           'Callback',@cb_DynVTool, ...
           'Tag',tag_m_dynv    ...
           );
end
%---------------------------------------------------------------------%
function cb_FigToolBar(hco,eventStruct) %#ok<INUSD>

menu = gcbo;
oldVal = get(menu,'checked');
switch oldVal
  case 'on'  , newVal = 'off';
  case 'off' , newVal = 'on';
end
set(menu,'Checked',newVal);
domymenu('menubar','toggletoolbar',gcbf) 
%---------------------------------------------------------------------%
function cb_DynVTool(hco,eventStruct) %#ok<INUSD>

menu = gcbo;
oldVal = get(menu,'checked');
switch oldVal
  case 'on'  , newVal = 'off';
  case 'off' , newVal = 'on';
end
set(menu,'Checked',newVal);
dynvtool('visible',gcbf,newVal)	   
%---------------------------------------------------------------------%
function setMenuInsert(h)

c = get(h,'Children');
tag = get(c,'tag');
%----------------------------------
% 'figMenuInsertLight'
% 'figMenuInsertAxes'
% 'figMenuInsertEllipse'
% 'figMenuInsertRectangle'
% 'figMenuInsertTextbox'
% 'figMenuInsertArrow2'
% 'figMenuInsertTextArrow'
% 'figMenuInsertArrow'
% 'figMenuInsertLine'
% 'figMenuInsertColorbar'
% 'figMenuInsertLegend'
% 'figMenuInsertTitle'
% 'figMenuInsertZLabel'
% 'figMenuInsertYLabel'
% 'figMenuInsertXLabel'
%----------------------------------
ind = [...
    find(strcmp(tag,'figMenuInsertColorbar')); ...
    find(strcmp(tag,'figMenuInsertLight'));    ...
    find(strcmp(tag,'figMenuInsertAxes'));     ...
	];
if ~isempty(ind) , delete(c(ind)); end
%---------------------------------------------------------------------%
function setMenuTools(h)

c = get(h,'Children');
tag = get(c,'tag');
%----------------------------------
% 'figMenuToolsBFDS'
% 'figMenuToolsBFDS'
% 'figDataManagerBrushTools'
% 'figMenuToolsAlign'
% 'figMenuToolsAlign'
% 'figMenuToolsAlignDistributeTool'
% 'figMenuToolsAlignDistributeSmart'
% 'figMenuViewGrid'
% 'figMenuSnapToGrid'
% 'figMenuEditPinning'
% 'figMenuOptions'
% 'figMenuResetView'
% 'figLinked'
% 'figBrush'
% 'figMenuDatatip'
% 'figMenuRotate3D'
% 'figMenuPan'
% 'figMenuZoomOut'
% 'figMenuZoomIn'
% 'figMenuToolsPlotedit'
%----------------------------------
%%%-----------------------------------------%%%
% Suppress SubMenus.
%-------------------
%     '&Edit Plot'
%     &Data Statistics
%     Basic &Fitting                    
%     Distri&bute                       
%     Ali&gn                            
%     Align Distrib&ute Tool ...        
%     &Smart Align and Distribute       
%     View Layout Gr&id                 
%     Snap To &Layout Grid              
%     Pi&n to Axes                      
%     Options                           
%     Reset View                        
%     D&ata Cursor                      
%     &Rotate 3D                        
%     &Pan                              
%     Zoom &Out                         
%     &Zoom In                          
%     &Edit Plot                        
%-----------------------
idx2Keep = [];
idx = find(strcmp('figMenuRotate3D',tag));
idx2Keep = [idx2Keep;idx];
idx = find(strcmp('figMenuZoomOut',tag));
idx2Keep = [idx2Keep;idx];
idx = find(strcmp('figMenuZoomIn',tag));
idx2Keep = [idx2Keep;idx];
idx2Del = setdiff((1:length(c)),idx2Keep);
if ~isempty(idx2Del) , delete(c(idx2Del)); end
%---------------------------------------------------------------------%
function cb_Default_Color_Mode(hco,eventStruct) %#ok<INUSD> % Menu Preference

ud = get(hco,'UserData');
idx = find(ud==hco);
set(ud(idx),'Checked','On');
set(ud(3-idx),'Checked','Off');
%---------------------------------------------------------------------%
%=======================================================================%


%========================= TOOLS FOR  MENUS ============================%
function [DefaultStandardMenus,NB_Main_STDMenus] = GetDefaultFigureMenus %#ok<DEFNU>

% Use only once for a new version to find menu items.
%--------------------------------------------------------------------------
% {'F' 'E' 'V' 'I' 'T' 'D' 'W' 'H'} for MATLAB Version 7.2.0.232 (R2006a)
%--------------------------------------------------------------------------

showHiddenVal = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
fig_TEMPO = figure('Visible','off');
lstMenus  = findall(get(fig_TEMPO,'Children'),'flat','Type','uimenu');
lstMenus  = flipud(lstMenus);
NB_Main_STDMenus = length(lstMenus);
lstLabels = get(lstMenus,'label');
DefaultStandardMenus = cell(1,NB_Main_STDMenus);
for k=1:NB_Main_STDMenus , DefaultStandardMenus{k} = lstLabels{k}(2); end

% Get Handles.
%-------------
idx = 1;
lstALLMenus{idx} = findall(lstMenus,'Type','uimenu');
continu = true;
while continu
    idx = idx + 1;
    tmp = get(lstALLMenus{idx-1},'Parent');
    tmp = cat(1,tmp{:});
    lstALLMenus{idx} = tmp;
    tmp = unique(tmp);
    L = length(tmp);
    continu = L>1;
end
nbStep = length(lstALLMenus);
nbMenu = length(lstALLMenus{1});

% Get Labels.
%-------------
lstALL_Labels = cell(nbMenu,nbStep);
for k = 1:nbStep
    type_hdl = get(lstALLMenus{k},'Type');
    idx = strcmp(type_hdl,'uimenu');
    if any(idx)
        tmp = get(lstALLMenus{k}(idx),'label');
        lstALL_Labels(idx,k) = tmp;
    end
end

% Get Callback.
%--------------
lstALL_CB = cell(nbMenu,nbStep);
for k = 1:nbStep
    type_hdl = get(lstALLMenus{k},'Type');
    idx = strcmp(type_hdl,'uimenu');
    if any(idx)
        tmp = get(lstALLMenus{k}(idx),'Callback');
        lstALL_CB(idx,k) = tmp;
    end
end

delete(fig_TEMPO);
set(0,'ShowHiddenHandles',showHiddenVal);
%---------------------------------------------------------------------%
function liste = copyMenu(liste,cible)

set(liste,'Parent',cible);
set(liste,'HandleVisibility','on');
%---------------------------------------------------------------------%
%=======================================================================%
%=======================================================================%


%=======================================================================%
%---------------------------------------------------------------------%
function defineWfigPROP(fig,s,flag) %#ok<INUSD>

wfigPROP = wtbxappdata('get',fig,'WfigPROP');
if ~isempty(wfigPROP) && (nargin<3) , return; end
switch length(s)
  case 0 ,    return
  case 1 ,    ind = 1;
  otherwise , ind = 2;
end
[path,name] = fileparts(s(ind).name); %#ok<ASGLU>
figParent = gcbf;
wfigPROP  = struct('MakeFun',name,'FigParent',figParent,'FigChild',[]);
wtbxappdata('set',fig,'WfigPROP',wfigPROP);
if ~isempty(figParent)
    wfigPROP = wtbxappdata('get',figParent,'WfigPROP');
    if ~isempty(wfigPROP)
        wfigPROP.FigChild = unique([wfigPROP.FigChild,fig]);
        idx = ~ishandle(wfigPROP.FigChild);
        wfigPROP.FigChild(idx) = [];
        wtbxappdata('set',figParent,'WfigPROP',wfigPROP);
    end
end
%---------------------------------------------------------------------%
%=======================================================================%


function appendClose(oldCallback, varargin)
% Nargin == 1:
% First call wfigmngr close on this figure. Then call the old
% callback.
% Nargin == 2:
% First call wfigmngr close on this figure. Then call the function
% in varargin{2}. Then call the old callback.
% Nargin == 3:
% First call wfigmngr close then call vararin{2}. Failing that,
% call the old callback.

fig = varargin{1};

wfigmngr('close', fig);

if length(varargin) > 1
    funcNam = str2func(varargin{2});

    if length(varargin) > 2
        ansVal = funcNam('close', fig);
        if ansVal > -1
            hgfeval(oldCallback);
        end
    else
        funcNam('close', fig);
        hgfeval(oldCallback);
    end
else
    hgfeval(oldCallback);
end

function tryDelete(fig)
if ishandle(fig)
    delete(fig)
end

