function varargout = cwtfttool2(varargin)
%CWTFTTOOL2 Continuous wavelet transform tool using FFT.


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jul-2012.
%   Copyright 1995-2020 The MathWorks, Inc.
    
% DDUX data logging
if isempty(varargin) 
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "cwftttool2";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end
%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cwtfttool2_OpeningFcn, ...
                   'gui_OutputFcn',  @cwtfttool2_OutputFcn, ...
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
% --- Executes just before cwtfttool2 is made visible.                    %
%*************************************************************************%
function cwtfttool2_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for cwtfttool2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cwtfttool2 wait for user response (see UIRESUME)
% uiwait(handles.wfbmtool_Win);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALIZATION Introduced manually in the automatic generated code %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
hFig = handles.output;
nameFig = get(hFig,'Name');
LstFig = wfindobj(0,'Type','Figure','Name',nameFig); %#ok<*NASGU>
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = cwtfttool2_OutputFcn(hObject,eventdata,handles) 
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
function DEL_Win_Callback(hObject,eventdata,handles)


hFig = handles.output;
nameFig = get(hFig,'Name');
LstFig = wfindobj(0,'Type','Figure','Name',nameFig);
fig_EQ = wtbxappdata('get',hFig,'fig_EQ');
if ishandle(fig_EQ) , delete(fig_EQ); end
delete(gcbf)
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles)  

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    fig = get(hObject,'Parent');
    status = wwaitans({fig,getWavMSG('Wavelet:cwtfttool:CWTFFT')},...
        getWavMSG('Wavelet:cwtfttool2:Save_CWT2_Anal'),2,'Cancel');
    switch status
        case -1 , return;
        case  1 , Men_SavDEC_Callback(hObject,eventdata,handles);
        otherwise
    end
    wtbxappdata('set',hObject,'status_SAVE',1);
end
DEL_Win_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
%--------------------------------------------------------------------------
function Men_SavDEC_Callback(hObject,eventdata,handles)  

% Get figure handle.
%-------------------
fig = handles.output;

% Begin waiting.
%---------------
wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitSaving'));

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',fig, ...
    '*.mat',getWavMSG('Wavelet:cwtfttool:SaveDecomp'));
if ~ok
    wwaiting('off',fig);   % End waiting.
    return; 
end

% Saving file.
%-------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end
CWTS = wtbxappdata('get',fig,'CWTStruct');  
try
    save([pathname filename],'CWTS','-mat');
catch           %#ok<CTCH>
    errargt(mfilename,getWavMSG('Wavelet:cwtfttool:SaveFailed'),'msg');
end

% End waiting.
%-------------
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Export_Callback(hObject,eventdata,handles,option)  

fig = handles.output;
wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitExport'));
switch option
    case 'sig'
    case 'ana'
        CWTS = wtbxappdata('get',fig,'CWTStruct');
        wtbxexport(CWTS,'name','CWTS','title',...
                getWavMSG('Wavelet:cwtfttool:CWTStructure'));
end
wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_ANAL_Callback(hObject,eventdata,handles,param)  

fig = gcbf;
wwaiting('msg',fig,getWavMSG('Wavelet:commongui:WaitCompute'));
X = wtbxappdata('get',fig,'Sig_ANAL');

% Get wavelet for analysis.
WNam = get(handles.Pop_WAV_NAM,{'Value','String'});
wname = deblank(WNam{2}{WNam{1}});
WAV_Param_Table = wtbxappdata('get',hObject,'WAV_Param_Table');
idx_Wave = strcmp(wname,WAV_Param_Table(:,1));
PAR_Cell = WAV_Param_Table(idx_Wave,2);
if ~isempty(PAR_Cell{1})
    TMP = PAR_Cell{1}(:,2);
    nbPar = length(TMP);
    wpara = cell(1,nbPar);
    for k = 1:length(TMP)
        if ischar(TMP{k}) 
            wpara{k} =  eval(TMP{k});
        else
            wpara{k} = TMP{k};
        end
    end
else
    wpara = [];
end
if nargin>3 && ~isempty(param) , wpara{1} = param; end % DEMO
WAV = {wname,wpara};

AP = wtbxappdata('get',fig,'Pow_Anal_Params');
AP.WAV = WAV;
AP.sampPer = 1;
wtbxappdata('set',fig,'Pow_Anal_Params',AP);

OPT_ANG = get(handles.Pop_DEF_ANG,'Value');
OPT_SCA = get(handles.Pop_DEF_SCA,'Value');
sX = size(X);
switch OPT_SCA
    case 1
        scales = 1:15;
        if min(sX(1:2))>1000
            scales = [1 10];
        elseif min(sX(1:2))>512
            scales = [1 5 10];
        elseif min(sX(1:2))>256
            scales = [1 5 10];
        end
        
    case 2
        maxPow = log2(min(sX(1:2)))-1;
        scales = 2.^(1:0.5:maxPow);
        if min(sX(1:2))>1000
            scales =  2.^[1 maxPow/2 maxPow];
        elseif min(sX(1:2))>512
            scales =  2.^[1 maxPow];
        elseif min(sX(1:2))>256
            scales =  2.^[1 maxPow/4 maxPow/2 maxPow];
        end
        
    case 3 , scales = AP.scales;
        
end
switch OPT_ANG
    case 1  
        angles = 0;
        
    case 2 
        angles = AP.angles;
        if length(sX)>2 && length(angles)>4
            angles = (0:pi/3:pi);
        end
        if min(sX(1:2))>1000 && length(angles)>2
            angles = angles(1:3);
        end
       
    case 3  
        angles = AP.angles;
end

if length(scales)<2 
    ena = 'Off'; 
else
    ena = 'On'; 
end
set(handles.Pus_SEL_Scales,'UserData',ena);
if length(angles)<2 
    ena = 'Off'; 
else
    ena = 'On';
end
set(handles.Pus_SEL_Angles,'UserData',ena);

% Continuous Analysis
CWTStruct = cwtft2(X,'wavelet',WAV,'scales',scales,'angles',angles);

wtbxappdata('set',fig,'CWTStruct',CWTStruct);
wtbxappdata('set',fig,'Scales_INI',scales);
wtbxappdata('set',fig,'Angles_INI',angles);
Lst_Scales_INI(fig,handles)
nbSc = length(scales);
if nbSc>2 
    numSCA = 3;
else
    numSCA = 1;
end
set(handles.Pop_Cur_SCA,'String',int2str((1:nbSc)'),'Value',numSCA);
set(handles.Pop_Cur_ANG,'String',int2str((1:length(angles))'),'Value',1);
showScaleANAL(handles,numSCA,'first');
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
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX MENUS (Install)
%---------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'Enable','On');
default_nbcolors = 250;
cbcolmap('set',hObject,'pal',{'gray',default_nbcolors})
cbcolmap('Enable',hObject,'Off')

% Set colors and fontes for the figure.
%---------------------------------------
FigColor = get(hObject,'Color');

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);

set(handles.Txt_BigTitle,...
    'BackgroundColor',FigColor,'ForegroundColor',[0 0 1],...
    'FontSize',7,'FontWeight','Bold')
set(hObject,'DefaultAxesBox','On')

% Store Axes Positions
%---------------------
hAXES = findobj(hObject,'Type','Axes');
axe_STORAGE = cell(length(hAXES),4);
axe_STORAGE(:,1) = get(hAXES,'Tag');
axe_STORAGE(:,2) = num2cell(findobj(hObject,'Type','Axes'));
axe_STORAGE(:,3) = get(hAXES,'Position');
axe_STORAGE(:,4) = axe_STORAGE(:,3);
pL = get(axe_STORAGE{5,2},'Position');
pR = get(axe_STORAGE{5,2},'Position');
pMOD = get(axe_STORAGE{4,2},'Position');
pMOD(3) = pR(1)+pR(3)-pL(1);
axe_STORAGE{4,4} = pMOD;
pREA = get(axe_STORAGE{3,2},'Position');
pANG = get(axe_STORAGE{2,2},'Position');
pREA([1 3]) = pMOD([1 3]);
pREA(2) = pANG(2);
axe_STORAGE{3,4} = pREA;
pL(3) = pMOD(3);
axe_STORAGE{5,4} = pL;
wtbxappdata('set',hObject,'axe_STORAGE',axe_STORAGE);
wtbxappdata('set',hObject,'FlagReal',0);

% Initialize Synthesized Status.
%-------------------------------
Tab_Synt_Status = zeros(2,3);
wtbxappdata('set',hObject,'Tab_Synt_Status',Tab_Synt_Status);

% Initialize TooltipStrings.
%---------------------------
set([handles.Txt_WAV_NAM;handles.Pop_WAV_NAM; ...
    handles.Txt_WAV_PAR;handles.Edi_WAV_PAR],'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SelectWaveletAndWaveletParametersForContinuousAnalysis'));
set([handles.Txt_DEF_SCA;handles.Pop_DEF_SCA; ...
    handles.Pus_DEF_SCA;],'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_DefineScalesForContinuousAnalysis'));
set(handles.Lst_SEL_SC,'TooltipString',...
    getWavMSG('Wavelet:cwtfttool:sprintf_SelectScalesUsingMousenCTRLMAJAndArrowKeys'));

% Initialize Analysis Parameters.
%--------------------------------
% Making the wavelet parameters table
built_WAV_Param_Table(hObject)

