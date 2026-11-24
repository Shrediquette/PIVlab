function generateUI % All the GUI elements are created here
default = gui.default_settings; % default values of all settings
handles = guihandles; %alle handles mit tag laden und ansprechbar machen
MainWindow=getappdata(0,'hgui');
guidata(MainWindow,handles)

panelwidth=gui.retr('panelwidth');
margin=gui.retr('margin');
panelheighttools=gui.retr('panelheighttools');
panelheightpanels=gui.retr('panelheightpanels');
Figure_Size = get(MainWindow, 'Position');
mainpanel_pos = [0+margin Figure_Size(4)-panelheightpanels-margin panelwidth panelheightpanels]; % position of the main panels (multip..)

%% Toolspanel
handles.tools = gui.ui_panel(MainWindow, [0+margin Figure_Size(4)-panelheightpanels-panelheighttools-margin panelwidth panelheighttools], 'Tools', ...
    'Tag','tools');
parentitem=get(handles.tools, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text29 = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'Current point:');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.u_cp = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'N/A', 'tag','u_cp');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.v_cp = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'N/A', 'tag','v_cp');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.x_cp = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'N/A', 'tag','x_cp');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.y_cp = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'N/A', 'tag','y_cp');

item=[0 item(2)+item(4) parentitem(3) 1];
handles.scalar_cp = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'N/A', 'tag','scalar_cp');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.filenameshow = gui.ui_text(handles.tools, pos(parentitem,item,margin), 'N/A', ...
    'Horizontalalignment','center', 'tag','filenameshow');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.fileselector = gui.ui(handles.tools, 'slider', pos(parentitem,item,margin), 'Horizontalalignment','center', ...
    'max',4, 'min',1, 'value',1, 'sliderstep',[0.5 1], 'Callback',@gui.fileselector_Callback, 'tag','fileselector', ...
    'TooltipString','Step through your frames here', 'interruptible','off', 'BusyAction','cancel', ...
    'UserData','not_a_setting');%,'Interruptible','off','busyaction','cancel');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.togglepair = gui.ui(handles.tools, 'togglebutton', pos(parentitem,item,margin), 'string','Toggle', ...
    'Callback',@gui.togglepair_Callback, 'tag','togglepair', 'TooltipString','Toggle images within a frame', ...
    'interruptible','off', 'BusyAction','cancel', 'UserData','not_a_setting');%,'Interruptible','off','busyaction','cancel');

item=[0  item(2)+item(4)+margin*0.2 parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.toggle_parallel = gui.ui(handles.tools, 'togglebutton', pos(parentitem,item,margin), ...
    'Callback',@misc.toggle_parallel_Callback, 'tag','toggle_parallel', 'UserData','not_a_setting');

item=[parentitem(3)/2/2 item(2) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.stereo_camera_toggle = gui.ui_button(handles.tools, pos(parentitem,item,margin), 'CAM 1', @stereo.camera_toggle_Callback, ...
    'Fontweight','bold', 'tag','stereo_camera_toggle', ...
    'TooltipString','Two cameras: switch between camera 1 and camera 2 (Ctrl+Shift+1 / Ctrl+Shift+2)', ...
    'Visible','off', 'UserData','not_a_setting');

item=[parentitem(3)/2 item(2) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.zoomon = gui.ui(handles.tools, 'togglebutton', pos(parentitem,item,margin), 'Callback',@gui.zoomon_Callback, ...
    'tag','zoomon', 'TooltipString','Zoom', 'UserData','not_a_setting');

item=[parentitem(3)/2+parentitem(3)/2/2 item(2) parentitem(3)/2/2 parentitem(3)/2/2/4];
handles.panon = gui.ui(handles.tools, 'togglebutton', pos(parentitem,item,margin), 'Callback',@gui.panon_Callback, ...
    'tag','panon', 'TooltipString','Pan', 'UserData','not_a_setting');

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

handles.quick = gui.ui_panel(MainWindow, [0+margin*0.5 0+margin*0.5+panelheighttools+quickheight quickwidth quickheight], 'Main tasks quick access', ...
    'Tag','quick', 'Visible','on');
handles.quick1 = gui.ui(handles.quick, 'togglebutton', [1*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight], ...
    'Callback',@gui.quick1_Callback, 'tag','quick1', 'TooltipString','Load images', 'UserData','not_a_setting');
handles.quick2 = gui.ui(handles.quick, 'togglebutton', [2*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight], ...
    'Callback',@gui.quick2_Callback, 'tag','quick2', 'TooltipString','Mask generation', 'UserData','not_a_setting');
handles.quick3 = gui.ui(handles.quick, 'togglebutton', [3*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight], ...
    'Callback',@gui.quick3_Callback, 'tag','quick3', 'TooltipString','Pre-processing', 'UserData','not_a_setting');
handles.quick4 = gui.ui(handles.quick, 'togglebutton', [4*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight], ...
    'Callback',@gui.quick4_Callback, 'tag','quick4', 'TooltipString','PIV settings', 'UserData','not_a_setting');
handles.quick5 = gui.ui(handles.quick, 'togglebutton', [5*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight], ...
    'Callback',@gui.quick5_Callback, 'tag','quick5', 'TooltipString','Analyze', 'UserData','not_a_setting');
handles.quick6 = gui.ui(handles.quick, 'togglebutton', [6*(quickwidth/(iconamount-1))-(quickwidth/(iconamount-1)) 0.1 iconwidth iconheight], ...
    'Callback',@gui.quick6_Callback, 'tag','quick6', 'TooltipString','Calibrate', 'UserData','not_a_setting');

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
handles.toolprogress = gui.ui_panel(MainWindow, [0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight], 'Progress', ...
    'Tag','toolprogress', 'Visible','on');
parentitem=get(handles.toolprogress, 'Position');
item=[margin 0.4 parentitem(3) 1];
handles.toolprogress_bg = gui.ui_text(handles.toolprogress, pos(parentitem,item,margin), '', ...
    'BackgroundColor',[0.85 0.85 0.85], 'Enable','off');
handles.toolprogress_fg = gui.ui_text(handles.toolprogress, [item(1)+margin parentitem(4)-item(4)-margin-item(2) 0 item(4)], '', ...
    'BackgroundColor','g', 'Enable','off');
gui.put('handle_toolprogress_bg',handles.toolprogress_bg); %for faster access in update loop
gui.put('handle_toolprogress_fg',handles.toolprogress_fg);


%% Multip01
handles.multip01 = gui.ui_panel(MainWindow, mainpanel_pos, 'Input data', ...
    'Tag','multip01');
parentitem=get(handles.multip01, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.loadimgsbutton = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Import images', {@import.loadimgsbutton_Callback,1,[]}, ...
    'Fontsize',12, 'TooltipString','Load image data');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.stereo_import = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Import multi-camera images', @import.stereo_import_Callback, ...
    'Fontsize',12, 'Tag','stereo_import', ...
    'TooltipString','Import the images of camera 1 and camera 2: stereo-PIV (u, v, w) or one larger field of view (u, v), chosen from the camera geometry by "Compute 3D alignment" (Ctrl+Shift+O)');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.loadvideobutton = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Convert + import video', @import.convertvideobutton_Callback, ...
    'Fontsize',12, 'TooltipString','Convert a video to lossless image files, then load them (time-resolved)');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.loadsessionbutton = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Load session', @import.load_session_Callback, ...
    'Fontsize',12, 'TooltipString','Load previously saved session file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.acquirebutton = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Acquire images', @acquisition.capture_images_Callback, ...
    'Fontsize',12, 'TooltipString','Acquire PIV images in PIVlab');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.reset_gui = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Reset PIVlab GUI', @gui.reset_gui_Callback, ...
    'Fontsize',12, 'Tag','reset_gui', 'Fontangle','italic', ...
    'TooltipString','Remove all images, results, masks and calibrations and set all settings to their defaults, as after a new start of PIVlab');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.link_to_manual = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Read Manual', @gui.pivlabmanual_Callback, ...
    'Fontsize',12, 'TooltipString','Open the PIVlab manual', 'Foregroundcolor',[0.2 0.4 1], 'Fontangle','italic');

item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 1];
handles.text2 = gui.ui_text(handles.multip01, pos(parentitem,item,margin), 'Image list:');

PIVver=gui.retr('PIVver');
item=[0 item(2)+item(4) parentitem(3) 12];
handles.filenamebox = gui.ui(handles.multip01, 'listbox', pos(parentitem,item,margin), 'max',3, 'min',1, ...
    'String',{['Welcome to PIVlab ' PIVver '.'] 'Add images by clicking the' '"Import images" button above.'}, ...
    'Callback',@gui.filenamebox_Callback, 'tag','filenamebox', ...
    'TooltipString','This list displays the frames that you currently loaded', 'UserData','not_a_setting');
gui.put('standard_bg_color',get(handles.filenamebox,'Backgroundcolor'));

item=[0 item(2)+item(4)+margin/8 parentitem(3)/3*2 2];
handles.remove_imgs = gui.ui_button(handles.multip01, pos(parentitem,item,margin), 'Remove images', @import.remove_images_from_list, ...
    'Tag','remove_imgs', 'TooltipString','Remove images from the image list', 'enable','off');

item=[0 item(2)+item(4)+0.4 parentitem(3) 3];
handles.text4 = gui.ui_text(handles.multip01, pos(parentitem,item,margin), 'Use the scrollbar in the "Tools" panel to cycle through the images.');

item=[0 item(2)+item(4) parentitem(3) 4];
handles.imsize = gui.ui_text(handles.multip01, pos(parentitem,item,margin), 'N/A', 'tag','imsize');

%% Multip02
handles.multip02 = gui.ui_panel(MainWindow, mainpanel_pos, 'Exclusions', ...
    'Tag','multip02');
parentitem=get(handles.multip02, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 12];
handles.uipanel5 = gui.ui_panel(handles.multip02, pos(parentitem,item,margin), 'Region of interest');

parentitem=get(handles.uipanel5, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.roi_hint = gui.ui_text(handles.uipanel5, pos(parentitem,item,margin), 'ROI inactive', ...
    'Horizontalalignment','center', 'tag','roi_hint');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
handles.roi_select = gui.ui_button(handles.uipanel5, pos(parentitem,item,margin), 'Select ROI', @roi.select_Callback, ...
    'TooltipString','Draw a rectangle for selecting a region of interest');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_roi = gui.ui_button(handles.uipanel5, pos(parentitem,item,margin), 'Clear ROI', @roi.clear_roi_Callback, ...
    'TooltipString','Remove the ROI');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/4 1.5];
handles.text155 = gui.ui_text(handles.uipanel5, pos(parentitem,item,margin), 'x:');

item=[parentitem(3)/4 item(2) parentitem(3)/4 1.5];
handles.text156 = gui.ui_text(handles.uipanel5, [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], 'y:');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4 1.5];
handles.text157 = gui.ui_text(handles.uipanel5, [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], 'width:');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1.5];
handles.text158 = gui.ui_text(handles.uipanel5, [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], 'height:');

item=[parentitem(3)/4*0+margin item(2)+item(4) parentitem(3)/4 1.5];
handles.ROI_Man_x = gui.ui(handles.uipanel5, 'edit', [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], ...
    'String','', 'tag','ROI_Man_x', 'Callback',@roi.Man_ROI_Callback, 'UserData','not_a_setting');

item=[parentitem(3)/4*1+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_y = gui.ui(handles.uipanel5, 'edit', [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], ...
    'String','', 'tag','ROI_Man_y', 'Callback',@roi.Man_ROI_Callback, 'UserData','not_a_setting');

item=[parentitem(3)/4*2+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_w = gui.ui(handles.uipanel5, 'edit', [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], ...
    'String','', 'tag','ROI_Man_w', 'Callback',@roi.Man_ROI_Callback, 'UserData','not_a_setting');

item=[parentitem(3)/4*3+margin item(2) parentitem(3)/4 1.5];
handles.ROI_Man_h = gui.ui(handles.uipanel5, 'edit', [item(1) parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)], ...
    'String','', 'tag','ROI_Man_h', 'Callback',@roi.Man_ROI_Callback, 'UserData','not_a_setting');


%% Multip25 (new mask)
handles.multip25 = gui.ui_panel(MainWindow, mainpanel_pos, 'Image masking', ...
    'Tag','multip25');
parentitem=get(handles.multip25, 'Position');
item=[0 0 0 0];


%Edit or preview mode
item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.text252 = gui.ui_text(handles.multip25, pos(parentitem,item,margin), 'Mode:');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_edit_mode = gui.ui(handles.multip25, 'popupmenu', pos(parentitem,item,margin), ...
    'String',{'Edit mask','Preview mask'}, 'Tag','mask_edit_mode', 'Callback',@mask.edit_mode_Callback, ...
    'TooltipString','Switch between mask edit mode and mask preview mode', 'UserData','not_a_setting');


%basic or expert mask capabilities
item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 1.5];
handles.text251 = gui.ui_text(handles.multip25, pos(parentitem,item,margin), 'Capabilities:', 'Tag','text251'); % tag: hidden in Basic mode (PIVlab_hidden_elements.txt)

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_basic_expert = gui.ui_setting(handles.multip25, 'popupmenu', pos(parentitem,item,margin), default.masks, 'mask_basic_expert', ...
    'String',{'Basic','Expert'}, 'Callback',@mask.basic_expert_Callback, ...
    'TooltipString','Switch betwenn basic mask generation and advanced mask generation modes');

%panel Polygon mask items
item=[0 item(2)+item(4)+margin/8 parentitem(3) 8];
handles.uipanel25_1 = gui.ui_panel(handles.multip25, pos(parentitem,item,margin), 'Polygon mask items', ...
    'Tag','uipanel25_1');

parentitem=get(handles.uipanel25_1, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_add_freehand = gui.ui_button(handles.uipanel25_1, pos(parentitem,item,margin), 'Free hand', {@mask.add_Callback,'freehand'}, ...
    'TooltipString','Add a freehand mask');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_add_assisted = gui.ui_button(handles.uipanel25_1, pos(parentitem,item,margin), 'Assisted f.h.', {@mask.add_Callback,'assisted'}, ...
    'TooltipString','Add an assisted freehand mask');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_add_circle = gui.ui_button(handles.uipanel25_1, pos(parentitem,item,margin), 'Circle', {@mask.add_Callback,'circle'}, ...
    'TooltipString','Add a circular mask');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_add_rectangle = gui.ui_button(handles.uipanel25_1, pos(parentitem,item,margin), 'Rectangle', {@mask.add_Callback,'rectangle'}, ...
    'TooltipString','Add a rectangular mask');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_add_polygon = gui.ui_button(handles.uipanel25_1, pos(parentitem,item,margin), 'Polygon', {@mask.add_Callback,'polygon'}, ...
    'TooltipString','Add a polygon mask');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.mask_import = gui.ui_button(handles.uipanel25_1, pos(parentitem,item,margin), 'Import pixel mask', @mask.import_Callback, ...
    'Tag','mask_import', 'TooltipString','Import a user generated mask from a binary image file');

%panel expert mask

parentitem=get(handles.multip25, 'Position');

item=[0 3.75 parentitem(3) 23.25];
handles.uipanel25_2 = gui.ui_panel(handles.multip25, pos(parentitem,item,margin), 'Generate masks from PIV images', ...
    'Tag','uipanel25_2', 'Visible','off');
item=[0 0 0 0];
parentitem=get(handles.uipanel25_2, 'Position');


item=[0 0 parentitem(3) 1.5];
handles.mask_bright_or_dark = gui.ui_setting(handles.uipanel25_2, 'popupmenu', pos(parentitem,item,margin), default.masks, 'mask_bright_or_dark', ...
    'String',{'Bright area mask generator','Dark area mask generator','Low contrast area mask generator', 'Custom script (coming soon)'}, ...
    'Callback',@mask.bright_or_dark_Callback, 'TooltipString','Select different automatic mask generators here');


%% bright area mask generator
item=[0 1.5+margin/2 parentitem(3) 14];
handles.uipanel25_3 = gui.ui_panel(handles.uipanel25_2, pos(parentitem,item,margin), 'Bright area mask generator', ...
    'Tag','uipanel25_3', 'Visible','on');
item=[0 0 0 0];
parentitem=get(handles.uipanel25_3, 'Position');

checkbox_width = parentitem(3)/10*1;
filter_text_width=parentitem(3)/10*4;
size_text_width=parentitem(3)/10*3;
size_width=parentitem(3)/10*1.5;

%binarize
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.binarize_enable = gui.ui_setting(handles.uipanel25_3, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'binarize_enable', ...
    'String','', 'Callback',@mask.binarize_enable_Callback, 'TooltipString','Enable this mask generator');

item=[checkbox_width item(2) filter_text_width 1];
handles.binarize_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Enable');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.binarize_threshold_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Threshold:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.binarize_threshold = gui.ui_setting(handles.uipanel25_3, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'binarize_threshold', ...
    'TooltipString','Image binarization threshold');


%medfilt
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_medfilt_enable = gui.ui_setting(handles.uipanel25_3, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_medfilt_enable', ...
    'String','', 'TooltipString','Use a median filter to smooth the input to the binarization');

item=[checkbox_width item(2) filter_text_width 1];
handles.median_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Median filter');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.median_size_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.median_size = gui.ui_setting(handles.uipanel25_3, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'median_size', ...
    'TooltipString','Size of the median kernel');



%Imopen/imclose
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imopen_imclose_enable = gui.ui_setting(handles.uipanel25_3, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_imopen_imclose_enable', ...
    'String','', 'TooltipString','Enable morphological opening or closing of image');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imopen_text = uicontrol(handles.uipanel25_2,'Style','text', 'String','imopen','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)]);
handles.imopen_imclose_selection = gui.ui_setting(handles.uipanel25_3, 'popupmenu', pos(parentitem,item,margin,margin/4), default.masks, 'imopen_imclose_selection', ...
    'String',{'Morphologically open image','Morphologically close image'}, ...
    'TooltipString','Select morphological open or close');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imopen_imclose_size_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imopen_imclose_size = gui.ui_setting(handles.uipanel25_3, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'imopen_imclose_size', ...
    'TooltipString','Size of the structuring element');



%imdilate/imerode
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imdilate_imerode_enable = gui.ui_setting(handles.uipanel25_3, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_imdilate_imerode_enable', ...
    'String','', 'TooltipString','Enable image dilation or image erosion');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imclose_text = uicontrol(handles.uipanel25_2,'Style','text', 'String','imclose','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)]);
handles.imdilate_imerode_selection = gui.ui_setting(handles.uipanel25_3, 'popupmenu', pos(parentitem,item,margin,margin/4), default.masks, 'imdilate_imerode_selection', ...
    'String',{'Dilate image','Erode image'}, 'TooltipString','Choose between erosion or dilation');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imdilate_imerode_size_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imdilate_imerode_size = gui.ui_setting(handles.uipanel25_3, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'imdilate_imerode_size', ...
    'TooltipString','Size of the structuring element');



%remove small
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_remove_enable = gui.ui_setting(handles.uipanel25_3, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_remove_enable', ...
    'String','', 'TooltipString','Enable the removal of small blobs');

item=[checkbox_width item(2) filter_text_width 1];
handles.remove_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Remove blots');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.remove_size_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.remove_size = gui.ui_setting(handles.uipanel25_3, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'remove_size', ...
    'TooltipString','Maximum area (in px) of the blobs to be removed');

%fillholes
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_fill_enable = gui.ui_setting(handles.uipanel25_3, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_fill_enable', ...
    'String','', 'TooltipString','Enable hole filling');

item=[checkbox_width item(2) filter_text_width 1];
handles.fill_text = gui.ui_text(handles.uipanel25_3, pos(parentitem,item,margin,margin/4), 'Fill holes');


%% dark area mask generator
parentitem=get(handles.uipanel25_2, 'Position');
item=[0 1.5+margin/2 parentitem(3) 14];
handles.uipanel25_5 = gui.ui_panel(handles.uipanel25_2, pos(parentitem,item,margin), 'Dark area mask generator', ...
    'Tag','uipanel25_5', 'Visible','off');
item=[0 0 0 0];

parentitem=get(handles.uipanel25_5, 'Position');

%binarize
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.binarize_enable_2 = gui.ui_setting(handles.uipanel25_5, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'binarize_enable_2', ...
    'String','', 'Callback',@mask.binarize_enable_2_Callback, 'TooltipString','Enable this mask generator');

item=[checkbox_width item(2) filter_text_width 1];
handles.binarize_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Enable');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.binarize_threshold_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Threshold:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.binarize_threshold_2 = gui.ui_setting(handles.uipanel25_5, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'binarize_threshold_2', ...
    'TooltipString','Image binarization threshold');

%medfilt
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_medfilt_enable_2 = gui.ui_setting(handles.uipanel25_5, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_medfilt_enable_2', ...
    'String','', 'TooltipString','Use a median filter to smooth the input to the binarization');

item=[checkbox_width item(2) filter_text_width 1];
handles.median_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Median filter');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.median_size_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.median_size_2 = gui.ui_setting(handles.uipanel25_5, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'median_size_2', ...
    'TooltipString','Size of the median kernel');


%Imopen/imclose
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imopen_imclose_enable_2 = gui.ui_setting(handles.uipanel25_5, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_imopen_imclose_enable_2', ...
    'String','', 'TooltipString','Enable morphological opening or closing of image');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imopen_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imopen','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)]);
