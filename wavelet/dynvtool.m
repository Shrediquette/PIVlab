function varargout = dynvtool(option,fig,varargin)
%DYNVTOOL Dynamic visualization tool.
%   VARARGOUT = DYNVTOOL(OPTION,FIG,VARARGIN)
%
%   option = 'create'
%   option = 'attach' 
%   option = 'init'
%   option = 'go'
%   option = 'stop'
%   option = 'on'
%   option = 'fcn_w'
%   option = 'close'
%   option = 'cleanXYPos'
%
%   option = 'ini_his'
%   option = 'get'
%   option = 'put'
%   option = 'zoom+'
%   option = 'zoom-'
%   option = 'center'
%
%   option = 'visible'
%   option = 'hide'
%   option = 'show'
%
%   option = 'wmb'
%   option = 'rmb'
%   option = 'handles'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Nov-95.
%   Last Revision: 11-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.18.4.17 $ $Date: 2013/08/23 23:45:05 $

%----------------------------------
% DynVTool MemoryBloc Structure.
%----------------------------------
% Structure:
%   handles = Structure of handles.
%   DynV_Sel_Box
%   DynV_Line_Hor
%   DynV_Line_Ver 
%   flgTrans
%   linColor
%   axeInd
%   axeCmd
%   axeAct
%   axeSel
%   xyConst
%   histPtr
%   histData
%   axeSel
%----------------------------------
memBlocName = 'DynVToolMemBloc';

if nargin<2
    fig = gcf;
end
% Check the figure exists and is a figure
if ~ishandle(fig) || isempty(findobj(fig, 'flat', 'Type', 'Figure'))
    return;
end

dynvfcn = @(~,~)mngmbtn('down',fig);

