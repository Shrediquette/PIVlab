function varargout = wfbmstat(varargin)
%WFBMSTAT Fractional Brownian motion statistics tool.
%   VARARGOUT = WFBMSTAT(VARARGIN)

% WFBMSTAT MATLAB file for wfbmstat.fig
%      WFBMSTAT, by itself, creates a new WFBMSTAT or raises the existing
%      singleton*.
%
%      H = WFBMSTAT returns the handle to a new WFBMSTAT or the handle to
%      the existing singleton*.
%
%      WFBMSTAT('Property','Value',...) creates a new WFBMSTAT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wfbmstat_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WFBMSTAT('CALLBACK') and WFBMSTAT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WFBMSTAT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 28-Aug-2007 18:28:43
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Mar-2003.
%   Last Revision: 03-Aug-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2013/08/23 23:45:18 $ 

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @wfbmstat_OpeningFcn, ...
    'gui_OutputFcn',  @wfbmstat_OutputFcn, ...
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
% --- Executes just before wfbmstat is made visible.                      %
%*************************************************************************%
function wfbmstat_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for wfbmstat
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wfbmstat wait for user response (see UIRESUME)
% uiwait(handles.wfbmStat_Win);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code %
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
function varargout = wfbmstat_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
function Edi_NbBins_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

FieldDefault ='50';
NbBins = str2double(get(hObject,'String'));
if ~isequal(NbBins,fix(NbBins)) || NbBins <= 0 || isnan(NbBins)
    set(hObject,'String',FieldDefault);
end
%--------------------------------------------------------------------------
function Chk_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pus_Statistics_Callback(handles.Pus_Statistics,eventdata,handles)
%--------------------------------------------------------------------------
function Pus_Statistics_Callback(hObject,eventdata,handles) %#ok<INUSL,INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
cleanTOOL(handles);

% Computing.
%-----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Parameters initialization.
%---------------------------
curr_color = wtbutils('colors','res');

% Get FBM_PARAMS parameters.
%---------------------------
FBM_PARAMS = get(hFig,'UserData');

% Get uicontrol values.
%----------------------
DiffOrder_Str   = get(handles.Pop_DiffOrder,'String');  % Diff. order (string)
DiffOrder_Ind   = get(handles.Pop_DiffOrder,'Value');   % Diff. order (Index)
DiffOrder_Str   = DiffOrder_Str{DiffOrder_Ind,:};       % Diff. order (string)
DiffOrder_Num   = str2double(DiffOrder_Str);            % Diff. order (numeric)
NumBins_Str     = get(handles.Edi_NbBins,'String');     % Bins (string)
NumBins_Num     = str2double(NumBins_Str);              % Bins (numeric)

% Compute values to display.
%---------------------------
if DiffOrder_Num==0
    FBMxDif = FBM_PARAMS.FBM;
else
    FBMxDif = diff(FBM_PARAMS.FBM,DiffOrder_Num);
end
his      = wgethist(FBMxDif(:),NumBins_Num);
[~,imod] = max(his(2,:));
mode_val = (his(1,imod)+his(1,imod+1))/2;

% Get check status.
%------------------
Chk_Hist  = get(handles.Chk_Hist,'Value');
Chk_Auto  = get(handles.Chk_Auto,'Value');
Chk_Stats = get(handles.Chk_Stats,'Value');


axe_In_Tool = [...
    handles.Axe_xDif,       ...
    handles.Axe_xDif0,      ...
    handles.Axe_xDif1,      ...
    handles.Axe_xDif2,      ...
    handles.Axe_xDif3,      ...
    handles.Axe_xDif4,      ...
	handles.Axe_Hist,       ...
	handles.Axe_CumHist,    ...
	handles.Axe_Hist1,      ...
	handles.Axe_CumHist1,   ...
	handles.Axe_Hist4,      ...
	handles.Axe_CumHist4,   ...
	handles.Axe_Hist2,      ...
	handles.Axe_CumHist2,   ...
    handles.Axe_AutoCorr,   ...
    handles.Axe_AutoCorr1,  ...
    handles.Axe_AutoCorr2,  ...
    handles.Axe_AutoCorr4,  ...
    handles.Axe_FFT,        ...
    handles.Axe_FFT1,       ...
    handles.Axe_FFT2,       ...
    handles.Axe_FFT4        ...
    ];
children = wfindobj(axe_In_Tool,'type','axes','-xor');
delete(children);

% Displaying axes depending on check status.
%-------------------------------------------
if Chk_Hist && Chk_Auto && Chk_Stats
    axe_xdif    = handles.Axe_xDif;
	axe_hist    = handles.Axe_Hist;
	axe_cumhist = handles.Axe_CumHist;
	axe_corr    = handles.Axe_AutoCorr;
	axe_spec    = handles.Axe_FFT;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
    DispStats(FBMxDif,handles,mode_val);
