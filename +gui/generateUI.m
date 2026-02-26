function generateUI % All the GUI elements are created here
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
MainWindow=getappdata(0,'hgui');
guidata(MainWindow,handles)

panelwidth=gui.retr('panelwidth');
margin=gui.retr('margin');
panelheighttools=gui.retr('panelheighttools');
panelheightpanels=gui.retr('panelheightpanels');
Figure_Size = get(MainWindow, 'Position');

%% Toolspanel
handles.tools = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-panelheighttools-margin panelwidth panelheighttools],'title','Tools', 'Tag','tools','fontweight','bold');
parentitem=get(handles.tools, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text29 = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Current point:');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.u_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','u_cp');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.v_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','v_cp');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.x_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','x_cp');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.y_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','y_cp');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.scalar_cp = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','scalar_cp');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.filenameshow = uicontrol(handles.tools,'Style','text','units', 'characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','filenameshow');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.fileselector = uicontrol(handles.tools,'Style','slider','units', 'characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'max',4,'min',1,'value',1,'sliderstep',[0.5 1],'Callback',@gui.fileselector_Callback,'tag','fileselector','TooltipString','Step through your frames here','interruptible','off','BusyAction','cancel');%,'Interruptible','off','busyaction','cancel');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.togglepair = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], 'string','Toggle','Callback',@gui.togglepair_Callback,'tag','togglepair','TooltipString','Toggle images within a frame','interruptible','off','BusyAction','cancel');%,'Interruptible','off','busyaction','cancel');

item=[0  item(2)+item(4)+margin*0.2 parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.toggle_parallel = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@misc.toggle_parallel_Callback,'tag','toggle_parallel');

item=[parentitem(3)/2 item(2) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.zoomon = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@gui.zoomon_Callback,'tag','zoomon','TooltipString','Zoom');

item=[parentitem(3)/2+parentitem(3)/2/2 item(2) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.panon = uicontrol(handles.tools,'Style','togglebutton','units', 'characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@gui.panon_Callback,'tag','panon','TooltipString','Pan');

load (fullfile('images','icons.mat'))
if gui.retr('darkmode')
    zoompic=1-zoompic+35/255;
    panpic=1-panpic+35/255;
    zoompic(zoompic>1)=1;
    panpic(panpic>1)=1;
end
set(handles.zoomon, 'cdata',zoompic);
set(handles.panon, 'cdata',panpic);

%% Quick access
iconwidth=5;
iconheight=2;
iconamount=6;
quickwidth = gui.retr('quickwidth')-iconwidth-0.5-0.25;
quickheight = gui.retr('quickheight');

handles.quick = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin*0.5 0+margin*0.5+panelheighttools+quickheight quickwidth quickheight],'title','Main tasks quick access', 'Tag','quick','fontweight','bold','Visible','on');
handles.quick1 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[1*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@gui.quick1_Callback,'tag','quick1','TooltipString','Load images');
handles.quick2 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[2*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@gui.quick2_Callback,'tag','quick2','TooltipString','Mask generation');
handles.quick3 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[3*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@gui.quick3_Callback,'tag','quick3','TooltipString','Pre-processing');
handles.quick4 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[4*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@gui.quick4_Callback,'tag','quick4','TooltipString','PIV settings');
handles.quick5 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[5*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@gui.quick5_Callback,'tag','quick5','TooltipString','Analyze');
handles.quick6 = uicontrol(handles.quick,'Style','togglebutton','units', 'characters','position',[6*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight],'Callback',@gui.quick6_Callback,'tag','quick6','TooltipString','Calibrate');

load (fullfile('images','icons_quick.mat'))
if gui.retr('darkmode')
    loadpic=255-loadpic+35;
    maskpic=255-maskpic+35;
    prepic=255-prepic+35;
    settpic=255-settpic+35;
    anapic=255-anapic+35;
    calpic=255-calpic+35;
end
set(handles.quick1, 'cdata',loadpic);
set(handles.quick2, 'cdata',maskpic);
set(handles.quick3, 'cdata',prepic);
set(handles.quick4, 'cdata',settpic);
set(handles.quick5, 'cdata',anapic);
set(handles.quick6, 'cdata',calpic);

%% Progress info / progress bar
handles.toolprogress = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight],'title','Progress', 'Tag','toolprogress','fontweight','bold','Visible','on');
parentitem=get(handles.toolprogress, 'Position');
item=[margin 0.4 parentitem(3) 1];
handles.toolprogress_bg = uicontrol(handles.toolprogress,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','BackgroundColor',[0.85 0.85 0.85],'Tag','toolprogress_bg','Enable','off');
handles.toolprogress_fg = uicontrol(handles.toolprogress,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) 0 item(4)],'String','','BackgroundColor','g','Tag','toolprogress_fg','Enable','off');
gui.put('handle_toolprogress_bg',handles.toolprogress_bg); %for faster access in update loop
gui.put('handle_toolprogress_fg',handles.toolprogress_fg);


%% Multip01
handles.multip01 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Input data (CTRL+N)', 'Tag','multip01','fontweight','bold');
parentitem=get(handles.multip01, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.loadimgsbutton = uicontrol(handles.multip01,'Style','pushbutton','String','Import images','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@import.loadimgsbutton_Callback,1,[]},'Tag','loadimgsbutton','TooltipString','Load image data');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.loadvideobutton = uicontrol(handles.multip01,'Style','pushbutton','String','Import video','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @import.loadvideobutton_Callback,'Tag','loadvideobutton','TooltipString','Load video file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.loadsessionbutton = uicontrol(handles.multip01,'Style','pushbutton','String','Load session','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @import.load_session_Callback,'Tag','loadsessionbutton','TooltipString','Load previously saved session file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.acquirebutton = uicontrol(handles.multip01,'Style','pushbutton','String','Acquire images','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.capture_images_Callback,'Tag','acquirebutton','TooltipString','Acquire PIV images in PIVlab');

item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 1];
handles.text2 = uicontrol(handles.multip01,'Style','text','units', 'characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Image list:');

PIVver=gui.retr('PIVver');
item=[0 item(2)+item(4) parentitem(3) 12];
handles.filenamebox = uicontrol(handles.multip01,'Style','ListBox','max',3,'min',1,'units','characters','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String',{['Welcome to PIVlab ' PIVver '.'] 'Add images by clicking the' '"Import images" button above.'},'Callback',@gui.filenamebox_Callback,'tag','filenamebox','TooltipString','This list displays the frames that you currently loaded');
gui.put('standard_bg_color',get(handles.filenamebox,'Backgroundcolor'));

