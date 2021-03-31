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

% Last Modified by GUIDE v2.5 05-Mar-2021 20:07:44

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

set(gcf,'numbertitle','off','MenuBar','none','DockControls','off','Toolbar','none','visible','off');
% UIWAIT makes PIVlab_Quickview wait for user response (see UIRESUME)
% uiwait(handles.figure1);
set(handles.axes1,'Visible','off')
set(handles.axes2,'Visible','off')
set(handles.axes3,'Visible','off')
set(handles.axes4,'Visible','off')

setappdata(handles.figure1,'analyzed',0);

if exist('quickview_settings.mat','file')==0
	IA_size=32;fast_performance=1;disable_auto=0;
	save('quickview_settings.mat','IA_size','fast_performance','disable_auto');
	%default
	cmos=11.3;
	lens=50;
	reso=2048;
	FOV=700;
	velo=2;
	pulse=100;
	int=32;
	save ('quickview_settings.mat','cmos','lens','reso','FOV','velo','pulse','int','-append');
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
movegui('center');
set(gcf,'visible','on')
axes(handles.axes5)
imshow(imread('pivlab_logo1.jpg'),'parent',handles.axes5);
set(handles.axes5,'Position',[0.1,0.1,0.8,0.8],'xtick',[],'ytick',[])
set(handles.axes5,'Visible','on')
if verLessThan('matlab','9.5')
	disp('ERROR: PIVlab Quickview will only work for Matlab R2018b and later.')
	disp('Please use the normal PIVlab_GUI.m !')
end


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
if ~isequal(file,0)
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
	setappdata(handles.figure1,'analyzed',0);
	if iscell(file) %two selected files
		display_images(file, path,handles,0);
	else
		[~,~,suffix] = fileparts(file);
		direc=dir ([path '\*' suffix]);
		[filenames{1:length(direc),1}] = deal(direc.name);
		filenames = sortrows(filenames);
		for ijk = 1: size(filenames,1)
			if strcmp (filenames{ijk}, file) ==1
				file2=filenames{ijk+1};
			end
		end
		file={file,file2};
		display_images(file, path,handles,0);
	end
else
	disp('Please select 1 or 2 images')
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
	[x, y, u, v, ~,correlation_map] = piv_FFTmulti (image1,image2,IA_size*2,IA_size,1,[],roi.Position,2,IA_size,16,16,performance_settings1,performance_settings2,getappdata(handles.figure1,'disable_auto'),performance_settings3); %actual PIV analysis    axes(handles.axes2)
	[u,v] = PIVlab_postproc (u,v,1,1, [], 1,7, 1,3);
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
	set(gca,'yticklabel',[])
	set(gca,'YScale','log')
	grid on
	xlim([mean(magn(:),'omitnan') -  3*std(magn(:),'omitnan') , mean(magn(:),'omitnan') +  3*std(magn(:),'omitnan')])
	axes(handles.axes4)
	imagesc(correlation_map);colormap(handles.axes4,'parula')
	xticks([])
	yticks([])
	colorbar('West')
	setappdata(handles.figure1,'analyzed',1);
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
	if ~isempty(img_size)
		setappdata(handles.figure1,'roi_size',[1 1 ,img_size(2)-1,img_size(1)-1]);
		file=getappdata(handles.figure1,'file');
		path=getappdata(handles.figure1,'path');
		display_images(file, path,handles,1)
	end
end
if strcmp(eventdata.Character,'+')
	if getappdata(handles.figure1,'analyzed') == 1
		dat=findobj('type','Quiver');
		u=dat.UData*1.1;
		v=dat.VData*1.1;
		set(dat,'UData',u);
		set(dat,'VData',v);
	end
end
if strcmp(eventdata.Character,'-')
	if getappdata(handles.figure1,'analyzed') == 1
		dat=findobj('type','Quiver');
		u=dat.UData/1.1;
		v=dat.VData/1.1;
		set(dat,'UData',u);
		set(dat,'VData',v);
	end
end
if strcmp(eventdata.Character,'a')
	if getappdata(handles.figure1,'analyzed') == 1
		dat=findobj('type','Quiver');
		u=dat.UData;
		v=dat.VData;
		umean=mean(u(:),'omitnan');
		vmean=mean(v(:),'omitnan');
		set(dat,'UData',u-umean);
		set(dat,'VData',v-vmean);
	end
end
if strcmp(eventdata.Character,'c')
	calc_GUI
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

