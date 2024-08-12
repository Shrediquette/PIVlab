function varargout = wcoher(s1,s2,scales,wname,varargin)
%WCOHER Wavelet coherence.
%
%   WCOHER is not recommended. Use WCOHERENCE instead.
%
%	For two signals S1 and S2, WCOH = WCOHER(S1,S2,SCALES,WAME)
%   returns the wavelet coherence (WCOH).
%   SCALES is a vector which contains the scales, and WNAME is a 
%   string containing the name of the wavelet used for the continuous 
%   wavelet transform.
%
%   In addition, [WCOH,WCS] = WCOHER(...) returns also the
%   Wavelet Cross Spectrum (WCS).
%
%   In addition, [WCOH,WCS,CWT_S1,CWT_S2] = WCOHER(...) returns 
%   also the continuous wavelet transforms of S1 and S2.
%
%   [...] = WCOHER(...,'ntw',VAL,'nsw',VAL) allows to smooth the 
%   CWT coefficients before computing WCOH and WCS. Smoothing
%   can be done in time or scale, specifying in each case the width 
%   of the window using positive integers:
%       'ntw' : N-point time window  (default is min[20,0.05*length(S1)])
%       'nsw' : N-point scale window (default is 1).
%
%   [...] = WCOHER(...,'plot') displays the modulus and phase 
%   of the Wavelet Coherence (WCOH).
%
%   [...] = WCOHER(...,'plot',TYPEPLOT) allows to display other plots.
%	The valid values for TYPEPLOT are:
%       'wcoh' : More on WCOH phase is displayed.
%       'wcs'  : WCS is displayed.
%       'cwt'  : Continuous wavelet transforms are displayed.
%       'all'  : All the outputs are displayed.
%
%   Arrows representing the phase are displayed on the Wavelet
%   Coherence plots. 
%   [...] = WCOHER(...,'nat',VAL,'nas',VAL,'ars',ARS) allows to 
%   change the number and the scale factor for the arrows (see QUIVER):
%       'nat' : number of arrows in time.
%       'nas' : number of arrows in scale.
%       'asc' : scale factor for the arrows.
%       ARS = 2 doubles their relative length, and ARS = 0.5 
%       halves the length.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

nbIN = nargin;

% Parameters for Smoothing (Width of Windows).
flag_SMOOTH = false;
NSW = [];
NTW = [];

% Number of arrows and flag for plots.
NAT = [];
NAS = [];
ASC = 0;
QUI = {}; % Quiver Properties.
flag_PLOT = false;
OK_default = false;

if nbIN>4
    nbIN = nbIN-4;
    k = 1;
    while k<=nbIN
        argNAM = varargin{k};
        if k<nbIN
            argVAL = varargin{k+1};
        else
            argVAL = [];
        end
        switch upper(argNAM(1:3))
            case 'NTW' , NTW = argVAL;
            case 'NSW' , NSW = argVAL;
            case 'PLO' , flag_PLOT = true; type_PLOT = lower(argVAL);
            case 'NAT' , NAT = argVAL;
            case 'NAS' , NAS = argVAL;
            case 'ASC' , ASC = argVAL;
            case 'QUI' , QUI = argVAL;                
        end
        k = k+2;
    end
end
if ~isempty(NSW) && isequal(fix(NSW),NSW) && (NSW>0)
    flag_SMOOTH = true;
end
if ~isempty(NTW) && isequal(fix(NTW),NTW) && (NTW>0)
    flag_SMOOTH = true;
else
    NTW = min([round(0.05*length(s1)),20]);
end

cfs_s1    = wavelet.internal.cwt(s1,scales,wname);
cfs_s10   = cfs_s1;
cfs_s1    = smoothCFS(abs(cfs_s1).^2,flag_SMOOTH,NSW,NTW);
cfs_s1    = sqrt(cfs_s1);
cfs_s2    = wavelet.internal.cwt(s2,scales,wname);
cfs_s20   = cfs_s2;
cfs_s2    = smoothCFS(abs(cfs_s2).^2,flag_SMOOTH,NSW,NTW);
cfs_s2    = sqrt(cfs_s2);
cfs_cross = conj(cfs_s10).*cfs_s20;
cfs_cross = smoothCFS(cfs_cross,flag_SMOOTH,NSW,NTW);
WCOH      = cfs_cross./(cfs_s1.*cfs_s2);