handles.imopen_imclose_selection_2 = gui.ui_setting(handles.uipanel25_5, 'popupmenu', pos(parentitem,item,margin,margin/4), default.masks, 'imopen_imclose_selection_2', ...
    'String',{'Morphologically open image','Morphologically close image'}, ...
    'TooltipString','Select morphological open or close');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imopen_imclose_size_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imopen_imclose_size_2 = gui.ui_setting(handles.uipanel25_5, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'imopen_imclose_size_2', ...
    'TooltipString','Size of the structuring element');

%imdilate/imerode
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imdilate_imerode_enable_2 = gui.ui_setting(handles.uipanel25_5, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_imdilate_imerode_enable_2', ...
    'String','', 'TooltipString','Enable image dilation or image erosion');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imclose_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imclose','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)]);
handles.imdilate_imerode_selection_2 = gui.ui_setting(handles.uipanel25_5, 'popupmenu', pos(parentitem,item,margin,margin/4), default.masks, 'imdilate_imerode_selection_2', ...
    'String',{'Dilate image','Erode image'}, 'TooltipString','Choose between erosion or dilation');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imdilate_imerode_size_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imdilate_imerode_size_2 = gui.ui_setting(handles.uipanel25_5, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'imdilate_imerode_size_2', ...
    'TooltipString','Size of the structuring element');

%remove small
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_remove_enable_2 = gui.ui_setting(handles.uipanel25_5, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_remove_enable_2', ...
    'String','', 'TooltipString','Enable the removal of small blobs');

item=[checkbox_width item(2) filter_text_width 1];
handles.remove_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Remove blots');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.remove_size_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.remove_size_2 = gui.ui_setting(handles.uipanel25_5, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'remove_size_2', ...
    'TooltipString','Maximum area (in px) of the blobs to be removed');

%fillholes
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_fill_enable_2 = gui.ui_setting(handles.uipanel25_5, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_fill_enable_2', ...
    'String','', 'TooltipString','Enable hole filling');

item=[checkbox_width item(2) filter_text_width 1];
handles.fill_text_2 = gui.ui_text(handles.uipanel25_5, pos(parentitem,item,margin,margin/4), 'Fill holes');



%% low contrast mask generator
parentitem=get(handles.uipanel25_2, 'Position');
item=[0 1.5+margin/2 parentitem(3) 14];
handles.uipanel25_7 = gui.ui_panel(handles.uipanel25_2, pos(parentitem,item,margin), 'Low contrast mask generator', ...
    'Tag','uipanel25_7', 'Visible','off');
item=[0 0 0 0];

parentitem=get(handles.uipanel25_7, 'Position');

%low contrast
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.low_contrast_mask_enable = gui.ui_setting(handles.uipanel25_7, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'low_contrast_mask_enable', ...
    'String','', 'Callback',@mask.low_contrast_mask_enable_Callback, 'TooltipString','Enable this mask generator');

item=[checkbox_width item(2) filter_text_width-3 1];
handles.low_contrast_mask_text = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Enable');

item=[checkbox_width+filter_text_width-3 item(2) size_text_width 1];
handles.low_contrast_mask_text_2 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Threshold:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width-3+size_text_width item(2) size_width+3 1];
handles.low_contrast_mask_threshold = gui.ui_setting(handles.uipanel25_7, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'low_contrast_mask_threshold', ...
    'TooltipString','Image binarization threshold');

item=[parentitem(3)/3  item(2)+item(4)+margin/8 parentitem(3)/3*2 1.5];
handles.low_contrast_mask_threshold_suggest = gui.ui_button(handles.uipanel25_7, pos(parentitem,item,margin), 'Suggest threshold', @mask.low_contrast_threshold_suggest_Callback, ...
    'Tag','low_contrast_mask_threshold_suggest', ...
    'TooltipString','Suggest a suitable starting point for the threshold');


%medfilt
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_medfilt_enable_3 = gui.ui_setting(handles.uipanel25_7, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_medfilt_enable_3', ...
    'String','', 'TooltipString','Use a median filter to smooth the input to the binarization');

item=[checkbox_width item(2) filter_text_width 1];
handles.median_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Median filter');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.median_size_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.median_size_3 = gui.ui_setting(handles.uipanel25_7, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'median_size_3', ...
    'TooltipString','Size of the median kernel');


%Imopen/imclose
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imopen_imclose_enable_3 = gui.ui_setting(handles.uipanel25_7, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_imopen_imclose_enable_3', ...
    'String','', 'TooltipString','Enable morphological opening or closing of image');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imopen_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imopen','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)]);
handles.imopen_imclose_selection_3 = gui.ui_setting(handles.uipanel25_7, 'popupmenu', pos(parentitem,item,margin,margin/4), default.masks, 'imopen_imclose_selection_3', ...
    'String',{'Morphologically open image','Morphologically close image'}, ...
    'TooltipString','Select morphological open or close');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imopen_imclose_size_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imopen_imclose_size_3 = gui.ui_setting(handles.uipanel25_7, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'imopen_imclose_size_3', ...
    'TooltipString','Size of the structuring element');

%imdilate/imerode
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.5];
handles.mask_imdilate_imerode_enable_3 = gui.ui_setting(handles.uipanel25_7, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_imdilate_imerode_enable_3', ...
    'String','', 'TooltipString','Enable image dilation or image erosion');

item=[checkbox_width item(2) filter_text_width 1.5];
%handles.imclose_text_2 = uicontrol(handles.uipanel25_5,'Style','text', 'String','imclose','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin/4 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2/4 item(4)]);
handles.imdilate_imerode_selection_3 = gui.ui_setting(handles.uipanel25_7, 'popupmenu', pos(parentitem,item,margin,margin/4), default.masks, 'imdilate_imerode_selection_3', ...
    'String',{'Dilate image','Erode image'}, 'TooltipString','Choose between erosion or dilation');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.imdilate_imerode_size_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.imdilate_imerode_size_3 = gui.ui_setting(handles.uipanel25_7, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'imdilate_imerode_size_3', ...
    'TooltipString','Size of the structuring element');

%remove small
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_remove_enable_3 = gui.ui_setting(handles.uipanel25_7, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_remove_enable_3', ...
    'String','', 'TooltipString','Enable the removal of small blobs');

item=[checkbox_width item(2) filter_text_width 1];
handles.remove_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Remove blots');

item=[checkbox_width+filter_text_width item(2) size_text_width 1];
handles.remove_size_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Size:', ...
    'HorizontalAlignment','right');

item=[checkbox_width+filter_text_width+size_text_width item(2) size_width 1];
handles.remove_size_3 = gui.ui_setting(handles.uipanel25_7, 'edit', pos(parentitem,item,margin,margin/4), default.masks, 'remove_size_3', ...
    'TooltipString','Maximum area (in px) of the blobs to be removed');

%fillholes
item=[margin/4 item(2)+item(4)+margin/2 checkbox_width 1.1];
handles.mask_fill_enable_3 = gui.ui_setting(handles.uipanel25_7, 'checkbox', pos(parentitem,item,margin,margin/4), default.masks, 'mask_fill_enable_3', ...
    'String','', 'TooltipString','Enable hole filling');

item=[checkbox_width item(2) filter_text_width 1];
handles.fill_text_3 = gui.ui_text(handles.uipanel25_7, pos(parentitem,item,margin,margin/4), 'Fill holes');


%% mask operations apply etc

parentitem=get(handles.uipanel25_2, 'Position');

item=[0 16.5 parentitem(3) 1.5];
handles.automask_preview = gui.ui_button(handles.uipanel25_2, pos(parentitem,item,margin), 'Preview current frame', @mask.automask_preview_Callback, ...
    'TooltipString','Preview the automatically generated mask');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.automask_generate_current = gui.ui_button(handles.uipanel25_2, pos(parentitem,item,margin), 'Make mask for current frame', @mask.automask_generate_current_Callback, ...
    'TooltipString','Automatic generation of a mask for the current frame');

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.automask_generate_all = gui.ui_button(handles.uipanel25_2, pos(parentitem,item,margin), 'Make mask for all frames', @mask.automask_generate_all_Callback, ...
    'TooltipString','Automatic generation of a mask for all frames');


%panel image display options
parentitem=get(handles.multip25, 'Position');
item=[0 12 parentitem(3) 5];
handles.uipanel25_10 = gui.ui_panel(handles.multip25, pos(parentitem,item,margin), 'Image display options', ...
    'Tag','uipanel25_10');

parentitem=get(handles.uipanel25_10, 'Position');
item=[0 0 parentitem(3)/2 1.5];
handles.mask_display_brighter = gui.ui_button(handles.uipanel25_10, pos(parentitem,item,margin), 'Brighter', @mask.display_brighter_darker_Callback, ...
    'Tag','mask_display_brighter', 'TooltipString','increase brightness');

item=[parentitem(3)/2 0 parentitem(3)/2 1.5];
handles.mask_display_darker = gui.ui_button(handles.uipanel25_10, pos(parentitem,item,margin), 'Darker', @mask.display_brighter_darker_Callback, ...
    'Tag','mask_display_darker', 'TooltipString','decrease brightness');

item=[0 0+item(4) parentitem(3)/2 1.5];
handles.mask_display_average = gui.ui_button(handles.uipanel25_10, pos(parentitem,item,margin), 'Display average', @mask.display_average_Callback, ...
    'TooltipString','Show the mean image');


%panel mask modifications
parentitem=get(handles.multip25, 'Position');
item=[0 18 parentitem(3) 6.5];
handles.uipanel25_9 = gui.ui_panel(handles.multip25, pos(parentitem,item,margin), 'Mask modifications', ...
    'Tag','uipanel25_9');

parentitem=get(handles.uipanel25_9, 'Position');
item=[0 0 parentitem(3)/2 1.5];
handles.mask_shrink = gui.ui_button(handles.uipanel25_9, pos(parentitem,item,margin), 'Shrink mask', @mask.shrink_grow_Callback, ...
    'Tag','mask_shrink', 'TooltipString','Shrink the currently selected mask');

item=[0+item(3) item(2) parentitem(3)/2 1.5];
handles.mask_grow = gui.ui_button(handles.uipanel25_9, pos(parentitem,item,margin), 'Grow mask', @mask.shrink_grow_Callback, ...
    'Tag','mask_grow', 'TooltipString','Enlarge the currently selected mask');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_simplify = gui.ui_button(handles.uipanel25_9, pos(parentitem,item,margin), 'Simplify', @mask.subdivide_simplify_Callback, ...
    'Tag','mask_simplify', 'TooltipString','Simplify the currently selected mask');



item=[0+item(3) item(2) parentitem(3)/2 1.5];
handles.mask_subdivide = gui.ui_button(handles.uipanel25_9, pos(parentitem,item,margin), 'Subdivide', @mask.subdivide_simplify_Callback, ...
    'Tag','mask_subdivide', 'TooltipString','Subdivide the currently selected mask');


item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.mask_optimize = gui.ui_button(handles.uipanel25_9, pos(parentitem,item,margin), 'Optimize', @mask.subdivide_simplify_Callback, ...
    'Tag','mask_optimize', 'TooltipString','Optimize the waypoints of the currently selected mask');


item=[0+item(3) item(2) parentitem(3)/2 1.5];
handles.mask_combine = gui.ui_button(handles.uipanel25_9, pos(parentitem,item,margin), 'Combine', @mask.combine_Callback, ...
    'TooltipString','Combine all overlapping masks of the current frame');



%panel mask operations
item=[0 0 0 0];
parentitem=get(handles.multip25, 'Position');
item=[0 27 parentitem(3) 7.5];
handles.uipanel25_6 = gui.ui_panel(handles.multip25, pos(parentitem,item,margin), 'Mask operations');

item=[0 0 0 0];
parentitem=get(handles.uipanel25_6, 'Position');
item=[0 item(2)+item(4) parentitem(3)*0.6 1.5];
handles.mask_apply_to_current = gui.ui_button(handles.uipanel25_6, pos(parentitem,item,margin), 'Copy mask to frames', @mask.copy_to_all_Callback, ...
    'TooltipString','Copy masks from the current frame to the selected frames');

item=[parentitem(3)*0.6 item(2) parentitem(3)*0.4 1.5];
handles.mask_copy_frames = gui.ui_setting(handles.uipanel25_6, 'edit', pos(parentitem,item,margin), default.masks, 'mask_copy_frames', ...
    'TooltipString','Select which frames this operation applies to. E.g. "1:end", "1,4,7" or "10:15". "end" = last frame.');

item=[0 item(2)+item(4)+0.5 parentitem(3)*0.6 1.5];
handles.mask_delete_all = gui.ui_button(handles.uipanel25_6, pos(parentitem,item,margin), 'Clear masks in frames', @mask.delete_all_Callback, ...
    'TooltipString','Delete masks in the selected frames');

item=[parentitem(3)*0.6 item(2) parentitem(3)*0.4 1.5];
handles.mask_clear_frames = gui.ui_setting(handles.uipanel25_6, 'edit', pos(parentitem,item,margin), default.masks, 'mask_clear_frames', ...
    'TooltipString','Select which frames this operation applies to. E.g. "1:end", "1,4,7" or "10:15". "end" = last frame.');

item=[0 item(2)+item(4)+0.5 parentitem(3)/2 1.5];
handles.mask_save = gui.ui_button(handles.uipanel25_6, pos(parentitem,item,margin), 'Save all masks', @mask.save_Callback, ...
    'TooltipString','Save all masks to Matlab file for reuse');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.mask_load = gui.ui_button(handles.uipanel25_6, pos(parentitem,item,margin), 'Load mask(s)', @mask.load_Callback, ...
    'TooltipString','Load masks that were previously created in PIVlab');


%% Multip03
handles.multip03 = gui.ui_panel(MainWindow, mainpanel_pos, 'Image pre-processing', ...
    'Tag','multip03');
parentitem=get(handles.multip03, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.clahe_enable = gui.ui_setting(handles.multip03, 'checkbox', pos(parentitem,item,margin), default.analysis, 'clahe_enable', ...
    'String','Enable CLAHE', ...
    'TooltipString','Contrast limited adaptive histogram equalization: Enhances contrast, should be enabled');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text8 = gui.ui_text(handles.multip03, pos(parentitem,item,margin), 'Window size [px]', ...
    'HorizontalAlignment','right');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.clahe_size = gui.ui_setting(handles.multip03, 'edit', pos(parentitem,item,margin), default.analysis, 'clahe_size', ...
    'TooltipString','Size of the tiles for CLAHE. Default setting is fine in most cases');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.highpass_enable = gui.ui_setting(handles.multip03, 'checkbox', pos(parentitem,item,margin), default.analysis, 'highpass_enable', ...
    'String','Enable highpass', 'TooltipString','Highpass the image data. Only needed for some special cases');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text9 = gui.ui_text(handles.multip03, pos(parentitem,item,margin), 'Kernel size [px]', ...
    'HorizontalAlignment','right');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.highpass_size = gui.ui_setting(handles.multip03, 'edit', pos(parentitem,item,margin), default.analysis, 'highpass_size', ...
    'TooltipString','Kernel size of the lowpass filtered image that is subtracted from the original image');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.intenscap_enable = gui.ui_setting(handles.multip03, 'checkbox', pos(parentitem,item,margin), default.analysis, 'intenscap_enable', ...
    'String','Enable intensity capping', 'TooltipString','Intensity capping. Only needed for some special cases');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.wiener_enable = gui.ui_setting(handles.multip03, 'checkbox', pos(parentitem,item,margin), default.analysis, 'wiener_enable', ...
    'String','Wiener2 denoise and low pass', ...
    'TooltipString','Wiener denoise filter and Gaussian low pass. Only needed for some special cases');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text159 = gui.ui_text(handles.multip03, pos(parentitem,item,margin), 'Window size [px]', ...
    'HorizontalAlignment','right', 'Tag','text159');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.wiener_size = gui.ui_setting(handles.multip03, 'edit', pos(parentitem,item,margin), default.analysis, 'wiener_size', ...
    'TooltipString','Window size of the Wiener denoise filter');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1.1];
handles.autolimit_enable = gui.ui_setting(handles.multip03, 'checkbox', pos(parentitem,item,margin), default.analysis, 'autolimit_enable', ...
    'String','Auto contrast stretch', ...
    'TooltipString','Automatic stretching of the image intensity histogram. Important for 16-bit images.');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.text162 = gui.ui_text(handles.multip03, pos(parentitem,item,margin), 'minimum:', 'Tag','text162');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text163 = gui.ui_text(handles.multip03, pos(parentitem,item,margin), 'maximum:', 'Tag','text163');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.minintens = gui.ui_setting(handles.multip03, 'edit', pos(parentitem,item,margin), default.analysis, 'minintens', ...
    'Callback',@preproc.minintens_Callback, 'TooltipString','Lower bound of the histogram [0...1]');

item=[parentitem(3)/2 item(2) parentitem(3)/3*1 1];
handles.maxintens = gui.ui_setting(handles.multip03, 'edit', pos(parentitem,item,margin), default.analysis, 'maxintens', ...
    'Callback',@preproc.maxintens_Callback, 'TooltipString','Upper bound of the histogram [0...1]');

item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 7];
handles.uipanel351 = gui.ui_panel(handles.multip03, pos(parentitem,item,margin), 'Background Subtraction');

parentitem=get(handles.uipanel351, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3)/3 1.5];
handles.bg_subtract = gui.ui_setting(handles.uipanel351, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'bg_subtract', ...
    'String',{'off','subtract average intensity','subtract minimum intensity'}, 'Callback',@preproc.remove_bg_img, ...
    'TooltipString','Calculates an average or minimum image out of all images, then subtracts that from every image.');

item=[parentitem(3)/3 item(2) parentitem(3)/3*2 1.5];
handles.bg_view = gui.ui_button(handles.uipanel351, pos(parentitem,item,margin), 'View background image', @preproc.bg_view_Callback, ...
    'TooltipString','Display the generated background image. Click again to toggle between background A and B.');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1.5];
handles.bg_save = gui.ui_button(handles.uipanel351, pos(parentitem,item,margin), 'Save', @preproc.bg_save_Callback, ...
    'TooltipString','Save the backgound image');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.bg_load = gui.ui_button(handles.uipanel351, pos(parentitem,item,margin), 'Load', @preproc.bg_load_Callback, ...
    'TooltipString','Load the backgound image');

parentitem=get(handles.multip03, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+32 parentitem(3) 2];
handles.preview_preprocess = gui.ui_button(handles.multip03, pos(parentitem,item,margin), 'Apply and preview current frame', @preproc.preview_preprocess_Callback, ...
    'Tag','preview_preprocess', 'TooltipString','Preview the effect of image pre-processing');

item=[0+item(3)/2 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.export_preprocess = gui.ui_button(handles.multip03, pos(parentitem,item,margin), 'Export preview', @export.preprocess_Callback, ...
    'TooltipString','Export the preprocessed image (use toggle button to switch between image A and B)');


%% Multip04
handles.multip04 = gui.ui_panel(MainWindow, mainpanel_pos, 'PIV settings', ...
    'Tag','multip04');
parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];
%neu
item=[0 item(2)+item(4) parentitem(3)/4 1.5];
handles.textSuggest = gui.ui_text(handles.multip04, pos(parentitem,item,margin), 'Help:', 'tag','textSuggest');

item=[parentitem(3)/4 item(2)+margin/2 parentitem(3)/1.85 1.5];
handles.SuggestSettings = gui.ui_button(handles.multip04, pos(parentitem,item,margin), 'Suggest settings', @piv.SuggestPIVsettings, ...
    'Tag','SuggestSettings', 'TooltipString','Suggest PIV settings based on image data in current frame');

item=[0 item(2)+item(4)+margin/3 parentitem(3) 4];
handles.uipanel35 = gui.ui_panel(handles.multip04, pos(parentitem,item,margin), 'PIV algorithm');

parentitem=get(handles.uipanel35, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.algorithm_selection = gui.ui_setting(handles.uipanel35, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'algorithm_selection', ...
    'String',{'Multipass FFT window deformation','Ensemble multipass FFT window deformation','Single pass direct cross-correlation (DCC)', 'Optical flow (wavelet-based)'}, ...
    'TooltipString',sprintf('* Multipass FFT window deformation is the standard algorithm, suitable for most cases.\n* Ensemble correlation is for sparsely seeded flows (e.g. micro-piv). \n* DCC is the first algorithm that was implemented in PIVlab. \n* Optical flow can yield higher resolution with appropriate image data (but is slower), implemented by Schmidt et al. from case.edu'), ...
    'Callback',@piv.algorithm_selection_Callback);

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

%OFV UI items
item=[0 7 parentitem(3) 8];
handles.uipanel_ofv1 = gui.ui_panel(handles.multip04, pos(parentitem,item,margin), 'Optical flow settings', ...
    'Tag','uipanel_ofv1', 'Visible','off');
parentitem=get(handles.uipanel_ofv1, 'Position');
item=[0 0 0 0];


item=[0 item(2)+item(4) parentitem(3) 3];
handles.text_parallelpatches = gui.ui_text(handles.uipanel_ofv1, pos(parentitem,item,margin), 'Parallel process patches:', ...
    'Tag','text_parallelpatches');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_parallelpatches = gui.ui_setting(handles.uipanel_ofv1, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'ofv_parallelpatches', ...
    'String',{'Off' '128' '256' '512' '1024' 'Default'}, 'TooltipString','Parallel processing of patches');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text_ofv_median = gui.ui_text(handles.uipanel_ofv1, pos(parentitem,item,margin), 'Inter-pass median filter:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_median = gui.ui_setting(handles.uipanel_ofv1, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'ofv_median', ...
    'String',{'Off' '3x3' '5x5' '9x9'}, 'TooltipString','Median filtering in between the pyramid levels');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text_ofv_pyramid_levels = gui.ui_text(handles.uipanel_ofv1, pos(parentitem,item,margin), 'Pyramid levels:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_pyramid_levels = gui.ui_setting(handles.uipanel_ofv1, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'ofv_pyramid_levels', ...
    'String',{'5' '4' '3' '2' '1'}, ...
    'TooltipString','Amount of coarse-to-fine steps, larger numbers required for larger displacements');

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.text_ofv_eta = gui.ui_text(handles.uipanel_ofv1, pos(parentitem,item,margin), 'Smoothness (eta):');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.ofv_eta = gui.ui_setting(handles.uipanel_ofv1, 'edit', pos(parentitem,item,margin), default.analysis, 'ofv_eta', ...
    'TooltipString','smoothness determined by the regularization parameter');


parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 7+8.5 parentitem(3) 12];

