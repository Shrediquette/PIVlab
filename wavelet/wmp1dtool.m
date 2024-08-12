function varargout = wmp1dtool(varargin)
%WMP1DTOOL New wavelet for continuous analysis tool.
%   VARARGOUT = WMP1DTOOL(VARARGIN)

% WMP1DTOOL MATLAB file for wmp1dtool.fig
%      WMP1DTOOL, by itself, creates a new WMP1DTOOL or raises the existing
%      singleton*.
%
%      H = WMP1DTOOL returns the handle to a new WMP1DTOOL or the handle to
%      the existing singleton*.
%
%      WMP1DTOOL('Property','Value',...) creates a new WMP1DTOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wmp1dtool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WMP1DTOOL('CALLBACK') and WMP1DTOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WMP1DTOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Copyright 1995-2020 The MathWorks, Inc.


% DDUX data logging
if  isempty(varargin) 
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "wmp1dtool";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end
%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmp1dtool_OpeningFcn, ...
                   'gui_OutputFcn',  @wmp1dtool_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before wmp1dtool is made visible.                     %
%*************************************************************************%
function wmp1dtool_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for wmp1dtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manually in the automatic generated code %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wmp1dtool_OutputFcn(hObject,eventdata,handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;
%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%
%--------------------------------------------------------------------------
function Pus_Approximate_Callback(hObject,eventdata,handles,arg) 

% Get figure handle.
%-------------------
hFig = handles.output;
if nargin<4 , arg = 'none'; end

% Cleaning.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
cleanTOOL('approx',[handles.Axe_ADD,handles.Axe_CFS,...
    handles.Axe_QUAL,handles.Axe_COMPO,handles.Pan_COMPO],handles);

% Computing.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Calling the Matching Pursuit Algorithm.
%----------------------------------------
hdl_DISP = [
    handles.Txt_TYP_DISP;handles.Pop_TYP_DISP;...
    handles.Txt_STP_PLOT;handles.Pop_STP_PLOT;handles.Txt_STP_PLOT_2 ...
    ];
toENA_OFF = [...
    hdl_DISP; ...
    get(handles.Pan_DICO,'Children'); ...
    get(handles.Pan_ADD_PAR,'Children'); ...
    get(handles.Pan_COMPO,'Children'); ...
    get(handles.Pan_ALG_PAR,'Children'); ...
    hObject; handles.Pop_Type_ALG ...
    ];
val = get(handles.Pop_Type_ALG,'Value');
if isequal(val,3) % WMP
    toENA_OFF = [toENA_OFF ; handles.Txt_Cfs_WMP; handles.Edi_Cfs_WMP]; 
end

toENA_OFF = toENA_OFF(~strcmp(get(toENA_OFF,'type'),'uipanel'));
set(toENA_OFF,'Enable','Off');
pause(0.05)

% Calling the Matching Pursuit Algorithm.
%----------------------------------------
wtbxappdata('set',hFig,'Init_Algo',0);
wtbxappdata('set',hFig,'Approx_Results',{});
[YFIT,R,COEFF,IOPT,qual] = wmpguifunc(handles,arg);
wtbxappdata('set',hFig,'Approx_Results',{YFIT,R,COEFF,IOPT,qual});
wtbxappdata('set',hFig,'Init_Algo',0);
set(toENA_OFF,'Enable','On');

% Init DynVTool.
%---------------
axe_IND = [handles.Axe_CFS , handles.Axe_QUAL];
axe_CMD = [handles.Axe_SIG , handles.Axe_ADD , handles.Axe_COMPO];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% get Menu Handles.
%------------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');

% Enable the Save synthesized signal Menu item.
%----------------------------------------------
set([hdl_Menus.m_save,hdl_Menus.m_exp_wrks],'Enable','on');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pop_Type_ALG_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
switch val
    case {1,2} , vis = 'Off';
    case 3 , vis = 'On';
end
set([handles.Txt_Cfs_WMP;handles.Edi_Cfs_WMP],'Visible',vis);
%-------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject, eventdata, handles)

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
hFig = get(hObject,'Parent');
if isequal(lower(ena_Save),'on')
    status = wwaitans({hFig,getWavMSG('Wavelet:wmp1dRF:WaitAnsAppNam')},...
        getWavMSG('Wavelet:wmp1dRF:WaitAnsAppQuest'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            Men_Save_Callback(m_save,eventdata,handles,'sig')
        otherwise
    end
end
delete(hFig)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function Men_LoadSig(hObject,eventdata,handles,Y,name,flagWRKS) 

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
if nargin<4
    [sigInfos,~,ok] = utguidiv('load_sig',hFig,'Signal_Mask',...
        getWavMSG('Wavelet:wmp1dRF:Men_Load_Signal'));
    if ~ok, return; end
    pathname = sigInfos.pathname;
    filename = sigInfos.filename;
    loadSIG = true;
    caller = 'load';
    
elseif nargin<6
    ok = 1;
    loadSIG = false;
    caller = 'demo';
    
else
    [sigInfos,Y,ok] = wtbximport('1d');
    if ~ok, return; end
    name = sigInfos.name;
    loadSIG = false;
    caller = 'import';
end

% Cleaning.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
set([hdl_Menus.m_save,hdl_Menus.m_exp_wrks],'Enable','Off');
cleanTOOL('load',[handles.Axe_SIG,handles.Axe_ADD ...
           handles.Axe_CFS,handles.Axe_QUAL,...
           handles.Axe_COMPO,handles.Pan_COMPO],...
           handles,caller);
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');

% Loading file.
%--------------
if loadSIG
    [name,ext] = strtok(filename,'.');
    if isempty(ext) || isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end
    try
        fullName = [pathname filename];
        TMP = load(fullName);
        DUM = fieldnames(TMP);
        idxY = strcmp(DUM,'Y');
        % Use strcmpi() do not rely on order
        idxApprox = strcmpi(DUM,'Approx_Results');
        if any(idxY)
            Y = TMP.(DUM{idxY});
        elseif any(idxApprox)
            Y = TMP.('Approx_Results'){1};
        else
            Y = TMP.(DUM{1});
        end
        if iscell(Y) , Y = Y{1}; end
        clear TMP DUM idxY
    catch ME
        errargt(mfilename,getWavMSG('Wavelet:wmp1dRF:LoadFail'),'msg');
        wwaiting('off',hFig);
        return;
    end
end
   
wtbxappdata('set',hObject,'sig_ANAL',Y);

% Get variable values.
%---------------------
lenY = length(Y);
X = linspace(0,1,lenY);
if size(X)~=size(Y) , Y = Y'; end
LowInter = X(1);
UppInter = X(end);

% Reset matching pursuit dictionary (if necessary.)
%--------------------------------------------------
DICO = wtbxappdata('get',hFig,'MP_Dictionary');
if ~isempty(DICO) && ~isequal(lenY,size(DICO,1))
    wtbxappdata('set',hFig,'MP_Dictionary',[],'MP_nbVect',[]);
end

% Update uicontrols on the command part.
%---------------------------------------
set(handles.Edi_Sig_NAM,'String',name);
set([handles.Pus_Approximate,handles.Pop_Type_ALG],...
    'Enable','on');

% Axe_SIG axes display.
%----------------------
lw = 1;
axeCur = handles.Axe_SIG;
lin_SIG = line(X,Y,'Color','r','LineWidth',lw,...
    'Visible','Off','Parent',axeCur,'Tag','Sig_ANAL');
ext  = abs(max(Y) - min(Y)) / 100;
Ylim = [min(Y)-ext max(Y)+ext];
Xlim = [min(X) max(X)];
set(axeCur,'XLim',Xlim,'YLim',Ylim);

% Set the axes visible.
%----------------------
set(handles.Axe_SIG,'FontUnits','point','FontSize',8);
set([handles.Axe_SIG,lin_SIG],'Visible','on');
title(getWavMSG('Wavelet:wmp1dRF:Analyzed_Signal'), ...
    'FontUnits','point','FontSize',8,'Parent',handles.Axe_SIG)

% Init DynVTool.
%---------------
axe_IND = [handles.Axe_CFS , handles.Axe_QUAL];
axe_CMD = [handles.Axe_SIG , handles.Axe_ADD , handles.Axe_COMPO ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Men_Save_Callback(hObject,eventdata,handles,arg) %#ok<*INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

% Get 
%----------------
switch arg
    case 'sig' 
        hdl_APP = wfindobj(hFig,'Type','Line','Tag','Sig_APPROX');
        try   
            Y = get(hdl_APP,'YData');
        catch ME %#ok<*NASGU>
            wwaiting('off',hFig);
            return;
        end
        str_DLG = getWavMSG('Wavelet:wmp1dRF:WMP_Save_Approximation');
        
    case 'cpt'
        lin_CPT = wtbxappdata('get',hFig,'lin_COMPO');
        TMP = get(lin_CPT(1),'YData');
        nbVAL = length(TMP);
        nbCPT = length(lin_CPT);
        CPT = zeros(nbCPT,nbVAL);
        CPT(1,:) = TMP;
        for k = 2:nbCPT-1  
            CPT(k,:) = get(lin_CPT(k),'YData');
        end
        str_DLG = getWavMSG('Wavelet:wmp1dRF:WMP_Save_Components');

    case 'dec'
        Approx_Results =  wtbxappdata('get',hFig,'Approx_Results');
        InfoSTR =  'Approx_Results = {YFIT,R,COEFF,IOPT,qual}';
        [LstCPT,nbVect] =  wtbxappdata('get',hFig,'LstCPT','MP_nbVect'); 
        str_DLG = getWavMSG('Wavelet:wmp1dRF:WMP_Save_Decomposition');

    case 'dic'
        [DICO,nbVect] = ...
            wtbxappdata('get',hFig,'MP_Dictionary','MP_nbVect'); %#ok<*ASGLU>
        str_DLG = getWavMSG('Wavelet:wmp1dRF:WMP_Save_Dictionary');

end

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig,'*.mat',str_DLG);
if ~ok
    wwaiting('off',hFig);
    return; 
end

% Saving file.
%-------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

try
    switch arg
        case 'sig' , save([pathname filename],'Y','-mat');
        case 'cpt' , save([pathname filename],'CPT','-mat');
        case 'dec' 
            save([pathname filename], ...
                'InfoSTR','Approx_Results','LstCPT','nbVect','-mat');
        case 'dic' 
            save([pathname filename],'DICO','nbVect','-mat');
            
    end
catch ME
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function demo_FUN(hObject,eventdata,handles,numDEM)

% Default Demo Parameters.
%-------------------------
[SIG,nameSIG] = getSig_EXAMPLE(1024,numDEM);

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing and loading file.
%--------------------------
% pathname = utguidiv('WTB_DemoPath',filename);
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_load = hdl_Menus.m_load;

wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitLoadCompute'));
Men_LoadSig(m_load,eventdata,handles,SIG,nameSIG);
LstCPT  = get(handles.Lst_CMP_DICO,'String');
if isempty(LstCPT)
    Pus_RECENT_CMP_Callback(hObject,eventdata,handles)
end
Pus_Approximate_Callback(hObject,eventdata,handles,'demo');
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Export_Callback(hObject,eventdata,handles) 

hFig = handles.output;        
hdl_APP = wfindobj(hFig,'Type','Line','Tag','Sig_APPROX');
Y = get(hdl_APP,'YData');
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitExport'));
wtbxexport(Y,'name','sig_1D','title',getWavMSG('Wavelet:wmp1dRF:WMP1D'));
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function close_FUN(hObject,eventdata,handles) 

Pus_CloseWin = handles.Pus_CloseWin;
Pus_CloseWin_Callback(Pus_CloseWin,eventdata,handles);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles)

% WTBX -- Install DynVTool.
%--------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
pan = wfindobj(hObject,'type','uipanel','tag','Pan_DAT_WAV');
set(pan,'Visible','On')
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX MENUS (Install)
%---------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% Initialize titles of axes.
%---------------------------
titleSTR = getWavMSG('Wavelet:wmp1dRF:Analyzed_Signal_Upper');
wguiutils('setAxesTitle',handles.Axe_SIG,titleSTR);
wguiutils('setAxesTitle',handles.Axe_ADD,'');
wguiutils('setAxesTitle',handles.Axe_CFS,'');
wguiutils('setAxesTitle',handles.Axe_COMPO,'');

% Grid Settings.
%---------------
set(hObject,'DefaultAxesGridColor','k', ...
            'DefaultAxesGridLineStyle',':')

% Set Initial Basis and ...
%--------------------------
DICO_DEF = {'sym4 - lev5';'wpsym4 - lev5';'dct';'sin';'cos'};
Data_RECENT = {'sym4 - lev5',true;'wpsym4 - lev5',true;'dct',true;  ...
      'sin',true;'cos',true};
set(handles.uitable_RECENT,'Data',Data_RECENT);
wtbxappdata('set',hObject,'DICO_DEF',DICO_DEF);
wtbxappdata('set',hObject,'Data_RECENT',Data_RECENT);
wtbxappdata('set',hObject,'Init_Algo',0);

% Save Tool Parameters.
%----------------------
utanapar('Install_V3',hObject,'maxlev',12,'deflev',5);
cbanapar('set',hObject,'wav','sym4','lev',5);
set(handles.Lst_CMP_DICO,'String',...
      {'sym4 - lev5','wpsym4 - lev5','dct','sin','cos'});    
 
% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);