switch option
    case 'rmb'
        varargout{1} = wtbxappdata('get',fig,memBlocName);

    case 'wmb'
        wtbxappdata('set',fig,memBlocName,varargin{1});

    case 'handles'
        memB = wtbxappdata('get',fig,memBlocName);
        varargout{1} = memB.handles;
        if ~isempty(varargin)
          varargout{1} = struct2cell(varargout{1});
          varargout{1} = cat(1,varargout{1}{:});
        end

    case 'get'
        %*************************************************************%
        %** OPTION = 'get' RECUPERATION D'UN ETAT DANS L'HISTORIQUE **%
        %*************************************************************%
        % in4 (optional) force the reset.
        %--------------------------------
        sens          = varargin{1};
        dVTmemB       = dynvtool('rmb',fig);
        DynV_Reg_HPtr = dVTmemB.histPtr;
        data          = dVTmemB.histData;
		Txt_History   = dVTmemB.handles.Txt_History;
        Pus_Hist_Init = dVTmemB.handles.Pus_Hist_Init;
        Pus_Hist_Prev = dVTmemB.handles.Pus_Hist_Prev;
        Pus_Hist_Next = dVTmemB.handles.Pus_Hist_Next;
        change        = 'non';
        if sens>0
            m = size(data,1);
            if DynV_Reg_HPtr<m
                DynV_Reg_HPtr = DynV_Reg_HPtr+1;
                if DynV_Reg_HPtr==m
                    set(Pus_Hist_Next,'Enable','Off');
                end
                set([Pus_Hist_Prev,Pus_Hist_Init],'Enable','On');
                change = 'oui';
            end
        elseif (DynV_Reg_HPtr>1) || (nargin==4)
            if sens==0
                DynV_Reg_HPtr = 1;
            elseif sens<0
                DynV_Reg_HPtr = DynV_Reg_HPtr-1;
            end
			if nargin==4
        		set([Txt_History,Pus_Hist_Init, ...
					Pus_Hist_Prev,Pus_Hist_Next],'Enable','Off');
			else
				set(Pus_Hist_Next,'Enable','On');
			end
            if DynV_Reg_HPtr==1
                set([Pus_Hist_Prev,Pus_Hist_Init],'Enable','Off');
            end
            change = 'oui';
        end
        if strcmp(change,'oui')
            dVTmemB.histPtr = DynV_Reg_HPtr;
            % Edi_PosX = dVTmemB.handles.Edi_PosX;
            % Edi_PosY = dVTmemB.handles.Edi_PosY;
            dVTmemB = mngmbtn('delLines',fig,'All',dVTmemB);
            if isempty(data) , return; end
            don = data(DynV_Reg_HPtr,:);
            p = size(don,2);
            if p>1
                axe_hdls = [dVTmemB.axeInd dVTmemB.axeAct];
                if don(1)~=0
                    lig = don(1);
                    col = don(2);
                    His_don    = zeros(lig,col);
                    His_don(:) = don(3:lig*col+2);
                    k = 3+lig*col;
                    %------ depilage d'un etat ------%
                    fcns = get(Pus_Hist_Init,'UserData');
                    feval(fcns(2,:),His_don);
                else
                    k = 3;
                end
                for i = 1:length(axe_hdls)
                    x = [don(k) don(k+1)];
                    y = [don(k+2) don(k+3)];
                    k = k+4;
                    h = axe_hdls(i);
                    if any(x~=get(h,'XLim')) || any(y~=get(h,'YLim'))
                        set(h,'XLim',x,'YLim',y);
                    end
                end
            end
        end

    case 'put'
        %******************************************************%
        %** OPTION = 'put' AJOUT D'UN ETAT DANS L'HISTORIQUE **%
        %******************************************************%
        dVTmemB       = dynvtool('rmb',fig);
		Txt_History   = dVTmemB.handles.Txt_History;		
        Pus_Hist_Init = dVTmemB.handles.Pus_Hist_Init;
        Pus_Hist_Prev = dVTmemB.handles.Pus_Hist_Prev;
        Pus_Hist_Next = dVTmemB.handles.Pus_Hist_Next;
        DynV_Axe_Ind  = dVTmemB.axeInd;
        DynV_Axe_Act  = dVTmemB.axeAct;
        axe_hdls      = [DynV_Axe_Ind DynV_Axe_Act];
        coor = [];
        for i = 1:length(axe_hdls)
            coor = [coor get(axe_hdls(i),'XLim') get(axe_hdls(i),'YLim')]; %#ok<AGROW>
        end
        fcns = get(Pus_Hist_Init,'UserData');
        %--- State storage (user function) ---%
        z1  = eval(fcns(1,:));
        s   = size(z1);
        val = z1(:)';
        DynV_Reg_HPtr = dVTmemB.histPtr;
        if DynV_Reg_HPtr~=0
            data = dVTmemB.histData;
            data = [data(1:DynV_Reg_HPtr,:);[s val coor]];
        else
            data = [s val coor];
        end
        DynV_Reg_HPtr = size(data,1);
        if DynV_Reg_HPtr>1
            set([Txt_History,Pus_Hist_Prev,Pus_Hist_Init],'Enable','On');
        end
        dVTmemB.histPtr  = DynV_Reg_HPtr;
        dVTmemB.histData = data;
        dynvtool('wmb',fig,dVTmemB);
        set(Pus_Hist_Next,'Enable','Off');

    case 'ini_his'
        %*******************************************************%
        %** OPTION = 'ini_his' INITIALISATION DE L'HISTORIQUE **%
        %*******************************************************%
        if nargin==3 , dynvtool('get',fig,0); end
        dVTmemB       = dynvtool('rmb',fig);
		Txt_History   = dVTmemB.handles.Txt_History;
        Pus_Hist_Init = dVTmemB.handles.Pus_Hist_Init;
        Pus_Hist_Prev = dVTmemB.handles.Pus_Hist_Prev;
        Pus_Hist_Next = dVTmemB.handles.Pus_Hist_Next;
        Edi_PosX      = dVTmemB.handles.Edi_PosX;
        Edi_PosY      = dVTmemB.handles.Edi_PosY;
        dVTmemB.histPtr = 0;
        dVTmemB.histData = [];
        set([Txt_History,Pus_Hist_Init, ...
		     Pus_Hist_Prev,Pus_Hist_Next],'Enable','Off');
        if nargin==4
            fcn_put = varargin{1};
            fcn_get = varargin{2};
            if isempty(fcn_put) , fcn_put='[]'; end
            if isempty(fcn_get) , fcn_get='[]'; end
            space  = ' ' ;
            c1 = size(fcn_put,2);
            c2 = size(fcn_get,2);
            if c2>c1
                fcn_sto = [fcn_put space*ones(1,c2-c1); fcn_get];
            else
                fcn_sto = [fcn_put ; fcn_get space*ones(1,c1-c2)];
            end
            set(Pus_Hist_Init,'UserData',fcn_sto);
            set(Pus_Hist_Prev,'UserData','');
            set(Pus_Hist_Next,'UserData','');
        end
        set(Edi_PosX,'String','X = ');
        set(Edi_PosY,'String','Y = ');
        dynvtool('wmb',fig,dVTmemB);

    case {'zoom+','zoom-'}
        %*****************************************************%
        %** OPTION = 'zoom+' or 'zoom-'   GESTION DES ZOOMS **%
        %*****************************************************%
        dir = varargin{1};
        dVTmemB = dynvtool('rmb',fig);
        DynV_Sel_Box = dVTmemB.DynV_Sel_Box;
        if isempty(DynV_Sel_Box)
            WarnString = getWavMSG('Wavelet:moreMSGRF:DynV_WarnZoom_MSG');
            wwarndlg(WarnString, ...
                getWavMSG('Wavelet:moreMSGRF:DynV_WarnZoom'),'bloc')
            return;
        end
        
        pzbx = get(DynV_Sel_Box,'XData');
        pzby = get(DynV_Sel_Box,'YData');
        xmin = min(pzbx);       xmax = max(pzbx);
        ymin = min(pzby);       ymax = max(pzby);
        dVTmemB = mngmbtn('delLines',fig,'All',dVTmemB);
        if (xmin<xmax) && (ymin<ymax)
            DynV_Axe_Ind = dVTmemB.axeInd;
            DynV_Axe_Sel = dVTmemB.axeSel;
            if ~isempty(DynV_Axe_Ind) && ...
               ~isempty(find(DynV_Axe_Sel==DynV_Axe_Ind,1))
                DynV_Axe_Act = DynV_Axe_Sel;
                DynV_XY_Const = [0 0];
            else
                DynV_Axe_Act  = dVTmemB.axeAct;
                DynV_XY_Const = dVTmemB.xyConst;
            end
            %--- En direction des x ---%
            if dir(1)~=0
                %-- Agrandir --%
                if strcmp(option,'zoom+')
                    ux = [xmin xmax];
                %-- Diminuer --%
                elseif strcmp(option,'zoom-')
                    xL  = get(DynV_Axe_Sel,'XLim');
                    ux1 = (xL(1)-xmax)*xL(1)+(xmin-xL(1))*xL(2);
                    ux2 = (xmin-xL(2))*xL(2)+(xL(2)-xmax)*xL(1);
                    ux  = [ux1 ux2]/(xmin-xmax);
                end
                if DynV_XY_Const(1)~=0
                    set(DynV_Axe_Act,'XLim',ux);
                else
                    set(DynV_Axe_Sel,'XLim',ux);
                end
            end
            %--- En direction des y ---%
            if dir(2)~=0
                %-- Agrandir --%
                if strcmp(option,'zoom+')
                    uy = [ymin ymax];
                %-- Diminuer --%
                elseif strcmp(option,'zoom-')
                    yL  = get(DynV_Axe_Sel,'YLim');
                    uy1 = (yL(1)-ymax)*yL(1)+(ymin-yL(1))*yL(2);
                    uy2 = (ymin-yL(2))*yL(2)+(yL(2)-ymax)*yL(1);
                    uy  = [uy1 uy2]/(ymin-ymax);
                end
                if DynV_XY_Const(2)~=0
                    set(DynV_Axe_Act,'YLim',uy);
                else
                    set(DynV_Axe_Sel,'YLim',uy);
                end
            end
            dynvtool('put',fig);
        end

    case 'center'
        btn = varargin{1};
        dir = varargin{2};
        if isstruct(btn)   % Sometimes: Version V3
            btn = btn.Edi_Center;
        end
        if ~ishandle(btn)
            handles = guihandles(gcbf);
            btn = handles.Edi_Center; 
        end
        dVTmemB      = dynvtool('rmb',fig);
        DynV_Axe_Sel = dVTmemB.axeSel;
        if isempty(DynV_Axe_Sel)
            DynV_Axe_Act  = dVTmemB.axeAct;
            DynV_XY_Const = dVTmemB.xyConst;
            if isempty(DynV_Axe_Act) , return; end
            DynV_Axe_Sel  = DynV_Axe_Act(1);
        else
            DynV_Axe_Ind = dVTmemB.axeInd;
            if ~isempty(DynV_Axe_Ind) && ...
               ~isempty(find(DynV_Axe_Sel==DynV_Axe_Ind,1))
                DynV_Axe_Act  = DynV_Axe_Sel;
                DynV_XY_Const = [0 0];
            else
                DynV_Axe_Act  = dVTmemB.axeAct;
                DynV_XY_Const = dVTmemB.xyConst;
            end
        end
        strval = get(btn,'String');		
        mngmbtn('delLines',fig,'All',dVTmemB);
        if isempty(DynV_Axe_Act) , return; end		
        [val_centre,count,err] = sscanf(strval,'%f');
        if count==1 && isempty(err)
            if length(DynV_Axe_Act)==1 , seul = 1; else seul = 0; end
            %--- Centrer par rapport a x ---%
            if dir==0
                if seul || DynV_XY_Const(1)~=0
                    laxe = DynV_Axe_Act(1);
                else
                    laxe = DynV_Axe_Sel;
                end
                if isempty(laxe) , return; end
                x = get(laxe,'XLim');
                la = (x(2)-x(1))/2;
                xmin = val_centre-la;
                xmax = val_centre+la;
                if seul || DynV_XY_Const(1)~=0
                    set(DynV_Axe_Act,'XLim',[xmin xmax]);
                else
                    set(DynV_Axe_Sel,'XLim',[xmin xmax]);
                end

            %--- Centrer par rapport a y ---%
            elseif dir==1
                if seul || DynV_XY_Const(2)~=0
                    laxe = DynV_Axe_Act(1);
                else
                    laxe = DynV_Axe_Sel;
                end
                if isempty(laxe) , return; end
                y = get(laxe,'YLim');
                la = (y(2)-y(1))/2;
                ymin = val_centre-la;
                ymax = val_centre+la;
                if seul || DynV_XY_Const(2)~=0
                    set(DynV_Axe_Act,'YLim',[ymin ymax]);
                else
                    set(DynV_Axe_Sel,'YLim',[ymin ymax]);
                end
            else
                return;
            end
            dynvtool('put',fig);
        end
        set(btn,'String','');

    case {'Install_V3','Install_V3_CB','create','create_V3'}
        % Create structure.
        %------------------
        dVTmemB.handles   = [];
        dVTmemB.Enable_Style = 0;
        dVTmemB.DynV_Sel_Box  = [];
        dVTmemB.DynV_Line_Hor = [];
        dVTmemB.DynV_Line_Ver = [];
        dVTmemB.flgTrans  = 0;
        dVTmemB.linColor  = [1 0 0];
        dVTmemB.axeInd    = [];
        dVTmemB.axeCmd    = [];
        dVTmemB.axeAct    = [];
        dVTmemB.axeSel    = [];
        dVTmemB.xyConst   = [0 0];
        dVTmemB.histPtr   = 0;
        dVTmemB.histData  = [];
        %------------------------------------------
        % Enable_Style Values: -1, 0 or 1 
        % Style of Controls Used by  'set_BtnOnOff'
        %------------------------------------------
        switch option
            case 'create' % OLD VERSION
                handles = CreateDynVTool(fig,varargin{:});
            case {'create_V3','Install_V3','Install_V3_CB'}
                handles = varargin{1};
                values = {...
                    handles.Fra_DynVTool,   ...
                    handles.Pus_ZoomXPlus,  handles.Pus_ZoomXMinus,  ... 
                    handles.Pus_ZoomYPlus,  handles.Pus_ZoomYMinus,  ... 
                    handles.Pus_ZoomXYPlus, handles.Pus_ZoomXYMinus, ... 
                    handles.Fra_Center,     handles.Txt_Center,      ...
                    handles.Pus_CenterX,    handles.Pus_CenterY,     ...
                    handles.Edi_Center,     ...
                    handles.Fra_Info,       handles.Txt_Info,  ...
                    handles.Edi_PosX,       handles.Edi_PosY,        ...
                    handles.Fra_Hist,       handles.Txt_History,     ...
                    handles.Pus_Hist_Init,  handles.Pus_Hist_Prev, handles.Pus_Hist_Next,   ...
                    handles.Tog_View_Axes   ...
                    };
                fields = {...
                    'Fra_DynVTool',                      ...
                    'Pus_ZoomXPlus',  'Pus_ZoomXMinus',  ... 
                    'Pus_ZoomYPlus',  'Pus_ZoomYMinus',  ...
                    'Pus_ZoomXYPlus', 'Pus_ZoomXYMinus', ...
                    'Fra_Center',     'Txt_Center',      ...
                    'Pus_CenterX',    'Pus_CenterY',     ...
                    'Edi_Center',  ...
                    'Fra_Info', 'Txt_Info',  ...
                    'Edi_PosX', 'Edi_PosY'   ...
                    'Fra_Hist', 'Txt_History',  'Pus_Hist_Init', ...
                    'Pus_Hist_Prev', 'Pus_Hist_Next', ...
                    'Tog_View_Axes'  ...
                    };
                handles = cell2struct(values,fields,2);
        end
        dVTmemB.handles = handles;
        switch option            
            case {'create','create_V3','Install_V3'}
            case 'Install_V3_CB'
                set(handles.Pus_ZoomXPlus  ,'Callback',@(~,~)dynvtool('zoom+',fig,[1 0]))
                set(handles.Pus_ZoomXMinus ,'Callback',@(~,~)dynvtool('zoom-',fig,[1 0]))
                set(handles.Pus_ZoomYPlus  ,'Callback',@(~,~)dynvtool('zoom+',fig,[0 1]))
                set(handles.Pus_ZoomYMinus ,'Callback',@(~,~)dynvtool('zoom-',fig,[0 1]))
                set(handles.Pus_ZoomXYPlus ,'Callback',@(~,~)dynvtool('zoom+',fig,[1 1]))
                set(handles.Pus_ZoomXYMinus,'Callback',@(~,~)dynvtool('zoom-',fig,[1 1]))
                ediStr = (handles.Edi_Center);
                set(handles.Pus_CenterX    ,'Callback',@(~,~)dynvtool('center',fig, ediStr ,0))
                set(handles.Pus_CenterY    ,'Callback',@(~,~)dynvtool('center',fig, ediStr ,1))
                set(handles.Edi_Center     ,'Callback',@(~,~)dynvtool('edi_center',fig, ediStr ))
                set(handles.Pus_Hist_Init  ,'Callback',@(~,~)dynvtool('get',fig,0))
                set(handles.Pus_Hist_Prev  ,'Callback',@(~,~)dynvtool('get',fig,-1))
                set(handles.Pus_Hist_Next  ,'Callback',@(~,~)dynvtool('get',fig,1))
                set(handles.Tog_View_Axes  ,'Callback',@(~,~)dynvtool('set_dynvzaxe',fig, handles.Tog_View_Axes));
        end

        % Add Context Sensitive Help (CSHelp).
        %-------------------------------------
        hdl_DYNV_ZOOM = [ ...     
                handles.Pus_ZoomXPlus,  handles.Pus_ZoomXMinus,  ... 
                handles.Pus_ZoomYPlus,  handles.Pus_ZoomYMinus,  ... 
                handles.Pus_ZoomXYPlus, handles.Pus_ZoomXYMinus  ...
            ];
        hdl_DYNV_INFO = [ ...
                handles.Fra_Info, handles.Txt_Info,  ...
                handles.Edi_PosX, handles.Edi_PosY   ...
            ];
        hdl_DYNV_HIST = [ ...        
                handles.Fra_Hist,       handles.Txt_History,     ...
                handles.Pus_Hist_Init,  handles.Pus_Hist_Prev, handles.Pus_Hist_Next,   ...
                handles.Tog_View_Axes   ...
            ];
        hdl_DYNV_ZAXE = handles.Tog_View_Axes;
        wfighelp('add_ContextMenu',fig,hdl_DYNV_ZOOM,'DYNV_ZOOM');
        wfighelp('add_ContextMenu',fig,hdl_DYNV_INFO,'DYNV_INFO');
        wfighelp('add_ContextMenu',fig,hdl_DYNV_HIST,'DYNV_HIST');
        wfighelp('add_ContextMenu',fig,hdl_DYNV_ZAXE,'DYNV_ZAXE');
        %-------------------------------------
        
        % Store the Memory Bloc.
        %-----------------------
        dynvtool('wmb',fig,dVTmemB);
        if nargout>0 
            varargout{1} = get(handles.Fra_DynVTool,'Position');
        end
  
    case {'init','attach','go'}
        %********************************************************%
        %** OPTION = 'attach' CREATION OU MODIFICATION         **%
        %** OPTION = 'init'   CREATION OU MODIFICATION et PUT  **%
        %** OPTION = 'go'     RELANCE DU MODULE APRES UN STOP  **%
        %********************************************************%
        try 
            dynvtool('get',fig,0'); mngmbtn('delLines',fig,'All'); 
        catch %#ok<CTCH>
        end
        %------------------------ Defaults ----------------------%
        def_ZoomColor = 'r';
        g_ind   = []; g_cmd   = []; g_act   = []; cont_xy = [0 0];
        fcn_put = ''; fcn_get = ''; fcn_wri = ''; par_wri = [];
        fcn_sel = ''; par_sel = []; cbox    = def_ZoomColor;
        inputs = {...
                g_ind,g_cmd,g_act,cont_xy,fcn_put,fcn_get,...
                fcn_wri,par_wri,fcn_sel,par_sel,cbox...
                };
        %----------------------- test inputs ---------------------%
        nbin = nargin-2;
        if nbin>0
            inputs(1:nbin) = varargin;
            g_ind   = inputs{1}; g_cmd = inputs{2}; g_act = inputs{3};
            cont_xy = inputs{4};
            fcn_put = inputs{5};
            fcn_get = inputs{6};
            fcn_wri = inputs{7};
            par_wri = inputs{8};
            fcn_sel = inputs{9};
            par_sel = inputs{10};
            cbox    = inputs{11};
        end
        if isempty(fcn_wri) , fcn_wri = 'mngcoor'; end
        Act_Axes = [g_cmd g_act];
        %--------------------------------------------------------%
        dVTmemB       = dynvtool('rmb',fig);
        Fra_DynVTool  = dVTmemB.handles.Fra_DynVTool;
        Edi_PosX = dVTmemB.handles.Edi_PosX;
        Edi_PosY = dVTmemB.handles.Edi_PosY;
        if strcmp(get(Fra_DynVTool,'Visible'),'on')
            DynV_Status = 1;
        else
            DynV_Status = 0;
        end
        if DynV_Status && (~isempty(g_ind) || ~isempty(Act_Axes))
            set(fig,'Interruptible','On');
            action = @(~,~)mngmbtn('down',fig);
            set(fig,'WindowButtonDownFcn',action);
        end
        dVTmemB.linColor = cbox;
        dVTmemB.axeInd   = g_ind;
        dVTmemB.axeCmd   = g_cmd;
        dVTmemB.axeAct   = Act_Axes;
        dVTmemB.xyConst  = cont_xy;
        dynvtool('wmb',fig,dVTmemB);

        if strcmp(option,'go')
            dynvtool('get',fig,0);
            set(Edi_PosX,'String','X = ');
            set(Edi_PosY,'String','Y = ');
        else
            dynvtool('ini_his',fig,fcn_put,fcn_get);
        end

        mempos_coor = wmemutil('add',[],fcn_wri);
        mempos_coor = wmemutil('add',mempos_coor,double(par_wri));
        mempos_coor = wmemutil('add',mempos_coor,fcn_sel);
        mempos_coor = wmemutil('add',mempos_coor,double(par_sel));
        set(Edi_PosX,'UserData',mempos_coor);
        set(Edi_PosY,'UserData',mempos_coor);

        if strcmp(option,'init') , dynvtool('put',fig); end

        %-------------- Storage of parameters --------------%
        if isempty(g_ind) && isempty(g_cmd) , return; end
        params = [];
        params = wmemutil('add',params,double(g_ind));
        params = wmemutil('add',params,double(g_cmd));
        params = wmemutil('add',params,double(g_act));
        params = wmemutil('add',params,cont_xy);
        params = wmemutil('add',params,fcn_put);
        params = wmemutil('add',params,fcn_get);
        params = wmemutil('add',params,fcn_wri);
        params = wmemutil('add',params,double(par_wri));
        params = wmemutil('add',params,fcn_sel);
        params = wmemutil('add',params,double(par_sel));
        params = wmemutil('add',params,cbox);
        VdynData = get(Fra_DynVTool,'UserData');
        ind = wmemutil('ind',VdynData,params);
        if ind==1 , return; end
        max_stack = 3;
        tmp = [];
        tmp = wmemutil('add',tmp,params);
        nb = 1; k=1;
        while (k<=max_stack+ind) && (nb<=max_stack) 
            if k~=ind
                tmp = wmemutil('add',tmp,wmemutil('get',VdynData,k));
                nb  = nb+1;
            end
            k = k+1;
        end
        VdynData = tmp;
        set(Fra_DynVTool,'UserData',VdynData);
		dynvtool('set_BtnOnOff',fig,'On','Init')
		% dynvtool('dynvzaxe_BtnOnOff',fig,'On')

    case 'on'
        %***************************************%
        %** OPTION = 'on' CONNECTER LE MODULE **%
        %***************************************%
        if nargin<3 , ini = 0; else ini = varargin{1}; end
        if ini , dynvtool('get',fig,0,1); end
        dVTmemB = dynvtool('rmb',fig);
        Fra_DynVTool = dVTmemB.handles.Fra_DynVTool;
        VdynData = get(Fra_DynVTool,'UserData');
        if ~isempty(VdynData)
            continu = 1;
            params = wmemutil('get',VdynData);
            [g_ind,params]   = wmemutil('get',params);
            [g_cmd,params]   = wmemutil('get',params);
            [g_act,params]   = wmemutil('get',params);
            [cont_xy,params] = wmemutil('get',params);
            [fcn_put,params] = wmemutil('get',params);
            [fcn_get,params] = wmemutil('get',params);
            [fcn_wri,params] = wmemutil('get',params);
            [par_wri,params] = wmemutil('get',params);
            [fcn_sel,params] = wmemutil('get',params);
            [par_sel,params] = wmemutil('get',params);
            cbox             = wmemutil('get',params);
        else
            continu = 0;
            g_ind = []; g_cmd = []; g_act = []; 
        end
        dynvaxes = [g_ind g_cmd g_act];
        figaxes = findobj(get(fig,'Children'),'flat','Type','axes');
        if ~isempty(setdiff(dynvaxes,figaxes)) , continu = 0; end 
        if continu
            mngmbtn('delLines',fig,'All',dVTmemB);
            set(Fra_DynVTool,'UserData',VdynData);
            dynvtool('go',fig,g_ind,g_cmd,g_act,cont_xy,...
                    fcn_put,fcn_get,fcn_wri,par_wri,fcn_sel,par_sel,cbox);
        else
            dynvtool('attach',fig);
        end

    case 'stop'
        %**********************************************************%
        %** OPTION = 'stop'  REINITIALISATION ET ARRET DU MODULE **%
        %**********************************************************%
        if nargin<3 , ini = 1; else ini = varargin{1}; end
        dynvtool('get',fig,0);
        if ini , dynvtool('ini_his',fig); end
        
        winfcn  = get(fig,'WindowButtonDownFcn');
        if compareCallbacks(winfcn, dynvfcn)
            set(fig,'WindowButtonDownFcn','');
        end
        mngmbtn('delLines',fig,'All');

    case 'fcn_w'
        %*******************************************************%
        %** OPTION = 'fcn_w' CHANGE THE WRITING FUNCTION      **%
        %*******************************************************%
        dVTmemB       = dynvtool('rmb',fig);
        Fra_DynVTool  = dVTmemB.handles.Fra_DynVTool;
        Edi_PosX = dVTmemB.handles.Edi_PosX;
        Edi_PosY = dVTmemB.handles.Edi_PosY;
        VdynData      = get(Fra_DynVTool,'UserData');
        if isempty(VdynData) , return; end
        [params,VdynData] = wmemutil('get',VdynData);
        [g_ind,params]   = wmemutil('get',params);
        [g_cmd,params]   = wmemutil('get',params);
        [g_act,params]   = wmemutil('get',params);
        [cont_xy,params] = wmemutil('get',params);
        [fcn_put,params] = wmemutil('get',params);
        [fcn_get,params] = wmemutil('get',params);
        [fcn_wri,params] = wmemutil('get',params); %#ok<ASGLU>
        [par_wri,params] = wmemutil('get',params); %#ok<ASGLU>
        [fcn_sel,params] = wmemutil('get',params);
        [par_sel,params] = wmemutil('get',params);
        cbox             = wmemutil('get',params);
        fcn_wri = varargin{1};
        if nargin==4 , par_wri = varargin{2}; else par_wri = []; end 
        if isempty(fcn_wri) , fcn_wri='mngcoor'; end
        mempos_coor = wmemutil('add',[],fcn_wri);
        mempos_coor = wmemutil('add',mempos_coor,par_wri);
        mempos_coor = wmemutil('add',mempos_coor,fcn_sel);
        mempos_coor = wmemutil('add',mempos_coor,par_sel);

        set(Edi_PosX,'UserData',mempos_coor);
        set(Edi_PosY,'UserData',mempos_coor);
        params = [];
        params = wmemutil('add',params,g_ind);
        params = wmemutil('add',params,g_cmd);
        params = wmemutil('add',params,g_act);
        params = wmemutil('add',params,cont_xy);
        params = wmemutil('add',params,fcn_put);
        params = wmemutil('add',params,fcn_get);
        params = wmemutil('add',params,fcn_wri);
        params = wmemutil('add',params,par_wri);
        params = wmemutil('add',params,fcn_sel);
        params = wmemutil('add',params,par_sel);
        params = wmemutil('add',params,cbox);
        VdynData = wmemutil('add',VdynData,params,'top');
        set(Fra_DynVTool,'UserData',VdynData);

    case 'close'
        %********************************************%
        %** OPTION = 'close' DESTRUCTION DU MODULE **%
        %********************************************%
        dVTmemB = dynvtool('rmb',fig);
        if isempty(dVTmemB) ,  return; end
        Fra_DynVTool = dVTmemB.handles.Fra_DynVTool;
        if ~isempty(Fra_DynVTool) , set(Fra_DynVTool,'UserData',''); end
        mngmbtn('delLines',fig,'All',dVTmemB);

    case 'visible'
        dVTmemB = dynvtool('rmb',fig);
        if isempty(dVTmemB) , return; end
        handles = struct2cell(dVTmemB.handles);
        handles = cat(1,handles{:});
        vis = varargin{1};
        set(handles,'Visible',vis);
        switch vis
          case 'off' , dynvtool('stop',fig,0);
          case 'on'  , dynvtool('on',fig,1);
        end

    case 'hide'
        dVTmemB = dynvtool('rmb',fig);
        if isempty(dVTmemB) , return; end
        handles = struct2cell(dVTmemB.handles);
        handles = cat(1,handles{:});
        if ~isempty(handles)
            winfcn  = get(fig,'WindowButtonDownFcn');
            if compareCallbacks(winfcn, dynvfcn)
                set(fig,'WindowButtonDownFcn','');
            end
            mngmbtn('delLines',fig,'All',dVTmemB);
            set(handles,'Visible','off');
        end

    case 'show'
        dVTmemB = dynvtool('rmb',fig);
        if isempty(dVTmemB) , return; end
        handles = struct2cell(dVTmemB.handles);
        handles = cat(1,handles{:});
        if ~isempty(handles)
            set(fig,'WindowButtonDownFcn',dynvfcn);
            set(handles,'Visible','on');
        end

    case 'set_BtnOnOff'
		ena_Val = varargin{1};
		typCall = varargin{2};				
        dVTmemB = dynvtool('rmb',fig);
        if isempty(dVTmemB) , return; end
        if ~isfield(dVTmemB,'Enable_Style') , return; end
		switch dVTmemB.Enable_Style
			case 0 , if ~isequal(typCall,'Init'), return; end
			case 1 
                if isequal(typCall,'Init')
                    dynvtool('dynvzaxe_BtnOnOff',fig,'On')
                    return;
                end
		end
        handles = dVTmemB.handles;
		zoomBtn = [...
				handles.Pus_ZoomXPlus ;  handles.Pus_ZoomYPlus;  handles.Pus_ZoomXYPlus; ...
				handles.Pus_ZoomXMinus ; handles.Pus_ZoomYMinus; handles.Pus_ZoomXYMinus  ...
				];
		centerBtn = [handles.Pus_CenterX ; handles.Pus_CenterY ; handles.Txt_Center];
		ediCenter = handles.Edi_Center;
		infoBtn   = [handles.Edi_PosX ; handles.Edi_PosY];
		infoTxt   = handles.Txt_Info;
		Txt_History = handles.Txt_History;
		Tog_View_Axes = dVTmemB.handles.Tog_View_Axes;
		
		switch typCall
			case 'Init'
				btn = [zoomBtn ; centerBtn ; ediCenter; ...
					   infoTxt ; infoBtn ; Txt_History ; Tog_View_Axes];
                set(btn,'Enable',ena_Val);
                set(infoBtn,'Enable','Inactive');
			
			case 'All'
                set([zoomBtn ; centerBtn ; infoTxt],'Enable',ena_Val);
                if isequal(lower(ena_Val),'off')
                    set(ediCenter,'String','');
                    set(infoBtn(1),'String','X = ');
                    set(infoBtn(2),'String','Y = ');
                end
                set(infoBtn,'Enable','Inactive');

			case 'Zoom'
                set(zoomBtn,'Enable',ena_Val);

			case 'Center'
				set(centerBtn,'Enable',ena_Val);
				if isequal(lower(ena_Val),'off')
					set(ediCenter,'String','');
				end
				
			case 'Info'
                set(infoTxt,'Enable',ena_Val);
                if isequal(lower(ena_Val),'off')
                    set(infoBtn(1),'String','X = ');
                    set(infoBtn(2),'String','Y = ');
                end
                set(infoBtn,'Enable','Inactive');
		end	

    case 'dynvzaxe_BtnOnOff'
        dVTmemB = dynvtool('rmb',fig);
        if isempty(dVTmemB) , return; end	
        Tog_View_Axes = dVTmemB.handles.Tog_View_Axes;
		if length(varargin)<1
			ax = wfindobj(get(fig,'Children'), ...
							'flat','Type','axes','Visible','on');
			if length(ax)<=1 , ena_Val = 'Off'; else ena_Val = 'On'; end
		else
			ena_Val = varargin{1};	
		end
		set(Tog_View_Axes,'Enable',ena_Val);
        
    case 'set_dynvzaxe'
        % tog = varargin{1};
		figPos  = get(fig,'Position');
        figUnit = get(fig,'Units');
        if isequal(lower(figUnit(1:3)),'pix')
            Ymax = figPos(4);
        else
            Ymax = 1;
        end
        handles = dynvtool('handles',fig);
        tog = findobj(fig,'Tag','Tog_View_Axes');
		dynVPos = get(handles.Fra_DynVTool,'Position');
		graPos  = [dynVPos(1),dynVPos(4)*1.05,dynVPos(3),Ymax-dynVPos(4)*1.05];
		dynvzaxe('ini',fig,graPos,tog)
        
    case 'edi_center'
        edi = varargin{1};
        if ~ishandle(edi)
            handles = guihandles(gcbf);
            edi = handles.Edi_Center;
        end
        strval = get(edi,'String');
        [val_centre,count,err] = sscanf(strval,'%f'); %#ok<ASGLU>
        if count==1 && isempty(err)
            ena_Val = 'On'; 
        else
            ena_Val = 'Off';
        end
        dynvtool('set_BtnOnOff',fig,ena_Val,'Center');
        
	otherwise
        %********************%
        %** UNKNOWN OPTION **%
        %********************%
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

%======================================================================%
% INTERNAL FUNCTIONS: DYNVTOOL CONSTRUCTION
%======================================================================%
function [handles,dynVPos] = CreateDynVTool(fig,varargin)
% in3 = xprop (optional)
% in4 = zoom_axe on/off (optional)
%---------------------------------

Enable_Style = 0;

% Get Globals.
%-------------
[ediActBkColor,ediInActBkColor,fraBkColor,shadowColor,uicFontSize] = ...
    mextglob('get','Def_Edi_ActBkColor','Def_Edi_InActBkColor',...
    'Def_FraBkColor','Def_ShadowColor','Def_UicFontSize');

if nargin<2
    pos = [0 0 1];
    okZoomAxe = 1;
elseif  nargin<3
    pos = [0 0 varargin{1}];
    okZoomAxe = 1;
else
    pos = [0 0 varargin{1}];
    okZoomAxe = varargin{2};
end

fig_units = 'pixels';
old_fig_units = get(fig,'Units');
if ~isequal(old_fig_units,fig_units)
    set(fig,'Units',fig_units)
end
flgTool      = 1+2+4+8+16;
flgTool      = bitset(flgTool,5,okZoomAxe);
[posUIC,infoFontSize] = getHorPos(fig,pos,flgTool);
JJ           = 1;
dynVPos      = posUIC(JJ,:); JJ = JJ+1;
pos_btngx    = posUIC(JJ,:); JJ = JJ+1;
pos_btndx    = posUIC(JJ,:); JJ = JJ+1;
pos_btngy    = posUIC(JJ,:); JJ = JJ+1;
pos_btndy    = posUIC(JJ,:); JJ = JJ+1;
pos_btngxy   = posUIC(JJ,:); JJ = JJ+1;
pos_btndxy   = posUIC(JJ,:); JJ = JJ+1;

pos_fracent  = posUIC(JJ,:); JJ = JJ+1;
pos_txtcent  = posUIC(JJ,:); JJ = JJ+1;
pos_btncx    = posUIC(JJ,:); JJ = JJ+1;
pos_btncy    = posUIC(JJ,:); JJ = JJ+1;
pos_edcent   = posUIC(JJ,:); JJ = JJ+1;

pos_frapos   = posUIC(JJ,:); JJ = JJ+1;
pos_txtpos   = posUIC(JJ,:); JJ = JJ+1;
pos_btn_xpos = posUIC(JJ,:); JJ = JJ+1;
pos_btn_ypos = posUIC(JJ,:); JJ = JJ+1;
pos_frahis   = posUIC(JJ,:); JJ = JJ+1;
pos_txthis   = posUIC(JJ,:); JJ = JJ+1;
pos_hinit    = posUIC(JJ,:); JJ = JJ+1;
pos_hprev    = posUIC(JJ,:); JJ = JJ+1;
pos_hnext    = posUIC(JJ,:); JJ = JJ+1;
pos_btnzaxe  = posUIC(JJ,:);

if ~isequal(get(0,'CurrentFigure'),fig) , figure(fig); end

comFigProp = {'Parent',fig,'Units',fig_units};
comFraProp = [comFigProp,'Style','Frame'];
comPusProp = [comFigProp,'Style','pushbutton'];
comEdiProp = [comFigProp,'Style','Edit','FontSize',uicFontSize];
Fra_DynVTool = uicontrol(...
    comFigProp{:},                  ...
    'Style','Frame',                ...
    'Position',dynVPos,             ...
    'ForegroundColor',shadowColor,  ...
    'BackgroundColor',fraBkColor    ...
    );

switch Enable_Style
    case -1
        ena_Zoom = 'On'; ena_Cent = 'On';
        ena_Info = 'On'; ena_Hist = 'On';
    case {0,1}
        ena_Zoom = 'Off'; ena_Cent = 'Off';	
        ena_Info = 'Off'; ena_Hist = 'Off';
end

if bitget(flgTool,1)
    action  = @(~,~)dynvtool('zoom+', fig ,[1 0]);
    Pus_ZoomXPlus   = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btngx, ...
        'String','X+',        ...
        'TooltipString',getWavMSG('Wavelet:commongui:Dynv_ZoomInX'),...
        'Enable',ena_Zoom,    ...
        'Tag','Pus_ZoomXPlus',...
        'Callback',action     ...
    );
    action  = @(~,~)dynvtool('zoom-', fig ,[1 0]);
    Pus_ZoomXMinus   = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btndx, ...
        'String','X-',        ...
        'TooltipString',getWavMSG('Wavelet:commongui:Dynv_ZoomOutX'),...
        'Enable',ena_Zoom,    ...
        'Tag','Pus_ZoomXMinus',...        
        'Callback',action     ...
    );
    action  = @(~,~)dynvtool('zoom+', fig ,[0 1]);
    Pus_ZoomYPlus   = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btngy, ...
        'String','Y+',        ...
        'TooltipString',getWavMSG('Wavelet:commongui:Dynv_ZoomInY'),...
        'Enable',ena_Zoom,    ...
        'Tag','Pus_ZoomYPlus',...        
        'Callback',action     ...
    );
    action  = @(~,~)dynvtool('zoom-', fig ,[0 1]);
    Pus_ZoomYMinus   = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btndy, ...
        'String','Y-',        ...
        'TooltipString',getWavMSG('Wavelet:commongui:Dynv_ZoomOutY'),...
        'Enable',ena_Zoom,    ...
        'Tag','Pus_ZoomYMinus',...        
        'Callback',action     ...
    );
    action  = @(~,~)dynvtool('zoom+', fig ,[1 1]);
    Pus_ZoomXYPlus  = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btngxy,...
        'String','XY+',       ...
        'TooltipString',getWavMSG('Wavelet:commongui:Dynv_ZoomInXY'),...
        'Enable',ena_Zoom,    ...
        'Tag','Pus_ZoomXYPlus',...                
        'Callback',action     ...
    );
    action  = @(~,~)dynvtool('zoom-', fig ,[1 1]);
    Pus_ZoomXYMinus  = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btndxy,...
        'String','XY-',       ...
        'TooltipString',getWavMSG('Wavelet:commongui:Dynv_ZoomOutXY'),...
        'Enable',ena_Zoom,    ...
        'Tag','Pus_ZoomXYMinus',...                
        'Callback',action     ...
    );