handles.uipanel_ofv2 = gui.ui_panel(handles.multip04, pos(parentitem,item,margin), 'References', ...
    'Tag','uipanel_ofv2', 'Visible','off');
parentitem=get(handles.uipanel_ofv2, 'Position');
item=[0 0 0 0];


item=[0 item(2)+item(4) parentitem(3) 5];
handles.text_source = gui.ui_text(handles.uipanel_ofv2, pos(parentitem,item,margin), 'Schmidt, B. E., and J. A. Sutton. "High-resolution velocimetry from tracer particle fields using a wavelet-based optical flow method." Experiments in Fluids 60.3 (2019): 37.');

item=[0 item(2)+item(4) parentitem(3) 5];
handles.text_source = gui.ui_text(handles.uipanel_ofv2, pos(parentitem,item,margin), 'Jassal, G.R., Thielicke, W. and Schmidt, B.E. (2025) "An Optical Flow Algorithm with Automatic Parameter Adjustment for Fluid Velocimetry", Journal of Open Research Software, 13(1), p. 22.');


parentitem=get(handles.multip04, 'Position');
item=[0 7 parentitem(3) 6];
handles.uipanel41 = gui.ui_panel(handles.multip04, pos(parentitem,item,margin), 'Pass 1', 'Tag','uipanel41');

parentitem=get(handles.uipanel41, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text11 = gui.ui_text(handles.uipanel41, pos(parentitem,item,margin), 'Interrogation area [px]');

item=[parentitem(3)/3*2 item(2)+margin/2 parentitem(3)/3 1];
handles.text12 = gui.ui_text(handles.uipanel41, pos(parentitem,item,margin), 'Step [px]');

item=[0 item(2)+item(4) parentitem(3)/3*1 1];
handles.pass1_size = gui.ui_setting(handles.uipanel41, 'edit', pos(parentitem,item,margin), default.analysis, 'pass1_size', ...
    'Callback',@piv.intarea_Callback, ...
    'TooltipString','Interrogation window edge length of the first pass. Should be < 0.25 times your maximum displacement');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.pass1_step = gui.ui_setting(handles.uipanel41, 'edit', pos(parentitem,item,margin), default.analysis, 'pass1_step', ...
    'Callback',@piv.step_Callback, ...
    'TooltipString','Horizontal and vertical offset or step of the interrogation windows. Usually this is 50 % of the interrogation window edge length (interrogation area)');

item=[parentitem(3)/3*2 item(2)+item(4) parentitem(3)/3*1 1];
handles.steppercentage = gui.ui_text(handles.uipanel41, pos(parentitem,item,margin), 'N/A', 'Tag','steppercentage', ...
    'HorizontalAlignment','center');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 13.5 parentitem(3) 7.5];
handles.uipanel42 = gui.ui_panel(handles.multip04, pos(parentitem,item,margin), 'Pass 2...4', 'Tag','uipanel42');

parentitem=get(handles.uipanel42, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text129 = gui.ui_text(handles.uipanel42, pos(parentitem,item,margin), 'Interrogation area [px]');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.text130 = gui.ui_text(handles.uipanel42, pos(parentitem,item,margin), 'Step [px]');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1.1];
handles.pass2_enable = gui.ui_setting(handles.uipanel42, 'checkbox', pos(parentitem,item,margin), default.analysis, 'pass2_enable', ...
    'String','Pass 2', 'Callback',@piv.pass2_checkbox_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.pass2_size = gui.ui_setting(handles.uipanel42, 'edit', pos(parentitem,item,margin), default.analysis, 'pass2_size', ...
    'Callback',@piv.pass2_size_Callback, ...
    'TooltipString','Second pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.pass2_step = gui.ui_text(handles.uipanel42, pos(parentitem,item,margin), '16', 'Tag','pass2_step', ...
    'HorizontalAlignment','center');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1.1];
handles.pass3_enable = gui.ui_setting(handles.uipanel42, 'checkbox', pos(parentitem,item,margin), default.analysis, 'pass3_enable', ...
    'String','Pass 3', 'Callback',@piv.pass3_checkbox_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.pass3_size = gui.ui_setting(handles.uipanel42, 'edit', pos(parentitem,item,margin), default.analysis, 'pass3_size', ...
    'enable','off', 'Callback',@piv.pass3_size_Callback, ...
    'TooltipString','Third pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.pass3_step = gui.ui_text(handles.uipanel42, pos(parentitem,item,margin), '16', 'Tag','pass3_step', ...
    'HorizontalAlignment','center');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2.5 1.1];
handles.pass4_enable = gui.ui_setting(handles.uipanel42, 'checkbox', pos(parentitem,item,margin), default.analysis, 'pass4_enable', ...
    'String','Pass 4', 'Callback',@piv.pass4_checkbox_Callback);

item=[parentitem(3)/2.5 item(2) parentitem(3)/4*1 1];
handles.pass4_size = gui.ui_setting(handles.uipanel42, 'edit', pos(parentitem,item,margin), default.analysis, 'pass4_size', ...
    'enable','off', 'Callback',@piv.pass4_size_Callback, ...
    'TooltipString','Fourth pass interrogation window edge length (interrogation area). Must be <= the previous pass');

item=[parentitem(3)/3*2 item(2) parentitem(3)/4*1 1];
handles.pass4_step = gui.ui_text(handles.uipanel42, pos(parentitem,item,margin), '16', 'Tag','pass4_step', ...
    'HorizontalAlignment','center');


item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.repeat_last_enable = gui.ui_setting(handles.uipanel42, 'checkbox', pos(parentitem,item,margin), default.analysis, 'repeat_last_enable', ...
    'String','Repeat last pass until', 'Callback',@piv.repeat_last_Callback, ...
    'TooltipString','This will repeat the last pass of a multipass analysis until the average difference to the previous pass is less than "quality slope".', ...
    'visible','off');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text128x = gui.ui_text(handles.uipanel42, pos(parentitem,item,margin), 'quality slope <', 'visible','off', ...
    'Tag','text128x', 'HorizontalAlignment','center');

item=[parentitem(3)/2 item(2) parentitem(3)/3.5 1];
handles.repeat_last_threshold = gui.ui_setting(handles.uipanel42, 'edit', pos(parentitem,item,margin), default.analysis, 'repeat_last_threshold', ...
    'enable','off', 'Callback',@piv.repeated_thesh_Callback, ...
    'TooltipString','This will repeat the last pass of a multipass analysis until the average difference to the previous pass is less than "quality slope".', ...
    'visible','off');

parentitem=get(handles.multip04, 'Position');
item=[0 0 0 0];

item=[0 5+5+11.5+margin/3 parentitem(3) 1];
handles.text14 = gui.ui_text(handles.multip04, pos(parentitem,item,margin), 'Sub-pixel estimator', 'Tag','text14');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.subpixel_estimator = gui.ui_setting(handles.multip04, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'subpixel_estimator', ...
    'String',{'Gauss 2x3-point','2D Gauss'}, ...
    'TooltipString','Subpixel estimation technique. 2D Gauss is supposed to be more accurate for image data that contains motion blur, but there is hardly a difference');

%item=[0 item(2)+item(4)+margin parentitem(3) 1];
%handles.Repeated_box = uicontrol(handles.multip04,'Style','checkbox', 'String','5 x repeated correlation','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Tag','Repeated_box','TooltipString','With very bad image data, enabling the repeated correlation will enhance data yield. But it''s pretty slow');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.disable_autocorrelation = gui.ui_setting(handles.multip04, 'checkbox', pos(parentitem,item,margin), default.analysis, 'disable_autocorrelation', ...
    'String','Disable auto-correlation', ...
    'TooltipString','This will disallow displacements close to zero. It helps when there is a very strong background signal');

item=[0 item(2)+item(4)+margin/1.5 parentitem(3) 1];
handles.text914 = gui.ui_text(handles.multip04, pos(parentitem,item,margin), 'Correlation robustness', ...
    'Tag','text914');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 2];
handles.correlation_robustness = gui.ui_setting(handles.multip04, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'correlation_robustness', ...
    'String',{'Standard (recommended)','High','Extreme'}, 'TooltipString','Correlation quality. Better = slower...');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 1.5];
handles.uncertainty_enable = gui.ui_setting(handles.multip04, 'checkbox', pos(parentitem,item,margin), default.analysis, 'uncertainty_enable', ...
    'String','Estimate uncertainty (slow)', 'Visible','on', ...
    'TooltipString','Estimate velocity measurement uncertainty (Sciacchitano 2013). Doubles the analysis time!');


item=[0 item(2)+item(4)+margin*1.5 parentitem(3) 2];
handles.Settings_Apply_current = gui.ui_button(handles.multip04, pos(parentitem,item,margin), 'Analyze current frame', @piv.AnalyzeSingle_Callback, ...
    'Tag','Settings_Apply_current', 'TooltipString','Apply PIV settings to current frame');

%% Multip05
handles.multip05 = gui.ui_panel(MainWindow, mainpanel_pos, 'Analyze', ...
    'Tag','multip05');
parentitem=get(handles.multip05, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.AnalyzeSingle = gui.ui_button(handles.multip05, pos(parentitem,item,margin), 'Analyze current frame', @piv.AnalyzeSingle_Callback, ...
    'Fontsize',12, 'Tag','AnalyzeSingle', 'TooltipString','Perform PIV analysis for current frame');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.AnalyzeAll = gui.ui_button(handles.multip05, pos(parentitem,item,margin), 'Analyze all frames', @piv.AnalyzeAll_Callback, ...
    'Fontsize',12, 'Tag','AnalyzeAll', 'TooltipString','Perform PIV analyses for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/4*2.5 2.5];
handles.update_display_checkbox = gui.ui_setting(handles.multip05, 'checkbox', pos(parentitem,item,margin), default.display, 'update_display_checkbox', ...
    'String','Refresh display', ...
    'TooltipString','Refresh the display during the analysis. Disabling it will increase processing speed.');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 2.5];
handles.cancelbutt = gui.ui_button(handles.multip05, pos(parentitem,item,margin), 'Cancel', @piv.cancelbutt_Callback, ...
    'Tag','cancelbutt', 'TooltipString','Cancel analysis');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.clear_everything = gui.ui_button(handles.multip05, pos(parentitem,item,margin), 'Clear all results', @misc.clear_everything_Callback, ...
    'TooltipString','Clear all results');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 2];
handles.progress = gui.ui_text(handles.multip05, pos(parentitem,item,margin), 'Frame progress: N/A', ...
    'Tag','progress', 'Visible','off');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.overall = gui.ui_text(handles.multip05, pos(parentitem,item,margin), 'Total progress: N/A', 'Tag','overall');

item=[0 item(2)+item(4)+margin*3 parentitem(3) 2];
handles.totaltime = gui.ui_text(handles.multip05, pos(parentitem,item,margin), 'Time left: N/A', 'Tag','totaltime');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.messagetext = gui.ui_text(handles.multip05, pos(parentitem,item,margin), 'N/A', 'Tag','messagetext');

%% Multip06
handles.multip06 = gui.ui_panel(MainWindow, mainpanel_pos, 'Vector validation', ...
    'Tag','multip06');
parentitem=get(handles.multip06, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 13];

handles.uipanel42x = gui.ui_panel(handles.multip06, pos(parentitem,item,margin), 'Velocity limits (u & v)');
parentitem=get(handles.uipanel42x, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3 2];
handles.vel_limit = gui.ui_button(handles.uipanel42x, pos(parentitem,item,margin), 'Rectangle', @validate.vel_limit_Callback, ...
    'Tag','vel_limit', ...
    'TooltipString','Display a velocity scatter plot and draw a window around the allowed velocities');

item=[parentitem(3)/3*1 item(2) parentitem(3)/3 2];
handles.vel_limit_freehand = gui.ui_button(handles.uipanel42x, pos(parentitem,item,margin), 'Freehand', @validate.vel_limit_Callback, ...
    'Tag','vel_limit_freehand', ...
    'TooltipString','Display a velocity scatter plot and freely draw around the allowed velocities');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 2];
handles.vel_limit_auto = gui.ui_button(handles.uipanel42x, pos(parentitem,item,margin), 'Auto', @validate.vel_limit_Callback, ...
    'Tag','vel_limit_auto', ...
    'TooltipString','Display a velocity scatter plot and automatically draw a shape around them');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.scatter_all_frames = gui.ui_setting(handles.uipanel42x, 'checkbox', pos(parentitem,item,margin), default.display, 'scatter_all_frames', ...
    'String','display all frames in scatterplot', ...
    'TooltipString','Use velocity data of all frames in the velocity scatter plot');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.vel_limit_active = gui.ui_text(handles.uipanel42x, pos(parentitem,item,margin), 'Limit inactive', ...
    'Tag','vel_limit_active', 'HorizontalAlignment','center');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 3];
handles.limittext = gui.ui_text(handles.uipanel42x, pos(parentitem,item,margin), '', 'Tag','limittext', ...
    'HorizontalAlignment','center');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.clear_vel_limit = gui.ui_button(handles.uipanel42x, pos(parentitem,item,margin), 'Clear all u & v velocity limits', @validate.clear_vel_limit_Callback, ...
    'TooltipString','Remove the velocity limits');


parentitem=get(handles.multip06, 'Position');
item=[0 0 0 0];

item=[0 13+margin/2 parentitem(3) 1.1];
handles.stdev_enable = gui.ui_setting(handles.multip06, 'checkbox', pos(parentitem,item,margin), default.analysis, 'stdev_enable', ...
    'String','Standard deviation filter', ...
    'TooltipString','Filter velocities by removing velocities that are outside the mean velocity +- n times the standard deviation');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text18 = gui.ui_text(handles.multip06, pos(parentitem,item,margin), 'Threshold [n*stdev]');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.stdev_thresh = gui.ui_setting(handles.multip06, 'edit', pos(parentitem,item,margin), default.analysis, 'stdev_thresh', ...
    'Callback',@validate.stdev_thresh_Callback, ...
    'TooltipString','Threshold for the standard deviation filter. Velocities that are outside the mean velocity +- n times the standard deviation will be removed');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.loc_median_enable = gui.ui_setting(handles.multip06, 'checkbox', pos(parentitem,item,margin), default.analysis, 'loc_median_enable', ...
    'String','Local median filter', ...
    'TooltipString','Normalized local median test from Westerweel and Scarano (2005)');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19 = gui.ui_text(handles.multip06, pos(parentitem,item,margin), 'Threshold');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.loc_med_thresh = gui.ui_setting(handles.multip06, 'edit', pos(parentitem,item,margin), default.analysis, 'loc_med_thresh', ...
    'Callback',@validate.loc_med_thresh_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.notch_enable = gui.ui_setting(handles.multip06, 'checkbox', pos(parentitem,item,margin), default.analysis, 'notch_enable', ...
    'String','Magnitude notch filter', ...
    'TooltipString','Notch filter: Discards velocities in the specified range from vL to vH');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.textnotchL = gui.ui_text(handles.multip06, pos(parentitem,item,margin), 'vL', 'Tag','textnotchL');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.notch_L_thresh = gui.ui_setting(handles.multip06, 'edit', pos(parentitem,item,margin), default.analysis, 'notch_L_thresh', ...
    'Callback',@validate.notch_L_thresh_Callback);

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.textnotchH = gui.ui_text(handles.multip06, pos(parentitem,item,margin), 'vH', 'Tag','textnotchH');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.notch_H_thresh = gui.ui_setting(handles.multip06, 'edit', pos(parentitem,item,margin), default.analysis, 'notch_H_thresh', ...
    'Callback',@validate.notch_H_thresh_Callback);

%item=[0 item(2)+item(4) parentitem(3)/3*2 1];
%handles.text20 = uicontrol(handles.multip06,'Style','text','String','Epsilon','HorizontalAlignment','left','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

%item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
%handles.epsilon = uicontrol(handles.multip06,'Style','edit','String','0.1','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback',@epsilon_Callback,'Tag','epsilon');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.rejectsingle = gui.ui_button(handles.multip06, pos(parentitem,item,margin), 'Manually reject vector', @validate.rejectsingle_Callback, ...
    'TooltipString','Manually remove vectors. Click on the base of the vectors that you want to discard');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.interpol_missing = gui.ui_setting(handles.multip06, 'checkbox', pos(parentitem,item,margin), default.analysis, 'interpol_missing', ...
    'String','Interpolate missing data', ...
    'TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors', ...
    'Callback',@validate.set_other_interpol_checkbox);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.apply_filter_current = gui.ui_button(handles.multip06, pos(parentitem,item,margin), 'Apply to current frame', @validate.apply_filter_current_Callback, ...
    'TooltipString','Apply the filters to the current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_filter_all = gui.ui_button(handles.multip06, pos(parentitem,item,margin), 'Apply to all frames', @validate.apply_filter_all_Callback, ...
    'Tag','apply_filter_all', 'TooltipString','Apply the filters to all frames');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.restore_all = gui.ui_button(handles.multip06, pos(parentitem,item,margin), 'Undo all validations (all frames)', @validate.restore_all_Callback, ...
    'TooltipString','Remove all velocity filters for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.amount_nans = gui.ui_text(handles.multip06, pos(parentitem,item,margin), 'Valid detection probability (VDP): 100 %', ...
    'HorizontalAlignment','center', 'Tag','amount_nans', 'TooltipString','Valid detection probability in percent');

% Vector color legend: colored swatches showing the three vector types.
% Valid and interpolated colors mirror "Modify plot appearance" settings and
% are updated dynamically in validate.count_discarded_data.
swatch_w = 3; swatch_gap = 0.3;
swatch_x = margin;
label_x  = swatch_x + swatch_w + swatch_gap;
label_w  = parentitem(3) - margin*2 - swatch_w - swatch_gap;

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_valid_swatch = gui.ui_text(handles.multip06, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_valid_swatch', 'BackgroundColor',[0 1 0], ...
    'TooltipString','Valid vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.validtxt1 = gui.ui_text(handles.multip06, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Valid vectors (1st peak)', ...
    'tag','validtxt1');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_secondpeak_swatch = gui.ui_text(handles.multip06, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_secondpeak_swatch', 'BackgroundColor',[0 0.8 1], ...
    'TooltipString','2nd-peak vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.secondpeaktxt1 = gui.ui_text(handles.multip06, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Valid vectors (2nd peak)', ...
    'tag','secondpeaktxt1');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_interp_swatch = gui.ui_text(handles.multip06, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_interp_swatch', 'BackgroundColor',[1 0.5 0], ...
    'TooltipString','Rejected/interpolated vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.rejectedtxt1 = gui.ui_text(handles.multip06, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Rejected / interpolated', ...
    'tag','rejectedtxt1');

%% Multip07
handles.multip07 = gui.ui_panel(MainWindow, mainpanel_pos, 'Calibration', ...
    'Tag','multip07');
parentitem=get(handles.multip07, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 2];
handles.load_ext_img = gui.ui_button(handles.multip07, pos(parentitem,item,margin), 'Load calibration image (optional)', @calibrate.load_ext_img_Callback, ...
    'TooltipString','Load a reference image for calibration (if you recorded one)');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.optimize_calib_img = gui.ui_setting(handles.multip07, 'checkbox', pos(parentitem,item,margin), default.calibration, 'optimize_calib_img', ...
    'String','Enhance image contrast', 'Callback',@calibrate.optimize_calib_img_Callback, ...
    'TooltipString','Enhance the display of the calibration image');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
gui.ui_text(handles.multip07, pos(parentitem,item,margin), 'Setup Scaling', 'FontWeight','bold');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.draw_line = gui.ui_button(handles.multip07, pos(parentitem,item,margin), 'Pick reference length [px]', @calibrate.draw_line_Callback, ...
    'TooltipString','Draw a line as distance reference in the image');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1.5];
handles.text26b = gui.ui_text(handles.multip07, pos(parentitem,item,margin), 'Reference length in px');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.pixeldist = gui.ui(handles.multip07, 'edit', pos(parentitem,item,margin), 'String','1', 'Tag','pixeldist', ...
    'Callback',@calibrate.pixeldist_changed_Callback, ...
    'TooltipString','Reference lenght in pixels. Enter directly here or click ''Select reference distance'' button', ...
    'UserData','not_a_setting');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
handles.text26 = gui.ui_text(handles.multip07, pos(parentitem,item,margin), 'Real distance in mm');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.realdist = gui.ui_setting(handles.multip07, 'edit', pos(parentitem,item,margin), default.calibration, 'realdist', ...
    'Callback',@calibrate.realdist_Callback, ...
    'TooltipString','Enter the real world length of the line here (in millimeters)');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
handles.text27 = gui.ui_text(handles.multip07, pos(parentitem,item,margin), 'time step in ms');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.time_inp = gui.ui_setting(handles.multip07, 'edit', pos(parentitem,item,margin), default.calibration, 'time_inp', ...
    'Callback',@calibrate.time_inp_Callback, ...
    'TooltipString','Enter the delta t between two images here. Enter 0 if you want to measure displacements instead of velocities.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 8];
handles.uipanel_offsets = gui.ui_panel(handles.multip07, pos(parentitem,item,margin), 'Setup Offsets', ...
    'Tag','uipanel_offsets');
parentitem=get(handles.uipanel_offsets, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/4*3 1];
handles.text27a = gui.ui_text(handles.uipanel_offsets, pos(parentitem,item,margin), 'x increases towards the');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.x_axis_direction = gui.ui_setting(handles.uipanel_offsets, 'popupmenu', pos(parentitem,item,margin), default.calibration, 'x_axis_direction', ...
    'String',{'right','left'}, 'TooltipString','Direction of the x axis');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/4*3 1];
handles.text27b = gui.ui_text(handles.uipanel_offsets, pos(parentitem,item,margin), 'y increases towards the');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1.5];
handles.y_axis_direction = gui.ui_setting(handles.uipanel_offsets, 'popupmenu', pos(parentitem,item,margin), default.calibration, 'y_axis_direction', ...
    'String',{'bottom','top'}, 'TooltipString','Direction of the y axis');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/1.5 2];
