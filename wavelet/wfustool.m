function varargout = wfustool(varargin)
%WFUSTOOL Discrete wavelet 2D tool for image fusion.
%   VARARGOUT = WFUSTOOL(VARARGIN)

% WFUSTOOL MATLAB file for wfustool.fig
%      WFUSTOOL, by itself, creates a new WFUSTOOL or raises the existing
%      singleton*.
%
%      H = WFUSTOOL returns the handle to a new WFUSTOOL or the handle to
%      the existing singleton*.
%
%      WFUSTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WFUSTOOL.M with the given input arguments.
%
%      WFUSTOOL('Property','Value',...) creates a new WFUSTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wfustool_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wfustool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wfustool


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Copyright 1995-2020 The MathWorks, Inc.


% DDUX data logging
if isempty(varargin)
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "wfustool";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfustool_OpeningFcn, ...
                   'gui_OutputFcn',  @wfustool_OutputFcn, ...
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
%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before wfustool is made visible.                      %
%*************************************************************************%
function wfustool_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<VANUS>
% This function has no output args, see OutputFcn.

% Choose default command line output for wfustool
handles.output = hObject;
% Initialize okSize to true, tst_ImagSize() should set this to false if the
% images are not equal in size
handles.output.UserData.okSize = true;
% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Introduced manualy in the automatic generated code   %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wfustool_OutputFcn(hObject,eventdata,handles) %#ok<INUSL>
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
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hFig = handles.output;
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    status = wwaitans({hFig,getWavMSG('Wavelet:divGUIRF:Image_Fusion')},...
        getWavMSG('Wavelet:commongui:SaveSI_Quest'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));
            save_FUN(m_save,eventdata,handles)
            wwaiting('off',hFig);
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------
function Load_Img1_Callback(hObject,eventdata,handles,varargin) %#ok<DEFNU,INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;
def_nbCodeOfColors = 255;
if isempty(varargin)
    imgFileType = getimgfiletype;
    [imgInfos,img_anal,map,ok] = ...
        utguidiv('load_img',hFig,imgFileType, ...
        getWavMSG('Wavelet:commongui:Load_Image'),def_nbCodeOfColors);
else
    [imgInfos,img_anal,ok] = wtbximport('2d');
    map = pink(def_nbCodeOfColors);
end
if ~ok
    return;
end
hFig.UserData.okSize = tst_ImageSize(hFig,1,imgInfos);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Load_Img1_Callback','beg');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlev(imgInfos.size,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanapar('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanapar('set',hFig, ...
        'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,curlev)} ...
        );
end
%---------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
img_Size = imgInfos.size;
wtbxappdata('set',hFig,'Size_IMG_1',img_Size);
img_Size_2 = wtbxappdata('get',hFig,'Size_IMG_2');
L1 = length(img_Size);
L2 = length(img_Size_2);
%---------------------------------
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else arg = []; end
curMap = get(hFig,'Colormap');
NB_ColorsInPal = max([NB_ColorsInPal,size(curMap,1)]);
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
%---------------------------------
n_s =  ...
    getWavMSG('Wavelet:divGUIRF:Img_Size',img_Name,img_Size(2),img_Size(1));
