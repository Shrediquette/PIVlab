function varargout = dw3dtool(varargin)
%DW3DTOOL Discrete wavelet 3D tool.
%   VARARGOUT = DW3DTOOL(VARARGIN)

%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% DDUX data logging
if isempty(varargin) 
    dataId = matlab.ddux.internal.DataIdentification("WA", ...
        "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
    DDUXdata = struct();
    DDUXdata.appName = "dw3dtool";
    matlab.ddux.internal.logData(dataId,DDUXdata);
end

%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dw3dtool_OpeningFcn, ...
                   'gui_OutputFcn',  @dw3dtool_OutputFcn, ...
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
% --- Executes just before dw3dtool is made visible.                      %
%*************************************************************************%
function dw3dtool_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<VANUS>
% This function has no output args, see OutputFcn.

% Choose default command line output for dw3dtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALIZATION Introduced manually in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = dw3dtool_OutputFcn(hObject,eventdata,handles) 
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
function Pus_CloseWin_Callback(hObject,eventdata,handles)   %#ok<DEFNU>

status = tst_Save(eventdata,handles);
if isequal(status,-1) , return; end
dw3dtool_Win_DeleteFcn(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function dw3dtool_Win_DeleteFcn(hObject,eventdata,handles) 

hFig = handles.output;
% s = dbstack;
% pus_Call = any(strcmp({s(:).name},'Pus_CloseWin_Callback'));
% if ~pus_Call , tst_Save(eventdata,handles); end
try
    figChild = wfigmngr('getWinPROP',hFig,'FigChild');
    figChild = figChild(ishandle(figChild));
    delete(figChild);
end %#ok<*TRYNC>
delete(hFig);
%--------------------------------------------------------------------------
function status = tst_Save(eventdata,handles)

hFig = handles.output;
status = 0;
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    status = wwaitans({hFig,getWavMSG('Wavelet:divGUIRF:III_D_Analysis')},...
        getWavMSG('Wavelet:commongui:QUEST_Save_Dec'),2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));
            save_FUN(m_save,eventdata,handles,'dec')
            wwaiting('off',hFig);
        otherwise
    end
end
%--------------------------------------------------------------------------
function Load_Data_Callback(hObject,eventdata,handles,varargin) 

% Get figure handle.
%-------------------
hFig = handles.output;

typeLOAD = varargin{1};
switch typeLOAD
    case 'load'
        [filename,~] = uigetfile( ...
            {'*.mat','MAT-files (*.mat)'; ...
            '*.*',  'All Files (*.*)'}, ...
            getWavMSG('Wavelet:divGUIRF:Pick_a_file'), 'Untitled.mat'); 
        ok = ~isequal(filename,0);
        if ~ok, return; end
        err = 0;
        try
            Data = whos('-file',filename);
            nbData = length(Data);
            Okdata = false(1,nbData);
            idxVar = 0;
            for k = 1:nbData
                DS = Data(k).size;
                nbdim = length(DS);
                if nbdim>2
                    nbdim = nbdim-length(find(DS==1));
                    if nbdim==3
                        Okdata(k) = 1;
                        idxVar = k; 
                    end
                end
                if Okdata(k) , NameVar = Data(k).name; break; end
            end
            if idxVar>0
                S = load(filename);
            else
                err = 1;
            end
        catch 
            err = 1;
        end
        
        if ~err && isfield(S,NameVar)
            X = S.(NameVar);
            X = squeeze(X);
            if min(size(X))<5 , err = 1; end
        else
            err = 1;
        end
        if err
            uiwait(warndlg(getWavMSG('Wavelet:divGUIRF:Invalid_3D'), ...
                getWavMSG('Wavelet:divGUIRF:Load_3D'),'modal'))
            return;
        end
        
        [~,Data_Name] = fileparts(filename);
        
    case 'import'
        [dataInfos,X,ok] = wtbximport('3d');
        if ~ok, return; end
        Data_Name = dataInfos.name;

    case 'demo'
        filename = varargin{2};
        level = varargin{3};
        cbanapar('set',hFig,'lev',level);
        S  = load(filename);
        fn = fieldnames(S);
        if isfield(S,'X') , X = S.('X'); else X = S.(fn{1}); end
        [~,Data_Name] = fileparts(filename);
        X = squeeze(X);
end
sX = size(X);

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitClean'));

% Clean Axes.
%------------
HDL_Axes = [...
    handles.Axe_ORI;handles.Axe_APP;handles.Axe_DET; ...
    handles.Axe_AAA;handles.Axe_AAD; ...
    handles.Axe_DDD;handles.Axe_DAD;handles.Axe_ADD; ...
    handles.Axe_DDA;handles.Axe_DAA;handles.Axe_ADA];
Children = allchild(HDL_Axes);
delete(cat(1,Children{:}));

% Clean UIC.
%------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_data = hdl_Menus.m_exp_data;
Hdl_to_Disable = [...
    m_save,m_exp_data, ... 
    handles.Txt_Slice_ORIENT,handles.Pop_Slice_ORIENT,...
    handles.Txt_SLICE_Rec,handles.Sli_SLICE_Rec,handles.Edi_SLICE_Rec, ...
    handles.Txt_SLICE_Cfs,handles.Sli_SLICE_Cfs,handles.Edi_SLICE_Cfs,...
    handles.Pus_SLICE_MOV, ...
    handles.Pop_LEV_DISP,handles.Txt_LEV_DISP, ...
    handles.Txt_3D_DISP,handles.Pop_3D_DISP ...
    ];
Hdl_to_Enable = [handles.Pus_Decompose,];
set([Hdl_to_Disable,Hdl_to_Enable],'Enable','Off');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlev(min(sX),'haar');
levmax = min(levm,max_lev_anal);
curlev = cbanapar('get',hFig,'lev');
cbanapar('set',hFig, ...
    'lev',{'String',int2str((1:levmax)'),'Value',min(levmax,curlev)} ...
    );
wtbxappdata('set',hFig,'ORI_Data',X,'SizeOfData',sX,'Slice_ORIENT','Z');

n_s = [Data_Name '  (' , int2str(sX(2)) 'x' int2str(sX(1)) ...
    'x' int2str(sX(3)) ')'];
set(handles.Edi_Data_NS,'String',n_s);

% Display the original data.
%---------------------------
Axe_ORI = handles.Axe_ORI;
dimstr = ['[' int2str(sX) ']'];
image(X(:,:,1),'Parent',Axe_ORI);
title('Z = 1','Parent',Axe_ORI);
xlabel({getWavMSG('Wavelet:divGUIRF:Final_Title_1'),dimstr},'Parent',Axe_ORI)
dynvtool('init',hFig,[],Axe_ORI,[],[1 1],'','','','int');

% Clean Tool.
%------------
set(Hdl_to_Enable,'Enable','On');
set(handles.Pop_Slice_ORIENT,'Value',3);
set(handles.Pop_3D_DISP,'Value',1);
set(handles.Sli_SLICE_Rec,'Value',0);
wtbxappdata('set',hFig,'Sli_Rec_VAL',0);
set(handles.Edi_SLICE_Rec,'String','1');
set(handles.Sli_SLICE_Cfs,'Value',0);
wtbxappdata('set',hFig,'Sli_Cfs_VAL',0);
set(handles.Edi_SLICE_Cfs,'String','1');

% End waiting.
%-------------
wwaiting('off',hFig);

% Demo case.
%-----------
if isequal(typeLOAD,'demo')
     Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles);
     set(handles.Pop_3D_DISP,'Value',2);
     Pop_3D_DISP_Callback(handles.Pop_3D_DISP,eventdata,handles)
end
%--------------------------------------------------------------------------
function Pus_Decompose_Callback(hObject,eventdata,handles,varargin) 

hFig = handles.output;
nbIN = length(varargin);
if nbIN<1 , X = wtbxappdata('get',hFig,'ORI_Data'); end

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Decomposition.
%---------------
[wname,level] = cbanapar('get',hFig,'wav','lev');
wname_Y = getWname(handles.Pop_Wav_Fam_Y,handles.Pop_Wav_Num_Y);
wname_Z = getWname(handles.Pop_Wav_Fam_Z,handles.Pop_Wav_Num_Z);
Pop_ExtM  = handles.Pop_ExtM;
lst = get(Pop_ExtM,'String');
extMode = lst{get(Pop_ExtM,'Value')};
wdec = wavedec3(X,level,{wname,wname_Y,wname_Z},'mode',extMode);
wtbxappdata('set',hFig,'wdec',wdec);

% Clean Tool.
%------------
StrPOP = int2str((1:level)');
set(handles.Pop_LEV_DISP,'String',StrPOP,'Value',level)
levDISP = level;
sizeDEC = wdec.sizes;
nbSliceREC = sizeDEC(end,3);
nbSliceCFS = sizeDEC(end-levDISP,3);
set(handles.Txt_SLICE_Rec,'String', ...
    getWavMSG('Wavelet:divGUIRF:Txt_SLICE_Rec','Z',nbSliceREC));
set(handles.Sli_SLICE_Rec,'Value',0,'UserData',sizeDEC);
wtbxappdata('set',hFig,'Sli_Rec_VAL',0);
set(handles.Edi_SLICE_Rec,'UserData',sizeDEC);
set(handles.Txt_SLICE_Cfs,'String', ...
    getWavMSG('Wavelet:divGUIRF:Txt_SLICE_Cfs','Z',nbSliceCFS));
set(handles.Sli_SLICE_Cfs,'Value',0,'UserData',sizeDEC);
wtbxappdata('set',hFig,'Sli_Cfs_VAL',0);
LstPOP = cell(1,2*level + 4);
LstPOP(1) = {getWavMSG('Wavelet:commongui:Str_None');};
LstPOP(2) = {getWavMSG('Wavelet:divGUIRF:Final_Title_1');};
LstPOP(3) = {'----------'};
idx = 3;
for j = 1:level
    idx = idx+1;
    levstr = int2str(j);
    LstPOP{idx} = sprintf('APP %s',levstr);
end
idx = idx+1;
LstPOP(idx) = {'----------'};
for j = 1:level
    idx = idx+1;
    LstPOP{idx} = getWavMSG('Wavelet:divGUIRF:DET_from',j);
end
idx = idx+1;
LstPOP(idx) = {'----------'};
for j = 1:level
    idx = idx+1;
    LstPOP{idx} = sprintf('DET %1.0f',j);
end
set(handles.Txt_3D_DISP,'Enable','On');
set(handles.Pop_3D_DISP,'String',LstPOP,'Value',1,'UserData',1);

% Compute Decomposition Components.
%----------------------------------
Compute_Dec_Components(handles)

% Display Analysis.
%------------------
Display_Analysis(handles);
Add_OR_Del_SaveAPPMenu(hFig,level)

% End waiting.
%-------------
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
m_save = hdl_Menus.m_save;
m_exp_data = hdl_Menus.m_exp_data;
Hdl_to_Enable = [handles.Pus_Decompose,m_save,m_exp_data,...
    handles.Txt_Slice_ORIENT,handles.Pop_Slice_ORIENT,...
    handles.Txt_SLICE_Rec,handles.Sli_SLICE_Rec,handles.Edi_SLICE_Rec, ...
    handles.Txt_SLICE_Cfs,handles.Sli_SLICE_Cfs,handles.Edi_SLICE_Cfs,...
    handles.Pus_SLICE_MOV, ...
    handles.Pop_LEV_DISP,handles.Txt_LEV_DISP, ...
    handles.Txt_3D_DISP,handles.Pop_3D_DISP ...
    ];
set(Hdl_to_Enable,'Enable','On');

wwaiting('off',hFig);
%-------------------------------------------------------------------------
function Pus_SLICE_MOV_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;

m_File = wfindobj(hFig,'type','uimenu','tag','figMenuFile');
btn_Close = handles.Pus_CloseWin;
set([m_File,btn_Close],'Enable','Off');

% Wwaiting.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

tmp = get(handles.Pop_Slice_ORIENT,{'Value','String'});
orient = tmp{2}{tmp{1}};
switch orient
    case 'X' , perm = [3 2 1];
    case 'Y' , perm = [3 1 2];
    case 'Z' , perm = [1 2 3];
end
idxSize = perm(3);

X = wtbxappdata('get',hFig,'ORI_Data');
typeCompo = {'AAA','AAD','ADA','ADD','DAA','DAD','DDA','DDD'};
level = get(handles.Pop_LEV_DISP,'Value');
L = wtbxappdata('get',hFig,'LowComp');
H = wtbxappdata('get',hFig,'HighComp');
sX = size(X); dimstrX = ['[' int2str(sX) ']'];
sL = size(L); dimstrL = ['[' int2str(sL) ']'];
sH = size(H); dimstrH = ['[' int2str(sH) ']'];
X = permute(X,perm);
L = permute(L,perm);
H = permute(H,perm);

Y = cell(1,8);
sY = zeros(8,3);
for k = 1:8
    type = typeCompo{k};
    Y{k} = wtbxappdata('get',hFig,[type 'Comp']);
    sY(k,:) = size(Y{k});
    Y{k} = permute(Y{k},perm);
end

Axe_ORI = handles.Axe_ORI;
Axe_APP = handles.('Axe_APP');
Axe_DET = handles.('Axe_DET');
axe_IND = zeros(1,8);
for k = 1:8
    type = typeCompo{k};
    axe_IND(k) = handles.(['Axe_' type]);
end
for j = 1:sX(idxSize)
    orientSTR = [orient ' = ' int2str(j)];
    set(handles.Edi_SLICE_Rec,'String',int2str(j),'UserData',j);
    slide_Val = (j-1)/(sX(idxSize)-1);
    set(handles.Sli_SLICE_Rec,'Value',slide_Val);
    wtbxappdata('set',hFig,'Sli_Rec_VAL',slide_Val);
    image(X(:,:,j),'Parent',Axe_ORI);
    xlabel({getWavMSG('Wavelet:divGUIRF:Final_Title_1'),dimstrX},'Parent',Axe_ORI)
    title(orientSTR,'Parent',Axe_ORI);
    pause(0.01)
    imagesc(L(:,:,j),'Parent',Axe_APP);
    xlabel({getWavMSG('Wavelet:divGUIRF:Xlab_3D_APP',level),dimstrL},'Parent',Axe_APP)
    title(orientSTR,'Parent',Axe_APP);
    imagesc(abs(H(:,:,j)),'Parent',Axe_DET);
    xlabel({getWavMSG('Wavelet:divGUIRF:Xlab_3D_DET',level),dimstrH},'Parent',Axe_DET)
    title(orientSTR,'Parent',Axe_DET);
    pause(0.01)
end
for j = 1:sY(1,idxSize)
    set(handles.Edi_SLICE_Cfs,'String',int2str(j),'UserData',j);
    slide_Val = (j-1)/(sY(1,idxSize)-1);
    set(handles.Sli_SLICE_Cfs,'Value',slide_Val);
    orientSTR = [orient ' = ' int2str(j)];
    for k = 1:8
        type = typeCompo{k};
        dimstr = ['[' int2str(sY(k,:)) ']'];
        imagesc(abs(Y{k}(:,:,j)),'Parent',axe_IND(k));
        str1 = getWavMSG('Wavelet:divGUIRF:Xlab_3D_CFS',type,level);
        xlabel({str1,dimstr},'Parent',axe_IND(k))
        if isodd(k)
            title(orientSTR,'Parent',axe_IND(k))
            pause(0.05)
        end
    end
end

% Show Decompositions.
%---------------------
axe_CMD = [handles.('Axe_ORI'),handles.('Axe_APP'),handles.('Axe_DET')];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
set([m_File,btn_Close],'Enable','On');
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function Pop_3D_DISP_Callback(hObject,eventdata,handles)

hFig = handles.output;

v = get(hObject,'Value')-1;
if v==0; return; end

% Cleaning.
%----------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

u = get(hObject,'UserData');
levDEC = get(handles.Pop_Lev,'Value');

if v==1 
    type = 'A'; lev = 0;
     Final_Title = getWavMSG('Wavelet:divGUIRF:Final_Title_1');
elseif v==2
    set(hObject,'Value',u); 
    wwaiting('off',hFig); return    
elseif 2<v && v<=2+levDEC
     type = 'A'; lev = v-2;
     Final_Title = getWavMSG('Wavelet:divGUIRF:Final_Title_2',lev);
elseif v == 3+levDEC
    set(hObject,'Value',u); 
    wwaiting('off',hFig); return
elseif 3+levDEC<v && v<=3+2*levDEC % Components at all levels different from AAA 
    type = 'D'; lev = v-3-levDEC;
    Final_Title = getWavMSG('Wavelet:divGUIRF:Final_Title_3',lev);
elseif v==4+2*levDEC
    set(hObject,'Value',u); 
    wwaiting('off',hFig); return
elseif 4+2*levDEC<v   % Components at the same level different from AAA
    type = 'S'; lev = v-4-2*levDEC;
    Final_Title = getWavMSG('Wavelet:divGUIRF:Final_Title_4',lev);
end

fig = open('disp3dwin.fig');
fig_Handles = guihandles(fig);
% Remove insert menu
allHandles = findall(fig);
InsertMenu = findobj(allHandles,'tag','figMenuInsert');
delete(InsertMenu);
Sli_E = fig_Handles.Sli_E;
Sli_A = fig_Handles.Sli_A;
Edi_E = fig_Handles.Edi_EL;
Edi_A = fig_Handles.Edi_AZ;
set(fig,'Name',getWavMSG('Wavelet:divGUIRF:Disp3D_Name'));
uic = wfindobj(fig,'type','uicontrol');
tag = get(uic,'tag');
idx = strcmp(tag,'Txt_AZI');
set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Azimuth'));
idx = strcmp(tag,'text8');
set(uic(idx),'String',getWavMSG('Wavelet:divGUIRF:Elevation'));
idx = strcmp(tag,'Pus_CloseWin');
set(uic(idx),'String',getWavMSG('Wavelet:commongui:Str_Close'));

try
    wfigmngr('modify_FigChild',hFig,fig)
    wdec = wtbxappdata('get',hFig,'wdec');
    map = pink(255);
    
    switch type
        case {'A','D'} 
            XR = waverec3(wdec,type,lev);
            if any(type=='D') , XR = abs(XR); end
        case 'S'
            XR = waverec3(wdec,'A',lev-1) - waverec3(wdec,'A',lev);
            XR = abs(XR);
    end
    colormap(map)
%     sD = size(XR);
%     Cvals = round(linspace(1,sD(3),6));
%     try
%         phandles = contourslice(XR,[],[],Cvals,8);
%         SetView(gca,Sli_A,Sli_E,Edi_A,Edi_E,-37.5,30); axis tight;
%         set(phandles,'LineWidth',2)
%         title(sprintf('Wait Computing ... %s','1'))
%         pause(0.05)
%     catch %#ok<*CTCH>
%         wwaiting('off',hFig);
%     end
    try
        Ds = smooth3(XR);
        hiso = patch(isosurface(Ds,5),'FaceColor',[1,.75,.65], ...
            'EdgeColor','none');
        title(getWavMSG('Wavelet:commongui:WaitCompute'))
        pause(0.05)
    catch %#ok<*CTCH>
        Finish_3D_DISP(hFig,hObject);
    end
    
    try
        hcap = patch(isocaps(XR,5),'FaceColor','interp','EdgeColor','none');
        colormap(map)
        title(getWavMSG('Wavelet:commongui:WaitCompute'))
        pause(1)
        SetView(gca,Sli_A,Sli_E,Edi_A,Edi_E,45.5,30); axis tight;
        daspect([1,1,.4])
        title(getWavMSG('Wavelet:commongui:WaitCompute'))
        pause(0.05)
    catch
        Finish_3D_DISP(hFig,hObject);
    end
    
    try
        % Add Lighting
        lightangle(305,30);
        set(gcf,'Renderer','zbuffer'); lighting phong
        isonormals(Ds,hiso)
        set(hcap,'AmbientStrength',.6)
        set(hiso,'SpecularColorReflectance',0,'SpecularExponent',50)
        SetView(gca,Sli_A,Sli_E,Edi_A,Edi_E,215,30); axis tight;
        title(getWavMSG('Wavelet:commongui:WaitCompute'))
        pause(0.05)
        box on
    catch
        Finish_3D_DISP(hFig,hObject);
    end
    
    a = gca;
    v = get(a,'View');
    title(getWavMSG('Wavelet:commongui:WaitCompute'))
    for k = 1:2:20
        try
            SetView(a,Sli_A,Sli_E,Edi_A,Edi_E,v(1)+k,v(2)+k);
            axis tight;
            pause(0.1);
        catch
            Finish_3D_DISP(hFig,hObject);
        end
    end
    title(Final_Title)
catch
    Finish_3D_DISP(hFig,hObject);
end
Finish_3D_DISP(hFig,hObject);
%-------------------------------------------------------------------------
function Finish_3D_DISP(hFig,hObject)

% Reset the Popup to "None"
set(hObject,'Value',1);
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function SetView(Axe,Sli_A,Sli_E,Edi_A,Edi_E,ValA,ValE)

if ValE>180 , ValE = ValE-360; elseif ValE<-180 , ValE = ValE+360; end
if ValA>180 , ValA = ValA-360; elseif ValA<-180 , ValA = ValA+360; end
set(Sli_A,'Value',ValA);
set(Sli_E,'Value',ValE);
set(Edi_A,'String',sprintf('%5.1f',ValA));
set(Edi_E,'String',sprintf('%5.1f',ValE));
set(Axe,'View',[ValA,ValE]);
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%
function demo_FUN(hObject,eventdata,handles,numDEM) %#ok<DEFNU>

switch numDEM
    case 1 , filename = 'wmri.mat';         level = 2;
    case 2 , filename = 'holeinsphere.mat'; level = 2;
    case 3 , filename = 'column.mat';       level = 3;
    case 4 , filename = 'movemask.mat';     level = 2;
    case 5 , filename = 'movecrt128.mat';   level = 3;       
    case 6 , filename = 'knee.mat';         level = 4;      
end
Load_Data_Callback(hObject,eventdata,handles,'demo',filename,level)
%-------------------------------------------------------------------------
function save_FUN(hObject,eventdata,handles,lastarg) 

% Get figure handle.
%-------------------
hFig = handles.output;

% Get Data to save.
%------------------
switch lastarg
    case 'dec'
        strTIT = getWavMSG('Wavelet:divGUIRF:III_D_SaveDEC');
        SaveStr = {'wdec'};
        
    case 'app'
        strTIT = getWavMSG('Wavelet:divGUIRF:III_D_SaveAPP');
        levToSave = get(hObject,'Position');
        SaveStr = {'X'};
end

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig,'*.mat',strTIT);
if ~ok, return; end

% Begin waiting.
%--------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitSave'));

% Getting Data to Save.
%---------------------
wdec = wtbxappdata('get',hFig,'wdec'); 
if isequal(lastarg,'app')
    X = waverec3(wdec,'A',levToSave); %#ok<NASGU>
end

% Saving file.
%--------------
[name,ext] = strtok(filename,'.');
if isempty(ext) || isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

try
    save([pathname filename],SaveStr{:});
catch ME %#ok<NASGU>
    errargt(mfilename,getWavMSG('Wavelet:commongui:SaveFail'),'msg');
end
wwaiting('off',hFig);
%-------------------------------------------------------------------------%
function Export_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitExport'));

dec_3D = wtbxappdata('get',hFig,'wdec');  
wtbxexport(dec_3D,'name','dec_3D', ...
    'title',getWavMSG('Wavelet:commongui:Str_Decomp'));

wwaiting('off',hFig);
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%



%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles) 

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
default_nbcolors = 255;
cbcolmap('set',hObject,'pal',{'pink',default_nbcolors})
%-------------------------------------------------------------------------
% TOOL INITIALIZATION
%-------------------------------------------------------------------------
% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(hObject,handles);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);
%------------------------------------------------
set(hObject,'DefaultAxesXTick',[],'DefaultAxesYTick',[])
%-------------------------------------------------------------