else
    Pus_ZoomXPlus   = [];   Pus_ZoomXMinus   = [];
    Pus_ZoomYPlus   = [];   Pus_ZoomYMinus   = [];
    Pus_ZoomXYPlus  = [];   Pus_ZoomXYMinus  = [];
end

if bitget(flgTool,2)
    Fra_Center   = uicontrol(...
        comFraProp{:},               ...
        'Position',pos_fracent,      ...
        'ForegroundColor',shadowColor,  ...        
        'BackgroundColor',fraBkColor ...
        );
    
    strcent = {getWavMSG('Wavelet:commongui:Dynv_Center') , ...
        getWavMSG('Wavelet:commongui:Dynv_On')};
    Txt_Center    = uicontrol(...
        comFigProp{:},                ...
        'Style','Text',               ...
        'BackgroundColor',fraBkColor, ...
        'Position',pos_txtcent,       ...
        'Enable',ena_Cent,            ...
        'String',strcent              ...
    );   
    Edi_Center = uicontrol(...
        comEdiProp{:},                    ...
        'BackgroundColor',ediActBkColor,  ...
        'Tag','Edi_Center',...                        
        'Position',pos_edcent             ...
    );
    ediStr = (Edi_Center);
    cbFunc = @(~,~)dynvtool('edi_center', fig, ediStr );    
    set(Edi_Center,'Callback',cbFunc);
    
    Pus_CenterX  = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btncx, ...
        'Enable',ena_Cent,    ...
        'Tag','Pus_CenterX',  ...                        
        'String','X'          ...
        );
    Pus_CenterY  = uicontrol(...
        comPusProp{:},        ...
        'Position',pos_btncy, ...
        'Enable',ena_Cent,    ...
        'Tag','Pus_CenterY',  ...                                
        'String','Y'          ...
        );
    

    set(Pus_CenterX,'Callback',@(~,~)dynvtool('center', fig, ediStr, 0));
    set(Pus_CenterY,'Callback',@(~,~)dynvtool('center', fig, ediStr, 1));