set(handles.Edi_Data_NS,'String',n_s);                
image(wd2uiorui2d('d2uint',img_anal),'Parent',handles.Axe_Image_1); 
wguiutils('setAxesTitle',handles.Axe_Image_1, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',1),'On');
set(handles.Axe_Image_1,'Box','On');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Load_Img1_Callback','end');
if L1==L2
    if L1==3 , vis_UTCOLMAP = 'Off'; else vis_UTCOLMAP = 'On'; end
    cbcolmap('Visible',hFig,vis_UTCOLMAP); 
end
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Load_Img2_Callback(hObject,eventdata,handles,varargin) %#ok<DEFNU,INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;
def_nbCodeOfColors = 255;
if isempty(varargin)
    imgFileType = getimgfiletype;    
    [imgInfos,img_anal,map,ok] = ...
        utguidiv('load_img',hFig,imgFileType, ...
        getWavMSG('Wavelet:commongui:Load_Image'),def_nbCodeOfColors);
else
    [imgInfos,img_anal,ok] = wtbximport('2d');
    map = pink(def_nbCodeOfColors);
end
if ~ok
    return;
end
hFig.UserData.okSize = tst_ImageSize(hFig,2,imgInfos);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Load_Img2_Callback','beg');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlev(imgInfos.size,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanapar('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanapar('set',hFig, ...
        'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,curlev)} ...
        );
end
%---------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
img_Size = imgInfos.size;
wtbxappdata('set',hFig,'Size_IMG_2',img_Size);
%---------------------------------
img_Size_1 = wtbxappdata('get',hFig,'Size_IMG_1');
L1 = length(img_Size_1);
L2 = length(img_Size);
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else arg = []; end
curMap = get(hFig,'Colormap');
NB_ColorsInPal = max([NB_ColorsInPal,size(curMap,1)]);
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
%---------------------------------
n_s = ...
    getWavMSG('Wavelet:divGUIRF:Img_Size',img_Name,img_Size(2),img_Size(1));
set(handles.Edi_Image_2,'String',n_s);                
image(wd2uiorui2d('d2uint',img_anal),'Parent',handles.Axe_Image_2); 
wguiutils('setAxesTitle',handles.Axe_Image_2, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',2),'On');
wguiutils('setAxesXlabel',handles.Axe_Image_Fus, ...
    getWavMSG('Wavelet:commongui:Syn_Img'),'On');
set(handles.Axe_Image_2,'Box','On');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Load_Img2_Callback','end');
if L1==L2
    if L1==3 , vis_UTCOLMAP = 'Off'; else vis_UTCOLMAP = 'On'; end
    cbcolmap('Visible',hFig,vis_UTCOLMAP); 
end
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pus_Decompose_Callback(hObject,eventdata,handles,varargin) %#ok<INUSL>

hFig = handles.output;
nbIN = length(varargin);
if nbIN<1
    img_Size_1 = wtbxappdata('get',hFig,'Size_IMG_1');
    img_Size_2 = wtbxappdata('get',hFig,'Size_IMG_2');
    D = length(img_Size_1)-length(img_Size_2);
    if D~=0
        dispWarnMessage(hFig);
        set(handles.Pus_Decompose,'Enable','Off');
        set(handles.Pus_Fusion,'Enable','Off');
        return;
    
    end
    flagIDX = length(img_Size_1)<3;
    setfigNAME(hFig,flagIDX)
end
axe_IND = [...
        handles.Axe_ImgDec_1 , ...
        handles.Axe_ImgDec_2 , ...
        handles.Axe_ImgDec_Fus ...
    ];
axe_CMD = [...
        handles.Axe_Image_1 , ...
        handles.Axe_Image_2 , ...
        handles.Axe_Image_Fus ...
    ];
axe_ACT = [];

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','beg');

% Decomposition.
%---------------
[wname,level] = cbanapar('get',hFig,'wav','lev');
Image_1 = findobj(handles.Axe_Image_1,'Type','image');
X = get(Image_1,'CData');
tree_1 = wfustree(X,level,wname);
Image_2 = findobj(handles.Axe_Image_2,'Type','image');
X = get(Image_2,'CData');
tree_2 = wfustree(X,level,wname);

% Store Decompositions Parameters.
%--------------------------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tool_PARAMS.DecIMG_1 = tree_1;
tool_PARAMS.DecIMG_2 = tree_2;
dwt_ATTRB = struct('type','dwt','wname',wname,'level',level);
tool_PARAMS.dwt_ATTRB = dwt_ATTRB;
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

% Show Decompositions.
%---------------------
DecIMG_1 = getdec(tree_1);
image(wd2uiorui2d('d2uint',DecIMG_1),'Parent',handles.Axe_ImgDec_1);
wguiutils('setAxesTitle',handles.Axe_ImgDec_1, ...
    getWavMSG('Wavelet:divGUIRF:Decomposition_X',1),'On');
set(handles.Axe_ImgDec_1,'Box','On');

DecIMG_2 = getdec(tree_2);
image(wd2uiorui2d('d2uint',DecIMG_2),'Parent',handles.Axe_ImgDec_2);
wguiutils('setAxesTitle',handles.Axe_ImgDec_2, ...
    getWavMSG('Wavelet:divGUIRF:Decomposition_X',2),'On');
set(handles.Axe_ImgDec_2,'Box','On');

dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pop_Fus_App_Callback(hObject,eventdata,handles)

Edi = handles.Edi_Fus_App;
Txt = handles.Txt_Edi_App;
set_Fus_Param(hObject,Edi,Txt,eventdata,handles)
set(handles.Tog_Inspect,'Enable','Off');
%--------------------------------------------------------------------------
function Pop_Fus_Det_Callback(hObject,eventdata,handles)

Edi = handles.Edi_Fus_Det;
Txt = handles.Txt_Edi_Det;
set_Fus_Param(hObject,Edi,Txt,eventdata,handles)
set(handles.Tog_Inspect,'Enable','Off');
%--------------------------------------------------------------------------
function Edi_Fus_App_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pop = handles.Pop_Fus_App;
Edi = handles.Edi_Fus_App;
tst_Fus_Param(Pop,Edi,eventdata,handles);
%--------------------------------------------------------------------------
function Edi_Fus_Det_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

Pop = handles.Pop_Fus_Det;
Edi = handles.Edi_Fus_Det;
tst_Fus_Param(Pop,Edi,eventdata,handles);
%--------------------------------------------------------------------------
function Pus_Fusion_Callback(hObject,eventdata,handles) %#ok<INUSL>

hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Pus_Fusion_Callback','beg');

% Get Decompositions Parameters.
%-------------------------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_1 = tool_PARAMS.DecIMG_1;
tree_2 = tool_PARAMS.DecIMG_2;
% dwt_ATTRB = tool_PARAMS.dwt_ATTRB;
% type  = dwt_ATTRB.type;
% wname = dwt_ATTRB.wname;
% level = dwt_ATTRB.level;

% Get Fusion Parameters.
%-----------------------
AfusMeth = get_Fus_Param('app',handles);
DfusMeth = get_Fus_Param('det',handles);

% Make Fusion.
%-------------
[XFus,tree_F] = wfusdec(tree_1,tree_2,AfusMeth,DfusMeth);
DecImgFus = getdec(tree_F);
tool_PARAMS.DecIMG_F = tree_F;
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

% Plot Decomposition and Image.
%------------------------------
axeCur = handles.Axe_ImgDec_Fus;
image(wd2uiorui2d('d2uint',DecImgFus),'Parent',axeCur);
wguiutils('setAxesXlabel',axeCur, ...
    getWavMSG('Wavelet:divGUIRF:FusionOfDec'),'On');
set(axeCur,'Box','On');

axeCur = handles.Axe_Image_Fus;
image(wd2uiorui2d('d2uint',XFus),'Parent',axeCur);
wguiutils('setAxesXlabel',axeCur, ...
    getWavMSG('Wavelet:commongui:Syn_Img'),'On');
set(axeCur,'Box','On');
%---------------------------------------------
axe_IND = [...
        handles.Axe_ImgDec_1 , ...
        handles.Axe_ImgDec_2 , ...
        handles.Axe_ImgDec_Fus ...
    ];
axe_CMD = [...
        handles.Axe_Image_1 , ...
        handles.Axe_Image_2 , ...
        handles.Axe_Image_Fus ...
    ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
set(handles.Tog_Inspect,'Enable','On');
CleanTOOL(hFig,eventdata,handles,'Pus_Fusion_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Tog_Inspect_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
Val_Inspect = get(hObject,'Value');

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','beg',Val_Inspect);

axe_INI = [...
        handles.Axe_ImgDec_1 , handles.Axe_ImgDec_2 , handles.Axe_ImgDec_Fus ,...
        handles.Axe_Image_1  , handles.Axe_Image_2 ,  handles.Axe_Image_Fus...
    ];
children = wfindobj(axe_INI,'type','axes','-xor');
child_INI = children(:)';
axe_TREE = [...
        handles.Axe_Tree_Dec , ...
        handles.Axe_Tree_Img1  , handles.Axe_Tree_Img2 ,  handles.Axe_Tree_ImgF...
    ];
children = wfindobj(axe_TREE,'type','axes','-xor');
child_DEC = children(:)';

hdl_Arrows = wtbxappdata('get',hFig,'hdl_Arrows');
switch Val_Inspect
    case 0 
        set([axe_TREE , child_DEC],'Visible','Off');
        delete(child_DEC);
        set([axe_INI  , child_INI , hdl_Arrows(:)'],'Visible','On');
        dynvtool('init',hFig,axe_INI(1:3),axe_INI,[],[1 1],'','','','int');
        set(hObject,'String',getWavMSG('Wavelet:divGUIRF:Inspect_FusTree'));
        set(handles.Pus_CloseWin,'Enable','On');
    case 1 
        dynvtool('ini_his',hFig,-1);
        set([axe_INI  , child_INI , hdl_Arrows(:)'],'Visible','Off');        
        set([axe_TREE , child_DEC],'Visible','On');
        Tree_MANAGER('create',hFig,eventdata,handles);
        set(hObject,'String',getWavMSG('Wavelet:divGUIRF:Return_Dec'));
        set(handles.Pus_CloseWin,'Enable','Off');
end

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','end',Val_Inspect);
wwaiting('off',hFig);
%--------------------------------------------------------------------------
function Pop_Nod_Lab_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
lab_Value  = get(hObject,'Value');
% lab_String = get(hObject,'String');
switch lab_Value
    case 1 , NodeLabType = 'index';
    case 2 , NodeLabType = 'depth_pos';
    case 3 , NodeLabType = 'size';
    case 4 , NodeLabType = 'type';
end
% NodeLabType = deblank(lab_String(lab_Value,:));
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
if isequal(NodeLabType,node_PARAMS.nodeLab) , return; end
node_PARAMS.nodeLab = NodeLabType;
wtbxappdata('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeLab',hFig,eventdata,handles,lab_Value)
%--------------------------------------------------------------------------
function Pop_Nod_Act_Callback(hObject,eventdata, handles) %#ok<DEFNU>

hFig = handles.output;
act_Value = get(hObject,'Value');
% act_String = get(hObject,'String');
switch act_Value
    case 1 , NodeActType = 'visualize';
    case 2 , NodeActType = 'reconstruct';
    case 3 , NodeActType = 'split_merge';
end
% NodeActType = deblank(act_String(act_Value,:));
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
if isequal(NodeActType,node_PARAMS.nodeAct) , return; end
node_PARAMS.nodeAct = NodeActType;
wtbxappdata('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeAct',hFig,eventdata,handles,act_Value)
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%



%=========================================================================%
%                    TREE MANAGEMENT and CALLBACK FUNCTIONS               %
%-------------------------------------------------------------------------%
function Tree_MANAGER(option,hFig,eventdata,handles,varargin) %#ok<INUSL>

% Miscellaneous Values.
%----------------------
line_color = [0 0 0];
actColor   = 'b';
inactColor = 'r';

% MemBloc of stored values.
%--------------------------
n_stored_val = 'NTREE_Plot';
ind_tree     = 1;
% ind_Class    = 2;
ind_hdls_txt = 3;
ind_hdls_lin = 4;
ind_menu_NodeLab =  5;
ind_type_NodeLab =  6;
% ind_menu_NodeAct =  7;
ind_type_NodeAct =  8;
% ind_menu_TreeAct =  9;
% ind_type_TreeAct = 10;
% nb1_stored = 10;

% Handles.
%---------
tool_hdl_AXES = wtbxappdata('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Dec  = axe_TREE(1);

% tool_PARAMS.
%-------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_F = tool_PARAMS.DecIMG_F;

switch option
    case 'create'
        % node_PARAMS.
        %-------------
        node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
        type_NodeLab = node_PARAMS.nodeLab;
        
        Tree_Colors = struct(...
            'line_color',line_color, ...
            'actColor',actColor,     ...
            'inactColor',inactColor);  
        wtbxappdata('set',hFig,'Tree_Colors',Tree_Colors);
        set(Axe_Tree_Dec,'DefaultTextFontSize',8)
        order = treeord(tree_F);
        depth = treedpth(tree_F);
        allN  = allnodes(tree_F);
        NBnod = (order^(depth+1)-1)/(order-1);
        table_node = -ones(1,NBnod);
        table_node(allN+1) = allN;
        [xnpos,ynpos] = xynodpos(table_node,order,depth);
        
        hdls_lin = zeros(1,NBnod);
        hdls_txt = zeros(1,NBnod);
        i_fath  = 1;
        i_child = i_fath+(1:order);
        for d=1:depth
            ynT = ynpos(d,:);
            ynL = ynT+[0.01 -0.01];
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        hdls_lin(ic) = line(...
                            'Parent',Axe_Tree_Dec, ...
                            'XData',[xnpos(i_fath) xnpos(ic)],...
                            'YData',ynL,...
                            'Color',line_color);
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end
        labels = tlabels(tree_F,'i'); % Indices
        textProp = {...
                'Parent',Axe_Tree_Dec,          ...
                'FontWeight','bold',            ...
                'Color',actColor,               ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle',   ...
                'Clipping','on'                 ...
            };    
        
        i_node = 1;   
        hdls_txt(i_node) = ...
            text(textProp{:},...
            'String', labels(i_node,:),   ...
            'Position',[0 0.1 0],         ...
            'UserData',table_node(i_node) ...
            );
        i_node = i_node+1;
        
        i_fath  = 1;
        i_child = i_fath+(1:order);
        for d=1:depth
            for p=0:order:order^d-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        hdls_txt(ic) = text(...
                            textProp{:},...
                            'String',labels(i_node,:), ...
                            'Position',[xnpos(ic) ynpos(d,2) 0],...
                            'UserData',table_node(ic)...
                            );
                        i_node = i_node+1;
                    end
                end
                i_child = i_child+order;
            end
        end
        nodeAction = ...
            @(o,~)wfustool('nodeAction_CallBack',o,[],hFig);        
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);
        [nul,notAct] = findactn(tree_F,allN,'na'); %#ok<ASGLU>
        set(hdls_txt(notAct+1),'Color',inactColor);
        %----------------------------------------------
        m_lab = [];
        wmemtool('wmb',hFig,n_stored_val, ...
            ind_tree,tree_F,      ...
            ind_hdls_txt,hdls_txt, ...
            ind_hdls_lin,hdls_lin, ...
            ind_menu_NodeLab,m_lab, ...
            ind_type_NodeLab,'Index', ...
            ind_type_NodeAct,'' ...
            );        
        %----------------------------------------------
        switch lower(type_NodeLab)
            case 'index' 
            otherwise    , plot(tree_F,'setNodeLabel',hFig,lower(type_NodeLab));
        end        
        %----------------------------------------------
        wguiutils('setAxesTitle',Axe_Tree_Dec, ...
            getWavMSG('Wavelet:divGUIRF:Wav_Dec_Tree'),'On');
        show_Node_IMAGES(hFig,'Visualize',0)
        
    case 'setNodeLab'
        if length(varargin)>1
            labValue = varargin{1};
        else
            handles = guihandles(hFig);
            labValue = get(handles.Pop_Nod_Lab,'Value');
        end
        switch labValue
            case 1 , labtype = 'i'; 
            case 2 , labtype = 'dp';
            case 3 , labtype = 's';
            case 4 , labtype = 't';
        end
        labels = tlabels(tree_F,labtype);
        hdls_txt = wmemtool('rmb',hFig,n_stored_val,ind_hdls_txt);
        hdls_txt = hdls_txt(hdls_txt~=0);
        for k=1:length(hdls_txt), set(hdls_txt(k),'String',labels(k,:)); end

    case 'setNodeAct'
        nodeAction = ...
            @(o,~)wfustool('nodeAction_CallBack',o,[],hFig);
        hdls_txt = wmemtool('rmb',hFig,n_stored_val,ind_hdls_txt);
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);        
end
%-------------------------------------------------------------------------
function nodeAction_CallBack(hObject,eventdata,hFig) %#ok<INUSL,DEFNU>

node = plot(ntree,'getNode',hFig);
if isempty(node) , return; end
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
nodeAct = lower(node_PARAMS.nodeAct);
if isequal(nodeAct,'split_merge') || isequal(nodeAct,'split / merge')
    tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
    tree_F = tool_PARAMS.DecIMG_F;
    tnrank = findactn(tree_F,node);
    if isnan(tnrank) , return;  end
    plot(tree_F,'Split-Merge',hFig);
    tree_1 = tool_PARAMS.DecIMG_1;
    tree_2 = tool_PARAMS.DecIMG_2;
    if tnrank>0
        tree_1 = nodesplt(tree_1,node);
        tree_2 = nodesplt(tree_2,node);
        tree_F = nodesplt(tree_F,node);
    else
        tree_1 = nodejoin(tree_1,node);
        tree_2 = nodejoin(tree_2,node);
        tree_F = nodejoin(tree_F,node);
    end
    tool_PARAMS.DecIMG_1 = tree_1;
    tool_PARAMS.DecIMG_2 = tree_2;
    tool_PARAMS.DecIMG_F = tree_F;
    wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
    Tree_MANAGER('setNodeLab',hFig,eventdata,guihandles(hFig))
else
    show_Node_IMAGES(hFig,nodeAct,node);
end
%-------------------------------------------------------------------------
function show_Node_IMAGES(hFig,nodeAct,node)

tool_hdl_AXES = wtbxappdata('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Img1 = axe_TREE(2);
Axe_Tree_Img2 = axe_TREE(3);
Axe_Tree_ImgF = axe_TREE(4);
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_1 = tool_PARAMS.DecIMG_1;
tree_2 = tool_PARAMS.DecIMG_2;
tree_F = tool_PARAMS.DecIMG_F;

mousefrm(hFig,'watch')
NBC = cbcolmap('get',hFig,'nbColors');
flag_INVERSE = false;
show_One_IMAGE(nodeAct,tree_1,node,NBC,flag_INVERSE,Axe_Tree_Img1, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',1))
show_One_IMAGE(nodeAct,tree_2,node,NBC,flag_INVERSE,Axe_Tree_Img2, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',2))
show_One_IMAGE(nodeAct,tree_F,node,NBC,flag_INVERSE,...
    Axe_Tree_ImgF,getWavMSG('Wavelet:commongui:Syn_Img'))
lind = tlabels(tree_F,'i',node);
ldep = tlabels(tree_F,'p',node);
if isequal(nodeAct,'reconstruct')
    axeTitle = getWavMSG('Wavelet:divGUIRF:RecCfsNode',lind,ldep);
else
    axeTitle = getWavMSG('Wavelet:divGUIRF:CfsNode',lind,ldep);
end
title(axeTitle,'Parent',Axe_Tree_ImgF);
mousefrm(hFig,'arrow')
dynvtool('init',hFig,axe_TREE(1),axe_TREE(2:4),[],[1 1],'','','','int');
%-------------------------------------------------------------------------
function show_One_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE,axe,xlab)

X = getCoded_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE);
image(wd2uiorui2d('d2uint',X),'Parent',axe);
wguiutils('setAxesXlabel',axe,xlab,'On');
set(axe,'Box','On');
%-------------------------------------------------------------------------
function X = getCoded_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE)

switch lower(nodeAct)
    case 'visualize' , [nul,X] = nodejoin(treeOBJ,node); %#ok<ASGLU>
    case 'reconstruct' , X = rnodcoef(treeOBJ,node);
end
if node>0  
    X = wcodemat(X,NBC,'mat',1);
    if flag_INVERSE && rem(node,4)~=1 , X = max(X(:))-X; end
end
%==========================================================================


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,numDEM) %#ok<INUSL>

optIMG   = 'BW';
switch numDEM
    case 1 
        I_1 = 'detail_1'; I_2 = 'detail_2';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max';
        DfusMeth = 'max';       
    case 2
        I_1 = 'cathe_1'; I_2 = 'cathe_2';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max'; 
        DfusMeth = 'max'; 
    case 3
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max';
        DfusMeth = 'max';
    case 4
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'bior6.8' ; level = 3;
        AfusMeth = 'rand';
        DfusMeth = 'max';
    case 5
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',4);
        DfusMeth = struct('name','UD_fusion','param',1);
    case 6
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'DU_fusion'; DfusMeth = 'DU_fusion';
    case 7
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'LR_fusion'; 
        DfusMeth = 'LR_fusion';
    case 8
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'RL_fusion';
        DfusMeth = 'RL_fusion';
    case 9
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'sym6' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',2);
        DfusMeth = struct('name','UD_fusion','param',4);
    case 10
        I_1 = 'face_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'mean';
        DfusMeth = 'max';
    case 11
        I_1 = 'face_pai'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'mean';
        DfusMeth = 'max';
    case 12
        I_1 = 'fond_bou'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',1);
        DfusMeth = 'max';
    case 13
        I_1 = 'fond_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',1);
        DfusMeth = 'max';
    case 14
        I_1 = 'fond_pav'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'max';
    case 15
        I_1 = 'fond_tex'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth  = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'img1';
    case 16
        I_1 = 'pile_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth  = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'img1';
    case 17
        I_1 = 'arms.jpg'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max';
    case 18
        I_1 = 'arms.jpg'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max';
        optIMG   = 'COL';
    case 19
        I_1 = 'facets'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max';
        optIMG   = 'COL'; 
    case 20
        I_1 = 'mask'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','RL_fusion','param',1);
        DfusMeth = struct('name','LR_fusion','param',1);
        optIMG   = 'COL';        
end

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
def_nbCodeOfColors = 255;
filename = I_1;
idx = strfind(filename,'.');
if isempty(idx) 
    filename = [filename '.mat'];
end
pathname = utguidiv('WTB_DemoPath',filename);
[imgInfos_1,X_1,map,ok] = ...
    utguidiv('load_dem2D',hFig,pathname,filename,def_nbCodeOfColors,optIMG); %#ok<ASGLU>
if ~ok, return; end
% tst_ImageSize(hFig,1,imgInfos_1);

filename = I_2;
idx = strfind(filename,'.');
if isempty(idx) , filename = [filename '.mat']; end
[imgInfos_2,X_2,map,ok] = ...
    utguidiv('load_dem2D',hFig,pathname,filename,def_nbCodeOfColors,optIMG);
if ~ok, return; end
% tst_ImageSize(hFig,2,imgInfos_2);
flagIDX = length(imgInfos_1.size)<3;
setfigNAME(hFig,flagIDX)

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));
CleanTOOL(hFig,eventdata,handles,'demo_FUN');

% Setting Analysis parameters
%----------------------------
cbanapar('set',hFig,'wav',wname,'lev',level);
set_Fus_Methode('app',AfusMeth,eventdata,handles);
set_Fus_Methode('det',DfusMeth,eventdata,handles);

% Loading Images and Setting GUI.
%-------------------------------
img_Size_1 = imgInfos_1.size;
if isequal(imgInfos_1.true_name,'X')
    img_Name_1 = imgInfos_1.name;
else
    img_Name_1 = imgInfos_1.true_name;
end
wtbxappdata('set',hFig,'Size_IMG_1',img_Size_1);
NB_ColorsInPal = size(map,1);
if imgInfos_1.self_map 
    arg = map; 
else
    arg = [];
end
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
n_s = ...
    getWavMSG('Wavelet:divGUIRF:Img_Size',img_Name_1,img_Size_1(2),img_Size_1(1));
set(handles.Edi_Data_NS,'String',n_s);                
image(X_1,'Parent',handles.Axe_Image_1);
wguiutils('setAxesTitle',handles.Axe_Image_1, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',1),'On');
set(handles.Axe_Image_1,'Box','On');
%--------------------------------------------
if isequal(imgInfos_2.true_name,'X')
    img_Name_2 = imgInfos_2.name;
else
    img_Name_2 = imgInfos_2.true_name;
end
img_Size_2 = imgInfos_2.size;
wtbxappdata('set',hFig,'Size_IMG_2',img_Size_2);
NB_ColorsInPal = size(map,1);
if imgInfos_2.self_map 
    arg = map; 
else
    arg = [];
end
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
n_s = ...
    getWavMSG('Wavelet:divGUIRF:Img_Size',img_Name_2,img_Size_2(2),img_Size_2(1));
set(handles.Edi_Image_2,'String',n_s);                
image(X_2,'Parent',handles.Axe_Image_2);
wguiutils('setAxesTitle',handles.Axe_Image_2, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',2),'On');
set(handles.Axe_Image_2,'Box','On');
%--------------------------------------------
if length(size(X_2))>2 
    vis_UTCOLMAP = 'Off'; 
else
    vis_UTCOLMAP = 'On';
end
cbcolmap('Visible',hFig,vis_UTCOLMAP);

% Decomposition and Fusion.
%--------------------------
Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles,'demo');
Pus_Fusion_Callback(handles.Pus_Fusion,eventdata,handles);
%--------------------------------------------------------------------------
function set_Fus_Methode(type,fusMeth,eventdata,handles)

switch type
    case 'app'
        Pop = handles.Pop_Fus_App;
        Edi = handles.Edi_Fus_App;
    case 'det'
        Pop = handles.Pop_Fus_Det;
        Edi = handles.Edi_Fus_Det;
end
if ischar(fusMeth)
    fusMeth = struct('name',fusMeth,'param','');
end
methName = fusMeth.name;
tabMeth = wtranslate('ORI_fus_meth');
numMeth = find(strncmp(methName,tabMeth,length(methName)));
set(Pop,'Value',numMeth);
switch type
    case 'app' , Pop_Fus_App_Callback(Pop,eventdata,handles);
    case 'det' , Pop_Fus_Det_Callback(Pop,eventdata,handles);
end
ediVAL = get(Edi,'String');
newVAL = num2str(fusMeth.param);
if isempty(newVAL) , newVAL = ediVAL; end
set(Edi,'String',newVAL);
%-------------------------------------------------------------------------
function save_FUN(hObject,eventdata,handles) %#ok<INUSL>

% Get figure handle.
%-------------------
hFig = handles.output;

% Getting Synthesized Image.
%---------------------------
axe = handles.Axe_Image_Fus;
img_Fus = findobj(axe,'Type','image');
X = round(get(img_Fus,'CData'));
utguidiv('save_img',getWavMSG('Wavelet:commongui:Sav_Synt_Img'),hFig,X);
%-------------------------------------------------------------------------%
function Export_Callback(hObject,eventdata,handles) %#ok<INUSL,DEFNU>

hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitExport'));
axe = handles.Axe_Image_Fus;
img_Fus = findobj(axe,'Type','image');
Xfus = round(get(img_Fus,'CData'));
wtbxexport(Xfus,'name','Xfus','title', ...
    getWavMSG('Wavelet:commongui:Str_ExportImg'));
wwaiting('off',hFig);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%
function CleanTOOL(hFig,eventdata,handles,callName,option,varargin) %#ok<INUSL>

tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
hdl_Menus   = wtbxappdata('get',hFig,'hdl_Menus');
ena_LOAD_DEC = 'On';
switch callName
    case 'demo_FUN'
        tool_PARAMS.flagIMG_1 = true;
        tool_PARAMS.flagIMG_2 = true;
        tool_PARAMS.flagDEC   = false;
        tool_PARAMS.flagFUS   = false;
        tool_PARAMS.flagINS   = false;
        hAXE = [handles.Axe_ImgDec_1,  handles.Axe_ImgDec_2,...
                handles.Axe_Image_Fus, handles.Axe_ImgDec_Fus];
        hIMG = findobj(hAXE,'Type','image');
        delete(hIMG);
                
    case 'Load_Img1_Callback'
        switch option
            case 'beg'
                tool_PARAMS.flagIMG_1 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagFUS   = false;
                tool_PARAMS.flagINS   = false;
                hAXE = [handles.Axe_ImgDec_1,handles.Axe_ImgDec_2 ...
                        handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus ...
                        ];
                hIMG = findobj(hAXE,'Type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Load_Img2_Callback'
        switch option
            case 'beg' 
                tool_PARAMS.flagIMG_2 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagFUS   = false;
                tool_PARAMS.flagINS   = false;
                hAXE = [handles.Axe_ImgDec_1,handles.Axe_ImgDec_2 ...
                        handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus ...
                        ];
                hIMG = findobj(hAXE,'Type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Pus_Decompose_Callback'
        switch option
            case 'beg'  
                tool_PARAMS.flagDEC = true;
                tool_PARAMS.flagFUS = false;
                hAXE = [handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus];
                hIMG = findobj(hAXE,'Type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Pus_Fusion_Callback'
        switch option
            case 'beg' 
            case 'end' , tool_PARAMS.flagFUS = true;
        end
        
    case 'Tog_Inspect_Callback'
        Val_Inspect = varargin{1};
        flag_Enable = logical(1-Val_Inspect);
        switch option
            case 'beg' 
                tool_PARAMS.flagDEC = false;
                ena_LOAD_DEC = 'Off';
                ena_FUS_PAR  = 'Off';
                ena_NOD_OPT  = 'Off';
            case 'end' 
                tool_PARAMS.flagDEC = flag_Enable;
                if flag_Enable
                    ena_LOAD_DEC = 'On';
                    ena_FUS_PAR  = 'On';
                    ena_NOD_OPT  = 'Off';
                else
                    ena_LOAD_DEC = 'Off';
                    ena_FUS_PAR  = 'Off';
                    ena_NOD_OPT  = 'On';
                end
        end
        m_Load_Img1 = hdl_Menus.m_Load_Img1;
        m_Load_Img2 = hdl_Menus.m_Load_Img2;
        m_demo = hdl_Menus.m_demo;
        set([m_Load_Img1,m_Load_Img2,m_demo....
             handles.Pus_Decompose],'Enable',ena_LOAD_DEC);
        set([handles.Txt_Fus_Params, ...
             handles.Txt_Fus_App,handles.Pop_Fus_App,  ...
             handles.Txt_Edi_App,handles.Edi_Fus_App,  ...
             handles.Txt_Fus_Det,handles.Pop_Fus_Det,  ...
             handles.Txt_Edi_Det,handles.Edi_Fus_Det],  ...         
            'Enable',ena_FUS_PAR);
        set([handles.Txt_Nod_Lab,handles.Pop_Nod_Lab, ...
             handles.Txt_Nod_Act,handles.Pop_Nod_Act,], ...
            'Enable',ena_NOD_OPT);
end
Ok_DEC = tool_PARAMS.flagIMG_1 & tool_PARAMS.flagIMG_2;
% Here we should have hFig.UserData.okSize as false for images of unequal
% size. The apply button should not enable until the decompose operation
% has completed.
if Ok_DEC && isequal(ena_LOAD_DEC,'On') && hFig.UserData.okSize
    set(handles.Pus_Decompose,'Enable','On');
else
    set(handles.Pus_Decompose,'Enable','Off');
end
if tool_PARAMS.flagDEC
    set(handles.Pus_Fusion,'Enable','On');
else
    set(handles.Pus_Fusion,'Enable','Off');
end

m_save = hdl_Menus.m_save;
m_exp_sig = hdl_Menus.m_exp_sig;
if tool_PARAMS.flagFUS
    set(handles.Tog_Inspect,'Enable','On');
    set([m_save,m_exp_sig],'Enable','On')
else
    set(handles.Tog_Inspect,'Enable','Off');
    set([m_save,m_exp_sig],'Enable','Off')
end

wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
%--------------------------------------------------------------------------
%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%



%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) %#ok<INUSL>

% WTBX -- Install DynVTool
%-------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX -- Install ANAPAR FRAME
%-----------------------------
wnameDEF  = 'db1';
maxlevDEF = 5;
levDEF    = 2;
utanapar('Install_V3_CB',hObject,'maxlev',maxlevDEF,'deflev',levDEF);
cbanapar('set',hObject,'wav',wnameDEF,'lev',levDEF);

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'Enable','On');
default_nbcolors = 128;
cbcolmap('set',hObject,'pal',{'pink',default_nbcolors})
%-------------------------------------------------------------------------
% TOOL INITIALISATION
%-------------------------------------------------------------------------
% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(hObject,handles);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);
%------------------------------------------------
set(hObject,'DefaultAxesXTick',[],'DefaultAxesYTick',[],...
    'DefaultAxesXTickMode','manual','DefaultAxesYTickMode','manual')
hdl_Arrows = arrowfus(handles,'On');
wtbxappdata('set',hObject,'hdl_Arrows',hdl_Arrows);
%-------------------------------------------------------------------------
axe_INI = [...
    handles.Axe_ImgDec_1 , handles.Axe_ImgDec_2 , handles.Axe_ImgDec_Fus ,...
    handles.Axe_Image_1  , handles.Axe_Image_2 ,  handles.Axe_Image_Fus...
    ];
axe_TREE = [...
    handles.Axe_Tree_Dec , ...
    handles.Axe_Tree_Img1  , handles.Axe_Tree_Img2 ,  handles.Axe_Tree_ImgF...
    ];
tool_hdl_AXES = struct('axe_INI',axe_INI,'axe_TREE',axe_TREE);
wtbxappdata('set',hObject,'tool_hdl_AXES',tool_hdl_AXES);
set(hObject,'Visible','Off');drawnow
%-------------------------------------------------------------------------
wguiutils('setAxesTitle',handles.Axe_Image_1, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',1));
wguiutils('setAxesTitle',handles.Axe_Image_2, ...
    getWavMSG('Wavelet:divGUIRF:Image_X',2));
wguiutils('setAxesXlabel',handles.Axe_Image_Fus, ...
    getWavMSG('Wavelet:commongui:Syn_Img'));
wguiutils('setAxesTitle',handles.Axe_ImgDec_1, ...
    getWavMSG('Wavelet:divGUIRF:Decomposition_X',1));
wguiutils('setAxesTitle',handles.Axe_ImgDec_2, ...
    getWavMSG('Wavelet:divGUIRF:Decomposition_X',2));
wguiutils('setAxesXlabel',handles.Axe_ImgDec_Fus, ...
    getWavMSG('Wavelet:divGUIRF:FusionOfDec'));
%-------------------------------------------------------------------------
dwt_ATTRB   = struct('type','lwt','wname','','level',[]);
tool_PARAMS = struct(...
    'infoIMG_1',[],'infoIMG_2',[],...    
    'flagIMG_1',false,'flagIMG_2',false,...
    'flagDEC',false,'flagFUS',false, 'flagINS',false, ...
    'DecIMG_1',[],'DecIMG_2',[],'DecIMG_F',[], ...
    'dwt_ATTRB',dwt_ATTRB);
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);
%-------------------------------------------------------------
node_PARAMS = struct('nodeLab','index','nodeAct','visualize');
wtbxappdata('set',hObject,'node_PARAMS',node_PARAMS);
%--------------------------------------------------------------

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(hFig,handles)

m_files = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = @(o,~)wfustool('Pus_CloseWin_Callback',o,[],guidata(o));
set(m_close,'Callback',cb_close);

m_Load_Img1 = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Load_OR_Import_X',1), ...
    'Tag','Load_OR_Import_1', ...
    'Position',1,'Enable','On'         ...
    );
m_Load_Img2 = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Load_OR_Import_X',2), ...
    'Tag','Load_OR_Import_2', ...    
    'Position',2,'Enable','On'            ...
    );
m_save = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:commongui:SaveSI'), ...
    'Position',3, 'Enable','Off',  ...
    'Callback',@(o,~)wfustool('save_FUN',o,[],guidata(o)) ...
    );
m_demo = uimenu(m_files,'Label',getWavMSG('Wavelet:commongui:Lab_Example'), ...
    'Position',4,'Separator','Off');
m_exp_sig = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Str_ExpImg'),'Position',5, ...
    'Enable','Off','Separator','On',...
    'Tag','Export', ...
    'Callback',@(o,~)wfustool('Export_Callback',o,[],guidata(o))  ...
    );

