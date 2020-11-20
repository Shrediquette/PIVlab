function varargout = PIVlab_Quickview(varargin)
% PIVLAB_QUICKVIEW MATLAB code for PIVlab_Quickview.fig
%      PIVLAB_QUICKVIEW, by itself, creates a new PIVLAB_QUICKVIEW or raises the existing
%      singleton*.
%
%      H = PIVLAB_QUICKVIEW returns the handle to a new PIVLAB_QUICKVIEW or the handle to
%      the existing singleton*.
%
%      PIVLAB_QUICKVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIVLAB_QUICKVIEW.M with the given input arguments.
%
%      PIVLAB_QUICKVIEW('Property','Value',...) creates a new PIVLAB_QUICKVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PIVlab_Quickview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PIVlab_Quickview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PIVlab_Quickview

% Last Modified by GUIDE v2.5 20-Nov-2020 13:21:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PIVlab_Quickview_OpeningFcn, ...
    'gui_OutputFcn',  @PIVlab_Quickview_OutputFcn, ...
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


% --- Executes just before PIVlab_Quickview is made visible.
function PIVlab_Quickview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PIVlab_Quickview (see VARARGIN)

% Choose default command line output for PIVlab_Quickview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(gcf,'numbertitle','off','MenuBar','none','DockControls','off','Toolbar','none');

% UIWAIT makes PIVlab_Quickview wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.axes1,'Visible','off')
set(handles.axes2,'Visible','off')
set(handles.axes3,'Visible','off')
set(handles.axes4,'Visible','off')

if exist('quickview_settings.mat','file')==0
    IA_size=32;fast_performance=1;disable_auto=0;
    save('quickview_settings.mat','IA_size','fast_performance','disable_auto');
else
    load('quickview_settings.mat');
end
setappdata(handles.figure1,'IA_size',IA_size);
setappdata(handles.figure1,'fast_performance',fast_performance);
setappdata(handles.figure1,'disable_auto',disable_auto);
switch IA_size
    case 64
        handles.size64.Checked = 'on';
        handles.size48.Checked = 'off';
        handles.size32.Checked = 'off';
        handles.size16.Checked = 'off';
    case 48
        handles.size64.Checked = 'off';
        handles.size48.Checked = 'on';
        handles.size32.Checked = 'off';
        handles.size16.Checked = 'off';
    case 32
        handles.size64.Checked = 'off';
        handles.size48.Checked = 'off';
        handles.size32.Checked = 'on';
        handles.size16.Checked = 'off';
    case 16
        handles.size64.Checked = 'off';
        handles.size48.Checked = 'off';
        handles.size32.Checked = 'off';
        handles.size16.Checked = 'on';
end
switch fast_performance
    case 0
        handles.perf_fast.Checked = 'off';
        handles.perf_exhaustive.Checked = 'on';
    case 1
        handles.perf_fast.Checked = 'on';
        handles.perf_exhaustive.Checked = 'off';
end
if disable_auto==0
    handles.disable_auto.Checked = 'off';
else
    handles.disable_auto.Checked = 'on';
end



axes(handles.axes5)
imshow(imread('pivlab_logo1.jpg'),'parent',handles.axes5);
set(handles.axes5,'Position',[0.1,0.1,0.8,0.8],'xtick',[],'ytick',[])
set(handles.axes5,'Visible','on')

% --- Outputs from this function are returned to the command line.
function varargout = PIVlab_Quickview_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_imgs.
function Load_imgs_Callback(hObject, eventdata, handles)
if exist('quickview_settings.mat','file')==0
    path=pwd;
    save ('quickview_settings.mat','path', '-append');
else
    load('quickview_settings.mat','path');
    
    if ~exist('path','var')
        path=pwd;
        save ('quickview_settings.mat','path', '-append');
    end
end
[file,path]=uigetfile({'*.bmp;*.tiff;*.tif;*.jpg;*.b16;*.png;*.jpeg'},'Halleluja',path,'MultiSelect','on');
if ~isequal(file,0) && iscell(file)
    set(handles.axes1,'Visible','on')
    set(handles.axes2,'Visible','on')
    set(handles.axes3,'Visible','on')
    set(handles.axes4,'Visible','on')
    if ishghandle(handles.axes5)
        set(handles.axes5,'Visible','off')
        set(handles.axes5.Children,'Visible','off')
        set(handles.axes5.Children,'CData',[])
        delete(handles.axes5.Children)
        delete(handles.axes5)
    end
    save ('quickview_settings.mat','path', '-append');
    display_images(file, path,handles,0);
else
    disp('Please select 2 images')
end