else
    Fra_Center = []; Txt_Center = [];
    Edi_Center = []; Pus_CenterX = []; Pus_CenterY = [];
end

if bitget(flgTool,3)
    Fra_Info = uicontrol(...
        comFraProp{:},               ...
        'Style','Frame',             ...
        'Units',fig_units,            ...
        'Position',pos_frapos,       ...
        'Tag','Fra_Info',            ... 
        'ForegroundColor',shadowColor,  ...
        'BackgroundColor',fraBkColor ...
        );
    Txt_Info = uicontrol(...
        'Parent',fig,                   ...
        'Style','Text',                 ...
        'Units',fig_units,               ...
        'Enable',ena_Info,              ...
        'BackgroundColor',fraBkColor,   ...
        'Position',pos_txtpos,          ...
        'Tag','Txt_Info',               ...                                
        'String',{' ',getWavMSG('Wavelet:commongui:Dynv_Info'),' '} ...
        );
    Edi_PosX = uicontrol(...
        comEdiProp{:},                  ...
        'FontSize',infoFontSize,        ...
        'BackgroundColor',ediInActBkColor,...
        'Enable',ena_Info,              ...
        'Position',pos_btn_xpos,        ...
        'String','X = ',                ...
        'Tag','Edi_PosX',               ...                                        
        'HorizontalAlignment','center'  ...
        );
    Edi_PosY = uicontrol(...
        comEdiProp{:},                  ...
        'FontSize',infoFontSize,        ...        
        'BackgroundColor',ediInActBkColor,...
        'Enable',ena_Info,              ...
        'Position',pos_btn_ypos,        ...
        'String','Y = ',                ...
        'Tag','Edi_PosY',               ...                                                
        'HorizontalAlignment','center'  ...
        );