% Keep Slice Movie enabled during DYNV Zoom.
%-------------------------------------------
wtbxappdata('set',hObject,'Keep_DynV_Enabled',handles.Pus_SLICE_MOV);

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
cb_close = @(o,~)dw3dtool('Pus_CloseWin_Callback',o,[],guidata(o));
set(m_close,'Callback',cb_close);

m_Load_Data = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Load_Data'), ...
    'Position',1,'Enable','On',  ...
    'Callback',                ...
    @(o,~)dw3dtool('Load_Data_Callback',o,[],guidata(o),'load')  ...
    );
m_save = uimenu(m_files,...
    'Label',getWavMSG('Wavelet:commongui:Str_Save'),'Position',2, 'Enable','Off'  ...
    );
uimenu(m_save,...
    'Label',getWavMSG('Wavelet:dw2dRF:Lab_Decomposition'), ...
    'Position',1, 'Enable','On',  ...
    'Callback',@(o,~)dw3dtool('save_FUN',o,[],guidata(o),'dec') ...
    );
Men_Save_APP = uimenu(m_save,...
    'Label',getWavMSG('Wavelet:commongui:Approximations'), ...
    'Position',2, 'Enable','On',  ...
    'Tag','Men_Save_APP' ...
    );
uimenu(Men_Save_APP,...
    'Label',getWavMSG('Wavelet:dw2dRF:AppLevX',1), ...
    'Position',1,             ...
    'Callback',@(o,~)dw3dtool('save_FUN',o,[],guidata(o),'app') ...
    );