elseif ~Chk_Hist && ~Chk_Auto && ~Chk_Stats
    axe_xdif  = handles.Axe_xDif0;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
elseif Chk_Hist && ~Chk_Auto && Chk_Stats
    axe_xdif    = handles.Axe_xDif1;
	axe_hist    = handles.Axe_Hist1;
	axe_cumhist = handles.Axe_CumHist1;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
    DispStats(FBMxDif,handles,mode_val);
elseif ~Chk_Hist && Chk_Auto && Chk_Stats
    axe_xdif  = handles.Axe_xDif1;
	axe_corr  = handles.Axe_AutoCorr1;
	axe_spec  = handles.Axe_FFT1;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
    DispStats(FBMxDif,handles,mode_val);
elseif Chk_Hist && ~Chk_Auto && ~Chk_Stats
    axe_xdif    = handles.Axe_xDif2;
	axe_hist    = handles.Axe_Hist2;
	axe_cumhist = handles.Axe_CumHist2;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
elseif ~Chk_Hist && Chk_Auto && ~Chk_Stats
    axe_xdif  = handles.Axe_xDif2;
	axe_corr  = handles.Axe_AutoCorr2;
	axe_spec  = handles.Axe_FFT2;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
elseif ~Chk_Hist && ~Chk_Auto && Chk_Stats
    axe_xdif    = handles.Axe_xDif3;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispStats(FBMxDif,handles,mode_val);
elseif Chk_Hist && Chk_Auto && ~Chk_Stats
    axe_xdif    = handles.Axe_xDif4;
	axe_hist    = handles.Axe_Hist4;
	axe_cumhist = handles.Axe_CumHist4;
	axe_corr    = handles.Axe_AutoCorr4;
	axe_spec    = handles.Axe_FFT4;
    DispxDif(FBMxDif,axe_xdif,DiffOrder_Str,curr_color,FBM_PARAMS);
    DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color);
    DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color);
end

% Init DynVTool.
%---------------
axe_IND = [...
    handles.Axe_xDif,       ...
    handles.Axe_xDif0,      ...
    handles.Axe_xDif1,      ...
    handles.Axe_xDif2,      ...
    handles.Axe_xDif3,      ...
    handles.Axe_xDif4,      ...
    handles.Axe_AutoCorr,   ...
    handles.Axe_AutoCorr1,  ...
    handles.Axe_AutoCorr2,  ...
    handles.Axe_AutoCorr4,  ...
    handles.Axe_FFT,        ...
    handles.Axe_FFT1,       ...
    handles.Axe_FFT2,       ...
    handles.Axe_FFT4        ...
    ];
axe_CMD = axe_IND;
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 0],'','','');

% End waiting.
%-------------
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

close(gcbf)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Special Callback Functions                         %
%                --------------------------------                         %
%=========================================================================%

% --- Executes on button press in Statistics from wfbmtool figure.
function WfbmtoolCall_Callback(hObject,eventdata,handles,FBM_PARAMS) %#ok<INUSL,DEFNU>

% Save wfbmtool handles in 'UserData' field of wfbmstat figure.
%--------------------------------------------------------------
if isfield(FBM_PARAMS,'demoMODE')
    F1 = allchild(0);
end

wfbmstat('UserData',FBM_PARAMS);

if isfield(FBM_PARAMS,'demoMODE')
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

% WTBX MENUS (Install)
%---------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% Set Title in the 1Dif axes (first time).
%-----------------------------------------
title = getWavMSG('Wavelet:divGUIRF:FBM_IncOrd_N',1);
wguiutils('setAxesTitle',handles.Axe_xDif,title,'On');

% Save Tool Parameters.
%----------------------
uicFontSize = get(handles.Txt_Mean,'FontSize');
minFontSize = wtbutils('utSTATS_PREFS');
uicFontSize = min([uicFontSize,minFontSize]);
hSTATS  =   [                                                           ...
    handles.Txt_Mean,handles.Txt_Max,handles.Txt_Min,handles.Txt_Range, ...
    handles.Txt_StdDev,handles.Txt_Median,handles.Txt_MedAbsDev,        ...
    handles.Txt_MeanAbsDev,handles.Txt_Mode,                            ...
    handles.Txt_L1,handles.Txt_L2,handles.Txt_LM,                       ...
    handles.Edi_Mean,handles.Edi_Max,handles.Edi_Min,handles.Edi_Range, ...
    handles.Edi_StdDev,handles.Edi_Median,handles.Edi_MedAbsDev,        ...
    handles.Edi_MeanAbsDev,handles.Edi_Mode,                            ...
    handles.Edi_L1,handles.Edi_L2,handles.Edi_LM,                       ...    
    ];
set(hSTATS,'FontSize',uicFontSize);

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);

