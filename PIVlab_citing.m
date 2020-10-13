function varargout = PIVlab_citing(varargin)
% PIVLAB_CITING MATLAB code for PIVlab_citing.fig
%      PIVLAB_CITING, by itself, creates a new PIVLAB_CITING or raises the existing
%      singleton*.
%
%      H = PIVLAB_CITING returns the handle to a new PIVLAB_CITING or the handle to
%      the existing singleton*.
%
%      PIVLAB_CITING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIVLAB_CITING.M with the given input arguments.
%
%      PIVLAB_CITING('Property','Value',...) creates a new PIVLAB_CITING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PIVlab_citing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PIVlab_citing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PIVlab_citing

% Last Modified by GUIDE v2.5 18-Mar-2015 22:37:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PIVlab_citing_OpeningFcn, ...
    'gui_OutputFcn',  @PIVlab_citing_OutputFcn, ...
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


% --- Executes just before PIVlab_citing is made visible.
function PIVlab_citing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PIVlab_citing (see VARARGIN)

% Choose default command line output for PIVlab_citing
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
handles=guihandles(gcf);

hgui=getappdata(0,'hgui');
var=getappdata(hgui, 'PIVver');

set(handles.edit5,'String',['Thielicke, W. & Stamhuis, E.J. (2014). PIVlab – Towards User-friendly, Affordable and Accurate Digital Particle Image Velocimetry in MATLAB. Journal of Open Research Software 2(1):e30, DOI: http://dx.doi.org/10.5334/jors.bl']);
set(handles.edit2,'String',['Thielicke, W. & Stamhuis, E.J. (2014): PIVlab - Time-Resolved Digital Particle Image Velocimetry Tool for MATLAB (version: ' var '), DOI: http://dx.doi.org/10.6084/m9.figshare.1092508']);
set(handles.edit3,'String',['Thielicke, W. (2014): The Flapping Flight of Birds - Analysis and Application. Phd thesis, Rijksuniversiteit Groningen, http://irs.ub.rug.nl/ppn/382783069']);
set(handles.edit4,'String',['Garcia, D. (2011): A fast all-in-one method for automated post-processing of PIV data. Experiments in Fluids, Springer-Verlag, 2011, 50, 1247-1259']);


% --- Outputs from this function are returned to the command line.
function varargout = PIVlab_citing_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[bibfile,bibpath] = uiputfile('PIVlabThielicke.bib','Save Bibtex file');
if isequal(bibfile,0) | isequal(bibpath,0)
else
    hgui=getappdata(0,'hgui');
    var=getappdata(hgui, 'PIVver');
    fid=fopen(fullfile(bibpath,bibfile), 'wt');fprintf(fid,['@ARTICLE{Thielicke2014,\n author = {William Thielicke and Eize J. Stamhuis},\n title = {{PIVlab - Time-Resolved Digital Particle Image Velocimetry Tool for MATLAB (version: ' var ')}},\n year = {2014},\n month = {07},\n url = {http://dx.doi.org/10.6084/m9.figshare.1092508}\n}']);fclose(fid);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)

function text1_CreateFcn(hObject, eventdata, handles)



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
[bibfile,bibpath] = uiputfile('ThesisThielicke.bib','Save Bibtex file');
if isequal(bibfile,0) | isequal(bibpath,0)
else
    fid=fopen(fullfile(bibpath,bibfile), 'wt');fprintf(fid,'@PHDTHESIS{Thielicke2014,\n  author = {William Thielicke},\n  title = {The Flapping Flight of Birds -- Analysis and Application},\n  school = {Rijksuniversiteit Groningen},\n  year = {2014},\n abstract = {This thesis analyses the aerodynamics of slow-speed flapping flight in birds using physical models and time-resolved, 3D flow visualization with a custom DPIV tool. \n It was shown that flow separation plays an important role in the flapping flight of birds. Leading-edge vortices develop at high effective angles of attack and enhance the circulation and hence the aerodynamic force. The intensity of leading-edge vortices can be greatly influenced by the airfoil design, such as camber and thickness. It is likely that birds and bats benefit from these possibilities to control LEVs. The aerodynamic efficiency however decreases with the development of LEVs. The efficiency can be modulated and improved by twisting the wings. That does however decrease the magnitude of the aerodynamic force coefficients and can most likely not be afforded in all flight modes: At higher flight speeds, force coefficients do not need to be maximal, and wing twist increases both the L/D and the span efficiency. Low flight speeds require maximal force coefficients and efficiency becomes of secondary interest. \n Such a competition between efficiency and peak forces also exists in technical flight: Fixed wing aircraft are very efficient in cruising flight, but -- unlike birds -- do not generate enough lift in slow speed flight. Rotary wing devices can generate sufficient forces in slow and hovering flight, but -- again unlike birds -- have an inferior efficiency at higher flight speeds. Flapping wing micro air vehicles can combine the advantages of rotary and fixed wing aircraft. A prototype and a method that may predict the aerodynamic forces generated in slow-speed flapping flight using a theory of delta-wing aircraft was developed. The MAV is equipped with bird-inspired wings that perform very well in both gliding flight and slow-speed flapping flight. \n The combination of flight modes enables to develop micro air vehicles that might one day have a similar performance as birds: Exceptional manoeuvrability in combination with an outstanding aerodynamic efficiency.}\n}');fclose(fid);
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
handles=guihandles(gcf);
clipboard('copy', get(handles.edit5,'string'))

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
handles=guihandles(gcf);
clipboard('copy', get(handles.edit2,'string'))


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
handles=guihandles(gcf);
clipboard('copy', get(handles.edit3,'string'))


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
guidata(hObject, handles);
handles=guihandles(gcf);
clipboard('copy', get(handles.edit4,'string'))