else
    Fra_Info = []; Txt_Info = [];
    Edi_PosX = []; Edi_PosY = [];
end

if bitget(flgTool,4)
    Fra_Hist = uicontrol(...
        comFraProp{:},                  ...
        'Position',pos_frahis,          ...
        'Tag','Fra_Hist',               ...
        'ForegroundColor',shadowColor,  ...
        'BackgroundColor',fraBkColor    ...
        );
    
    Txt_History = uicontrol(...
        'Parent',fig,                   ...
        'Style','Text',                 ...
        'Units',fig_units,              ...
        'BackgroundColor',fraBkColor,   ...
        'Position',pos_txthis,          ...
        'Enable',ena_Hist,              ...
        'Tag','Txt_History',            ...                        
        'String',{' ',getWavMSG('Wavelet:commongui:Dynv_History'),' '} ...
        );
    
    action = @(~,~)dynvtool('get', fig ,0);
    Pus_Hist_Init = uicontrol(...
        comPusProp{:},          ...
        'Position',pos_hinit,   ...
        'Enable','Off',         ...
        'String','<<-',         ...
        'FontWeight','bold',    ...
        'Tag','Pus_Hist_Init',  ...                        
        'Callback',action       ...
    );
    action         = @(~,~)dynvtool('get', fig,-1);
    Pus_Hist_Prev  = uicontrol(...
        comPusProp{:},          ...
        'Position',pos_hprev,   ...
        'Enable','Off',         ...
        'String','<-',          ...
        'FontWeight','bold',    ...
        'Tag','Pus_Hist_Prev',  ...                
        'Callback',action       ...
    );
    action         = @(~,~)dynvtool('get', fig, 1);
    Pus_Hist_Next  = uicontrol(...
        comPusProp{:},          ...
        'Position',pos_hnext,   ...
        'Enable','Off',         ...
        'String','->',          ...
        'FontWeight','bold',    ...
        'Tag','Pus_Hist_Next',  ...        
        'Callback',action       ...
    );
    set(Pus_Hist_Init,'UserData',[ '[]'; '[]' ]);
    set(Pus_Hist_Prev,'UserData','');
    set(Pus_Hist_Next,'UserData','');