handles.set_x_offset = gui.ui_button(handles.uipanel_offsets, pos(parentitem,item,margin), 'Set x & y offsets', @calibrate.set_offset_Callback, ...
    'TooltipString','Click into your calibration image and tell PIVlab what physical x and y coordinates this point represents.');

item=[0 0 0 0];
parentitem=get(handles.multip07, 'Position');

item=[0 23 parentitem(3) 5];
handles.calidisp = gui.ui_text(handles.multip07, pos(parentitem,item,margin), 'inactive', ...
    'HorizontalAlignment','center', 'Tag','calidisp');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.apply_cali = gui.ui_button(handles.multip07, pos(parentitem,item,margin), 'Apply calibration', @calibrate.apply_cali_Callback, ...
    'TooltipString','Apply calibration to the whole session');
item=[0 item(2)+item(4)+margin*0.5 parentitem(3) 2];
handles.clear_cali = gui.ui_button(handles.multip07, pos(parentitem,item,margin), 'Clear calibration', @calibrate.clear_cali_Callback, ...
    'TooltipString','Remove calibration');

%% Multip08
handles.multip08 = gui.ui_panel(MainWindow, mainpanel_pos, 'Derive Parameters', ...
    'Tag','multip08');
parentitem=get(handles.multip08, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.text33 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Display Parameter');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.derivchoice = gui.ui_setting(handles.multip08, 'popupmenu', pos(parentitem,item,margin), default.display, 'derivchoice', ...
    'String','N/A', 'HorizontalAlignment','Left', 'Callback',@plot.derivchoice_Callback, ...
    'TooltipString','Select the parameter that you want to display as colour-coded overlay');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.LIChint1 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'LIC resolution', 'visible','off', ...
    'Tag','LIChint1');

item=[parentitem(3)/2 item(2) parentitem(3)/3 1];
handles.licres = gui.ui_setting(handles.multip08, 'slider', pos(parentitem,item,margin), default.display, 'licres', ...
    'sliderstep',[0.25 0.25], 'max',2, 'min',0.1, 'String','Display Parameter', 'visible','off', ...
    'TooltipString','Resolution of the LIC image. Higher values take longer to calculate', ...
    'Callback',@plot.licres_Callback);

item=[parentitem(3)/2+parentitem(3)/3 item(2) parentitem(3)/6 1];
handles.LIChint2 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), '0.7', 'visible','off', ...
    'Tag','LIChint2');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1.6];
handles.text32 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Data smoothing');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.6];
handles.smooth_mode = gui.ui_setting(handles.multip08, 'popupmenu', pos(parentitem,item,margin), default.analysis, 'smooth_mode', ...
    'String',{'None';'2D';'time (moving average)';'2D + time'}, 'Callback',@plot.smooth_mode_Callback, ...
    'TooltipString','Data smoothing. "2D" = spatial smoothing of each frame (uses "smoothn" by Damien Garcia). "time" = moving average over the frames (time). "2D + time" applies both (2D first, then temporal).');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
handles.text_smooth_param = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Smoothing parameter', ...
    'Tag','text_smooth_param');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.smooth_param = gui.ui_setting(handles.multip08, 'edit', pos(parentitem,item,margin), default.analysis, 'smooth_param', ...
    'TooltipString','Smoothing parameter S passed to "smoothn" for 2D smoothing. Larger = smoother (typical 0.1 ... 1).');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
handles.text_temporal_window = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Temporal window (±frames)', ...
    'Visible','off', 'Tag','text_temporal_window');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.temporal_window = gui.ui_setting(handles.multip08, 'edit', pos(parentitem,item,margin), default.analysis, 'temporal_window', ...
    'Visible','off', 'Callback',@plot.temporal_window_Callback, ...
    'TooltipString','Number of neighbouring frames used on each side of the current frame. The frames are combined with a triangular (Bartlett) window, so closer frames count more.');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text34 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Subtract flow');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3 1.5];
handles.text35 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'u:', 'HorizontalAlignment','right', ...
    'Tag','text35');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1.5];
handles.subtr_u = gui.ui_setting(handles.multip08, 'edit', pos(parentitem,item,margin), default.display, 'subtr_u', ...
    'Callback',@plot.subtr_u_Callback, ...
    'TooltipString','Subtract a constant u velocity (horizontal) from the results');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.mean_u = gui.ui_button(handles.multip08, pos(parentitem,item,margin), 'mean u', @plot.mean_u_Callback, ...
    'TooltipString','Subtract the mean u velocity from the results', 'Tag','mean_u');

item=[0 item(2)+item(4) parentitem(3)/3 1.5];
handles.text36 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'v:', 'HorizontalAlignment','right', ...
    'Tag','text36');

item=[parentitem(3)/3 item(2) parentitem(3)/3 1.5];
handles.subtr_v = gui.ui_setting(handles.multip08, 'edit', pos(parentitem,item,margin), default.display, 'subtr_v', ...
    'Callback',@plot.subtr_v_Callback, 'TooltipString','Subtract a constant v velocity (vertical) from the results');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.mean_v = gui.ui_button(handles.multip08, pos(parentitem,item,margin), 'mean v', @plot.mean_v_Callback, ...
    'TooltipString','Subtract the mean v velocity from the results', 'Tag','mean_v');

item=[0 item(2)+item(4)+margin parentitem(3)/2 1];
handles.text41 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Colormap limits');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.1];
handles.autoscaler = gui.ui_setting(handles.multip08, 'checkbox', pos(parentitem,item,margin), default.display, 'autoscaler', ...
    'String','autoscale', 'Callback',@plot.autoscaler_Callback, ...
    'TooltipString','Autoscale the color map, so that it is stretched to the min and max of each frame. Should be DISABLED when rendering videos etc.');

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.text39 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'min:', 'Tag','text39');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text40 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'max:', 'Tag','text40');

item=[0 item(2)+item(4) parentitem(3)/4 1];
handles.mapscale_min = gui.ui_setting(handles.multip08, 'edit', pos(parentitem,item,margin), default.display, 'mapscale_min', ...
    'Enable','off', 'HorizontalAlignment','left', 'Callback',@plot.mapscale_min_Callback, ...
    'TooltipString','Minimum of the color map');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.mapscale_max = gui.ui_setting(handles.multip08, 'edit', pos(parentitem,item,margin), default.display, 'mapscale_max', ...
    'Enable','off', 'HorizontalAlignment','left', 'Callback',@plot.mapscale_max_Callback, ...
    'TooltipString','Maximum of the color map');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.highp_vectors = gui.ui_setting(handles.multip08, 'checkbox', pos(parentitem,item,margin), default.display, 'highp_vectors', ...
    'String','Highpass vector field', ...
    'TooltipString','High-pass the vector field. Useful when you want to subtract a non-uniform background flow. The modified data is NOT saved');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.text83 = gui.ui_text(handles.multip08, pos(parentitem,item,margin), 'Strength:', 'Tag','text83');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.highpass_strength = gui.ui_setting(handles.multip08, 'slider', pos(parentitem,item,margin), default.display, 'highpass_strength', ...
    'sliderstep',[0.1 0.1], 'max',51, 'min',1, ...
    'TooltipString','Strength of the high-pass. The modified data is NOT saved');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.extrapolate_border = gui.ui_setting(handles.multip08, 'checkbox', pos(parentitem,item,margin), default.analysis, 'extrapolate_border', ...
    'String','Extrapolate border', ...
    'TooltipString','Extrapolate colour map into the border region using spring inpainting instead of filling with the mean value. Slower but produces a smoother display.');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.apply_deriv = gui.ui_button(handles.multip08, pos(parentitem,item,margin), 'Apply to current frame', @plot.apply_deriv_Callback, ...
    'HorizontalAlignment','left', 'TooltipString','Apply settings to current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_deriv_all = gui.ui_button(handles.multip08, pos(parentitem,item,margin), 'Apply to all frames', @plot.apply_deriv_all_Callback, ...
    'HorizontalAlignment','left', 'Tag','apply_deriv_all', 'TooltipString','Apply settings to all frames');

%% Multip09
handles.multip09 = gui.ui_panel(MainWindow, mainpanel_pos, 'Modify plot appearance', ...
    'Tag','multip09');
parentitem=get(handles.multip09, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.autoscale_vec = gui.ui_setting(handles.multip09, 'checkbox', pos(parentitem,item,margin), default.display, 'autoscale_vec', ...
    'String','autoscale vectors', 'Callback',@plot.autoscale_vec_Callback, ...
    'TooltipString','Enable automatic scaling of the vector display');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text43 = gui.ui_text(handles.multip09, pos(parentitem,item,margin), 'Vector scale');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1];
handles.vectorscale = gui.ui_setting(handles.multip09, 'edit', pos(parentitem,item,margin), default.display, 'vectorscale', ...
    'Callback',@plot.vectorscale_Callback, 'TooltipString','Manually enter a vector scale factor here');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text114 = gui.ui_text(handles.multip09, pos(parentitem,item,margin), 'Vector line width');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.vecwidth = gui.ui_setting(handles.multip09, 'edit', pos(parentitem,item,margin), default.display, 'vecwidth', ...
    'Callback',@plot.vecwidth_Callback, 'TooltipString','Line width of the vectors');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text132 = gui.ui_text(handles.multip09, pos(parentitem,item,margin), 'plot every nth vector, n =', ...
    'Tag','tex132');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.nthvect = gui.ui_setting(handles.multip09, 'edit', pos(parentitem,item,margin), default.display, 'nthvect', ...
    'TooltipString','If you are confused by the amount of arrows shown on the screen, then you can reduce the amount here.');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.suppress_vec = gui.ui_setting(handles.multip09, 'checkbox', pos(parentitem,item,margin), default.display, 'suppress_vec', ...
    'String','hide vectors', 'Callback',@plot.suppress_vec_Callback, 'TooltipString','Hide vectors in display');

item=[0 item(2)+item(4)+margin/4*0 parentitem(3)/4*3 1];
handles.text200 = gui.ui_text(handles.multip09, pos(parentitem,item,margin), 'Mask transparency [%]');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1];
handles.masktransp = gui.ui_setting(handles.multip09, 'edit', pos(parentitem,item,margin), default.display, 'masktransp', ...
    'Callback',@mask.transp_Callback, 'TooltipString','Transparency of the masking area display (red)');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.uniform_vector_scale = gui.ui_setting(handles.multip09, 'checkbox', pos(parentitem,item,margin), default.display, 'uniform_vector_scale', ...
    'String','uniform vector scale', 'TooltipString','Draw all vectors with the same size, independent of velocity', ...
    'Callback',@plot.vector_scale_Callback);

item=[0 item(2)+item(4) parentitem(3)/4*3 1.1];
handles.power_vector_scale = gui.ui_setting(handles.multip09, 'checkbox', pos(parentitem,item,margin), default.display, 'power_vector_scale', ...
    'String','power law vector scale', ...
    'TooltipString','Draw vector scale with a sublinear power function: Large vector lengths are more and more attenuated the smaller the exponent is.', ...
    'Callback',@plot.vector_scale_Callback);
item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1.1];
handles.power_vector_scale_factor = gui.ui_setting(handles.multip09, 'edit', pos(parentitem,item,margin), default.display, 'power_vector_scale_factor', ...
    'TooltipString','Draw vector scale with a sublinear power function: Large vector lengths are more and more attenuated the smaller the exponent is.', ...
    'Callback',@plot.vector_scale_Callback);

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1];
handles.displ_image_txt = gui.ui_text(handles.multip09, pos(parentitem,item,margin), 'Background:');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.displ_image = gui.ui_setting(handles.multip09, 'popupmenu', pos(parentitem,item,margin), default.display, 'displ_image', ...
    'String',{'Display PIV image' 'Solid black','Solid white'}, ...
    'TooltipString','Display the PIV image in the background');



item=[0 item(2)+item(4)+margin/8 parentitem(3) 8.75];
handles.uipanel37 = gui.ui_panel(handles.multip09, pos(parentitem,item,margin), 'Vector colors');

parentitem=get(handles.uipanel37, 'Position');
item=[0 0 0 0];
colors_cell = gui.vec_preset_colors();
color_names = colors_cell(:,1)';

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
gui.ui_text(handles.uipanel37, pos(parentitem,item,margin), 'Valid (1st peak)');
item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
% Only the "valid" vectors offer magnitude coloring. Keeping this entry out of
% the other three popups (in particular deriv_color) is what guarantees that
% magnitude-colored vectors can never appear on top of a scalar background,
% where they would fight the overlay for the colormap and the colorbar.
valid_color_names = [color_names {'Magnitude'}];
handles.valid_color = gui.ui_setting(handles.uipanel37, 'popupmenu', pos(parentitem,item,margin), default.display, 'valid_color', ...
    'String',valid_color_names);

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 1.5];
gui.ui_text(handles.uipanel37, pos(parentitem,item,margin), 'Valid (2nd peak)');
item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.secondpeak_color = gui.ui_setting(handles.uipanel37, 'popupmenu', pos(parentitem,item,margin), default.display, 'secondpeak_color', ...
    'String',color_names);

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 1.5];
gui.ui_text(handles.uipanel37, pos(parentitem,item,margin), 'Replaced / interp.');
item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.interp_color = gui.ui_setting(handles.uipanel37, 'popupmenu', pos(parentitem,item,margin), default.display, 'interp_color', ...
    'String',color_names);

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 1.5];
gui.ui_text(handles.uipanel37, pos(parentitem,item,margin), 'On derivatives');
item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.deriv_color = gui.ui_setting(handles.uipanel37, 'popupmenu', pos(parentitem,item,margin), default.display, 'deriv_color', ...
    'String',color_names);

parentitem=get(handles.multip09, 'Position');
item=[0 12.5+6.5+2 parentitem(3) 8.5];
handles.uipanel27 = gui.ui_panel(handles.multip09, pos(parentitem,item,margin), 'Derived parameter appearance');

parentitem=get(handles.uipanel27, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1];
handles.text43c = gui.ui_text(handles.uipanel27, pos(parentitem,item,margin), 'Colormap opacity [%]');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4*1 1];
handles.colormapopacity = gui.ui_setting(handles.uipanel27, 'edit', pos(parentitem,item,margin), default.display, 'colormapopacity', ...
    'TooltipString','Opacity of the colormap (0...1)');

item=[0 item(2)+item(4)+margin/3 parentitem(3)/2 1];
handles.text143 = gui.ui_text(handles.uipanel27, pos(parentitem,item,margin), 'Color map');

item=[0+item(3) item(2) parentitem(3)/2 1];
handles.text143a = gui.ui_text(handles.uipanel27, pos(parentitem,item,margin), 'Steps', 'Tag','text143a');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.colormap_choice = gui.ui_setting(handles.uipanel27, 'popupmenu', pos(parentitem,item,margin), default.display, 'colormap_choice', ...
    'String',{'Parula','HSV','Jet','HSB','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','Lines','Plasma'}, ...
    'TooltipString','Select the color map for displaying derived parameters here');

item=[0+item(3) item(2) parentitem(3)/2 2];
handles.colormap_steps = gui.ui_setting(handles.uipanel27, 'popupmenu', pos(parentitem,item,margin), default.display, 'colormap_steps', ...
    'String',{'256','128','64','32','16','8','4','2'}, 'TooltipString','Select the amount of colors in a colormap');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/5*3 1];
handles.text143b = gui.ui_text(handles.uipanel27, pos(parentitem,item,margin), 'Image interpolation', ...
    'Tag','text143b');

item=[0+item(3) item(2)-0.2 parentitem(3)/5*2 2];
handles.colormap_interpolation = gui.ui_setting(handles.uipanel27, 'popupmenu', pos(parentitem,item,margin), default.display, 'colormap_interpolation', ...
    'String',{'bilinear','bicubic','nearest'}, ...
    'TooltipString','Image interpolation method for displaying the derived parameters. Default is bilinear');

%item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.img_not_mask = gui.ui_setting(handles.uipanel27, 'checkbox', pos(parentitem,item,margin), default.display, 'img_not_mask', ...
    'String','Do not display mask', 'Visible','off');

parentitem=get(handles.multip09, 'Position');
item=[0 12.5+6.5+1.5+9.4 parentitem(3) 5.7];
handles.uipanel27b = gui.ui_panel(handles.multip09, pos(parentitem,item,margin), 'Color legend');

parentitem=get(handles.uipanel27b, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/5*3 1];
handles.displ_colorbar = gui.ui_text(handles.uipanel27b, pos(parentitem,item,margin), 'Show colorbar:', ...
    'TooltipString','Display a colour bar for the derived parameters');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.colorbarpos = gui.ui_setting(handles.uipanel27b, 'popupmenu', pos(parentitem,item,margin), default.display, 'colorbarpos', ...
    'String',{'None' 'SouthOutside','NorthOutside','EastOutside','WestOutside'}, ...
    'TooltipString','Position of the colour bar');

item=[0 item(2)+item(4) parentitem(3)/5*3 1];
handles.colorbarnumberformattxt = gui.ui_text(handles.uipanel27b, pos(parentitem,item,margin), 'Colorbar numeric format:');

item=[parentitem(3)/5*3 item(2) parentitem(3)/5*2 2];
handles.colorbarnumberformat = gui.ui_setting(handles.uipanel27b, 'popupmenu', pos(parentitem,item,margin), default.display, 'colorbarnumberformat', ...
    'String',{'compact notation' 'scientific notation' 'fixed-decimals'}, ...
    'TooltipString','Number format of the colorbar');

parentitem=get(handles.multip09, 'Position');
item=[0 17.5+4+14.2+margin/4 parentitem(3)/2 2];
handles.ref_vect_txt = gui.ui_text(handles.multip09, pos(parentitem,item,margin), 'Reference vector scale:', ...
    'TooltipString','Display a reference vector');

item=[parentitem(3)/2 item(2) parentitem(3)/6 1.5];
handles.ref_vect_scl = gui.ui_setting(handles.multip09, 'edit', pos(parentitem,item,margin), default.display, 'ref_vect_scl', ...
    'TooltipString','Scaling of the reference vector. Same units as vector units.');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 2];
handles.ref_vect_pos = gui.ui_setting(handles.multip09, 'popupmenu', pos(parentitem,item,margin), default.display, 'ref_vect_pos', ...
    'String',{'Off' 'Top left','Top right','Bottom right','Bottom left'}, ...
    'TooltipString','Position of the reference vector');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.enhance_images = gui.ui_setting(handles.multip09, 'checkbox', pos(parentitem,item,margin), default.display, 'enhance_images', ...
    'String','Enhance PIV image display', 'TooltipString','Improve contrast of PIV images for display');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.dummy = gui.ui_button(handles.multip09, pos(parentitem,item,margin), 'Apply', @plot.dummy_Callback, ...
    'TooltipString','Apply the settings');

%% Multip10
handles.multip10 = gui.ui_panel(MainWindow, mainpanel_pos, 'Export as text file (ASCII)', ...
    'Tag','multip10');
