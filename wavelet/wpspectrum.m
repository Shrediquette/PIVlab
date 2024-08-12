function [spec,times,freqs,tn_Seq] = wpspectrum(wpt,fs,varargin)
%WPSPECTRUM Wavelet packet spectrum.
%   [SPEC,TIMES,FREQS] = WPSPECTRUM(WPT,FS) constructs a matrix 
%   of wavelet packet power spectrum, based on the Wavelet Packet 
%   Transform WPT, where data samples have been sampled at FS  
%   rate. The result is a matrix of coefficients SPEC with  
%   estimates centered on times TIMES and frequencies FREQS.
%   [...] = WPSPECTRUM(WPT) uses FS = 1 as sampling rate. 
% 
%   In addition, [...] = WPSPECTRUM(...,'plot') displays the 
%   wavelet packet spectrum.
% 
%   Moreover, [...,TNFO] = WPSPECTRUM(...) returns in addition the  
%   terminal nodes of the wavelet packet tree ordered in frequential 
%   (i.e. sequential) order.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Feb-2010.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

%-----------------------------------------------------------------
%   ColorMODE is an integer which represents the color mode with:
%       1: 'FRQ : Global + abs'
%       3: 'FRQ : Global
%       5: 'NAT : Global + abs'
%       7: 'NAT : Global
%	[S,F,T,tn] = wpspectrum(wpt,fs,'plot','lf','off','smooth','on');
%-----------------------------------------------------------------

% Check number of input arguments. 
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(1,9);

% Check number of output arguments. 
nargoutchk(0,4)

% Check first input argument. 
if ~isa(wpt,'wptree')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgTyp'));
end

% Check second input argument.
if nargin>1
    if ~(length(fs)==1 && isreal(fs) && fs>0)
        fs = 1; 
    end
else
    fs = 1;
end

% Defaults.
flag_PLOT = false;
nbIN = length(varargin);
axe  = [];
colorMode = [];
LowFreqOff = false;
SmoothOn   = false;

if nbIN>0
    k = 1;
    while k<=nbIN
        ArgNAM = lower(varargin{k});
        if k<nbIN , ArgVAL = lower(varargin{k+1}); end
        k = k+2;
        switch ArgNAM
            case 'plot'   , k = k-1; flag_PLOT = true;
            case 'lf'     , LowFreqOff = ~isequal(lower(ArgVAL),'on');
            case 'smooth' , SmoothOn   = ~isequal(lower(ArgVAL),'off');
            case 'cmode'  , colorMode = ArgVAL;
            otherwise
                error(message('Wavelet:FunctionInput:ArgumentName'));
        end
    end
end
if isempty(colorMode) , colorMode = 1; end

[order,dmax,tn] = get(wpt,'order','depth','tn');
sizes = read(wpt,'tnsizes');
nbtn  = length(tn);
cfs   = read(wpt,'data');
[depths,posis] = ind2depo(order,tn);
[~,tn_Seq,I] = otnodes(wpt);

switch colorMode
    case {1,5} , cfs = abs(cfs);
end
switch colorMode
    case {1,3} , ord = I;
    case {5,7} , ord = 1:length(tn);
end
sizes = max(sizes,[],2);
deb = ones(1,nbtn);
fin = ones(1,nbtn+1);
for k = 1:nbtn
    fin(k)   = deb(k)+sizes(k)-1;
    deb(k+1) = fin(k)+1;
end
nbrows = (2.^(dmax-depths));
NBrowtot = sum(nbrows);
datasize = max(read(wpt,'sizes',0));
NBcoltot = datasize;
spec  = zeros(NBrowtot,NBcoltot);
ypos     = zeros(nbtn,1);
if nbtn>1
    for k = 1:nbtn
        ypos(ord(k)) = sum(nbrows(ord(1:k-1)));
    end
