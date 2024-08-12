function varargout = wmpguifunc(handles,varargin)
%MATCHING PURSUIT using wavelet.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 06-Mar-2013.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check inputs
nbIN = length(varargin);

hFig    = handles.output;
axe_SIG = handles.Axe_SIG;
axe_CFS = handles.Axe_CFS;
axe_ADD = handles.Axe_ADD;
axe_COMPO = handles.Axe_COMPO;
axe_QUAL  = handles.Axe_QUAL;
Pus_START = handles.Pus_START_PLOT;
Pus_STOP  = handles.Pus_STOP_PLOT;
Pus_END_DISP = handles.Pus_END_DISP;
Pus_STOP_ALG = handles.Pus_STOP_ALG;
Pop_ITER = handles.Pop_ITER;
pos_axe_COMPO = get(axe_COMPO,'Position');
SIG = wtbxappdata('get',hFig,'sig_ANAL');
set(hFig,'Pointer','arrow')

% Default and initialization for parameters.
%-------------------------------------------
LstCPT   = [];
onceFLAG = [];
%---------------
LstCPT_DEF   = {'sym4 - lev5','wpsym4 - lev5','dct','sin','cos'};
onceFLAG_DEF = false;
% demoFLAG   = false;

k = 1;
while k<=nbIN
    argNAM = lower(varargin{k});
    switch argNAM
        case 'lstcpt'   , LstCPT = varargin{k+1}; k = k+2;
        case 'onceflag' , onceFLAG = varargin{k+1}; k = k+2;
        otherwise , k = k+1;
    end
end
if isempty(LstCPT)
    LstCPT  = get(handles.Lst_CMP_DICO,'String');
    if isempty(LstCPT) , LstCPT = LstCPT_DEF; end
end
if isempty(onceFLAG) , onceFLAG = onceFLAG_DEF; end

% Get Type of algorithm.
%-----------------------
type_ALG = get(handles.Pop_Type_ALG,'Value');

% Get Plot Parameters: Itermax, typePLOT and stepPLOT.
%-----------------------------------------------------
str = get(handles.Pop_ITER,'String');
val = get(Pop_ITER,'Value');
itermax = str2double(str{val});
val = get(handles.Pop_TYP_DISP,'Value');
switch val
    case 1 
        typePLOT = 'oneplot';
    case 2 
        typePLOT = 'stepwise';
    case 3 
        typePLOT = 'movie';
end
str = get(handles.Pop_STP_PLOT,'String');
val = get(handles.Pop_STP_PLOT,'Value');
stepPLOT = str2double(str{val});

% Algorithm Parameters.
%---------------------
N = length(SIG);
Pop_ERR = handles.Pop_ERR_MAX;
num_ERR = get(Pop_ERR,'Value');
valERR = [];
namERR = 'none';
if num_ERR>1
    Edi_ERR = handles.Edi_ERR_MAX;
    str_ERR = get(Pop_ERR,'String');
    namERR  = str_ERR{num_ERR};
    valERR  = str2double(get(Edi_ERR,'String'));
end
if isempty(valERR) || isnan(valERR)
    valERR = 0;
    set(Pop_ERR,'Value',1);
else
    itermax = min([N,500]);
end

% Preparing data.
%----------------
rowwise = size(SIG,1)==1;
Y = SIG;
Y = Y(:);
N2Y = Y'*Y;
xval = 1:N;

init_STOP_ALG;

% Initialization of the dictionnary.
%-----------------------------------
LstCPT_SAV = LstCPT;
[DICO,nbVect] = wtbxappdata('get',hFig,'MP_Dictionary','MP_nbVect');
if isempty(DICO)
    wwaiting('msg',hFig,getWavMSG('Wavelet:wmp1dRF:WaitBuildDic'));
    LstCPT_TMP = LstCPT;
    for kk = 1:length(LstCPT)
        tmp = LstCPT{kk};
        idx = strfind(tmp,'-');
        if ~isempty(idx)
            S1 = tmp(1:idx-1);
            S2 = tmp(idx+5:end);
            LstCPT_TMP{kk} = {S1,str2double(S2)};
        end
    end
    [DICO,nbVect] = wmpdictionary(N,'lstcpt',LstCPT_TMP);
    wtbxappdata('set',hFig,'MP_Dictionary',DICO,'MP_nbVect',nbVect);
    wwaiting('off',hFig);