parentitem=get(handles.multip10, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.addfileinfo = gui.ui_setting(handles.multip10, 'checkbox', pos(parentitem,item,margin), default.export, 'addfileinfo', ...
    'String','Add file information', ...
    'TooltipString','Add information like image file names etc. to the output file');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.add_header = gui.ui_setting(handles.multip10, 'checkbox', pos(parentitem,item,margin), default.export, 'add_header', ...
    'String','Add column headers', 'TooltipString','Add a header for each column');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.export_vort = gui.ui_setting(handles.multip10, 'checkbox', pos(parentitem,item,margin), default.export, 'export_vort', ...
    'String','Include derivatives', 'TooltipString','Calculate and export derivatives');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.delimitertext = gui.ui_text(handles.multip10, pos(parentitem,item,margin), 'Delimiter:');

item=[0 item(2)+item(4)+margin/6 parentitem(3) 1.5];
handles.delimiter = gui.ui_setting(handles.multip10, 'popupmenu', pos(parentitem,item,margin), default.export, 'delimiter', ...
    'String',{'comma','tab','space'}, 'HorizontalAlignment','Left', 'TooltipString','Select the delimiter here');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.ascii_current = gui.ui_button(handles.multip10, pos(parentitem,item,margin), 'Export current frame', @export.ascii_current_Callback, ...
    'TooltipString','Export data for current frame only');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.ascii_all = gui.ui_button(handles.multip10, pos(parentitem,item,margin), 'Export all frames', @export.ascii_all_Callback, ...
    'Tag','ascii_all', 'TooltipString','Export data for all frames');


%% Multip11
handles.multip11 = gui.ui_panel(MainWindow, mainpanel_pos, 'Save as MATLAB file', ...
    'Tag','multip11');
parentitem=get(handles.multip11, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin parentitem(3) 4];
handles.matlab_text = gui.ui_text(handles.multip11, pos(parentitem,item,margin), 'Exports x, y, velocities, calibration, and vector type. Check "Include derivatives" to also calculate and export vorticity, magnitude, divergence, Q criterion, shear, strain, vector angle, and correlation coefficient.');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
handles.export_mat_derivatives = gui.ui_setting(handles.multip11, 'checkbox', pos(parentitem,item,margin), default.export, 'export_mat_derivatives', ...
    'String','Include derivatives', ...
    'TooltipString','Calculate and include all derivatives (vorticity, magnitude, divergence, Q criterion, shear, strain, vector angle, correlation coefficient)');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_mat_current = gui.ui_button(handles.multip11, pos(parentitem,item,margin), 'Export current frame', @export.save_mat_current_Callback, ...
    'TooltipString','Export data for current frame only');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.save_mat_all = gui.ui_button(handles.multip11, pos(parentitem,item,margin), 'Export all frames', @export.save_mat_all_Callback, ...
    'Tag','save_mat_all', 'TooltipString','Export data for all frames');

%% Multip12
handles.multip12 = gui.ui_panel(MainWindow, mainpanel_pos, 'Extract parameters from poly-line', ...
    'Tag','multip12');
parentitem=get(handles.multip12, 'Position');
item=[0 0 0 0];

%item=[0 item(2)+item(4) parentitem(3) 2];
%handles.text55 = uicontrol(handles.multip12,'Style','text','String','Draw a line or circle and extract derived parameters from it.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

%item=[0 item(2)+item(4) parentitem(3) 7];
%handles.text91 = uicontrol(handles.multip12,'Style','text','String','Draw a poly-line by clicking with left mouse button. Right mouse button ends the poly-line. Draw a circle by clicking twice with the left mouse button: First click is for the centre, second click for radius.','Units','characters', 'HorizontalAlignment','left','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)]);

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
handles.text57 = gui.ui_text(handles.multip12, pos(parentitem,item,margin), 'Type:');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.draw_what = gui.ui_setting(handles.multip12, 'popupmenu', pos(parentitem,item,margin), default.export, 'draw_what', ...
    'String',{'polyline','circle','circle series (tangent vel. only)'}, 'HorizontalAlignment','Left', ...
    'Callback',@extract.draw_what_Callback, ...
    'TooltipString','Select the type of object that you want to draw and extract data from');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.draw_stuff = gui.ui_button(handles.multip12, pos(parentitem,item,margin), 'Draw!', @extract.draw_extraction_coordinates_Callback, ...
    'Tag','draw_stuff', 'TooltipString','Draw the object that you selected above');

%%new buttons, load and save polylines
item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.save_polyline = gui.ui_button(handles.multip12, pos(parentitem,item,margin), 'Save coords', @extract.save_polyline_Callback, ...
    'TooltipString','Save poly line coordinates to *.mat file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.load_polyline = gui.ui_button(handles.multip12, pos(parentitem,item,margin), 'Load coords', @extract.load_polyline_Callback, ...
    'Tag','load_polyline', 'TooltipString','Load poly line coordinates from *.mat file');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text56 = gui.ui_text(handles.multip12, pos(parentitem,item,margin), 'Data to extract:');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.extraction_choice = gui.ui_setting(handles.multip12, 'popupmenu', pos(parentitem,item,margin), default.export, 'extraction_choice', ...
    'String','N/A', 'HorizontalAlignment','left', 'Callback',@extract.extraction_choice_Callback, ...
    'TooltipString','What parameter do you want to extract along the line / circle?');

item=[0 item(2)+item(4)+margin parentitem(3)/2 2];
handles.plot_data = gui.ui_button(handles.multip12, pos(parentitem,item,margin), 'Extract data', @extract.plot_data_Callback, ...
    'Tag','plot_data', ...
    'TooltipString','When you finished drawing a line / circle, you can plot data along the line / circle by pushing this button');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_plot = gui.ui_button(handles.multip12, pos(parentitem,item,margin), 'Clear data', @extract.clear_plot_Callback, ...
    'TooltipString','Clear line / circle data');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1];
handles.iLoveLenaMaliaAndLine = gui.ui_text(handles.multip12, pos(parentitem,item,margin), 'Save extraction(s)');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.extractLineAll = gui.ui_setting(handles.multip12, 'checkbox', pos(parentitem,item,margin), default.export, 'extractLineAll', ...
    'String','extract and save for all frames', ...
    'TooltipString','Extract data for all frames of the current session');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.extractionLine_fileformat = gui.ui_setting(handles.multip12, 'popupmenu', pos(parentitem,item,margin), default.export, 'extractionLine_fileformat', ...
    'String',{'Excel file' 'Text file'}, 'HorizontalAlignment','left', ...
    'TooltipString','The format that the data is saved in');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.save_data = gui.ui_button(handles.multip12, pos(parentitem,item,margin), 'Export data', @extract.save_data_Callback, ...
    'TooltipString','Extract data and save results to a text file');

%% Multip13
handles.multip13 = gui.ui_panel(MainWindow, mainpanel_pos, 'Measure distance & angle', ...
    'Tag','multip13');
parentitem=get(handles.multip13, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 10];
handles.uipanel40 = gui.ui_panel(handles.multip13, pos(parentitem,item,margin), 'Distance & angle');

parentitem=get(handles.uipanel40, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.set_points = gui.ui_button(handles.uipanel40, pos(parentitem,item,margin), 'Draw line', @extract.set_points_Callback, ...
    'TooltipString','Draw a line to measure distance and angle');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/3*2 1];
handles.text50 = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'Delta x:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.deltax = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'N/A', 'Tag','deltax');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text51 = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'Delta y:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.deltay = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'N/A', 'Tag','deltay');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text52 = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'Length:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.length = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'N/A', 'Tag','length');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text53 = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'Angle to horiz. (deg):');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.alpha = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'N/A', 'Tag','alpha');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text54 = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'Angle to vert. (deg):');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.beta = gui.ui_text(handles.uipanel40, pos(parentitem,item,margin), 'N/A', 'Tag','beta');

parentitem=get(handles.multip13, 'Position');
item=[0 0 0 0];
item=[0 11.5 parentitem(3) 10];
handles.uipanel39 = gui.ui_panel(handles.multip13, pos(parentitem,item,margin), 'Markers');

parentitem=get(handles.uipanel39, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 3];
handles.text146 = gui.ui_text(handles.uipanel39, pos(parentitem,item,margin), 'Highlight points in the analyses. The markers will be memorized even if a new session is started.');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.putmarkers = gui.ui_button(handles.uipanel39, pos(parentitem,item,margin), 'Set markers', @plot.putmarkers_Callback, ...
    'TooltipString','Click in the image to place markers. End by clicking the right mouse button');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.delmarkers = gui.ui_button(handles.uipanel39, pos(parentitem,item,margin), 'Clear markers', @plot.delmarkers_Callback, ...
    'TooltipString','Clear all markers');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.holdmarkers = gui.ui_setting(handles.uipanel39, 'checkbox', pos(parentitem,item,margin), default.display, 'holdmarkers', ...
    'String','Hold markers', ...
    'TooltipString','Memorize markers even when a new session is started. Will be cleared only when you restart PIVlab');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.displmarker = gui.ui_setting(handles.uipanel39, 'checkbox', pos(parentitem,item,margin), default.display, 'displmarker', ...
    'String','Display markers', 'Callback',@plot.displmarker_Callback, 'TooltipString','Show or hide the markers');

parentitem=get(handles.multip13, 'Position');
item=[0 22+margin/2 parentitem(3) 2];
handles.markers_display_average = gui.ui_button(handles.multip13, pos(parentitem,item,margin), 'Display average', @mask.display_average_Callback, ...
    'TooltipString','Show the mean image');

%% Multip14
handles.multip14 = gui.ui_panel(MainWindow, mainpanel_pos, 'Statistics', ...
    'Tag','multip14');
parentitem=get(handles.multip14, 'Position');
item=[0 0 0 0];

%values of the current frame in groups of three: mean u, v, w / min u, v, w / max u, v, w / std u, v, w
%(plot.update_Stats; the w lines are only filled in stereo-PIV mode)
stat_names={'mean','min','max','std'};
stat_components={'u','v','w'};
for s_nr=1:numel(stat_names)
	for c_nr=1:numel(stat_components)
		stat_tag=[stat_names{s_nr} stat_components{c_nr}];
		if c_nr==1
			item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*1 1]; %small gap before each group
		else
			item=[0 item(2)+item(4) parentitem(3)/3*1 1];
		end
		handles.([stat_tag '_label']) = gui.ui_text(handles.multip14, pos(parentitem,item,margin), [stat_names{s_nr} ' ' stat_components{c_nr} ':']);
		item=[parentitem(3)/3*1 item(2) parentitem(3)/3*2 1];
		handles.(stat_tag) = gui.ui_text(handles.multip14, pos(parentitem,item,margin), 'N/A', 'Tag',stat_tag);
	end
end

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text67 = gui.ui_text(handles.multip14, pos(parentitem,item,margin), 'Histogram plot');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 2];
handles.hist_select = gui.ui_setting(handles.multip14, 'popupmenu', pos(parentitem,item,margin), default.display, 'hist_select', ...
    'String',{'u velocity','v velocity','velocity magnitude','sub-pixels'}, ...
    'TooltipString','What data to display in a histogram plot');

item=[parentitem(3)/2 item(2) parentitem(3)/4 2];
handles.text66 = gui.ui_text(handles.multip14, pos(parentitem,item,margin), 'bins:');

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 2];
handles.nrofbins = gui.ui_setting(handles.multip14, 'edit', pos(parentitem,item,margin), default.display, 'nrofbins', ...
    'TooltipString','Nr. of bins in the histogram plot');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.histdraw = gui.ui_button(handles.multip14, pos(parentitem,item,margin), 'Histogram', @plot.histdraw_Callback, ...
    'TooltipString','Draw a histogram');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.scatterplotter = gui.ui_button(handles.multip14, pos(parentitem,item,margin), 'Scatter plot u & v', @plot.scatterplotter_Callback, ...
    'TooltipString','Scatter plot u vs. v velocities', 'Tag','scatterplotter');

%% Multip16
handles.multip16 = gui.ui_panel(MainWindow, mainpanel_pos, 'Save image (sequence)', ...
    'Tag','multip16');
parentitem=get(handles.multip16, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];

handles.export_still_or_animation = gui.ui_setting(handles.multip16, 'popupmenu', pos(parentitem,item,margin), default.export, 'export_still_or_animation', ...
    'String',{'Please wait...'}, 'HorizontalAlignment','Left', 'Callback',@export.still_or_animation_Callback, ...
    'TooltipString','Select type of export.');

item=[0 item(2)+item(4)+margin parentitem(3)/3*2 1];
handles.qualstring = gui.ui_text(handles.multip16, pos(parentitem,item,margin), 'Quality (%)');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.quality_setting = gui.ui_setting(handles.multip16, 'edit', pos(parentitem,item,margin), default.export, 'quality_setting', ...
    'TooltipString','Quality setting of exported file');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.fpsstring = gui.ui_text(handles.multip16, pos(parentitem,item,margin), 'Frames per second (Hz)');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
handles.fps_setting = gui.ui_setting(handles.multip16, 'edit', pos(parentitem,item,margin), default.export, 'fps_setting', ...
    'TooltipString','Frame rate of the video file');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
if ~isMATLABReleaseOlderThan("R2025a")
    handles.resolutionstring = gui.ui_text(handles.multip16, pos(parentitem,item,margin), 'Image size (%)');
else
    handles.resolutionstring = gui.ui_text(handles.multip16, pos(parentitem,item,margin), 'Resolution (dpi)');
end
item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1];
if ~isMATLABReleaseOlderThan("R2025a")
    handles.resolution_setting = gui.ui_setting(handles.multip16, 'edit', pos(parentitem,item,margin), default.export, 'resolution_setting', ...
        'TooltipString','Scaling of the output file (relative to the raw input images)');
else
    handles.resolution_setting = gui.ui_setting(handles.multip16, 'edit', pos(parentitem,item,margin), default.export, 'resolution_setting', ...
        'TooltipString','Resolution of the output image');
end
item=[0 item(2)+item(4)+margin*2 parentitem(3) 2];
handles.do_export_pixel_data_single = gui.ui_button(handles.multip16, pos(parentitem,item,margin), 'Export single frame', @export.do_export_pixel_data_Callback, ...
    'Tag','do_export_pixel_data_single', 'TooltipString','Save image for currently active frame');

item=[0 item(2)+item(4)+margin*2 parentitem(3)/2 1];
handles.text87 = gui.ui_text(handles.multip16, pos(parentitem,item,margin), 'First frame');

item=[ parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.text88 = gui.ui_text(handles.multip16, pos(parentitem,item,margin), 'Last frame');

item=[0 item(2)+item(4) parentitem(3)/3 1];
handles.firstframe = gui.ui_setting(handles.multip16, 'edit', pos(parentitem,item,margin), default.export, 'firstframe', ...
    'TooltipString','First frame to export');

item=[parentitem(3)/2 item(2) parentitem(3)/3 1];
handles.lastframe = gui.ui_setting(handles.multip16, 'edit', pos(parentitem,item,margin), default.export, 'lastframe', ...
    'TooltipString','Last frame to export');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.do_export_pixel_data = gui.ui_button(handles.multip16, pos(parentitem,item,margin), 'Export multiple frames', @export.do_export_pixel_data_Callback, ...
    'Tag','do_export_pixel_data', 'TooltipString','Save image sequence for the selected frames');

%% Multip17
handles.multip17 = gui.ui_panel(MainWindow, mainpanel_pos, 'Extract parameters from area', ...
    'Tag','multip17');
parentitem=get(handles.multip17, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
handles.text57a = gui.ui_text(handles.multip17, pos(parentitem,item,margin), 'Type:');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.draw_what_area = gui.ui_setting(handles.multip17, 'popupmenu', pos(parentitem,item,margin), default.export, 'draw_what_area', ...
    'String',{'rectangle','polygon','circle','circle series'}, 'HorizontalAlignment','Left', ...
    'TooltipString','Select the type of object that you want to draw and extract data from');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.draw_stuff_area = gui.ui_button(handles.multip17, pos(parentitem,item,margin), 'Draw!', @extract.draw_extraction_coordinates_Callback, ...
    'Tag','draw_stuff_area', 'TooltipString','Draw the object that you selected above');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.save_area_coordinates = gui.ui_button(handles.multip17, pos(parentitem,item,margin), 'Save coords', @extract.save_polyline_Callback, ...
    'TooltipString','Save area coordinates to *.mat file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.load_area_coordinates = gui.ui_button(handles.multip17, pos(parentitem,item,margin), 'Load coords', @extract.load_polyline_Callback, ...
    'Tag','load_area_coordinates', 'TooltipString','Load area coordinates from *.mat file');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.text56a = gui.ui_text(handles.multip17, pos(parentitem,item,margin), 'Calculate the average of:');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.extraction_choice_area = gui.ui_setting(handles.multip17, 'popupmenu', pos(parentitem,item,margin), default.export, 'extraction_choice_area', ...
    'String','N/A', 'HorizontalAlignment','left', ...
    'TooltipString','What parameter do you want to extract from the area?');

item=[0 item(2)+item(4)+margin parentitem(3)/2 2];
handles.plot_data_area = gui.ui_button(handles.multip17, pos(parentitem,item,margin), 'Extract data', @extract.plot_data_area_Callback, ...
    'TooltipString','Extract the data from the area drawn');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.clear_plot_area = gui.ui_button(handles.multip17, pos(parentitem,item,margin), 'Clear data', @extract.clear_plot_Callback, ...
    'TooltipString','Clear area data');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.results_txts = gui.ui_text(handles.multip17, pos(parentitem,item,margin), 'Results:');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 4];
handles.area_results = gui.ui(handles.multip17, 'edit', pos(parentitem,item,margin), 'String',{''}, ...
    'Tag','area_results', 'TooltipString','Results of area extraction', 'Max',4, 'Min',1, ...
    'Horizontalalignment','left', 'UserData','not_a_setting');

item=[0 item(2)+item(4)+margin*2 parentitem(3) 1];
handles.save_plot_data_area = gui.ui_text(handles.multip17, pos(parentitem,item,margin), 'Save extraction(s)');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.extractAreaAll = gui.ui_setting(handles.multip17, 'checkbox', pos(parentitem,item,margin), default.export, 'extractAreaAll', ...
    'String','extract and save for all frames', ...
    'TooltipString','Extract data for all frames of the current session');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.extractionArea_fileformat = gui.ui_setting(handles.multip17, 'popupmenu', pos(parentitem,item,margin), default.export, 'extractionArea_fileformat', ...
    'String',{'Excel file' 'Text file'}, 'HorizontalAlignment','left', ...
    'TooltipString','The format that the data is saved in');

item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 2];
handles.save_data_area = gui.ui_button(handles.multip17, pos(parentitem,item,margin), 'Export data', @extract.save_data_area_Callback, ...
    'TooltipString','Extract data and save results to a text file');



%% Multip18
handles.multip18 = gui.ui_panel(MainWindow, mainpanel_pos, 'Stream lines', ...
    'Tag','multip18');
parentitem=get(handles.multip18, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 3];
handles.text117 = gui.ui_text(handles.multip18, pos(parentitem,item,margin), 'Stream lines are global, that means that they apply to all frames of the current session.');

item=[0 item(2)+item(4) parentitem(3) 1.1];
handles.holdstream = gui.ui_setting(handles.multip18, 'checkbox', pos(parentitem,item,margin), default.display, 'holdstream', ...
    'String','hold streamlines', ...
    'TooltipString','If enabled, every streamline that you draw will be added to the list of streamlines, instead of overwriting the list of streamlines');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.drawstreamlines = gui.ui_button(handles.multip18, pos(parentitem,item,margin), 'Draw stream lines', @plot.drawstreamlines_Callback, ...
    'TooltipString','Every click adds a streamline. End with a right click');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.streamrake = gui.ui_button(handles.multip18, pos(parentitem,item,margin), 'Draw stream line rake', @plot.streamrake_Callback, ...
    'TooltipString','Draw a rake of streamlines: First click is the starting point of the rake, second click is the end point');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 2];
handles.text118 = gui.ui_text(handles.multip18, pos(parentitem,item,margin), 'Amount of stream lines on rake');

item=[parentitem(3)/3*2 item(2)+0.5 parentitem(3)/3 1];
handles.streamlamount = gui.ui_setting(handles.multip18, 'edit', pos(parentitem,item,margin), default.display, 'streamlamount', ...
    'TooltipString','Amount of streamlines on the rake');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.streamslice = gui.ui_button(handles.multip18, pos(parentitem,item,margin), 'Draw streamslice', @plot.streamslice_Callback, ...
    'TooltipString','Automatically draw streamlines covering the entire velocity field using MATLAB''s streamslice function');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 2];
handles.text_streamslicedensity = gui.ui_text(handles.multip18, pos(parentitem,item,margin), 'Streamslice density');

item=[parentitem(3)/3*2 item(2)+0.5 parentitem(3)/3 1];
handles.streamslicedensity = gui.ui_setting(handles.multip18, 'edit', pos(parentitem,item,margin), default.display, 'streamslicedensity', ...
    'TooltipString','Density of streamslice streamlines (default: 1, higher values = more streamlines)');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.deletestreamlines = gui.ui_button(handles.multip18, pos(parentitem,item,margin), 'Delete all stream lines', @plot.deletestreamlines_Callback, ...
    'TooltipString','Remove all streamlines');

item=[0 item(2)+item(4)+margin*3 parentitem(3)/2 2];
handles.text119 = gui.ui_text(handles.multip18, pos(parentitem,item,margin), 'Color');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.streamlcolor = gui.ui_setting(handles.multip18, 'popupmenu', pos(parentitem,item,margin), default.display, 'streamlcolor', ...
    'String',{'y','r','b','k','w'}, 'TooltipString','Colour of the streamlines');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 2];