% --- Sampling period
AP.sampPer = 1; 
% --- Wavelet 
WAV.name =  'morl'; WAV.param = 6;
AP.WAV = WAV;
% --- Scales and Angles;
nbSamp = 128;
SCA.s0 = 2*AP.sampPer; SCA.ds = 0.4875; 
SCA.nb = fix(1*log2(nbSamp)/SCA.ds)+1; 
SCA.type = 'pow'; SCA.pow = 2;
AP.SCA = SCA;
AP.scales = (SCA.s0) * (SCA.pow).^((0:(SCA.nb)-1)*(SCA.ds));
AP.ANG = 'pi/4';
AP.angles = pi*(0:7)/4;
wtbxappdata('set',hObject,'Pow_Anal_Params',AP);
wtbxappdata('set',hObject,'Default_Pow_Anal_Params',AP);
% ---------
AP.sampPer = 1; 
SCA.s0 = 10*AP.sampPer; SCA.ds = SCA.s0; SCA.nb = 20; 
SCA.type = 'lin';
AP.SCA = SCA;
AP.scales = SCA.s0 + (0:SCA.nb-1)*(SCA.ds);
wtbxappdata('set',hObject,'Linear_Anal_Params',AP);
wtbxappdata('set',hObject,'Default_Linear_Anal_Params',AP);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function cleanTOOL(option,fig,handles,typeLOAD) 

switch option
    case {'load_beg','anal_beg'}
        set(handles.Pan_SEL_SC,'Userdata',[])
        if strcmpi(get(handles.Pan_SEL_SC,'Visible'),'on')
            Pus_SEL_Scales_Callback(handles.Pus_SEL_Scales,[],handles)
            pause(0.01);
        end
        
        hdl_Axe_SIG  = handles.Axe_SIG_L; 
        hdl_Axe_ANAL = [...
            handles.Axe_MOD ; handles.Axe_ANG; ...
            handles.Axe_REAL; handles.Axe_IMAG];
        axCB = wfindobj(fig,'Type','axes','Tag','Colorbar');
        axL = handles.Axe_SIG_L;
        switch option
            case 'load_beg'
                vis = 'off';
                hdl_AXE_Child = allchild(...
                    [hdl_Axe_SIG ; hdl_Axe_ANAL ; axCB]);
                toDEL = cat(1,hdl_AXE_Child{:});
                hdl_VIS_OnOff = hdl_Axe_SIG;
                
            case 'anal_beg' 
                vis = 'on';
                hdl_Inv = [...
                    findobj(axL,'Tag','RecSIG') ; ...
                    findobj(axL,'Tag','RecLST') ; ...
                    findobj(axL,'Tag','RecMAN') ];
                hdl_AXE_Child = allchild(...
                    [hdl_Axe_ANAL ; axCB ;]);
                toDEL = [hdl_Inv ; cat(1,hdl_AXE_Child{:})];
                hdl_VIS_OnOff = [];
        end
        delete(toDEL);
        SavMenOnOff(fig,'allMenAndSub','Off')
        Tab_Synt_Status = zeros(2,3);
        wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);
        hdl_VIS_OnOff = [hdl_VIS_OnOff;...
            handles.Txt_BigTitle ; hdl_Axe_ANAL ; axCB];
        hdl_VIS_OnOff = hdl_VIS_OnOff(ishandle(hdl_VIS_OnOff));
        wtbxappdata('set',fig,'Sel_Box_CFS',[]);
        set(findall(hdl_VIS_OnOff),'Visible',vis);
        if isequal(option,'load_beg')
            set(handles.Pop_DEF_ANG,'Value',2);
            set(handles.Pop_DEF_SCA,'Value',1);
            if ~isequal(typeLOAD,'demo')
                set(handles.Pop_WAV_NAM,'Value',1) % Morlet
                set(handles.Edi_WAV_PAR,'String','[6,1,1]')
                Pop_WAV_NAM_Callback(fig,[],handles)
            end
            Pop_DEF_SCA_Callback(handles.Pop_DEF_SCA,[],handles)
            Pop_DEF_ANG_Callback(handles.Pop_DEF_ANG,[],handles)
            dynvtool('ini_his',fig,-1);
        end
end
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(fig)

% Add UIMENUS.
%-------------
m_files  = wfigmngr('getmenus',fig,'file');
m_close  = wfigmngr('getmenus',fig,'close');
cb_close = @(o,~)cwtfttool2('Pus_CloseWin_Callback',o,[],guidata(o));
set(m_close,'Callback',cb_close);

m_Load_Data = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_LoadData'), ...
    'Position',1,'Enable','On','Tag','Load',  ...
    'Callback',                ...
    @(o,~)cwtfttool2('Load_Data_Callback',o,[],guidata(o),'load')  ...
    );
m_save = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:cwtfttool:label_Save'),'Position',2, 'Enable','Off'  ...
    );
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:cwtfttool:label_Decomposition'), ...
    'Position',1, 'Enable','On','Tag','Decomposition',  ...
    'Callback',@(o,~)cwtfttool2('Men_SavDEC_Callback',o,[],guidata(o)) ...
    );

m_demo = uimenu(m_files,'Label',getWavMSG('Wavelet:cwtfttool:label_ExampleAnalysis'),...
    'Position',3,'Separator','Off');
m_subdemo(1) = uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_IndImg'),...
    'Tag','Ind_Img','Position',1);  % Indexed images
m_subdemo(2) = uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_ColImg'),...
    'Tag','Col_Img','Position',2);  % Truecolor images

uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ImportData'), ...
    'Position',4,'Enable','On' ,'Separator','On',  ...
    'Tag','Import', ...
    'Callback',                ...
    @(o,~)cwtfttool2('Load_Data_Callback',o,[],guidata(o),'import')  ...
    );

m_exp_data = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ExportData'),'Position',5, ...
    'Tag','Export_Data','Enable','Off','Separator','Off'  ...
    );
uimenu(m_exp_data, ...
    'Label',getWavMSG('Wavelet:cwtfttool:label_ExportCWTFTStructToWorkspace'), ...
    'Position',1,'Enable','On','Separator','Off','Tag','Export_CWTFT',...
    'Callback',...
    @(o,~)cwtfttool2('Export_Callback',o,[],guidata(o),'ana')  ...
    );

sigDESC{1} = {...
    'Circle (256x256) - wavelet: morl6',... 
    'Circle (256x256) - wavelet: paul4', ...
    'Triangle (128x128) - wavelet: morl6',... 
    'Triangle (128x128) - wavelet: paul4', ...    
    'Hexagon (128x128) - wavelet: morl6',... 
    'Hexagon (128x128) - wavelet: paul4', ...
    'Star (128x128) - wavelet: morl6',... 
    'Star (128x128) - wavelet: paul4',  ...
    'Circle, Rectangle and Triangle (512x512) - wavelet: morl6',... 
    'Circle, Rectangle and Triangle (512x512) - wavelet: paul4', ...
    'Mask (256x256) - wavelet: morl6', ...
    'Mask (256x256) - wavelet: paul4',  ...
    'Mask (256x256) - wavelet: mexh',  ...
    'Mask (256x256) - wavelet: dog',  ...
    'Mask (256x256) - wavelet: gaus',  ...
    'Laure (256x256) - wavelet: morl6',... 
    'Laure (256x256) - wavelet: paul4', ...
    'Pearswtx (256x512) - wavelet: morl6',... 
    'Pearswtx (256x512 - wavelet: paul4', ...
    'Catherine (256x256) - wavelet: morl6',...
    'Catherine (256x256) - wavelet: paul4', ...
    'Woman (256x256) - wavelet: morl6', ...
    'Woman (256x256) - wavelet: paul4', ...
    'Bust (256x256) - wavelet: morl6', ...
    'Bust (256x256) - wavelet: paul4' , ...
    'Porch (512x512) - wavelet: morl6', ...
    'Porch (512x512) - wavelet: paul4' , ...
    'Finger (256x256) - wavelet: morl6', ...
    'Finger (256x256) - wavelet: paul4', ...
    'Glasses (512x512) - wavelet: morl6',... 
    'Glasses (512x512) - wavelet: paul4' ...        
    };

sigDESC{2} = {...
    'woodstatue (256x256) - wavelet: morl - lin', ...
    'woodstatue (256x256) - wavelet: paul4 - lin', ...
    'wpeppers (512x512) - wavelet: morl - lin', ...
    'wpeppers (512x512) - wavelet: paul4 - lin', ...
    'whorse (512x512) - wavelet: morl - lin', ...
    'whorse (512x512) - wavelet: paul4 - lin', ...
    'wflower (256x256) - wavelet: morl - lin', ...
    'wflower (256x256) - wavelet: paul4 - lin', ...
    'persan (512x512) - wavelet: morl - lin', ...
    'persan (512x512) - wavelet: paul4 - lin', ...
    'devil (300x400) - wavelet: morl - lin', ...
    'devil (300x400) - wavelet: paul4 - lin', ...
    'arms (256x256) - wavelet: morl - lin', ...
    'arms (256x256) - wavelet: paul4 - lin', ...
    'woodsculp256 (256x256) - wavelet: morl - lin', ...
    'woodsculp256 (256x256) - wavelet: paul4 - lin', ...
    'Glasses (512x512) - wavelet: morl6',... 
    'Glasses (512x512) - wavelet: paul4', ...    
    'Ironthree (1152x1152) - wavelet: morl6',... 
    'Ironthree (1152x1152) - wavelet: paul4' ...    
    };

for j = 1:2
    nbSIG = length(sigDESC{j});
    for k = 1:nbSIG
        sep = 'Off';
        if (j==1 && (k==11 || k==16)) , sep = 'On'; end
        uimenu(m_subdemo(j), ...
            'Label',['Ex' int2str(k) ' - ' sigDESC{j}{k}],    ...
            'Position',k,'Enable','On','Separator',sep,     ...
            'Callback',       ...
            @(o,~)cwtfttool2('Men_Example_Callback',o,[],guidata(o),j) ...
            );
    end
end


% Add Help for Tool.
%------------------
wfighelp('addHelpTool',fig, ...
    getWavMSG('Wavelet:cwtfttool2:HLP_CWTFT2'),'CWTFT2_GUI');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_Load_Data',m_Load_Data,...
    'm_save',m_save,'m_demo',m_demo,'m_exp_data',m_exp_data);
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%



