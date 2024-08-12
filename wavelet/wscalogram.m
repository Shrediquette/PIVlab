function S = wscalogram(typePLOT,coefs,varargin)
%WSCALOGRAM Scalogram for continuous wavelet transform.
%   SC = WSCALOGRAM(TYPEPLOT,COEFS) computes the scalogram 
%   SC (percentage of energy for each coefficient). COEFS is
%   the matrix of continuous wavelet coefficients (see CWT).
%   The scalogram is obtained by computing:
%       S = abs(coefs.*coefs); SC = 100*S./sum(S(:))
%  
%   When typePLOT is equal to 'image', a scaled image of
%   scalogram is displayed, when TYPEPLOT is equal to 'contour', 
%   a contour representation of scalogram is displayed.
%   Otherwise the scalogram is returned without plot 
%   representation. 
%
%   SC = WSCALOGRAM(...,'PropNAME',PropVAL,...)
%   Available values for 'PropNAME' are: 
%       - 'scales': scales used for CWT
%       - 'ydata':  signal used for CWT 
%       - 'xdata':  x values corresponding to signal
%       - 'power':  (positive) real value
%   
%   The default value for 'power' is zero. if power>0,
%   the coefficients are normalized: 
%       coefs(k,:) = coefs(k,:)/(scales(k)^power)
%   then the scalogram is computed as explained above.
%
%   Examples of valid uses are:
%     wname = 'mexh';
%     scales = (1:128);
%     load cuspamax
%     signal = cuspamax;
%     coefs = cwt(signal,scales,wname);
%     figure; SCimg = wscalogram('image',coefs);
%     figure; SCcnt = wscalogram('contour',coefs);
%     figure; SCimg = wscalogram('image',coefs,'scales',scales,'ydata',signal);
%     figure; SCcnt = wscalogram('contour',coefs,'scales',scales,'ydata',signal);
%
%   See also CWT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Jan-2007.
%   Last Revision: 02-Feb-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Convert string to char array
if isStringScalar(typePLOT)
    typePLOT = convertStringsToChars(typePLOT);
end

if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbIN = nargin;
narginchk(2,10);
nb_SCALES = size(coefs,1);
nbIN = nbIN-2;
flagSIG = false;
flagXDATA = false;
power = 0;
scales = 1:nb_SCALES;
nbcl = 10;

if nbIN>0
    firstIN = nbIN+1;
    if isnumeric(varargin{1})
        scales = varargin{1};
        if nbIN>1
            if isnumeric(varargin{2})
                SIG = varargin{2};
                flagSIG = true;
                if nbIN>2
                    if isnumeric(varargin{3})
                        xSIG = varargin{3};
                        flagXDATA = true;
                        if nbIN>3
                            if isnumeric(varargin{4})
                                power = varargin{4};
                            else
                                firstIN = 4;
                            end
                        end
                    else
                        firstIN = 3;
                    end
                end
            else
                firstIN = 2;
            end
        end
    else
        firstIN = 1;
    end
    for k = firstIN:2:nbIN
        argNAM = varargin{k};
        switch argNAM
            case 'scales' , scales = varargin{k+1};
            case 'ydata'  , SIG = varargin{k+1}; flagSIG = true;
            case 'xdata'  , xSIG = varargin{k+1}; flagXDATA = true;
            case 'power'  , power = varargin{k+1};
            case 'nbcl'   , nbcl = varargin{k+1};
        end
    end
end
if flagSIG && ~flagXDATA , xSIG = 1:length(SIG); end

% Compute scalogram.
if power>0
    for k=1:size(coefs,1)
        coefs(k,:) = coefs(k,:)/scales(k)^power;
    end
end
S = abs(coefs.*coefs);
S = 100*S./sum(S(:));

switch typePLOT
    case {'image','contour','surface'}
    otherwise , return;
end

% Plot scalogram.
if flagSIG
    axeAct = subplot(4,1,1);
    plot(xSIG,SIG,'r','Parent',axeAct);
    title(getWavMSG('Wavelet:commongui:Str_AnalSig'),'Parent',axeAct);
    axis tight
    set(axeAct,'XLim',[xSIG(1) xSIG(end)],'Tag','SIG_Axes');
    currFig = get(axeAct,'Parent');
    axeAct_CFS = wfindobj(currFig,'Type','axes','Tag','CFS_Axes');
    if isempty(axeAct_CFS)
        pos_axeAct = get(axeAct,'Position');
        pos_axeAct(2) = 0.1; 
        pos_axeAct(4) = 3.2*pos_axeAct(4);
        axeAct = axes('Position',pos_axeAct,'Tag','CFS_Axes');
    else
        axeAct = axeAct_CFS;
        reset(axeAct);
    end
else
    axeAct = subplot(1,1,1);
    pos_axeAct = get(axeAct,'Position');
    pos_axeAct(4) = 0.95*pos_axeAct(4);
    set(axeAct,'Position',pos_axeAct);
end

nb     = ceil(nb_SCALES/20);
ytics  = 1:nb:nb_SCALES;
tmp    = scales(1:nb:nb*length(ytics));
ylabs  = num2str(tmp(:));
if flagSIG , xdata = xSIG; else xdata = 1:size(coefs,2); end

switch typePLOT
    case 'image'   , imagesc(S,'XData',xdata,'Parent',axeAct);
    case 'contour' , contour(S,nbcl,'XData',xdata,'Parent',axeAct);
    case 'surface' , surf(S,'Parent',axeAct); shading interp; axis tight
end
set(axeAct, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Tag','CFS_Axes', ...
        'Box','On' ...
        );
titleSTR =  getWavMSG('Wavelet:divGUIRF:WSCAL_PerEner');
title(titleSTR,'Parent',axeAct);
xlabel(getWavMSG('Wavelet:divCMDLRF:TimeORSpace'),'Parent',axeAct);
ylabel(getWavMSG('Wavelet:divCMDLRF:Scales_a'),'Parent',axeAct);
pos = get(axeAct,'Position');
pos(1) = pos(1)+pos(3)+0.025;
pos(3) = 0.02;
colorbar('peer',axeAct,'EastOutside','FontSize',8,'Position',pos);