% End Of initialization.
%-----------------------
wfbmstat('Pus_Statistics_Callback',hObject,eventdata,handles);
set(hObject,'Visible','On');
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%

function cleanTOOL(handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Clean figure.
%--------------
hAXES   = findobj(hFig,'Type','axes');
hLINES  = findobj(hAXES,'Type','line');
hPATCH  = findobj(hAXES,'Type','patch');
set(hAXES,'Visible','off');
set(handles.Pan_STATS,'Visible','off');
delete([hLINES;hPATCH]);
%--------------------------------------------------------------------------

%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(hFig)

% Add UIMENUS.
%-------------
m_files     = wfigmngr('getmenus',hFig,'file');

% Add Help for Tool.
%------------------
% wfighelp('addHelpTool',hFig,'&Continuous Analysis','CW1D_GUI');

% Add Help Item.
%----------------
% wfighelp('addHelpItem',hFig,'Continuous Transform','CW_TRANSFORM');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files);
%-------------------------------------------------------------------------

function DispxDif(FBMxDif,axe_xdif,DiffOrder,curr_color,FBM_PARAMS)
% x order increments axes display.
%---------------------------------
line(0:length(FBMxDif)-1,FBMxDif,'Color',curr_color,'Parent',axe_xdif);
Xlim    = [0 length(FBMxDif)];
ext = abs(max(FBMxDif) - min(FBMxDif)) / 100;
Ylim = [min(FBMxDif)-ext max(FBMxDif)+ext];
set(axe_xdif,'XLim',Xlim,'YLim',Ylim);

% Get parameter settings.
%------------------------
Wav = FBM_PARAMS.Wav;                   % Wavelet used                           
Val_Length_Num = FBM_PARAMS.Length;     % Signal length (numeric)                           
Val_Index = FBM_PARAMS.H;               % Fractal index (numeric)                                        


strORDER = deblankl(DiffOrder);
if isequal(strORDER,'0')
    label = getWavMSG('Wavelet:divGUIRF:Tit_SyntLen',Val_Length_Num,Wav,num2str(Val_Index));    
%     labSTR = [ ...
%         'Synthesized Fractional Brownian Motion of length %s',  ...
%         ' using %s and H = %s'];
%     label = sprintf(labSTR,num2str(Val_Length_Num),Wav,num2str(Val_Index));
else
    label = getWavMSG('Wavelet:divGUIRF:FBM_IncOrd_N',strORDER);
end
wguiutils('setAxesTitle',axe_xdif,label,'On');
set(axe_xdif,'Visible','on');
%--------------------------------------------------------------------------

function DispHistCumhist(FBMxDif,axe_hist,axe_cumhist,his,curr_color)
% Displaying histogram.
%----------------------
his(2,:)  = his(2,:)/length(FBMxDif(:));
wplothis(axe_hist,his,curr_color);
label = getWavMSG('Wavelet:commongui:Str_Hist');
wguiutils('setAxesTitle',axe_hist,label,'On');
set(axe_hist,'Visible','on');

% Displaying cumulated histogram.
%--------------------------------
for i=6:4:length(his(2,:))
    his(2,i)   = his(2,i)+his(2,i-4);
    his(2,i+1) = his(2,i);
end
wplothis(axe_cumhist,[his(1,:);his(2,:)],curr_color);
label = getWavMSG('Wavelet:commongui:Str_CumHist');
wguiutils('setAxesTitle',axe_cumhist,label,'On');
set(axe_cumhist,'Visible','on');
%--------------------------------------------------------------------------

function DispCorrSpec(FBMxDif,axe_corr,axe_spec,curr_color)
% Displaying Autocorrelations.
%-----------------------------       
[corr,lags] = wautocor(FBMxDif);
lenLagsPos  = (length(lags)-1)/2;
lenKeep     = min(200,lenLagsPos);
first       = lenLagsPos+1-lenKeep;
last        = lenLagsPos+1+lenKeep;
Xval        = lags(first:last);
Yval        = corr(first:last);
line('XData',Xval,'YData',Yval,'Color',curr_color,'Parent',axe_corr);
set(axe_corr,'XLim',[Xval(1) Xval(end)],...
             'YLim',[min(0,1.1*min(Yval)) 1]);
label = getWavMSG('Wavelet:commongui:Str_AutoCor');
wguiutils('setAxesTitle',axe_corr,label,'On');
set(axe_corr,'Visible','on');

% Displaying Spectrum.
%---------------------
[sp,f]  = wspecfft(FBMxDif);
Xlim    = [min(f) max(f)];
ext     = abs(max(sp) - min(sp)) / 100;
Ylim    = [min(sp)-ext max(sp)+ext];
set(axe_spec,'XLim',Xlim,'YLim',Ylim);
label = getWavMSG('Wavelet:commongui:Str_EnerSpect');
set(axe_spec,'Visible','on');
line('XData',f,'YData',sp,'Color',curr_color,'Parent',axe_spec);
wguiutils('setAxesTitle',axe_spec,label,'On');
%--------------------------------------------------------------------------
function DispStats(FBMxDif,handles,mode_val)