% Set Initial Misc ...
%---------------------
pos_PUS_MOV = [...
    get(handles.Pus_START_PLOT,'Position'); ...
    get(handles.Pus_STOP_PLOT,'Position');  ...
    get(handles.Pus_END_DISP,'Position') ...
    ];
pos_PUS_STPW = pos_PUS_MOV;
pos_PUS_STPW(2,1) = pos_PUS_STPW(2,1)-pos_PUS_STPW(2,3)/2;
pos_PUS_STPW(3,1) = pos_PUS_STPW(3,1)-pos_PUS_STPW(2,3)/2;
wtbxappdata('set',hObject,'pos_PUS_BTN',{pos_PUS_MOV,pos_PUS_STPW});
wtbxappdata('set',hObject,'in_AddPan',[]);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function cleanTOOL(option,div_HDL,handles,caller) 

hFig    = handles.output;
hLINES  = findobj(div_HDL,'Type','line');
hPATCH  = findobj(div_HDL,'Type','patch');
hIMAGES = findobj(div_HDL,'Type','image');
hTXT    = wfindobj(div_HDL,'Type','text');
hLEGEND = wfindobj(hFig,'Tag','legend');
delete([hLINES;hPATCH;hIMAGES;hLEGEND;hTXT]);
switch option
    case 'load'
        delete(get(div_HDL(1),'xlabel'))
        set(handles.Pop_ITER,'Value',8);      % 20 iterations
        set(handles.Pop_ERR_MAX,'Value',1);   % None
        set(handles.Pop_Type_ALG,'Value',1);  % Basic MP
        set(handles.Pop_TYP_DISP,'Value',1);  % Final Plot
        
    case 'approx'
        xl = get(handles.Axe_SIG,'xlabel');
        t = get(handles.Axe_SIG,'title');
        lin = wfindobj(hFig,'Type','line','Tag','Sig_APPROX');
        delete([lin,xl])
        set(t,'String',getWavMSG('Wavelet:wmp1dRF:Analyzed_Signal'));
        Lst_CMP = get(handles.Lst_CMP_DICO,'String');
        if isempty(Lst_CMP)
            Data_RECENT = wtbxappdata('get',hFig,'Data_RECENT');
            set(handles.Lst_CMP_DICO,'Value',[],'String',Data_RECENT(:,1));
        end