item=[0 item(2)+item(4)+margin/8 parentitem(3)/3*2 2];
handles.remove_imgs = uicontrol(handles.multip01,'Style','pushbutton','String','Remove images','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @import.remove_images_from_list,'Tag','remove_imgs','TooltipString','Remove images from the image list','enable','off');

item=[0 item(2)+item(4)+0.4 parentitem(3) 3];
handles.text4 = uicontrol(handles.multip01,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Use the scrollbar in the "Tools" panel to cycle through the images.');

item=[0 item(2)+item(4) parentitem(3) 4];
handles.imsize = uicontrol(handles.multip01,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','imsize');

%% Multip02
handles.multip02 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Exclusions (CTRL+E)', 'Tag','multip02','fontweight','bold');
parentitem=get(handles.multip02, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 12];
handles.uipanel5 = uipanel(handles.multip02, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Region of interest', 'Tag','uipanel5','fontweight','bold');

parentitem=get(handles.uipanel5, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.roi_hint = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','ROI inactive','tag','roi_hint');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
handles.roi_select = uicontrol(handles.uipanel5,'Style','pushbutton','String','Select ROI','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @roi.select_Callback,'Tag','roi_select','TooltipString','Draw a rectangle for selecting a region of interest');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_roi = uicontrol(handles.uipanel5,'Style','pushbutton','String','Clear ROI','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @roi.clear_roi_Callback,'Tag','clear_roi','TooltipString','Remove the ROI');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/4 1.5];
handles.text155 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','x:');

item=[parentitem(3)/4 item(2) parentitem(3)/4 1.5];
handles.text156 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','y:');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4 1.5];
handles.text157 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','width:');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1.5];
handles.text158 = uicontrol(handles.uipanel5,'Style','text','units','characters','Horizontalalignment', 'left','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','height:');

item=[parentitem(3)/4*0+margin item(2)+item(4) parentitem(3)/4 1.5];
handles.ROI_Man_x = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_x','Callback',@roi.Man_ROI_Callback);

item=[parentitem(3)/4*1+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_y = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_y','Callback',@roi.Man_ROI_Callback);

item=[parentitem(3)/4*2+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_w = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_w','Callback',@roi.Man_ROI_Callback);

item=[parentitem(3)/4*3+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_h = uicontrol(handles.uipanel5,'Style','edit','units','characters','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ROI_Man_h','Callback',@roi.Man_ROI_Callback);


%% Multip25 (new mask)
handles.multip25 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image masking', 'Tag','multip25','fontweight','bold');
parentitem=get(handles.multip25, 'Position');
item=[0 0 0 0];


%Edit or preview mode
item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.text252 = uicontrol(handles.multip25,'Style','text','String','Mode:','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text252');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_edit_mode = uicontrol(handles.multip25,'Style','popupmenu','String',{'Edit mask','Preview mask'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','mask_edit_mode','Callback',@mask.edit_mode_Callback, 'TooltipString','Switch between mask edit mode and mask preview mode');


%basic or expert mask capabilities
item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 1.5];
handles.text251 = uicontrol(handles.multip25,'Style','text','String','Capabilities:','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text251');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_basic_expert = uicontrol(handles.multip25,'Style','popupmenu','String',{'Basic','Expert'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','mask_basic_expert','Callback',@mask.basic_expert_Callback, 'TooltipString','Switch betwenn basic mask generation and advanced mask generation modes');

%panel Polygon mask items
item=[0 item(2)+item(4)+margin/8 parentitem(3) 8];
handles.uipanel25_1 = uipanel(handles.multip25, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Polygon mask items', 'Tag','uipanel25_1','fontweight','bold');

parentitem=get(handles.uipanel25_1, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_add_freehand = uicontrol(handles.uipanel25_1,'Style','pushbutton','String','Free hand','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@mask.add_Callback,'freehand'},'Tag','mask_add_freehand','TooltipString','Add a freehand mask');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_add_assisted = uicontrol(handles.uipanel25_1,'Style','pushbutton','String','Assisted f.h.','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@mask.add_Callback,'assisted'},'Tag','mask_add_freehand','TooltipString','Add an assisted freehand mask');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_add_circle = uicontrol(handles.uipanel25_1,'Style','pushbutton','String','Circle','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@mask.add_Callback,'circle'},'Tag','mask_add_circle','TooltipString','Add a circular mask');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_add_rectangle = uicontrol(handles.uipanel25_1,'Style','pushbutton','String','Rectangle','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@mask.add_Callback,'rectangle'},'Tag','mask_add_rectangle','TooltipString','Add a rectangular mask');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_add_polygon = uicontrol(handles.uipanel25_1,'Style','pushbutton','String','Polygon','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', {@mask.add_Callback,'polygon'},'Tag','mask_add_polygon','TooltipString','Add a polygon mask');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.mask_import = uicontrol(handles.uipanel25_1,'Style','pushbutton','String','Import pixel mask','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.import_Callback,'Tag','mask_import','TooltipString','Import a user generated mask from a binary image file');

%panel expert mask

parentitem=get(handles.multip25, 'Position');

item=[0 3.75 parentitem(3) 23.25];
handles.uipanel25_2 = uipanel(handles.multip25, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Generate masks from PIV images', 'Tag','uipanel25_2','fontweight','bold','Visible','off');
item=[0 0 0 0];
parentitem=get(handles.uipanel25_2, 'Position');


item=[0 0 parentitem(3) 1.5];
handles.mask_bright_or_dark = uicontrol(handles.uipanel25_2,'Style','popupmenu','String',{'Bright area mask generator','Dark area mask generator','Low contrast area mask generator', 'Custom script (coming soon)'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','mask_bright_or_dark','Callback',@mask.bright_or_dark_Callback, 'TooltipString','Select different automatic mask generators here');


%% bright area mask generator
item=[0 1.5+margin/2 parentitem(3) 14];
handles.uipanel25_3 = uipanel(handles.uipanel25_2, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Bright area mask generator', 'Tag','uipanel25_3','fontweight','bold','Visible','on');
item=[0 0 0 0];
parentitem=get(handles.uipanel25_3, 'Position');

checkbox_width = parentitem(3)/10*1;
filter_text_width=parentitem(3)/10*4;
size_text_width=parentitem(3)/10*3;
size_width=parentitem(3)/10*1.5;

%binarize
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.binarize_enable = uicontrol(handles.uipanel25_3,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Callback',@mask.binarize_enable_Callback,'Tag','binarize_enable','TooltipString','Enable this mask generator');

item=[checkbox_width item(2) filter_text_width 1];
handles.binarize_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Enable','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','binarize_text');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.binarize_threshold_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Threshold:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','binarize_threshold_text');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.binarize_threshold = uicontrol(handles.uipanel25_3,'Style','edit', 'String','0.8','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','binarize_threshold','TooltipString','Image binarization threshold');


%medfilt
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_medfilt_enable = uicontrol(handles.uipanel25_3,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_medfilt_enable','TooltipString','Use a median filter to smooth the input to the binarization');

item=[checkbox_width item(2) filter_text_width 1];
handles.median_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Median filter','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_text');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.median_size_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_size_text');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.median_size = uicontrol(handles.uipanel25_3,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_size','TooltipString','Size of the median kernel');



%Imopen/imclose
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imopen_imclose_enable = uicontrol(handles.uipanel25_3,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_imopen_imclose_enable','TooltipString','Enable morphological opening or closing of image');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imopen_text = uicontrol(handles.uipanel25_2,'Style','text', 'String','imopen','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_text');
handles.imopen_imclose_selection = uicontrol(handles.uipanel25_3,'Style','popupmenu', 'String',{'Morphologically open image','Morphologically close image'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_selection','TooltipString','Select morphological open or close');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imopen_imclose_size_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_size_text');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imopen_imclose_size = uicontrol(handles.uipanel25_3,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_size','TooltipString','Size of the structuring element');



%imdilate/imerode
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imdilate_imerode_enable = uicontrol(handles.uipanel25_3,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_imdilate_imerode_enable','TooltipString','Enable image dilation or image erosion');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imclose_text = uicontrol(handles.uipanel25_2,'Style','text', 'String','imclose','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imclose_text');
handles.imdilate_imerode_selection = uicontrol(handles.uipanel25_3,'Style','popupmenu', 'String',{'Dilate image','Erode image'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_selection','TooltipString','Choose between erosion or dilation');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imdilate_imerode_size_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_size_text');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imdilate_imerode_size = uicontrol(handles.uipanel25_3,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_size','TooltipString','Size of the structuring element');



%remove small
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_remove_enable = uicontrol(handles.uipanel25_3,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_remove_enable','TooltipString','Enable the removal of small blobs');

item=[checkbox_width item(2) filter_text_width 1];
handles.remove_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Remove blots','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_text');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.remove_size_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_size_text');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.remove_size = uicontrol(handles.uipanel25_3,'Style','edit', 'String','1000','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_size','TooltipString','Maximum area (in px) of the blobs to be removed');

%fillholes
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_fill_enable = uicontrol(handles.uipanel25_3,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_fill_enable','TooltipString','Enable hole filling');

item=[checkbox_width item(2) filter_text_width 1];
handles.fill_text = uicontrol(handles.uipanel25_3,'Style','text', 'String','Fill holes','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','fill_text');

mask.binarize_enable_Callback

%% dark area mask generator
parentitem=get(handles.uipanel25_2, 'Position');
item=[0 1.5+margin/2 parentitem(3) 14];
handles.uipanel25_5 = uipanel(handles.uipanel25_2, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Dark area mask generator', 'Tag','uipanel25_5','fontweight','bold','Visible','off');
item=[0 0 0 0];

parentitem=get(handles.uipanel25_5, 'Position');

%binarize
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.binarize_enable_2 = uicontrol(handles.uipanel25_5,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Callback',@mask.binarize_enable_2_Callback,'Tag','binarize_enable_2','TooltipString','Enable this mask generator');

item=[checkbox_width item(2) filter_text_width 1];
handles.binarize_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Enable','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','binarize_text_2');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.binarize_threshold_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Threshold:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','binarize_threshold_text_2');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.binarize_threshold_2 = uicontrol(handles.uipanel25_5,'Style','edit', 'String','0.01','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','binarize_threshold_2','TooltipString','Image binarization threshold');

%medfilt
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_medfilt_enable_2 = uicontrol(handles.uipanel25_5,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_medfilt_enable_2','TooltipString','Use a median filter to smooth the input to the binarization');

item=[checkbox_width item(2) filter_text_width 1];
handles.median_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Median filter','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_text_2');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.median_size_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_size_text_2');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.median_size_2 = uicontrol(handles.uipanel25_5,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_size_2','TooltipString','Size of the median kernel');


%Imopen/imclose
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imopen_imclose_enable_2 = uicontrol(handles.uipanel25_5,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_imopen_imclose_enable_2','TooltipString','Enable morphological opening or closing of image');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imopen_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imopen','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_text_2');
handles.imopen_imclose_selection_2 = uicontrol(handles.uipanel25_5,'Style','popupmenu', 'String',{'Morphologically open image','Morphologically close image'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_selection_2','TooltipString','Select morphological open or close');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imopen_imclose_size_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_size_text_2');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imopen_imclose_size_2 = uicontrol(handles.uipanel25_5,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_size_2','TooltipString','Size of the structuring element');

%imdilate/imerode
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imdilate_imerode_enable_2 = uicontrol(handles.uipanel25_5,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_imdilate_imerode_enable_2','TooltipString','Enable image dilation or image erosion');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imclose_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imclose','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imclose_text_2');
handles.imdilate_imerode_selection_2 = uicontrol(handles.uipanel25_5,'Style','popupmenu', 'String',{'Dilate image','Erode image'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_selection_2','TooltipString','Choose between erosion or dilation');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imdilate_imerode_size_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_size_text_2');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imdilate_imerode_size_2 = uicontrol(handles.uipanel25_5,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_size_2','TooltipString','Size of the structuring element');

%remove small
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_remove_enable_2 = uicontrol(handles.uipanel25_5,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_remove_enable_2','TooltipString','Enable the removal of small blobs');

item=[checkbox_width item(2) filter_text_width 1];
handles.remove_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Remove blots','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_text_2');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.remove_size_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_size_text_2');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.remove_size_2 = uicontrol(handles.uipanel25_5,'Style','edit', 'String','1000','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_size_2','TooltipString','Maximum area (in px) of the blobs to be removed');

%fillholes
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_fill_enable_2 = uicontrol(handles.uipanel25_5,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_fill_enable_2','TooltipString','Enable hole filling');

item=[checkbox_width item(2) filter_text_width 1];
handles.fill_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','Fill holes','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','fill_text_2');



%% low contrast mask generator
parentitem=get(handles.uipanel25_2, 'Position');
item=[0 1.5+margin/2 parentitem(3) 14];
handles.uipanel25_7 = uipanel(handles.uipanel25_2, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Low contrast mask generator', 'Tag','uipanel25_7','fontweight','bold','Visible','off');
item=[0 0 0 0];

parentitem=get(handles.uipanel25_7, 'Position');

%low contrast
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.low_contrast_mask_enable = uicontrol(handles.uipanel25_7,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Callback',@mask.low_contrast_mask_enable_Callback,'Tag','low_contrast_mask_enable','TooltipString','Enable this mask generator');

item=[checkbox_width item(2) filter_text_width-3 1];
handles.low_contrast_mask_text = uicontrol(handles.uipanel25_7,'Style','text', 'String','Enable','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','low_contrast_mask_text');

item=[checkbox_width+filter_text_width-3 item(2) size_text_width 1];
handles.low_contrast_mask_text_2 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Threshold:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','low_contrast_mask_text');

item=[checkbox_width+filter_text_width-3+size_text_width item(2) size_width+3 1];
handles.low_contrast_mask_threshold = uicontrol(handles.uipanel25_7,'Style','edit', 'String','0.01','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','low_contrast_mask_threshold','TooltipString','Image binarization threshold');

item=[parentitem(3)/3  item(2)+item(4)+margin/8 parentitem(3)/3*2 1.5];
handles.low_contrast_mask_threshold_suggest = uicontrol(handles.uipanel25_7,'Style','pushbutton','String','Suggest threshold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.low_contrast_threshold_suggest_Callback,'Tag','low_contrast_mask_threshold_suggest','TooltipString','Suggest a suitable starting point for the threshold');


%medfilt
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_medfilt_enable_3 = uicontrol(handles.uipanel25_7,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_medfilt_enable_3','TooltipString','Use a median filter to smooth the input to the binarization');

item=[checkbox_width item(2) filter_text_width 1];
handles.median_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Median filter','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_text_3');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.median_size_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_size_text_3');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.median_size_3 = uicontrol(handles.uipanel25_7,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','median_size_3','TooltipString','Size of the median kernel');


%Imopen/imclose
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imopen_imclose_enable_3 = uicontrol(handles.uipanel25_7,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_imopen_imclose_enable_3','TooltipString','Enable morphological opening or closing of image');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imopen_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imopen','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_text_2');
handles.imopen_imclose_selection_3 = uicontrol(handles.uipanel25_7,'Style','popupmenu', 'String',{'Morphologically open image','Morphologically close image'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_selection_3','TooltipString','Select morphological open or close');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imopen_imclose_size_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_size_text_3');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imopen_imclose_size_3 = uicontrol(handles.uipanel25_7,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imopen_imclose_size_3','TooltipString','Size of the structuring element');

%imdilate/imerode
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imdilate_imerode_enable_3 = uicontrol(handles.uipanel25_7,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_imdilate_imerode_enable_3','TooltipString','Enable image dilation or image erosion');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imclose_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imclose','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imclose_text_2');
handles.imdilate_imerode_selection_3 = uicontrol(handles.uipanel25_7,'Style','popupmenu', 'String',{'Dilate image','Erode image'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_selection_3','TooltipString','Choose between erosion or dilation');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imdilate_imerode_size_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_size_text_3');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imdilate_imerode_size_3 = uicontrol(handles.uipanel25_7,'Style','edit', 'String','5','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','imdilate_imerode_size_3','TooltipString','Size of the structuring element');

%remove small
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_remove_enable_3 = uicontrol(handles.uipanel25_7,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_remove_enable_3','TooltipString','Enable the removal of small blobs');

item=[checkbox_width item(2) filter_text_width 1];
handles.remove_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Remove blots','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_text_3');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.remove_size_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Size:','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_size_text_3');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.remove_size_3 = uicontrol(handles.uipanel25_7,'Style','edit', 'String','1000','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','remove_size_3','TooltipString','Maximum area (in px) of the blobs to be removed');

%fillholes
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_fill_enable_3 = uicontrol(handles.uipanel25_7,'Style','checkbox', 'value',0, 'String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','mask_fill_enable_3','TooltipString','Enable hole filling');

item=[checkbox_width item(2) filter_text_width 1];
handles.fill_text_3 = uicontrol(handles.uipanel25_7,'Style','text', 'String','Fill holes','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)],'Tag','fill_text_3');


%% mask operations apply etc

parentitem=get(handles.uipanel25_2, 'Position');

item=[0 16.5 parentitem(3) 1.5];
handles.automask_preview = uicontrol(handles.uipanel25_2,'Style','pushbutton','String','Preview current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.automask_preview_Callback,'Tag','automask_preview','TooltipString','Preview the automatically generated mask');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.automask_generate_current = uicontrol(handles.uipanel25_2,'Style','pushbutton','String','Make mask for current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.automask_generate_current_Callback,'Tag','automask_generate_current','TooltipString','Automatic generation of a mask for the current frame');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.automask_generate_all = uicontrol(handles.uipanel25_2,'Style','pushbutton','String','Make mask for all frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.automask_generate_all_Callback,'Tag','automask_generate_all','TooltipString','Automatic generation of a mask for all frames');


%panel image display options
parentitem=get(handles.multip25, 'Position');
item=[0 12 parentitem(3) 5];
handles.uipanel25_10 = uipanel(handles.multip25, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Image display options', 'Tag','uipanel25_10','fontweight','bold');

parentitem=get(handles.uipanel25_10, 'Position');
item=[0 0 parentitem(3)/2 1.5];
handles.mask_display_brighter = uicontrol(handles.uipanel25_10,'Style','pushbutton','String','Brighter','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.display_brighter_darker_Callback,'Tag','mask_display_brighter','TooltipString','increase brightness');

item=[parentitem(3)/2 0 parentitem(3)/2 1.5];
handles.mask_display_darker = uicontrol(handles.uipanel25_10,'Style','pushbutton','String','Darker','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.display_brighter_darker_Callback,'Tag','mask_display_darker','TooltipString','decrease brightness');

item=[0 0+item(4) parentitem(3)/2 1.5];
handles.mask_display_average = uicontrol(handles.uipanel25_10,'Style','pushbutton','String','Display average','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.display_average_Callback,'Tag','mask_display_average','TooltipString','Show the mean image');


%panel mask modifications
parentitem=get(handles.multip25, 'Position');
item=[0 18 parentitem(3) 6.5];
handles.uipanel25_9 = uipanel(handles.multip25, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Mask modifications', 'Tag','uipanel25_9','fontweight','bold');

parentitem=get(handles.uipanel25_9, 'Position');
item=[0 0 parentitem(3)/2 1.5];
handles.mask_shrink = uicontrol(handles.uipanel25_9,'Style','pushbutton','String','Shrink mask','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.shrink_grow_Callback,'Tag','mask_shrink','TooltipString','Shrink the currently selected mask');

item=[0+item(3) item(2) parentitem(3)/2 1.5];
handles.mask_grow = uicontrol(handles.uipanel25_9,'Style','pushbutton','String','Grow mask','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.shrink_grow_Callback,'Tag','mask_grow','TooltipString','Enlarge the currently selected mask');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_simplify = uicontrol(handles.uipanel25_9,'Style','pushbutton','String','Simplify','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.subdivide_simplify_Callback,'Tag','mask_simplify','TooltipString','Simplify the currently selected mask');



item=[0+item(3) item(2) parentitem(3)/2 1.5];
handles.mask_subdivide = uicontrol(handles.uipanel25_9,'Style','pushbutton','String','Subdivide','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.subdivide_simplify_Callback,'Tag','mask_subdivide','TooltipString','Subdivide the currently selected mask');


item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_optimize = uicontrol(handles.uipanel25_9,'Style','pushbutton','String','Optimize','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.subdivide_simplify_Callback,'Tag','mask_optimize','TooltipString','Optimize the waypoints of the currently selected mask');


item=[0+item(3) item(2) parentitem(3)/2 1.5];
handles.mask_combine = uicontrol(handles.uipanel25_9,'Style','pushbutton','String','Combine','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.combine_Callback,'Tag','mask_combine','TooltipString','Combine all overlapping masks of the current frame');



%panel mask operations
item=[0 0 0 0];
parentitem=get(handles.multip25, 'Position');
item=[0 27 parentitem(3) 6.5];
handles.uipanel25_6 = uipanel(handles.multip25, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Mask operations', 'Tag','uipanel25_6','fontweight','bold');

item=[0 0 0 0];
parentitem=get(handles.uipanel25_6, 'Position');
item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.mask_apply_to_current = uicontrol(handles.uipanel25_6,'Style','pushbutton','String','Copy mask to all frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.copy_to_all_Callback,'Tag','mask_apply_to_current','TooltipString','Apply masks from current frame to all frames');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.mask_delete_all = uicontrol(handles.uipanel25_6,'Style','pushbutton','String','Clear all masks','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.delete_all_Callback,'Tag','mask_delete_all','TooltipString','Delete all masks');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_save = uicontrol(handles.uipanel25_6,'Style','pushbutton','String','Save all masks','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.save_Callback,'Tag','mask_save','TooltipString','Save all masks to Matlab file for reuse');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_load = uicontrol(handles.uipanel25_6,'Style','pushbutton','String','Load mask(s)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.load_Callback,'Tag','mask_load','TooltipString','Load masks that were previously created in PIVlab');


%% Multip03
handles.multip03 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image pre-processing (CTRL+I)', 'Tag','multip03','fontweight','bold');
parentitem=get(handles.multip03, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.clahe_enable = uicontrol(handles.multip03,'Style','checkbox', 'value',1, 'String','Enable CLAHE','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','clahe_enable','TooltipString','Contrast limited adaptive histogram equalization: Enhances contrast, should be enabled');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text8 = uicontrol(handles.multip03,'Style','text', 'String','Window size [px]','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text8');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.clahe_size = uicontrol(handles.multip03,'Style','edit', 'String','64','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','clahe_size','TooltipString','Size of the tiles for CLAHE. Default setting is fine in most cases');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.enable_highpass = uicontrol(handles.multip03,'Style','checkbox', 'value',0, 'String','Enable highpass','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','enable_highpass','TooltipString','Highpass the image data. Only needed for some special cases');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text9 = uicontrol(handles.multip03,'Style','text', 'String','Kernel size [px]','Units','characters','HorizontalAlignment','right', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text9');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.highp_size = uicontrol(handles.multip03,'Style','edit', 'String','15','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','highp_size','TooltipString','Kernel size of the lowpass filtered image that is subtracted from the original image');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.enable_intenscap = uicontrol(handles.multip03,'Style','checkbox', 'value',0, 'String','Enable intensity capping','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','enable_intenscap','TooltipString','Intensity capping. Only needed for some special cases');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.wienerwurst = uicontrol(handles.multip03,'Style','checkbox', 'value',0, 'String','Wiener2 denoise and low pass','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','wienerwurst','TooltipString','Wiener denoise filter and Gaussian low pass. Only needed for some special cases');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text159 = uicontrol(handles.multip03,'Style','text', 'String','Window size [px]','HorizontalAlignment','right','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text159');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.wienerwurstsize = uicontrol(handles.multip03,'Style','edit', 'String','15','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','wienerwurstsize','TooltipString','Window size of the Wiener denoise filter');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1.1];
handles.Autolimit = uicontrol(handles.multip03,'Style','checkbox', 'value',1, 'String','Auto contrast stretch','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','Autolimit','TooltipString','Automatic stretching of the image intensity histogram. Important for 16-bit images.');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.text162 = uicontrol(handles.multip03,'Style','text', 'String','minimum:','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text162');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text163 = uicontrol(handles.multip03,'Style','text', 'String','maximum:','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text163');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.minintens = uicontrol(handles.multip03,'Style','edit', 'String','0','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','minintens','Callback',@preproc.maxintens_Callback,'TooltipString','Lower bound of the histogram [0...1]');

item=[parentitem(3)/2 item(2) parentitem(3)/3*1 1];
handles.maxintens = uicontrol(handles.multip03,'Style','edit', 'String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','maxintens','Callback',@preproc.minintens_Callback,'TooltipString','Upper bound of the histogram [0...1]');

item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 4];
handles.uipanel351 = uipanel(handles.multip03, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Background Subtraction', 'Tag','uipanel351','fontweight','bold');
parentitem=get(handles.uipanel351, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3)/3 1.5];
handles.bg_subtract = uicontrol(handles.uipanel351,'Style','popupmenu', 'String',{'off','subtract average intensity','subtract minimum intensity'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','bg_subtract','Callback',@preproc.remove_bg_img, 'TooltipString','Calculates an average or minimum image out of all images, then subtracts that from every image.');

item=[parentitem(3)/3 item(2) parentitem(3)/3*2 1.5];
handles.bg_view = uicontrol(handles.uipanel351,'Style','pushbutton','String','View background image','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.bg_view_Callback,'Tag','bg_view','TooltipString','Display the generated background image. Click again to toggle between background A and B.');

parentitem=get(handles.multip03, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+28 parentitem(3) 2];
handles.preview_preprocess = uicontrol(handles.multip03,'Style','pushbutton','String','Apply and preview current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.preview_preprocess_Callback,'Tag','preview_preprocess','TooltipString','Preview the effect of image pre-processing');

item=[0+item(3)/2 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.export_preprocess = uicontrol(handles.multip03,'Style','pushbutton','String','Export preview','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @export.preprocess_Callback,'Tag','export_preprocess','TooltipString','Export the preprocessed image (use toggle button to switch between image A and B)');


%% Multip04
handles.multip04 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','PIV settings (CTRL+S)', 'Tag','multip04','fontweight','bold');
parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];
%neu
item=[0 item(2)+item(4) parentitem(3)/4 1.5];
handles.textSuggest = uicontrol(handles.multip04,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Help:','tag','textSuggest');

item=[parentitem(3)/4 item(2)+margin/2 parentitem(3)/1.85 1.5];
handles.SuggestSettings = uicontrol(handles.multip04,'Style','pushbutton','String','Suggest settings','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @piv.SuggestPIVsettings,'Tag','SuggestSettings','TooltipString','Suggest PIV settings based on image data in current frame');

item=[0 item(2)+item(4) parentitem(3) 4];
handles.uipanel35 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','PIV algorithm', 'Tag','uipanel35','fontweight','bold');

parentitem=get(handles.uipanel35, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.algorithm_selection = uicontrol(handles.uipanel35,'Style','popupmenu', 'String',{'Multipass FFT window deformation','Ensemble multipass FFT window deformation','Single pass direct cross-correlation (DCC)', 'Optical flow (wavelet-based)'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','algorithm_selection','TooltipString',sprintf('* Multipass FFT window deformation is the standard algorithm, suitable for most cases.\n* Ensemble correlation is for sparsely seeded flows (e.g. micro-piv). \n* DCC is the first algorithm that was implemented in PIVlab. \n* Optical flow can yield higher resolution with appropriate image data (but is slower), implemented by Schmidt et al. from case.edu'),'Callback',@piv.algorithm_selection_Callback);

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

%OFV UI items
item=[0 7 parentitem(3) 8];
handles.uipanel_ofv1 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Optical flow settings', 'Tag','uipanel_ofv1','fontweight','bold','Visible','off');
parentitem=get(handles.uipanel_ofv1, 'Position');
item=[0 0 0 0];


item=[0 item(2)+item(4) parentitem(3) 3];
handles.text_parallelpatches = uicontrol(handles.uipanel_ofv1,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Parallel process patches:','Tag','text_parallelpatches');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_parallelpatches = uicontrol(handles.uipanel_ofv1,'Style','popupmenu', 'String',{'Off' '128' '256' '512' '1024' 'Default'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ofv_parallelpatches','TooltipString','Parallel processing of patches');
set (handles.ofv_parallelpatches,'Value',6);

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text_ofv_median = uicontrol(handles.uipanel_ofv1,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Inter-pass median filter:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_median = uicontrol(handles.uipanel_ofv1,'Style','popupmenu', 'String',{'Off' '3x3' '5x5' '9x9'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ofv_median','TooltipString','Median filtering in between the pyramid levels');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text_ofv_pyramid_levels = uicontrol(handles.uipanel_ofv1,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Pyramid levels:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_pyramid_levels = uicontrol(handles.uipanel_ofv1,'Style','popupmenu', 'String',{'5' '4' '3' '2' '1'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ofv_pyramid_levels','TooltipString','Amount of coarse-to-fine steps, larger numbers required for larger displacements');
handles.ofv_pyramid_levels.Value = 3; %set default

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text_ofv_eta = uicontrol(handles.uipanel_ofv1,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Smoothness (eta):');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_eta = uicontrol(handles.uipanel_ofv1,'Style','edit', 'String','40','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ofv_eta','TooltipString','smoothness determined by the regularization parameter');


parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 7+8.5 parentitem(3) 12];

handles.uipanel_ofv2 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','References', 'Tag','uipanel_ofv2','fontweight','bold','Visible','off');
parentitem=get(handles.uipanel_ofv2, 'Position');
item=[0 0 0 0];


item=[0 item(2)+item(4) parentitem(3) 5];
handles.text_source = uicontrol(handles.uipanel_ofv2,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Schmidt, B. E., and J. A. Sutton. "High-resolution velocimetry from tracer particle fields using a wavelet-based optical flow method." Experiments in Fluids 60.3 (2019): 37.');

item=[0 item(2)+item(4) parentitem(3) 5];
handles.text_source = uicontrol(handles.uipanel_ofv2,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Jassal, G.R., Thielicke, W. and Schmidt, B.E. (2025) "An Optical Flow Algorithm with Automatic Parameter Adjustment for Fluid Velocimetry", Journal of Open Research Software, 13(1), p. 22.');


parentitem=get(handles.multip04, 'Position');
item=[0 7 parentitem(3) 6];
handles.uipanel41 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Pass 1', 'Tag','uipanel41','fontweight','bold');

parentitem=get(handles.uipanel41, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text11 = uicontrol(handles.uipanel41,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Interrogation area [px]','tag','text11');

item=[parentitem(3)/3*2 item(2)+margin/2 parentitem(3)/3 1];
handles.text12 = uicontrol(handles.uipanel41,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Step [px]','tag','text12');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.intarea = uicontrol(handles.uipanel41,'Style','edit', 'String','64','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.intarea_Callback,'Tag','intarea','TooltipString','Interrogation window edge length of the first pass. Should be < 0.25 times your maximum displacement');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.step = uicontrol(handles.uipanel41,'Style','edit', 'String','32','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.step_Callback,'Tag','step','TooltipString','Horizontal and vertical offset or step of the interrogation windows. Usually this is 50 % of the interrogation window edge length (interrogation area)');

item=[parentitem(3)/3*2 item(2)+item(4) parentitem(3)/3*1 1];
handles.steppercentage = uicontrol(handles.uipanel41,'Style','text', 'String','N/A','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','steppercentage');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 13 parentitem(3) 10];
handles.uipanel42 = uipanel(handles.multip04, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Pass 2...4', 'Tag','uipanel42','fontweight','bold');

parentitem=get(handles.uipanel42, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text129 = uicontrol(handles.uipanel42,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Interrogation area [px]','tag','text129');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.text130 = uicontrol(handles.uipanel42,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Step [px]','tag','text130');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1.1];
handles.checkbox26 = uicontrol(handles.uipanel42,'Style','checkbox', 'String','Pass 2','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','checkbox26','Callback',@piv.pass2_checkbox_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.edit50 = uicontrol(handles.uipanel42,'Style','edit', 'String','32','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.pass2_size_Callback,'Tag','edit50','TooltipString','Second pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.text126 = uicontrol(handles.uipanel42,'Style','text', 'String','16','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text126');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1.1];
handles.checkbox27= uicontrol(handles.uipanel42,'Style','checkbox', 'String','Pass 3','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','checkbox27','Callback',@piv.pass3_checkbox_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.edit51 = uicontrol(handles.uipanel42,'Style','edit', 'String','32','Units','characters','enable','off', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.pass3_size_Callback,'Tag','edit51','TooltipString','Third pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.text127 = uicontrol(handles.uipanel42,'Style','text', 'String','16','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text127');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1.1];
handles.checkbox28= uicontrol(handles.uipanel42,'Style','checkbox', 'String','Pass 4','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','checkbox28','Callback',@piv.pass4_checkbox_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.edit52 = uicontrol(handles.uipanel42,'Style','edit', 'String','32','Units','characters','enable','off', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.pass4_size_Callback,'Tag','edit52','TooltipString','Fourth pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.text128 = uicontrol(handles.uipanel42,'Style','text', 'String','16','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text128');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.repeat_last= uicontrol(handles.uipanel42,'Style','checkbox', 'String','Repeat last pass until','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.repeat_last_Callback,'Tag','repeat_last','TooltipString','This will repeat the last pass of a multipass analysis until the average difference to the previous pass is less than "quality slope".');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text128x = uicontrol(handles.uipanel42,'Style','text', 'String','quality slope <','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text128x');

item=[parentitem(3)/2 item(2) parentitem(3)/3.5 1];
handles.edit52x = uicontrol(handles.uipanel42,'Style','edit', 'String','0.025','Units','characters','enable','off', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@piv.repeated_thesh_Callback,'Tag','edit52x','TooltipString','This will repeat the last pass of a multipass analysis until the average difference to the previous pass is less than "quality slope".');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 5+5+11.5+1.5+margin/3 parentitem(3) 1];
handles.text14 = uicontrol(handles.multip04,'Style','text', 'String','Sub-pixel estimator','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text14');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.subpix = uicontrol(handles.multip04,'Style','popupmenu', 'String',{'Gauss 2x3-point','2D Gauss'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','subpix','TooltipString','Subpixel estimation technique. 2D Gauss is supposed to be more accurate for image data that contains motion blur, but there is hardly a difference');

%item=[0 item(2)+item(4)+margin parentitem(3) 1];
%handles.Repeated_box = uicontrol(handles.multip04,'Style','checkbox', 'String','5 x repeated correlation','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','Repeated_box','TooltipString','With very bad image data, enabling the repeated correlation will enhance data yield. But it''s pretty slow');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.mask_auto_box = uicontrol(handles.multip04,'Style','checkbox', 'String','Disable auto-correlation','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','mask_auto_box','TooltipString','This will disallow displacements close to zero. It helps when there is a very strong background signal');

item=[0 item(2)+item(4)+margin/1.5 parentitem(3) 1];
handles.text914 = uicontrol(handles.multip04,'Style','text', 'String','Correlation robustness','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text914');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 2];
handles.CorrQuality = uicontrol(handles.multip04,'Style','popupmenu', 'String',{'Standard (recommended)','High','Extreme'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','CorrQuality','TooltipString','Correlation quality. Better = slower...');

item=[0 item(2)+item(4)+margin/1.5 parentitem(3) 1.5];
handles.Settings_Apply_current = uicontrol(handles.multip04,'Style','pushbutton','String','Analyze current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @piv.AnalyzeSingle_Callback,'Tag','Settings_Apply_current','TooltipString','Apply PIV settings to current frame');

%% Multip05
handles.multip05 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Analyze (CTRL+A)', 'Tag','multip05','fontweight','bold');
parentitem=get(handles.multip05, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.AnalyzeSingle = uicontrol(handles.multip05,'Style','pushbutton','String','Analyze current frame','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @piv.AnalyzeSingle_Callback,'Tag','AnalyzeSingle','TooltipString','Perform PIV analysis for current frame');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.AnalyzeAll = uicontrol(handles.multip05,'Style','pushbutton','String','Analyze all frames','Units','characters', 'Fontunits','points','Fontsize',12,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @piv.AnalyzeAll_Callback,'Tag','AnalyzeAll','TooltipString','Perform PIV analyses for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*2.5 2.5];
handles.update_display_checkbox = uicontrol(handles.multip05,'Style','checkbox', 'value',0, 'String','Refresh display','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','update_display_checkbox','TooltipString','Refresh the display during the analysis. Disabling it will increase processing speed.');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 2.5];
handles.cancelbutt = uicontrol(handles.multip05,'Style','pushbutton','String','Cancel','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @piv.cancelbutt_Callback,'Tag','cancelbutt','TooltipString','Cancel analysis');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.clear_everything = uicontrol(handles.multip05,'Style','pushbutton','String','Clear all results','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @misc.clear_everything_Callback,'Tag','clear_everything','TooltipString','Clear all results');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 2];
handles.progress = uicontrol(handles.multip05,'Style','text','String','Frame progress: N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','progress','Visible','off');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.overall = uicontrol(handles.multip05,'Style','text','String','Total progress: N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','overall');

item=[0 item(2)+item(4)+margin*3 parentitem(3) 2];
handles.totaltime = uicontrol(handles.multip05,'Style','text','String','Time left: N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','totaltime');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.messagetext = uicontrol(handles.multip05,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','messagetext');

%% Multip06
handles.multip06 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Vector validation (CTRL+V)', 'Tag','multip06','fontweight','bold');
parentitem=get(handles.multip06, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 13];

handles.uipanel42x = uipanel(handles.multip06, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Velocity limits', 'Tag','uipanel42x','fontweight','bold');
parentitem=get(handles.uipanel42x, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3 2];
handles.vel_limit = uicontrol(handles.uipanel42x,'Style','pushbutton','String','Rectangle','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.vel_limit_Callback,'Tag','vel_limit','TooltipString','Display a velocity scatter plot and draw a window around the allowed velocities');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3 2];
handles.vel_limit_freehand = uicontrol(handles.uipanel42x,'Style','pushbutton','String','Freehand','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.vel_limit_Callback,'Tag','vel_limit_freehand','TooltipString','Display a velocity scatter plot and freely draw around the allowed velocities');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 2];
handles.vel_limit_auto = uicontrol(handles.uipanel42x,'Style','pushbutton','String','Auto','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.vel_limit_Callback,'Tag','vel_limit_auto','TooltipString','Display a velocity scatter plot and automatically draw a shape around them');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.meanofall = uicontrol(handles.uipanel42x,'Style','checkbox','Value',1,'String','display all frames in scatterplot','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','meanofall','TooltipString','Use velocity data of all frames in the velocity scatter plot');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.vel_limit_active = uicontrol(handles.uipanel42x,'Style','text','String','Limit inactive','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','vel_limit_active');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 3];
handles.limittext = uicontrol(handles.uipanel42x,'Style','text','String','','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','limittext');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.clear_vel_limit = uicontrol(handles.uipanel42x,'Style','pushbutton','String','Clear all velocity limits','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.clear_vel_limit_Callback,'Tag','clear_vel_limit','TooltipString','Remove the velocity limits');


parentitem=get(handles.multip06, 'Position');
item=[0 0 0 0];

item=[0 13+margin/2 parentitem(3) 1.1];
handles.stdev_check = uicontrol(handles.multip06,'Style','checkbox','String','Standard deviation filter','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','stdev_check','TooltipString','Filter velocities by removing velocities that are outside the mean velocity +- n times the standard deviation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text18 = uicontrol(handles.multip06,'Style','text','String','Threshold [n*stdev]','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text18');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.stdev_thresh = uicontrol(handles.multip06,'Style','edit','String','4.7','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@validate.stdev_thresh_Callback,'Tag','stdev_thresh','TooltipString','Threshold for the standard deviation filter. Velocities that are outside the mean velocity +- n times the standard deviation will be removed');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.loc_median = uicontrol(handles.multip06,'Style','checkbox','String','Local median filter','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','loc_median','TooltipString','Normalized local median test from Westerweel and Scarano (2005)');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19 = uicontrol(handles.multip06,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.loc_med_thresh = uicontrol(handles.multip06,'Style','edit','String','3','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@validate.loc_med_thresh_Callback,'Tag','loc_med_thresh');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.notch_filter = uicontrol(handles.multip06,'Style','checkbox','String','Magnitude notch filter','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','notch_filter','TooltipString','Notch filter: Discards velocities in the specified range from vL to vH');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.textnotchL = uicontrol(handles.multip06,'Style','text','String','vL','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','textnotchL');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.notch_L_thresh = uicontrol(handles.multip06,'Style','edit','String','-1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@validate.notch_L_thresh_Callback,'Tag','notch_L_thresh');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.textnotchH = uicontrol(handles.multip06,'Style','text','String','vH','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','textnotchH');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.notch_H_thresh = uicontrol(handles.multip06,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@validate.notch_H_thresh_Callback,'Tag','notch_H_thresh');

%item=[0 item(2)+item(4) parentitem(3)/3*2 1];
%handles.text20 = uicontrol(handles.multip06,'Style','text','String','Epsilon','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text20');

%item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
%handles.epsilon = uicontrol(handles.multip06,'Style','edit','String','0.1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@epsilon_Callback,'Tag','epsilon');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.rejectsingle = uicontrol(handles.multip06,'Style','pushbutton','String','Manually reject vector','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.rejectsingle_Callback,'Tag','rejectsingle','TooltipString','Manually remove vectors. Click on the base of the vectors that you want to discard');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.interpol_missing = uicontrol(handles.multip06,'Style','checkbox','String','Interpolate missing data','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpol_missing','TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors','Callback',@validate.set_other_interpol_checkbox);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.apply_filter_current = uicontrol(handles.multip06,'Style','pushbutton','String','Apply to current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.apply_filter_current_Callback,'Tag','apply_filter_current','TooltipString','Apply the filters to the current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_filter_all = uicontrol(handles.multip06,'Style','pushbutton','String','Apply to all frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.apply_filter_all_Callback,'Tag','apply_filter_all','TooltipString','Apply the filters to all frames');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.restore_all = uicontrol(handles.multip06,'Style','pushbutton','String','Undo all validations (all frames)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.restore_all_Callback,'Tag','restore_all','TooltipString','Remove all velocity filters for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.amount_nans = uicontrol(handles.multip06,'Style','text','String','VDP: 100 %','HorizontalAlignment','center','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','amount_nans','TooltipString','Valid detection probability in percent');

%% Multip07
handles.multip07 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Calibration (CTRL+Z)', 'Tag','multip07','fontweight','bold');
parentitem=get(handles.multip07, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.load_ext_img = uicontrol(handles.multip07,'Style','pushbutton','String','Load calibration image (optional)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @calibrate.load_ext_img_Callback,'Tag','load_ext_img','TooltipString','Load a reference image for calibration (if you recorded one)');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.optimize_calib_img = uicontrol(handles.multip07,'Style','checkbox','Value',1,'String','Enhance image contrast','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','optimize_calib_img','Callback',@calibrate.optimize_calib_img_Callback, 'TooltipString','Enhance the display of the calibration image');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
uicontrol(handles.multip07,'Style','text','String','Setup Scaling','FontWeight','bold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.draw_line = uicontrol(handles.multip07,'Style','pushbutton','String','Pick reference length [px]','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @calibrate.draw_line_Callback,'Tag','draw_line','TooltipString','Draw a line as distance reference in the image');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1.5];
handles.text26b = uicontrol(handles.multip07,'Style','text','String','Reference length in px','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text26b');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.pixeldist = uicontrol(handles.multip07,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','pixeldist','Callback',@calibrate.pixeldist_changed_Callback,'TooltipString','Reference lenght in pixels. Enter directly here or click ''Select reference distance'' button');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
handles.text26 = uicontrol(handles.multip07,'Style','text','String','Real distance in mm','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text26');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.realdist = uicontrol(handles.multip07,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@calibrate.realdist_Callback,'Tag','realdist','TooltipString','Enter the real world length of the line here (in millimeters)');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
handles.text27 = uicontrol(handles.multip07,'Style','text','String','time step in ms','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text27');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.time_inp = uicontrol(handles.multip07,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@calibrate.time_inp_Callback,'Tag','time_inp','TooltipString','Enter the delta t between two images here. Enter 0 if you want to measure displacements instead of velocities.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 8];
handles.uipanel_offsets = uipanel(handles.multip07, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Setup Offsets', 'Tag','uipanel_offsets','fontweight','bold');
parentitem=get(handles.uipanel_offsets, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/4*3 1];
handles.text27a = uicontrol(handles.uipanel_offsets,'Style','text','String','x increases towards the','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text27a');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.x_axis_direction = uicontrol(handles.uipanel_offsets,'Style','popupmenu','String',{'right','left'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','x_axis_direction','TooltipString','Direction of the x axis');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/4*3 1];
handles.text27b = uicontrol(handles.uipanel_offsets,'Style','text','String','y increases towards the','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text27b');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.y_axis_direction = uicontrol(handles.uipanel_offsets,'Style','popupmenu','String',{'bottom','top'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','y_axis_direction','TooltipString','Direction of the y axis');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/1.5 2];
handles.set_x_offset = uicontrol(handles.uipanel_offsets,'Style','pushbutton','String','Set x & y offsets','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @calibrate.set_offset_Callback,'Tag','set_x_offset','TooltipString','Click into your calibration image and tell PIVlab what physical x and y coordinates this point represents.');

item=[0 0 0 0];
parentitem=get(handles.multip07, 'Position');

item=[0 23 parentitem(3) 5];
handles.calidisp = uicontrol(handles.multip07,'Style','text','String','inactive','HorizontalAlignment','center','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calidisp');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.apply_cali = uicontrol(handles.multip07,'Style','pushbutton','String','Apply calibration','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @calibrate.apply_cali_Callback,'Tag','apply_cali','TooltipString','Apply calibration to the whole session');
item=[0 item(2)+item(4)+margin*0.5 parentitem(3) 2];
handles.clear_cali = uicontrol(handles.multip07,'Style','pushbutton','String','Clear calibration','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @calibrate.clear_cali_Callback,'Tag','clear_cali','TooltipString','Remove calibration');

%% Multip08
handles.multip08 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Derive Parameters (CTRL+D)', 'Tag','multip08','fontweight','bold');
parentitem=get(handles.multip08, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text33 = uicontrol(handles.multip08,'Style','text','String','Display Parameter','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text33');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.derivchoice = uicontrol(handles.multip08,'Style','popupmenu','String','N/A','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.derivchoice_Callback,'Tag','derivchoice','TooltipString','Select the parameter that you want to display as colour-coded overlay');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.LIChint1 = uicontrol(handles.multip08,'Style','text','String','LIC resolution','Units','characters','visible','off', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','LIChint1');

item=[parentitem(3)/2 item(2) parentitem(3)/3 1];
handles.licres = uicontrol(handles.multip08,'Style','slider','sliderstep',[0.25 0.25],'max',2,'min',0.1,'value',0.7,'String','Display Parameter','visible','off','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','licres','TooltipString','Resolution of the LIC image. Higher values take longer to calculate','Callback',@plot.licres_Callback);

item=[parentitem(3)/2+parentitem(3)/3 item(2) parentitem(3)/6 1];
handles.LIChint2 = uicontrol(handles.multip08,'Style','text','String','0.7','Units','characters', 'visible','off','HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','LIChint2');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.smooth = uicontrol(handles.multip08,'Style','checkbox','String','Smooth data','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','smooth','TooltipString','Enable smoothing of noisy data. Uses "smoothn" by Damien Garcia');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.text32 = uicontrol(handles.multip08,'Style','text','String','Strength:','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text32');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.smoothstr = uicontrol(handles.multip08,'Style','slider','sliderstep',[0.2 0.2],'max',11,'min',1,'value',1,'Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','smoothstr','TooltipString','Strength of smoothing. More information is displayed in Matlabs command window when you clicked "Apply"');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text34 = uicontrol(handles.multip08,'Style','text','String','Subtract flow','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text34');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3 1.5];
handles.text35 = uicontrol(handles.multip08,'Style','text','String','u:','Units','characters', 'HorizontalAlignment','right','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text35');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1.5];
handles.subtr_u = uicontrol(handles.multip08,'Style','edit','String','0','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.subtr_u_Callback,'Tag','subtr_u','TooltipString','Subtract a constant u velocity (horizontal) from the results');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.mean_u = uicontrol(handles.multip08,'Style','pushbutton','String','mean u','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.mean_u_Callback,'Tag','mean_u','TooltipString','Subtract the mean u velocity from the results');

item=[0 item(2)+item(4) parentitem(3)/3 1.5];
handles.text36 = uicontrol(handles.multip08,'Style','text','String','v:','Units','characters', 'HorizontalAlignment','right','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text36');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1.5];
handles.subtr_v = uicontrol(handles.multip08,'Style','edit','String','0','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.subtr_v_Callback,'Tag','subtr_v','TooltipString','Subtract a constant v velocity (vertical) from the results');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.mean_v = uicontrol(handles.multip08,'Style','pushbutton','String','mean v','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.mean_v_Callback,'Tag','mean_v','TooltipString','Subtract the mean v velocity from the results');

item=[0 item(2)+item(4)+margin parentitem(3)/2 1];
handles.text41 = uicontrol(handles.multip08,'Style','text','String','Colormap limits','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text41');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.1];
handles.autoscaler = uicontrol(handles.multip08,'Style','checkbox','String','autoscale','Value',1,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.autoscaler_Callback,'Tag','autoscaler','TooltipString','Autoscale the color map, so that it is stretched to the min and max of each frame. Should be DISABLED when rendering videos etc.');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text39 = uicontrol(handles.multip08,'Style','text','String','min:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text39');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text40 = uicontrol(handles.multip08,'Style','text','String','max:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text40');

item=[0 item(2)+item(4) parentitem(3)/4 1];
handles.mapscale_min = uicontrol(handles.multip08,'Style','edit','String','-1','Enable','off','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.mapscale_min_Callback,'Tag','mapscale_min','TooltipString','Minimum of the color map');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.mapscale_max = uicontrol(handles.multip08,'Style','edit','String','1','Enable','off','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.mapscale_max_Callback,'Tag','mapscale_max','TooltipString','Maximum of the color map');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.highp_vectors = uicontrol(handles.multip08,'Style','checkbox','String','Highpass vector field','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','highp_vectors','TooltipString','High-pass the vector field. Useful when you want to subtract a non-uniform background flow. The modified data is NOT saved');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.text83 = uicontrol(handles.multip08,'Style','text','String','Strength:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text83');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.highpass_strength = uicontrol(handles.multip08,'Style','slider','sliderstep',[0.1 0.1],'max',51,'min',1,'value',30,'Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','highpass_strength','TooltipString','Strength of the high-pass. The modified data is NOT saved');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.apply_deriv = uicontrol(handles.multip08,'Style','pushbutton','String','Apply to current frame','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.apply_deriv_Callback,'Tag','apply_deriv','TooltipString','Apply settings to current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_deriv_all = uicontrol(handles.multip08,'Style','pushbutton','String','Apply to all frames','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.apply_deriv_all_Callback, 'Tag','apply_deriv_all','TooltipString','Apply settings to all frames');
%{
item=[0 item(2)+item(4)+margin/3*2 parentitem(3) 7];
handles.uipanel43 = uipanel(handles.multip08, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Calculate mean / sum', 'Tag','uipanel43','fontweight','bold');

parentitem=get(handles.uipanel43, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.text153 = uicontrol(handles.uipanel43,'Style','text','String','Frames to calc mean / sum:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text153');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.selectedFramesMean = uicontrol(handles.uipanel43,'Style','edit','String','1:end','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','selectedFramesMean','TooltipString','Select which frames to include for calculating the mean velocity. E.g. "1,3,4,8:10"');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
handles.meanmaker = uicontrol(handles.uipanel43,'Style','pushbutton','String','Calc. mean','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 1}, 'Tag','meanmaker','TooltipString','Calculate mean velocities and append an extra frame with the results');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.summaker = uicontrol(handles.uipanel43,'Style','pushbutton','String','Calc. sum','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@temporal_operation_Callback, 0}, 'Tag','summaker','TooltipString','Calculate sum of displacements and append an extra frame with the results');
%}
%% Multip09
handles.multip09 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Modify plot appearance (CTRL+M)', 'Tag','multip09','fontweight','bold');
parentitem=get(handles.multip09, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.autoscale_vec = uicontrol(handles.multip09,'Style','checkbox','String','autoscale vectors','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.autoscale_vec_Callback,'Tag','autoscale_vec','TooltipString','Enable automatic scaling of the vector display');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text43 = uicontrol(handles.multip09,'Style','text','String','Vector scale','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text43');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1];
handles.vectorscale = uicontrol(handles.multip09,'Style','edit','String','8','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.vectorscale_Callback,'Tag','vectorscale','TooltipString','Manually enter a vector scale factor here');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text114 = uicontrol(handles.multip09,'Style','text','String','Vector line width','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text114');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.vecwidth = uicontrol(handles.multip09,'Style','edit','String','0.5','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.vecwidth_Callback,'Tag','vecwidth','TooltipString','Line width of the vectors');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text132 = uicontrol(handles.multip09,'Style','text','String','plot every nth vector, n =','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','tex132');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.nthvect = uicontrol(handles.multip09,'Style','edit','String','1','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','nthvect','TooltipString','If you are confused by the amount of arrows shown on the screen, then you can reduce the amount here.');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.suppress_vec = uicontrol(handles.multip09,'Style','checkbox','String','hide vectors','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.suppress_vec_Callback,'Tag','suppress_vec','TooltipString','Hide vectors in display');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text200 = uicontrol(handles.multip09,'Style','text','String','Mask transparency [%]','Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text200');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.masktransp = uicontrol(handles.multip09,'Style','edit','String','50','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','masktransp','Callback',@mask.transp_Callback,'TooltipString','Transparency of the masking area display (red)');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.uniform_vector_scale = uicontrol(handles.multip09,'Style','checkbox','String','uniform vector scale','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','uniform_vector_scale','TooltipString','Draw all vectors with the same size, independent of velocity','Callback',@plot.vector_scale_Callback);

item=[0 item(2)+item(4) parentitem(3)/4*3 1.1];
handles.power_vector_scale = uicontrol(handles.multip09,'Style','checkbox','String','power law vector scale','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','power_vector_scale','TooltipString','Draw vector scale with a sublinear power function: Large vector lengths are more and more attenuated the smaller the exponent is.','Callback',@plot.vector_scale_Callback);
item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1.1];
handles.power_vector_scale_factor = uicontrol(handles.multip09,'Style','edit','String','0.3','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','power_vector_scale_factor','TooltipString','Draw vector scale with a sublinear power function: Large vector lengths are more and more attenuated the smaller the exponent is.','Callback',@plot.vector_scale_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.displ_image_txt = uicontrol(handles.multip09,'Style','text','String','Background:', 'HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','displ_image_txt');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.displ_image = uicontrol(handles.multip09,'Style','popupmenu', 'String',{'Display PIV image' 'Solid black','Solid white'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','displ_image','TooltipString','Display the PIV image in the background');



item=[0 item(2)+item(4)+margin/8 parentitem(3) 8.5];
handles.uipanel37 = uipanel(handles.multip09, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Vector colors', 'Tag','uipanel37','fontweight','bold');

parentitem=get(handles.uipanel37, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.text138 = uicontrol(handles.uipanel37,'Style','text','String',' R           G           B         [0...1]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text138');

item=[0 item(2)+item(4) parentitem(3)/5 1.5];
handles.validr = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validr');

item=[parentitem(3)/5*1 item(2) parentitem(3)/5 1.5];
handles.validg = uicontrol(handles.uipanel37,'Style','edit','String','1','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validg');

item=[parentitem(3)/5*2 item(2) parentitem(3)/5 1.5];
handles.validb = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validb');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.text139 = uicontrol(handles.uipanel37,'Style','text','String','valid vectors','Units','characters','HorizontalAlignment','left','Position',[item(1)+margin/2 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text139', 'fontsize', 6);

item=[0 item(2)+item(4)-0.4 parentitem(3)/5 1.5];
handles.validdr = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validdr');

item=[parentitem(3)/5*1 item(2) parentitem(3)/5 1.5];
handles.validdg = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validdg');

item=[parentitem(3)/5*2 item(2) parentitem(3)/5 1.5];
handles.validdb = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','validdb');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.text142 = uicontrol(handles.uipanel37,'Style','text','String','vectors on derivatives','HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text142', 'fontsize', 6);

item=[0 item(2)+item(4)-0.4 parentitem(3)/5 1.5];
handles.interpr = uicontrol(handles.uipanel37,'Style','edit','String','1','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpr');

item=[parentitem(3)/5*1 item(2) parentitem(3)/5 1.5];
handles.interpg = uicontrol(handles.uipanel37,'Style','edit','String','0.5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpg');

item=[parentitem(3)/5*2 item(2) parentitem(3)/5 1.5];
handles.interpb = uicontrol(handles.uipanel37,'Style','edit','String','0','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpb');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 1,5];
handles.text140 = uicontrol(handles.uipanel37,'Style','text','String','interpolated vectors','HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text142', 'fontsize', 6);

parentitem=get(handles.multip09, 'Position');
item=[0 12.5+6.5+1.5 parentitem(3) 9];
handles.uipanel27 = uipanel(handles.multip09, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Derived parameter appearance', 'Tag','uipanel27','fontweight','bold');

parentitem=get(handles.uipanel27, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text43c = uicontrol(handles.uipanel27,'Style','text','String','Colormap opacity [%]','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text43c');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1];
handles.colormapopacity = uicontrol(handles.uipanel27,'Style','edit','String','75','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormapopacity','TooltipString','Opacity of the colormap (0...1)');

item=[0 item(2)+item(4)+margin/3 parentitem(3)/2 1];
handles.text143 = uicontrol(handles.uipanel27,'Style','text','String','Color map','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text143');

item=[0+item(3) item(2) parentitem(3)/2 1];
handles.text143a = uicontrol(handles.uipanel27,'Style','text','String','Steps','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text143a');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.colormap_choice = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'Parula','HSV','Jet','HSB','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','Lines','Plasma'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormap_choice','TooltipString','Select the color map for displaying derived parameters here');

item=[0+item(3) item(2) parentitem(3)/2 2];
handles.colormap_steps = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'256','128','64','32','16','8','4','2'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormap_steps','TooltipString','Select the amount of colors in a colormap');

item=[0 item(2)+item(4)+margin/3*2 parentitem(3)/5*3 1];
handles.text143b = uicontrol(handles.uipanel27,'Style','text','String','Image interpolation','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text143b');

item=[0+item(3) item(2)-0.2 parentitem(3)/5*2 2];
handles.colormap_interpolation = uicontrol(handles.uipanel27,'Style','popupmenu', 'String',{'bilinear','bicubic','nearest'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colormap_interpolation','TooltipString','Image interpolation method for displaying the derived parameters. Default is bilinear');

%item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.img_not_mask = uicontrol(handles.uipanel27,'Style','checkbox','String','Do not display mask','Units','characters','Visible','off','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','img_not_mask');

parentitem=get(handles.multip09, 'Position');
item=[0 12.5+6.5+1.5+9.4 parentitem(3) 5.7];
handles.uipanel27b = uipanel(handles.multip09, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Color legend', 'Tag','uipanel27b','fontweight','bold');

parentitem=get(handles.uipanel27b, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/5*3 1];
handles.displ_colorbar = uicontrol(handles.uipanel27b,'Style','text','String','Show colorbar:', 'HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','displ_colorbar','TooltipString','Display a colour bar for the derived parameters');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.colorbarpos = uicontrol(handles.uipanel27b,'Style','popupmenu', 'String',{'None' 'SouthOutside','NorthOutside','EastOutside','WestOutside'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colorbarpos','TooltipString','Position of the colour bar');

item=[0 item(2)+item(4) parentitem(3)/5*3 1];
handles.colorbarnumberformattxt = uicontrol(handles.uipanel27b,'Style','text','String','Colorbar numeric format:', 'HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colorbarnumberformattxt');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.colorbarnumberformat = uicontrol(handles.uipanel27b,'Style','popupmenu', 'String',{'compact notation' 'scientific notation' 'fixed-decimals'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','colorbarnumberformat','TooltipString','Number format of the colorbar');

parentitem=get(handles.multip09, 'Position');
item=[0 17.5+4+14.2+margin/4 parentitem(3)/2 2];
handles.ref_vect_txt = uicontrol(handles.multip09,'Style','text','String','Reference vector scale:', 'HorizontalAlignment','left','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ref_vect_txt','TooltipString','Display a reference vector');

item=[parentitem(3)/2 item(2) parentitem(3)/6 1.5];
handles.ref_vect_scl = uicontrol(handles.multip09,'Style','edit','String','1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ref_vect_scl','TooltipString','Scaling of the reference vector. Same units as vector units.');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 2];
handles.ref_vect_pos = uicontrol(handles.multip09,'Style','popupmenu', 'String',{'Off' 'Top left','Top right','Bottom right','Bottom left'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ref_vect_pos','TooltipString','Position of the reference vector');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.enhance_images = uicontrol(handles.multip09,'Style','checkbox','String','Enhance PIV image display','Value',1,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','enhance_images','TooltipString','Improve contrast of PIV images for display');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.dummy = uicontrol(handles.multip09,'Style','pushbutton','String','Apply','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.dummy_Callback,'Tag','dummy','TooltipString','Apply the settings');

%% Multip10
handles.multip10 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Export as text file (ASCII)', 'Tag','multip10','fontweight','bold');
parentitem=get(handles.multip10, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.addfileinfo = uicontrol(handles.multip10,'Style','checkbox','String','Add file information','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','addfileinfo','TooltipString','Add information like image file names etc. to the output file');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.add_header = uicontrol(handles.multip10,'Style','checkbox','String','Add column headers','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','add_header','TooltipString','Add a header for each column');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.export_vort = uicontrol(handles.multip10,'Style','checkbox','String','Include derivatives','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','export_vort','TooltipString','Calculate and export derivatives');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.delimitertext = uicontrol(handles.multip10,'Style','text','String','Delimiter:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','delimitertext');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 1.5];
handles.delimiter = uicontrol(handles.multip10,'Style','popupmenu','String',{'comma','tab','space'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','delimiter','TooltipString','Select the delimiter here');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.ascii_current = uicontrol(handles.multip10,'Style','pushbutton','String','Export current frame','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.ascii_current_Callback,'Tag','ascii_current','TooltipString','Export data for current frame only');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.ascii_all = uicontrol(handles.multip10,'Style','pushbutton','String','Export all frames','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.ascii_all_Callback,'Tag','ascii_all','TooltipString','Export data for all frames');


%% Multip11
handles.multip11 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save as MATLAB file', 'Tag','multip11','fontweight','bold');
parentitem=get(handles.multip11, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin parentitem(3) 6];
handles.matlab_text = uicontrol(handles.multip11,'Style','text','String','The files will only include the derivatives that you calculated in the ''Plot -> Derive parameters'' panel. If you did not calculate any derivatives, then the corresponding fields will be empty.','Units','characters','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','matlab_text');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_mat_current = uicontrol(handles.multip11,'Style','pushbutton','String','Export current frame','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.save_mat_current_Callback,'Tag','save_mat_current','TooltipString','Export data for current frame only');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_mat_all = uicontrol(handles.multip11,'Style','pushbutton','String','Export all frames','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.save_mat_all_Callback,'Tag','save_mat_all','TooltipString','Export data for all frames');

%% Multip12
handles.multip12 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Extract parameters from poly-line', 'Tag','multip12','fontweight','bold');
parentitem=get(handles.multip12, 'Position');
item=[0 0 0 0];

%item=[0 item(2)+item(4) parentitem(3) 2];
%handles.text55 = uicontrol(handles.multip12,'Style','text','String','Draw a line or circle and extract derived parameters from it.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text55');

%item=[0 item(2)+item(4) parentitem(3) 7];
%handles.text91 = uicontrol(handles.multip12,'Style','text','String','Draw a poly-line by clicking with left mouse button. Right mouse button ends the poly-line. Draw a circle by clicking twice with the left mouse button: First click is for the centre, second click for radius.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text91');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
handles.text57 = uicontrol(handles.multip12,'Style','text','String','Type:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text57');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.draw_what = uicontrol(handles.multip12,'Style','popupmenu','String',{'polyline','circle','circle series (tangent vel. only)'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.draw_what_Callback,'Tag','draw_what','TooltipString','Select the type of object that you want to draw and extract data from');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.draw_stuff = uicontrol(handles.multip12,'Style','pushbutton','String','Draw!','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.draw_extraction_coordinates_Callback,'Tag','draw_stuff','TooltipString','Draw the object that you selected above');

%%new buttons, load and save polylines
item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.save_polyline = uicontrol(handles.multip12,'Style','pushbutton','String','Save coords','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.save_polyline_Callback,'Tag','save_polyline','TooltipString','Save poly line coordinates to *.mat file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.load_polyline = uicontrol(handles.multip12,'Style','pushbutton','String','Load coords','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.load_polyline_Callback,'Tag','load_polyline','TooltipString','Load poly line coordinates from *.mat file');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text56 = uicontrol(handles.multip12,'Style','text','String','Data to extract:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text56');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.extraction_choice = uicontrol(handles.multip12,'Style','popupmenu','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.extraction_choice_Callback,'Tag','extraction_choice','TooltipString','What parameter do you want to extract along the line / circle?');

item=[0 item(2)+item(4)+margin parentitem(3)/2 2];
handles.plot_data = uicontrol(handles.multip12,'Style','pushbutton','String','Extract data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.plot_data_Callback,'Tag','plot_data','TooltipString','When you finished drawing a line / circle, you can plot data along the line / circle by pushing this button');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_plot = uicontrol(handles.multip12,'Style','pushbutton','String','Clear data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.clear_plot_Callback,'Tag','clear_plot','TooltipString','Clear line / circle data');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1];
handles.iLoveLenaMaliaAndLine = uicontrol(handles.multip12,'Style','text','String','Save extraction(s)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','iLoveLenaMaliaAndLine');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.extractLineAll = uicontrol(handles.multip12,'Style','checkbox','String','extract and save for all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','extractLineAll','TooltipString','Extract data for all frames of the current session');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.extractionLine_fileformat = uicontrol(handles.multip12,'Style','popupmenu','String',{'Excel file' 'Text file'},'Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','extractionLine_fileformat','TooltipString','The format that the data is saved in');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.save_data = uicontrol(handles.multip12,'Style','pushbutton','String','Export data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.save_data_Callback,'Tag','save_data','TooltipString','Extract data and save results to a text file');

%% Multip13
handles.multip13 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Measure distance & angle (CTRL+T)', 'Tag','multip13','fontweight','bold');
parentitem=get(handles.multip13, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 10];
handles.uipanel40 = uipanel(handles.multip13, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Distance & angle', 'Tag','uipanel40','fontweight','bold');

parentitem=get(handles.uipanel40, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.set_points = uicontrol(handles.uipanel40,'Style','pushbutton','String','Draw line','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.set_points_Callback,'Tag','set_points','TooltipString','Draw a line to measure distance and angle');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text50 = uicontrol(handles.uipanel40,'Style','text','String','Delta x:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text50');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.deltax = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','deltax');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text51 = uicontrol(handles.uipanel40,'Style','text','String','Delta y:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text51');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.deltay = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','deltay');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text52 = uicontrol(handles.uipanel40,'Style','text','String','Length:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text52');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.length = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','length');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text53 = uicontrol(handles.uipanel40,'Style','text','String','Angle to horiz. (deg):','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text53');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.alpha = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','alpha');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text54 = uicontrol(handles.uipanel40,'Style','text','String','Angle to vert. (deg):','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text54');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.beta = uicontrol(handles.uipanel40,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','beta');

parentitem=get(handles.multip13, 'Position');
item=[0 0 0 0];
item=[0 11.5 parentitem(3) 10];
handles.uipanel39 = uipanel(handles.multip13, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Markers', 'Tag','uipanel39','fontweight','bold');

parentitem=get(handles.uipanel39, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 3];
handles.text146 = uicontrol(handles.uipanel39,'Style','text','String','Highlight points in the analyses. The markers will be memorized even if a new session is started.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text146');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.putmarkers = uicontrol(handles.uipanel39,'Style','pushbutton','String','Set markers','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.putmarkers_Callback,'Tag','putmarkers','TooltipString','Click in the image to place markers. End by clicking the right mouse button');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.delmarkers = uicontrol(handles.uipanel39,'Style','pushbutton','String','Clear markers','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.delmarkers_Callback,'Tag','delmarkers','TooltipString','Clear all markers');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.holdmarkers = uicontrol(handles.uipanel39,'Style','checkbox','String','Hold markers','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','holdmarkers','TooltipString','Memorize markers even when a new session is started. Will be cleared only when you restart PIVlab');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.displmarker = uicontrol(handles.uipanel39,'Style','checkbox','String','Display markers','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.displmarker_Callback,'Tag','displmarker','TooltipString','Show or hide the markers');

parentitem=get(handles.multip13, 'Position');
item=[0 22+margin/2 parentitem(3) 2];
handles.markers_display_average = uicontrol(handles.multip13,'Style','pushbutton','String','Display average','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @mask.display_average_Callback,'Tag','markers_display_average','TooltipString','Show the mean image');

%% Multip14
handles.multip14 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Statistics (CTRL+B)', 'Tag','multip14','fontweight','bold');
parentitem=get(handles.multip14, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*1 1];
handles.text59 = uicontrol(handles.multip14,'Style','text','String','mean u:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text59');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.meanu = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','meanu');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text60 = uicontrol(handles.multip14,'Style','text','String','mean v:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text60');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.meanv = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','meanv');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text59a = uicontrol(handles.multip14,'Style','text','String','max u:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text59a');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.maxu = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','maxu');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text60a = uicontrol(handles.multip14,'Style','text','String','min u:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text60a');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.minu = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','minu');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text59b = uicontrol(handles.multip14,'Style','text','String','max v:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text59a');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.maxv = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','maxv');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.text60b = uicontrol(handles.multip14,'Style','text','String','min v:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text60a');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
handles.minv = uicontrol(handles.multip14,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','minv');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text67 = uicontrol(handles.multip14,'Style','text','String','Histogram plot','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text67');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
handles.hist_select = uicontrol(handles.multip14,'Style','popupmenu','String',{'u velocity','v velocity','velocity magnitude','sub-pixels'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','hist_select','TooltipString','What data to display in a histogram plot');

item=[parentitem(3)/2 item(2) parentitem(3)/4 2];
handles.text66 = uicontrol(handles.multip14,'Style','text','String','bins:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text66');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 2];
handles.nrofbins = uicontrol(handles.multip14,'Style','edit','String','100','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','nrofbins','TooltipString','Nr. of bins in the histogram plot');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.histdraw = uicontrol(handles.multip14,'Style','pushbutton','String','Histogram','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.histdraw_Callback,'Tag','histdraw','TooltipString','Draw a histogram');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.scatterplotter = uicontrol(handles.multip14,'Style','pushbutton','String','Scatter plot u & v','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.scatterplotter_Callback,'Tag','scatterplotter','TooltipString','Scatter plot u vs. v velocities');

%% Multip15
handles.multip15 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Particle image generation (CTRL+G)', 'Tag','multip15','fontweight','bold');
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text68 = uicontrol(handles.multip15,'Style','text','String','Flow simulation:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text68');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.flow_sim = uicontrol(handles.multip15,'Style','popupmenu','String',{'Rankine vortex','Hamel-Oseen vortex','Linear shift','Rotation','Membrane'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.flow_sim_Callback,'Tag','flow_sim','TooltipString','Select the velocity field for the simulation here');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text77 = uicontrol(handles.multip15,'Style','text','String','Image size x [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text77');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.img_sizex = uicontrol(handles.multip15,'Style','edit','String','800','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','img_sizex','TooltipString','Image width in pixels');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text96 = uicontrol(handles.multip15,'Style','text','String','Image size y [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text96');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.img_sizey = uicontrol(handles.multip15,'Style','edit','String','600','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','img_sizey','TooltipString','Image height in pixels');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 8];
handles.uipanel24 = uipanel(handles.multip15, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Particle simulation', 'Tag','uipanel24','fontweight','bold');

parentitem=get(handles.uipanel24, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text70 = uicontrol(handles.uipanel24,'Style','text','String','Nr. of particles','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text70');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_am = uicontrol(handles.uipanel24,'Style','edit','String','200000','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.part_am_Callback,'Tag','part_am','TooltipString','Amount of particles used for the simulation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text71 = uicontrol(handles.uipanel24,'Style','text','String','Particle diameter [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text71');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_size = uicontrol(handles.uipanel24,'Style','edit','String','3','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.part_size_Callback,'Tag','part_size','TooltipString','Mean particle image diameter');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text72 = uicontrol(handles.uipanel24,'Style','text','String','Random size [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text72');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_var = uicontrol(handles.uipanel24,'Style','edit','String','1','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.part_var_Callback,'Tag','part_var','TooltipString','Particle image diameter variation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text98 = uicontrol(handles.uipanel24,'Style','text','String','Sheet thickness [0...1]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text98');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.sheetthick = uicontrol(handles.uipanel24,'Style','edit','String','0.5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.sheetthick_Callback,'Tag','sheetthick','TooltipString','Simulated laser sheet thickness. A thinner light sheet sheds more light on each particle');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text73 = uicontrol(handles.uipanel24,'Style','text','String','Noise','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text73');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_noise = uicontrol(handles.uipanel24,'Style','edit','String','0.001','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.part_noise_Callback,'Tag','part_noise','TooltipString','Simulated image sensor noise');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text115 = uicontrol(handles.uipanel24,'Style','text','String','Random z position [%]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text115');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.part_z = uicontrol(handles.uipanel24,'Style','edit','String','10','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.part_z_Callback,'Tag','part_z','TooltipString','Movement of the particles perpendicular to the light sheet (out-of-plane motion)');

%rankinepanel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 11];
handles.rankinepanel = uipanel(handles.multip15, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Rankine vortex', 'Tag','rankinepanel','fontweight','bold');

parentitem=get(handles.rankinepanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 2];
handles.singledoublerankine = uicontrol(handles.rankinepanel,'Style','popupmenu','String',{'Single vortex','Vortex pair'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.singledoublerankine_Callback,'Tag','singledoublerankine','TooltipString','Simulate a single vortex or a vortex pair');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text74 = uicontrol(handles.rankinepanel,'Style','text','String','Core radius [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text74');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.rank_core = uicontrol(handles.rankinepanel,'Style','edit','String','100','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.rank_core_Callback,'Tag','rank_core','TooltipString','Radius of the solid body rotation core');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text75 = uicontrol(handles.rankinepanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text75');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.rank_displ = uicontrol(handles.rankinepanel,'Style','edit','String','8','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.rank_displ_Callback,'Tag','rank_displ','TooltipString','Maximum displacement of particles in the image');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text99 = uicontrol(handles.rankinepanel,'Style','text','String','Vortex1 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text99');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text102 = uicontrol(handles.rankinepanel,'Style','text','Visible','off','String','Vortex2 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text102');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text100 = uicontrol(handles.rankinepanel,'Style','text','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text100');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.rankx1 = uicontrol(handles.rankinepanel,'Style','edit','String','200','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.rankx1_Callback,'Tag','rankx1','TooltipString','x-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text103 = uicontrol(handles.rankinepanel,'Style','text','Visible','off','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text103');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.rankx2 = uicontrol(handles.rankinepanel,'Style','edit','Visible','off','String','600','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.rankx2_Callback,'Tag','rankx2','TooltipString','x-centre of the second vortex');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text101 = uicontrol(handles.rankinepanel,'Style','text','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text101');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.ranky1 = uicontrol(handles.rankinepanel,'Style','edit','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.ranky1_Callback,'Tag','ranky1','TooltipString','y-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text104 = uicontrol(handles.rankinepanel,'Style','text','Visible','off','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text104');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.ranky2 = uicontrol(handles.rankinepanel,'Style','edit','Visible','off','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.ranky2_Callback,'Tag','ranky2','TooltipString','y-centre of the second vortex');

%------------oseen panel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 11];
handles.oseenpanel = uipanel(handles.multip15, 'Units','characters','Visible','off', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Hamel-Oseen vortex', 'Tag','oseenpanel','fontweight','bold');

parentitem=get(handles.oseenpanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 2];
handles.singledoubleoseen = uicontrol(handles.oseenpanel,'Style','popupmenu','String',{'Single vortex','Vortex pair'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.singledoubleoseen_Callback,'Tag','singledoubleoseen','TooltipString','Simulate a single vortex or a vortex pair');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text106 = uicontrol(handles.oseenpanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text106');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.oseen_displ = uicontrol(handles.oseenpanel,'Style','edit','String','5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.oseen_displ_Callback,'Tag','oseen_displ','TooltipString','Maximum displacement of the particles');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text113 = uicontrol(handles.oseenpanel,'Style','text','String','time [0...1]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text113');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.oseen_time = uicontrol(handles.oseenpanel,'Style','edit','String','0.05','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.oseen_time_Callback,'Tag','oseen_time','TooltipString','Time component of the Hamel-Oseen simulation: The vortex decays with vorticity when time increases');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.text107 = uicontrol(handles.oseenpanel,'Style','text','String','Vortex1 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text107');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text110 = uicontrol(handles.oseenpanel,'Style','text','Visible','off','String','Vortex2 centre','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text110');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text108 = uicontrol(handles.oseenpanel,'Style','text','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text108');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseenx1 = uicontrol(handles.oseenpanel,'Style','edit','String','200','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.oseenx1_Callback,'Tag','oseenx1','TooltipString','x-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text111 = uicontrol(handles.oseenpanel,'Style','text','Visible','off','String','x','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text111');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseenx2 = uicontrol(handles.oseenpanel,'Style','edit','Visible','off','String','600','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.oseenx2_Callback,'Tag','oseenx2','TooltipString','x-centre of the second vortex');

item=[0 item(2)+item(4) parentitem(3)/8 1];
handles.text109 = uicontrol(handles.oseenpanel,'Style','text','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text109');

item=[parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseeny1 = uicontrol(handles.oseenpanel,'Style','edit','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.oseeny1_Callback,'Tag','oseeny1','TooltipString','y-centre of the first vortex');

item=[parentitem(3)/2 item(2) parentitem(3)/8 1];
handles.text112 = uicontrol(handles.oseenpanel,'Style','text','Visible','off','String','y','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text112');

item=[parentitem(3)/2+parentitem(3)/8 item(2) parentitem(3)/4 1];
handles.oseeny2 = uicontrol(handles.oseenpanel,'Style','edit','Visible','off','String','300','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.oseeny2_Callback,'Tag','oseeny2','TooltipString','y-centre of the second vortex');

%rotationpanel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 10];
handles.rotationpanel = uipanel(handles.multip15, 'Units','characters','Visible','off', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Rotation', 'Tag','rotationpanel','fontweight','bold');

parentitem=get(handles.rotationpanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.text76 = uicontrol(handles.rotationpanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text76');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.rotationdislacement = uicontrol(handles.rotationpanel,'Style','edit','String','5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.rotationdisplacement_Callback,'Tag','rotationdislacement','TooltipString','Maximum displacement of the particles');

%linear shiftpanel
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 14+margin parentitem(3) 10];
handles.shiftpanel = uipanel(handles.multip15, 'Units','characters', 'Visible','off','Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Linear shift', 'Tag','shiftpanel','fontweight','bold');

parentitem=get(handles.shiftpanel, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 1];
handles.text97 = uicontrol(handles.shiftpanel,'Style','text','String','Max displacement [px]','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text97');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.shiftdisplacement = uicontrol(handles.shiftpanel,'Style','edit','String','5','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.shiftdisplacement_Callback,'Tag','shiftdisplacement','TooltipString','Maximum displacement of the particles');
%--------------- rest unter panels
parentitem=get(handles.multip15, 'Position');
item=[0 0 0 0];

item=[0 27 parentitem(3) 1];
handles.status_creation = uicontrol(handles.multip15,'Style','text','String','N/A','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','status_creation');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.generate_it = uicontrol(handles.multip15,'Style','pushbutton','String','Create images','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.generate_it_Callback,'Tag','generate_it','TooltipString','Start particle simulation and create image pair');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.save_imgs = uicontrol(handles.multip15,'Style','pushbutton','String','Save images','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@simulate.save_imgs_Callback,'Tag','save_imgs','TooltipString','Save current set of particle simulation images (e.g. if you want to import them to PIVlab)');

%% Multip16
handles.multip16 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save image (sequence)', 'Tag','multip16','fontweight','bold');
parentitem=get(handles.multip16, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];

handles.export_still_or_animation = uicontrol(handles.multip16,'Style','popupmenu','String',{'Please wait...'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.still_or_animation_Callback,'Tag','export_still_or_animation','TooltipString','Select type of export.');

item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1];
handles.qualstring = uicontrol(handles.multip16,'Style','text','String','Quality (%)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','qualstring');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.quality_setting = uicontrol(handles.multip16,'Style','edit','String','100','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','quality_setting','TooltipString','Quality setting of exported file');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.fpsstring = uicontrol(handles.multip16,'Style','text','String','Frames per second (Hz)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','fpsstring');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.fps_setting = uicontrol(handles.multip16,'Style','edit','String','30','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','fps_setting','TooltipString','Frame rate of the video file');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
if ~isMATLABReleaseOlderThan("R2025a")
    handles.resolutionstring = uicontrol(handles.multip16,'Style','text','String','Image size (%)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','resolutionstring');
else
    handles.resolutionstring = uicontrol(handles.multip16,'Style','text','String','Resolution (dpi)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','resolutionstring');
end
item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
if ~isMATLABReleaseOlderThan("R2025a")
    handles.resolution_setting = uicontrol(handles.multip16,'Style','edit','String','100','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','resolution_setting','TooltipString','Scaling of the output file (relative to the raw input images)');
else
    handles.resolution_setting = uicontrol(handles.multip16,'Style','edit','String','150','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','resolution_setting','TooltipString','Resolution of the output image');
end
item=[0 item(2)+item(4)+margin*2 parentitem(3) 2];
handles.do_export_pixel_data_single = uicontrol(handles.multip16,'Style','pushbutton','String','Export single frame','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.do_export_pixel_data_Callback,'Tag','do_export_pixel_data_single','TooltipString','Save image for currently active frame');

item=[0 item(2)+item(4)+margin*2 parentitem(3)/2 1];
handles.text87 = uicontrol(handles.multip16,'Style','text','String','First frame','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text87');

item=[ parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text88 = uicontrol(handles.multip16,'Style','text','String','Last frame','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text87');

item=[0 item(2)+item(4) parentitem(3)/3 1];
handles.firstframe = uicontrol(handles.multip16,'Style','edit','String','N/A','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','firstframe','TooltipString','First frame to export');

item=[parentitem(3)/2 item(2) parentitem(3)/3 1];
handles.lastframe = uicontrol(handles.multip16,'Style','edit','String','N/A','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','lastframe','TooltipString','Last frame to export');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.do_export_pixel_data = uicontrol(handles.multip16,'Style','pushbutton','String','Export multiple frames','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.do_export_pixel_data_Callback,'Tag','do_export_pixel_data','TooltipString','Save image sequence for the selected frames');

%% Multip17
handles.multip17 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Extract parameters from area', 'Tag','multip17','fontweight','bold');
parentitem=get(handles.multip17, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
handles.text57a = uicontrol(handles.multip17,'Style','text','String','Type:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text57a');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.draw_what_area = uicontrol(handles.multip17,'Style','popupmenu','String',{'rectangle','polygon','circle','circle series'},'Units','characters', 'HorizontalAlignment','Left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','draw_what_area','TooltipString','Select the type of object that you want to draw and extract data from');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.draw_stuff_area = uicontrol(handles.multip17,'Style','pushbutton','String','Draw!','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.draw_extraction_coordinates_Callback,'Tag','draw_stuff_area','TooltipString','Draw the object that you selected above');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.save_area_coordinates = uicontrol(handles.multip17,'Style','pushbutton','String','Save coords','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.save_polyline_Callback,'Tag','save_area_coordinates','TooltipString','Save area coordinates to *.mat file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.load_area_coordinates = uicontrol(handles.multip17,'Style','pushbutton','String','Load coords','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.load_polyline_Callback,'Tag','load_area_coordinates','TooltipString','Load area coordinates from *.mat file');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text56a = uicontrol(handles.multip17,'Style','text','String','Calculate the average of:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text56a');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.extraction_choice_area = uicontrol(handles.multip17,'Style','popupmenu','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','extraction_choice_area','TooltipString','What parameter do you want to extract from the area?');

item=[0 item(2)+item(4)+margin parentitem(3)/2 2];
handles.plot_data_area = uicontrol(handles.multip17,'Style','pushbutton','String','Extract data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.plot_data_area_Callback,'Tag','plot_data_area','TooltipString','Extract the data from the area drawn');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_plot_area = uicontrol(handles.multip17,'Style','pushbutton','String','Clear data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.clear_plot_Callback,'Tag','clear_plot_area','TooltipString','Clear area data');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.results_txts = uicontrol(handles.multip17,'Style','text','String','Results:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','results_txts');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 4];
handles.area_results = uicontrol(handles.multip17,'Style','edit','String',{''},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','area_results','TooltipString','Results of area extraction','Max',4,'Min',1,'Horizontalalignment','left');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1];
handles.save_plot_data_area = uicontrol(handles.multip17,'Style','text','String','Save extraction(s)','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','save_plot_data_area');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.extractAreaAll = uicontrol(handles.multip17,'Style','checkbox','String','extract and save for all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','extractAreaAll','TooltipString','Extract data for all frames of the current session');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.extractionArea_fileformat = uicontrol(handles.multip17,'Style','popupmenu','String',{'Excel file' 'Text file'},'Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','extractionArea_fileformat','TooltipString','The format that the data is saved in');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.save_data_area = uicontrol(handles.multip17,'Style','pushbutton','String','Export data','Units','characters', 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@extract.save_data_area_Callback,'Tag','save_data_area','TooltipString','Extract data and save results to a text file');



%% Multip18
handles.multip18 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Stream lines', 'Tag','multip18','fontweight','bold');
parentitem=get(handles.multip18, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 3];
handles.text117 = uicontrol(handles.multip18,'Style','text','String','Stream lines are global, that means that they apply to all frames of the current session.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text117');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.holdstream = uicontrol(handles.multip18,'Style','checkbox','String','hold streamlines','Value',1,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','holdstream','TooltipString','If enabled, every streamline that you draw will be added to the list of streamlines, instead of overwriting the list of streamlines');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.drawstreamlines = uicontrol(handles.multip18,'Style','pushbutton','String','Draw stream lines','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.drawstreamlines_Callback,'Tag','drawstreamlines','TooltipString','Every click adds a streamline. End with a right click');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.streamrake = uicontrol(handles.multip18,'Style','pushbutton','String','Draw stream line rake','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.streamrake_Callback,'Tag','streamrake','TooltipString','Draw a rake of streamlines: First click is the starting point of the rake, second click is the end point');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 2];
handles.text118 = uicontrol(handles.multip18,'Style','text','String','Amount of stream lines on rake','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text118');

item=[parentitem(3)/3*2 item(2)+0.5 parentitem(3)/3 1];
handles.streamlamount = uicontrol(handles.multip18,'Style','edit','String','10','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','streamlamount','TooltipString','Amount of streamlines on the rake');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.deletestreamlines = uicontrol(handles.multip18,'Style','pushbutton','String','Delete all stream lines','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.deletestreamlines_Callback,'Tag','deletestreamlines','TooltipString','Remove all streamlines');

item=[0 item(2)+item(4)+margin*3 parentitem(3)/2 2];
handles.text119 = uicontrol(handles.multip18,'Style','text','String','Color','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text119');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.streamlcolor = uicontrol(handles.multip18,'Style','popupmenu','String',{'y','r','b','k','w'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','streamlcolor','TooltipString','Colour of the streamlines');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 2];
handles.text120 = uicontrol(handles.multip18,'Style','text','String','Line width','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text120');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.streamlwidth = uicontrol(handles.multip18,'Style','popupmenu','String',{'1','2','3'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','streamlwidth','TooltipString','Line width of the streamlines');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.applycolorwidth = uicontrol(handles.multip18,'Style','pushbutton','String','Apply color and width','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.applycolorwidth_Callback,'Tag','applycolorwidth','TooltipString','Apply the settings for colour and width');

%% Multip19
handles.multip19 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save as Paraview VTK file', 'Tag','multip19','fontweight','bold');
parentitem=get(handles.multip19, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 2];
handles.paraview_current = uicontrol(handles.multip19,'Style','pushbutton','String','Save current frame','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.paraview_current_Callback,'Tag','paraview_current','TooltipString','Save current frame as Paraview file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.paraview_all = uicontrol(handles.multip19,'Style','pushbutton','String','Save all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.paraview_all_Callback,'Tag','paraview_all','TooltipString','Save all frames as Paraview files');

%% Multip20
handles.multip20 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Save as TECPLOT file', 'Tag','multip20','fontweight','bold');
parentitem=get(handles.multip20, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.export_vort_tec = uicontrol(handles.multip20,'Style','checkbox','String','Include derivatives','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','export_vort_tec','TooltipString','Include derivatives like vorticity etc. in the exported file');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.tecplot_current = uicontrol(handles.multip20,'Style','pushbutton','String','Save current frame','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.tecplot_current_Callback,'Tag','tecplot_current','TooltipString','Save current frame only as Tecplot file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.tecplot_all = uicontrol(handles.multip20,'Style','pushbutton','String','Save all frames','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@export.tecplot_all_Callback,'Tag','tecplot_all','TooltipString','Save all frames as Tecplot files');

%% Multip21
handles.multip21 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Preferences', 'Tag','multip21','fontweight','bold');
parentitem=get(handles.multip21, 'Position');
item=[0 0 0 0]; %reset positioning

if ~verLessThan('Matlab','25')
    item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
    handles.matlab_theme_txt = uicontrol(handles.multip21,'Style','text','String','Color theme','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','matlab_theme_txt');

    item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
    handles.matlab_theme = uicontrol(handles.multip21,'Style','popupmenu','String',{'Dark','Light'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','matlab_theme','TooltipString','Change Matlab Theme','Callback',@gui.change_theme);


    current_theme = MainWindow.Theme.BaseColorStyle;

    if strcmpi(current_theme, 'Dark')
        set( handles.matlab_theme,'Value',1);
    elseif strcmpi(current_theme, 'Light')
        set( handles.matlab_theme,'Value',2);
    end
end

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.paneltext = uicontrol(handles.multip21,'Style','text','String','Width of the panels','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.panelslider = uicontrol(handles.multip21,'Style','slider','max',80,'min',30,'sliderstep',[0.05 0.05],'Value',50,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','panelslider','TooltipString','Width of the panel that you see on the left side');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.pref_apply = uicontrol(handles.multip21,'Style','pushbutton','String','Apply','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@gui.pref_apply_Callback,'Tag','prefapply','TooltipString','Apply the new width. All data from the UI will be cleared');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 3];
handles.paneltext2 = uicontrol(handles.multip21,'Style','text','String','If some button texts are clipped or not readable, try to increase the panelwidth here.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext2');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 3];
handles.paneltext2 = uicontrol(handles.multip21,'Style','text','String','Warning: Current results and settings will be cleared.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext2');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.paneltext3 = uicontrol(handles.multip21,'Style','text','String','Change font size','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext3');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.textsizeup = uicontrol(handles.multip21,'Style','pushbutton','String','Increase','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@gui.font_size_change,1},'Tag','textsizeup','TooltipString','Increase the text size of buttons etc.');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.textsizedown = uicontrol(handles.multip21,'Style','pushbutton','String','Decrease','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@gui.font_size_change,-1},'Tag','textsizedown','TooltipString','Decrease the text size of buttons etc');

item=[0 item(2)+item(4)+margin parentitem(3) 4];
handles.paneltext4 = uicontrol(handles.multip21,'Style','text','String','Please note: This setting will currently not be saved. Because otherwise this might screw up your user interface permanently.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','paneltext4');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.flash_sync = uicontrol(handles.multip21,'Style','pushbutton','String','Flash firmware to synchronizer','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@gui.flash_sync_Callback,'Tag','flash_sync','TooltipString','Flash new firmware to OPTOLUTION synchronizer');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.detect_cam = uicontrol(handles.multip21,'Style','pushbutton','String','Detect connected cameras','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@acquisition.camera_info,'Tag','detect_cam','TooltipString','Detect connected cameras');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.detect_dongle = uicontrol(handles.multip21,'Style','pushbutton','String','Detect serial dongle','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@acquisition.serial_info,'Tag','detect_dongle','TooltipString','Detect if driver for the dongle is installed');


%% Multip22
handles.multip22 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Derive Temporal Parameters', 'Tag','multip22','fontweight','bold');
parentitem=get(handles.multip22, 'Position');
item=[0 0 0 0];

%item=[0 item(2)+item(4)+margin/3*2 parentitem(3) 7];
%handles.uipanel43 = uipanel(handles.multip22, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Calculate mean / sum', 'Tag','uipanel43','fontweight','bold');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.text153 = uicontrol(handles.multip22,'Style','text','String','Frames to process:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text153');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.selectedFramesMean = uicontrol(handles.multip22,'Style','edit','String','1:end','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','selectedFramesMean','TooltipString','Select which frames to include for calculating the mean velocity. E.g. "1,3,4,8:10"');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.append_replace = uicontrol(handles.multip22,'Style','popupmenu', 'Value', 1, 'String',{'append to dataset' 'replace all existing'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','append_replace','TooltipString','Append the newly calculated vector field to the current session, or replace previously calculated vector fields');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.meanmaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate mean','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@plot.temporal_operation_Callback, 1}, 'Tag','meanmaker','TooltipString','Calculate mean velocities and append an extra frame with the results');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.summaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate sum','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@plot.temporal_operation_Callback, 0}, 'Tag','summaker','TooltipString','Calculate sum of displacements and append an extra frame with the results');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.stdmaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate stdev','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@plot.temporal_operation_Callback, 2}, 'Tag','stdmaker','TooltipString','Calculate standard deviation of displacements and append an extra frame with the results');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.tkemaker = uicontrol(handles.multip22,'Style','pushbutton','String','Calculate TKE','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',{@plot.temporal_operation_Callback, 3}, 'Tag','tkemaker','TooltipString','Calculate turbulent kinetic energy and append an extra frame with the results');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.remove_temporal_frame = uicontrol(handles.multip22,'Style','pushbutton','String','Remove current','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@plot.remove_temporal_frame_Callback, 'Tag','remove_temporal_frame','TooltipString','Remove the currently displayed frame');


%% multip23
handles.multip23 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image based validation', 'Tag','multip23','fontweight','bold');
parentitem=get(handles.multip23, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.do_contrast_filter = uicontrol(handles.multip23,'Style','checkbox','String','Filter low contrast','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','do_contrast_filter','TooltipString','This filter removes vectors from regions where the input image contrast is low.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19a = uicontrol(handles.multip23,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19a');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.contrast_filter_thresh = uicontrol(handles.multip23,'Style','edit','String','0.001','Units','characters', 'Fontunits','points','Callback',@validate.contrast_filter_thresh_Callback, 'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','contrast_filter_thresh');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.suggest_contrast_filter = uicontrol(handles.multip23,'Style','pushbutton','String','Suggest threshold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Finds a threshold that discards vectors in the regions where image contrast is low. Use this as a starting point only.','Tag','suggest_contrast_filter','Callback', @validate.suggest_contrast_filter_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.do_bright_filter = uicontrol(handles.multip23,'Style','checkbox','String','Filter bright objects','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','do_bright_filter','TooltipString','This filter removes vectors from regions where the input image has connected bright objects.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19b = uicontrol(handles.multip23,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19b');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.bright_filter_thresh = uicontrol(handles.multip23,'Style','edit','String','0.001','Units','characters', 'Fontunits','points','Callback',@validate.bright_filter_thresh_Callback,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','bright_filter_thresh');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.suggest_bright_filter = uicontrol(handles.multip23,'Style','pushbutton','String','Suggest threshold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'TooltipString','Finds a threshold that discards vectors in the regions where bright objects are found. Use this as a starting point only.','Tag','suggest_bright_filter','Callback', @validate.suggest_bright_filter_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.do_corr2_filter = uicontrol(handles.multip23,'Style','checkbox','String','Correlation coefficient filter','Value',0,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','do_corr2_filter','TooltipString','This filter removes vectors from image areas that have a low correlation between image A and B. Especially useful after removing the background signal.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19corrfilter = uicontrol(handles.multip23,'Style','text','String','Threshold','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','text19corrfilter');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.corr_filter_thresh = uicontrol(handles.multip23,'Style','edit','String','0.5','Units','characters', 'Fontunits','points','Callback',@validate.corr_filter_thresh_Callback,'Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','corr_filter_thresh');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.interpol_missing2 = uicontrol(handles.multip23,'Style','checkbox','String','Interpolate missing data','Value',1,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','interpol_missing2','TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors','Callback',@validate.set_other_interpol_checkbox);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.apply_filter_current = uicontrol(handles.multip23,'Style','pushbutton','String','Apply to current frame','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.apply_filter_current_Callback,'Tag','apply_filter_current','TooltipString','Apply the filters to the current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_filter_all = uicontrol(handles.multip23,'Style','pushbutton','String','Apply to all frames','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.apply_filter_all_Callback,'Tag','apply_filter_all','TooltipString','Apply the filters to all frames');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.restore_all = uicontrol(handles.multip23,'Style','pushbutton','String','Undo all validations (all frames)','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @validate.restore_all_Callback,'Tag','restore_all','TooltipString','Remove all velocity filters for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.amount_nans = uicontrol(handles.multip23,'Style','text','String','Filtered data: 0 %','HorizontalAlignment','center','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','amount_nans');

%% Multip24
% General
handles.multip24 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image Acquisition', 'Tag','multip24','fontweight','bold');
parentitem=get(handles.multip24, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 10];
handles.uipanelac_general = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','General settings', 'Tag','uipanelac_general','fontweight','bold');

parentitem=get(handles.uipanelac_general, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.ac_projecttxt = uicontrol(handles.uipanelac_general,'Style','text', 'String','Project path:','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_projecttxt');

item=[0 item(2)+item(4) parentitem(3)/1.5 1.5];
handles.ac_project = uicontrol(handles.uipanelac_general,'Style','edit','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','','tag','ac_project');
set(handles.ac_project,'Fontsize', get(handles.ac_project,'Fontsize')-1);

item=[parentitem(3)/1.5 item(2) parentitem(3)/3 1.5];
handles.ac_browse = uicontrol(handles.uipanelac_general,'Style','pushbutton','String','Browse...','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.browse_Callback,'Tag','ac_browse','TooltipString','Browse for project folder. Images and configurations will be stored here.');

item=[0 item(2)+item(4)+margin*0.05 parentitem(3) 1];
handles.ac_configtxt = uicontrol(handles.uipanelac_general,'Style','text', 'String','Select configuration:','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_configtxt');

item=[0 item(2)+item(4) parentitem(3) 2];

available_PIV_configurations = { ...
    %	'Nd:YAG (SimpleSync) + pco.pixelfly usb' ...
    %	'Nd:YAG (SimpleSync) + pco.panda 26 DS' ...
    'Webcam demo (no synchronizer)' ...
    'PIVlab LD-PS + OPTOcam 2/80' ...
    'PIVlab LD-PS + pco.edge 26 DS CLHS' ...
    'PIVlab LD-PS + pco.panda 26 DS' ...
    'PIVlab LD-PS + pco.pixelfly usb' ...
    'PIVlab LD-PS + OPTRONIS Cyclone' ...
    'PIVlab LD-PS + Chronos' ...
    'PIVlab LD-PS + Basler acA2000-165um' ...
    'PIVlab LD-PS + FLIR FFY-U3-16S2M' ...
    };

handles.ac_config = uicontrol(handles.uipanelac_general,'Style','popupmenu', 'Value', 1, 'String',available_PIV_configurations,'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_config','TooltipString','Lists the available configurations (synchronizer + cameras)','Callback',@acquisition.select_capture_config_Callback);

item=[0 item(2)+item(4)+0.25 parentitem(3)/2 2];
handles.ac_comport = uicontrol(handles.uipanelac_general,'Style','popupmenu', 'String',{'COM1'},'Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_comport');

item=[parentitem(3)/2 item(2) parentitem(3)/2*0.9 2];
handles.ac_connect = uicontrol(handles.uipanelac_general,'Style','pushbutton','String','Connect','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.connect_Callback,'Tag','ac_connect','TooltipString','Connect to PIVlab-SimpleSync');

IndicatorPos=get(handles.ac_connect,'Position');

handles.ac_serialstatus = uicontrol(handles.uipanelac_general,'Style','edit','units','characters','HorizontalAlignment','center','position',[IndicatorPos(1)+IndicatorPos(3) IndicatorPos(2) 2 IndicatorPos(4)],'String','','tag','ac_serialstatus','BackgroundColor',[1 0 0],'Foregroundcolor',[1 1 1],'Enable','inactive','TooltipString','Status of the serial connection to PIVlab-SimpleSync');


% Sync control
parentitem=get(handles.multip24, 'Position');
item=[0 10.5 parentitem(3) 12+0.5];
handles.uipanelac_laser = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Synchronizer control', 'Tag','uipanelac_laser','fontweight','bold');

parentitem=get(handles.uipanelac_laser, 'Position');
item=[0 0 0 0];

item=[0 0 parentitem(3)/4*2.5 2];
handles.ac_fpstxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Frame rate in Hz:','tag','ac_fpstxt');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1.6];
handles.ac_fps = uicontrol(handles.uipanelac_laser,'Style','popupmenu','String',{'5' '3' '1.5' '1'},'Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.sync_settings_Callback,'Tag','ac_fps','TooltipString','Frame rate during PIV image capture','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.3 parentitem(3)/4*2.5 1];
handles.ac_interpulstxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Pulse distance in µs:','tag','ac_interpulstxt');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_interpuls = uicontrol(handles.uipanelac_laser,'Style','edit','String','250','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.sync_settings_Callback,'Tag','ac_interpuls','TooltipString','Pulse spacing of the laser','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2.5 1];
handles.ac_powertxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Laser energy in %:','tag','ac_powertxt');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_power = uicontrol(handles.uipanelac_laser,'Style','edit','String','100','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.sync_settings_Callback,'Tag','ac_power','TooltipString','Laser energy','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3) 1];
handles.ac_pulselengthtxt = uicontrol(handles.uipanelac_laser,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Pulse length: 0 µs','tag','ac_pulselengthtxt');

item=[0 item(2)+item(4)+margin*0.2 parentitem(3) 1.1];
handles.ac_enable_straddling_figure = uicontrol(handles.uipanelac_laser,'Style','checkbox','String','Timing graph','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_enable_straddling_figure','TooltipString','Show a graph with the timing of camera and laser pulses','Callback', @acquisition.sync_settings_Callback);

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2 2];
handles.ac_laserstatus = uicontrol(handles.uipanelac_laser,'Style','edit','units','characters','HorizontalAlignment','center','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','N/A','tag','ac_laserstatus','FontName','FixedWidth','BackgroundColor',[1 0 0],'Foregroundcolor',[0 0 0],'Enable','inactive','Fontweight','bold','TooltipString','Status of the laser');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4*2 2];
handles.ac_lasertoggle = uicontrol(handles.uipanelac_laser,'Style','Pushbutton','String','Toggle Laser','Fontweight','bold','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.lasertoggle_Callback,'Tag','ac_lasertoggle','TooltipString','Toggle laser on and off','interruptible','off','busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3)/2 1.5];
handles.ac_enable_ext_trigger = uicontrol(handles.uipanelac_laser,'Style','checkbox','String','Ext. trigger','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_enable_ext_trigger','TooltipString','Use external trigger input on PIVlab-SimpleSync','Callback', @acquisition.ext_trigger_xmsync_settings_Callback,'Visible','off');

item=[0 item(2) parentitem(3)/2 1.5];
handles.ac_enable_ext_trigger_oltsync = uicontrol(handles.uipanelac_laser,'Style','Pushbutton','String','Trigger mode','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_enable_ext_trigger_oltsync','TooltipString','Configure trigger input on PIVlab-SimpleSync','Callback', @acquisition.ext_trigger_oltsync_settings_Callback,'Visible','off');

item=[item(3) item(2) parentitem(3)/2 1.5];
handles.ac_device_control = uicontrol(handles.uipanelac_laser,'Style','pushbutton','String','Devices','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_device_control','TooltipString','Setup external devices (such as remote controlled seeding generator etc.)','Callback',@acquisition.device_control_Callback);


%item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 2];
%handles.ac_ext_trigger_settings = uicontrol(handles.uipanelac_laser,'Style','Pushbutton','String','Setup','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_ext_trigger_settings_Callback,'Tag','ac_ext_trigger_settings','TooltipString','Setup external trigger input on PIVlab-SimpleSync');


% Camera settings
parentitem=get(handles.multip24, 'Position');
item=[0 23.5 parentitem(3) 7];
handles.uipanelac_camsettings = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Camera settings', 'Tag','uipanelac_camsettings','fontweight','bold');

parentitem=get(handles.uipanelac_camsettings, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/8 parentitem(3)/4.1 1.5];
handles.ac_calibBinning = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','Binning','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @acquisition.calibBinning_Callback,'Tag','ac_calibBinning','TooltipString','Select pixel binning');

item=[parentitem(3)/4.1*1  item(2) parentitem(3)/4.1 1.5];
handles.ac_calibROI = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','ROI','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @acquisition.calibROI_Callback,'Tag','ac_calibROI','TooltipString','Select ROI in camera image');

item=[parentitem(3)/4.1*2  item(2) parentitem(3)/4.1 1.5];
handles.ac_lensctrl = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','Lens','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @acquisition.lens_control_Callback,'Tag','ac_lensctrl','TooltipString','Control camera lens');

item=[parentitem(3)/4.1*3  item(2) parentitem(3)/4.1 1.5];
handles.ac_camera_setup = uicontrol(handles.uipanelac_camsettings,'Style','pushbutton','String','Setup','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)],'Callback', @acquisition.camera_setup_Callback,'Tag','ac_camera_setup','TooltipString','Configure selected camera');


item=[0 item(2)+item(4)+margin/4 parentitem(3)/4.1 1.5];
handles.ac_cam_helper_txt = uicontrol(handles.uipanelac_camsettings,'Style','text','units','characters','HorizontalAlignment','left','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','Display:','tag','ac_cam_helper_txt');
item=[0 item(2)+item(4)+margin/8 parentitem(3)/3 1.5];
handles.ac_displ_sharp = uicontrol(handles.uipanelac_camsettings,'Style','checkbox','String','Sharpness','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)],'Tag','ac_displ_sharp','TooltipString','Display sharpness','Callback', @acquisition.display_cam_overlay_Callback,'Visible','on');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1.5];
handles.ac_displ_grid = uicontrol(handles.uipanelac_camsettings,'Style','checkbox','String','Grid','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)],'Tag','ac_displ_grid','TooltipString','Display grid','Callback', @acquisition.display_cam_overlay_Callback,'Visible','on');

%item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
%not working at the moment...
handles.ac_displ_hist = uicontrol(handles.uipanelac_camsettings,'Style','checkbox','String','Histogram','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)],'Tag','ac_displ_hist','TooltipString','Display histogram','Callback', @acquisition.display_cam_overlay_Callback,'Visible','off');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.calib_dolivedetect = uicontrol(handles.uipanelac_camsettings,'Style','checkbox','String','Calibration','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)],'Callback', @preproc.cam_live_detect_Callback,'Tag','calib_dolivedetect','TooltipString','Do realtime marker detection and image storage.');

% Calib capture

parentitem=get(handles.multip24, 'Position');
item=[0 27.5+3.5 parentitem(3) 4.5];

handles.uipanelac_calib = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Live image', 'Tag','uipanelac_calib','fontweight','bold');

parentitem=get(handles.uipanelac_calib, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.ac_expotxt = uicontrol(handles.uipanelac_calib,'Style','text', 'String','Exposure in ms: ','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_expotxt');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.ac_expo = uicontrol(handles.uipanelac_calib,'Style','edit','units','characters','HorizontalAlignment','right','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','50','tag','ac_expo','TooltipString','Exposure of the camera during calibration image capture','Callback', @acquisition.exposure_Callback);

item=[0 item(2)+item(4)+margin*0.25 parentitem(3)/4 1.5];
handles.ac_calibcapture = uicontrol(handles.uipanelac_calib,'Style','pushbutton','String','Start','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)],'Callback', @acquisition.calibcapture_Callback,'Tag','ac_calibcapture','TooltipString','Start live view of the camera','interruptible','on','BusyAction','queue');

item=[parentitem(3)/4*1 item(2) parentitem(3)/4 1.5];
handles.ac_calibsnapshot = uicontrol(handles.uipanelac_calib,'Style','pushbutton','String','Snapshot','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)],'Callback', @acquisition.camera_snapshot_Callback,'Tag','ac_calibsnapshot','TooltipString','Save current display','enable','on');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4 1.5];
handles.ac_calibsave = uicontrol(handles.uipanelac_calib,'Style','pushbutton','String','Save','Units','characters', 'Fontunits','points','Position',[item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)],'Callback', @acquisition.camera_stop_Callback,'Tag','ac_calibsave','TooltipString','Save last image','enable','off');

% PIV capture
parentitem=get(handles.multip24, 'Position');
item=[0 33+3.5 parentitem(3) 5];
handles.uipanelac_capture = uipanel(handles.multip24, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Capture PIV images', 'Tag','uipanelac_capture','fontweight','bold');

parentitem=get(handles.uipanelac_capture, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.ac_imgamounttxt = uicontrol(handles.uipanelac_capture,'Style','text', 'String','Image amount: ','Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_imgamounttxt');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.ac_imgamount = uicontrol(handles.uipanelac_capture,'Style','edit','units','characters','HorizontalAlignment','right', 'enable','off','position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'String','100','tag','ac_imgamount','TooltipString','Amount of double images to capture. If red: RAM most likely not sufficient.','Callback',@acquisition.image_amount_Callback);

%live PIV preview disabled
item=[parentitem(3)/2+parentitem(3)/4 item(2) parentitem(3)/4 1];
handles.ac_realtime = uicontrol(handles.uipanelac_capture,'Style','checkbox','units','characters','HorizontalAlignment','right','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)],'Value',0,'String','Live','tag','ac_realtime','TooltipString','Enable real-time PIV','Callback',@acquisition.realtime_Callback,'Visible','off');

item=[0 item(2)+item(4)+margin*0.25 parentitem(3)/3 1.5];
handles.ac_pivcapture = uicontrol(handles.uipanelac_capture,'Style','pushbutton','String','Start','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.piv_capture_Callback,'Tag','ac_pivcapture','TooltipString','Start PIV image capture and laser');

item=[parentitem(3)/3*1 item(2) parentitem(3)/5 1.5];
handles.ac_pivcapture_save = uicontrol(handles.uipanelac_capture,'Style','checkbox','units','characters','HorizontalAlignment','right','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)],'Value',0,'String','Save','tag','ac_pivcapture_save','TooltipString','Save PIV double images','Callback',@acquisition.pivcapture_save_Callback);

item=[parentitem(3)/3*1+parentitem(3)/5 item(2) parentitem(3)/5 1.5];
handles.ac_auto_interframe = uicontrol(handles.uipanelac_capture,'Style','Pushbutton','String','Auto','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_auto_interframe','TooltipString','Automatically determine suitable interframe time','Callback', @acquisition.automatic_interframe,'Visible','off');


item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.ac_pivstop = uicontrol(handles.uipanelac_capture,'Style','pushbutton','String','Abort','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @acquisition.camera_stop_Callback,'Tag','ac_pivstop','TooltipString','Cancel capture and discard images');

parentitem=get(handles.multip24, 'Position');
item=[0 30.5 parentitem(3) 2];
handles.ac_msgbox = uicontrol(handles.multip24,'Style','edit', 'Fontname','fixedwidth', 'enable','inactive','Max', 3, 'min', 1, 'String',{'Welcome to PIVlab' 'image acquisition!'},'Units','characters', 'Fontunits','points','HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','ac_msgbox','TooltipString','Messages','visible','off');
set(handles.ac_msgbox,'BackgroundColor', get (handles.ac_msgbox,'BackgroundColor')*0.95); %dim msgbox color


%% camera calibration
handles.multip26 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Camera calibration', 'Tag','multip26','fontweight','bold');
parentitem=get(handles.multip26, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 32];
handles.calib_imagedata = uipanel(handles.multip26, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Calibration image data', 'Tag','calib_imagedata','fontweight','bold');

parentitem=get(handles.calib_imagedata, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_undist_cam_label=uicontrol(handles.calib_imagedata,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'FontWeight','bold','Tag','calib_undist_cam_label');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_load_imgs = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Load target images','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_calibration_loadimages_Callback,'Tag','calib_load_imgs','TooltipString','Load images of the calibration target');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_fisheye = uicontrol(handles.calib_imagedata,'Style','checkbox','units','characters','HorizontalAlignment','right','position',[item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)],'Value',0,'String','fisheye camera','tag','calib_fisheye','TooltipString','Enable fisheye camera model for very high distortion lenses. Slow.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_estimateparams = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Estimate cam parameters','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_estimateparams_Callback,'Tag','calib_estimateparams','TooltipString','Detect charuco markers and estimate camera parameters');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1.5];
handles.calib_saveparams = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Save parameters','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_saveparams_Callback,'Tag','calib_saveparams','TooltipString','Save the camera parameters to a file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_loadparams = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Load parameters','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_loadparams_Callback,'Tag','calib_loadparams','TooltipString','Load camera parameters from a file');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.calib_clearparams = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Clear parameters','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_clearparams_Callback,'Tag','calib_clearparams','TooltipString','Clear camera parameters');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_showreproject = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Show reprojection errors','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_showreproject_Callback,'Tag','calib_showreproject','TooltipString','Show reprojection errors (should be below 1 pixel for a valid undistortion)');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_showdistortion = uicontrol(handles.calib_imagedata,'Style','pushbutton','String','Show lens distortion','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_showdistortion_Callback,'Tag','calib_showdistortion','TooltipString','Show camera lens distortion');

item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1.5];
uicontrol(handles.calib_imagedata,'Style','text','String','Output image size:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.calib_viewtype = uicontrol(handles.calib_imagedata,'Style','popupmenu','String',{'Cut away black borders' 'Same size as input image' 'Include black borders'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_viewtype','TooltipString','Select how black borders should be treated','Callback',@preproc.cam_change_viewtype_Callback);

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.calib_usecalibration = uicontrol(handles.calib_imagedata,'Style','checkbox','String','Enable camera calibration', 'Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_usecalibration','TooltipString','Enable camera calibration / undistortion','Callback', @preproc.cam_enable_cam_calib_Callback);

%% camera rectification
handles.multip27 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Image rectification', 'Tag','multip27','fontweight','bold');
parentitem=get(handles.multip27, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 32];
handles.rect_imagedata = uipanel(handles.multip27, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Rectification image data', 'Tag','rect_imagedata','fontweight','bold');

parentitem=get(handles.rect_imagedata, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_rect_cam_label=uicontrol(handles.rect_imagedata,'Style','text','String','N/A','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'FontWeight','bold','Tag','calib_rect_cam_label');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_load_imgs = uicontrol(handles.rect_imagedata,'Style','pushbutton','String','Load target image','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_rectification_loadimages_Callback,'Tag','rect_load_imgs','TooltipString','Load an image of the calibration target aligned with your target coordinate system and inside the laser sheet.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_show_points = uicontrol(handles.rect_imagedata,'Style','pushbutton','String','Show detected markers','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_rectification_show_points_Callback,'Tag','rect_show_points','TooltipString','Show all points that can be detected');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_show_rectified = uicontrol(handles.rect_imagedata,'Style','pushbutton','String','Show rectified board','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_rectification_show_rectified_Callback,'Tag','rect_show_rectified','TooltipString','Show a preview of the undistorted calibration board');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_show_cam_position = uicontrol(handles.rect_imagedata,'Style','pushbutton','String','Show camera position','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_rectification_show_cam_position_Callback,'Tag','rect_show_cam_position','TooltipString','Show a 3D scene of camera and board position');

item=[0 item(2)+item(4)+margin parentitem(3)/2 1.5];
uicontrol(handles.rect_imagedata,'Style','text','String','Upscaling:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1.5];
handles.calib_upscale = uicontrol(handles.rect_imagedata,'Style','popupmenu','String',{'1x' '2x'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_upscale','TooltipString','Upscaling factor reducing then effect of image interpolations, but making analyses slower','Callback', @preproc.cam_rectification_upscale_Callback);

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.calib_userectification = uicontrol(handles.rect_imagedata,'Style','checkbox','String','Enable image rectification', 'Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_userectification','TooltipString','Use image rectification','Callback', @preproc.cam_enable_cam_rectification_Callback);


%% Marker board setup
handles.multip28 = uipanel(MainWindow, 'Units','characters', 'Position', [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels],'title','Marker board setup', 'Tag','multip28','fontweight','bold');
parentitem=get(handles.multip28, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 15];
handles.calib_markersetup = uipanel(handles.multip28, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Properties', 'Tag','calib_markersetup','fontweight','bold');

parentitem=get(handles.calib_markersetup, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
uicontrol(handles.calib_markersetup,'Style','text','String','Board type:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_boardtype = uicontrol(handles.calib_markersetup,'Style','popupmenu','String',{'ChArUco DICT_4X4_1000'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_boardtype','TooltipString','Select the type of calibration marker board');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
uicontrol(handles.calib_markersetup,'Style','text','String','Origin color:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_origincolor = uicontrol(handles.calib_markersetup,'Style','popupmenu','String',{'Black' 'White'},'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_origincolor','TooltipString','Color of the top left checker');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
uicontrol(handles.calib_markersetup,'Style','text','String','Rows:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_rows = uicontrol(handles.calib_markersetup,'Style','edit','String','23','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_rows','TooltipString','Amount of rows of the checkerboard');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
uicontrol(handles.calib_markersetup,'Style','text','String','Columns:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_columns = uicontrol(handles.calib_markersetup,'Style','edit','String','24','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_columns','TooltipString','Amount of columns of the checkerboard');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
uicontrol(handles.calib_markersetup,'Style','text','String','Checker size:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_checkersize = uicontrol(handles.calib_markersetup,'Style','edit','String','10','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_checkersize','TooltipString','Size of the checkers');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
uicontrol(handles.calib_markersetup,'Style','text','String','Marker size:','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_markersize = uicontrol(handles.calib_markersetup,'Style','edit','String','8','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_markersize','TooltipString','Size of the markers');

item=[0 item(2)+item(4)+margin parentitem(3)/1.5 1.5];
handles.calib_find_params = uicontrol(handles.calib_markersetup,'Style','pushbutton','String','Guess parameters','Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','calib_find_params','TooltipString','Automatically guess charuco parameters','Callback', @preproc.cam_find_charuco_parameters_Callback);

%{
item=[0 0 0 0];
parentitem=get(handles.multip28, 'Position');
item=[0 item(2)+item(4)+15+margin parentitem(3) 5];
handles.calib_livedetection = uipanel(handles.multip28, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Image acquisition settings', 'Tag','calib_livedetection','fontweight','bold');
parentitem=get(handles.calib_livedetection, 'Position');
item=[0 0 0 0];

item=[0 item(2)+margin / 4 parentitem(3) 1.5];
handles.calib_dolivedetect = uicontrol(handles.calib_livedetection,'Style','checkbox','String','Enable live detection + storage','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_live_detect_Callback,'Tag','calib_dolivedetect','TooltipString','Do realtime marker detection and image storage.');
%}
item=[0 0 0 0];
parentitem=get(handles.multip28, 'Position');
item=[0 item(2)+item(4)+20+margin*2 parentitem(3) 5];
handles.calib_generate = uipanel(handles.multip28, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Marker board generation', 'Tag','calib_generate','fontweight','bold');
parentitem=get(handles.calib_generate, 'Position');
item=[0 0 0 0];

item=[0 item(2)+margin / 4 parentitem(3) 1.5];
handles.calib_generateboard = uicontrol(handles.calib_generate,'Style','pushbutton','String','Generate Charuco board','Value',0,'Units','characters','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @preproc.cam_generateboard_Callback,'Tag','calib_generateboard','TooltipString','Generate a suitable Charuco board');





%% Image acquisition: load last device and COM port
try
    warning off
    load('PIVlab_settings_default.mat','last_selected_device','last_selected_fps','last_selected_pulsedist','last_selected_energy');
    if exist('last_selected_device','var')
        if ~isempty(last_selected_device)
            set(handles.ac_config, 'value',last_selected_device);
        else
            set(handles.ac_config, 'value',1);
        end
    end
    if exist('last_selected_fps','var')
        if ~isempty(last_selected_fps)
            pause(0.01)
            set(handles.ac_fps, 'value',last_selected_fps);
        else
            set(handles.ac_fps, 'value',1);
        end
    end
    if exist('last_selected_pulsedist','var')
        set(handles.ac_interpuls, 'String',last_selected_pulsedist);
    end
    if exist('last_selected_energy','var')
        set(handles.ac_power, 'String',last_selected_energy);
    end
    load('PIVlab_settings_default.mat','selected_com_port');
    if exist('selected_com_port','var') && ~isempty(selected_com_port)
        gui.put('selected_com_port',selected_com_port);
    end
    warning on
catch
end
gui.put('multitiff',0); %default for compatibility: Not a multitiff.
gui.put('pcopanda_dbl_image',0); %default for compatibility: Not a multitiff.

disp('-> UI generated.')