%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function Men_Example_Callback(hObject,eventdata,handles,varargin) 

optDEM = varargin{1};
numDEM = get(hObject,'Position');
switch optDEM
    case 1
        demoCell = {...
            'circle.jpg','morl',[],'lin'; ...
            'circle.jpg','paul',[],'lin'; ...
            'triangle.jpg','morl',[],'lin'; ...
            'triangle.jpg','paul',[],'lin'; ...
            'hexagon.jpg','morl',[],'lin'; ...
            'hexagon.jpg','paul',[],'lin'; ...
            'star.jpg','morl',[],'lin'; ...
            'star.jpg','paul',[],'lin'; ...
            'crtcol','morl',[],'lin'; ...
            'crtcol','paul',[],'lin'; ... 
            'mask','morl',[],'lin'; ...
            'mask','paul',[],'lin'; ...
            'mask','mexh',[],'lin'; ...
            'mask','dog',[],'lin'; ...
            'mask','gaus',[],'lin'; ...
            'laure','morl',[],'lin'; ...
            'laure','paul',[],'lin';...
            'pearswtx.jpg','morl',[],'lin'; ...
            'pearswtx.jpg','paul',[],'lin'; ...
            'catherine','morl',[],'lin'; ...
            'catherine','paul',[],'lin'; ...
            'woman','morl',[],'lin'; ...
            'woman','paul',[],'lin'; ...
            'bust','morl',[],'lin'; ...
            'bust','paul',[],'lin'; ...
            'porche','morl',[],'lin'; ...
            'porche','paul',[],'lin'; ...
            'finger','morl',[],'lin'; ...
            'finger','paul',[],'lin'; ...
            'glasses.jpg','morl',[],'lin'; ...
            'glasses.jpg','paul',[],'lin'  ...
            };
        
    case 2
         demoCell = {...
            'woodstatue.jpg','morl',[],'lin'; ...
            'woodstatue.jpg','paul',[],'lin'; ...
            'wpeppers.jpg','morl',[],'lin'; ...
            'wpeppers.jpg','paul',[],'lin'; ...
            'whorse.jpg','morl',[],'lin'; ...
            'whorse.jpg','paul',[],'lin'; ...
            'wflower.jpg','morl',[],'lin'; ...
            'wflower.jpg','paul',[],'lin'; ...            
            'persan.jpg','morl',[],'lin'; ...
            'persan.jpg','paul',[],'lin'; ...            
            'devil.jpg','morl',[],'lin'; ...
            'devil.jpg','paul',[],'lin'; ...
            'arms.jpg','morl',[],'lin'; ...
            'arms.jpg','paul',[],'lin'; ...            
            'woodsculp256.jpg','morl',[],'lin'; ...
            'woodsculp256.jpg','paul',[],'lin'; ... 
            'glasses.jpg','morl',[],'lin'; ...
            'glasses.jpg','paul',[],'lin';  ...                        
            'ironthree.jpg','morl',[],'lin'; ...
            'ironthree.jpg','paul',[],'lin' ...            
            };       
end
Load_Data_Callback(hObject,eventdata,handles,'demo',optDEM,demoCell,numDEM);
%-------------------------------------------------------------------------%
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%


%--------------------------------------------------------------------------
function Load_Data_Callback(hObject,eventdata,handles,varargin) %#ok<*INUSL>

% Get figure handle.
%-------------------
% axAspect = {'image'};
axAspect = {'tight'};

fig = handles.output;
typeLOAD = varargin{1};
switch typeLOAD
    case 'load'
        default_nbcolors = 255;
        imgFileType = getimgfiletype;
        [imgInfos,X,map,ok] = utguidiv('load_img',fig, ...
            imgFileType,getWavMSG('Wavelet:commongui:Load_Image'), ...
            default_nbcolors); %#ok<ASGLU>
        if ~ok, return; end
        if ~ok
            uiwait(warndlg(getWavMSG('Wavelet:cwtfttool:dlg_Invalid1DData')),...
                getWavMSG('Wavelet:cwtfttool:dlg_Loading1DData'),'modal')
            return;
        end
        Data_Name = imgInfos.name;
        
    case 'import'
        [dataInfos,X,ok] = wtbximport('2d');
        if ~ok, return; end
        Data_Name = dataInfos.name;

    case 'demo'
        fileOPT = varargin{2};
        demoCell = varargin{3};
        numDEM = varargin{4};
        param = demoCell{numDEM,3};
        switch fileOPT
            case 0
                filename = demoCell{numDEM,1};
                S  = load(filename);
                fn = fieldnames(S);
                if isfield(S,'X') 
                    X = S.('X'); 
                else
                    X = S.(fn{1}); 
                end
                [~,Data_Name] = fileparts(filename);
                
            case {1,2,3}
                sigName = demoCell{numDEM,1};
                try
                    X = imread(demoCell{numDEM,1},'jpg');
                    
                catch %#ok<CTCH>
                    S = load(sigName);                    
                    fn = fieldnames(S);
                    if isfield(S,'X') 
                        X = S.('X');
                    else
                        X = S.(fn{1});
                    end
                    NB_ColorsInPal = 220;
                    if isfield(S,'map')
                        map = S.('map');
                        cbcolmap('set',fig,'pal',...
                            {'pink',NB_ColorsInPal,'self',map});
                        cbcolmap('pal',fig)
                    else
                        cbcolmap('set',fig,'pal',{'pink',NB_ColorsInPal});
                    end
                    clear S;
                end
                if fileOPT==1 , X = wconvimg('col2idx',X); end
                
                wname = demoCell{numDEM,2};
                switch wname
                    case 'paul', valWAV = 3;
                    case 'morl', valWAV = 1;
                    case 2 , valWAV = 4;
                    case 3 , valWAV = 5;
                    otherwise
                        LST = get(handles.Pop_WAV_NAM,'String');
                        valWAV = find(strcmp(LST,wname));
                end
                set(handles.Pop_WAV_NAM,'Value',valWAV);
                Pop_WAV_NAM_Callback(handles.Pop_WAV_NAM,eventdata,handles);
                Data_Name = sigName;
        end
        
end
wtbxappdata('set',fig,'Sig_ANAL',X);
wtbxappdata('set',fig,'Img_SIZE',size(X));
cbcolmap('Enable',fig,'On');
if size(X,3)>1 
    vis_UtColor = 'Off'; 
else
    vis_UtColor = 'On';
end
cbcolmap('Visible',fig,vis_UtColor);

% Cleaning.
%----------
wwaiting('msg',fig,getWavMSG('Wavelet:cwtfttool:WaitClean'));

% Clean Axes.
%------------
cleanTOOL('load_beg',fig,handles,typeLOAD);

% Clean UIC.
%------------
hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_data = hdl_Menus.m_exp_data;
Hdl_to_Disable = [...
    m_save,m_exp_data,  ...
    handles.Pus_ShowCfs,handles.Pus_SEL_Scales,handles.Pus_SEL_Angles, ...
    handles.Txt_Cur_SCA,handles.Pop_Cur_SCA, ...
    handles.Txt_Cur_ANG,handles.Pop_Cur_ANG,handles.Pus_Apply];
Hdl_to_Enable = [...
    handles.Pop_DEF_SCA,handles.Pop_DEF_ANG,handles.Pop_WAV_NAM, ...
    handles.Pus_More_Params,handles.Pus_ANAL     ...
    ];
set([Hdl_to_Disable,Hdl_to_Enable],'Enable','Off');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
sz = size(X);
if length(sz)<3
    n_s = [Data_Name '  (' , int2str(sz(1)) ',' int2str(sz(2)) ')'];
else
    n_s = [Data_Name '  (' , int2str(sz(1)) ',' int2str(sz(2))  ',' int2str(sz(3)) ')'];
end
set(handles.Edi_Data_NS,'String',n_s);

% Display the original data.
%---------------------------
Axe_SIG_L = handles.Axe_SIG_L;
set(findall(Axe_SIG_L),'Visible','On');
titleSTR = getWavMSG('Wavelet:cwtfttool2:Analyzed_Image');

set(Axe_SIG_L,'YDir','Reverse','Box','On');
image(X,'Tag','SIG','Parent',Axe_SIG_L); 
wtitle(titleSTR,'Parent',Axe_SIG_L)
axis(Axe_SIG_L,axAspect{:})

% Clean Tool.
%------------
set(Hdl_to_Enable,'Enable','On');

% End waiting.
%-------------
wwaiting('off',fig);

% Demo case.
%-----------
if isequal(typeLOAD,'demo')
     Pus_ANAL_Callback(handles.Pus_ANAL,eventdata,handles,param);
end
%--------------------------------------------------------------------------
function hC = Add_ColorBar(hA)

fig = ancestor(hA,'figure');
ImgSIZE = wtbxappdata('get',fig,'Img_SIZE');
if length(ImgSIZE)>2 , return; end   % True Color Image

a = wfindobj(fig,'type','axes');
tag = get(a,'Tag');
a = a(strcmp(tag,'Colorbar'));
for k = 1:length(a)
    ud = get(a(k),'Userdata');
    if isequal(ud.Parent,hA)
        delete(a(k)); break
    end
end

pA = get(hA,'Position');
hC = colorbar('peer',hA,'EastOutside');
set(hA,'Position',pA);
pC = get(hC,'Position');
set(hC,'Position',[pA(1)+pA(3)+0.01  pC(2)+pC(4)/15 pC(3)/2 4*pC(4)/5])
ud.dynvzaxe.enable = 'Off';
ud.Parent = hA;
set(hC,'UserData',ud);
%-----------------------------------------------------------------------
function SavMenOnOff(fig,num,ena)