% Computing values for statistics.
%---------------------------------
errtol     = 1.0E-12;
mean_val   = mean(FBMxDif);
max_val    = max(FBMxDif);
min_val    = min(FBMxDif);
range_val  = max_val-min_val;
std_val    = std(FBMxDif);
med_val    = median(FBMxDif);
medDev_val = median(abs(FBMxDif(:)-med_val)); 
if abs(medDev_val)<errtol , medDev_val = 0; end
meanDev_val = mean(abs(FBMxDif(:)-mean_val));      
if abs(meanDev_val)<errtol , meanDev_val = 0; end
L1_val = norm(FBMxDif,1);
L2_val = norm(FBMxDif,2);
LM_val = norm(FBMxDif,Inf);

% Displaying Statistics.
%-----------------------
set(handles.Edi_Mean,'String',sprintf('%1.4g',mean_val));
set(handles.Edi_Max,'String',sprintf('%1.4g',max_val));
set(handles.Edi_Min,'String',sprintf('%1.4g',min_val));
set(handles.Edi_Range,'String',sprintf('%1.4g',range_val));
set(handles.Edi_StdDev,'String',sprintf('%1.4g',std_val));
set(handles.Edi_Median,'String',sprintf('%1.4g',med_val));
set(handles.Edi_MedAbsDev,'String',sprintf('%1.4g',medDev_val));
set(handles.Edi_MeanAbsDev,'String',sprintf('%1.4g',meanDev_val));
set(handles.Edi_Mode,'String',sprintf('%1.4g',mode_val));
set(handles.Edi_L1,'String',sprintf('%1.4g',L1_val));
set(handles.Edi_L2,'String',sprintf('%1.4g',L2_val));
set(handles.Edi_LM,'String',sprintf('%1.4g',LM_val));

set(handles.Pan_STATS,'Visible','on');
%--------------------------------------------------------------------------
function [sp,f] = wspecfft(signal)
%WSPECFFT FFT spectrum of a signal.
%
% f is the frequency 
% sp is the energy, the square of the FFT transform

% The input signal is empty.
%---------------------------
if isempty(signal)
    sp = [];f =[];return
end

% Compute the spectrum.
%----------------------
n   = length(signal);
XTF = fft(fftshift(signal));
m   = ceil(n/2) + 1;

% Compute the output values.
%---------------------------
f   = linspace(0,0.5,m);
sp  = (abs(XTF(1:m))).^2;
%--------------------------------------------------------------------------

function [c,lags] = wautocor(a,maxlag)
%WAUTOCOR Auto-correlation function estimates.
%   [C,LAGS] = WAUTOCOR(A,MAXLAG) computes the 
%   autocorrelation function c of a one dimensional
%   signal a, for lags = [-maxlag:maxlag]. 
%   The autocorrelation c(maxlag+1) = 1.
%   If nargin==1, by default, maxlag = length(a)-1.

if nargin == 1, maxlag = size(a,2)-1;end
lags = -maxlag:maxlag;
if isempty(a) , c = []; return; end
epsi = sqrt(eps);
a    = a(:);
a    = a - mean(a);
nr   = length(a); 
if std(a)>epsi
    % Test of the variance.
    %----------------------
    mr     = 2 * maxlag + 1;
    nfft   = 2^nextpow2(mr);
    nsects = ceil(2*nr/nfft);
    if nsects>4 && nfft<64
        nfft = min(4096,max(64,2^nextpow2(nr/4)));
    end
    c      = zeros(nfft,1);
    minus1 = (-1).^(0:nfft-1)';
    af_old = zeros(nfft,1);
    n1     = 1;
    nfft2  = nfft/2;
    while (n1<nr)
       n2 = min( n1+nfft2-1, nr );
       af = fft(a(n1:n2,:), nfft);
       c  = c + af.* conj( af + af_old);
       n1 = n1 + nfft2;
       af_old = minus1.*af;
    end
    if n1==nr
        af = ones(nfft,1)*a(nr,:);
   	c  = c + af.* conj( af + af_old );
    end
    mxlp1 = maxlag+1;
    c = real(ifft(c));
    c = [ c(mxlp1:-1:2,:); c(1:mxlp1,1) ];

    % Compute the autocorrelation function.
    %-------------------------------------- 
    cdiv = c(mxlp1,1);
    c = c / cdiv;
else
    % If  the variance is too small.
    %-------------------------------
    c = ones(size(lags));
end
%--------------------------------------------------------------------------
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%