end
[N,p] = size(DICO);

% Many levels for the basis.
%---------------------------
if iscell(LstCPT)
    nbFUN = length(LstCPT);
    TMP = cell(1,nbFUN);
    for kp = 1:nbFUN
        dum =  LstCPT{kp};
        if iscell(dum)
            name = dum{1};
            TMP{kp} = [name dum{2}];
        else
            TMP{kp} = dum;
        end
    end
    LstCPT = TMP;
end
wtbxappdata('set',hFig,'LstCPT',LstCPT);

strPOP = ['none',LstCPT,'signal'];
set(handles.Pop_COMPO,'String',strPOP,'Value',1);

J     = 1:p;               % index of remaining variables in the dictionary
COEFF = zeros(itermax,1);  % coeff
YFIT  = zeros(N,1) ;
nV = length(nbVect);
lin_COMPO = zeros(1,nV+1);
% Color and parameters used for plotting.
%----------------------------------------
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
ErrQual_COL = [0.0  0.0  1.0];
ErrL2_COL   = [1.0  0.0  0.0];
ErrL1_COL   = [0.0  0.8  0.0];
ErrMax_COL  = [0.5  0.5  0.5];
FontU = 'point';  FontN = get(hFig,'DefaultAxesFontName');
FontW = 'normal'; FontS = 8;
%-----------------------------------------------------------------
ax = wfindobj(hFig,'type','axes');
set(ax,'FontUnits',FontU,'FontSize',FontS);
set([axe_CFS,axe_ADD,axe_QUAL,axe_COMPO,handles.Pan_COMPO],'Visible','on');
if ~isequal(typePLOT,'oneplot')
    kPLOT = 0:stepPLOT:itermax;
    if ~ismember(itermax,kPLOT) , kPLOT = [kPLOT,itermax]; end
else
    kPLOT = itermax;
end

% Initialization
IOPT = zeros(1,itermax);
ErrL1 = zeros(1,itermax);
ErrL2 = zeros(1,itermax);
ErrMax = zeros(1,itermax);
contrib = zeros(N,nV);
R = Y;
Add = zeros(N,1);
k = 0;
switch type_ALG
    case 1
        IOPT  = [];     % index of the choosen variables
    case {2,3}
        XX  = DICO;
        qual = zeros(1,itermax);
        J     = 1:p;    % index of remaining variables in the dictionary
        IOPT  = [];     % index of the choosen variables
        COEFF = zeros(itermax,1); % Coefficients
        YFIT  = zeros(N,1);
        if isequal(type_ALG,3)
            wmpcfs = str2double(get(handles.Edi_Cfs_WMP,'String'));
        end
end

if ~isequal(typePLOT,'oneplot')
    set(Pus_START,'Enable','On','Userdata',0);
    wtbxappdata('set',hFig,'Init_Algo',1);
    autoDISP = isequal(typePLOT,'movie');
    set(Pus_END_DISP,'Enable','On')
    set(Pus_START,'Enable','Off')
    set(Pus_STOP,'Enable','On')
    set([Pus_START,Pus_STOP,Pus_END_DISP],'Userdata',0);
    if ~autoDISP , set(Pus_STOP,...
            'String',getWavMSG('Wavelet:wmp1dRF:Pus_NEXT'));
    end
end