m_demo = uimenu(m_files,'Label',getWavMSG('Wavelet:divGUIRF:Example_Anal'),...
    'Position',3,'Separator','Off','Tag','Examples');
uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:commongui:Import_Data'), ...
    'Position',4,'Enable','On' ,'Separator','On','Tag','Import',  ...
    'Callback',                ...
    @(o,~)dw3dtool('Load_Data_Callback',o,[],guidata(o),'import')  ...
    );
m_exp_data = uimenu(m_files, ...
    'Label',getWavMSG('Wavelet:divGUIRF:Lab_ExportDec'),'Position',5, ...
    'Enable','Off','Separator','Off','Tag','Export',...
    'Callback',@(o,~)dw3dtool('Export_Callback',o,[],guidata(o))  ...
    );
demoPar = {...
    getWavMSG('Wavelet:divGUIRF:DW3D_Ex1'),'db1',2; ...
    getWavMSG('Wavelet:divGUIRF:DW3D_Ex2'),'db1',2; ...
    getWavMSG('Wavelet:divGUIRF:DW3D_Ex3'),'db1',3; ...
    getWavMSG('Wavelet:divGUIRF:DW3D_Ex4'),'db1',2; ...
    getWavMSG('Wavelet:divGUIRF:DW3D_Ex5'),'db1',3; ...
    getWavMSG('Wavelet:divGUIRF:DW3D_Ex6'),'db1',4  ...    
    };
