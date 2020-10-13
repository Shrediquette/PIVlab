function varargout = Background_GUI(varargin)
% BACKGROUND_GUI MATLAB code for Background_GUI.fig
%      BACKGROUND_GUI, by itself, creates a new BACKGROUND_GUI or raises the existing
%      singleton*.
%
%      H = BACKGROUND_GUI returns the handle to a new BACKGROUND_GUI or the handle to
%      the existing singleton*.
%
%      BACKGROUND_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUND_GUI.M with the given input arguments.
%
%      BACKGROUND_GUI('Property','Value',...) creates a new BACKGROUND_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Background_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Background_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Background_GUI

% Last Modified by GUIDE v2.5 27-Oct-2018 16:10:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Background_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @Background_GUI_OutputFcn, ...
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

% --- Executes just before Background_GUI is made visible.
function Background_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Background_GUI (see VARARGIN)

% Choose default command line output for Background_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

handles.output = hObject;
guidata(hObject, handles);
handles=guihandles(hObject);
setappdata(0,'hbackgui',gcf);

imshow(imread('PIVlablogo.jpg'))

% UIWAIT makes Background_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Background_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
%wenn änderung im popupmenu: alles löschen, save disablen
setappdata(getappdata(0,'hbackgui'),'image1_bg',[])
setappdata(getappdata(0,'hbackgui'),'image2_bg',[])
set(handles.subtractsave, 'Enable', 'off');



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background_gui on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in load_img_list.
function load_img_list_Callback(hObject, eventdata, handles)



popup_sel_index = get(handles.popupmenu1, 'Value'); %1 für A-B C-D





[filenames, directory] = uigetfile({'*.bmp';'*.jpg';'*.tif';'*.jpeg';'*.tiff'},'File Selector','MultiSelect','on');
filenames = sortrows(filenames); %sort all image files

%wenn eine ungerade Anzahl an Bilder geladen wurde --> letztes Element
%entfernen.
if mod(length(filenames),2)==1 %wenn ungerade --> ergibt 1
    cutoff=length(filenames);
    filenames(cutoff)=[];
end
amount = length(filenames);

if amount >=2 && amount < 20
    uiwait(msgbox('Hint: You selected only a small number of images. The results of the background generation might be suboptimal. Backgound generation works much better for large amounts of input images.','Hint','modal'));
end
set(handles.subtractsave, 'Enable', 'off');

if amount > 2 %nur was machen wenn auch überhaupt Bilder geladen wurden
    setappdata(getappdata(0,'hbackgui'),'image1_bg',[])
    setappdata(getappdata(0,'hbackgui'),'image2_bg',[])
    
    setappdata(getappdata(0,'hbackgui'),'filenames',filenames)
    setappdata(getappdata(0,'hbackgui'),'directory',directory)
    
    
    
    if popup_sel_index == 1 % A-B, C-D ,... Style
        %check loaded imgs:
        %figure;for k=1:2:50;imshow(imadjust(imread(fullfile(directory, filenames{k}))));drawnow;end
        %figure;for k=2:2:50;imshow(imadjust(imread(fullfile(directory, filenames{k}))));drawnow;end
        image1=imread(fullfile(directory, filenames{1})); %read first image to get dimensions
        image2=imread(fullfile(directory, filenames{2})); %read second image to get dimensions
        if size(image1,3)>1
            image1=rgb2gray(image1);
            image2=rgb2gray(image2);
            colorimg=1;
        else
            colorimg=0;
        end
        counter=0;
        classimage=class(image1); %memorize the original image format
        image1=int64(image1); %convert to int64 to accept very large numbers
        image2=int64(image2);
        for i=3:2:amount
            counter=counter+1;
            set(handles.progress, 'String', ['Progress: ' num2str(round(i/amount*100)) ' %']);drawnow;
            try
                if colorimg==0;
                    image1=image1+int64(imread(fullfile(directory, filenames{i}))); % read images
                    image2=image2+int64(imread(fullfile(directory, filenames{i+1})));
                else
                    image1=image1+int64(rgb2gray(imread(fullfile(directory, filenames{i})))); % read images
                    image2=image2+int64(rgb2gray(imread(fullfile(directory, filenames{i+1}))));
                end
            catch ME
                disp('ERROR: MOST LIKELY YOUR IMAGES DO NOT HAVE THE SAME SIZE.')
                disp (ME)
            end
            
        end
        
        %Making average in the format of the original image
        if strcmp(classimage,'uint16')==1
            image1_bg=uint16(image1/round(amount/2));
            image2_bg=uint16(image2/round(amount/2));
        end
        if strcmp(classimage,'uint8')==1
            image1_bg=uint8(image1/round(amount/2));
            image2_bg=uint8(image2/round(amount/2));
        end
        %make results accessible to the rest of the GUI:
        setappdata(getappdata(0,'hbackgui'),'image1_bg',image1_bg)
        setappdata(getappdata(0,'hbackgui'),'image2_bg',image2_bg)
    end % Sequencing style 1
    
    if popup_sel_index == 2 % A-B, B-C ,... Style
        image1=imread(fullfile(directory, filenames{1})); %read first image to get dimensions
        counter=0;
        if size(image1,3)>1
            image1=rgb2gray(image1);
            colorimg=1;
        else
            colorimg=0;
        end
        classimage=class(image1); %memorize the original image format
        image1=int64(image1); %convert to int64 to accept very large numbers
        for i=2:1:amount
            set(handles.progress, 'String', ['Progress: ' num2str(round(i/amount*100)) ' %']);drawnow;
            
            counter=counter+1;
            try
                if colorimg==0
                image1=image1+int64(imread(fullfile(directory, filenames{i}))); % read images
                else
                    image1=image1+int64(rgb2gray(imread(fullfile(directory, filenames{i})))); % read images
                end
            catch ME
                disp('ERROR: MOST LIKELY YOUR IMAGES DO NOT HAVE THE SAME SIZE.')
                disp (ME)
            end
            
        end
        
        %Making average in the format of the original image
        if strcmp(classimage,'uint16')==1
            image1_bg=uint16(image1/round(amount));
        end
        if strcmp(classimage,'uint8')==1
            image1_bg=uint8(image1/round(amount));
        end
        setappdata(getappdata(0,'hbackgui'),'image1_bg',image1_bg)
    end % Sequencing style 2
    
    setappdata(getappdata(0,'hbackgui'),'displaying',1);
    toggleAB_Callback
    set(handles.progress, 'String', ['Progress: ' num2str(100) ' %']);drawnow;
    set(handles.subtractsave, 'Enable', 'on');
