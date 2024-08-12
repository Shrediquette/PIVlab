function varargout = wtbxexport(varargin)
% WTBXEXPORT MATLAB file for wtbxexport.fig

% Last Modified by GUIDE v2.5 22-Jun-2009 17:14:45
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Mar-2007.
%   Last Revision 17-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wtbxexport_OpeningFcn, ...
                   'gui_OutputFcn',  @wtbxexport_OutputFcn, ...
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
%--------------------------------------------------------------------------
% --- Executes just before wtbxexport is made visible.
function wtbxexport_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for wtbxexport
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialisation
Init_Tool(hObject,eventdata,handles,varargin{:});

% UIWAIT makes wtbxexport wait for user response (see UIRESUME)
uiwait(handles.figure1);
%--------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = wtbxexport_OutputFcn(hObject,eventdata,handles)  %#ok<INUSD>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];
%--------------------------------------------------------------------------
function lst_VAR_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

lst = get(hObject,'String');
val = get(hObject,'Value');
if isequal(val,2) , val = 1; end
varName = lst{val};
set(handles.edi_VAR,'String',varName);
%--------------------------------------------------------------------------
function Pus_OK_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>


Verify_and_Export_Var(hObject,gcbf,handles)
%--------------------------------------------------------------------------
function Verify_and_Export_Var(hObject,fig,handles) %#ok<INUSL>

name_VAR = get(handles.edi_VAR,'String');
if isempty(name_VAR) , return; end
if iscell(name_VAR)
    name_VAR = name_VAR{1};
    if isempty(name_VAR) , return; end
end

% Verify the name of the variable
OK_Var = true;

lst_STR = get(handles.lst_VAR,'String');
idx = find(strcmp(name_VAR,lst_STR));
call_DLG = ~isempty(idx) && ~isequal(idx,1);
if call_DLG
    Str_Yes = getWavMSG('Wavelet:commongui:Str_Yes');
    Str_No =  getWavMSG('Wavelet:commongui:Str_No');
    ButtonName = questdlg(...
        getWavMSG('Wavelet:moreMSGRF:QUEST_Replace_VAR',name_VAR), ...
        getWavMSG('Wavelet:moreMSGRF:Replace_VAR'),Str_Yes,Str_No,Str_No);
    switch ButtonName
        case Str_No
            OK_Var = false;
            % To reset the dialog and prompt again,
            % uncomment the 3 next lines and comment the 4th.
            
            name_VAR = get(handles.edi_VAR,'UserData');
            if iscell(name_VAR) , name_VAR = name_VAR{1}; end
            set(handles.edi_VAR,'String',name_VAR);
            % close(fig) % The dialog is closed.
            
        case Str_Yes
    end
end

% Export to the workspace.
if OK_Var
    Var_VALUE = wtbxappdata('get',fig,'Var_VALUE');
    if isequal(name_VAR,getWavMSG('Wavelet:moreMSGRF:Curr_Part'))
        name_VAR = 'Curr_Part'; 
    end
    assignin('base',name_VAR,Var_VALUE)
    close(fig)
end
%--------------------------------------------------------------------------
function Pus_CAN_Callback(hObject,eventdata,handles) %#ok<INUSD,DEFNU>

close(gcbf)
%--------------------------------------------------------------------------
function edi_VAR_Callback(hObject,eventdata,handles) %#ok<DEFNU,INUSD>

% Verify_and_Export_Var(hObject,gcbf,handles)
%--------------------------------------------------------------------------
function  Init_Tool(hObject,eventdata,handles,varargin) %#ok<INUSL>

% Set WindowStyle modal.
wtranslate(mfilename,hObject)
set(hObject,'WindowStyle','modal')

% Check variables on Workspace.
workspace_vars = evalin('base','whos');
num_of_vars = length(workspace_vars);
var_Names = cell(1,num_of_vars);
for k=1:num_of_vars , var_Names{k} = workspace_vars(k).name; end

% Set new variable name.
name_DEF = {'my_VAR'};
name_VAR = '';
titleSTR = getWavMSG('Wavelet:commongui:Lab_Export');
nbIN = length(varargin)-1;
for k = 2:2:nbIN
    argNAM = varargin{k};
    argVAL = varargin{k+1};
    switch argNAM
        case 'name'  , name_VAR = {argVAL};
        case 'title' , titleSTR = [titleSTR ' - ' argVAL]; %#ok<AGROW>
    end
end
if isempty(name_VAR) , name_VAR = name_DEF; end
var_Names = [name_VAR , '-----------------' , var_Names];

% Verify new name.
idx = 0;
nameUSED = any(strcmp(var_Names,name_VAR));
while nameUSED
    idx = idx + 1;
    name_VAR = {['my_VAR_' int2str(idx)]};
    nameUSED = any(strcmp(var_Names,name_VAR));    
end
set(handles.edi_VAR,'String',name_VAR,'UserData',name_VAR);
set(handles.lst_VAR,'String',var_Names);
set(hObject,'Name',titleSTR);

% Store new variable value.
wtbxappdata('set',hObject,'Var_VALUE',varargin{1});
%--------------------------------------------------------------------------