nbDEM = size(demoPar,1);
for k = 1:nbDEM
    action = @(o,~)dw3dtool('demo_FUN',o,[],guidata(o),k);
    demoSET = getWavMSG('Wavelet:divGUIRF:Example_3D',demoPar{k,1:3});
    uimenu(m_demo,'Label',demoSET,'Callback',action);
end
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_Load_Data',m_Load_Data,...
    'm_save',m_save,'m_demo',m_demo,'m_exp_data',m_exp_data);

% Add Help for Tool.
%------------------

%-------------------------------------------------------------------------
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%
%-------------------------------------------------------------------------
function Pop_ExtM_Callback(hObject, eventdata, handles) %#ok<DEFNU>

%-------------------------------------------------------------------------
function Pop_Wav_Num_Y_Callback(hObject, eventdata, handles) %#ok<DEFNU>

Pop_Wav_Fam = handles.Pop_Wav_Fam_Y;
Pop_Wav_Num = handles.Pop_Wav_Num_Y;
cbanapar('cba_num',gcbf,[Pop_Wav_Fam Pop_Wav_Num])
%-------------------------------------------------------------------------
function Pop_Wav_Fam_Y_Callback(hObject,eventdata,handles) %#ok<*INUSL,DEFNU>

Pop_Wav_Fam = handles.Pop_Wav_Fam_Y;
Pop_Wav_Num = handles.Pop_Wav_Num_Y;
cbanapar('cba_fam',gcbf,[Pop_Wav_Fam Pop_Wav_Num])
%-------------------------------------------------------------------------
function Pop_Wav_Num_Z_Callback(hObject,eventdata,handles) %#ok<*INUSD,DEFNU>