varargout = {WCOH,cfs_cross,cfs_s10,cfs_s20};
if ~flag_PLOT , return; end

% Default
QuiverPROP = {'Color','k','LineWidth',1};
NbArTime  = 40;
NbArScale = 20;
ArSca = 1;
if ~isempty(NAT) && isequal(NAT,fix(NAT)) && NAT>=0 && NAT<length(s1)
    NbArTime = NAT;
end
if ~isempty(NAS) && isequal(NAS,fix(NAS)) && NAS>=0 && NAS<length(scales)
    NbArScale = NAS;
end
if ~isempty(ASC) && ASC>0 && ASC<5
    ArSca = ASC;
end
if ~isempty(QUI) , QuiverPROP = QUI; end

% Define the default for type of plot.
OK_all = strcmpi('all',type_PLOT);
Idx = strfind(type_PLOT,'cwt');
OK_cwt = ~isempty(Idx);
Idx = strfind(type_PLOT,'wcs');
OK_wcs = ~isempty(Idx);
Idx = strfind(type_PLOT,'wcoh');
OK_wcoh = ~isempty(Idx);
if ~(OK_all || OK_cwt || OK_wcs)
    OK_default = true;
end
if OK_wcoh , OK_default = false; end

figPROP  = {'Units','Normalized','DefaultAxesFontSize',8, ...
    'Position',[0.06 , 0.25 , 0.40 , 0.65]};
if OK_all || OK_cwt
    STR1 = getWavMSG('Wavelet:cwtft:CWT_For_W1W2', ...
                inputname(1),inputname(2));
    figure('Name',STR1,figPROP{:});
    plotCOEFS('cwt',s1,s2,cfs_s10,cfs_s20,scales)
end
if OK_all || OK_wcs
    STR1 = getWavMSG('Wavelet:divCMDLRF:Wav_Cross_Spec');
    figure('Name',STR1,figPROP{:});
    plotCOEFS('wcs',s1,s2,cfs_cross,scales,STR1)
end
if OK_all || OK_wcoh
    STR1 = getWavMSG('Wavelet:divCMDLRF:Wav_Coherence');
    figure('Name',STR1,figPROP{:});
    Plot_angle_MODQUIV('Phase',s1,s2,scales,WCOH,...
        NbArTime,NbArScale,ArSca,QuiverPROP)
end
if OK_all || OK_default
    STR1 = getWavMSG('Wavelet:divCMDLRF:Wav_Coherence');  
    figure('Name',STR1,figPROP{:});
    colormap(jet(128))
    Plot_angle_MODQUIV('Modulus',s1,s2,scales,WCOH,...
        NbArTime,NbArScale,ArSca,QuiverPROP)
end


%----------------------------------------------------------------------
function CFS = smoothCFS(CFS,flag_SMOOTH,NSW,NTW)

if ~flag_SMOOTH , return; end
if ~isempty(NTW)
    len = NTW;
    F   = ones(1,len)/len;
    CFS = conv2(CFS,F,'same');