uimenu(m_Load_Img1, ...
    'Label',getWavMSG('Wavelet:commongui:Load_Image'),   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    @(o,~)wfustool('Load_Img1_Callback',o,[],guidata(o))  ...
    );
 uimenu(m_Load_Img1, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Import'),   ...
    'Position',2,              ...
    'Enable','On',             ...
    'Tag','Import_1',          ...
    'Callback',                ...
    @(o,~)wfustool('Load_Img1_Callback',o,[],guidata(o),1)  ...
    );

uimenu(m_Load_Img2, ...
    'Label',getWavMSG('Wavelet:commongui:Load_Image'),   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    @(o,~)wfustool('Load_Img2_Callback',o,[],guidata(o))  ...
    );
 uimenu(m_Load_Img2, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_Import'),   ...
    'Position',2,              ...
    'Enable','On',             ...
    'Tag','Import_2',          ...    
    'Callback',                ...
    @(o,~)wfustool('Load_Img2_Callback',o,[],guidata(o),1)  ...
    );

m_demoIDX = uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_IndImg'), ...
    'Tag','Lab_IndImg', ...    
    'Position',1);
m_demoCOL = uimenu(m_demo, ...
    'Label',getWavMSG('Wavelet:commongui:Lab_ColImg'),...
    'Tag','Lab_ColImg', ...
    'Position',2);

