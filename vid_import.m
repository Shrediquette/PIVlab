% Video file selection, startframe, endframe and skipping of frames for PIVlab
function vid_import(pathname)
%% Make figure
vidWindow = figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Video import','Toolbar','none','Units','characters','Position',[10 10 80 40],'tag','vid_import','visible','off','resize','on')%,'windowstyle','modal');

%% Initialize
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
guidata(vidWindow,handles)
setappdata(0,'vidWindow',vidWindow);
movegui(vidWindow,'center')
set(vidWindow, 'Visible','on');

margin=1;
parentitem=get(vidWindow, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.selectvideo = uicontrol(vidWindow,'Style','pushbutton','String','Select video file','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@select_Callback, pathname},'Tag','selectvideo','TooltipString','Select video file');

item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1];
handles.text1 = uicontrol(vidWindow,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Start frame: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.startframe = uicontrol(vidWindow,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','1','Tag','startframe');
item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text2 = uicontrol(vidWindow,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','End frame: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.endframe = uicontrol(vidWindow,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','10','Tag','endframe');
item=[0 item(2)+item(4) parentitem(3)/3*2 1];

handles.text3 = uicontrol(vidWindow,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Decimate framerate by: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.skipframe = uicontrol(vidWindow,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','2','Tag','skipframe');
item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1];

handles.text4 = uicontrol(vidWindow,'Style','text','units', 'characters','Horizontalalignment', 'right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Preview frame nr.: ');
item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.previewframe = uicontrol(vidWindow,'Style','edit','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','2','Tag','previewframe');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.previewvideo = uicontrol(vidWindow,'Style','pushbutton','String','Preview video frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preview_Callback,'Tag','previewvideo','TooltipString','Preview video frame','enable','off');


item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.importvideo = uicontrol(vidWindow,'Style','pushbutton','String','Import video frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @import_Callback,'Tag','importvideo','TooltipString','Import video frames','enable','off');

item=[0 item(2)+item(4)+margin parentitem(3) 40];
axes1=axes('units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);
axis image;
set(gca,'ActivePositionProperty','outerposition');%,'Box','off','DataAspectRatioMode','auto','Layer','bottom','Units','normalized');
imagesc(rand(100,100));drawnow


function select_Callback(~,~,pathname)
vidWindow=getappdata(0,'vidWindow');
handles=guihandles(vidWindow);
[filename,pathname] = uigetfile({'*.avi';'*.mp4';'*.mpg';'*.wmv';'*.*'},'Video File Selector',pathname)
if ~isequal(filename,0)
    videoObj = VideoReader(fullfile(pathname,filename));
    if isnan(videoObj.Height)
        fprintf('Failed to create video object.\n');
    else
        setappdata(vidWindow,'videoObj',videoObj);
        frame = read(videoObj,str2num(get(handles.previewframe,'String')));
        imshow(frame)
        set(handles.importvideo,'enable','on')
        set(handles.previewvideo,'enable','on')
        setappdata(vidWindow,'filename',filename);
        setappdata(vidWindow,'pathname',pathname);
        setappdata(vidWindow,'startframe',str2num(get(handles.startframe,'String')));
        setappdata(vidWindow,'endframe',str2num(get(handles.endframe,'string')));
        setappdata(vidWindow,'skipframe',str2num(get(handles.skipframe,'String')));
    end
end

function preview_Callback(~,~,~)

vidWindow=getappdata(0,'vidWindow');
%{
handles=guihandles(vidWindow);
videoObj=getappdata(vidWindow,'videoObj');
frame = read(videoObj,str2num(get(handles.previewframe,'String')));
        imshow(frame)
%}


implay(fullfile(getappdata(vidWindow,'pathname'),getappdata(vidWindow,'filename')))

function import_Callback(~,~,~)
vidWindow=getappdata(0,'vidWindow');
hgui=getappdata(0,'hgui');

    setappdata(hgui,'filename',getappdata(vidWindow,'filename'));
    setappdata(hgui,'pathname',getappdata(vidWindow,'pathname'));
    setappdata(hgui,'startframe',getappdata(vidWindow,'startframe'));
    setappdata(hgui,'endframe',getappdata(vidWindow,'endframe'));
    setappdata(hgui,'skipframe',getappdata(vidWindow,'skipframe'));

close(vidWindow)
disp('import')