Pop_Wav_Fam = handles.Pop_Wav_Fam_Z;
Pop_Wav_Num = handles.Pop_Wav_Num_Z;
cbanapar('cba_num',gcbf,[Pop_Wav_Fam Pop_Wav_Num])
%-------------------------------------------------------------------------
function Pop_Wav_Fam_Z_Callback(hObject,eventdata,handles) %#ok<DEFNU>

Pop_Wav_Fam = handles.Pop_Wav_Fam_Z;
Pop_Wav_Num = handles.Pop_Wav_Num_Z;
cbanapar('cba_fam',gcbf,[Pop_Wav_Fam Pop_Wav_Num])
%-------------------------------------------------------------------------
function Pop_LEV_DISP_Callback(hObject,eventdata,handles) %#ok<DEFNU>

% Begin waiting.
%--------------
hFig = handles.output;
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));

% Compute Decomposition Components.
%----------------------------------
Compute_Dec_Components(handles)

% Display Analysis.
%------------------
Display_Analysis(handles)

% End waiting.
%-------------
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function Display_Analysis(handles)

hFig = handles.output;

% Begin waiting.
%--------------
wwaiting('msg',hFig,getWavMSG('Wavelet:commongui:WaitCompute'));
sliceVAL = 1;

level = get(handles.Pop_LEV_DISP,'Value');
tmp = get(handles.Pop_Slice_ORIENT,{'Value','String'});
orient = tmp{2}{tmp{1}};
switch orient
    case 'X' , perm = [3 2 1];
    case 'Y' , perm = [3 1 2];
    case 'Z' , perm = [1 2 3];