end
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
set(hdl_Menus.m_save,'Enable','Off')

set(div_HDL,'Visible','off');
%-------------------------------------------------------------------------
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
%-------------------------------------------------------------------------
function hdl_Menus = Install_MENUS(hFig)

% Add UIMENUS.
%-------------
m_files = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = @(o,~)wmp1dtool('close_FUN',o,[],guidata(o));
set(m_close,'Callback',cb_close);

m_load  = uimenu(m_files,                   ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Load_Signal'), ...
    'Position',1,                           ...    
    'Enable','On',                          ...
    'Callback',                             ...
    @(o,~)wmp1dtool('Men_LoadSig',o,[],guidata(o))  ...
    );

m_save  = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Save'),  ...
    'Position',2,         ...
    'Enable','Off',       ...
    'Tag','m_save'        ...
    );
uimenu(m_save, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Save_APP'), ...
    'Position',1,         ...
    'Enable','On',        ...
    'Callback',           ...
    @(o,~)wmp1dtool('Men_Save_Callback',o,[],guidata(o),'sig')  ...
    );
uimenu(m_save, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Save_CPT'), ...
    'Position',2,         ...
    'Enable','On',        ...
    'Callback',           ...
    @(o,~)wmp1dtool('Men_Save_Callback',o,[],guidata(o),'cpt')  ...
    );
