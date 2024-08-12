function varargout = dw1dview_dorc(varargin)
% DW1DVIEW_DORC MATLAB file for dw1dview_dorc.fig
%      DW1DVIEW_DORC, by itself, creates a new DW1DVIEW_DORC or raises the existing
%      singleton*.
%
%      H = DW1DVIEW_DORC returns the handle to a new DW1DVIEW_DORC or the handle to
%      the existing singleton*.
%
%      DW1DVIEW_DORC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DW1DVIEW_DORC.M with the given input arguments.
%
%      DW1DVIEW_DORC('Property','Value',...) creates a new DW1DVIEW_DORC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dw1dview_dorc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dw1dview_dorc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dw1dview_dorc

% Last Modified by GUIDE v2.5 09-Aug-2007 16:30:23
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Aug-2007.
%   Last Revision: 22-Oct-2011.
%   Copyright 1995-2020 The MathWorks, Inc.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dw1dview_dorc_OpeningFcn, ...
                   'gui_OutputFcn',  @dw1dview_dorc_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before dw1dview_dorc is made visible.
function dw1dview_dorc_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Choose default command line output for dw1dview_dorc
handles.output = hObject;

% Update handles structure
guidata(hObject,handles);

wfigmngr('extfig',hObject,'ExtFig_Show');

% Clean Axe_SIG
Axe_SIG = handles.Axe_SIG;
OBJ = wfindobj(Axe_SIG,'Type','line');
delete(OBJ);

% Check Caller
win = varargin{1};
nameCaller = get(win,'Tag');
switch nameCaller
    case {'DW1D_DEN','WP1D_DEN'}
        typeSIG = 'Denoised';
        nameSTR = getWavMSG('Wavelet:dw1dRF:View_OSDS');
        chkSTR  = getWavMSG('Wavelet:dw1dRF:Str_DS');
        
    case {'DW1D_CMP','WP1D_CMP'}
        typeSIG = 'Compressed';
        nameSTR = getWavMSG('Wavelet:dw1dRF:View_OSCS');
        chkSTR  = getWavMSG('Wavelet:dw1dRF:Str_CS');
end
CallerST = struct('handle',win,'typeSIG',typeSIG);
wtbxappdata('set',hObject,'Caller',CallerST);
set(hObject,'Name',nameSTR);
set(handles.Chk_DorC,'String',chkSTR);

% Install DynVTool.
dynvtool('Install_V3',hObject,handles);

wfigmngr('end_GUIDE_FIG',hObject,mfilename,'noRedim');

% Show Denoised or Compressed Signal
switch nameCaller
    case {'DW1D_DEN','DW1D_CMP'}
        [lin_ORI,lin_DorC] = utthrw1d('get',win,'handleORI','handleTHR'); 
    case 'WP1D_DEN'
        [lin_ORI,lin_DorC] = utthrwpd('get',win,'handleORI','handleTHR');        
    case 'WP1D_CMP'
        [lin_ORI,lin_DorC] = utthrgbl('get',win,'handleORI','handleTHR');
end
sigORI = get(lin_ORI,{'XData','YData'});
sigDEN = get(lin_DorC,{'XData','YData'});
ORI_color = wtbutils('colors','sig');
DorC_color = 'k';
LW = 2;
lin_ORI = line(...
    'Parent',handles.Axe_SIG, ...
    'XData',sigORI{1},  ...
    'YData',sigORI{2},  ...
    'Color',ORI_color,  ...
    'Visible','Off'     ...
    );
lin_DorC = line(...
    'Parent',handles.Axe_SIG, ...
    'XData',sigDEN{1},  ...
    'YData',sigDEN{2},  ...
    'LineWidth',LW, ...
    'Color',DorC_color,  ...
    'Visible','On'      ...    
    );
axis(handles.Axe_SIG,'tight');
set(handles.Axe_SIG,'Xgrid','On','Ygrid','On')
wtitle(chkSTR,'Parent',Axe_SIG);
wtbxappdata('set',hObject,'lin_ORI',lin_ORI);
wtbxappdata('set',hObject,'lin_DorC',lin_DorC);

% Initialize DYNVTOOL.
%---------------------
dynvtool('init',hObject,[],Axe_SIG,[],[1 0],'','','','real');

% UIWAIT makes dw1dview_dorc wait for user response (see UIRESUME)
% uiwait(handles.Fig_Sig_DorC);

% --- Outputs from this function are returned to the command line.
function varargout = dw1dview_dorc_OutputFcn(hObject,eventdata,handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Pus_CloseWin.
function Pus_CloseWin_Callback(hObject,eventdata,handles,arg) %#ok<INUSD,DEFNU>

if nargin>3
    fig = wfindobj(0,'Type','Figure','Tag','Fig_Sig_DorC');
else
    if strcmpi(get(hObject,'Type'),'Figure')
        fig = hObject;
    else
        fig = get(hObject,'Parent');
    end
end
delete(fig)

% --- Executes on button press in Pus_CloseWin.
function Chk_Callback(hObject,eventdata,handles,num) %#ok<INUSL,DEFNU>

valChk = get(hObject,'Value');
lin_ORI = wtbxappdata('get',hObject,'lin_ORI');
lin_DorC = wtbxappdata('get',hObject,'lin_DorC');
CallerST = wtbxappdata('get',hObject,'Caller');
switch num
    case 0 , LIN = lin_ORI;
    case 1 , LIN = lin_DorC;    
end

if isequal(valChk,1) , vis = 'On'; else vis = 'Off'; end
set(LIN,'Visible',vis');
vis_ORI = get(lin_ORI,'Visible');
vis_DorC = get(lin_DorC,'Visible');
if strcmpi(vis_ORI,'On')
    if strcmpi(vis_DorC,'On')
        switch lower(CallerST.typeSIG(1))
            case 'c' , strTIT = getWavMSG('Wavelet:commongui:Ori_CompSig');
            case 'd' , strTIT = getWavMSG('Wavelet:commongui:Ori_DenoSig');
        end
    else
        strTIT = getWavMSG('Wavelet:commongui:OriSig');
    end
else
    if strcmpi(vis_DorC,'On')
        switch lower(CallerST.typeSIG(1))
            case 'c' , strTIT = getWavMSG('Wavelet:commongui:CompSig');
            case 'd' , strTIT = getWavMSG('Wavelet:commongui:DenoSig');
        end
    else
        strTIT = '';
    end
end
wtitle(strTIT,'Parent',handles.Axe_SIG);