else
    uiwait(msgbox('Error: You did not select enough images.','Error','modal'));
end

%subtract
%{

%}


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in toggleAB.
function toggleAB_Callback(hObject, eventdata, handles)
displaying=1;
image1_bg=getappdata(getappdata(0,'hbackgui'),'image1_bg');
image2_bg=getappdata(getappdata(0,'hbackgui'),'image2_bg');
displaying=getappdata(getappdata(0,'hbackgui'),'displaying');



if displaying == 1
    displaying = 2;
    setappdata(getappdata(0,'hbackgui'),'displaying',displaying);
    if isempty(image1_bg)==0
        
        imshow(imadjust(image1_bg))
    end
else
    displaying = 1;
    setappdata(getappdata(0,'hbackgui'),'displaying',displaying);
    if isempty(image2_bg)==0
        imshow(imadjust(image2_bg))
    end
end


% --- Executes on button press in subtractsave.
function subtractsave_Callback(hObject, eventdata, handles)

filenames=  getappdata(getappdata(0,'hbackgui'),'filenames');
directory=  getappdata(getappdata(0,'hbackgui'),'directory');
image1_bg=getappdata(getappdata(0,'hbackgui'),'image1_bg');
image2_bg=getappdata(getappdata(0,'hbackgui'),'image2_bg');
popup_sel_index = get(handles.popupmenu1, 'Value'); %1 für A-B C-D


amount = length(filenames);
counter=0;

folder_out = uigetdir(directory,'Please choose a new & empty folder for saving files.');

if folder_out~=0
    image1=imread(fullfile(directory, filenames{1}));
    if size(image1,3)>1
        colorimg=1;
    else
        colorimg=0;
    end
    %sequencing style beachten...
    if popup_sel_index == 1 % A-B, C-D ,... Style
        for i=1:2:amount
            set(handles.progress, 'String', ['Progress: ' num2str(round(i/amount*100)) ' %']);drawnow;
            counter=counter+1;
            if colorimg==0
                image1=imread(fullfile(directory, filenames{i}))-image1_bg;
                image2=imread(fullfile(directory, filenames{i+1}))-image2_bg;
            else
                image1=rgb2gray(imread(fullfile(directory, filenames{i})))-image1_bg;
                image2=rgb2gray(imread(fullfile(directory, filenames{i+1})))-image2_bg;
            end
            imwrite(image1,fullfile(folder_out,['bg_subtracted_' filenames{i}]));
            imwrite(image2,fullfile(folder_out,['bg_subtracted_' filenames{i+1}]));
        end
    end
    if popup_sel_index == 2 % A-B, B-C ,... Style
        for i=1:amount
            set(handles.progress, 'String', ['Progress: ' num2str(round(i/amount*100)) ' %']);drawnow;
            counter=counter+1;
            if colorimg==0
                image1=imread(fullfile(directory, filenames{i}))-image1_bg;
            else
                image1=rgb2gray(imread(fullfile(directory, filenames{i})))-image1_bg;
            end
            imwrite(image1,fullfile(folder_out,['bg_subtracted_' filenames{i}]));
        end
    end
    
    
    set(handles.progress, 'String', ['Progress: ' num2str(100) ' %']);drawnow;
end