uimenu(m_save, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Save_DEC'), ...
    'Position',3,         ...
    'Enable','On',        ...
    'Callback',           ...
    @(o,~)wmp1dtool('Men_Save_Callback',o,[],guidata(o),'dec')  ...
    );
uimenu(m_save, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Save_DIC'), ...
    'Position',4,         ...
    'Enable','On',        ...
    'Callback',           ...
    @(o,~)wmp1dtool('Men_Save_Callback',o,[],guidata(o),'dic')  ...
    );

m_demo = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Example'), ...
    'Position',3,'Separator','Off');

uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Import'),...
    'Position',4,'Enable','On', ...
    'Separator','On',...
    'Callback',  ...    
    @(o,~)wmp1dtool('Men_LoadSig',o,[],guidata(o),[],[],[]) ...
    );
m_exp_wrks = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:wmp1dRF:Men_Export'),...
    'Position',5, ...
    'Enable','Off','Separator','Off',...
    'Callback',@(o,~)wmp1dtool('Export_Callback',o,[],guidata(o)) ...
    );

demoSET = cell(19,1);
idx = 1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_CuspSig');
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_SinSig'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_sum3sin');
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_TruncSin'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_SinVarFrq'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_SinDiscont'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_freqbrk'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_BlocksSig'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_BumpsSig'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_DopplerSig'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_HeavySinSig'); 
idx = idx+1;        
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBlocks'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NDoppler');
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NBumps');
idx = idx+1;      
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_QuadchirpSig');
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_MishmashSig');
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_NSinVarFrq'); 
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_SensorSig');
idx = idx+1;
demoSET {idx} = getWavMSG('Wavelet:moreMSGRF:EX1D_Name_leleccum');
nbDEM = size(demoSET,1);
sepSET = [2 7 12 18];
for k = 1:nbDEM
    action = @(o,~)wmp1dtool('demo_FUN',o,[],guidata(o),k);
    if find(k==sepSET)
        Sep = 'On';
    else
        Sep = 'Off';
    end
    uimenu(m_demo,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig,getWavMSG('Wavelet:wmp1dRF:MP_ALG'),'WMP_TOOL');