nbDEM = 20;
demoSET = cell(nbDEM,1);
for k = 1:nbDEM
    demoSET{k} = getWavMSG(['Wavelet:divGUIRF:WFUS_Ex' int2str(k)]);
end
% demoSET = {...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Magic Square','db1',2,'(max,max)') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Catherine','db1',2,'(max,max)') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','db1',2,'(max,max)') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','bior6.8',3,'(rand,max)') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','db1',3,'(UD_fusion,UD_fusion') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','db1',3,'(DU_fusion,DU_fusion))') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','db1',3,'(LR_fusion,LR_fusion)') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','db1',3,'(RL_fusion,RL_fusion)') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Bust','sym6',3,'([UD_fusion,2] , [UD_fusion,4] )') ; ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (1) and Mask','sym4',3,'(mean,max)');  ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (2) and Mask','sym4',3,'(mean,max)');  ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (3) and Mask','sym4',3,'( [UD_fusion,1] , max)'); ... 
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (4) and Mask','sym4',3,'( [UD_fusion,1] , max)'); ... 
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (5) and Mask','sym4',3,'( [UD_fusion,0.5] , max)'); ... 
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (6) and Mask','sym4',3,'( [UD_fusion,0.5] , img1)');  ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (7) and Mask','sym4',3,'( [UD_fusion,0.5] , img1)');  ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (8) and Arms','sym4',3,'(img1,max)');  ...
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Texture (8) and Arms (COL)','sym4',3,'(img1,max)');  ...        
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Facets and Mask' ,'sym4',3,'(img1,max)');  ...        
%     getWavMSG('Wavelet:divGUIRF:WFUS_DemoEX','Mask and Texture (8)','sym4',3,'( [LR_fusion,1] , [RL_fusion,1] )'),  ...
%     };
% nbDEM = size(demoSET,1);
sepSET = [3,10];
for k = 1:nbDEM

    action = @(o,~)wfustool('demo_FUN',o,[],guidata(o),k);
    if find(k==sepSET)
        Sep = 'On';
    else
        Sep = 'Off';
    end
    if k<18
        md = m_demoIDX;
    else
        md = m_demoCOL;
    end
    uimenu(md,'Label',[demoSET{k}],'Separator',Sep,'Callback',action);