handles.text120 = gui.ui_text(handles.multip18, pos(parentitem,item,margin), 'Line width');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.streamlwidth = gui.ui_setting(handles.multip18, 'popupmenu', pos(parentitem,item,margin), default.display, 'streamlwidth', ...
    'String',{'1','2','3'}, 'TooltipString','Line width of the streamlines');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.applycolorwidth = gui.ui_button(handles.multip18, pos(parentitem,item,margin), 'Apply color and width', @plot.applycolorwidth_Callback, ...
    'TooltipString','Apply the settings for colour and width');

%% Multip19
handles.multip19 = gui.ui_panel(MainWindow, mainpanel_pos, 'Save as Paraview VTK file', ...
    'Tag','multip19');
parentitem=get(handles.multip19, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4) parentitem(3) 2];
handles.paraview_current = gui.ui_button(handles.multip19, pos(parentitem,item,margin), 'Save current frame', @export.paraview_current_Callback, ...
    'TooltipString','Save current frame as Paraview file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.paraview_all = gui.ui_button(handles.multip19, pos(parentitem,item,margin), 'Save all frames', @export.paraview_all_Callback, ...
    'Tag','paraview_all', 'TooltipString','Save all frames as Paraview files');

%% Multip20
handles.multip20 = gui.ui_panel(MainWindow, mainpanel_pos, 'Save as TECPLOT file', ...
    'Tag','multip20');
parentitem=get(handles.multip20, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1.5];
handles.export_vort_tec = gui.ui_setting(handles.multip20, 'checkbox', pos(parentitem,item,margin), default.export, 'export_vort_tec', ...
    'String','Include derivatives', 'TooltipString','Include derivatives like vorticity etc. in the exported file');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.tecplot_current = gui.ui_button(handles.multip20, pos(parentitem,item,margin), 'Save current frame', @export.tecplot_current_Callback, ...
    'TooltipString','Save current frame only as Tecplot file');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.tecplot_all = gui.ui_button(handles.multip20, pos(parentitem,item,margin), 'Save all frames', @export.tecplot_all_Callback, ...
    'Tag','tecplot_all', 'TooltipString','Save all frames as Tecplot files');

%% Multip21
handles.multip21 = gui.ui_panel(MainWindow, mainpanel_pos, 'Preferences', ...
    'Tag','multip21');
parentitem=get(handles.multip21, 'Position');
item=[0 0 0 0]; %reset positioning

if ~verLessThan('Matlab','25')
    item=[0 item(2)+item(4)+margin/4 parentitem(3) 1];
    handles.matlab_theme_txt = gui.ui_text(handles.multip21, pos(parentitem,item,margin), 'Color theme');

    item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
    handles.matlab_theme = gui.ui(handles.multip21, 'popupmenu', pos(parentitem,item,margin), ...
        'String',{'Dark','Light'}, 'Tag','matlab_theme', 'TooltipString','Change Matlab Theme', ...
        'Callback',@gui.change_theme, 'UserData','not_a_setting');


    current_theme = MainWindow.Theme.BaseColorStyle;

    if strcmpi(current_theme, 'Dark')
        set( handles.matlab_theme,'Value',1);
    elseif strcmpi(current_theme, 'Light')
        set( handles.matlab_theme,'Value',2);
    end
end

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.paneltext = gui.ui_text(handles.multip21, pos(parentitem,item,margin), 'Width of the panels');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.panelslider = gui.ui(handles.multip21, 'slider', pos(parentitem,item,margin), 'max',80, 'min',30, ...
    'sliderstep',[0.05 0.05], 'Value',50, 'Tag','panelslider', ...
    'TooltipString','Width of the panel that you see on the left side', 'UserData','not_a_setting');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.pref_apply = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Apply', @gui.pref_apply_Callback, ...
    'Tag','prefapply', 'TooltipString','Apply the new width. All data from the UI will be cleared');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 3];
handles.paneltext2 = gui.ui_text(handles.multip21, pos(parentitem,item,margin), 'If some button texts are clipped or not readable, try to increase the panelwidth here.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 3];
handles.paneltext2 = gui.ui_text(handles.multip21, pos(parentitem,item,margin), 'Warning: Current results and settings will be cleared.');

item=[0 item(2)+item(4)+margin parentitem(3) 1];
handles.paneltext3 = gui.ui_text(handles.multip21, pos(parentitem,item,margin), 'Change font size');

item=[0 item(2)+item(4) parentitem(3)/2 2];
handles.textsizeup = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Increase', {@gui.font_size_change,1}, ...
    'TooltipString','Increase the text size of buttons etc.');

item=[parentitem(3)/2 item(2) parentitem(3)/2 2];
handles.textsizedown = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Decrease', {@gui.font_size_change,-1}, ...
    'TooltipString','Decrease the text size of buttons etc');

item=[0 item(2)+item(4)+margin parentitem(3) 4];
handles.paneltext4 = gui.ui_text(handles.multip21, pos(parentitem,item,margin), 'Please note: This setting will currently not be saved. Because otherwise this might screw up your user interface permanently.');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.flash_sync = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Flash firmware to synchronizer', @gui.flash_sync_Callback, ...
    'TooltipString','Flash new firmware to OPTOLUTION synchronizer');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.detect_cam = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Detect connected cameras', @acquisition.camera_info, ...
    'TooltipString','Detect connected cameras');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.detect_dongle = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Detect serial dongle', @acquisition.serial_info, ...
    'TooltipString','Detect if driver for the dongle is installed');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.test_sync = gui.ui_button(handles.multip21, pos(parentitem,item,margin), 'Send test string (disable interlock!)', @gui.test_sync_Callback, ...
    'TooltipString','Check all channels of the synchronizer (WARNING! Turn off interlocks!)');


%% Multip22
handles.multip22 = gui.ui_panel(MainWindow, mainpanel_pos, 'Derive Temporal Parameters', ...
    'Tag','multip22');
parentitem=get(handles.multip22, 'Position');
item=[0 0 0 0];

%item=[0 item(2)+item(4)+margin/3*2 parentitem(3) 7];
%handles.uipanel43 = uipanel(handles.multip22, 'Units','characters', 'Position', [item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'title','Calculate mean / sum','fontweight','bold');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.text153 = gui.ui_text(handles.multip22, pos(parentitem,item,margin), 'Frames to process:');

item=[0 item(2)+item(4) parentitem(3) 2];
handles.selectedFramesMean = gui.ui_setting(handles.multip22, 'edit', pos(parentitem,item,margin), default.tools, 'selectedFramesMean', ...
    'TooltipString','Select which frames to include for calculating the mean velocity. E.g. "1,3,4,8:10". For multiple averages (e.g. phase average) enter rows: "[1:10:end;2:10:end;3:10:end]" -> one averaged frame per row.');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.append_replace = gui.ui_setting(handles.multip22, 'popupmenu', pos(parentitem,item,margin), default.tools, 'append_replace', ...
    'String',{'append to dataset' 'replace all existing'}, ...
    'TooltipString','Append the newly calculated vector field to the current session, or replace previously calculated vector fields');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.meanmaker = gui.ui_button(handles.multip22, pos(parentitem,item,margin), 'Calculate mean', {@plot.temporal_operation_Callback, 1}, ...
    'TooltipString','Calculate mean velocities and append an extra frame with the results');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.summaker = gui.ui_button(handles.multip22, pos(parentitem,item,margin), 'Calculate sum', {@plot.temporal_operation_Callback, 0}, ...
    'Tag','summaker', 'TooltipString','Calculate sum of displacements and append an extra frame with the results');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.stdmaker = gui.ui_button(handles.multip22, pos(parentitem,item,margin), 'Calculate stdev', {@plot.temporal_operation_Callback, 2}, ...
    'Tag','stdmaker', ...
    'TooltipString','Calculate standard deviation of displacements and append an extra frame with the results');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.tkemaker = gui.ui_button(handles.multip22, pos(parentitem,item,margin), 'Calculate TKE', {@plot.temporal_operation_Callback, 3}, ...
    'Tag','tkemaker', ...
    'TooltipString','Calculate turbulent kinetic energy and append an extra frame with the results');

item=[0 item(2)+item(4)+margin parentitem(3) 2];
handles.remove_temporal_frame = gui.ui_button(handles.multip22, pos(parentitem,item,margin), 'Remove current', @plot.remove_temporal_frame_Callback, ...
    'TooltipString','Remove the currently displayed frame');

% Periodic menu (Kozlov N.) -->
item=[0 item(2)+item(4)+margin*2 parentitem(3) 2];
handles.text_osc = gui.ui_text(handles.multip22, pos(parentitem,item,margin), 'Periodic (harmonic) flow:', ...
    'Tag','text_osc');
item=[0 item(2)+item(4) parentitem(3)/3 2];
handles.frames_per_period = gui.ui_setting(handles.multip22, 'edit', pos(parentitem,item,margin), default.tools, 'frames_per_period', ...
    'TooltipString','Indicate the number of frames that equals one period');
handles.phase_meanmaker = gui.ui_button(handles.multip22, [item(1)+item(3) parentitem(4)-item(4)-margin-item(2) item(3)*2-margin item(4)], 'Calculate phase mean', @plot.phase_mean_Callback, ...
    'Tag','phase_meanmaker', ...
    'TooltipString','Calculate mean velocities for each oscillation phase and append extra frames with the results for one period');
% <--

%% multip23
handles.multip23 = gui.ui_panel(MainWindow, mainpanel_pos, 'Image based validation', ...
    'Tag','multip23');
parentitem=get(handles.multip23, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.contrast_filter_enable = gui.ui_setting(handles.multip23, 'checkbox', pos(parentitem,item,margin), default.analysis, 'contrast_filter_enable', ...
    'String','Filter low contrast', ...
    'TooltipString','This filter removes vectors from regions where the input image contrast is low.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19a = gui.ui_text(handles.multip23, pos(parentitem,item,margin), 'Threshold');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.contrast_filter_thresh = gui.ui_setting(handles.multip23, 'edit', pos(parentitem,item,margin), default.analysis, 'contrast_filter_thresh', ...
    'Callback',@validate.contrast_filter_thresh_Callback);

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.suggest_contrast_filter = gui.ui_button(handles.multip23, pos(parentitem,item,margin), 'Suggest threshold', @validate.suggest_contrast_filter_Callback, ...
    'TooltipString','Finds a threshold that discards vectors in the regions where image contrast is low. Use this as a starting point only.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.bright_filter_enable = gui.ui_setting(handles.multip23, 'checkbox', pos(parentitem,item,margin), default.analysis, 'bright_filter_enable', ...
    'String','Filter bright objects', ...
    'TooltipString','This filter removes vectors from regions where the input image has connected bright objects.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19b = gui.ui_text(handles.multip23, pos(parentitem,item,margin), 'Threshold');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.bright_filter_thresh = gui.ui_setting(handles.multip23, 'edit', pos(parentitem,item,margin), default.analysis, 'bright_filter_thresh', ...
    'Callback',@validate.bright_filter_thresh_Callback);

item=[0 item(2)+item(4) parentitem(3)/3*2 1.5];
handles.suggest_bright_filter = gui.ui_button(handles.multip23, pos(parentitem,item,margin), 'Suggest threshold', @validate.suggest_bright_filter_Callback, ...
    'TooltipString','Finds a threshold that discards vectors in the regions where bright objects are found. Use this as a starting point only.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.corr_filter_enable = gui.ui_setting(handles.multip23, 'checkbox', pos(parentitem,item,margin), default.analysis, 'corr_filter_enable', ...
    'String','Correlation coefficient filter', ...
    'TooltipString','This filter removes vectors from image areas that have a low correlation between image A and B. Especially useful after removing the background signal.');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text19corrfilter = gui.ui_text(handles.multip23, pos(parentitem,item,margin), 'Threshold');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.corr_filter_thresh = gui.ui_setting(handles.multip23, 'edit', pos(parentitem,item,margin), default.analysis, 'corr_filter_thresh', ...
    'Callback',@validate.corr_filter_thresh_Callback);

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.interpol_missing2 = gui.ui(handles.multip23, 'checkbox', pos(parentitem,item,margin), ...
    'String','Interpolate missing data', 'Value',1, 'Tag','interpol_missing2', ...
    'TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors', ...
    'Callback',@validate.set_other_interpol_checkbox, 'UserData','not_a_setting');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.apply_filter_current = gui.ui_button(handles.multip23, pos(parentitem,item,margin), 'Apply to current frame', @validate.apply_filter_current_Callback, ...
    'TooltipString','Apply the filters to the current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.apply_filter_all = gui.ui_button(handles.multip23, pos(parentitem,item,margin), 'Apply to all frames', @validate.apply_filter_all_Callback, ...
    'Tag','apply_filter_all', 'TooltipString','Apply the filters to all frames');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
handles.restore_all = gui.ui_button(handles.multip23, pos(parentitem,item,margin), 'Undo all validations (all frames)', @validate.restore_all_Callback, ...
    'TooltipString','Remove all velocity filters for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
handles.amount_nans = gui.ui_text(handles.multip23, pos(parentitem,item,margin), 'Filtered data: 0 %', ...
    'HorizontalAlignment','center', 'Tag','amount_nans');

% Vector color legend — mirrors the one in the Vector validation panel.
% Swatch colors are updated dynamically in validate.count_discarded_data.
swatch_w = 3; swatch_gap = 0.3;
swatch_x = margin;
label_x  = swatch_x + swatch_w + swatch_gap;
label_w  = parentitem(3) - margin*2 - swatch_w - swatch_gap;

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_valid_swatch2 = gui.ui_text(handles.multip23, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_valid_swatch2', 'BackgroundColor',[0 1 0], ...
    'TooltipString','Valid vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.validtxt2 = gui.ui_text(handles.multip23, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Valid vectors (1st peak)', ...
    'tag','validtxt2');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_secondpeak_swatch2 = gui.ui_text(handles.multip23, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_secondpeak_swatch2', 'BackgroundColor',[0 0.8 1], ...
    'TooltipString','2nd-peak vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.secondpeaktxt2 = gui.ui_text(handles.multip23, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Valid vectors (2nd peak)', ...
    'tag','secondpeaktxt2');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_interp_swatch2 = gui.ui_text(handles.multip23, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_interp_swatch2', 'BackgroundColor',[1 0.5 0], ...
    'TooltipString','Rejected/interpolated vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.rejectedtxt2 = gui.ui_text(handles.multip23, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Rejected / interpolated', ...
    'tag','rejectedtxt2');

%% Multip32: stereo based validation (stereo-PIV only: the filters test the 3D result, stereo.limit_discard)
handles.multip32 = gui.ui_panel(MainWindow, mainpanel_pos, 'Stereo based validation', ...
    'Tag','multip32');
parentitem=get(handles.multip32, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
handles.stereo_val_note = gui.ui_text(handles.multip32, pos(parentitem,item,margin), 'Stereo-PIV only. Vectors are removed in both cameras.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.1];
handles.residual_enable = gui.ui_setting(handles.multip32, 'checkbox', pos(parentitem,item,margin), default.analysis, 'residual_enable', ...
    'String','Reconstruction residual filter', 'Callback',@validate.residual_enable_Callback, ...
    'TooltipString',['Removes vectors where the two cameras do not fit one 3D velocity (reconstruction residual larger than the threshold), '      'e.g. where one camera sees dirt or an object']);

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text_residual_thresh = gui.ui_text(handles.multip32, pos(parentitem,item,margin), 'Threshold [px]');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.residual_thresh = gui.ui_setting(handles.multip32, 'edit', pos(parentitem,item,margin), default.analysis, 'residual_thresh', ...
    'Callback',@validate.stereo_value_Callback, ...
    'TooltipString','Vectors with a reconstruction residual larger than this (px) are removed');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.stereo_show_residual = gui.ui(handles.multip32, 'checkbox', pos(parentitem,item,margin), ...
    'String','Show residual map', 'Value',0, 'Tag','stereo_show_residual', 'UserData','not_a_setting', ...
    'Callback',@validate.stereo_show_residual_Callback, 'Enable','off', ...
    'TooltipString','Shows the residual of the unvalidated result of this frame. Vectors above the threshold are shown in a solid colour. Needs the reconstruction residual filter.');

item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.w_median_enable = gui.ui_setting(handles.multip32, 'checkbox', pos(parentitem,item,margin), default.analysis, 'w_median_enable', ...
    'String','Local median filter (W)', ...
    'TooltipString',['Normalized median test of the out-of-plane component W. '      'Removes W outliers that the residual filter cannot see (an error of one camera along the stereo baseline only changes W).']);

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text_w_median_thresh = gui.ui_text(handles.multip32, pos(parentitem,item,margin), 'Threshold');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.w_median_thresh = gui.ui_setting(handles.multip32, 'edit', pos(parentitem,item,margin), default.analysis, 'w_median_thresh', ...
    'Callback',@validate.stereo_value_Callback, ...
    'TooltipString','Threshold of the normalized median test of W (like the local median filter)');

% W limits: sub-panel like "Velocity limits (u & v)" of the vector validation
item=[0 item(2)+item(4)+margin parentitem(3) 8.7];
handles.w_limit_panel = gui.ui_panel(handles.multip32, pos(parentitem,item,margin), 'W limits', ...
    'Tag','w_limit_panel');
panel_item = item; % continue below the sub-panel
parentitem=get(handles.w_limit_panel, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.w_limit_enable = gui.ui_setting(handles.w_limit_panel, 'checkbox', pos(parentitem,item,margin), default.analysis, 'w_limit_enable', ...
    'String','Enable W limits', ...
    'TooltipString','Removes vectors with an out-of-plane component W outside the range from W min to W max');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text_w_limit_min = gui.ui_text(handles.w_limit_panel, pos(parentitem,item,margin), 'W min');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.w_limit_min = gui.ui_setting(handles.w_limit_panel, 'edit', pos(parentitem,item,margin), default.analysis, 'w_limit_min', ...
    'Callback',@validate.stereo_value_Callback, ...
    'TooltipString','Smallest allowed W, in the units of the velocity limits (m/s with a calibration, px/frame without)');

item=[0 item(2)+item(4) parentitem(3)/3*2 1];
handles.text_w_limit_max = gui.ui_text(handles.w_limit_panel, pos(parentitem,item,margin), 'W max');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3*1 1];
handles.w_limit_max = gui.ui_setting(handles.w_limit_panel, 'edit', pos(parentitem,item,margin), default.analysis, 'w_limit_max', ...
    'Callback',@validate.stereo_value_Callback, ...
    'TooltipString','Largest allowed W, in the units of the velocity limits (m/s with a calibration, px/frame without)');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.w_limit_select = gui.ui_button(handles.w_limit_panel, pos(parentitem,item,margin), 'Select', @validate.w_limit_select_Callback, ...
    'Tag','w_limit_select', 'TooltipString','Display a histogram of W and drag the range of the allowed W');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.w_limit_auto = gui.ui_button(handles.w_limit_panel, pos(parentitem,item,margin), 'Auto', @validate.w_limit_select_Callback, ...
    'Tag','w_limit_auto', ...
    'TooltipString','Display a histogram of W and automatically select the range of the main peak');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.1];
handles.w_hist_all_frames = gui.ui_setting(handles.w_limit_panel, 'checkbox', pos(parentitem,item,margin), default.display, 'w_hist_all_frames', ...
    'String','display all frames in histogram', 'TooltipString','Use W of all frames in the histogram');

parentitem=get(handles.multip32, 'Position');
item=panel_item;
item=[0 item(2)+item(4)+margin parentitem(3) 1.1];
handles.interpol_missing3 = gui.ui(handles.multip32, 'checkbox', pos(parentitem,item,margin), ...
    'String','Interpolate missing data', 'Value',1, 'Tag','interpol_missing3', ...
    'TooltipString','Interpolate missing velocity data. Interpolated data appears as ORANGE vectors', ...
    'Callback',@validate.set_other_interpol_checkbox, 'UserData','not_a_setting');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 2];
gui.ui_button(handles.multip32, pos(parentitem,item,margin), 'Apply to current frame', @validate.apply_filter_current_Callback, ...
    'TooltipString','Apply the filters of all validation panels to the current frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
gui.ui_button(handles.multip32, pos(parentitem,item,margin), 'Apply to all frames', @validate.apply_filter_all_Callback, ...
    'TooltipString','Apply the filters of all validation panels to all frames');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
gui.ui_button(handles.multip32, pos(parentitem,item,margin), 'Undo all validations (all frames)', @validate.restore_all_Callback, ...
    'TooltipString','Remove all velocity filters for all frames');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1];
gui.ui_text(handles.multip32, pos(parentitem,item,margin), 'Valid detection probability (VDP): 100 %', ...
    'HorizontalAlignment','center', 'Tag','amount_nans', 'TooltipString','Valid detection probability in percent');

swatch_w = 3; swatch_gap = 0.3;
swatch_x = margin;
label_x  = swatch_x + swatch_w + swatch_gap;
label_w  = parentitem(3) - margin*2 - swatch_w - swatch_gap;

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_valid_swatch3 = gui.ui_text(handles.multip32, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_valid_swatch3', 'BackgroundColor',[0 1 0], ...
    'TooltipString','Valid vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.validtxt3 = gui.ui_text(handles.multip32, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Valid vectors (1st peak)', ...
    'tag','validtxt3');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_secondpeak_swatch3 = gui.ui_text(handles.multip32, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_secondpeak_swatch3', 'BackgroundColor',[0 0.8 1], ...
    'TooltipString','2nd-peak vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.secondpeaktxt3 = gui.ui_text(handles.multip32, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Valid vectors (2nd peak)', ...
    'tag','secondpeaktxt3');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.0];
handles.veccolor_interp_swatch3 = gui.ui_text(handles.multip32, [swatch_x parentitem(4)-item(4)-margin-item(2) swatch_w item(4)], '', ...
    'Tag','veccolor_interp_swatch3', 'BackgroundColor',[1 0.5 0], ...
    'TooltipString','Rejected/interpolated vector color — configurable in ''Modify plot appearance''', ...
    'HorizontalAlignment','center');
handles.rejectedtxt3 = gui.ui_text(handles.multip32, [label_x parentitem(4)-item(4)-margin-item(2) label_w item(4)], 'Rejected / interpolated', ...
    'tag','rejectedtxt3');

%% Multip24
% General
handles.multip24 = gui.ui_panel(MainWindow, mainpanel_pos, 'Image Acquisition', ...
    'Tag','multip24');
parentitem=get(handles.multip24, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 10];
handles.uipanelac_general = gui.ui_panel(handles.multip24, pos(parentitem,item,margin), 'General settings');

parentitem=get(handles.uipanelac_general, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 1];
handles.ac_projecttxt = gui.ui_text(handles.uipanelac_general, pos(parentitem,item,margin), 'Project path:');

item=[0 item(2)+item(4) parentitem(3)/1.5 1.5];
handles.ac_project = gui.ui_setting(handles.uipanelac_general, 'edit', pos(parentitem,item,margin), default.acquisition, 'ac_project', ...
    'HorizontalAlignment','left');
set(handles.ac_project,'Fontsize', get(handles.ac_project,'Fontsize')-1);

item=[parentitem(3)/1.5 item(2) parentitem(3)/3 1.5];
handles.ac_browse = gui.ui_button(handles.uipanelac_general, pos(parentitem,item,margin), 'Browse...', @acquisition.browse_Callback, ...
    'TooltipString','Browse for project folder. Images and configurations will be stored here.');

item=[0 item(2)+item(4)+margin*0.05 parentitem(3) 1];
handles.ac_configtxt = gui.ui_text(handles.uipanelac_general, pos(parentitem,item,margin), 'Select configuration:');

item=[parentitem(3)-11 item(2)+item(4)+0.45 11 1.1];
handles.ac_stereo = gui.ui_setting(handles.uipanelac_general, 'checkbox', [item(1)-margin+0.5 parentitem(4)-item(4)-margin-item(2) item(3)-0.5 item(4)], default.acquisition, 'ac_stereo', ...
    'String','2 cameras', ...
    'TooltipString','Record with two cameras of the selected type (both on the camera output of the synchronizer): stereo-PIV or a larger field of view', ...
    'Callback',@acquisition.stereo_Callback);

item=[0 item(2)-0.45 parentitem(3)-11 2];

available_PIV_configurations = { ...
    %	'Nd:YAG (SimpleSync) + pco.pixelfly usb' ...
    %	'Nd:YAG (SimpleSync) + pco.panda 26 DS' ...
    'Webcam demo (no synchronizer)' ...
    'PIVlab LD-PS + OPTOcam' ... %the model (2/80 or 20/9) is detected in select_capture_config_Callback
    'PIVlab LD-PS + pco.edge 26 DS CLHS' ...
    'PIVlab LD-PS + pco.panda 26 DS' ...
    'PIVlab LD-PS + pco.pixelfly usb' ...
    'PIVlab LD-PS + OPTRONIS Cyclone' ...
    'PIVlab LD-PS + Chronos' ...
    'PIVlab LD-PS + Basler acA2000-165um' ...
    'PIVlab LD-PS + FLIR FFY-U3-16S2M' ...
    };

handles.ac_config = gui.ui_setting(handles.uipanelac_general, 'popupmenu', pos(parentitem,item,margin), default.acquisition, 'ac_config', ...
    'String',available_PIV_configurations, ...
    'TooltipString','Lists the available configurations (synchronizer + cameras)', ...
    'Callback',@acquisition.select_capture_config_Callback);

item=[0 item(2)+item(4)+0.25 parentitem(3)/2 2];
handles.ac_comport = gui.ui_setting(handles.uipanelac_general, 'popupmenu', pos(parentitem,item,margin), default.acquisition, 'ac_comport', ...
    'String',{'COM1'}, 'HorizontalAlignment','left');

item=[parentitem(3)/2 item(2) parentitem(3)/2*0.9 2];
handles.ac_connect = gui.ui_button(handles.uipanelac_general, pos(parentitem,item,margin), 'Connect', @acquisition.connect_Callback, ...
    'Tag','ac_connect', 'TooltipString','Connect to PIVlab-SimpleSync');

IndicatorPos=get(handles.ac_connect,'Position');

handles.ac_serialstatus = gui.ui(handles.uipanelac_general, 'edit', [IndicatorPos(1)+IndicatorPos(3) IndicatorPos(2) 2 IndicatorPos(4)], ...
    'HorizontalAlignment','center', 'String','', 'tag','ac_serialstatus', 'BackgroundColor',[1 0 0], ...
    'Foregroundcolor',[1 1 1], 'Enable','inactive', ...
    'TooltipString','Status of the serial connection to PIVlab-SimpleSync', 'UserData','not_a_setting');


% Sync control
parentitem=get(handles.multip24, 'Position');
item=[0 10.5 parentitem(3) 12+0.5];
handles.uipanelac_laser = gui.ui_panel(handles.multip24, pos(parentitem,item,margin), 'Synchronizer control');

parentitem=get(handles.uipanelac_laser, 'Position');
item=[0 0 0 0];

item=[0 0 parentitem(3)/4*2.5 2];
handles.ac_fpstxt = gui.ui_text(handles.uipanelac_laser, pos(parentitem,item,margin), 'Frame rate in Hz:');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1.6];
handles.ac_fps = gui.ui_setting(handles.uipanelac_laser, 'popupmenu', pos(parentitem,item,margin), default.acquisition, 'ac_fps', ...
    'String',{'5' '3' '1.5' '1'}, 'Callback',@acquisition.sync_settings_Callback, ...
    'TooltipString','Frame rate during PIV image capture', 'interruptible','off', 'busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.3 parentitem(3)/4*2.5 1];
handles.ac_interpulstxt = gui.ui_text(handles.uipanelac_laser, pos(parentitem,item,margin), 'Pulse distance in µs:');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_interpuls = gui.ui_setting(handles.uipanelac_laser, 'edit', pos(parentitem,item,margin), default.acquisition, 'ac_interpuls', ...
    'Callback',@acquisition.sync_settings_Callback, 'TooltipString','Pulse spacing of the laser', ...
    'interruptible','off', 'busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2.5 1];
handles.ac_powertxt = gui.ui_text(handles.uipanelac_laser, pos(parentitem,item,margin), 'Laser energy in %:');

item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 1];
handles.ac_power = gui.ui_setting(handles.uipanelac_laser, 'edit', pos(parentitem,item,margin), default.acquisition, 'ac_power', ...
    'Callback',@acquisition.sync_settings_Callback, 'TooltipString','Laser energy', 'interruptible','off', ...
    'busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3) 1];
handles.ac_pulselengthtxt = gui.ui_text(handles.uipanelac_laser, pos(parentitem,item,margin), 'Pulse length: 0 µs', ...
    'tag','ac_pulselengthtxt');

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/2 1.1];
handles.ac_enable_straddling_figure = gui.ui_setting(handles.uipanelac_laser, 'checkbox', pos(parentitem,item,margin), default.acquisition, 'ac_enable_straddling_figure', ...
    'String','Timing graph', 'TooltipString','Show a graph with the timing of camera and laser pulses', ...
    'Callback',@acquisition.sync_settings_Callback);

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.1];
handles.ac_low_energy_mode = gui.ui_setting(handles.uipanelac_laser, 'checkbox', pos(parentitem,item,margin), default.acquisition, 'ac_low_energy_mode', ...
    'String','Low energy mode', ...
    'TooltipString',sprintf(['Pulse the laser at 100 Hz with the shortest pulse (1 µs) for alignment.\n'  	'Synchronized PIV capture is disabled while active.\n\n'  	'Average power at this duty cycle (peak -> average):\n'  	'      5 W  ->  0.5 mW\n'  	'    20 W  ->  2 mW\n'  	'    40 W  ->  4 mW\n'  	'  400 W  ->  40 mW']), ...
    'Callback',@acquisition.low_energy_mode_Callback);

item=[0 item(2)+item(4)+margin*0.2 parentitem(3)/4*2 2];
handles.ac_laserstatus = gui.ui(handles.uipanelac_laser, 'edit', pos(parentitem,item,margin), ...
    'HorizontalAlignment','center', 'String','N/A', 'tag','ac_laserstatus', 'FontName','FixedWidth', ...
    'BackgroundColor',[1 0 0], 'Foregroundcolor',[0 0 0], 'Enable','inactive', 'Fontweight','bold', ...
    'TooltipString','Status of the laser', 'UserData','not_a_setting');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4*2 2];