end
idxSize = perm(3);
orientSTR = [orient ' = ' int2str(sliceVAL)];

wdec  = wtbxappdata('get',hFig,'wdec');
sizeDEC = wdec.sizes;
levDISP = get(handles.Pop_LEV_DISP,'Value');
nbSliceREC = sizeDEC(end,idxSize);
nbSliceCFS = sizeDEC(end-levDISP,idxSize);
set(handles.Txt_SLICE_Rec,'String', ...
    getWavMSG('Wavelet:divGUIRF:Txt_SLICE_Rec',orient,nbSliceREC));
set(handles.Sli_SLICE_Rec,'Value',0,'UserData',sizeDEC);
wtbxappdata('set',hFig,'Sli_Rec_VAL',0);
set(handles.Edi_SLICE_Rec,'String',int2str(sliceVAL),'UserData',sliceVAL);
set(handles.Txt_SLICE_Cfs,'String', ...
    getWavMSG('Wavelet:divGUIRF:Txt_SLICE_Cfs',orient,nbSliceCFS));
set(handles.Sli_SLICE_Cfs,'Value',0,'UserData',sizeDEC);
wtbxappdata('set',hFig,'Sli_Cfs_VAL',0);
set(handles.Edi_SLICE_Cfs,'String',int2str(sliceVAL),'UserData',sliceVAL);

X = wtbxappdata('get',hFig,'ORI_Data');
sX = size(X); dimstr = ['[' int2str(sX) ']'];
X = permORIENT(X,perm);
Axe_ORI = handles.('Axe_ORI');
imagesc(X(:,:,sliceVAL),'Parent',Axe_ORI);
xlabel({getWavMSG('Wavelet:divGUIRF:Final_Title_1'),dimstr},'Parent',Axe_ORI)
title(orientSTR,'Parent',Axe_ORI);

Y = wtbxappdata('get',hFig,'LowComp');
sY = size(Y); dimstr = ['[' int2str(sY) ']'];
Y = permORIENT(Y,perm);
Axe_APP = handles.('Axe_APP');
imagesc(Y(:,:,sliceVAL),'Parent',Axe_APP);
xlabel({getWavMSG('Wavelet:divGUIRF:Xlab_3D_APP',level),dimstr},'Parent',Axe_APP)
title(orientSTR,'Parent',Axe_APP);

Y = wtbxappdata('get',hFig,'HighComp');
sY = size(Y); dimstr = ['[' int2str(sY) ']'];
Y = permORIENT(Y,perm);
Axe_DET = handles.('Axe_DET');
imagesc(abs(Y(:,:,sliceVAL)),'Parent',Axe_DET);
xlabel({getWavMSG('Wavelet:divGUIRF:Xlab_3D_DET',level),dimstr},'Parent',Axe_DET)
title(orientSTR,'Parent',Axe_DET);