end
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_Load_Img1',m_Load_Img1,'m_Load_Img2',m_Load_Img2,...
    'm_save',m_save,'m_demo',m_demo,'m_exp_sig',m_exp_sig);

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig, ...
    getWavMSG('Wavelet:divGUIRF:Image_Fusion'),'WFUS_GUI');
hdl_FUS = [...
        handles.Txt_Edi_Det , handles.Txt_Edi_App , handles.Pop_Fus_Det , ...
        handles.Pop_Fus_App , handles.Txt_Fus_Params , handles.Pus_Fusion , ...
        handles.Txt_Fus_Det , handles.Txt_Fus_App , handles.Fra_Fus_Params ...
        ];
wfighelp('add_ContextMenu',hFig,hdl_FUS,'WFUS_IMG');
%-------------------------------------------------------------------------

% BEGIN: Arrows for WTBX FUSION TOOL %
%------------------------------------%
function hdl_Arrows = arrowfus(handles,visible)
%ARROWFUS Plot the arrows for WFUSTOOL.

colArrowDir = [0.925 0.925 0.925]; % Gray 
colArrowRev = colArrowDir;
axe_arrow = handles.Axe_Utils;
Axe_Image_1    = handles.Axe_Image_1;
Axe_ImgDec_1   = handles.Axe_ImgDec_1;
Axe_Image_2    = handles.Axe_Image_2;
Axe_ImgDec_2   = handles.Axe_ImgDec_2;
Axe_Image_Fus  = handles.Axe_Image_Fus;
Axe_ImgDec_Fus = handles.Axe_ImgDec_Fus;
[ar1,t1] = PlotArrow('direct',axe_arrow, ...
    Axe_Image_1,Axe_ImgDec_1,colArrowDir,visible);