handles.ac_lasertoggle = gui.ui_button(handles.uipanelac_laser, pos(parentitem,item,margin), 'Toggle Laser', @acquisition.lasertoggle_Callback, ...
    'Fontweight','bold', 'Tag','ac_lasertoggle', 'TooltipString','Toggle laser on and off', 'interruptible','off', ...
    'busyaction','cancel');

item=[0 item(2)+item(4)+margin*0.1 parentitem(3)/2 1.5];
handles.ac_enable_ext_trigger = gui.ui_setting(handles.uipanelac_laser, 'checkbox', pos(parentitem,item,margin), default.acquisition, 'ac_enable_ext_trigger', ...
    'String','Ext. trigger', 'TooltipString','Use external trigger input on PIVlab-SimpleSync', ...
    'Callback',@acquisition.ext_trigger_xmsync_settings_Callback, 'Visible','off');

item=[0 item(2) parentitem(3)/2 1.5];
handles.ac_enable_ext_trigger_oltsync = gui.ui_button(handles.uipanelac_laser, pos(parentitem,item,margin), 'Trigger mode', @acquisition.ext_trigger_oltsync_settings_Callback, ...
    'Tag','ac_enable_ext_trigger_oltsync', 'TooltipString','Configure trigger input on PIVlab-SimpleSync', ...
    'Visible','off');

item=[item(3) item(2) parentitem(3)/2 1.5];
handles.ac_device_control = gui.ui_button(handles.uipanelac_laser, pos(parentitem,item,margin), 'Devices', @acquisition.device_control_Callback, ...
    'TooltipString','Setup external devices (such as remote controlled seeding generator etc.)');


%item=[parentitem(3)/4*2.5 item(2) parentitem(3)/4*1.5 2];
%handles.ac_ext_trigger_settings = uicontrol(handles.uipanelac_laser,'Style','Pushbutton','String','Setup','Units','characters', 'Fontunits','points','Position',[item(1)+margin parentitem(4)-item(4)-margin-item(2) item(3)-margin*2 item(4)],'Callback', @ac_ext_trigger_settings_Callback,'TooltipString','Setup external trigger input on PIVlab-SimpleSync');


% Camera settings
parentitem=get(handles.multip24, 'Position');
item=[0 23.5 parentitem(3) 7+1.5];
handles.uipanelac_camsettings = gui.ui_panel(handles.multip24, pos(parentitem,item,margin), 'Camera settings');

parentitem=get(handles.uipanelac_camsettings, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/8 parentitem(3)/4.1 1.5];
handles.ac_calibBinning = gui.ui_button(handles.uipanelac_camsettings, [item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)], 'Binning', @acquisition.calibBinning_Callback, ...
    'Tag','ac_calibBinning', 'TooltipString','Select pixel binning');

item=[parentitem(3)/4.1*1  item(2) parentitem(3)/4.1 1.5];
handles.ac_calibROI = gui.ui_button(handles.uipanelac_camsettings, [item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)], 'ROI', @acquisition.calibROI_Callback, ...
    'Tag','ac_calibROI', 'TooltipString','Select ROI in camera image');

item=[parentitem(3)/4.1*2  item(2) parentitem(3)/4.1 1.5];
handles.ac_lensctrl = gui.ui_button(handles.uipanelac_camsettings, [item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)], 'Lens', @acquisition.lens_control_Callback, ...
    'Tag','ac_lensctrl', 'TooltipString','Control camera lens');

item=[parentitem(3)/4.1*3  item(2) parentitem(3)/4.1 1.5];
handles.ac_camera_setup = gui.ui_button(handles.uipanelac_camsettings, [item(1)+margin*0.1 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.1 item(4)], 'Setup', @acquisition.camera_setup_Callback, ...
    'Tag','ac_camera_setup', 'TooltipString','Configure selected camera');


item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.ac_cam_helper_txt = gui.ui_text(handles.uipanelac_camsettings, pos(parentitem,item,margin), 'Display (live overlay):');
item=[0 item(2)+item(4)+margin/8 parentitem(3)/2 1.5];
handles.ac_displ_sharp = gui.ui_setting(handles.uipanelac_camsettings, 'checkbox', [item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)], default.acquisition, 'ac_displ_sharp', ...
    'String','Sharpness', 'TooltipString','Display sharpness', 'Callback',@acquisition.display_cam_overlay_Callback, ...
    'Visible','on');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.ac_displ_grid = gui.ui_setting(handles.uipanelac_camsettings, 'checkbox', [item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)], default.acquisition, 'ac_displ_grid', ...
    'String','Grid', 'TooltipString','Display grid', 'Callback',@acquisition.display_cam_overlay_Callback, ...
    'Visible','on');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
handles.calib_dolivedetect = gui.ui_setting(handles.uipanelac_camsettings, 'checkbox', [item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)], default.acquisition, 'calib_dolivedetect', ...
    'String','Calibration', 'TooltipString','Do realtime marker detection and image storage.', ...
    'Callback',@preproc.cam_live_detect_Callback);

item=[parentitem(3)/2*1 item(2) parentitem(3)/2 1.5];
handles.ac_realtime_PIV = gui.ui_setting(handles.uipanelac_camsettings, 'checkbox', [item(1)+margin parentitem(4)-item(4)-margin/2-item(2) item(3)-margin*1 item(4)], default.acquisition, 'ac_realtime_PIV', ...
    'String','Displacement', 'TooltipString','NOT IMLEMENTED YET Do realtime displacement estimation');


% Calib capture

parentitem=get(handles.multip24, 'Position');
item=[0 27.5+3.5+1.75 parentitem(3) 4.5];

handles.uipanelac_calib = gui.ui_panel(handles.multip24, pos(parentitem,item,margin), 'Live image');

parentitem=get(handles.uipanelac_calib, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3)/2 1];
handles.ac_expotxt = gui.ui_text(handles.uipanelac_calib, pos(parentitem,item,margin), 'Exposure in ms: ');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1];
handles.ac_expo = gui.ui_setting(handles.uipanelac_calib, 'edit', pos(parentitem,item,margin), default.acquisition, 'ac_expo', ...
    'HorizontalAlignment','right', 'TooltipString','Exposure of the camera during calibration image capture', ...
    'Callback',@acquisition.exposure_Callback);

item=[0 item(2)+item(4)+margin*0.25 parentitem(3)/4 1.5];
handles.ac_calibcapture = gui.ui_button(handles.uipanelac_calib, [item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)], 'Start', @acquisition.calibcapture_Callback, ...
    'Tag','ac_calibcapture', 'TooltipString','Start live view of the camera', 'interruptible','on', ...
    'BusyAction','queue');

item=[parentitem(3)/4*1 item(2) parentitem(3)/4 1.5];
handles.ac_calibsnapshot = gui.ui_button(handles.uipanelac_calib, [item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)], 'Snapshot', @acquisition.camera_snapshot_Callback, ...
    'Tag','ac_calibsnapshot', 'TooltipString','Save current display', 'enable','on', 'interruptible','on', ...
    'BusyAction','queue');

item=[parentitem(3)/4*2 item(2) parentitem(3)/4 1.5];
handles.ac_calibsave = gui.ui_button(handles.uipanelac_calib, [item(1)+margin*0.25 parentitem(4)-item(4)-margin-item(2) item(3)-margin*2*0.25 item(4)], 'Save', @acquisition.camera_stop_Callback, ...
    'Tag','ac_calibsave', 'TooltipString','Save last image', 'enable','off');

% PIV capture
parentitem=get(handles.multip24, 'Position');
item=[0 33+3.5+1.75 parentitem(3) 5];
handles.uipanelac_capture = gui.ui_panel(handles.multip24, pos(parentitem,item,margin), 'Capture PIV images', ...
    'Tag','uipanelac_capture');

parentitem=get(handles.uipanelac_capture, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1];
handles.ac_imgamounttxt = gui.ui_text(handles.uipanelac_capture, pos(parentitem,item,margin), 'Image amount: ');

item=[parentitem(3)/2 item(2) parentitem(3)/4 1];
handles.ac_imgamount = gui.ui_setting(handles.uipanelac_capture, 'edit', pos(parentitem,item,margin), default.acquisition, 'ac_imgamount', ...
    'HorizontalAlignment','right', 'enable','off', ...
    'TooltipString','Amount of double images to capture. If red: RAM most likely not sufficient.', ...
    'Callback',@acquisition.image_amount_Callback);

%live PIV preview disabled
item=[parentitem(3)/2+parentitem(3)/4 item(2) parentitem(3)/4 1];
handles.ac_realtime = gui.ui_setting(handles.uipanelac_capture, 'checkbox', [item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)], default.acquisition, 'ac_realtime', ...
    'HorizontalAlignment','right', 'String','Live', 'TooltipString','Enable real-time PIV', ...
    'Callback',@acquisition.realtime_Callback, 'Visible','off');

item=[0 item(2)+item(4)+margin*0.25 parentitem(3)/3 1.5];
handles.ac_pivcapture = gui.ui_button(handles.uipanelac_capture, pos(parentitem,item,margin), 'Start', @acquisition.piv_capture_Callback, ...
    'TooltipString','Start PIV image capture and laser', 'interruptible','on', 'BusyAction','queue');

item=[parentitem(3)/3*1 item(2) parentitem(3)/5 1.5];
handles.ac_pivcapture_save = gui.ui_setting(handles.uipanelac_capture, 'checkbox', [item(1) parentitem(4)-item(4)-margin-item(2) item(3) item(4)], default.acquisition, 'ac_pivcapture_save', ...
    'HorizontalAlignment','right', 'String','Save', 'TooltipString','Save PIV double images', ...
    'Callback',@acquisition.pivcapture_save_Callback);

item=[parentitem(3)/3*1+parentitem(3)/5 item(2) parentitem(3)/5 1.5];
handles.ac_auto_interframe = gui.ui_button(handles.uipanelac_capture, pos(parentitem,item,margin), 'Auto', @acquisition.automatic_interframe, ...
    'Tag','ac_auto_interframe', 'TooltipString','Automatically determine suitable interframe time', 'Visible','off');


item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.ac_pivstop = gui.ui_button(handles.uipanelac_capture, pos(parentitem,item,margin), 'Abort', @acquisition.camera_stop_Callback, ...
    'Tag','ac_pivstop', 'TooltipString','Cancel capture and discard images');

parentitem=get(handles.multip24, 'Position');
item=[0 30.5 parentitem(3) 2];
handles.ac_msgbox = gui.ui(handles.multip24, 'edit', pos(parentitem,item,margin), 'Fontname','fixedwidth', ...
    'enable','inactive', 'Max',3, 'min',1, 'String',{'Welcome to PIVlab' 'image acquisition!'}, ...
    'HorizontalAlignment','left', 'Tag','ac_msgbox', 'TooltipString','Messages', 'visible','off', ...
    'UserData','not_a_setting');
set(handles.ac_msgbox,'BackgroundColor', get (handles.ac_msgbox,'BackgroundColor')*0.95); %dim msgbox color


%% camera calibration
handles.multip26 = gui.ui_panel(MainWindow, mainpanel_pos, 'Camera calibration', ...
    'Tag','multip26');
parentitem=get(handles.multip26, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 34];
handles.calib_imagedata = gui.ui_panel(handles.multip26, pos(parentitem,item,margin), 'Calibration image data');

parentitem=get(handles.calib_imagedata, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_undist_cam_label = gui.ui_text(handles.calib_imagedata, pos(parentitem,item,margin), 'N/A', ...
    'FontWeight','bold', 'Tag','calib_undist_cam_label');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_load_imgs = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Load target images', @preproc.cam_calibration_loadimages_Callback, ...
    'Tag','calib_load_imgs', 'TooltipString','Load images of the calibration target');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/5*4 1.5];
handles.calib_use_tilted_model = gui.ui_setting(handles.calib_imagedata, 'checkbox', pos(parentitem,item,margin), default.calibration, 'calib_use_tilted_model', ...
    'String','Scheimpflug, tilt (deg):', 'Callback',@preproc.cam_togglescheimpflug_Callback, ...
    'TooltipString','Tilted sensor model for cameras with a Scheimpflug adapter', 'UserData','session_only');