end
ypos = NBrowtot+1-ypos-nbrows;
for k = 1:nbtn
    d = depths(k);
    z = cfs(deb(k):fin(k));
    z2 = z(ones(1,2^d),:);
    vals = wkeep1(z2(:)',NBcoltot);
    r1 = ypos(k);
    r2 = ypos(k)+nbrows(k)-1;
    spec(r1:r2,:) = vals(ones(1,nbrows(k)),:);
    if LowFreqOff && k==1
        spec(r1:r2,:) = NaN;
    end
end
freqs = (1:size(spec,1))*fs/(2*size(spec,1));
times = (0:1:datasize-1)/fs;
if ~flag_PLOT , return; end

% If flag_PLOT is true.
%----------------------
if SmoothOn , spec = smoothCFS(spec,true,3,[]);end
if isempty(axe) , axe = gca; end
flg_line = 5;
if     dmax==flg_line   , lwidth = 0.5;
elseif dmax==flg_line-1 , lwidth = 1;
else                      lwidth = 2;
end
ymin = (ypos-1)/NBrowtot;
ymax = (ypos-1+nbrows)/NBrowtot;
ylim = [0 1];
alfa = 1/(2*NBrowtot);
ydata = [(1-alfa)*ylim(1)+alfa*ylim(2) (1-alfa)*ylim(2)+alfa*ylim(1)];

if NBrowtot==1 , ydata(1) = 1/2; ydata(2) = 1; end
xlim = [1,NBcoltot];
set(axe,'XLim',xlim,'YLim',ylim,'NextPlot','replace');
imgcfs = imagesc(...
    'Parent',axe,            ...
    'XData',1:NBcoltot,      ...
    'YData',ydata,           ...
    'CData',spec,            ...
    'UserData',[depths posis ymin ymax] ...
    );
NBdraw  = 0;
for k = 1:nbtn
    if dmax<=flg_line && nbtn~=1
        line(...
            'Parent',axe,               ...
            'XData',[0.5 NBcoltot+0.5], ...
            'YData',[ymin(k) ymin(k)],  ...
            'LineWidth',lwidth          ...
            );
    end
    NBdraw = NBdraw+1;
    if NBdraw==10 || k==nbtn
        set(imgcfs,'XData',1:NBcoltot,'YData',ydata,'CData',spec);
        NBdraw = 0;
    end
end
XL = get(axe,'XTick');
xlab = num2str((XL/fs)','%3.3f');
if nbtn<2^5
    FtnSize = 10;
elseif nbtn<2^6
    FtnSize = 8;
else
    FtnSize = 6;
end
switch colorMode
    case {1,3}
        YL = get(axe,'YTick');
        ylabSTR = getWavMSG('Wavelet:moreMSGRF:Freq_Hz');
        ylab = num2str((YL(end:-1:1)*fs/2)','%4.2f');
        AxeFtnSize = 10;
        
    case {5,7}
        ytick_NOD = sort((ymin+ymax)/2);
        set(axe,'YTick',ytick_NOD);
        ylabSTR = getWavMSG('Wavelet:divCMDLRF:WPIdx_Natural');
        ylab = int2str(tn(end:-1:1));
        AxeFtnSize = FtnSize;
end
set(axe,'YDir','reverse',       ...
    'layer','top',              ...
    'FontSize',AxeFtnSize,      ... 
    'YtickMode','manual',       ...
    'YTickLabelMode','manual',  ...    
    'XTickLabel',xlab,          ...
    'YTickLabel',ylab,          ...    
    'XLim',xlim,'YLim',ylim,    ...
    'Box','on');
wxlabel(getWavMSG('Wavelet:moreMSGRF:Time_secs'),'Parent',axe,'FontSize',10)
wylabel(ylabSTR,'Parent',axe,'FontSize',10)
wtitle(getWavMSG('Wavelet:moreMSGRF:WP_Dec'),'Parent',axe,'FontSize',10)
colormap(cool(255))
switch colorMode    
    case {1,3}
        ytick_NOD = 1-(ymin+ymax)/2;
        ylab_NOD  = int2str(tn);
        for j = 1:nbtn  
            text(1+0.045,ytick_NOD(j),ylab_NOD(j,:), ...
                'Units','Normalized',...
                'FontSize',FtnSize,'HorizontalAlignment','right'); 
        end
        txtSTR = getWavMSG('Wavelet:divCMDLRF:WPIdx_Frequential');
        text(1+0.075,0.5,txtSTR, ...
                'Units','Normalized', ...
                'HorizontalAlignment','Center','Rotation',-90);
end

%----------------------------------------------------------------------
function CFS = smoothCFS(CFS,flag_SMOOTH,WWSS,WWST)

if ~flag_SMOOTH , return; end
if ~isempty(WWST)
    len = WWST;
    F   = ones(1,len)/len;
    CFS = conv2(CFS,F,'same');
end
if ~isempty(WWSS)
    len = WWSS;
    F   = ones(1,len)/len;    
    CFS = conv2(CFS,F','same');
end
%----------------------------------------------------------------------

