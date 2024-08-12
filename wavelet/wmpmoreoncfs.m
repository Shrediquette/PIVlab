function varargout = wmpmoreoncfs(varargin)
%WMPMOREONCFS Matching Pursuit more on coefficients.
%   VARARGOUT = WMPMOREONCFS(VARARGIN)

% Last Modified by GUIDE v2.5 06-Jun-2011 09:12:23
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-May-2011.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2013/07/05 04:30:46 $ 


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wmpmoreoncfs_OpeningFcn, ...
                   'gui_OutputFcn',  @wmpmoreoncfs_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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
% --- Executes just before wmpmoreoncfs is made visible.                  %
%*************************************************************************%
function wmpmoreoncfs_OpeningFcn(hObject,eventdata,handles,varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for wmpmoreoncfs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALIZATION Introduced manually in the automatic generated code %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles,varargin{:});
%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%
function varargout = wmpmoreoncfs_OutputFcn(hObject,eventdata,handles) 
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
%--------------------------------------------------------------------------
function Pus_CloseWin_Callback(hObject,eventdata,handles) %#ok<*DEFNU,*INUSD>

close(gcbf)
%--------------------------------------------------------------------------
%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%
function Init_Tool(hObject,eventdata,handles,varargin) 

% WTBX -- Install DynVTool.
%--------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX -- Initialize GUIDE Figure.
%---------------------------------
wfigmngr('beg_GUIDE_FIG',hObject);

% WTBX MENUS (Install)
%---------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'Enable','On');
default_nbcolors = 128;
cbcolmap('set',hObject,'pal',{'jet',default_nbcolors})

% Setting defaults.
%--------------------------------
Prefs = mextglob('get','WTBX_Preferences');
ax = wfindobj(hObject,'type','axes');
set(ax,'FontUnits','point', ...
    'FontName',Prefs.DefaultAxesFontName,'FontSize',8);
set(ax,'DefaultTextFontUnits','point', ...
    'DefaultTextFontName',Prefs.DefaultTextFontName,...
    'DefaultTextFontSize',8);
set(ax,'GridColor','k')
set(ax,'GridLineStyle',':')

% WTBX -- Terminate GUIDE Figure.
%--------------------------------
wfigmngr('end_GUIDE_FIG',hObject,mfilename);

% Initialize TooltipStrings.
%---------------------------

% Add Context Sensitive Help (CSHelp).
%-------------------------------------

% Initialize Analysis Parameters.
%--------------------------------
caller_Handles = varargin{1};
caller_FIG = caller_Handles.output; 
Axe_SIG = caller_Handles.Axe_SIG;

% Analysis parameters.
lev = 4;
dirDec = 'r';
wname = 'haar';

% Get Components.
lin_COMPO = wtbxappdata('get',caller_FIG,'lin_COMPO');
nbCPT = length(lin_COMPO);
nbCPT = nbCPT-1; % The last is the signal.
TMP = get(lin_COMPO(1),'YData');
nbVAL = length(TMP);
CPT = zeros(nbCPT,nbVAL);
for k = 1:nbCPT , CPT(k,:) = get(lin_COMPO(k),'YData'); end
wtbxappdata('set',hObject,'CPT',CPT);

LstCPT = wtbxappdata('get',caller_FIG,'LstCPT');
set(handles.Pop_FRQ_CPT,'String', [LstCPT,'Signal'],'Value',1)

% Wavelet packets decomposition.
dwtATTR = dwtmode('get');
dwtEXTM = dwtATTR.extMode;
[dec,coefs] = wavelet.internal.mwptdec(dirDec,CPT,lev,wname,dwtEXTM);  %#ok<ASGLU>