% Add Help Item.
%----------------

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_load',m_load,...
    'm_save',m_save,'m_exp_wrks',m_exp_wrks);
%-------------------------------------------------------------------------
%*************************************************************************
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%-------------------------------------------------------------------------
function Pop_COMPO_Callback(hObject,eventdata,handles)

val = get(hObject,'Value')-1;
lin_COMPO = wtbxappdata('get',hObject,'lin_COMPO');
nbLine = length(lin_COMPO);
valRAD = get(handles.Rad_ALL,'Value');
if isequal(valRAD,0)
    vis = 'Off'; LW = 2;
else
    vis = 'On';  LW = 3;
end
set(lin_COMPO,'Visible',vis,'Linewidth',1);
switch val
    case 0
        set(lin_COMPO(end),'Visible','On','Linewidth',1);
    otherwise
        propLine = {'Visible','On','Linewidth',LW};
        if val<nbLine , set(lin_COMPO(val),propLine{:}); end
        set(lin_COMPO(end),propLine{:});
end
%-------------------------------------------------------------------------
function Rad_ALL_Callback(hObject,eventdata,handles)

lin_COMPO = wtbxappdata('get',hObject,'lin_COMPO');
nbLine = length(lin_COMPO);
val = get(hObject,'Value');
valPOP = get(handles.Pop_COMPO,'Value')-1;
switch val
    case 0
        toHide = setdiff(1:nbLine-1,valPOP);
        set(lin_COMPO(toHide),'Visible','Off');
        LW = 1;
    case 1
        set(lin_COMPO,'Visible','On');
        if ~isequal(get(handles.Pop_COMPO,'Value'),1)
            LW = 3;
        else
            LW = 1;
        end
end
hTMP = lin_COMPO(end);
if valPOP>0 , hTMP = [hTMP , lin_COMPO(valPOP)]; end
set(hTMP,'Linewidth',LW);
%-------------------------------------------------------------------------
function Pop_TYP_DISP_Callback(hObject,eventdata,handles) %#ok<*DEFNU>

val = get(hObject,'value');
toENA = [handles.Txt_STP_PLOT;handles.Pop_STP_PLOT;handles.Txt_STP_PLOT_2];
pos_PUS_BTN = wtbxappdata('get',hObject,'pos_PUS_BTN');
% {pos_PUS_MOV,pos_PUS_STPW});
switch val
    case 1  % OnePlot
        ena = 'off'; 
        str_START = getWavMSG('Wavelet:wmp1dRF:StrALG_Start'); 
        str_STOP  = getWavMSG('Wavelet:wmp1dRF:StrALG_Stop'); 
        visON = []; 
        visOFF = [toENA;handles.Pus_START_PLOT; ...
            handles.Pus_STOP_PLOT;handles.Pus_END_DISP];
        pos_STOP = pos_PUS_BTN{1}(2,:);
        pos_DISP = pos_PUS_BTN{1}(3,:);
        
    case 2  % Stepwise
        ena = 'on';
        str_START = getWavMSG('Wavelet:wmp1dRF:StrALG_Start'); 
        str_STOP  = getWavMSG('Wavelet:wmp1dRF:StrALG_Next'); 
        visON = [toENA;handles.Pus_STOP_PLOT;handles.Pus_END_DISP]; 
        visOFF = handles.Pus_START_PLOT;
        pos_STOP = pos_PUS_BTN{2}(2,:);
        pos_DISP = pos_PUS_BTN{2}(3,:);
        
    case 3  % Movie
        ena = 'on';  
        str_START = getWavMSG('Wavelet:wmp1dRF:StrALG_Continue'); 
        str_STOP  = getWavMSG('Wavelet:wmp1dRF:StrALG_Pause'); 
        visOFF = []; 
        visON = [toENA;handles.Pus_START_PLOT; ...
            handles.Pus_STOP_PLOT;handles.Pus_END_DISP];
        pos_STOP = pos_PUS_BTN{1}(2,:);
        pos_DISP = pos_PUS_BTN{1}(3,:);
