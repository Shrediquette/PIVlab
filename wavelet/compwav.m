function varargout = compwav(varargin)
%COMPWAV Pattern detection tool using an adapted wavelet versus a well known one.
%   VARARGOUT = COMPWAV(VARARGIN)

% COMPWAV MATLAB file for compwav.fig
%      COMPWAV, by itself, creates a new COMPWAV or raises the existing
%      singleton*.
%
%      H = COMPWAV returns the handle to a new COMPWAV or the handle to
%      the existing singleton*.
%
%      COMPWAV('Property','Value',...) creates a new COMPWAV using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to compwav_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      COMPWAV('CALLBACK') and COMPWAV('CALLBACK',hObject,...) call the
%      local function named CALLBACK in COMPWAV.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 13-Apr-2006 18:16:42
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 19-Dec-2011.
%   Copyright 1995-2020 The MathWorks, Inc.


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @compwav_OpeningFcn, ...
                   'gui_OutputFcn',  @compwav_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State,varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before compwav is made visible.                      %
%*************************************************************************%
function compwav_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for compwav
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code  %
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
function varargout = compwav_OutputFcn(hObject,eventdata,handles) %#ok<*INUSL>
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
function Rad_TwoPatterns_Callback(hObject,eventdata,handles) %#ok<DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Test_Sig,'Value',0);
set([handles.Pop_Test_Sig],'Enable','off')
%--------------------------------------------------------------------------
function Rad_Trans_Callback(hObject,eventdata,handles) %#ok<DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Super,'Value',0);
%--------------------------------------------------------------------------
function Rad_Super_Callback(hObject,eventdata,handles) %#ok<DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Trans,'Value',0);
%--------------------------------------------------------------------------
function Rad_Test_Sig_Callback(hObject,eventdata,handles) %#ok<DEFNU>

set(hObject,'Value',1);
set(handles.Rad_TwoPatterns,'Value',0);
set([handles.Rad_Test_Sig,handles.Pop_Test_Sig],'Enable','on')
%--------------------------------------------------------------------------
function Rad_Contours_Callback(hObject,eventdata,handles) %#ok<DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Images,'Value',0);
%--------------------------------------------------------------------------
function Sli_Thresh_Callback(hObject,eventdata,handles) %#ok<DEFNU>

Tresh = get(hObject,'Value');
set(handles.Edi_Thresh,'String',num2str(Tresh,'%1.3f'));
%--------------------------------------------------------------------------
function Edi_Thresh_Callback(hObject,eventdata,handles) %#ok<DEFNU>

FieldDefault = '0.7';
Val_Thresh = str2double(get(hObject,'String'));
if Val_Thresh < 0.1 || Val_Thresh > 0.9 || isnan(Val_Thresh)
    set(hObject,'String',FieldDefault);
    set(handles.Sli_Thresh,'Value',str2double(FieldDefault));
else
    set(handles.Sli_Thresh,'Value',Val_Thresh);
    set(hObject,'String',num2str(Val_Thresh,'%1.3f'));
end
%--------------------------------------------------------------------------
function Rad_Images_Callback(hObject,eventdata,handles) %#ok<DEFNU>