end
if ~isempty(NSW)
    len = NSW;
    F   = ones(1,len)/len;    
    CFS = conv2(CFS,F','same');
end
%----------------------------------------------------------------------
function plotCOEFS(option,varargin)

switch option
    case 'cwt'
        [s1,s2,cfs1,cfs2,scales] = deal(varargin{1:5});
        a1  = subplot(4,2,1);
        plot(s1,'r','Parent',a1); axis tight
        wtitle(getWavMSG('Wavelet:commongui:Str_AnalSig'), ...
            'Parent',a1,'FontSize',10);
        b1  = subplot(4,2,2);
        plot(s2,'r','Parent',b1); axis tight
        wtitle(getWavMSG('Wavelet:commongui:Str_AnalSig'), ...
            'Parent',b1,'FontSize',10);
        a2 = subplot(3,2,3);
        titleSTR =  getWavMSG('Wavelet:cwtft:Str_Modulus');
        imagesc(1:size(cfs1,2),scales,abs(cfs1),'Parent',a2);
        wtitle(titleSTR,'Parent',a2);
        set(a2,'YDir','Normal');
        setYtickValues('scale',scales,a2)
        
        a3 = subplot(3,2,4);
        titleSTR =  getWavMSG('Wavelet:cwtft:Str_Modulus');
        imagesc(1:size(cfs2,2),scales,abs(cfs2),'Parent',a3);
        wtitle(titleSTR,'Parent',a3);
        set(a3,'YDir','Normal');
        setYtickValues('scale',scales,a3)

        a4 = subplot(3,2,5);
        titleSTR =  getWavMSG('Wavelet:cwtft:Str_Angle');
        teta = angle(cfs1);
        imagesc(1:size(cfs1,2),scales,teta,'Parent',a4);
        wtitle(titleSTR,'Parent',a4);
        set(a4,'YDir','Normal');
        setYtickValues('scale',scales,a4)

        a5 = subplot(3,2,6);
        titleSTR =  getWavMSG('Wavelet:cwtft:Str_Angle');
        teta = angle(cfs2);
        imagesc(1:size(cfs2,2),scales,teta,'Parent',a5);
        wtitle(titleSTR,'Parent',a5);
        set(a5,'YDir','Normal');
        setYtickValues('scale',scales,a5)
        
        BigTitle = getWavMSG('Wavelet:cwtft:BigTitleSTR');
        
    case 'wcs'
        [s1,s2,cfs,scales] = deal(varargin{1:4});
        a1  = subplot(4,1,1);
        plot(s1,'r','Parent',a1); hold on
        plot(s2,'b','Parent',a1); 
        axis tight
        wtitle(getWavMSG('Wavelet:cwtft:Analyzed_SIGNALS'),'Parent',a1,'FontSize',10);
        a2 = subplot(3,1,2);
        titleSTR =  getWavMSG('Wavelet:cwtft:Str_Modulus');
        imagesc(1:size(cfs,2),scales,abs(cfs),'Parent',a2);
        wtitle(titleSTR,'Parent',a2);
        ylabel(getWavMSG('Wavelet:cwtft:ylab_Scales'));        
        set(a2,'YDir','Normal');
        setYtickValues('scale',scales,a2)
        
        a4 = subplot(3,1,3);
        titleSTR =  getWavMSG('Wavelet:cwtft:Str_Angle');
        teta = angle(cfs);
        imagesc(1:size(cfs,2),scales,teta,'Parent',a4);
        wtitle(titleSTR,'Parent',a4);
        wxlabel(getWavMSG('Wavelet:cwtft:xlab_Times'),'Parent',a4)
        wylabel(getWavMSG('Wavelet:cwtft:ylab_Scales'),'Parent',a4);
        set(a4,'YDir','Normal');
        setYtickValues('scale',scales,a4)
        
        BigTitle = getWavMSG('Wavelet:divCMDLRF:Wav_Cross_Spec');
end
p1 = get(a1,'Position');
p2 = get(a2,'Position');
w  = 0.5;
x1 = p1(1);
switch option
    case 'cwt'
        p1b = get(b1,'Position');
        x2 = p1b(1)+p1b(3); 
        xM = (x1+x2)/2;
    case 'wcs'
        x2 = p1(1)+p1(3); 
        xM = (x1+x2)/2;
end
xL = xM-w/2;
Y1 = p1(2); Y2 = p2(2)+1.05*p2(4); Y3 = (Y1+Y2)/2-(Y1-Y2)/3.5;
pos = [xL , Y3 , w , 0.035];
FC = get(gcf,'Color');
st = dbstack; name = st(end).name;
if isequal(name,'mdbpublish') , FC = 'w'; end
uicontrol('Style','text','Units','Normalized',...
    'Position',pos,'BackgroundColor',FC, ...
    'FontSize',10,'FontWeight','bold',...
    'String',BigTitle);
pause(0.1);
%----------------------------------------------------------------------
function Plot_angle_MODQUIV(option,s1,s2,scales,CFS_Data,...
    NbArTime,NbArScale,ArSca,QuiverPROP)

switch lower(option)
    case 'phase'   , strTITLE = getWavMSG('Wavelet:cwtft:WCoher_Phase');
    case 'modulus' , strTITLE = getWavMSG('Wavelet:cwtft:WCoher_Modulus_Phase');
end

ax1 = subplot(4,1,1);
pos1 = get(ax1,'Position');
plot(s1,'r'); hold on; plot(s2,'b');
axis tight
wtitle(getWavMSG('Wavelet:cwtft:Analyzed_SIGNALS'),'Parent',ax1,'FontSize',10);
[nS,nT] = size(CFS_Data);
teta = angle(CFS_Data);
ax2  = subplot(2,1,2);
pos2 = [pos1(1) 0.05 pos1(3) pos1(2)-0.2];
set(ax2,'Position',pos2);
switch lower(option)
    case 'modulus'
        Y = 1:nS;
        X = 1:nT;
        imagesc(X,Y,abs(CFS_Data),'Parent',ax2);
    otherwise
        Y = 1:nS;
        X = 1:nT;        
        imagesc(X,Y,teta,'Parent',ax2);
end
cax = caxis;
if abs(cax(1)-cax(2))<0.01
    caxis(ax2,cax + [-0.1 0.1]); 
end
hc = colorbar('SouthOutside');
wtitle(strTITLE,'Parent',ax2,'FontSize',10);

hold on;
if NbArScale>0 && NbArTime>0
    stepS = nS/(NbArScale-1);
    stepT = nT/(NbArTime-1);
    Y = fix(1:stepS:nS);
    X = fix(1:stepT:nT);
    hQUIV = quiver(X',Y',cos(teta(Y,X)),sin(teta(Y,X)), ...
        ArSca,'Parent',ax2);
    set(hQUIV,QuiverPROP{:});
end

set(gcf,'Units','Normalized')
pos = get(hc,'Position');
pos = [pos(1)+pos(3)/4 pos(2)/2 pos(3)/2 pos(4)/2];
set(hc,'Position',pos);
pos2(2) = pos(2)+pos(4)+0.075;
pos2(4) = pos2(4)-pos(4)-0.05;
set(ax2,'Position',pos2,'YDir','Normal');
setYtickValues('index',scales,ax2)
if isequal(lower(option),'phase')
    bkCOL = get(gcf,'Color');
    st = dbstack; name = st(end).name;
    if isequal(name,'mdbpublish') , bkCOL = 'w'; end
    phc = get(hc,'Position');
    mini = round(180*min(teta(:))/pi);
    minSTR = sprintf('%3.0f °',mini);
    maxi = round(180*max(teta(:))/pi);
    maxSTR = sprintf('%3.0f ° ',maxi);
    uicontrol('Style','text','Units','Normalized',...
        'Position',[phc(1) phc(2)+phc(4) 0.1 phc(4)],...
        'HorizontalAlignment','left','BackgroundColor',bkCOL,...
        'String',minSTR);
    uicontrol('Style','text','Units','Normalized',...
        'Position',[phc(1)+phc(3)-0.1 phc(2)+phc(4) 0.1 phc(4)],...
        'HorizontalAlignment','right','BackgroundColor',bkCOL, ...
        'String',maxSTR);
end
%----------------------------------------------------------------------
function setYtickValues(option,scales,axeCUR)

nbTick = 10;
nS = length(scales);
if nS<nbTick , nbTick = nS; end
if isequal(scales,fix(scales))
    step = 1;
    nbL = nS;
    yt = 1:step:nS;
    while nbL>nbTick
        yt = 1:step:nS;
        step = step+1;
        nbL = length(yt);
    end
    ytlab = scales(yt);
    frmt = '%4.0f';
else
    switch option
        case 'index' , yt = linspace(1,nS,nbTick);
        case 'scale' , yt = linspace(scales(1),scales(end),nbTick);
    end
    ytlab = linspace(scales(1),scales(end),nbTick);
    frmt = '%5.1f';
end

ytLab = num2str(ytlab',frmt);
set(axeCUR,...
    'YTick',yt, ...
    'YTickLabel',ytLab, ...
    'YTickLabelMode','manual', ...
    'YTickMode','manual' ...
    );
%----------------------------------------------------------------------