end
set(toENA,'Enable',ena);
set(handles.Pus_START_PLOT,'String',str_START);
set(handles.Pus_STOP_PLOT,'String',str_STOP,'Position',pos_STOP);
set(handles.Pus_END_DISP,'Position',pos_DISP);
set(visOFF,'Visible','Off');
set(visON,'Visible','On');
%-------------------------------------------------------------------------
function Pop_STP_PLOT_Callback(hObject,eventdata,handles) %#ok<*INUSD>
%-------------------------------------------------------------------------
function Pus_START_PLOT_Callback(hObject,eventdata,handles)

set(hObject,'UserData',1);
%-------------------------------------------------------------------------
function Pus_STOP_PLOT_Callback(hObject,eventdata,handles)

set(hObject,'UserData',1);
%-------------------------------------------------------------------------
function Pus_END_DISP_Callback(hObject,eventdata,handles)

set(hObject,'UserData',1);
%-------------------------------------------------------------------------
function Pus_STOP_ALG_Callback(hObject,eventdata,handles)

set(hObject,'UserData',1);
%-------------------------------------------------------------------------
function Pop_ITER_Callback(hObject,eventdata,handles)

wmp1dcbpop('defString',hObject,'par')
%-------------------------------------------------------------------------
function Pop_FAM_DICO_Callback(hObject,eventdata,handles)

numFAM = get(hObject,'Value');
hdl2ENA = [handles.Txt_Wav,handles.Pop_Wav_Fam,handles.Pop_Wav_Num,...
    handles.Txt_Lev,handles.Pop_Lev];
switch numFAM
    case {1,2} , enaVAL = 'On';
    otherwise  , enaVAL = 'Off';
end
set(hdl2ENA,'Enable',enaVAL);
%-------------------------------------------------------------------------
function Lst_CMP_DICO_Callback(hObject,eventdata,handles)

%-------------------------------------------------------------------------
function Pus_ADD_CMP_Callback(hObject,eventdata,handles)

Pan_ADD = handles.Pan_ADD_PAR;
Pan_ALG = handles.Pan_ALG_PAR;
Pan_WAV = handles.Pan_DAT_WAV;
sav_ENA = get(handles.Pus_Approximate,'Enable');
set(handles.Pus_CLOSE_ADDCPT,'Userdata',sav_ENA);
set(Pan_ALG,'Visible','Off');
set(Pan_ADD,'Visible','On')
valPOP = get(handles.Pop_FAM_DICO,'Value');
in_DispPan = wfindobj(handles.Pan_DISP_PAR,'Enable','on');
if valPOP>2 , in_DispPan = []; end
wtbxappdata('set',hObject,'in_DispPan',in_DispPan);

set([handles.Pus_Approximate,handles.Pop_Type_ALG,...
    handles.Txt_Cfs_WMP,handles.Edi_Cfs_WMP,...
    handles.Pus_MORE,handles.Pus_RESIDUALS],'Visible','Off')
set([hObject;handles.Pus_DEL_CMP;in_DispPan],'Enable','Off')
%-------------------------------------------------------------------------
function Pus_CLOSE_ADDCPT_Callback(hObject,eventdata,handles)

Pan_ADD = handles.Pan_ADD_PAR;
Pan_ALG = handles.Pan_ALG_PAR;
set(Pan_ADD,'Visible','Off');
vis = get(handles.Pan_RECENT,'Visible');
hON = [handles.Pan_DISP_PAR,handles.Pus_Approximate,...
    handles.Pop_Type_ALG,handles.Pus_MORE,handles.Pus_RESIDUALS];
typeALG = get(handles.Pop_Type_ALG,'Value');
if isequal(typeALG,3)  
    hON = [hON , handles.Txt_Cfs_WMP,handles.Edi_Cfs_WMP];
end
set(hON,'visible','On');
set(Pan_ALG,'Visible','On')
sav_ENA = get(hObject,'Userdata');
set([handles.Pus_Approximate],'Enable',sav_ENA)
in_DispPan = wtbxappdata('get',hObject,'in_DispPan');
valPOP = get(handles.Pop_FAM_DICO,'Value');
if valPOP>2 , in_DispPan = []; end
set([handles.Pus_ADD_CMP;handles.Pus_DEL_CMP;in_DispPan; ...
    handles.Pop_Type_ALG],'Enable','On');
Pus_CLOSE_RECENT_Callback(hObject,eventdata,handles)
%-------------------------------------------------------------------------
function Pop_ERR_MAX_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
hdl_ITER = [handles.Pop_ITER,handles.Txt_ITER];
switch val
    case 1        
        ena = 'Off'; strEDI = '';
        set(hdl_ITER,'Enable','On');
    case {2,3,4} 
        ena = 'On';  strEDI = 5;
        set(hdl_ITER,'Enable','Off');