else
    Fra_Hist = [];
    Pus_Hist_Init =  [];  Pus_Hist_Prev = []; Pus_Hist_Next = [];
end
if bitget(flgTool,5)
    Tog_View_Axes = uicontrol(...
        comFigProp{:},         ...
        'Style','Togglebutton', ...
        'Position',pos_btnzaxe, ...
        'String',getWavMSG('Wavelet:commongui:Dynv_ViewAxes'),   ...
        'Tag','Tog_View_Axes',  ...        
        'Enable','Off'          ...
        );
    action = @(~,~)dynvtool('set_dynvzaxe', fig);
    set(Tog_View_Axes,'Callback',action);
else
    Tog_View_Axes = [];
end

if ~isequal(old_fig_units,fig_units)
    set(fig,'Units',old_fig_units)
end

values = {...
        Fra_DynVTool,   ...
        Pus_ZoomXPlus,  Pus_ZoomXMinus,  ... 
        Pus_ZoomYPlus,  Pus_ZoomYMinus,  ... 
        Pus_ZoomXYPlus, Pus_ZoomXYMinus, ... 
        Fra_Center,     Txt_Center,      ...
        Pus_CenterX,    Pus_CenterY,     ...
        Edi_Center,     ...
        Fra_Info,       Txt_Info,        ...
        Edi_PosX,       Edi_PosY,        ...
        Fra_Hist,       Txt_History,     ...
        Pus_Hist_Init,  Pus_Hist_Prev, Pus_Hist_Next,   ...
        Tog_View_Axes   ...
};
fields = {...
        'Fra_DynVTool',                      ...
        'Pus_ZoomXPlus',  'Pus_ZoomXMinus',  ... 
        'Pus_ZoomYPlus',  'Pus_ZoomYMinus',  ...
        'Pus_ZoomXYPlus', 'Pus_ZoomXYMinus', ...
        'Fra_Center',     'Txt_Center',      ...
        'Pus_CenterX',    'Pus_CenterY',     ...
        'Edi_Center',  ...
        'Fra_Info', 'Txt_Info',  ...
        'Edi_PosX', 'Edi_PosY'   ...
        'Fra_Hist', 'Txt_History',  'Pus_Hist_Init', ...
        'Pus_Hist_Prev', 'Pus_Hist_Next', ...
        'Tog_View_Axes'  ...
    };