typeCompo = {'AAA','AAD','ADA','ADD','DAA','DAD','DDA','DDD'};
axe_IND = zeros(1,8);
for k = 1:8
    type = typeCompo{k};
    Y = wtbxappdata('get',hFig,[type 'Comp']);
    sY = size(Y); dimstr = ['[' int2str(sY) ']'];
    Y = permORIENT(Y,perm);
    axe_IND(k) = handles.(['Axe_' type]);
    imagesc(abs(Y(:,:,sliceVAL)),'Parent',axe_IND(k));
    str1 = getWavMSG('Wavelet:divGUIRF:Xlab_3D_CFS',type,level);
    xlabel({str1,dimstr},'Parent',axe_IND(k))
    if isodd(k)
        title(orientSTR,'Parent',axe_IND(k));
    end
end

% Show Decompositions.
%---------------------
axe_CMD = [handles.('Axe_ORI'),handles.('Axe_APP'),handles.('Axe_DET')];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
wwaiting('off',hFig);
%-------------------------------------------------------------------------
function SLICE_Rec_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
type_Call = get(hObject,'Style');
type_Call = lower(type_Call(1:3));
tmp = get(handles.Pop_Slice_ORIENT,{'Value','String'});
orient = tmp{2}{tmp{1}};
switch orient
    case 'X' , perm = [3 2 1];
    case 'Y' , perm = [3 1 2];
    case 'Z' , perm = [1 2 3];
end
idxSize = perm(3);
sX = wtbxappdata('get',hFig,'SizeOfData');
old_Slide_VAL = wtbxappdata('get',hFig,'Sli_Rec_VAL');
max_Slice_VAL = sX(idxSize);
switch type_Call
    case 'sli'
        cur_slide_Val = get(hObject,'Value');
        delta = cur_slide_Val-old_Slide_VAL;
        if delta>0
            sliceVAL = ceil(cur_slide_Val*(max_Slice_VAL-1)+1);
        elseif delta<0
            sliceVAL = floor(cur_slide_Val*(max_Slice_VAL-1)+1);
        else
            return;
        end
        cur_slide_Val = (sliceVAL-1)/(max_Slice_VAL-1);
        ok = true;
        
    case 'edi'
        val = str2double(get(hObject,'String'));
        if ~isnan(val)
            val = round(val);
            ok = (1<=val) && (val<=max_Slice_VAL);
        else
            ok = false;
        end
        if ok
            set(hObject,'String',int2str(val),'UserData',val)
            cur_slide_Val = (val-1)/(max_Slice_VAL-1);
            sliceVAL = val;
        else
            val = get(hObject,'UserData');
            set(hObject,'String',int2str(val))
        end        
end
if ~ok , return; end
set(handles.Sli_SLICE_Rec,'Value',cur_slide_Val);
wtbxappdata('set',hFig,'Sli_Rec_VAL',cur_slide_Val);
set(handles.Edi_SLICE_Rec,'String',int2str(sliceVAL),'UserData',sliceVAL);

X = wtbxappdata('get',hFig,'ORI_Data');
L = wtbxappdata('get',hFig,'LowComp');
H = wtbxappdata('get',hFig,'HighComp');
sX = size(X); dimstrX = ['[' int2str(sX) ']'];
sL = size(L); dimstrL = ['[' int2str(sL) ']'];
sH = size(H); dimstrH = ['[' int2str(sH) ']'];

X = permORIENT(X,perm);
L = permORIENT(L,perm);
H = permORIENT(H,perm);
level = get(handles.Pop_LEV_DISP,'Value');
orientSTR = [orient ' = ' int2str(sliceVAL)];

Axe_ORI = handles.Axe_ORI;
image(X(:,:,sliceVAL),'Parent',Axe_ORI);
xlabel({getWavMSG('Wavelet:divGUIRF:Final_Title_1'),dimstrX},'Parent',Axe_ORI)
title(orientSTR,'Parent',Axe_ORI);
pause(0.01)
Axe_APP = handles.('Axe_APP');
imagesc(L(:,:,sliceVAL),'Parent',Axe_APP);
xlabel({getWavMSG('Wavelet:divGUIRF:Xlab_3D_APP',level),dimstrL},'Parent',Axe_APP)
title(orientSTR,'Parent',Axe_APP);
Axe_DET = handles.('Axe_DET');
imagesc(abs(H(:,:,sliceVAL)),'Parent',Axe_DET);
xlabel({getWavMSG('Wavelet:divGUIRF:Xlab_3D_DET',level),dimstrH},'Parent',Axe_DET)
title(orientSTR,'Parent',Axe_DET);
pause(0.01)

% Show Decompositions.
%---------------------
typeCompo = {'AAA','AAD','ADA','ADD','DAA','DAD','DDA','DDD'};
axe_IND = zeros(1,8);
for k = 1:8
    type = typeCompo{k};
    axe_IND(k) = handles.(['Axe_' type]);
end
axe_CMD = [handles.('Axe_ORI'),handles.('Axe_APP'),handles.('Axe_DET')];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');
%-------------------------------------------------------------------------
function SLICE_Cfs_Callback(hObject,eventdata,handles) %#ok<DEFNU>

hFig = handles.output;
type_Call = get(hObject,'Style');
type_Call = lower(type_Call(1:3));
tmp = get(handles.Pop_Slice_ORIENT,{'Value','String'});
orient = tmp{2}{tmp{1}};
switch orient
    case 'X' , perm = [3 2 1];
    case 'Y' , perm = [3 1 2];
    case 'Z' , perm = [1 2 3];