set(hObject,'Value',1);
set(handles.Rad_Contours,'Value',0);
%--------------------------------------------------------------------------
function Pus_Run_Callback(hObject,eventdata,handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
cleanTOOL([                                 ...
            handles.Axe_RunSigAdapWave ,    ...
            handles.Axe_RunSigWave ,        ...
            handles.Axe_AdapWaveDetect ,    ...
            handles.Axe_WaveDetect          ...
            ]);

% Get parameter values.
%----------------------
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');
Y           = tool_PARAMS.Y;
PSI         = tool_PARAMS.PSI;

% Get uicontrol values.
%----------------------
RadTrans    = get(handles.Rad_Trans,'Value');
ChkNoise    = get(handles.Chk_Noise,'Value');
ChkTriangle = get(handles.Chk_Triangle,'Value');
RadContours = get(handles.Rad_Contours,'Value');
RadImages   = get(handles.Rad_Images,'Value');
Str_Thresh  = get(handles.Edi_Thresh,'String');
Thresh      = str2double(Str_Thresh);

% Running signal construction.
%-----------------------------
titleSTR{1} = getWavMSG('Wavelet:divGUIRF:Running_Signal');

radSIG = handles.Rad_Test_Sig;
radVAL = get(radSIG,'Value');
if radVAL==1
    popSIG = handles.Pop_Test_Sig;
    popVAL = get(popSIG,'Value');
    popSTR = get(popSIG,'String');
    sigNAM = deblank(popSTR(popVAL,:));
    switch sigNAM{1}
        case 'testsig0' , load pthaar
        case 'testsig1' , load ptpssin1
        case 'testsig2' , load ptpssin2
        case 'testsig3' , load ptsine
        case 'testsig4' , load ptsumsin
        case 'testsig5' , load ptsinpol
        case 'testsig6' , load ptodtri
        case 'testsig7' , load ptodlin
        case 'testsig8' , load ptodpoly
    end
end
if RadTrans
    nbFormeBASE = 8; scaleBASE = 8; rapport = 2; PONDERATIONS =  [1,1];
    signalBASE = getSignal('translate',Y,rapport,PONDERATIONS,nbFormeBASE);
    lenSIG  = length(signalBASE);
    scaleMIN = 1;
    scaleMAX = 2*scaleBASE;
    NoiseLevel = 1.25;
    titleSTR{2} = 'F((t-20)/8) + sqrt(2)\timesF((t-40)/4)';
else
    nbFormeBASE = 3; scaleBASE = 32; rapport = 4; PONDERATIONS =  [1,1];
    signalBASE = getSignal('superpose',Y,rapport,PONDERATIONS,nbFormeBASE);
    lenSIG  = length(signalBASE);
    scaleMIN = 1;
    scaleMAX = 2*scaleBASE;
    NoiseLevel = 0.75;   
    titleSTR{2} = 'F((t-40)/32) + 2\timesF((t-40)/8)';
end
if radVAL==1, titleSTR{2} = sigNAM{1}; end
signal = signalBASE;

if ChkNoise
    NoiseLevel = NoiseLevel*std(signal);
    Noise = NoiseLevel*randn(1,lenSIG);
    signal = signal + Noise;
    titleSTR{2} = [titleSTR{2} ' + N'];
end

if ChkTriangle
    L = lenSIG/2;
    Triangle = [1:floor(L) , ceil(L):-1:1]/ceil(L);
    signal = signal + Triangle;
    titleSTR{2} = [titleSTR{2} ' + T'];
end
intervalleSIG = [0,nbFormeBASE*scaleBASE];
stepSIG = (intervalleSIG(2)-intervalleSIG(1))/(lenSIG-1);
xvalSIG = linspace(intervalleSIG(1),intervalleSIG(2),lenSIG);
stepScales = 1;
scales  = (scaleMIN:stepScales:scaleMAX);
    
% Running signal (adapted wavelet column) axes display.
%------------------------------------------------------
lw = 1;
axeCur = handles.Axe_RunSigAdapWave;
lin_SIG = line(xvalSIG,signal,'Color','b','LineWidth',lw,...
    'Visible','Off','Parent',axeCur);
Xlim = intervalleSIG;
ext = abs(max(signal) - min(signal)) / 100;
Ylim = [min(signal)-ext max(signal)+ext];
set(axeCur,'XLim',Xlim,'YLim',Ylim);
if radVAL
    [Tit1, Tit2] = deal(titleSTR{:});
    titleSTR = [Tit1 ': ' Tit2];
end

% Set the hdl visible.
%---------------------
set(findall(axeCur),'Visible','on');
wguiutils('setAxesTitle',axeCur,titleSTR);

% Running signal (wavelet column) axes display.
%----------------------------------------------
lw = 1;
axeCur = handles.Axe_RunSigWave;
lin_WAV = line(xvalSIG,signal,'Color','b','LineWidth',lw,...
    'Visible','Off','Parent',axeCur);
Xlim = intervalleSIG;
ext = abs(max(signal) - min(signal)) / 100;
Ylim = [min(signal)-ext max(signal)+ext];
set(axeCur,'XLim',Xlim,'YLim',Ylim);

% Set the axes visible.
%----------------------
set(findall(axeCur),'Visible','on');
wguiutils('setAxesTitle',axeCur,titleSTR);


% Get the wavelet used.
%----------------------
Wav = cbanapar('get',hFig,'wav');                           

% Compute the cwt.
%-----------------
C_psi = cwt({signal,stepSIG},scales,PSI);
C_wav = cwt({signal,stepSIG},scales,Wav);

% Find the coordinates of max coefs.
%-----------------------------------
% [ROW_psi,COL_psi] = maxCoefs(C_psi);
% [ROW_wav,COL_wav] = maxCoefs(C_wav);

% Coefficients representation.
%-----------------------------
if RadContours
    plotCONTOUR(C_psi,scales,xvalSIG,...
        handles.Axe_AdapWaveDetect,handles.Axe_ColBar,'psi',Thresh);
    LocalGrid(handles.Axe_AdapWaveDetect,RadTrans);
    plotCONTOUR(C_wav,scales,xvalSIG,...
        handles.Axe_WaveDetect,handles.Axe_ColBar,Wav,Thresh);
    LocalGrid(handles.Axe_WaveDetect,RadTrans);
    set([handles.Fra_ColPar,handles.Txt_PAL,handles.Txt_NBC, ...
         handles.Txt_BRI,handles.Pop_PAL,handles.Sli_NBC, ...
         handles.Edi_NBC,handles.Pus_BRI_M,handles.Pus_BRI_P],'Enable', 'Off');
elseif RadImages   
    plotCOEFS(C_psi,scales,handles,...
        handles.Axe_AdapWaveDetect,handles.Axe_ColBar,'psi');
    plotCOEFS(C_wav,scales,handles,...
        handles.Axe_WaveDetect,handles.Axe_ColBar,Wav);
    set([handles.Fra_ColPar,handles.Txt_PAL,handles.Txt_NBC, ...
         handles.Txt_BRI,handles.Pop_PAL,handles.Sli_NBC, ...
         handles.Edi_NBC,handles.Pus_BRI_M,handles.Pus_BRI_P],'Enable', 'On');
end

% Set the axes visible.
%----------------------
set(handles.Axe_AdapWaveDetect,'Visible','on');
set(handles.Axe_WaveDetect,'Visible','on');

% Init DynVTool.
%---------------
axe_IND = [];
axe_CMD = [...
        handles.Axe_RunSigAdapWave , ...
        handles.Axe_RunSigWave , ...
        handles.Axe_AdapWaveDetect , ...
        handles.Axe_WaveDetect ...
        ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

% Get nwavetool figure parameters.
%---------------------------------
tool_PARAMS = wtbxappdata('get',hObject,'tool_PARAMS');

% Enable the compare button on in nwavetool figure.
%--------------------------------------------------
set(tool_PARAMS.Pus_Compare,'Enable','On');

% Close current figure.
%----------------------
close(gcbf)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Special Callback Functions                         %
%                --------------------------------                         %
%=========================================================================%
% --- Executes on button press in Compare from nwavtool figure.
function NwavtoolCall_Callback(hObject,eventdata,handles,Nwavetool_PARAMS) %#ok<DEFNU>

% Save nwavtool information in 'UserData' field of compwav figure.
%-----------------------------------------------------------------
if isfield(Nwavetool_PARAMS,'demoMODE')
    F1 = allchild(0);
end
compwav('UserData',Nwavetool_PARAMS);
if isfield(Nwavetool_PARAMS,'demoMODE')
    F2 = allchild(0);
    hFig = setdiff(F2,F1);
    set(hFig,'HandleVisibility','On')
end
%=========================================================================%
%                END Special Callback Functions                           %
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

% WTBX -- Install ANAPAR FRAME.
%------------------------------
wnameDEF  = 'db1';
utanapar('Install_V3_CB',hObject,'wtype','cwt');
cbanapar('set',hObject,'wav',wnameDEF);

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'Enable','On');
default_nbcolors = 240;
cbcolmap('set',hObject,'pal',{'jet',default_nbcolors});

% Get nwavetool figure parameters.
%---------------------------------
Nwavetool_PARAMS = get(hObject,'UserData');

% Initialize uicontrols.
%-----------------------
set(handles.Rad_Trans,'Value',Nwavetool_PARAMS.RadTrans);
set(handles.Rad_Super,'Value',Nwavetool_PARAMS.RadSuper);
set(handles.Chk_Noise,'Value',Nwavetool_PARAMS.ChkNoise);
set(handles.Chk_Triangle,'Value',Nwavetool_PARAMS.ChkTriangle);
set(Nwavetool_PARAMS.Pus_Compare,'Enable','Off');

% Set current tool figure parameters.
%------------------------------------
tool_PARAMS.X       = Nwavetool_PARAMS.X;
tool_PARAMS.Y       = Nwavetool_PARAMS.Y;
tool_PARAMS.PSI     = Nwavetool_PARAMS.PSI;
tool_PARAMS.NC_PSI  = Nwavetool_PARAMS.NC_PSI;
tool_PARAMS.Pus_Compare = Nwavetool_PARAMS.Pus_Compare;
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);