[ar2,t2] = PlotArrow('direct',axe_arrow, ...
    Axe_Image_2,Axe_ImgDec_2,colArrowDir,visible);
[ar3,t3] = PlotArrow('reverse',axe_arrow, ...
    Axe_Image_Fus,Axe_ImgDec_Fus,colArrowRev,visible);
[ar4,t4] = PlotArrowVER(axe_arrow, ...
    Axe_ImgDec_1,Axe_ImgDec_2,Axe_ImgDec_Fus,colArrowDir,visible);
set(axe_arrow,'XLim',[0,1],'YLim',[0,1])
hdl_Arrows = [ [ar1,t1] ; [ar2,t2] ; [ar3,t3] ; [ar4,t4]];        
%----------------------------------------------------------------
function [ar,t] = ...
    PlotArrow(option,axe_arrow,axeINI,axeEND,colArrow,visible)

pImg = get(axeINI,'Position');
pDec = get(axeEND,'Position');
xAR_ini = pImg(1) + pImg(3);
xAR_end = pDec(1);
dx      = (xAR_end - xAR_ini);
yAR     = pImg(2) + pImg(4)/2;
pt1 = [xAR_ini+dx/6 yAR];
pt2 = [xAR_end-dx/6 yAR];
if isequal(option,'reverse')
    rot = pi; Pini = pt2; strTXT = 'idwt'; colorTXT = 'r';