% Compute Frequential order
nbPCK = (2^lev);
freqORD_FLAG = true;
if freqORD_FLAG
    frqord = wpfrqord((nbPCK-1:2*nbPCK-1)'); 
    [~,cfsORD] = sort(frqord);
else
    cfsORD = 1:nbPCK; %#ok<*UNRCH>
end

wtbxappdata('set',hObject,'coefs',coefs,'lev',lev,'cfsORD',cfsORD, ...
    'caller_FIG',caller_FIG,'Axe_SIG',Axe_SIG, ...
    'caller_Handles',caller_Handles);
Init_TABLE(caller_Handles,handles)

sigNAM = get(caller_Handles.Edi_Sig_NAM,'String');
set(handles.Edi_Sig_NAM,'String',sigNAM);
set(handles.Pop_SEL_FAM,'String',LstCPT);
plot_SIG_and_APP(caller_FIG,handles)
Pop_Mode_MORE_Callback(hObject,eventdata,handles)
%-------------------------------------------------------------------------
%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%
function hdl_Menus = Install_MENUS(fig)

% Add UIMENUS.
%-------------
m_files  = wfigmngr('getmenus',fig,'file');
m_close  = wfigmngr('getmenus',fig,'close');
cb_close = @(o,~)wmpmoreoncfs('Pus_CloseWin_Callback',o,[],guidata(o));
set(m_close,'Callback',cb_close);

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',fig,getWavMSG('Wavelet:wmp1dRF:MP_ALG'),'WMP_TOOL');

% Menu handles.
%----------------
hdl_Menus = struct('m_files',m_files,'m_close',m_close);
%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%

%--------------------------------------------------------------------------
function Pop_Mode_MORE_Callback(hObject,eventdata,handles) %#ok<*INUSL>

% Initialization of parameters.
[coefs,cfsORD,lev,caller_Handles,caller_FIG,Axe_SIG] = ...
    wtbxappdata('get',hObject,'coefs','cfsORD','lev',...
            'caller_Handles','caller_FIG','Axe_SIG');
local_Fig = handles.output;

% Plot Parameters.
NBC = 192;        % Number of colors in colormap.
LC  = [1 0 1];    % Color of main lines
LC2 = [0 0.7 0];  % Color of main lines
LW  = 2;          % Width of main lines

nbPCK = (2^lev);
sizCFS = size(coefs);
nbCPT = sizCFS(1)/nbPCK;
coefs_INI = coefs;
beg   = 1;
first = 1;
approx_FLAG  = true;
ax_SIG = handles.Axe_SIG_MORE;
ax_CFS = handles.Axe_CFS_MORE;
ax_CPT = handles.Axe_for_CPT;
PlotMODE = get(handles.Pop_Mode_MORE,'Value');
hCB = wfindobj(local_Fig,'type','axes','Tag','Colorbar');
hLEG = wfindobj(local_Fig,'type','axes','Tag','legend');
hSig_ANAL   = wfindobj(caller_FIG,'Type','line','Tag','Sig_ANAL');
lenSIG = length(get(hSig_ANAL,'XData'));
switch PlotMODE
    case {1,2}
        appCur = wtbxappdata('get',local_Fig,'appCur');
        if ishandle(appCur) , delete(appCur); end        
        hOFF = [ax_CPT ; allchild(ax_CPT) ; ...
            handles.uitable_CFS ; handles.Pan_INFO_CFS; handles.Pan_FREQ];
        hON  = [ax_SIG ; allchild(ax_SIG); ax_CFS ; hCB ; hLEG];
        
    case 3
        hOFF = [ax_CFS ; allchild(ax_CFS); hCB ; hLEG ; handles.Pan_FREQ];
        hON  = [ax_SIG ; allchild(ax_SIG); ax_CPT ; ...
            handles.uitable_CFS ; handles.Pan_INFO_CFS];
        
    case 4
        hOFF = [...
            ax_SIG ; allchild(ax_SIG); ...
            ax_CFS ; allchild(ax_CFS); hCB ; hLEG ; ...
            ax_CPT ; allchild(ax_CPT) ; handles.uitable_CFS ; ...
            handles.Pan_INFO_CFS];
        hON = [handles.Pan_FREQ];
end
set(hOFF,'Visible','Off');
set(hON,'Visible','On');

switch PlotMODE
    case {1,'byCPN'}
        while first<sizCFS(1)
            last = first+nbPCK-1;
            TMP = coefs_INI(beg:nbCPT:end,:);
            coefs(first:last,:) = TMP(cfsORD,:);
            coefs(first,:) = 0;
            first = last+1;
            beg = beg+1;
        end
        if approx_FLAG
            beg   = 1;
            first = 1;
            while first<sizCFS(1)
                last = first+nbPCK-1;
                coefs(first,:) = wcodemat(coefs(beg,:),NBC,'mat',0);
                maxi = max(abs(coefs(first,:)));
                coefs(first,:) = coefs(first,:)/(20*maxi);
                first = last+1;
                beg = beg+1;
            end
        end
        
        imagesc(coefs,'Parent',ax_CFS,...
            'Tag','Img_WPCfs','Userdata',[PlotMODE,lenSIG]);
        colormap(jet(NBC));
        set(ax_CFS,'Ydir','Normal','Ytick',[])
        set(ax_CFS,'Xlim',[0.5 sizCFS(2)+0.5],'Ylim',[0.5 sizCFS(1)+0.5])
        xl = get(ax_CFS,'Xlim');
        yl = get(ax_CFS,'Ylim');
        hold on;
        yini = yl(1);
        deltay = (yl(2)-yl(1))/nbCPT;
        for k = 1:nbCPT-1
            ycur = yini+k*deltay;
            line('XData',xl,'YData',[ycur,ycur], ...
                'Linewidth',LW,'Color',LC,'Parent',ax_CFS);
        end
        xtick = get(Axe_SIG,{'XTick','XTickLabel'});
        ytick  = yini + deltay*(0.5:nbCPT);
        set(ax_CFS,'XTick',xtick{1}/nbPCK,'XTickLabel',xtick{2});
        LstCPT = wtbxappdata('get',caller_FIG,'LstCPT');
        set(ax_CFS,'YTick',ytick,'YTickLabel',LstCPT);
        % if lev<5
        %     dy = deltay/nbPCK;
        %     for k = 1:nbCPT
        %         ycur = yini+(k-1)*deltay;
        %         for j = 1:nbPCK-1
        %             ycur = ycur+dy;
        %             line('XData',xl,'YData',[ycur,ycur], ...
        %                 'Linewidth',0.5,'LineStyle',':',...
        %                 'Color',1-[1 1 1],'Parent',ax_CFS);
        %         end
        %     end
        % end
        ylabel('','Parent',ax_CFS)

    case {2,'byPCK'}
        if approx_FLAG
            first = 1;
            last = first+nbCPT-1;
            maxi = max(abs(coefs(:)));
            coefs(first:last,:) = coefs(first:last,:)/maxi;
        end
        imagesc(coefs,'Parent',ax_CFS,...
            'Tag','Img_WPCfs','Userdata',[PlotMODE,lenSIG]);
        colormap(jet(NBC));
        set(ax_CFS,'Ydir','Normal','Ytick',[])
        xl = get(ax_CFS,'Xlim');
        yl = get(ax_CFS,'Ylim');
        hold on;
        yini = yl(1);
        deltay = (yl(2)-yl(1))/nbPCK;
        for k = 1:nbPCK-1
            ycur = yini+k*deltay;
            line('XData',xl,'YData',[ycur,ycur], ...
                'Linewidth',LW,'Color',LC2,'Parent',ax_CFS);
        end
        xtick = get(Axe_SIG,{'XTick','XTickLabel'});
        ytick = yini + deltay*(0.5:nbPCK);
        ytlab = int2str((1:nbPCK)');
        set(ax_CFS,'XTick',xtick{1}/nbPCK,'XTickLabel',xtick{2});
        set(ax_CFS,'YTick',ytick,'YTickLabel',ytlab);
        % if lev<5
        %     dy = deltay/nbCPT;
        %     for k = 1:nbPCK
        %         ycur = yini+(k-1)*deltay;
        %         for j = 1:nbPCK-1
        %             ycur = ycur+dy;
        %             if rem(j,nbCPT)>0
        %                 line('XData',xl,'YData',[ycur,ycur], ...
        %                     'Linewidth',0.5,'LineStyle',':',...
        %                     'Color',1-[1 1 1],'Parent',ax_CFS);
        %             end
        %         end
        %     end
        % end
        ylabel(getWavMSG('Wavelet:wmp1dRF:Lab_IndORPck'),'Parent',ax_CFS)
        
    case {3,'byCFS'}
        plotCFS(caller_Handles,handles)
        
    case 4  % Not Used
        Pop_FRQ_CPT_Callback(handles.Pop_FRQ_CPT,eventdata,handles)
end

switch PlotMODE
    case {1,2}
        set(ax_CFS,'Xlim',[0.5 sizCFS(2)+0.5],'Ylim',[0.5 sizCFS(1)+0.5])
        Add_ColorBar(ax_CFS);
        title(getWavMSG('Wavelet:wmp1dRF:WPACK_anal',lev), ...
            'Parent',ax_CFS);
        set(ax_CFS,'NextPlot','ReplaceChildren');
        dynvtool('init',local_Fig,[], ...
            [ax_SIG,ax_CFS],[],[1 0],'','','wmp1dcoor',ax_CFS);
    case 3
        dynvtool('init',local_Fig,[],[ax_SIG,ax_CPT],[],[0 0],'','','');       
        
    case 4
        dynvtool('init',local_Fig,[],[handles.Axe_FRQ_SIG, ...
            handles.Axe_FRQ_SPEC,handles.Axe_FRQ_PER],[],[0 0],'','','');       
        
end
%--------------------------------------------------------------------------
function hC = Add_ColorBar(hA)

pA = get(hA,'Position');
hC = wfindobj(get(hA,'Parent'),'Tag','Colorbar');
if ishandle(hC) , delete(hC); end
hC = colorbar('peer',hA,'SouthOutside');
set(hA,'Position',pA);
pC = get(hC,'Position');
set(hC,'Position',[pA(1)+pA(3)/3  pA(2)-1.5*pC(4) pC(3)/3 pC(4)/2],...
    'FontSize',8)
ud.dynvzaxe.enable = 'Off';
ud.Parent = hA;
set(hC,'UserData',ud);
%--------------------------------------------------------------------------
function plot_SIG_and_APP(caller_FIG,handles)

axe_SIG_MORE = handles.Axe_SIG_MORE;
hSig_ANAL   = wfindobj(caller_FIG,'Type','line','Tag','Sig_ANAL');
hSig_APPROX = wfindobj(caller_FIG,'Type','line','Tag','Sig_APPROX');
xval = get(hSig_ANAL,'XData');
Sig_ANAL   = get(hSig_ANAL,'YData');
Sig_APPROX = get(hSig_APPROX,'YData');
hL = plot(xval,Sig_ANAL,'r-',xval,Sig_APPROX,'b-',...
    'Parent',axe_SIG_MORE);
tmp = [Sig_ANAL(:);Sig_APPROX(:)]; mini = min(tmp); maxi= max(tmp);
set(axe_SIG_MORE,'Xlim',[1 length(Sig_ANAL)],'Ylim',[mini,maxi])
set(hL(1),'Tag','Sig_ANAL');
set(hL(2),'Tag','Sig_APPROX');
set(hL,'Linewidth',1.5)
axCur = legend(axe_SIG_MORE,...
    getWavMSG('Wavelet:wmp1dRF:Leg_Sig'),...
    getWavMSG('Wavelet:wmp1dRF:Leg_App'),'Location','NorthWest','AutoUpdate','off');
ud = get(axCur,'UserData');
ud.Parent = axe_SIG_MORE; ud.dynvzaxe.enable = 'Off';
set(axCur,'UserData',ud);
title(getWavMSG('Wavelet:wmp1dRF:Title_Sig_App'),'Parent',axe_SIG_MORE);
set(axe_SIG_MORE,'XGrid','On','YGrid','On');
%--------------------------------------------------------------------------
function plotCFS(caller_Handles,handles)

local_FIG = handles.output;
caller_FIG = caller_Handles.output; 
nbVect = wtbxappdata('get',caller_FIG,'MP_nbVect');
MP_Results = wtbxappdata('get',caller_FIG,'MP_Results');
nV = length(nbVect);
IOPT = MP_Results{4};
ax_SIG = handles.Axe_SIG_MORE;
ax_CPT = handles.Axe_for_CPT;
delete(allchild(ax_CPT));
LstCPT = get(caller_Handles.Lst_CMP_DICO,'String');
Data_CFS = wtbxappdata('get',local_FIG,'Data_CFS');
set(handles.uitable_CFS,'Data',Data_CFS);
set(ax_CPT,'NextPlot','Add');
%--------------------------------------------
% Color and parameters used for plotting.
%----------------------------------------
txtColor = get(get(ax_CPT,'Parent'),'Color');
M1 = jet(5); M2 = hsv(5);
M2([1 4],:) = [1 0.5 0.5;0.4 0.4 0.9];
map = [M1;M2;cool(nV)];
ColTab = num2cell(map,2)';
idx_DCT = strcmp(LstCPT,'dct');
idx_COS = strcmp(LstCPT,'cos');
idx_SIN = strcmp(LstCPT,'sin');
idx_POL = strcmp(LstCPT,'poly');
if any(idx_DCT) , ColTab{idx_DCT} = [0.8  0.0  0.8]; end
if any(idx_COS) , ColTab{idx_COS} = [0.85 0.85 0.0]; end
if any(idx_SIN) , ColTab{idx_SIN} = [0.0  0.8  0.8]; end
if any(idx_POL) , ColTab{idx_POL} = [0.0  0.0  0.0]; end
FontU = 'point';  FontN = get(local_FIG,'DefaultAxesFontName');
FontW = 'normal'; FontS = 8;
%----------------------------------------------------------
nbcfsTOT = 0;
first = 1;
for jjj = 1:nV
    idx_jjj = (nV+1-jjj);
    nbval = nbVect(jjj);
    last = first+nbval-1;
    yy = idx_jjj*ones(1,nbval);
    xx = (1:nbval)/nbval;
    plot([0 xx],[idx_jjj yy],'-k','Parent',ax_CPT);
    tf = ismember(IOPT,first:last);
    nbcfs  = sum(tf);
    nbcfsTOT = nbcfsTOT+nbcfs;
    if ~isempty(tf) && any(tf)
        index = IOPT(tf)-first+1;
        yytf = yy(index) + 0.5  ;
        XXX = [repmat(xx(index),2,1) ; NaN(1,size(xx(index),2))];
        XXX = XXX(:);
        YYY = [yytf ; yy(index) ; NaN(size(yytf))];
        YYY = YYY(:);
        plot(XXX,YYY,'Color',ColTab{jjj},'LineStyle','-',...
            'Parent',ax_CPT);
        plot(xx(index),yytf,'Color',ColTab{jjj}, ...
            'LineStyle','none','Marker','s',...
            'MarkerFaceColor',ColTab{jjj}, ...
            'MarkerSize',5,'Parent',ax_CPT, ...
            'ButtonDownFcn','win_Atom_BtnDown_FCN');
    end
    first = last+1;
    tagTXT = ['txt_' int2str(jjj)];
    txtEFF = wfindobj(ax_CPT,'Type','text','Tag',tagTXT);
    strEFF = [int2str(nbcfs) ' / ' int2str(nbval)];
    if isempty(txtEFF)
        text(1.025,yy(1)+0.25,strEFF,...
            'BackgroundColor',txtColor,...
            'EdgeColor',[0.5 0.5 0.5],...
            'HorizontalAlignment','left',...
            'FontUnits',FontU,'FontName',FontN, ...
            'FontSize',FontS,'FontWeight',FontW,...
            'Tag',tagTXT,'Parent',ax_CPT);
    else
        set(txtEFF,'String',strEFF);
    end    
end
set(ax_CPT,'Xlim',[0 1],'Ylim',[0.5,nV+1]);

strEFF = [int2str(nbcfsTOT) ' / ' int2str(sum(nbVect))];
title(getWavMSG('Wavelet:wmp1dRF:Ind_of_Sel',strEFF),'Parent',ax_CPT)
set(ax_CPT,'Xtick',[],'XTicklabel','',...
    'Ytick',(1:nV),'YTicklabel',LstCPT(end:-1:1));
appCur = wfindobj(ax_SIG,'Type','line','Tag','appCur');
if isempty(appCur)
    hSig_ANAL   = wfindobj(caller_FIG,'Type','line','Tag','Sig_ANAL');
    xval = get(hSig_ANAL,'XData');
    appCur = line('XData',xval,'YData',zeros(size(xval)),...
        'Color',[0 0.7 0],'Linewidth',2,'Tag','appCur','Parent',ax_SIG);
else
    xval = get(appCur,'XData');
    set(appCur,'YData',zeros(size(xval)));
end
wtbxappdata('set',handles.output,'appCur',appCur);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Init_TABLE(caller_Handles,handles)

local_FIG = handles.output;
caller_FIG = caller_Handles.output; 
nbVect = wtbxappdata('get',caller_FIG,'MP_nbVect');
nV = length(nbVect);
MP_Results = wtbxappdata('get',caller_FIG,'MP_Results');
[COEFF,IOPT] = deal(MP_Results{3:4});

nbCFS = length(IOPT);
IdxOfFam = zeros(nbCFS,1);
cumLEN =[1 1+cumsum(nbVect)];
for k = 1:nV
    IdxOfFam(cumLEN(k)<=IOPT & IOPT<cumLEN(k+1)) = k;
end
IdxInFAM = cell(nV,1);
xyLOC = zeros(nbCFS,2);
locInFAM = cell(nV,1);
nbcfsTOT = 0;
first = 1;
NumOfFam = zeros(size(IOPT));
for idxFAM = 1:nV
    nbval = nbVect(idxFAM);
    last = first+nbval-1;
    xx = (1:nbval)/nbval;
    yy = (nV+1-idxFAM)*ones(1,nbval);
    tf = ismember(IOPT,first:last);
    NumOfFam(tf) = idxFAM;
    nbcfs  = sum(tf);
    nbcfsTOT = nbcfsTOT+nbcfs;
    if ~isempty(tf) && any(tf)
        index = IOPT(tf)-first+1;
        XP = xx(index);
        YP = yy(index) + 0.5;
        xyLOC(tf,1) = XP(:);
        xyLOC(tf,2) = YP(:);
        IdxInFAM{idxFAM} = index;
        locInFAM{idxFAM} = [XP;YP]';
    end
    first = last+1;
end
Data_CFS = cell(nbCFS,6);
Data_CFS(:,1) = num2cell(false(nbCFS,1));
Data_CFS(:,2) = num2cell(COEFF(1:nbCFS));
Data_CFS(:,3) = num2cell((1:nbCFS)');
Data_CFS(:,4) = num2cell(IdxOfFam(:));
Data_CFS(:,5) = num2cell(IOPT(:));
Data_CFS(:,6) = num2cell(cat(2,IdxInFAM{:})');
wtbxappdata('set',local_FIG,'Data_CFS',Data_CFS);
wtbxappdata('set',local_FIG,'xyLOC',xyLOC);
wtbxappdata('set',local_FIG,'IdxInFAM',IdxInFAM);
wtbxappdata('set',local_FIG,'locInFAM',locInFAM);
%--------------------------------------------------------------------------

% --- Executes when entered data in editable cell(s) in uitable_CFS.
function uitable_CFS_CellEditCallback(hObject,eventdata,handles,arg)
% hObject    handle to uitable_CFS (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty
%	if Data was not changed 
%	Error: error string when failed to convert EditData to appropriate
%	value for Data 
% handles    structure with handles and user data (see GUIDATA)

if nargin<4
    Idx_CELL = eventdata.Indices;
    if ~isequal(Idx_CELL(2),1) , return; end
end
fig = handles.output;
[~,caller_FIG] = wtbxappdata('get',fig,'caller_Handles','caller_FIG');
DICO = wtbxappdata('get',caller_FIG,'MP_Dictionary');
appCur = wtbxappdata('get',fig,'appCur');
uitCFS = get(handles.uitable_CFS);
Data = uitCFS.Data;
C1 = Data(:,1);
C1 = cat(1,C1{:});
Idx = find(C1);
ydata = 0;
nbSEL = length(Idx);
for kk = 1:nbSEL
    ydata = ydata + Data{Idx(kk),2}*DICO(:,Data{Idx(kk),5});
end
if isequal(nbSEL,0)
    ydata = zeros(size(get(appCur,'XData')));
end
set(appCur,'YData',ydata)
ax = get(appCur,'Parent');
axis(ax,'tight')

% MP_Results = wtbxappdata('get',caller_FIG,'MP_Results');
% IOPT = MP_Results{4};
% ORD = cat(1,Data{:,4})';
xyLOC = wtbxappdata('get',fig,'xyLOC');
[~,CC] = sort(cat(1,Data{:,3}));
[~,DD] = sort(CC);
xyLOC = xyLOC(DD,:);
xyLOC = xyLOC(Idx,:);

ax = handles.Axe_for_CPT;
CFS_SEL = wfindobj(ax,'Type','line','Tag','Pts_CFS_SEL');
delete(CFS_SEL)
MCol = [1 0 0];
line('XData',xyLOC(:,1),'YData',xyLOC(:,2),'Color',MCol,...
    'Marker','s','MarkerSize',5,'MarkerEdgeColor',MCol,...
    'MarkerFaceColor',MCol,'LineStyle','none',...
    'ButtonDownFcn','win_Atom_BtnDown_FCN',...
    'Tag','Pts_CFS_SEL','Parent',ax)

hSig_ANAL   = wfindobj(caller_FIG,'Type','line','Tag','Sig_ANAL');
Y = get(hSig_ANAL,'YData');
R = Y(:)-ydata(:);
COEFF  = cat(1,Data{Idx,2});
qual   = 100*norm(COEFF)^2/norm(Y)^2;
ErrL1  = 100*(norm(R,1)/norm(Y,1));
ErrL2  = 100*(norm(R)/norm(Y));
ErrMax = 100*(norm(R,Inf)/norm(Y,Inf));
set(handles.Edi_QUAL,'String',sprintf('%5.2f %%',qual));
set(handles.Edi_Err_L2,'String',sprintf('%5.2f %%',ErrL2));
set(handles.Edi_Err_L1,'String',sprintf('%5.2f %%',ErrL1));
set(handles.Edi_Err_MAX,'String',sprintf('%5.2f %%',ErrMax));
%--------------------------------------------------------------------------
% --- Executes when selected cell(s) is changed in uitable_CFS.
function uitable_CFS_CellSelectionCallback(hObject,eventdata,handles)
% hObject    handle to uitable_CFS (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
Idx_CELL = eventdata.Indices;
if isempty(Idx_CELL) || isequal(Idx_CELL(2),1) , return; end
%--------------------------------------------------------------------------
function Pus_SORT_Callback(hObject,eventdata,handles,arg)

val = get(handles.Pop_SORT_Table,'Value');
D = get(handles.uitable_CFS,'Data');
switch val
    case {1} % Value
        D = sortrows(D,val+1);

    case 2 % Absolute value
        [~,Is] = sort(abs(cat(1,D{:,2})));
        D = D(Is,:);
        
    case {3,4,5,6} % Rank , Family , Ndx in Dicto, Ndx in Fam. , 
        D = sortrows(D,val);
end
if isequal(arg,-1) , D = D(end:-1:1,:); end
set(handles.uitable_CFS,'Data',D);
%--------------------------------------------------------------------------
function Pus_SEL_CPT_Callback(hObject,eventdata,handles)

val_SEL_CPT = get(handles.Pop_SEL_CPT,'Value');
uitCFS = get(handles.uitable_CFS);
D = uitCFS.Data;
switch val_SEL_CPT
    case {1,2}
        if isequal(val_SEL_CPT,1) , bool = {false}; else bool = {true}; end
        D(:,1) = bool;
        
    case 3
        val_FAM = get(handles.Pop_SEL_FAM,'Value');
        TMP = sortrows(D,3);
        II = cat(1,TMP{:,4})==val_FAM;
        TMP(:,1) = num2cell(II);
        [~,II] = sort(II,'descend');
        TMP = TMP(II,:);
        D = TMP;
end
set(handles.uitable_CFS,'Data',D);
uitable_CFS_CellEditCallback(handles.uitable_CFS,eventdata,handles,'pop')
%--------------------------------------------------------------------------
function Pop_SEL_CPT_Callback(hObject,eventdata,handles)

val = get(hObject,'Value');
switch val
    case {1,2} , vis = 'Off';
    case 3 ,     vis = 'On';
end
set(handles.Pop_SEL_FAM,'Visible',vis);
%--------------------------------------------------------------------------
function Pop_SEL_FAM_Callback(hObject,eventdata,handles)
%--------------------------------------------------------------------------
function Pop_FRQ_CPT_Callback(hObject,eventdata,handles)  % Not Used

caller_FIG = wtbxappdata('get',hObject,'caller_FIG');
val = get(hObject,'Value');
lst = get(hObject,'String');
strTITLE = lst{val};
if ~isequal(val,length(lst))
    strTITLE = ['Component: ' strTITLE]; 
end
lin_CPT = wtbxappdata('get',caller_FIG,'lin_COMPO');
window = 64; overlap = 63;
signal = get(lin_CPT(val),'YData');
mini = min(signal);
maxi = max(signal);
if isequal(mini,maxi) , mini = mini-0.01; maxi = maxi+0.01; end

plot(signal,'r','Parent',handles.Axe_FRQ_SIG);
title(strTITLE,'Parent',handles.Axe_FRQ_SIG);
set(handles.Axe_FRQ_SIG,'Xlim',[1,length(signal)],...
    'Ylim',[mini,maxi]);
set(handles.Axe_FRQ_SIG,'Nextplot','ReplaceChildren')
axes(handles.Axe_FRQ_PER); 
periodogram(signal); axis tight; pause(0.05); 
set(handles.Axe_FRQ_PER,'Nextplot','ReplaceChildren')
axes(handles.Axe_FRQ_SPEC);  
spectrogram(signal,window,overlap,'yaxis'); axis tight;
% xt = get(handles.Axe_FRQ_SIG,'XtickLabel');
% xL1 = get(handles.Axe_FRQ_SIG,'Xlim');
% xL2 = get(handles.Axe_FRQ_SPEC,'Xlim');
% set(handles.Axe_FRQ_SPEC,'XtickLabel','');
pause(0.05);
set(handles.Axe_FRQ_SPEC,'Nextplot','ReplaceChildren')
%--------------------------------------------------------------------------