handles = cell2struct(values,fields,2);
%-----------------------------------------------------------------------------%
function [posUIC,infoFontSize] = getHorPos(fig,pos,flags)

% Get Globals.
%-------------
[heightBtn,xSpacing,ySpacing] = ...
    mextglob('get','Def_Btn_Height','X_Spacing','Y_Spacing');
[plusWidth,d_WidthMax,infoFontSize] = wtbutils('dynV_PREFS');

okZoomTool = bitget(flags,1);
okCentTool = bitget(flags,2);
okInfoTool = bitget(flags,3);
okHistTool = bitget(flags,4);
okZAxeTool = bitget(flags,5);

posUIC  = zeros(23,4);
pos_f   = get(fig,'Position');
lmax    = pos(3);
if (lmax>1) || (lmax<0.5) , lmax = 1; end
lmax    = ceil(lmax*pos_f(3));

% Widths of Uicontrols.
inBox  = 1;            % Flag (buttons inside frame) 
large  = 150; %180
wid(1) = large/5;      % width for Zoom buttons.
wid(2) = large/3.5;    % width for Center text.
wid(3) = large/6;      % width for Center buttons.
wid(4) = large/5;      % width for Info text  (1).
wid(5) = large/3.2;    % width for Info texts (2).
wid(6) = large/3.5;    % width for History text.
wid(7) = large/7;      % width for History buttons.
wid(8) = large/2;      % width for View Axes buttons.
if ~okZAxeTool , wid(8) = 0; end
bdx     = min([xSpacing,4]);
bdcadx  = bdx;
margex  = 2*bdcadx+4*bdx;
lcad    = 3*wid(1)+wid(2)+2*wid(3)+wid(4)+wid(5)+wid(6)+2*wid(7)+wid(8)+margex;
deltaW  = lmax-lcad;
if abs(deltaW)>sqrt(eps)
    if deltaW<d_WidthMax
        sum1 = (margex+3*wid(1)+2*wid(3)+2*wid(7)+wid(8));
        sum2 = wid(2)+wid(4)+wid(5)+wid(6);
        if deltaW>=0
            mul = (lmax-sum1)/sum2;
            ind = [2,4,5,6];
            wid(ind) = wid(ind)*mul;
        else
            mul = (lmax-sum2)/sum1;
            ind = [1,3,7,8];
            wid(ind) = wid(ind)*mul;
        end
    else
        mul = lmax/lcad;
        wid = wid*mul;
        bdcadx = bdcadx*mul;
        bdx = bdx*mul;
        margex = margex*mul;
    end
    lcad = 3*wid(1)+wid(2)+2*wid(3)+wid(4)+wid(5)+wid(6)+2*wid(7)+wid(8)+margex;