else
    rot = 0;  Pini = pt1; strTXT = 'dwt';  colorTXT = 'b';
end
ar = wtbarrow('create','axes',axe_arrow,...
    'Scale',[pt2(1)-pt1(1) 1/9],'Trans',Pini,'Rotation',rot, ...
    'Color',colArrow,'Visible',visible);
t = text(...
    'Parent',axe_arrow,...
    'Position',[xAR_ini + dx/3 yAR],...
    'String',strTXT,'FontSize',12,'FontWeight','demi','Color',colorTXT);
%----------------------------------------------------------------
function [ar,t] = PlotArrowVER(axe_arrow,...
    Axe_ImgDec_1,Axe_ImgDec_2,Axe_ImgDec_Fus,colArrow,visible)

pDec1 = get(Axe_ImgDec_1,'Position');
pDec2 = get(Axe_ImgDec_2,'Position');
pDecF = get(Axe_ImgDec_Fus,'Position');
dy = pDec1(4)/4;
E  = 11*dy/60; 

xAR_ini = pDec1(1) + pDec1(3);
yAR_ini = pDec1(2) + pDec1(4)/2;
Pini  = [xAR_ini , yAR_ini];

x1 = 0;
x2 = pDec1(2)-pDec2(2);
x3 = pDec1(2)-pDecF(2);
XVal = [x1 , x2 , x3];
YVal = [E , 2.5*E , 6*E];