firstSTEP = true;
stop = STOP_ALG;
dispMSG(0);
while ~stop
    k = k+1;
    switch type_ALG
        case 1  % BASIC Matching Pursuit
            [~,i]	 = max(abs(R' * DICO));  % choose the max(abs(scalar product)
            kopt     = J(i);                 % indices of the kept variables
            COEFF(k) = R'*DICO(:,i);         % coefficient
            Z		 = COEFF(k) * DICO(:,i); % projection onto the kept variable
            IOPT(k)	 = kopt;
            Add  = Add + Z;          % cumulated modifs between 2 plots
            YFIT = YFIT + Z;         % fit
            R    = R - Z;            % residuals
            if onceFLAG
                J = setdiff(J,kopt);
                DICO(:,i) = [];
            end
            
        case {2,3}  % ORTHOGONAL Matching Pursuit and WEAK Matching Pursuit
            valScalProd = abs(R' * XX);
            okALG = false;
            if isequal(type_ALG,3)
                i = find(valScalProd>wmpcfs*norm(R),1,'first');
                if ~isempty(i) , okALG = true; end
            end
            if ~okALG , [~,i] = max(valScalProd); end  % OMP and ...
            kopt = J(i);           % indices of columns in the initial X.
            J    = setdiff(J,kopt);
            IOPT(k)	 = kopt;
            P    = DICO(:, IOPT);
            TMP  = ((P'*P)\P')*Y;
            COEFF(k) = TMP(k);
            Z = P*TMP - YFIT;
            Add  = Add + Z;
            YFIT = YFIT + Z;
            R    = R - Z;
            XX = DICO(:,J);
    end
    
    % Find index of selected coefficient in DICO
    first = 1;
    for jj = 1:nV
        last = first+nbVect(jj)-1;
        tf = ismember(kopt,first:last);
        if ~isempty(tf) && any(tf)
            index = kopt-first+1;
            jSEL = jj;
            break;
        end
        first = last+1;
    end
    
    contrib(:,jSEL) = contrib(:,jSEL) + Z;
    qual(k)	  = 100*norm(COEFF)^2/N2Y;  % cumulated quality
    ErrL1(k)  = 100*(norm(R,1)/norm(Y,1));
    ErrL2(k)  = 100*(norm(R)/norm(Y));
    ErrMax(k) = 100*(norm(R,Inf)/norm(Y,Inf));
    if ~isempty(namERR)
        switch num_ERR
            case 1 , curERR = Inf;         % 'NONE'
            case 2 , curERR = ErrL1(k);    % 'L1 NORM'
            case 3 , curERR = ErrL2(k);    % 'L2 NORM'
            case 4 , curERR = ErrMax(k);   % 'LINF NORM'
        end
    end
    
    STOP_ALG = get(Pus_STOP_ALG,'Userdata');
    if k>=itermax || curERR<valERR || STOP_ALG
        stop = true;
        kPLOT(kPLOT>=k) = [];
        kPLOT = [kPLOT,k]; %#ok<AGROW>
    end
    
    if ~isequal(typePLOT,'oneplot') && ismember(k,kPLOT)
        if isequal(typePLOT,'movie') && ...
                isequal(get(Pus_STOP,'Userdata'),1)
            STOP_ALG = waitButton(0);
        end
        %------------------------
        plotDEC;  Add = zeros(N,1); if type_ALG==1 , end
        stop = STOP_ALG || stop;
        %------------------------
        dispMSG(0);
        
        if isequal(typePLOT,'movie') && firstSTEP
            wwaiting('msg',hFig,getWavMSG('Wavelet:wmp1dRF:Press_Continue'),'nowatch');
            set(Pus_START,'Enable','On','Userdata',0);
            set(Pus_STOP,'Enable','Off','Userdata',0);
            waitFLAG = true;
            while waitFLAG
                pause(0.1);
                usr = get(Pus_START,'Userdata');
                waitFLAG = isequal(usr,0);
            end
            firstSTEP = false;
            set(Pus_START,'Enable','Off','Userdata',0);
            set(Pus_STOP,'Enable','On','Userdata',0);
        end
        
    end
    
end
COEFF = COEFF(1:length(IOPT));

% End of algorithm.
%------------------
if rowwise
    YFIT = YFIT(:)'; R = R(:)'; COEFF = COEFF(:)';
end

% Last plot.
%-----------
if isequal(typePLOT,'oneplot')
    onePLOT;
else
    plotRESIDUAL;
end

% Prepare outputs
%----------------
switch nargout
    case 1 , varargout = {YFIT};
    case 2 , varargout = {YFIT,R};
    case 3 , varargout = {YFIT,R,COEFF};
    case 4 , varargout = {YFIT,R,COEFF,IOPT};
    case 5 , varargout = {YFIT,R,COEFF,IOPT,qual};
    case 6 , varargout = {YFIT,R,COEFF,IOPT,qual,DICO};
end
wtbxappdata('set',hFig,'MP_Results',{YFIT,R,COEFF,IOPT,qual});


% Restore GUI.
%--------------
set([Pus_START,Pus_END_DISP,Pus_STOP],'Enable','Off','Userdata',0);
wtbxappdata('set',hFig,'lin_COMPO',lin_COMPO);
hdl_Menus = wtbxappdata('get',hFig,'hdl_Menus');
set(hdl_Menus.m_save,'Enable','On');
set(Pus_STOP_ALG,'Visible','Off','Enable','On','Userdata',0);
set([handles.Pus_MORE,handles.Pus_RESIDUALS],...
    'Visible','On','Enable','On','Userdata',0);
wwaiting('off',hFig);


%====================================================================
    function plotDEC
        idxKplot = find(kPLOT==k);
        newk = (kPLOT(idxKplot-1)+1):kPLOT(idxKplot);
        plotSIGandFIT;  % Plot Signal and Approximation Stems.
        %-----------------------------------------------------------
        plot(xval,Add,'g-','Parent',axe_ADD);
        if isequal(stepPLOT,1)
            tmp = cumsum(nbVect);
            idxOpt = kopt;
            if jSEL>1 , idxOpt = idxOpt - tmp(jSEL-1); end
            famOpt = LstCPT{jSEL};
            strTITLE = getWavMSG('Wavelet:wmp1dRF:AddATMore',...
                int2str(newk),famOpt,idxOpt);
        else
            strTITLE = getWavMSG('Wavelet:wmp1dRF:AddAT',int2str(newk));
        end
        title(strTITLE,'FontUnits',FontU,'FontSize',FontS,'Parent',axe_ADD)
        
        set(axe_ADD,'Xlim',[1 N], ...
            'Ylim',[min(Add(:))-0.001 max(Add(:))+0.001])
        %-----------------------------------------------------------
        plotCFS;        % Plot Coefficients Stems.
        plotCOMPO;      % Plot Components.
        plotQUAL;       % Plot Quality.
        %---------------------------------------------------
        autoDISP = isequal(typePLOT,'movie');
        usr_2 = get(Pus_END_DISP,'Userdata');
        if autoDISP && ~isequal(usr_2,1)
            usr_1 = get(Pus_STOP,'Userdata');
            if ~isequal(usr_2,1) && isequal(usr_1,1)
                STOP_ALG = waitButton(0);
            end
        else
            dispMSG(1);
            STOP_ALG = waitButton(1);
        end
        if STOP_ALG
            return
        elseif isequal(usr_2,1)
            typePLOT = 'oneplot';
            kPLOT = itermax;
        end
        
    end
%====================================================================
    function onePLOT
        %---------------------------------------------------
        plotSIGandFIT;  % Plot Signal and Approximation Stems.
        plotCFS;        % Plot Coefficients Stems.
        plotCOMPO;      % Plot Components.
        plotQUAL;       % Plot Quality.
        plotRESIDUAL;   % Plot Errors and Residuals.
    end
%====================================================================


%------------------------------------------------------------------
    function plotSIGandFIT
        hL = plot(xval,Y,'r-',xval,YFIT,'b-','Parent',axe_SIG);
        set(hL(1),'Tag','Sig_ANAL');
        set(hL(2),'Tag','Sig_APPROX');
        set(hL,'Linewidth',1.5)
        S1 = sprintf('%5.2f %%',qual(k));
        title({getWavMSG('Wavelet:wmp1dRF:Title_Sig_App'),...
            getWavMSG('Wavelet:wmp1dRF:StrIterEner',k,S1)}, ...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_SIG);
        S1 = num2str(ErrL2(k),'%5.2f %%');
        S2 = num2str(ErrMax(k),'%5.2f %%');
        S3 = num2str(ErrL1(k),'%5.2f %%');
        xlabel(getWavMSG('Wavelet:wmp1dRF:Relative_Err',S1,S2,S3), ...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_SIG);
        tmp = [Y(:);YFIT(:)]; mini = min(tmp); maxi= max(tmp);
        set(axe_SIG,'Xlim',[1 N],'Ylim',[mini,maxi])
        set(axe_SIG,'Xgrid','On','Ygrid','On');
        axL = legend(axe_SIG,getWavMSG('Wavelet:wmp1dRF:Leg_Sig'), ...
            getWavMSG('Wavelet:wmp1dRF:Leg_App'),'Location','NorthWest','AutoUpdate','off');
        setDynV(axL,axe_SIG)
    end
%------------------------------------------------------------------
    function plotCFS
        set(axe_CFS,'NextPlot','Add');
        txtColor = get(get(axe_CFS,'Parent'),'Color');
        nbcfsTOT = 0;
        first = 1;
        for jjj = 1:nV
            idx_jjj = (nV+1-jjj);
            nbval = nbVect(jjj);
            last = first+nbval-1;
            yy = idx_jjj*ones(1,nbval);
            xx = (1:nbval)/nbval;
            plot([0 xx],[idx_jjj yy],'-k','Parent',axe_CFS);
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
                    'Parent',axe_CFS);
                plot(xx(index),yytf,'Color',ColTab{jjj}, ...
                    'LineStyle','none','Marker','s',...
                    'MarkerFaceColor',ColTab{jjj}, ...
                    'MarkerSize',5,'Parent',axe_CFS, ...
                    'ButtonDownFcn','win_Atom_BtnDown_FCN');
            end
            tagTXT = ['txt_' int2str(jjj)];
            txtEFF = wfindobj(axe_CFS,'Type','text','Tag',tagTXT);
            strEFF = [int2str(nbcfs) ' / ' int2str(nbval)];
            if isempty(txtEFF)
                text(1.025,yy(1)+0.25,strEFF,...
                    'BackgroundColor',txtColor,...
                    'EdgeColor',[0.5 0.5 0.5],...
                    'HorizontalAlignment','left',...
                    'FontUnits',FontU,'FontName',FontN, ...
                    'FontSize',FontS,'FontWeight',FontW,...
                    'Tag',tagTXT,'Parent',axe_CFS);
            else
                set(txtEFF,'String',strEFF);
            end
            first = last+1;
        end
        strEFF = [int2str(nbcfsTOT) ' / ' int2str(sum(nbVect))];
        set(axe_CFS,'Xlim',[0 1],'Ylim',[0.5,nV+1]);
        title(getWavMSG('Wavelet:wmp1dRF:Ind_of_Sel',strEFF),...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_CFS)
        xlabel(getWavMSG('Wavelet:wmp1dRF:IdxCptDic'), ...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_CFS)
        set(axe_CFS,'Xtick',[],'XTicklabel','',...
            'Ytick',(1:nV),'YTicklabel',LstCPT_SAV(end:-1:1));
    end
%------------------------------------------------------------------
    function plotCOMPO
        valYD = [Y,contrib];
        Ylim = [min(valYD(:)) max(valYD(:))];
        delete(allchild(axe_COMPO));
        set(axe_COMPO,'Nextplot','Add');
        lin_COMPO(nV+1) = plot(xval,Y,'r','LineWidth',1,'Parent',axe_COMPO);
        for ic = 1:nV
            lin_COMPO(ic) = ...
                plot(xval,contrib(:,ic),'Color',ColTab{ic},...
                'LineWidth',1,'Parent',axe_COMPO);
        end
        set(axe_COMPO,'Xlim',[1 N],'Ylim',Ylim)
        axL = legend(axe_COMPO,['signal',LstCPT],...
            'Location',[0.28 0.18 0.08 0.15],'AutoUpdate','off');
        set(axL,'FontUnits',FontU,'FontSize',FontS);
        set(axe_COMPO,'Nextplot','ReplaceChildren',...
            'Position',pos_axe_COMPO);
        title(getWavMSG('Wavelet:wmp1dRF:SigCpts'), ...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_COMPO);
        set(axe_COMPO,'Xgrid','On','Ygrid','On');
        setDynV(axL,axe_COMPO)
    end
%------------------------------------------------------------------
    function plotQUAL
        lenqual = find(qual>0,1,'last');
        if lenqual>1
            xlim = [1,lenqual]; else
            xlim = [0.5,1.5];
        end
        idxPlot = 1:lenqual;
        if lenqual<10
            MarkerSize = 5;
        elseif lenqual<20
            MarkerSize = 4;
        else
            MarkerSize = 2;
        end
        linPROP = {'Marker','s','MarkerSize',MarkerSize,...
            'LineStyle','-','Parent',axe_QUAL};
        plot(idxPlot,qual(idxPlot),'Color',ErrQual_COL, ...
            'MarkerFaceColor',ErrQual_COL,linPROP{:});
        set(axe_QUAL,'NextPlot','add');
        plot(idxPlot,ErrMax(idxPlot),'Color',ErrMax_COL,...
            'MarkerFaceColor',ErrMax_COL,linPROP{:});
        plot(idxPlot,ErrL1(idxPlot),'Color',ErrL1_COL,...
            'MarkerFaceColor',ErrL1_COL,linPROP{:});
        plot(idxPlot,ErrL2(idxPlot),'Color',ErrL2_COL,...
            'MarkerFaceColor',ErrL2_COL,linPROP{:});
        mY = 1.01*max([qual,ErrMax,ErrL1,ErrL2]);
        set(axe_QUAL,'Xlim',xlim,'Ylim',[0,mY],...
            'NextPlot','ReplaceChildren');
        title(getWavMSG('Wavelet:wmp1dRF:RetEnerRelErr'), ...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_QUAL)
        xlabel(getWavMSG('Wavelet:wmp1dRF:Iteration'), ...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_QUAL)
        axL = legend(axe_QUAL,'Qual','ErrLMax','ErrL1','ErrL2', ...
            'Location',[0.08 0.084 0.20 0.025],...
            'Orientation','horizontal','AutoUpdate','off');
        
        set(axL,'FontUnits',FontU,'FontSize',FontS);
        set(axe_QUAL,'Position',[0.038 0.17  0.20  0.16]);
        set(axe_QUAL,'Xgrid','On','Ygrid','On');
        setDynV(axL,axe_QUAL)
    end
%------------------------------------------------------------------
    function plotRESIDUAL
        plot(xval,abs(R),'LineWidth',1,'Color',[1 0.70 0.28],...
            'Parent',axe_ADD,'Tag','Sig_RES');
        title(getWavMSG('Wavelet:wmp1dRF:StrResidual'),...
            'FontUnits',FontU,'FontSize',FontS,'Parent',axe_ADD)
        set(axe_ADD,'Xlim',[1 N],'Ylim',[0,max(abs(R))])
        set(axe_ADD,'Xgrid','On','Ygrid','On');
    end
%------------------------------------------------------------------
    function dispMSG(arg)
        if isequal(typePLOT,'movie') && ~firstSTEP
            msg = getWavMSG('Wavelet:wmp1dRF:Press_Pause');
        elseif arg==0
            msg = getWavMSG('Wavelet:commongui:WaitCompute');
        else
            msg = getWavMSG('Wavelet:wmp1dRF:Press_Next');
        end
        wwaiting('msg',hFig,msg,'nowatch');
        pause(0.01);
    end
%------------------------------------------------------------------
    function init_STOP_ALG
        set(Pus_STOP_ALG,'Visible','On','Enable','On','Userdata',0);
        pause(0.1);
        STOP_ALG = get(Pus_STOP_ALG,'Userdata');
    end
%------------------------------------------------------------------
    function STOP_ALG = waitButton(arg)
        if isequal(arg,0)
            set(Pus_START,'Enable','On','Userdata',0);
            set(Pus_STOP,'Enable','Off','Userdata',0);
            wwaiting('msg',hFig,...
                getWavMSG('Wavelet:wmp1dRF:Press_Continue'),'nowatch');
            waitFLAG = true;
            while waitFLAG
                usr_1 = get(Pus_START,'Userdata');
                usr_2 = get(Pus_END_DISP,'Userdata');
                STOP_ALG = get(Pus_STOP_ALG,'Userdata');
                waitFLAG = ~isequal(usr_1,1) && ~isequal(usr_2,1) && ...
                    ~isequal(STOP_ALG,1) ;
                pause(0.05);
            end
            set(Pus_START,'Enable','Off');
            set(Pus_STOP,'Enable','On');
        else
            set(Pus_START,'Enable','Off','Userdata',0');
            set(Pus_STOP,'Enable','On','Userdata',0'); % Pus_STOP <=> NEXT
            waitFLAG = true;
            while waitFLAG
                usr_1 = get(Pus_STOP,'Userdata');
                usr_2 = get(Pus_END_DISP,'Userdata');
                STOP_ALG = get(Pus_STOP_ALG,'Userdata');
                waitFLAG = isequal(usr_1,0)&& ~isequal(usr_2,1)&& ...
                    ~isequal(STOP_ALG,1) ;
                pause(0.05);
            end
        end
    end
%------------------------------------------------------------------
    function setDynV(axCur,axPar)
        ud = get(axCur,'UserData');
        ud.Parent = axPar;
        ud.dynvzaxe.enable = 'Off';
        set(axCur,'UserData',ud);
    end
%------------------------------------------------------------------
end