function display_images(file, path,handles,whoIsCalling)
if ~isempty(file)
    toggle_status=get(handles.toggle_img,'Value')+1;
    [~,~,ext] = fileparts(fullfile(path,file{toggle_status}));
    if strcmp(ext,'.b16')
        img=f_readB16(fullfile(path,file{toggle_status}));
    else
        img=imread(fullfile(path,file{toggle_status}));
    end
    if size(img,3)>1
        img=rgb2gray(img);
    end
    axes(handles.axes1)
    image(imadjust(img), 'parent',gca, 'cdatamapping', 'scaled');
    colormap(handles.axes1,'gray')
    axis image;
    set(gca,'ytick',[])
    set(gca,'xtick',[])
    %imagesc(img1,'Parent',handles.axes1);axis image
    if whoIsCalling == 0 %called after "open image"
        imgsize=size(img);
        roi_size=[round(imgsize(2)/4*1),round(imgsize(1)/4*1),round(imgsize(2)/4*2),round(imgsize(1)/4*2)];
        setappdata(handles.figure1,'roi_size',roi_size);
    else %called from toggle button
        roi_size= getappdata(handles.figure1,'roi_size');
    end
    roi = drawrectangle(handles.axes1, 'Position',roi_size,'Deletable',0);
    addlistener(roi,'ROIMoved',@allevents);
    setappdata(handles.figure1,'roi_size',roi_size);
    setappdata(handles.figure1,'img_size',size(img));
    setappdata(handles.figure1,'roi',roi);
    
    setappdata(handles.figure1,'file',file);
    setappdata(handles.figure1,'path',path);
end

function allevents(src,evt)
setappdata(src.Parent.Parent,'roi_size',src.Position)


% --- Executes on button press in Correlate.
function Correlate_Callback(hObject, eventdata, handles)
roi=getappdata(handles.figure1,'roi');
if ~isempty(roi)
    text(handles.axes2,10,50,'BUSY...','tag','busytext','fontsize',24,'Color','red','FontWeight','bold','BackgroundColor','k');drawnow;
    file=getappdata(handles.figure1,'file');
    path=getappdata(handles.figure1,'path');
    
    [~,~,ext] = fileparts(fullfile(path,file{1}));
    if strcmp(ext,'.b16')
        image1=f_readB16(fullfile(path,file{1}));
        image2=f_readB16(fullfile(path,file{2}));
    else
        image1=imread(fullfile(path,file{1}));
        image2=imread(fullfile(path,file{2}));
    end
    
    if roi.Position(3)+roi.Position(1)>=size(image1,2)
        roi.Position(3)=roi.Position(3)-1;
    end
    if roi.Position(4)+roi.Position(2)>=size(image1,1)
        roi.Position(4)=roi.Position(4)-1;
    end
    
    image1 = PIVlab_preproc (image1,round(roi.Position),1,50,0,0,0,0,0,0.0,1.0); %preprocess images
    image2 = PIVlab_preproc (image2,round(roi.Position),1,50,0,0,0,0,0,0.0,1.0); %preprocess images
    IA_size=getappdata(handles.figure1,'IA_size');
    %piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask_inpt, roi_inpt,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad)
    if getappdata(handles.figure1,'fast_performance')==1
        performance_settings1='*linear';
        performance_settings2=0;
        performance_settings3=0;
    else
        performance_settings1='*spline';
        performance_settings2=1;
        performance_settings3=1;
    end
    [x, y, u, v, ~] = piv_FFTmulti (image1,image2,IA_size*2,IA_size,1,[],roi.Position,2,IA_size,16,16,performance_settings1,performance_settings2,getappdata(handles.figure1,'disable_auto'),performance_settings3); %actual PIV analysis    axes(handles.axes2)
    [u,v] = PIVlab_postproc (u,v,1, [], 1,7, 1,3);
    if get(handles.toggle_img,'Value')==0
        display_image=image1/2;
    else
        display_image=image2/2;
    end
    axes(handles.axes2)
    image(display_image(round(roi.Position(2):roi.Position(2)+roi.Position(4)),round(roi.Position(1):roi.Position(1)+roi.Position(3))), 'parent',gca)%, 'cdatamapping', 'scaled');
    colormap(handles.axes2,'bone')
    set(gca,'Clipping','on')
    axis image;
    set(gca,'ytick',[])
    set(gca,'xtick',[])
    hold on
    quiver(x-roi.Position(1),y-roi.Position(2),u*8,v*8,'g','autoscale', 'off')%,'parent',handles.axes2)
    %xlim('tight')
    %ylim('tight')
    xlim([0 roi.Position(3)])
    ylim([0 roi.Position(4)])
    set(gca,'Clipping','on')
    hold off
    axes(handles.axes3)
    magn=(u.^2+v.^2).^0.5;
    %{
    max_magn=max(magn(:));
    min_magn=min(magn(:));
    magn=magn/max_magn;
    
    magn=imadjust(magn);
    magn=magn*max_magn;
    magn(magn>=max_magn)=nan;
    magn(magn<=min_magn)=nan;
    %}
    %disp('DAS FUNKTIONIERT SO NICHT! MUSS EIGENES CODEN')
    histogram(magn,round(numel(u)/10),'EdgeColor','none');
    set(gca,'ytick',[])
    
    xlim([mean(magn(:),'omitnan') -  3*std(magn(:),'omitnan') , mean(magn(:),'omitnan') +  3*std(magn(:),'omitnan')])
    axes(handles.axes4)
    
    [xtable, ytable, correlation] = piv_corr2 (image1,image2,IA_size*2, IA_size, [], roi.Position);
    
    imagesc(correlation);colormap(handles.axes4,'parula')
    xticks([])
    yticks([])
    colorbar('West')
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Figure_Size = get(hObject, 'Position');
%                                 x                    y                         width        height
set(handles.axes1,'Position',[0                    ,Figure_Size(4)/4*1 ,Figure_Size(3)/2   ,Figure_Size(4)/4*3   ],'xtick',[],'ytick',[],'ActivePositionProperty','outerposition');
set(handles.axes2,'Position',[Figure_Size(3)/2     ,Figure_Size(4)/4*1 ,Figure_Size(3)/2   ,Figure_Size(4)/4*3   ],'xtick',[],'ytick',[],'ActivePositionProperty','outerposition','Clipping','on');
set(handles.axes3,'Position',[Figure_Size(3)/2     ,0+4              ,Figure_Size(3)/2   ,Figure_Size(4)/4*1-4 ],'xtick',[],'ActivePositionProperty','outerposition');
set(handles.axes4,'Position',[0                    ,0+4               ,Figure_Size(3)/2   ,Figure_Size(4)/4*1-4 ],'xtick',[],'ytick',[],'ActivePositionProperty','outerposition');