typeARROW_VER = 'special_1';
ar = wtbarrow(typeARROW_VER,'axes',axe_arrow,...
    'XVal',XVal,'YVal',YVal, ...
    'HArrow',dy/4,'WArrow',dy/5,'Width',E, ...
    'Trans',Pini,'Rotation',pi/2, ...   
    'Color',colArrow,'Visible',visible);
xT = xAR_ini + 7*E;
yT = ((pDec1(2) + pDec1(2) + pDec1(4)/2)/2 + pDecF(2)+pDecF(4)/2)/2;
colorTXT = 'k';
t = text(...
    'Parent',axe_arrow,...    
    'Position',[xT yT],...
    'String', getWavMSG('Wavelet:divGUIRF:Str_FUSION'),'Color',colorTXT,...
    'FontWeight','bold','FontSize',10,'Rotation',-90);
%-------------------------------------------------------------------------
% END: Arrows for WTBX FUSION TOOL 
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function method = get_Fus_Param(type,handles)

switch type
    case 'app'
        Pop = handles.Pop_Fus_App;
        Edi = handles.Edi_Fus_App;
    case 'det'
        Pop = handles.Pop_Fus_Det;
        Edi = handles.Edi_Fus_Det;
end
numMeth = get(Pop,'Value');
tabMeth = wtranslate('ORI_fus_meth');
methName = tabMeth{numMeth};
switch methName
    case {'max','min','mean','rand','img1','img2'}  
        param = get(Edi,'String');
    case 'linear'   
        param = str2double(get(Edi,'String'));
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        param = str2double(get(Edi,'String'));
    case 'userDEF' 
        tst_Fus_Param(Pop,Edi,[],handles);
        param = get(Edi,'String');        
end
method  = struct('name',methName,'param',param);
%--------------------------------------------------------------------------
function set_Fus_Param(Pop,Edi,Txt,eventdata,handles) %#ok<INUSD>

numMeth = get(Pop,'Value');
tabMeth = wtranslate('ORI_fus_meth');
methName = tabMeth{numMeth};
switch methName
    case {'max','min','mean','rand','img1','img2'}  
        vis = 'Off'; ediVAL = ''; txtSTR = '';
    case 'linear'   
        vis = 'On'; ediVAL = 0.5; 
        txtSTR = getWavMSG('Wavelet:moreMSGRF:Par_In_0_1','<=','<=');
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        vis = 'On'; ediVAL = 1;   
        txtSTR = getWavMSG('Wavelet:moreMSGRF:Par_Sup_0','<=');
    case 'userDEF' 
        vis = 'On'; ediVAL = '';  
        txtSTR = getWavMSG('Wavelet:moreMSGRF:Par_FuncName');
end
set(Txt,'String',txtSTR);
set(Edi,'String',num2str(ediVAL));
set([Edi,Txt],'Visible',vis);
%--------------------------------------------------------------------------
function ok = tst_Fus_Param(Pop,Edi,eventdata,handles) %#ok<INUSD>

numMeth = get(Pop,'Value');
tabMeth = wtranslate('ORI_fus_meth');
methName = tabMeth{numMeth};
switch methName
    case 'linear'   
        def_ediVAL = 0.5;
        param = str2double(get(Edi,'String'));
        ok = ~isnan(param);
        if ok , ok = (0 <= param) & (param <= 1); end
        
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        def_ediVAL = 1;
        param = str2double(get(Edi,'String'));
        ok = ~isnan(param);
        if ok , ok = (0 <= param); end
        
    case 'userDEF' 
        def_ediVAL = 'wfusfun';
        param = get(Edi,'String');
        ok = ~isempty(param) & ischar(param);
        if ok 
            userFusFUN = which(param);
            ok = ~isempty(userFusFUN);
        end
        
    otherwise
        ok = true; param = get(Edi,'String');
end
if ok , def_ediVAL = param; end
set(Edi,'String',num2str(def_ediVAL));
%--------------------------------------------------------------------------
function okSize = tst_ImageSize(hFig,numIMG,info_IMG)
% tst_ImageSize returns the okSize value. This is stored in the UserData of
% the figure handle for evaluation in order to enable or disable decompose
% button.
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');  
switch numIMG
    case 1 , info_OTHER = tool_PARAMS.infoIMG_2;
    case 2 , info_OTHER = tool_PARAMS.infoIMG_1;
end
if isempty(info_OTHER)
    okSize = true;
else
    okSize = isequal(info_IMG.size,info_OTHER.size);
end
if ~okSize 
    dispWarnMessage(hFig); 
   
    
end
switch numIMG
    case 1 , tool_PARAMS.infoIMG_1 = info_IMG;
    case 2 , if okSize , tool_PARAMS.infoIMG_2 = info_IMG; end
end
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

%--------------------------------------------------------------------------
function dispWarnMessage(hFig)

warnMsg = getWavMSG('Wavelet:divGUIRF:WFUS_CautionMsg');
h = warndlg(warnMsg,getWavMSG('Wavelet:divGUIRF:Str_Caution'),'modal');
h.Tag = 'warning';
waitfor(h);
wwaiting('off',hFig);
%------------------------------------------------------------------------
function setfigNAME(fig,flagIDX)

if flagIDX
    figNAME = getWavMSG('Wavelet:divGUIRF:WFUS_Nam_Ind');
else
    figNAME = getWavMSG('Wavelet:divGUIRF:WFUS_Nam_TC');
end
set(fig,'Name',figNAME);
%-------------------------------------------------------------------------
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles) %#ok<INUSD,DEFNU>

delete(hFig)
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin) %#ok<INUSL,DEFNU>

handles = guidata(hFig);
numDEM  = varargin{1};
demo_FUN(hFig,eventdata,handles,numDEM);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