end
Y = wtbxappdata('get',hFig,'AAAComp');
sY = size(Y); 
idxSize = perm(3);
level = get(handles.Pop_LEV_DISP,'Value');
old_Slide_VAL = wtbxappdata('get',hFig,'Sli_Cfs_VAL');
max_Slice_VAL = sY(idxSize);
switch type_Call
    case 'sli'
        cur_slide_Val = get(hObject,'Value');
        delta = cur_slide_Val-old_Slide_VAL;
        if delta>0
            sliceVAL = ceil(cur_slide_Val*(max_Slice_VAL-1)+1);
        elseif delta<0
            sliceVAL = floor(cur_slide_Val*(max_Slice_VAL-1)+1);
        else
            return;
        end
        cur_slide_Val = (sliceVAL-1)/(max_Slice_VAL-1);
        ok = true;
        
    case 'edi'
        val = str2double(get(hObject,'String'));
        tmp = get(handles.Sli_SLICE_Cfs,{'Value','UserData'});
        if ~isnan(val)
            val = round(val);
            nbSlice = tmp{2}(end-level,idxSize);
            ok = (1<=val) && (val<=nbSlice);
        else
            ok = false;
        end
        if ok
            set(hObject,'String',int2str(val),'UserData',val)
            cur_slide_Val = (val-1)/(nbSlice-1);
            sliceVAL = val;
        else
            val = get(hObject,'UserData');
            set(hObject,'String',int2str(val))
        end        
end
if ~ok , return; end
set(handles.Sli_SLICE_Cfs,'Value',cur_slide_Val);
wtbxappdata('set',hFig,'Sli_Cfs_VAL',cur_slide_Val);
set(handles.Edi_SLICE_Cfs,'String',int2str(sliceVAL),'UserData',sliceVAL);

orientSTR = [orient ' = ' int2str(sliceVAL)];
dimstr = ['[' int2str(sY) ']'];
typeCompo = {'AAA','AAD','ADA','ADD','DAA','DAD','DDA','DDD'};
axe_IND = zeros(1,8);
for k = 1:8
    type = typeCompo{k};
    Y = wtbxappdata('get',hFig,[type 'Comp']);
    Y = permORIENT(Y,perm);
    axe_IND(k) = handles.(['Axe_' type]);
    imagesc(abs(Y(:,:,sliceVAL)),'Parent',axe_IND(k));
    str1 = getWavMSG('Wavelet:divGUIRF:Xlab_3D_CFS',type,level);
    xlabel({str1,dimstr},'Parent',axe_IND(k))
    if isodd(k)
        title(orientSTR,'Parent',axe_IND(k));
    end
    pause(0.01)
end

% Show Decompositions.
%---------------------
axe_CMD = [handles.('Axe_ORI'),handles.('Axe_APP'),handles.('Axe_DET')];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');
%-------------------------------------------------------------------------
function Pop_Slice_ORIENT_Callback(hObject,eventdata,handles) %#ok<DEFNU>

Display_Analysis(handles);
%-------------------------------------------------------------------------
function Y = permORIENT(Y,perm)

Y = permute(Y,perm);
%-------------------------------------------------------------------------
function Compute_Dec_Components(handles)

hFig  = handles.output;
wdec  = wtbxappdata('get',hFig,'wdec');
level = get(handles.Pop_LEV_DISP,'Value');
Y = waverec3(wdec,'A',level);
wtbxappdata('set',hFig,'LowComp',Y);
Y = waverec3(wdec,'D',level);
wtbxappdata('set',hFig,'HighComp',Y);
typeCompo = {'AAA','AAD','ADA','ADD','DAA','DAD','DDA','DDD'};
for k = 1:8
    type = typeCompo{k};
    Y = waverec3(wdec,['C' type],level);
    wtbxappdata('set',hFig,[type 'Comp'],Y);
end
%-------------------------------------------------------------------------
function wname = getWname(Pop_Wav_Fam,Pop_Wav_Num)
wf   = get(Pop_Wav_Fam,{'Style','String','Value'});
if isequal(wf{1},'edit')
    fam  = wf{2};
else
    if iscell(wf{2})
        fam  = wf{2}{wf{3}};
    else
        fam  = wf{2}(wf{3},:);
    end
end
fam = deblank(fam);
wf = get(Pop_Wav_Num,{'Style','String','Value'});
if ~isequal(wf{1},'edit')
    strn = wf{2};
    if ~isempty(strn)
        if iscell(strn)
            strn = deblank(strn{wf{3}});
        else
            strn = deblank(strn(wf{3},:));
        end
        if strcmp(strn,'no') , strn = ''; end
    else
        strn = '';
    end
else
    strn = deblank(wf{2});
    if strcmp(strn,'no') , strn = ''; end
end
wname = [fam strn];
%-------------------------------------------------------------------------
function Add_OR_Del_SaveAPPMenu(win_tool,Level_Anal)

% Add or Delete Save APP-Menu
%------------------------------
Men_Save_APP = findobj(win_tool,'Type','uimenu','Tag','Men_Save_APP');
child = get(Men_Save_APP,'Children');
delete(child);

cb_STR = @(o,~)dw3dtool('save_FUN',o,[],guidata(o),'app');
for k = 1:Level_Anal
    labSTR = getWavMSG('Wavelet:commongui:App',k);
    uimenu(Men_Save_APP,'Label',labSTR,'Position',k, ...
        'Callback',cb_STR  ...
        );
end
%-------------------------------------------------------------------------