SavSIG_Men = wfindobj(fig,'Type','uimenu','Tag','SavSIG_Men');
switch num
    case {1,2,3}
        M = wfindobj(fig,'Type','uimenu', ...
            'Parent',SavSIG_Men,'Position',num);
        
    case '0.1'
        M = wfindobj(fig,'Type','uimenu', ...
            'Parent',SavSIG_Men,'Position',1);
        M = [SavSIG_Men;M];
        
    case 'all'
        M = wfindobj(fig,'Type','uimenu','Parent',SavSIG_Men);
        
    case 'allMenAndSub'
        M = wfindobj(fig,'Type','uimenu','Parent',SavSIG_Men);
        M = [SavSIG_Men;M];
end
set(M,'Enable',ena);
%-----------------------------------------------------------------------


%=========================================================================%
%                BEGIN UICONTROL CALLBACKS FUNCTIONS                      %
%                -----------------------------------                      %
%=========================================================================%
%--------------------------------------------------------------------------
function Edi_SAMP_Callback(hObject,~,~)

val = str2double(get(hObject,'String'));
notOK = isnan(val) || val<=0 || ~isfinite(val);
if notOK
    usr = get(hObject,'Userdata');
    set(hObject,'String',num2str(usr));
    return
end
set(hObject,'Userdata',val);
%--------------------------------------------------------------------------
function Pus_ShowCfs_Callback(hObject,eventdata,handles) 

IdxSEL = get(handles.Lst_SEL_SC,'Value');
showScaleANAL(handles,IdxSEL(:),'select');
%--------------------------------------------------------------------------
function Pus_SEL_Scales_Callback(hObject,eventdata,handles)

PanSC = handles.Pan_SEL_SC;
ax = handles.Axe_SIG_L;
v = lower(get(PanSC,'Visible'));
if isequal(v,'on')
    v = 'off'; w = 'on';   
else
    [pus,fig] = gcbo;
    if isequal(pus,handles.Pus_SEL_Scales)
        Sel_Type = 'scales';
        Lst_Scales_INI(fig,handles);
        titleSTR = getWavMSG('Wavelet:cwtfttool2:Pan_SEL_Scales');
    else
        Sel_Type = 'angles';
        Lst_Angles_INI(fig,handles);
        titleSTR = getWavMSG('Wavelet:cwtfttool2:Pan_SEL_Angles');
    end
    set(PanSC,'title',titleSTR,'Userdata',Sel_Type);
    v = 'on';  w = 'off';  
end
set(handles.Pus_More_Params,'Enable',w);
set([handles.Pus_ANAL,handles.Pan_Visu],'Visible',w);

set([...
    handles.Txt_WAV_NAM;handles.Pop_WAV_NAM;   ...
    handles.Txt_DEF_SCA;handles.Pop_DEF_SCA; ...
    handles.Txt_DEF_ANG;handles.Pop_DEF_ANG; ...
    handles.Pus_DEF_SCA; ...
    handles.Txt_Cur_SCA;handles.Pop_Cur_SCA; ...
    handles.Txt_Cur_ANG;handles.Pop_Cur_ANG;handles.Pus_Apply],'Enable',w);
set(PanSC,'Visible',v);
set(handles.Pan_Visu,'Visible',w);
titleSTR = getWavMSG('Wavelet:cwtfttool2:Analyzed_Image');    
wtitle(titleSTR,'Parent',ax);
%--------------------------------------------------------------------------
function Pus_SEL_ALL_Callback(hObject,eventdata,handles)   

LstSC = handles.Lst_SEL_SC;
set(LstSC,'Value',1:size(get(LstSC,'String'),1))
%--------------------------------------------------------------------------
function Pus_SEL_NON_Callback(hObject,eventdata,handles)   

LstSC = handles.Lst_SEL_SC;
set(LstSC,'Value',[])
%--------------------------------------------------------------------------
function Pus_SEL_CLOSE_Callback(hObject,eventdata,handles) 

PanSC = handles.Pan_SEL_SC;
v = lower(get(PanSC,'Visible'));
if isequal(v,'on')
    v = 'off'; w = 'on';   
else
    v = 'on';  w = 'off';  
end
set([...
    handles.Txt_WAV_NAM;handles.Pop_WAV_NAM;   ...
    handles.Txt_DEF_SCA;handles.Pop_DEF_SCA;   ... 
    handles.Txt_DEF_ANG;handles.Pop_DEF_ANG; ...    
    handles.Pus_DEF_SCA; ...
    handles.Txt_Cur_SCA;handles.Pop_Cur_SCA; ...
    handles.Txt_Cur_ANG;handles.Pop_Cur_ANG;handles.Pus_Apply],'Enable',w);
set([handles.Pus_ANAL,handles.Pan_Visu],'Visible',w);
set(handles.Pus_More_Params,'Enable',w);
set(PanSC,'Visible',v);

fig = gcbf;
Tab_Synt_Status = wtbxappdata('get',fig,'Tab_Synt_Status');
Tab_Synt_Status(2,2) = 0;
wtbxappdata('set',fig,'Tab_Synt_Status',Tab_Synt_Status);        
%--------------------------------------------------------------------------
function Lst_Scales_INI(fig,handles)

hdl_TXT = handles.Txt_PAN_Sel;
set(hdl_TXT,'String',getWavMSG('Wavelet:cwtfttool2:Num_Value'));