item=[parentitem(3)/5*4 item(2) parentitem(3)/5 1.5];
handles.calib_tilt_angle = gui.ui_setting(handles.calib_imagedata, 'edit', pos(parentitem,item,margin), default.calibration, 'calib_tilt_angle', ...
    'Callback',@preproc.cam_togglescheimpflug_Callback, ...
    'TooltipString',['Tilt of the sensor about the vertical image axis in degrees (tilt about the horizontal axis = 0). The sign is found automatically.' newline '0: estimate both tilt angles from the target images (unreliable)']);

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_estimateparams = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Estimate cam parameters', @preproc.cam_estimateparams_Callback, ...
    'Tag','calib_estimateparams', 'TooltipString','Detect charuco markers and estimate camera parameters');

item=[0 item(2)+item(4)+margin/2 parentitem(3)/2 1.5];
handles.calib_saveparams = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Save parameters', @preproc.cam_saveparams_Callback, ...
    'Tag','calib_saveparams', 'TooltipString','Save the camera parameters to a file');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_loadparams = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Load parameters', @preproc.cam_loadparams_Callback, ...
    'Tag','calib_loadparams', 'TooltipString','Load camera parameters from a file');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
handles.calib_clearparams = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Clear parameters', @preproc.cam_clearparams_Callback, ...
    'Tag','calib_clearparams', 'TooltipString','Clear camera parameters');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
gui.ui_text(handles.calib_imagedata, pos(parentitem,item,margin), 'Calibration checks', 'Fontweight','bold');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.calib_showreproject = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Show reprojection errors', @preproc.cam_showreproject_Callback, ...
    'Tag','calib_showreproject', ...
    'TooltipString','Show reprojection errors (should be below 1 pixel for a valid undistortion)');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_showcams = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Show camera positions', @preproc.cam_show_cam_position_Callback, ...
    'Tag','calib_showcams', 'TooltipString','Show positions of the cameras');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_showdistortion = gui.ui_button(handles.calib_imagedata, pos(parentitem,item,margin), 'Show lens distortion', @preproc.cam_showdistortion_Callback, ...
    'Tag','calib_showdistortion', 'TooltipString','Show camera lens distortion');

item=[0 item(2)+item(4)+margin parentitem(3) 1.5];
gui.ui_text(handles.calib_imagedata, pos(parentitem,item,margin), 'Apply calibration', 'Fontweight','bold');

item=[0 item(2)+item(4)+margin/4 parentitem(3)/3*2 1.5];
gui.ui_text(handles.calib_imagedata, pos(parentitem,item,margin), 'Output image size:');

item=[parentitem(3)/3*2 item(2) parentitem(3)/3 1.5];
handles.calib_viewtype = gui.ui_setting(handles.calib_imagedata, 'popupmenu', pos(parentitem,item,margin), default.calibration, 'calib_viewtype', ...
    'String',{'Cut away black borders' 'Same size as input image' 'Include black borders'}, ...
    'TooltipString','Select how black borders should be treated', 'Callback',@preproc.cam_change_viewtype_Callback, ...
    'UserData','session_only');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.calib_usecalibration = gui.ui_setting(handles.calib_imagedata, 'checkbox', pos(parentitem,item,margin), default.calibration, 'calib_usecalibration', ...
    'String','Enable camera calibration', 'TooltipString','Enable camera calibration / undistortion', ...
    'Callback',@preproc.cam_enable_cam_calib_Callback, 'UserData','session_only');

%% camera rectification
handles.multip27 = gui.ui_panel(MainWindow, mainpanel_pos, 'Image rectification', ...
    'Tag','multip27');
parentitem=get(handles.multip27, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 32];
handles.rect_imagedata = gui.ui_panel(handles.multip27, pos(parentitem,item,margin), 'Rectification image data');

parentitem=get(handles.rect_imagedata, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.calib_rect_cam_label = gui.ui_text(handles.rect_imagedata, pos(parentitem,item,margin), 'N/A', ...
    'FontWeight','bold', 'Tag','calib_rect_cam_label');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_load_imgs = gui.ui_button(handles.rect_imagedata, pos(parentitem,item,margin), 'Load target image', @preproc.cam_rectification_loadimages_Callback, ...
    'Tag','rect_load_imgs', ...
    'TooltipString','Load an image of the calibration target aligned with your target coordinate system and inside the laser sheet.');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_show_points = gui.ui_button(handles.rect_imagedata, pos(parentitem,item,margin), 'Show detected markers', @preproc.cam_rectification_show_points_Callback, ...
    'Tag','rect_show_points', 'TooltipString','Show all points that can be detected');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_show_rectified = gui.ui_button(handles.rect_imagedata, pos(parentitem,item,margin), 'Show rectified board', @preproc.cam_rectification_show_rectified_Callback, ...
    'Tag','rect_show_rectified', 'TooltipString','Show a preview of the undistorted calibration board');

item=[0 item(2)+item(4)+margin/2 parentitem(3) 1.5];
handles.rect_show_cam_position = gui.ui_button(handles.rect_imagedata, pos(parentitem,item,margin), 'Show camera position', @preproc.cam_rectification_show_cam_position_Callback, ...
    'Tag','rect_show_cam_position', 'TooltipString','Show a 3D scene of camera and board position');

item=[0 item(2)+item(4)+margin parentitem(3)/2 1.5];
handles.calib_upscale_label = gui.ui_text(handles.rect_imagedata, pos(parentitem,item,margin), 'Upscaling:', ...
    'Tag','calib_upscale_label');
upscale_row = item(2);

item=[parentitem(3)/4*3 item(2) parentitem(3)/4 1.5];
handles.calib_upscale = gui.ui_setting(handles.rect_imagedata, 'popupmenu', pos(parentitem,item,margin), default.calibration, 'calib_upscale', ...
    'String',{'1x' '2x'}, ...
    'TooltipString','Upscaling factor reducing then effect of image interpolations, but making analyses slower', ...
    'Callback',@preproc.cam_rectification_upscale_Callback, 'UserData','session_only');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.calib_userectification = gui.ui_setting(handles.rect_imagedata, 'checkbox', pos(parentitem,item,margin), default.calibration, 'calib_userectification', ...
    'String','Enable image rectification', 'TooltipString','Use image rectification', ...
    'Callback',@preproc.cam_enable_cam_rectification_Callback, 'UserData','session_only');

% stereo-PIV: instead of upscaling and "Enable image rectification" (gui.update_dependent_controls)
item=[0 upscale_row parentitem(3) 5];
handles.stereo_rect_note = gui.ui_text(handles.rect_imagedata, pos(parentitem,item,margin), 'Two cameras: this board image is used by the 3D alignment (Analysis -> Multi-camera PIV).', ...
    'FontWeight','bold', 'Visible','off', 'Tag','stereo_rect_note', 'UserData','not_a_setting');


%% Marker board setup
handles.multip28 = gui.ui_panel(MainWindow, mainpanel_pos, 'Marker board setup', ...
    'Tag','multip28');
parentitem=get(handles.multip28, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 15];
handles.calib_markersetup = gui.ui_panel(handles.multip28, pos(parentitem,item,margin), 'Properties');

parentitem=get(handles.calib_markersetup, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3)/2 1.5];
gui.ui_text(handles.calib_markersetup, pos(parentitem,item,margin), 'Board type:');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_boardtype = gui.ui_setting(handles.calib_markersetup, 'popupmenu', pos(parentitem,item,margin), default.calibration, 'calib_boardtype', ...
    'String',{'ChArUco DICT_4X4_1000'}, 'Callback',@preproc.cam_board_param_edited_Callback, ...
    'TooltipString','Select the type of calibration marker board');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
gui.ui_text(handles.calib_markersetup, pos(parentitem,item,margin), 'Origin color:');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_origincolor = gui.ui_setting(handles.calib_markersetup, 'popupmenu', pos(parentitem,item,margin), default.calibration, 'calib_origincolor', ...
    'String',{'Black' 'White'}, 'Callback',@preproc.cam_board_param_edited_Callback, ...
    'TooltipString','Color of the top left checker');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
gui.ui_text(handles.calib_markersetup, pos(parentitem,item,margin), 'Nr. of rows:');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_rows = gui.ui_setting(handles.calib_markersetup, 'edit', pos(parentitem,item,margin), default.calibration, 'calib_rows', ...
    'Callback',@preproc.cam_board_param_edited_Callback, 'TooltipString','Amount of rows of the checkerboard');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
gui.ui_text(handles.calib_markersetup, pos(parentitem,item,margin), 'Nr. of columns:');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_columns = gui.ui_setting(handles.calib_markersetup, 'edit', pos(parentitem,item,margin), default.calibration, 'calib_columns', ...
    'Callback',@preproc.cam_board_param_edited_Callback, 'TooltipString','Amount of columns of the checkerboard');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
gui.ui_text(handles.calib_markersetup, pos(parentitem,item,margin), 'Checker size (mm):');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_checkersize = gui.ui_setting(handles.calib_markersetup, 'edit', pos(parentitem,item,margin), default.calibration, 'calib_checkersize', ...
    'Callback',@preproc.cam_board_param_edited_Callback, 'TooltipString','Size of the checkers');

item=[0 item(2)+item(4) parentitem(3)/2 1.5];
gui.ui_text(handles.calib_markersetup, pos(parentitem,item,margin), 'Marker size (mm):');

item=[parentitem(3)/2 item(2) parentitem(3)/2 1.5];
handles.calib_markersize = gui.ui_setting(handles.calib_markersetup, 'edit', pos(parentitem,item,margin), default.calibration, 'calib_markersize', ...
    'Callback',@preproc.cam_board_param_edited_Callback, 'TooltipString','Size of the markers');

item=[0 item(2)+item(4)+margin parentitem(3)/1.5 1.5];
handles.calib_find_params = gui.ui_button(handles.calib_markersetup, pos(parentitem,item,margin), 'Guess parameters', @preproc.cam_find_charuco_parameters_Callback, ...
    'TooltipString','Automatically guess charuco parameters');

item=[0 0 0 0];
parentitem=get(handles.multip28, 'Position');
item=[0 item(2)+item(4)+20+margin*2 parentitem(3) 7];
handles.calib_generate = gui.ui_panel(handles.multip28, pos(parentitem,item,margin), 'Marker board generation');
parentitem=get(handles.calib_generate, 'Position');
item=[0 0 0 0];
item=[0 item(2)+item(4)+margin/4 parentitem(3) 2];
gui.ui_text(handles.calib_generate, pos(parentitem,item,margin), 'Using the above settings');


item=[0 item(2)+item(4)+margin / 4 parentitem(3) 1.5];
handles.calib_generateboard = gui.ui_button(handles.calib_generate, pos(parentitem,item,margin), 'Generate Charuco board', @preproc.cam_generateboard_Callback, ...
    'Value',0, 'TooltipString','Generate a suitable Charuco board');

%% Marker board setup
handles.multip29 = gui.ui_panel(MainWindow, mainpanel_pos, 'Display correlation matrices', ...
    'Tag','multip29');
parentitem=get(handles.multip29, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 15];
handles.plot_correlation_matrices = gui.ui_panel(handles.multip29, pos(parentitem,item,margin), 'Properties');

parentitem=get(handles.plot_correlation_matrices, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4)+margin/4 parentitem(3) 1.5];
handles.retrieve_correlation_matrices = gui.ui_button(handles.plot_correlation_matrices, pos(parentitem,item,margin), 'Retrieve correlation matrices', @plot.correlation_matrices_calculate, ...
    'TooltipString','Get correlation matrices for all passes for currently displayed frame');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 5];
gui.ui_text(handles.plot_correlation_matrices, pos(parentitem,item,margin), 'After retrieving the correlation matrices, click on the vectors to show the correlation matrices of all passes.');



%% Multip30 Stereo-PIV
handles.multip30 = gui.ui_panel(MainWindow, mainpanel_pos, 'Multi-camera PIV', ...
    'Tag','multip30');
parentitem=get(handles.multip30, 'Position');
item=[0 0 0 0];

item=[0 item(2)+item(4) parentitem(3) 9.5];
handles.stereo_steps_panel = gui.ui_panel(handles.multip30, pos(parentitem,item,margin), 'Steps', ...
    'Tag','stereo_steps_panel');
parentitem2=get(handles.stereo_steps_panel, 'Position');
handles.stereo_steps = gui.ui_text(handles.stereo_steps_panel, [margin margin/4 parentitem2(3)-margin*2 parentitem2(4)-margin*1.25], 'Load the images of both cameras first (Input data panel: "Import multi-camera images").', ...
    'Tag','stereo_steps', 'UserData','not_a_setting');
% one row per step, coloured by stereo.update_panel (done / open / next step); only in stereo mode
row_height=(parentitem2(4)-margin*1.25)/7;
for k=1:7
    handles.(['stereo_step_' int2str(k)]) = gui.ui_text(handles.stereo_steps_panel, [margin margin/4+(7-k)*row_height parentitem2(3)-margin*2 row_height], '', ...
        'Tag',['stereo_step_' int2str(k)], 'Visible','off', 'UserData','not_a_setting');
end

item=[0 item(2)+item(4)+margin/4 parentitem(3) 5.5-margin/4];
handles.stereo_calib_panel = gui.ui_panel(handles.multip30, pos(parentitem,item,margin), '3D alignment', ...
    'Tag','stereo_calib_panel');
parentitem2=get(handles.stereo_calib_panel, 'Position');
item2=[0 0 0 0];
item2=[0 item2(2)+item2(4) parentitem2(3) 1.5];
handles.stereo_calibrate = gui.ui_button(handles.stereo_calib_panel, pos(parentitem2,item2,margin), 'Compute 3D alignment', @stereo.calibrate_Callback, ...
    'Tag','stereo_calibrate', ...
    'TooltipString','Places both cameras on the board from the board image in the light sheet of each camera (Image settings -> Camera calibration -> Image rectification -> Load target image). From the geometry: stereo-PIV (cameras look from different directions at the same area) or one larger field of view (cameras side by side, small overlap)');
item2=[0 item2(2)+item2(4)+margin/4 parentitem2(3) 1.5];
handles.stereo_show_3d = gui.ui_button(handles.stereo_calib_panel, pos(parentitem2,item2,margin), 'Show 3D setup', @stereo.show_3d_Callback, ...
    'Tag','stereo_show_3d', ...
    'TooltipString','Both cameras, the board, the overlap of the views and the light sheet in 3D, with the report of the 3D alignment');

item=[0 item(2)+item(4)+margin/4 parentitem(3) 22.5+margin*3/4];
handles.stereo_disp_panel = gui.ui_panel(handles.multip30, pos(parentitem,item,margin), 'Disparity correction', ...
    'Tag','stereo_disp_panel', 'UserData',item(4)); % UserData: height in manual mode (stereo.disparity_panel_layout)
parentitem3=get(handles.stereo_disp_panel, 'Position');
w=parentitem3(3);
item2=[0 0 0 0];
item2=[0 item2(2)+item2(4) w/4 1.5];
gui.ui_text(handles.stereo_disp_panel, [item2(1)+margin parentitem3(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Settings:', ...
    'Tag','stereo_disp_mode_text');
item2=[w/4 item2(2) w*3/4 1.5];
handles.stereo_disp_mode = gui.ui_setting(handles.stereo_disp_panel, 'popupmenu', pos(parentitem3,item2,margin), default.analysis, 'stereo_disp_mode', ...
    'String',{'Automatic','Manual'}, 'Callback',@stereo.disparity_mode_Callback, ...
    'TooltipString','Automatic: default settings for the disparity measurement. Manual: own settings');
% Manual settings: only visible in manual mode, in automatic mode the panel is shorter (stereo.disparity_panel_layout)
top=item2(2)+item2(4)+margin/4;
h=4.5+margin*3/4; % four rows
handles.stereo_disp_manual = uipanel(handles.stereo_disp_panel,'Units','characters','BorderType','none','Position',[0 parentitem3(4)-margin-top-h w h],'Tag','stereo_disp_manual');
parentitem2=[0 0 w h+margin]; % the rows use the same formula as in a titled panel
item2=[0 0 0 0];
item2=[0 item2(2)+item2(4) w/4 1];
gui.ui_text(handles.stereo_disp_manual, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Pairs:');
item2=[w/4 item2(2) w/4 1];
handles.stereo_disp_pairs = gui.ui_setting(handles.stereo_disp_manual, 'edit', [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], default.analysis, 'stereo_disp_pairs', ...
    'TooltipString','Number of image pairs used for the disparity (spread over the series). 0 = automatic: pairs are added until the disparity map is accurate to about 0.5 px');
item2=[w/2 item2(2) w/4 1];
gui.ui_text(handles.stereo_disp_manual, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Passes:');
item2=[w*3/4 item2(2) w/4 1];
handles.stereo_disp_passes = gui.ui_setting(handles.stereo_disp_manual, 'edit', pos(parentitem2,item2,margin), default.analysis, 'stereo_disp_passes', ...
    'TooltipString','Measure again on the corrected images and add the remaining disparity');
item2=[0 item2(2)+item2(4)+margin/4 w/4 1.5];
gui.ui_text(handles.stereo_disp_manual, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Model:');
[~, model_labels] = stereo.disparity_models;
item2=[w/4 item2(2) w*3/4 1.5];
handles.stereo_disp_model = gui.ui_setting(handles.stereo_disp_manual, 'popupmenu', pos(parentitem2,item2,margin), default.analysis, 'stereo_disp_model', ...
    'String',model_labels, 'TooltipString','Smooth model of the disparity map');
item2=[0 item2(2)+item2(4)+margin/4 w*3/4 1];
gui.ui_text(handles.stereo_disp_manual, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Window size [px] (0 = auto):');
item2=[w*3/4 item2(2) w/4 1];
handles.stereo_disp_ia = gui.ui_setting(handles.stereo_disp_manual, 'edit', pos(parentitem2,item2,margin), default.analysis, 'stereo_disp_ia', ...
    'TooltipString','Interrogation area of the first pass, 0 = one fifth of the image');
item2=[0 item2(2)+item2(4)+margin/4 w/4 1];
gui.ui_text(handles.stereo_disp_manual, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Stdev:');
item2=[w/4 item2(2) w/4 1];
handles.stereo_disp_stdev = gui.ui_setting(handles.stereo_disp_manual, 'edit', [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], default.analysis, 'stereo_disp_stdev', ...
    'TooltipString','Standard deviation filter of the disparity vectors');
item2=[w/2 item2(2) w/4 1];
gui.ui_text(handles.stereo_disp_manual, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Median:');
item2=[w*3/4 item2(2) w/4 1];
handles.stereo_disp_median = gui.ui_setting(handles.stereo_disp_manual, 'edit', pos(parentitem2,item2,margin), default.analysis, 'stereo_disp_median', ...
    'TooltipString','Local median filter of the disparity vectors');
% Measurement, report and display (always visible)
top=top+h;
h=11.5+margin;
handles.stereo_disp_results = uipanel(handles.stereo_disp_panel,'Units','characters','BorderType','none','Position',[0 parentitem3(4)-margin-top-h w h],'Tag','stereo_disp_results');
parentitem2=[0 0 w h+margin];
item2=[0 margin/2 w 1.5];
handles.stereo_measure_disparity = gui.ui_button(handles.stereo_disp_results, pos(parentitem2,item2,margin), 'Measure disparity', @stereo.measure_disparity_Callback, ...
    'Tag','stereo_measure_disparity', ...
    'TooltipString','Remaining misalignment of camera 1 and camera 2 (correlation of their A images); corrects both cameras');
item2=[0 item2(2)+item2(4)+margin/4 w 8.5];
handles.stereo_disp_report = gui.ui_text(handles.stereo_disp_results, pos(parentitem2,item2,margin), 'Not measured yet.', ...
    'Tag','stereo_disp_report', 'UserData','not_a_setting');
item2=[0 item2(2)+item2(4)+margin/4 w/4 1.5];
gui.ui_text(handles.stereo_disp_results, [item2(1)+margin parentitem2(4)-item2(4)-margin-item2(2) item2(3)-margin item2(4)], 'Show:');
item2=[w/4 item2(2) w*3/4 1.5];
handles.stereo_disp_show = gui.ui(handles.stereo_disp_results, 'popupmenu', pos(parentitem2,item2,margin), ...
    'String',{'Camera image'}, 'Value',1, 'Callback',@stereo.disparity_display_Callback, 'Tag','stereo_disp_show', ...
    'TooltipString','What the image shows while this panel is open (the disparity displays appear after "Measure disparity", the reconstruction residual after ANALYZE)', ...
    'UserData','not_a_setting'); % items: stereo.disparity_display_popup

%% Multip31 3D particle image generator
simulate.generate_ui_3d(MainWindow, default, margin, panelwidth, panelheightpanels, Figure_Size);

gui.put('multitiff',0); %default for compatibility: Not a multitiff.
gui.put('pcopanda_dbl_image',0); %default for compatibility: Not a multitiff.
gui.put('stereomode',0); % default: Not stereo mode
gui.put('stereo_active_camera',1); % stereo-PIV: camera shown and edited (stereo.switch_camera)
disp('-> UI generated.')
end

function p = pos(parentitem, item, margin, hmargin)
% Position of a control in a panel in characters. item = [x y_from_top width height] in the
% panel, parentitem = position of the panel. hmargin: margin left and right (default: margin).
if nargin < 4
    hmargin = margin;
end
p = [item(1)+hmargin parentitem(4)-item(4)-margin-item(2) item(3)-2*hmargin item(4)];
end