end
if isempty(get(handles.Edi_ERR_MAX,'String'))
    set(handles.Edi_ERR_MAX,'String',strEDI);
end
set(handles.Edi_ERR_MAX,'Enable',ena);
%-------------------------------------------------------------------------
function Edi_ERR_MAX_Callback(hObject,eventdata,handles)

wmp1dcbpop('edi',hObject,'edi')
%-------------------------------------------------------------------------
function Pop_Wav_Fam_Callback(hObject,eventdata,handles)

hFig = handles.output;
cbanapar('cba_fam',hFig,eventdata,handles)
%-------------------------------------------------------------------------
function Pop_Wav_Num_Callback(hObject,eventdata,handles)

hFig = handles.output;
cbanapar('cba_num',hFig,eventdata,handles)
%-------------------------------------------------------------------------
function Pop_Lev_Callback(hObject,eventdata,handles)
%-------------------------------------------------------------------------
function Pus_ADD_In_LST_Callback(hObject,eventdata,handles)

hFig = handles.output;
numFAM = get(handles.Pop_FAM_DICO,'Value');
switch numFAM
    case 1 % wavelet
        [wname,lev_Anal] = cbanapar('get',hFig,'wav','lev');
        addSTR = [wname, ' - lev' int2str(lev_Anal)];
    case 2 % WP full
        [wname,lev_Anal] = cbanapar('get',hFig,'wav','lev');
        addSTR = ['wp' wname, ' - lev' int2str(lev_Anal)];
    otherwise
        tmp = get(handles.Pop_FAM_DICO,'String');
        addSTR  = tmp{numFAM};
end
Lst_DIC = handles.Lst_CMP_DICO;
LstSTR = get(Lst_DIC,'String');
if isempty(LstSTR)
    LstSTR = {addSTR};
else
    if any(strcmp(LstSTR,addSTR))
        beep;
        return
    end
    LstSTR = [LstSTR ; {addSTR}];
end
set(Lst_DIC,'String',LstSTR,'Value',[]);
Data_RECENT = get(handles.uitable_RECENT,'Data');
Data_RECENT = [Data_RECENT;{addSTR,true}];
set(handles.uitable_RECENT,'Data',Data_RECENT);
wtbxappdata('set',hFig,'MP_Dictionary',[],'MP_nbVect',0);
%-------------------------------------------------------------------------
function Pus_RECENT_CMP_Callback(hObject,eventdata,handles)

Pan_RECENT = handles.Pan_RECENT;
set([handles.Pan_DISP_PAR,handles.Pus_Approximate, ...
    handles.Pop_Type_ALG],'visible','Off');

in_AddPan = wfindobj(handles.Pan_ADD_PAR,'Enable','on');
in_AddPan = in_AddPan(ishandle(in_AddPan));
wtbxappdata('set',hObject,'in_AddPan',in_AddPan);
set(Pan_RECENT,'visible','On');
set([hObject;handles.Pus_CLOSE_ADDCPT;handles.Pus_CloseWin;in_AddPan], ...
    'Enable','Off');
%-------------------------------------------------------------------------
function Pus_CLOSE_RECENT_Callback(hObject,eventdata,handles)

uit = handles.uitable_RECENT;
D = get(uit,'Data');
NewSTR = D(cat(1,D{:,2}),1);
OldSTR = get(handles.Lst_CMP_DICO,'String');
set(handles.Lst_CMP_DICO,'String',NewSTR);
set(handles.Pan_RECENT,'visible','Off');
in_AddPan = wtbxappdata('get',hObject,'in_AddPan');
valPOP = get(handles.Pop_FAM_DICO,'Value');
if valPOP>2
   set(handles.Pop_FAM_DICO,'Value',1);
end
if ~isequal(NewSTR,OldSTR)
    wtbxappdata('set',hObject,'MP_Dictionary',[],'MP_nbVect',0);
end
set([handles.Pus_RECENT_CMP;handles.Pus_CLOSE_ADDCPT; ...
    handles.Pus_CloseWin;in_AddPan],'Enable','On');
%-------------------------------------------------------------------------
function Pus_DEL_CMP_Callback(hObject,eventdata,handles)