scales_INI = wtbxappdata('get',fig,'Scales_INI');
Lst_SC = handles.Lst_SEL_SC;
NbSc = length(scales_INI);
Lst = [repmat(' ',NbSc,1) num2str((1:NbSc)','%7.0f') ...
    repmat('  |  ',NbSc,1) num2str(scales_INI','%4.4f') ...
    repmat('  |',NbSc,1)];   
set(Lst_SC,'String',Lst,'Value',[],'ListboxTop',1);
%--------------------------------------------------------------------------
function Lst_Angles_INI(fig,handles)

hdl_TXT = handles.Txt_PAN_Sel;
set(hdl_TXT,'String',getWavMSG('Wavelet:cwtfttool2:Num_Rad_Deg'));

angles_INI = wtbxappdata('get',fig,'Angles_INI');
Lst_SEL = handles.Lst_SEL_SC;
val_RAD = angles_INI'/pi;
val_DEG = 180*angles_INI'/pi;
NbAng = length(angles_INI);
tempo = rats(val_RAD);
tempo(:,[1:4,end-3:end]) = [];
degSTR = num2str(val_DEG,'%5.2f');
Lst = [repmat('  ',NbAng,1) num2str((1:NbAng)','%7.0f') ...
    repmat('  |  ',NbAng,1) tempo repmat(' pi',NbAng,1)...
    repmat('  |  ',NbAng,1) degSTR repmat('  |',NbAng,1)];   

set(Lst_SEL,'String',Lst,'Value',[],'ListboxTop',1);
%--------------------------------------------------------------------------
function Edi_WAV_PAR_Callback(hObject,~,~) 

%--------------------------------------------------------------------------
function Pop_WAV_NAM_Callback(hObject,eventdata,handles)

WNam = get(handles.Pop_WAV_NAM,{'Value','String'});
wname = deblank(WNam{2}{WNam{1}});
WAV_Param_Table = wtbxappdata('get',hObject,'WAV_Param_Table');
idx_Wave = strcmp(wname,WAV_Param_Table(:,1));
PAR_Cell = WAV_Param_Table(idx_Wave,2);
PAR_VAL  = PAR_Cell{1};
STR = [];
nb_PAR = size(PAR_VAL,1);
for j = 1:nb_PAR
    par = PAR_VAL{j,2};
    if ischar(par)
        STR = [STR, par]; %#ok<*AGROW>
    else
        STR = [STR , num2str(par,'%5.3f')];
    end
    if j<nb_PAR , STR = [STR,',']; end
end
STR = ['[' STR ']'];
set(handles.Edi_WAV_PAR,'String',STR,'Visible','On');
%--------------------------------------------------------------------------
function Pop_DEF_SCA_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
old = get(hObject,'Userdata');
set(hObject,'Userdata',val);
switch val
    case 1 , vis = 'off';    
    case 2 , vis = 'off';
    case 3 , vis = 'on';
end
if ~isequal(old,val)
    newpos = false;
    p = get(hObject,'Position');
    if ((old==1 || old==2) && val==3)
        p(3) = p(3)/1.5; newpos = true;
    elseif old==3
        p(3) = 1.5*p(3); newpos = true;
    end
    if newpos , set(hObject,'Position',p); end
end
set(handles.Pus_DEF_SCA,'Visible',vis);
%--------------------------------------------------------------------------
function Pus_DEF_SCA_Callback(hObject,eventdata,handles) 

fig = gcbf;
Change_Enabled = wfindobj(fig,'Enable','on');
kept_Enabled = allchild(handles.Pan_SEL_MAN_SCA);
Change_Enabled = setdiff(Change_Enabled,kept_Enabled);
wtbxappdata('set',fig,'Pus_DEF_SCA_Ena',Change_Enabled);
set(Change_Enabled,'Enable','off');
set([handles.Pus_ANAL,handles.Pus_SEL_Scales,handles.Pan_Visu, ...
    handles.Pus_SEL_Angles,handles.Pan_SEL_SCA_ANG,],'Visible','off');
set(handles.Pan_SEL_MAN_SCA,'Visible','on');
%--------------------------------------------------------------------------
function Pop_SCA_TYPE_Callback(hObject,eventdata,handles) 

val = get(hObject,'Value');
group1 = [...
    handles.Txt_SCA_INI;handles.Edi_SCA_INI; ...
    handles.Txt_SCA_SPA;handles.Edi_SCA_SPA; ...
    handles.Txt_SCA_NB; handles.Edi_SCA_NB ...    
    ];
switch val
    case 1  % Type = Power
        HdL_VIS = [group1; handles.Pop_SCA_POW;handles.Pus_SCA_Default];
        HdL_InVIS = [handles.Edi_SCA_Manual];
        
    case 2  % Type = Linear
        HdL_VIS = [group1;handles.Pus_SCA_Default];
        HdL_InVIS = [handles.Pop_SCA_POW;handles.Edi_SCA_Manual];
       
    case 3  % Type = Manual
        HdL_VIS = [handles.Edi_SCA_Manual;handles.Pus_SCA_Default];
        HdL_InVIS = [group1; handles.Pop_SCA_POW];
end
set(HdL_InVIS,'Visible','off');
set(HdL_VIS,'Visible','on');
%--------------------------------------------------------------------------
function Pop_SCA_POW_Callback(hObject,~,~) 

cwtftcbpop2('defString',hObject,'pow')
%--------------------------------------------------------------------------
function Pus_SCA_Apply_Callback(hObject,eventdata,handles) 

fig = gcbf;
AP = wtbxappdata('get',fig,'Pow_Anal_Params');
valType = get(handles.Pop_SCA_TYPE,'value');
switch valType
    case {1,2}   % Type = Power and Type = Linear
        err = 0;
        s0 = str2double(get(handles.Edi_SCA_INI,'String'));
        if isempty(s0) || isnan(s0) || (s0<=1E-9)
            set(handles.Edi_SCA_INI,'String','1');
            err = 1;
        end
        SCA.s0 = s0;
        ds = str2double(get(handles.Edi_SCA_SPA,'String'));
        SCA.ds = ds;
        if isempty(ds) || isnan(ds) || (ds<=1E-9)
            set(handles.Edi_SCA_SPA,'String','2');
            err = 1;
        end
        nb = str2double(get(handles.Edi_SCA_NB,'String'));
        if isempty(nb) || isnan(nb) || (nb<1)
            set(handles.Edi_SCA_NB,'String','20');
            err = 1;
        end
        if err
            beep; return;
        end
        SCA.nb = nb;
        if valType==1
            SCA.type = 'pow';
            Lst = get(handles.Pop_SCA_POW,'String');
            idx = get(handles.Pop_SCA_POW,'value');
            pow = str2double(Lst{idx});
            SCA.pow = pow;
            scales = (SCA.s0) * (SCA.pow).^((0:(SCA.nb)-1)*(SCA.ds));
        else
            SCA.type = 'lin';
            scales = SCA.s0 + (0:(SCA.nb)-1)*(SCA.ds);
        end
        
    case 3   % Type = Manual
        SCA = [];
        scales = str2num(get(handles.Edi_SCA_Manual,'String')); %#ok<ST2NM>
end
AP.SCA = SCA;
AP.scales = scales;
wtbxappdata('set',fig,'Pow_Anal_Params',AP)

Change_Enabled = wtbxappdata('get',fig,'Pus_DEF_SCA_Ena');
set(handles.Pan_SEL_MAN_SCA,'Visible','off')
set([handles.Pus_ANAL,handles.Pus_SEL_Scales,handles.Pan_Visu, ...
    handles.Pus_SEL_Angles,handles.Pan_SEL_SCA_ANG],'Visible','on');
set(Change_Enabled,'Enable','on');
%--------------------------------------------------------------------------
function Pus_SCA_Cancel_Callback(hObject,eventdata,handles) 

fig = gcbf;
Change_Enabled = wtbxappdata('get',fig,'Pus_DEF_SCA_Ena');
set(handles.Pan_SEL_MAN_SCA,'Visible','off')
set([handles.Pus_ANAL,handles.Pus_SEL_Scales,handles.Pan_Visu, ...
    handles.Pus_SEL_Angles,handles.Pan_SEL_SCA_ANG], ...
    'Visible','on');
set(Change_Enabled,'Enable','on');
%--------------------------------------------------------------------------
function Pus_SCA_Default_Callback(hObject,eventdata,handles) 

Edi_INI = handles.Edi_SCA_INI;
Edi_SPA = handles.Edi_SCA_SPA;
Edi_NBS = handles.Edi_SCA_NB;
TMP = get(handles.Pop_WAV_NAM,{'Value','String'});
wname = TMP{2}{TMP{1}};
typeMAN = get(handles.Pop_SCA_TYPE,'Value');
sX = size(wtbxappdata('get',gcbf,'Sig_ANAL'));
nbSamp = min(sX(1:2));
dt = 1;
switch typeMAN
    case 1  % Power
        [s0,ds,NbSc] = getDefaultAnalParams({wname,[]},nbSamp,dt);
        
    case 2  % Linear
        maxsca = dt*nbSamp;
        s0 = 2*dt; ds = 10*dt; NbSc = length(s0:ds:maxsca);
        
    case 3  % Manual
        s0 = dt; ds = 5*dt;   
        maxsca = dt*nbSamp;
        NbSc = length(s0:ds:maxsca);
        maxsca = s0+ds*(NbSc-1);
end
prec_s0 = nbdigit(s0);
prec_ds = nbdigit(ds);
frm_s0_STR = ['%'  '1.' int2str(prec_s0) 'f'];
frm_ds_STR = ['%'  '1.' int2str(prec_ds) 'f'];
s0STR = num2str(s0,frm_s0_STR);
dsSTR = num2str(ds,frm_ds_STR);
if ~isequal(typeMAN,3)
    set(Edi_INI,'String',s0STR)
    set(Edi_SPA,'String',dsSTR)
    set(Edi_NBS,'String',int2str(NbSc))
else
    prec_maxsca = nbdigit(maxsca);
    frm_maxscaSTR = ['%'  '1.' int2str(prec_maxsca) 'f'];
    maxscaSTR = num2str(maxsca,frm_maxscaSTR);
    strDEF = ['[' s0STR ' : ' dsSTR ' : ' maxscaSTR ']'];
    set(handles.Edi_SCA_Manual,'String',strDEF);
end
%----------------------------------
function prec = nbdigit(x)

mul = 0.1;
continu = true;
while continu
    mul = 10*mul;
    d = mul*x - floor(mul*x);
    continu = ~isequal(d,0);
end
prec = log10(mul);
%--------------------------------------------------------------------------
function [s0,ds,NbSc,scales] = getDefaultAnalParams(WAV,nbSamp,dt)

wname = WAV{1};
switch wname
    case {'morl','morlex','morl0'} 
        s0 = 2*dt; ds = 0.4875; NbSc = fix(log2(nbSamp)/ds)+1;
        scales = s0*2.^((0:NbSc-1)*ds);
       
    case {'mexh','dog'}
        s0 = 2*dt;  ds = 0.4875; NbSc = max([fix(log2(nbSamp)/ds),1]);
        scales = s0*2.^((0:NbSc-1)*ds);
        
    case 'paul'
        s0 = 2*dt;  ds = 0.4875; NbSc = fix(log2(nbSamp)/ds)+1;
        scales = s0*2.^((0:NbSc-1)*ds);
end
%--------------------------------------------------------------------------
%=========================================================================%
%                END OF UICONTROL CALLBACKS FUNCTIONS                     %
%=========================================================================%

%--------------------------------------------------------------------------
function err = showScaleANAL(handles,IdxSEL,showOPT)

err = false;
% axAspect = {'image'};
axAspect = {'tight'};

fig = handles.output;
NbSEL = size(IdxSEL,1);
if isequal(NbSEL,0) && ~isequal(showOPT,'movie') , beep; return; end
CWTStruct = wtbxappdata('get',fig,'CWTStruct');
cwtcfs = CWTStruct.cfs;
scales = CWTStruct.scales;
angles = CWTStruct.angles;
% realCFS = isreal(cwtcfs);
realCFS = 0;
FlagReal = wtbxappdata('get',fig,'FlagReal');
resetAXES = ~isequal(FlagReal,realCFS) || realCFS==1;
Sel_Type = get(handles.Pan_SEL_SC,'Userdata');
if isempty(Sel_Type) || isequal(showOPT,'first')
    Sel_Type = 'scales'; 
    set(handles.Pan_SEL_SC,'Userdata',Sel_Type);
end
if size(IdxSEL,2)==1
    switch Sel_Type
        case 'scales'
            idxSCA = IdxSEL;
            idxANG = get(handles.Pop_Cur_ANG,'Value');
            OneCFS =  cwtcfs(:,:,:,idxSCA,idxANG);
            
        case 'angles'
            idxSCA = get(handles.Pop_Cur_SCA,'Value');
            idxANG = IdxSEL;
            OneCFS = cwtcfs(:,:,:,idxSCA,idxANG);
    end      
end
if isequal(showOPT,'first') , cleanTOOL('anal_beg',fig,handles); end

if resetAXES
    wtbxappdata('set',fig,'FlagReal',realCFS);
    if realCFS 
        colPOS = 4; else 
        colPOS = 3;  
    end %      #ok<*UNRCH>
    axe_STORAGE = wtbxappdata('get',fig,'axe_STORAGE');
    idx = find(strcmp(axe_STORAGE(:,1),'Axe_SIG_L'));
    set(axe_STORAGE{idx,2},'Position',axe_STORAGE{idx,colPOS});
    idx = find(strcmp(axe_STORAGE(:,1),'Axe_MOD'));
    set(axe_STORAGE{idx,2},'Position',axe_STORAGE{idx,colPOS});
    idx = find(strcmp(axe_STORAGE(:,1),'Axe_REAL'));
    set(axe_STORAGE{idx,2},'Position',axe_STORAGE{idx,colPOS});
    if realCFS 
        vis = 'Off'; 
    else
        vis = 'On';
    end       %#ok<*UNRCH>
    idxAXE = [find(strcmp(axe_STORAGE(:,1),'Axe_ANG')); ...
           find(strcmp(axe_STORAGE(:,1),'Axe_IMAG'))];
    idxAXE = cat(1,axe_STORAGE{idxAXE,2});
    set(findall(idxAXE),'Visible',vis);
end

if NbSEL==1    
    switch Sel_Type
        case 'scales'
            idxSCA = IdxSEL(1);
            idxANG = get(handles.Pop_Cur_ANG,'Value');
            OneCFS =  cwtcfs(:,:,:,idxSCA,idxANG);
            
        case 'angles'
            idxSCA = get(handles.Pop_Cur_SCA,'Value');
            if size(IdxSEL,2)==1
                idxANG = IdxSEL(1);
            else
                idxANG = IdxSEL(2);
            end
            OneCFS = cwtcfs(:,:,:,idxSCA,idxANG);
    end  
    ax = handles.Axe_MOD;
    titleSTR = getWavMSG('Wavelet:cwtfttool:title_Modulus');
    displayImage(abs(OneCFS),ax)
    set(ax,'Ydir','Reverse','Box','On');
    axis(ax,axAspect{:});
    wxlabel(titleSTR,'Parent',ax);
    Add_ColorBar(ax);
    
    ax = handles.Axe_REAL;
    titleSTR = getWavMSG('Wavelet:cwtfttool:title_RealPart');
    displayImage(real(OneCFS),ax)
    set(ax,'Ydir','Reverse','Box','On');
    axis(ax,axAspect{:});
    wxlabel(titleSTR,'Parent',ax);
    Add_ColorBar(ax);
    
    if ~realCFS
        ax = handles.Axe_ANG;
        titleSTR = getWavMSG('Wavelet:cwtfttool:title_Angle');
        displayImage(angle(OneCFS),ax)
        set(ax,'Ydir','Reverse','Box','On');
        axis(ax,axAspect{:});
        wxlabel(titleSTR,'Parent',ax);
        Add_ColorBar(ax);
        
        ax = handles.Axe_IMAG;
        titleSTR = getWavMSG('Wavelet:cwtfttool:title_ImaginaryPart');
        displayImage(imag(OneCFS),ax)
        set(ax,'Ydir','Reverse','Box','On');
        axis(ax,axAspect{:});
        wxlabel(titleSTR,'Parent',ax);
        Add_ColorBar(ax);
    end
   
    scales = CWTStruct.scales;
    angles = CWTStruct.angles;
    angSTR = getAngleSTR(angles(idxANG));
    BigTitleSTR = getWavMSG('Wavelet:cwtfttool2:BigTitleSTR_2D_BIS', ...
        idxSCA,num2str(scales(idxSCA),'%3.3f'),idxANG,angSTR);
    bigTitle = wtbxappdata('get',fig,'Txt_BigTitle');
    set(bigTitle,'String',BigTitleSTR);
    
elseif isequal(showOPT,'select')
    win_Tag = ['Win_ShowCfs_' Sel_Type];
    win_Name = getWavMSG(['Wavelet:cwtfttool2:Win_CFS_' Sel_Type]);
    showFig = wfindobj(0,'type','figure','tag',win_Tag);
    if ishandle(showFig) , delete(showFig); end
    FS = mextglob('get','Def_TxtFontSize');
    showFig = figure(...
        'MenuBar','none','NumberTitle','Off','Name',win_Name, ...
        'Units','normalized','Position',[0.25 , 0.1 , 0.5 , 0.8],...
        'DefaultAxesXtick',[],'DefaultAxesYtick',[],...
        'DefaultAxesFontSize',FS,'ColorMap',gray(250), ...
        'Tag',win_Tag);
    wfigmngr('extfig',showFig,'ExtFig_DynV');
    dynvtool('create',showFig);
    idxPlot = 1;
    if ~realCFS 
        nbCOL = 4; 
    else
        nbCOL = 2;
    end
    axPLOT = zeros(NbSEL,1);
    switch Sel_Type
        case 'scales'
            idxANG = get(handles.Pop_Cur_ANG,'Value');
            tempo = rats(angles(idxANG)/pi);
            tempo(:,[1:4,end-3:end]) = [];
            tempo = [tempo ' pi'];
            txtSTR = [getWavMSG('Wavelet:cwtfttool2:Num_Angle',idxANG) ...
                ': ' tempo];
        case 'angles'
            idxSCA = get(handles.Pop_Cur_SCA,'Value');
            val_SEL = scales(idxSCA);
            tempo = num2str(val_SEL,'%3.3f');
            txtSTR = [getWavMSG('Wavelet:cwtfttool2:Num_Scale',idxSCA) ...
                        ': ' tempo];
    end
    uicontrol('Style','Text', ...
        'BackGroundColor',get(showFig,'Color'),'String',txtSTR, ...
        'Units','normalized','Position',[0.1 , 0.95 , 0.8 ,0.025], ...
        'FontSize',11 ...
        );
    for k = 1:NbSEL
        switch Sel_Type
            case 'scales'
                cfsSEL = cwtcfs(:,:,:,IdxSEL(k),idxANG);
                msgId = 'Num_Scale';
                val_SEL = scales(IdxSEL(k));
                tempo = num2str(val_SEL,'%3.3f');
                
            case 'angles'
                cfsSEL = cwtcfs(:,:,:,idxSCA,IdxSEL(k));
                msgId = 'Num_Angle';
                val_SEL = angles(IdxSEL(k))/pi;
                tempo = rats(val_SEL);
                tempo(:,[1:4,end-3:end]) = [];
                tempo = [tempo ' pi']; 
        end
        ax = subplot(NbSEL,nbCOL,idxPlot);
        axPLOT(idxPlot) = ax; idxPlot = idxPlot+1;
        displayImage(abs(cfsSEL),ax)
        set(ax,'Ydir','Reverse','Box','On');
        ylab = {getWavMSG(['Wavelet:cwtfttool2:' msgId],IdxSEL(k)),tempo};
        
        wylabel(ylab,'Rotation',0, ...
            'HorizontalAlignment','right','VerticalAlignment','middle', ...
            'Parent',ax);
        if k==NbSEL
            xlab = getWavMSG('Wavelet:cwtfttool:title_Modulus');
            wxlabel(xlab,'Parent',ax);
        end
                
        if ~realCFS 
            ax = subplot(NbSEL,nbCOL,idxPlot);
            axPLOT(idxPlot) = ax; idxPlot = idxPlot+1;
            displayImage(angle(cfsSEL),ax)            
            set(ax,'Ydir','Reverse','Box','On');
            if k==NbSEL
                xlab = getWavMSG('Wavelet:cwtfttool:title_Angle');
                wxlabel(xlab,'Parent',ax);
            end
        end
        
        ax = subplot(NbSEL,nbCOL,idxPlot);
        axPLOT(idxPlot) = ax; idxPlot = idxPlot+1;
        displayImage(real(cfsSEL),ax)            
        set(ax,'Ydir','Reverse','Box','On');
        if k==NbSEL
            xlab = getWavMSG('Wavelet:cwtfttool:title_RealPart');
            wxlabel(xlab,'Parent',ax);
        end
        
        if ~realCFS 
            ax = subplot(NbSEL,nbCOL,idxPlot);
            axPLOT(idxPlot) = ax; idxPlot = idxPlot+1;
            displayImage(imag(cfsSEL),ax)            
            set(ax,'Ydir','Reverse','Box','On');
            if k==NbSEL
                xlab = getWavMSG('Wavelet:cwtfttool:title_ImaginaryPart');
                wxlabel(xlab,'Parent',ax);
            end
        end
    end
    axPLOT = axPLOT(ishandle(axPLOT));
    wfigmngr('normalize',showFig);
    dynvtool('init',showFig,[],axPLOT,[],[1 1],'','','');
    
elseif isequal(showOPT,'movie')
    idxANG = get(handles.Pop_Cur_ANG,'Value');
    idxSCA = get(handles.Pop_Cur_SCA,'Value');
    switch Sel_Type
        case 'scales' , values = scales; count = get(handles.Lst_SEL_SC,'Value');
        case 'angles' , values = angles; count = get(handles.Lst_SEL_SC,'Value');
    end
    nbVAL = length(values);
    if length(count)>1 , count = count(1); end
    if isempty(count) || isequal(count,nbVAL) , count = 1; end
    while count<=nbVAL
        set(handles.Lst_SEL_SC,'Value',count);
        switch Sel_Type
            case 'scales'
                OneCFS = cwtcfs(:,:,:,count,idxANG);
                angSTR = getAngleSTR(angles(idxANG));
                BigTitleSTR = getWavMSG('Wavelet:cwtfttool2:BigTitleSTR_2D_BIS', ...
                    count,num2str(scales(count),'%3.3f'), ...
                    idxANG,angSTR);
                
            case 'angles'
                OneCFS = cwtcfs(:,:,:,idxSCA,count);
                angSTR = getAngleSTR(angles(count));
                BigTitleSTR = getWavMSG('Wavelet:cwtfttool2:BigTitleSTR_2D_BIS', ...
                    idxSCA,num2str(scales(idxSCA),'%3.3f'), ...
                    count,angSTR);
        end
        ax = handles.Axe_MOD;
        titleSTR = getWavMSG('Wavelet:cwtfttool:title_Modulus');
        displayImage(abs(OneCFS),ax)            
        set(ax,'Ydir','Reverse','Box','On');
        axis(ax,axAspect{:});
        wxlabel(titleSTR,'Parent',ax);
        Add_ColorBar(ax);
        
        ax = handles.Axe_REAL;
        titleSTR = getWavMSG('Wavelet:cwtfttool:title_RealPart');
        displayImage(real(OneCFS),ax)            
        set(ax,'Ydir','Reverse','Box','On');
        axis(ax,axAspect{:});
        wxlabel(titleSTR,'Parent',ax);
        Add_ColorBar(ax);
        
        if ~realCFS
            ax = handles.Axe_ANG;
            titleSTR = getWavMSG('Wavelet:cwtfttool:title_Angle');
            displayImage(angle(OneCFS),ax)            
            set(ax,'Ydir','Reverse','Box','On');
            axis(ax,axAspect{:});
            wxlabel(titleSTR,'Parent',ax);
            Add_ColorBar(ax);
            
            ax = handles.Axe_IMAG;
            titleSTR = getWavMSG('Wavelet:cwtfttool:title_ImaginaryPart');
            displayImage(imag(OneCFS),ax)            
            set(ax,'Ydir','Reverse','Box','On');
            axis(ax,axAspect{:});
            wxlabel(titleSTR,'Parent',ax);
            Add_ColorBar(ax);
        end
        bigTitle = wtbxappdata('get',fig,'Txt_BigTitle');
        set(bigTitle,'String',BigTitleSTR);
        pause(0.25)
        try
            out = get(handles.Pus_StopMOV,'UserData');
            if out 
                count = Inf;
            else
                count = count+1; 
            end
        catch
            err = true;
            break
        end
    end
end
if err ,  return; end

hdl_Menus = wtbxappdata('get',fig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_data = hdl_Menus.m_exp_data;
SavMenOnOff(fig,'0.1','On')
enaSCA = get(handles.Pus_SEL_Scales,'Userdata');
if isempty(enaSCA) , enaSCA = 'On'; end
enaANG = get(handles.Pus_SEL_Angles,'Userdata');
if isempty(enaANG) , enaANG = 'On'; end
Hdl_to_Enable = [...
    m_save;m_exp_data;handles.Pus_ShowCfs; ...
    handles.Txt_Cur_SCA;handles.Pop_Cur_SCA; ...
    handles.Txt_Cur_ANG;handles.Pop_Cur_ANG;handles.Pus_Apply];
set(Hdl_to_Enable,'Enable','On');
set(handles.Pus_SEL_Scales,'Enable',enaSCA);
set(handles.Pus_SEL_Angles,'Enable',enaANG);
axHdl = [...
    handles.Axe_SIG_L, ...
    handles.Axe_MOD,handles.Axe_REAL,handles.Axe_ANG,handles.Axe_IMAG];
dynvtool('init',fig,[],axHdl,[],[1 1],'','','');
set(handles.Axe_SIG_L,'Box','On');

wwaiting('off',fig);
%--------------------------------------------------------------------------
function Pus_MOVIE_Callback(hObject,eventdata,handles) 

fig = ancestor(hObject,'figure');
m_File = wfindobj(fig,'type','uimenu','tag','figMenuFile');
ToDiseable = [handles.Pus_SEL_ALL,handles.Pus_SEL_NON,...
    handles.Pus_ShowCfs,handles.Pus_SEL_CLOSE,handles.Pus_MOVIE,  ...
    handles.Pus_CloseWin,m_File];
set(ToDiseable,'Enable','Off')
set(handles.Pus_StopMOV,'Enable','on','UserData',0);
err = showScaleANAL(handles,[],'movie');
if err , return; end
set(handles.Pus_StopMOV,'Enable','off');
set(ToDiseable,'Enable','On')
%--------------------------------------------------------------------------
function Pus_StopMOV_Callback(hObject,eventdata,handles) 

set(handles.Pus_StopMOV,'UserData',1);
%--------------------------------------------------------------------------
function Pop_DEF_ANG_Callback(hObject,eventdata,handles) %#ok<*DEFNU>

val = get(hObject,'Value');
old = get(hObject,'Userdata');
set(hObject,'Userdata',val);
switch val
    case 1 , vis = 'off';
    case 2 , vis = 'off';
    case 3 , vis = 'on';
end
if ~isequal(old,val)
    newpos = false;
    p = get(hObject,'Position');
    if (old==2) && (val==3 || val==1)
        p(3) = p(3)/1.85; newpos = true;
    elseif val==2 && (old==3 || old==1)
        p(3) = 1.85*p(3); newpos = true;
    end
    if newpos , set(hObject,'Position',p); end
end
set(handles.Pus_DEF_ANG,'Visible',vis);
%--------------------------------------------------------------------------
function Pus_DEF_ANG_Callback(hObject,eventdata,handles) %#ok<*INUSD>

fig = gcbf;
Change_Enabled = wfindobj(fig,'Enable','on');
kept_Enabled = allchild(handles.Pan_SEL_MAN_ANG);
Change_Enabled = setdiff(Change_Enabled,kept_Enabled);
wtbxappdata('set',fig,'Pus_DEF_ANG_Ena',Change_Enabled);
set(Change_Enabled,'Enable','off');
set([handles.Pus_ANAL,handles.Pus_SEL_Scales,handles.Pan_Visu, ...
    handles.Pus_SEL_Angles,handles.Pan_SEL_SCA_ANG,],'Visible','off');
set(handles.Pan_SEL_MAN_ANG,'Visible','on');
%--------------------------------------------------------------------------
function Pus_INV_Callback(hObject,eventdata,handles)

fig = handles.output;

X = wtbxappdata('get',fig,'Sig_ANAL');
CWTStruct = wtbxappdata('get',fig,'CWTStruct');
scales = CWTStruct.scales;
% angles = CWTStruct.angles;
cwtcfs = CWTStruct.cfs;
NbSCA = length(scales);
cfsINV = 1;
mulWAV = 1;
meanSIG = mean(X(:));
IdxSc2Inv = get(handles.Lst_SEL_SC,'Value');
IdxZER = setdiff(1:NbSCA,IdxSc2Inv);
cwtcfs(:,:,:,IdxZER,1) = 0;
figure; colormap(pink(222));
step = 0.1; 
for pp = 2    
    cwtcfs_REC = cwtcfs;
    for k = 1:1:NbSCA
        cwtcfs_REC(:,:,:,k,1) = cwtcfs_REC(:,:,:,k,1)/(scales(k)^pp);
    end
    ds = scales(2)-scales(1);
    RR = real(cwtcfs_REC(:,:,:,:,:));
    RR = sum(RR,4); 
    Xrec = cfsINV*2*sum(RR,4)*ds/mulWAV;
    Xrec = Xrec-mean(Xrec(:))+meanSIG;
    Xrec = sum(Xrec,5);
    imagesc(Xrec);
    err = norm(abs(X(:)-Xrec(:)),2)/norm(X,2);
    xlabel(['Power = ' num2str(pp) ' - Err = ' num2str(err)])
    pause(0.1);
end
%-------------------------------------------------------
function Pop_Cur_SCA_Callback(hObject,eventdata,handles)
%-------------------------------------------------------
function Pop_Cur_ANG_Callback(hObject,eventdata,handles)
%-------------------------------------------------------
function Pus_Apply_Callback(hObject,eventdata,handles)

Idx_SCA = get(handles.Pop_Cur_SCA,'Value');
Idx_ANG = get(handles.Pop_Cur_ANG,'Value');
showScaleANAL(handles,[Idx_SCA,Idx_ANG],'select');
%-------------------------------------------------------
function Pus_ANG_Default_Callback(hObject,eventdata,handles)

pop  = handles.Pop_ANG_TYPE;
type = get(pop,'Value');
switch type
    case 1  % Linear
        set(handles.Pop_ANG_DELTA,'Value',7);  % pi/8
    case 2  % Manual
        set(handles.Edi_ANG_Manual,'String','[0:pi/4:7*pi/4]');
end
%-------------------------------------------------------
function Pus_ANG_Cancel_Callback(hObject,eventdata,handles)

fig = gcbf;
Change_Enabled = wtbxappdata('get',fig,'Pus_DEF_ANG_Ena');
set(handles.Pan_SEL_MAN_ANG,'Visible','off')
set([handles.Pus_ANAL,handles.Pus_SEL_Scales,handles.Pan_Visu, ...
    handles.Pus_SEL_Angles,handles.Pan_SEL_SCA_ANG], ...
    'Visible','on');
set(Change_Enabled,'Enable','on');
%-------------------------------------------------------
function Pop_ANG_TYPE_Callback(hObject,eventdata,handles)

HDL_1 = [handles.Pop_ANG_DELTA,handles.Txt_ANG_PI];
HDL_2 = [handles.Edi_ANG_Manual];
valType = get(hObject,'value');
switch valType
    case 1  % Fraction of PI
        set(HDL_2,'Visible','Off');
        set(HDL_1,'Visible','On');
    case 2  % Manual
        set(HDL_1,'Visible','Off');
        set(HDL_2,'Visible','On');
end
%-------------------------------------------------------
function Edi_ANG_Manual_Callback(hObject,eventdata,handles)
%-------------------------------------------------------
function Pop_ANG_DELTA_Callback(hObject,eventdata,handles)
%-------------------------------------------------------
function Pus_ANG_Apply_Callback(hObject,eventdata,handles)

fig = gcbf;
AP = wtbxappdata('get',fig,'Pow_Anal_Params');
valType = get(handles.Pop_ANG_TYPE,'value');
ANG = [];
switch valType
    case 1  % Type = Linear
        idx = get(handles.Pop_ANG_DELTA,'Value');
        lst = get(handles.Pop_ANG_DELTA,'String');
        val = eval(lst{idx});
        angles = 0:pi*val:(2*pi-0.1);
        
    case 2   % Type = Manual
        try
            angles = str2num(get(handles.Edi_ANG_Manual,'String')); %#ok<ST2NM>
            err = 0; 
        catch %#ok<CTCH> 
            err = 1; beep; return; 
        end
end
AP.ANG = ANG;
AP.angles = angles;
wtbxappdata('set',fig,'Pow_Anal_Params',AP)

Change_Enabled = wtbxappdata('get',fig,'Pus_DEF_ANG_Ena');
set(handles.Pan_SEL_MAN_ANG,'Visible','off')
set([handles.Pus_ANAL,handles.Pus_SEL_Scales,handles.Pan_Visu, ...
    handles.Pus_SEL_Angles,handles.Pan_SEL_SCA_ANG],'Visible','on');
set(Change_Enabled,'Enable','on');
%--------------------------------------------------------------------------
function Pus_More_Params_Callback(hObject,eventdata,handles)

wavInfo = get(handles.Pop_WAV_NAM,{'Value','String'});
wname = deblank(wavInfo{2}{wavInfo{1}});
WAV_Param_Table = wtbxappdata('get',hObject,'WAV_Param_Table');
idx_Wave = strcmp(wname,WAV_Param_Table(:,1));
Data_Table = WAV_Param_Table{idx_Wave,2};
tab = handles.Tab_Params;
set(tab,'Data',Data_Table);
hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_files = hdl_Menus.m_files;
Hdl_ENA_Off = [hObject,handles.Txt_WAV_NAM,handles.Pop_WAV_NAM,...
    handles.Txt_WAV_PAR,m_files,handles.Pus_CloseWin];
Hdl_VIS_Off = [...
    handles.Txt_DEF_SCA,handles.Pop_DEF_SCA,...    
    handles.Txt_DEF_ANG,handles.Pop_DEF_ANG, ...
    handles.Pus_ANAL,handles.Pan_Visu];
vis = get(handles.Pus_DEF_ANG,'Visible');
if strcmpi(vis,'On') , Hdl_VIS_Off = [Hdl_VIS_Off,handles.Pus_DEF_ANG]; end
vis = get(handles.Pus_DEF_SCA,'Visible');
if strcmpi(vis,'On') , Hdl_VIS_Off = [Hdl_VIS_Off,handles.Pus_DEF_SCA]; end
usr.ena = Hdl_ENA_Off;
usr.vis = Hdl_VIS_Off;
set(hObject,'UserData',usr)
set(Hdl_VIS_Off,'Visible','Off');
set(Hdl_ENA_Off,'Enable','Off');
set(handles.Pan_More_Params,'Visible','On');
%--------------------------------------------------------------------------
function Pus_Apply_OR_Cancel_Callback(hObject,eventdata,handles,ARG)

switch ARG
    case 0    % Cancel
    case 1    % Apply
        Data_Table = get(handles.Tab_Params,'Data');
        
        % Verification of new parameters
        %--------------------------------
        wavInfo = get(handles.Pop_WAV_NAM,{'Value','String'});
        wname = deblank(wavInfo{2}{wavInfo{1}});
        WAV.wname = wname;
        if ~isempty(Data_Table)
            WAV.param = Data_Table(:,2);
        else
            WAV.param = [];
        end
        OkWAV = waveft2(WAV,'Control_PARAM');
        if ~OkWAV
            errordlg(...
                getWavMSG('Wavelet:cwtfttool2:Invalid_Par_Val'), ...
                getWavMSG('Wavelet:cwtfttool2:Control_Par_Val'),'modal');
            return; 
        end
        WAV_Param_Table = wtbxappdata('get',hObject,'WAV_Param_Table');
        idx_Wave = strcmp(wname,WAV_Param_Table(:,1));
        WAV_Param_Table{idx_Wave,2} = Data_Table;
        wtbxappdata('set',hObject,'WAV_Param_Table',WAV_Param_Table);
        STR = [];
        nb_PAR = size(Data_Table,1);
        for j = 1:nb_PAR
            par = Data_Table{j,2};
            if ischar(par)
                STR = [STR, par]; %#ok<*AGROW>
            else
                STR = [STR , num2str(par,'%5.3f')];
            end
            if j<nb_PAR , STR = [STR,',']; end
        end
        STR = ['[' STR ']'];
        set(handles.Edi_WAV_PAR,'String',STR);
end
fig_EQ = wfindobj(0,'type','figure','Tag','Info_EQUA');
if ~isempty(fig_EQ) , close(fig_EQ); end
usr = get(handles.Pus_More_Params,'Userdata');
set(handles.Pan_More_Params,'Visible','Off');
set(usr.vis,'Visible','On');
set(usr.ena,'Enable','On');
%--------------------------------------------------------------------------
function Pus_EQUA_Callback(hObject,eventdata,handles)

idx_WAV = get(handles.Pop_WAV_NAM,'Value');
str_WAV = get(handles.Pop_WAV_NAM,'String');
wname = str_WAV(idx_WAV);
fig_EQ = cwtftinfo2(wname);
wtbxappdata('set',hObject,'fig_EQ',fig_EQ);
%--------------------------------------------------------------------------
function Pus_Default_Param_Callback(hObject, eventdata, handles)

Data_Table = get(handles.Tab_Params,'Data');
if ~isempty(Data_Table) , Data_Table(:,2) = Data_Table(:,3); end
set(handles.Tab_Params,'Data',Data_Table);
%--------------------------------------------------------------------------
% --- Executes when entered data in editable cell(s) in Tab_Params.
function Tab_Params_CellEditCallback(hObject,eventdata,handles)
% eventdata  structure with the following fields (see UITABLE)
%	Indices:      row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData:     string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. 
%            Empty if Data was not changed
%	Error: error string when failed to convert EditData to 
%          appropriate value for Data

idx_WAV = get(handles.Pop_WAV_NAM,'Value');
str_WAV = get(handles.Pop_WAV_NAM,'String');
wname = str_WAV{idx_WAV};
IdxData = eventdata.Indices;
IdxRow  = IdxData(1);
NewData = eventdata.NewData;
change  = 0;
try
    V = eval(eventdata.EditData);
    len = length(V);
    err = ~isequal(len,1);
    if ~err
        err = isnan(NewData) && isnan(V);
        if ~err , NewData = V; change  = 1; end
    end
catch
    err = 1;
end
if ~err
    switch wname
        case 'mexh' , if isequal(IdxRow,1) , err = ~(NewData>0); end
        case 'paul' , if isequal(IdxRow,1) , err = ~(NewData>0); end
        case {'cauchy','escauchy'}
            if isequal(IdxRow,2) || isequal(IdxRow,3) || isequal(IdxRow,4)
                err = ~(NewData>0);
            elseif isequal(IdxRow,1)
                err = ~(V>0 && V<pi/2);
            end
        case 'gaus'     , if isequal(IdxRow,1) , err = ~(NewData>0); end
        case 'wheel'    , if isequal(IdxRow,1) , err = ~(NewData>1); end
        case 'fan'      , if isequal(IdxRow,4) , err = ~(NewData>0); end
        case 'dogpow'   , if isequal(IdxRow,2) , err = ~(NewData>0); end
        case 'esmexh'   , if isequal(IdxRow,5) , err = ~(NewData>0); end
        case 'gaus2'    , if isequal(IdxRow,1) , err = ~(NewData>0); end
        case 'gaus3'    , if isequal(IdxRow,3) , err = ~(NewData>0); end
        case 'isodog'   , if isequal(IdxRow,1) , err = isequal(NewData,1); end
        case 'dog2'     , if isequal(IdxRow,1) , err = isequal(NewData,0); end
        case 'endstop2' , if isequal(IdxRow,2) , err = isequal(NewData,0); end
        case 'gabmexh'  , if isequal(IdxRow,2) , err = ~(NewData>0); end
        case 'sinc'     , if isequal(IdxRow,5) , err = ~(NewData>0); end
    end
end
if err
    D = get(hObject,'Data');
    D{IdxData(1),IdxData(2)} = eventdata.PreviousData;
    set(hObject,'Data',D);
    beep;
elseif change
    D = get(hObject,'Data');
    D{IdxData(1),IdxData(2)} = V;
    set(hObject,'Data',D);
end
%--------------------------------------------------------------------------
function built_WAV_Param_Table(fig)

WAV_Param_Table = {...
    'morl'      , {'Omega0',6,6;'Sigma',1,1;'Epsilon',1,1};
    'mexh'      , {'p',2,2;'sigmax',1,1;'sigmay',1,1};
    'paul'      , {'p',4,4};
    'dog'       , {'alpha',1.25,1.25};
    'cauchy'    , {'alpha','pi/6','pi/6';'L',4,4;'M',4,4;'sigma',1,1};
    'escauchy'  , {'alpha','pi/6','pi/6';'L',4,4;'M',4,4;'sigma',1,1};
    'gaus'      , {'p',1,1;'sigmax',1,1;'sigmay',1,1};
    'wheel'     , {'sigma',2,2};
    'fan'       , {'Omega0',5.336,5.336;'Sigma',1,1;'Epsilon',1,1;'J',6.5,6.5};        
    'pethat'    , {};
    'dogpow'    , {'alpha',1.25,1.25;'p',2,2};
    'esmorl'    , {'Omega0',6,6;'Sigma',1,1;'Epsilon',1,1};
    'esmexh'    , {'sigma',1,1;'Epsilon',0.5,0.5};
    'gaus2'     , {'p',1,1;'sigmax',1,1;'sigmay',1,1};
    'gaus3'     , {'A',1,1;'B',1,1;'p',1,1;'sigmax',1,1;'sigmay',1,1};
    'isodog'    , {'alpha',1.25,1.25};  
    'dog2'      , {'alpha',1.25,1.25};
    'isomorl'   , {'Omega0',6,6;'Sigma',1,1};
    'rmorl'     , {'Omega0',6,6;'Sigma',1,1;'Epsilon',1,1};
    'endstop1'  , {'Omega0',6,6};
    'endstop2'  , {'Omega0',6,6;'Sigma',1,1};
    'gabmexh'   , {'Omega0',5.336,5.336;'Epsilon',1,1};
    'sinc'      , {'Ax',1,1;'Ay',1,1;'p',1,1;'Omega0X',0,0;'Omega0Y',0,0};
    };
wtbxappdata('set',fig,'WAV_Param_Table',WAV_Param_Table);
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function displayImage(Y,ax)

Y = Y-min(Y(:));
Y = Y/max(abs(Y(:)));
imagesc(Y,'Parent',ax);
set(findall(ax),'Visible','on');
%--------------------------------------------------------------------------
function angSTR = getAngleSTR(val)

Deg = (180*val/pi);
tempo = rats(val/pi);
tempo(tempo==' ') = [];
angSTR = [' ' tempo ' pi [rad] = ' num2str(Deg,'%3.2f') ' [dgr]'];
%--------------------------------------------------------------------------