% --- Executes on button press in toggle_img.
function toggle_img_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file=getappdata(handles.figure1,'file');
path=getappdata(handles.figure1,'path');
display_images(file, path,handles,1);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if strcmp(eventdata.Character,'l')
    Load_imgs_Callback(hObject, eventdata, handles)
end
if strcmp(eventdata.Character,'p')
    Correlate_Callback(hObject, eventdata, handles)
end
if strcmp(eventdata.Character,'m')
    img_size=getappdata(handles.figure1,'img_size');
    setappdata(handles.figure1,'roi_size',[1 1 ,img_size(2)-1,img_size(1)-1]);
    file=getappdata(handles.figure1,'file');
    path=getappdata(handles.figure1,'path');
    display_images(file, path,handles,1)
end
if strcmp(eventdata.Character,'+')
    dat=findobj('type','Quiver');
    u=dat.UData*1.1;
    v=dat.VData*1.1;
    set(dat,'UData',u);
    set(dat,'VData',v);
end
if strcmp(eventdata.Character,'-')
    dat=findobj('type','Quiver');
    u=dat.UData/1.1;
    v=dat.VData/1.1;
    set(dat,'UData',u);
    set(dat,'VData',v);
end
function switch_menu(hObject,handles)
if strcmp(hObject.Checked,'off')
    handles.size64.Checked = 'off';
    handles.size48.Checked = 'off';
    handles.size32.Checked = 'off';
    handles.size16.Checked = 'off';
    hObject.Checked = 'on';
end

% --------------------------------------------------------------------
function size64_Callback(hObject, ~, handles)
switch_menu(hObject,handles)
setappdata(handles.figure1,'IA_size',64);

% --------------------------------------------------------------------
function size48_Callback(hObject, ~, handles)
switch_menu(hObject,handles)
setappdata(handles.figure1,'IA_size',48);

% --------------------------------------------------------------------
function size32_Callback(hObject, ~, handles)
switch_menu(hObject,handles)
setappdata(handles.figure1,'IA_size',32);


% --------------------------------------------------------------------
function size16_Callback(hObject, ~, handles)
switch_menu(hObject,handles)
setappdata(handles.figure1,'IA_size',16);


% --------------------------------------------------------------------
function perf_fast_Callback(hObject, eventdata, handles)
handles.perf_fast.Checked = 'on';
handles.perf_exhaustive.Checked = 'off';
setappdata(handles.figure1,'fast_performance',1);


% --------------------------------------------------------------------
function perf_exhaustive_Callback(hObject, eventdata, handles)
handles.perf_fast.Checked = 'off';
handles.perf_exhaustive.Checked = 'on';
setappdata(handles.figure1,'fast_performance',0);

% --------------------------------------------------------------------
function disable_auto_Callback(hObject, eventdata, handles)
if strcmp(hObject.Checked,'off')
    handles.disable_auto.Checked = 'on';
    setappdata(handles.figure1,'disable_auto',1);
else
    strcmp(hObject.Checked,'on');
    handles.disable_auto.Checked = 'off';
    setappdata(handles.figure1,'disable_auto',0);
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
IA_size=getappdata(handles.figure1,'IA_size');
fast_performance=getappdata(handles.figure1,'fast_performance');
disable_auto=getappdata(handles.figure1,'disable_auto');
try
    save('quickview_settings.mat','IA_size','fast_performance','disable_auto','-append');
catch
    disp('Could not write settings')
end
delete(hObject);