hFig = handles.output;
Lst_DIC = handles.Lst_CMP_DICO;
Str_LST = get(Lst_DIC,'String');
Val_LST = get(Lst_DIC,'Value');
Str_LST(Val_LST) = [];
set(Lst_DIC,'String',Str_LST,'Value',[]);
uit = handles.uitable_RECENT;
D = get(uit,'Data');
[~,idx] = setdiff(D(:,1),Str_LST);
D(idx,2) = {false};
set(uit,'Data',D);
wtbxappdata('set',hFig,'MP_Dictionary',[],'MP_nbVect',0);
set([handles.Pus_MORE,handles.Pus_RESIDUALS],'Enable','Off');
%-------------------------------------------------------------------------
function Pus_Clean_TAB_Callback(hObject,eventdata,handles)

hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:Wait'));
Qstr = getWavMSG('Wavelet:wmp1dRF:Quest_DLGRecCPT');
Tstr = getWavMSG('Wavelet:wmp1dRF:Title_DLGRecCPT');
QWARN = questdlg(Qstr,Tstr,'Yes','No','No');
switch QWARN
    case 'Yes'
    case 'No',  wwaiting('off',hFig); return;
end
wwaiting('off',hFig); 
Data_RECENT = wtbxappdata('get',hObject,'Data_RECENT');
set(handles.uitable_RECENT,'Data',Data_RECENT);
set(handles.Lst_CMP_DICO,'Value',[],'String',Data_RECENT(:,1));
%-------------------------------------------------------------------------
function Pus_MORE_Callback(hObject,eventdata,handles)

wmpmoreoncfs(handles)
%-------------------------------------------------------------------------
function Pus_RESIDUALS_Callback(hObject,eventdata,handles)

hFig = handles.output;
handleORI = wfindobj(hFig,'Type','line','Tag','Sig_ANAL');
handleRES = wfindobj(hFig,'Type','line','Tag','Sig_RES');
handleTHR = [];
wmoreres('create',hFig,hObject,handleRES,handleORI,handleTHR);
%-------------------------------------------------------------------------
function Edi_Cfs_WMP_Callback(hObject,eventdata,handles)

val = str2double(get(hObject,'String'));
err = 0;
if isnan(val) || val<0 || val>1 , err = 1; end
if err
    strOBJ = get(hObject,'UserData');
else
    strOBJ = num2str(val);
end
set(hObject,'String',strOBJ,'UserData',strOBJ);
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function  [Y,name] = getSig_EXAMPLE(N,num_ESSAI)

switch num_ESSAI
    case 1 , load cuspamax; Y = cuspamax; name = 'cuspamax';
    case 2 , t = linspace(0,1,N); Y = sin(4*pi*t); name = 'sine';
    case 3 
        t = linspace(0,1,N);
        Y = sin(8*pi*t)+ sin(16*pi*t)+ sin(32*pi*t);
        name = 'sumofsines';
    case 4
        t = linspace(0,1,N); Y = (t>0.25).*(t<0.75).*sin(4*pi*t);
        name = 'truncated sine';
    case 5
        t = linspace(0,1,N);
        Y = sin(8*pi*t).*(t<=0.5) + sin(16*pi*t).*(t>0.5);
        name = 'sine_var_frq';
    case 6
        t = linspace(1,1/N,N);
        x = 4*sin(4*pi*t);
        Y = x - sign(t - .3) - sign(.72 - t);
        name = 'discontinuous sine';
    case 7  , load freqbrk;  Y = freqbrk;  name = 'freqbrk';
    case 8  , Y = wnoise('blocks',fix(log2(N))); name = 'blocks';
    case 9  , Y = wnoise('bumps',fix(log2(N)));  name = 'bumps';
    case 10 , Y = wnoise('doppler',fix(log2(N))); name = 'doppler';
    case 11 , Y = wnoise('heavy sine',fix(log2(N))); name = 'heavy sine';
    case 12 , load noisbloc; Y = noisbloc; name = 'noisbloc'; 
    case 13 , load noisdopp; Y = noisdopp; name = 'noisdopp'; 
    case 14 , load noisbump; Y = noisbump; name = 'noisbump'; 
    case 15 , Y = wnoise('quadchirp',fix(log2(N))); name = 'quadchirp';
    case 16 , Y = wnoise('mishmash',fix(log2(N))); name = 'mishmash';
    case 17
        t = linspace(0,1,N);
        Y = sin(8*pi*t).*(t<=0.5) + sin(16*pi*t).*(t>0.5);
        Y = Y + 0.2*randn(size(Y));
            name = 'noisy sine_var_frq';
    case 18
        load sensor1;
        long  = N; first = 5000; last  = first + long-1;  
        Y = sensor1(first:last);
        name = 'sensor1';
    case 19
        load leleccum; Y = leleccum; name = 'leleccum';
end
L = length(Y);
if ~isequal(N,L)
    t = linspace(0,1,N);
    X = linspace(0,1,L);
    Y = interp1(X,Y,t);
end
%--------------------------------------------------------------------------