end
lcad = lcad + plusWidth;

wid(1) = floor(wid(1));
wid(2) = floor(wid(2));
wid(3) = floor(wid(3));
wid(4) = floor(wid(4));
wid(6) = floor(wid(6));
wid(7) = floor(wid(7));
wid(8) = floor(wid(8));
wid(5) = lcad-3*wid(1)-wid(2)-2*wid(3)-wid(4)-wid(6)-2*wid(7)-wid(8)-margex;

bdy    = min([ySpacing,4]);
bdcady = bdy;
haut   = heightBtn;
hautX2 = 2*haut;
hcad   = hautX2+2*bdcady;

JJ = 0;
JJ = JJ+1; posUIC(JJ,:) = [pos(1) pos(2) lcad hcad];        % pos_FraDV

xl = posUIC(1,1)+bdcadx;
yh = posUIC(1,2)+hcad-bdcady-haut;
if okZoomTool
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh,wid(1),haut];              % pos_btngx
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh-haut,wid(1),haut];         % pos_btndx
    JJ = JJ+1; posUIC(JJ,:) = [xl+wid(1),yh,wid(1),haut];       % pos_btngy
    JJ = JJ+1; posUIC(JJ,:) = [xl+wid(1),yh-haut,wid(1),haut];  % pos_btndy
    JJ = JJ+1; posUIC(JJ,:) = [xl+2*wid(1),yh,wid(1),haut];     % pos_btngxy
    JJ = JJ+1; posUIC(JJ,:) = [xl+2*wid(1),yh-haut,wid(1),haut];% pos_btndxy
    xl = xl+3*wid(1)+bdx;
end

if okCentTool
    if inBox
        wfra = wid(2)+2*wid(3); dy = bdy/2; hedi = haut-bdy;
    else
        wfra = wid(2); dy = 0; hedi = haut-bdy/2;         %#ok<*UNRCH>
    end
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh-haut,wfra,hautX2];   % pos_fracent
    JJ = JJ+1; 
    posUIC(JJ,:) = [xl+bdx/2,yh-haut+bdy/4,...
                    wid(2)-bdx,hautX2-2*bdy];             % pos_txtcent

    xl = xl+wid(2)-inBox*bdx;
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh,wid(3),haut-dy];        % pos_btncx
    JJ = JJ+1; posUIC(JJ,:) = [xl+wid(3),yh,wid(3),haut-dy]; % pos_btncy
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh-haut+dy+1,2*wid(3),hedi]; % pos_edcent
    xl = xl+2*wid(3)+bdx+inBox*bdx;
end

if okInfoTool
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh-haut,wid(4)+wid(5),hautX2];   % pos_frapos
    JJ = JJ+1; 
    posUIC(JJ,:) = [xl+bdx/2,yh-haut+bdy/2,wid(4)-bdx,hautX2-bdy]; % pos_txtpos
    xl = xl+wid(4)+bdx/2;
    JJ = JJ+1;
    posTMP = [xl+bdx/2,yh+bdy/2,wid(5)-2*bdx,haut-bdy]; 
    posUIC(JJ,:) = posTMP;                                 % pos_btn_xpos
    JJ = JJ+1;
    posUIC(JJ,:) = posTMP; posUIC(JJ,2) = yh-haut+bdy/2+1; % pos_btn_ypos 
    xl = xl+wid(5)+bdx;
end

if okHistTool
    if inBox , wfra = wid(6)+2*wid(7); dy = bdy/2;
    else wfra = wid(6); dy = 0; 
    end
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh-haut,wfra,hautX2];           % pos_frahis
    JJ = JJ+1; posUIC(JJ,:) = [xl+bdx/2,yh-haut+bdy/2,...
                                    wid(6)-bdx,hautX2-bdy];       % pos_txthis
    xlBtn = xl+wid(6)-inBox*bdx;
    JJ = JJ+1; posUIC(JJ,:) = [xlBtn,yh-haut+dy,2*wid(7),haut-dy];% pos_hinit
    JJ = JJ+1; posUIC(JJ,:) = [xlBtn,yh,wid(7),haut-dy];          % pos_hprev
    JJ = JJ+1; posUIC(JJ,:) = [xlBtn+wid(7),yh,wid(7),haut-dy];   % pos_hnext
    xl = xl+wid(6)+2*wid(7)+bdx;
end

if okZAxeTool
    JJ = JJ+1; posUIC(JJ,:) = [xl,yh-haut,wid(8),hautX2];     % pos_btnzaxe
end
%=============================================================================%

function t = compareCallbacks(winfcn, dynvfcn)
t = ~isempty(winfcn);
if t && isa(winfcn, 'function_handle')
    if isa(dynvfcn, 'function_handle')
        t = isequal(func2str(winfcn),func2str(dynvfcn));
    else
        t = false;
    end
elseif t && ischar(winfcn)
    if ischar(dynvfcn)
        t = isequal(winfcn,dynvfcn);
    else
        t = false;
    end
end