% Initialize colorbar.
%---------------------
cmap = get(hObject,'Colormap');
axeCur = handles.Axe_ColBar;
image((1:size(cmap,1)),'Parent',axeCur)
set(axeCur,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
dynvzaxe('exclude',hObject,axeCur)
ColorBarVisibility(axeCur,'Off');

% Set Title in the RunSigAdapWave axes.
%--------------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Running_Signal');
wguiutils('setAxesTitle',handles.Axe_RunSigAdapWave,titleSTR);

% Set Title in the RunSigWave axes.
%----------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Running_Signal');
wguiutils('setAxesTitle',handles.Axe_RunSigWave,titleSTR);

% Set Title in the AdapWaveDetect signal axes.
%---------------------------------------------
titleSTR = getWavMSG('Wavelet:divGUIRF:Str_AdapWav');
wguiutils('setAxesTitle',handles.Axe_AdapWaveDetect,titleSTR);

% Set Title in the pattern detection axes.
%-----------------------------------------
titleSTR = getWavMSG('Wavelet:commongui:Str_Wavelet');
wguiutils('setAxesTitle',handles.Axe_WaveDetect,titleSTR);
ColorBarVisibility(handles.Axe_ColBar,'On');

% End Of initialization.
%-----------------------
Pus_Run_Callback(hObject,eventdata,handles)

%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function cleanTOOL(handles)

hLINES  = findobj(handles,'Type','line');
delete(hLINES);
hLINES  = findobj(handles,'Type','patch');
delete(hLINES);
hIMAGES = findobj(handles,'Type','Image');
delete(hIMAGES);
%--------------------------------------------------------------------------
function ColorBarVisibility(Axe_ColBar,status)

hIMAGES = findobj(Axe_ColBar,'Type','image');
set(Axe_ColBar,'Visible',status);
set(hIMAGES,'Visible',status);
%--------------------------------------------------------------------------
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
%-------------------------------------------------------------------------
function signalBASE = ...
    getSignal(typeSIG,FormeBASE,rapport,PONDERATIONS,nbFormeBASE)

Forme_1 = FormeBASE;
len_F1  = length(Forme_1);
x_new   = linspace(0,1,len_F1/rapport);
x_old   = linspace(0,1,len_F1);        
Forme_2 = (rapport^0.5)*interp1(x_old,Forme_1,x_new);
len_F2  = length(Forme_2);
Forme_1 = PONDERATIONS(1)*Forme_1;
Forme_2 = PONDERATIONS(2)*Forme_2;
signalBASE = zeros(1,nbFormeBASE*len_F1);
switch typeSIG
	case 'superpose'
        deb = floor(((nbFormeBASE-1)/2-1/4)*len_F1) + 1; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = deb + floor((len_F1-len_F2)/2); fin = deb + len_F2-1;
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;

	case 'translate'
        deb = 2*len_F1; fin = deb + len_F1-1;
        signalBASE(deb:fin) = Forme_1;
        deb = floor(5*len_F1-len_F2/2); fin = deb + len_F2-1;        
        signalBASE(deb:fin) = signalBASE(deb:fin) + Forme_2;
end
%-------------------------------------------------------------------------
function plotCONTOUR(C,scales,xvalSIG,Axe,Axe_ColBar,Wav,Thresh)

% Compute and plot contours.
%---------------------------
maxi = max(max(abs(C))); 
D = abs(C)/maxi;
xval = (Thresh:0.025:1);
contour(xvalSIG,scales,D,xval,'Parent',Axe);

% Set Title in the pattern detection axes.
%-----------------------------------------
if isequal(Wav,'psi')
    titleSTR = getWavMSG('Wavelet:divGUIRF:Str_AdapWav');
else
    titleSTR = getWavMSG('Wavelet:divGUIRF:Nam_Wavelet',Wav);
end
wguiutils('setAxesTitle',Axe,titleSTR);
setAxesATTRB(scales,Axe);

% Set Xtick Values.
%------------------
NBC = 64;
xV = [xval(1),xval(end)]; 
setXTicks(Axe_ColBar,'real',NBC,xV);
%-------------------------------------------------------------------------
function plotCOEFS(C,scales,handles,Axe,Axe_ColBar,Wav)

NBC = 240;
abs_mode = 1;
C = wcodemat(C,NBC,'mat',abs_mode);
cbcolmap('set',handles.output,'pal',{'jet',NBC});
xL = get(handles.Axe_RunSigWave,'XLim');
yL = [scales(1) scales(end)];
image(xL,yL,C,'Parent',Axe);

% Set Title in the pattern detection axes.
%-----------------------------------------
if isequal(Wav,'psi')
    titleSTR = getWavMSG('Wavelet:divGUIRF:Str_AdapWav');
else
    titleSTR = getWavMSG('Wavelet:divGUIRF:Nam_Wavelet',Wav);
end
wguiutils('setAxesTitle',Axe,titleSTR);
setAxesATTRB(scales,Axe);
setXTicks(Axe_ColBar,'real',NBC,[0 1],5);
%-------------------------------------------------------------------------
function plotSURF(C,scales,xvalSIG,Axe,Axe_ColBar,Wav) %#ok<DEFNU>

NBC = 240;
set(get(Axe,'Parent'),'Colormap',jet(NBC));
maxi = max(max(abs(C)));
D = abs(C)/maxi;
surf(xvalSIG,scales,D,'Parent',Axe); 
shading interp
set(Axe,'View',[-18 72],'XLim',[xvalSIG(1),xvalSIG(end)],'YLim',[1,size(C,1)]);

% Set Title in the pattern detection axes.
%-----------------------------------------
if isequal(Wav,'psi')
    titleSTR = getWavMSG('Wavelet:divGUIRF:Str_AdapWav');
else
    titleSTR = getWavMSG('Wavelet:divGUIRF:Nam_Wavelet',Wav);
end
wguiutils('setAxesTitle',Axe,titleSTR);
setAxesATTRB(scales,Axe);
setXTicks(Axe_ColBar,'int',NBC,[0 NBC]);
%-------------------------------------------------------------------------
function setXTicks(Axe_ColBar,type,NBC,xV,nbTICS)

image((1:NBC),'Parent',Axe_ColBar);
set(get(Axe_ColBar,'Parent'),'Colormap',jet(NBC));
if nargin<5 , nbTICS = 7; end
xlim = get(Axe_ColBar,'XLim');
alfa = (xlim(2)-xlim(1))/(xV(2)-xV(1));
beta = xlim(1)-alfa*xV(1);
xCOL  = linspace(xV(1),xV(2),nbTICS);
xtics = alfa*xCOL + beta;
switch type
    case 'int'  , xlabs = int2str(xCOL(:));
    case 'real' , xlabs = num2str(xCOL(:),2);
end
set(Axe_ColBar, ...
        'XTick',xtics,'XTickLabel',xlabs, ...
        'YTick',[],'YTickLabel',[] ...
        );
%-------------------------------------------------------------------------
function setAxesATTRB(scales,axe)

nb_SCALES = length(scales);
nb    = ceil(nb_SCALES/20);
ytics = nb:nb:nb_SCALES;
tmp   = scales(nb:nb:nb*length(ytics));
ylabs = num2str(tmp(:));
set(axe, ...
        'YTick',ytics,          ...
        'YTickLabel',ylabs,     ...
        'YDir','normal',        ...
        'Box','On'              ...
        );
%-------------------------------------------------------------------------
function [ROW,COL] = maxCoefs(C) %#ok<DEFNU>

nb_ROW = size(C,1);
D = abs(C(:));
[~,idx] = max(D);

col_INF = fix(idx/nb_ROW);
ROW = idx - nb_ROW*col_INF;
if ROW~=0
    COL = col_INF+1;
else
    COL = col_INF; ROW = nb_ROW;
end
%-------------------------------------------------------------------------
function LocalGrid(Axe_Detect,RadTrans)

if RadTrans
    line([20 20],[0 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 20],[8 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([40 40],[0 4],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 40],[4 4],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line(20,8,'Color','k','Marker','*','Parent',Axe_Detect);
    line(40,4,'Color','k','Marker','*','Parent',Axe_Detect);
else
    line([40 40],[0 32],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 40],[32 32],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([40 40],[0 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line([0 40],[8 8],'Color','k','LineStyle','--','Parent',Axe_Detect);
    line(40,32,'Color','k','Marker','*','Parent',Axe_Detect);
    line(40,8,'Color','k','Marker','*','Parent',Axe_Detect);
end
%-------------------------------------------------------------------------
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%



%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles,varargin) %#ok<INUSD,DEFNU>

close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin) %#ok<DEFNU>

waveDEM = varargin{1};
handles = guidata(hFig);
cbanapar('set',hFig,'wav',waveDEM);
Pus_Run = handles.Pus_Run; 
Pus_Run_Callback(Pus_Run,[],handles);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