function calc_GUI
% Open a small GUI for calculating PIV parameters
f = figure('units','characters','Position',[1,1,45,20],'MenuBar','none', 'Toolbar','none', 'Units','characters', 'Name','PIV calc','numbertitle','off','Visible','off','Windowstyle','normal','resize','off','dockcontrol','off');
movegui(f,'center')
set(f,'units','characters');
figsize=get(f,'position');
textwidth=26;
inputwidth=10;
inputheight=1;
margin=0.25;
try %load previous settings
	load ('quickview_settings.mat','cmos','lens','reso','FOV','velo','pulse','int');
catch
	cmos=0;lens=0;reso=0;FOV=0;velo=0;pulse=0;int=0;
end
cmos_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','Chip width in mm','Position',[margin,figsize(4)-inputheight-margin,textwidth,inputheight],'tag','cmos_text');
cmos_edit  = uicontrol('Style','edit','units','characters','String',num2str(cmos),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','cmos_edit');
lens_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','Focal length in mm','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*1,textwidth,inputheight],'tag','lens_text');
lens_edit  = uicontrol('Style','edit','units','characters','String',num2str(lens),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*1,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','lens_edit');
reso_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','Camera x resolution in mm','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*2,textwidth,inputheight],'tag','reso_text');
reso_edit  = uicontrol('Style','edit','units','characters','String',num2str(reso),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*2,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','reso_edit');
FOV_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','FOV width in mm','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*3,textwidth,inputheight],'tag','FOV_text');
FOV_edit  = uicontrol('Style','edit','units','characters','String',num2str(FOV),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*3,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','FOV_edit');
velo_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','Velocity in m/s','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*4,textwidth,inputheight],'tag','velo_text');
velo_edit  = uicontrol('Style','edit','units','characters','String',num2str(velo),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*4,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','velo_edit');
pulse_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','Pulse separation in µs','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*5,textwidth,inputheight],'tag','pulse_text');
pulse_edit  = uicontrol('Style','edit','units','characters','String',num2str(pulse),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*5,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','pulse_edit');
int_text  = uicontrol('Style','text','units','characters','horizontalalignment','right','String','Final interrogation area in px','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*6,textwidth,inputheight],'tag','int_text');
int_edit  = uicontrol('Style','edit','units','characters','String',num2str(int),'Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*6,inputwidth,inputheight],'Callback',@update_calc_fields,'tag','int_edit');
working_text  = uicontrol('fontweight','bold','Style','text','units','characters','horizontalalignment','right','String','Working distance in m','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*7,textwidth,inputheight],'tag','working_text');
working_out  = uicontrol('fontweight','bold','Style','text','units','characters','String','32','Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*7,inputwidth,inputheight],'tag','working_out');
displace_text  = uicontrol('fontweight','bold','Style','text','units','characters','horizontalalignment','right','String','Displacement in px','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*8,textwidth,inputheight],'tag','displace_text');
displace_out  = uicontrol('fontweight','bold','Style','text','units','characters','String','32','Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*8,inputwidth,inputheight],'tag','displace_out');
spacing_text  = uicontrol('fontweight','bold','Style','text','units','characters','horizontalalignment','right','String','Vector spacing in mm','Position',[margin,figsize(4)-inputheight-margin-(margin+inputheight)*9,textwidth,inputheight],'tag','spacing_text');
spacing_out  = uicontrol('fontweight','bold','Style','text','units','characters','String','32','Position',[3+margin+textwidth+margin,figsize(4)-inputheight-margin-(margin+inputheight)*9,inputwidth,inputheight],'tag','spacing_out');
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
guidata(f,handles)
setappdata(0,'calchandle',f);
update_calc_fields
set(f,'visible','on');

function update_calc_fields(~,~)
getappdata(0,'calchandle');
handles=guihandles(getappdata(0,'calchandle'));
cmos=str2num(get(handles.cmos_edit,'string'));
lens=str2num(get(handles.lens_edit,'string'));
reso=str2num(get(handles.reso_edit,'string'));
FOV=str2num(get(handles.FOV_edit,'string'));
velo=str2num(get(handles.velo_edit,'string'));
pulse=str2num(get(handles.pulse_edit,'string'));
int=str2num(get(handles.int_edit,'string'));
save ('quickview_settings.mat','cmos','lens','reso','FOV','velo','pulse','int','-append');

working=((lens/1000)*(FOV/1000))/(cmos/1000);
displace=velo*pulse/1000*(reso/FOV);
spacing=FOV/(reso/(int/2));

set(handles.working_out,'String',num2str(round(working,1)))
set(handles.displace_out,'String',num2str(round(displace,1)))
set(handles.spacing_out,'String',num2str(round(spacing,1)))

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(~, ~, ~)
