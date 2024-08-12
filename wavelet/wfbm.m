function fBm = wfbm(H,L,varargin)
%WFBM Synthesize fractional Brownian motion.
%   FBM = WFBM(H,L) returns a fractional Brownian
%   motion signal (fBm) of parameter H (0 < H < 1) and
%   length L, following the algorithm proposed by Abry 
%   and Sellan.
%
%   FBM = WFBM(H,L,'plot') generates and plots the fBm
%   signal.
%
%   FBM = WFBM(H,L,NS,W) or FBM = WFBM(H,L,W,NS)
%   returns the fBm using NS reconstruction steps 
%   and the sufficiently regular orthogonal wavelet 
%   which name is W.
%
%   WFBM(H,L,'plot',NS) or WFBM(H,L,'plot',W) or
%   WFBM(H,L,'plot',NS,W) or WFBM(H,L,'plot',W,NS)
%   generates and plots the fBm signal.
%
%   WFBM(H,L) is equivalent to WFBM(H,L,6,'db10').
%   WFBM(H,L,NS) is equivalent to WFBM(H,L,NS,'db10').
%   WFBM(H,L,W) is equivalent to WFBM(H,L,W,6).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Dec-1996.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(2,5)

% Internal parameters.
%---------------------
delta 	= 10;	% sampling period to extract a "good" fBm
			    % Caution : for extreme values of H, a greater
			    % value of delta can be needed
			
prec	= 1E-4;	% precision for the terms of fs1 and gs1 sequences   

% Default values.
%----------------
nblev = 6; wname = 'db10'; plot_flag = 0;
if nargin>2
    if	~ischar(varargin{1})
        nblev = varargin{1};
        if nargin>3
            if ~isequal(varargin{2},'plot')
                wname = varargin{2};
                if nargin>4 , plot_flag = 1; end
            else
                plot_flag = 1;
            end
        end
    elseif isequal(varargin{1},'plot')
        plot_flag = 1;
        if nargin>3
            if ~ischar(varargin{2})
                nblev = varargin{2};
                if nargin>4 , wname = varargin{3}; end
            else
                wname = varargin{2};
                if nargin>4 , nblev = varargin{3}; end
            end
        end
    else
        wname = varargin{1};
        if nargin>3
            if ~ischar(varargin{2})
                nblev = varargin{2};
                if nargin>4 , plot_flag = 1; end
            else
                if isequal(varargin{2},'plot')
                    plot_flag = 1;
                end
                if nargin>4 , nblev = varargin{3}; end
            end
        end
    end
end

% Checking input parameter values.
%---------------------------------
if ~isnumeric(H) || H < 0 || H > 1 || isnan(H)
    error(message('Wavelet:FunctionArgVal:Invalid_FractIdx'));
end
if ~isequal(L,fix(L)) || L < 100 || isnan(L)
    error(message('Wavelet:FunctionArgVal:Invalid_SigLen'));
end
if ~isequal(nblev,fix(nblev)) || nblev < 2 || isnan(nblev)
    error(message('Wavelet:FunctionArgVal:Invalid_NbLev'));
end
wtype = wavemngr('type',wname);
if ~ischar(wname) || ~isequal(wtype,1)
    error(message('Wavelet:FunctionArgVal:Must_OrthWav'));
end

% Compute internal length.
%-------------------------
L = delta*L;

% Intermediate variables.
%------------------------
s = H+1/2;
d = H-1/2;

% Reconstruction filters.
%------------------------
[lo_R,hi_R] = wfilters(wname,'r');

% Fractional coefficients.
%-------------------------
ckalpha	= alphacfs(d,prec);
ckbeta	= betacfs(d,prec);

% Sequences fs1 and gs1.
%-----------------------
fs1 = conv(ckalpha,lo_R);
fs1 = sqrt(2)*2^(-s)*conv(fs1,[1 1]);
gs1 = conv(ckbeta,hi_R);
gs1 = sqrt(2)*2^(s)*cumsum(gs1);

% Number of starting points.
%---------------------------
nbmax  = max([length(fs1),length(gs1)]);
nbInit = ceil(L/2^(nblev));
len    = nbmax+nbInit;

% Adjust Filters.
%----------------
fs1 = [fs1 , zeros(1,nbmax-length(fs1))];
gs1 = [gs1 , zeros(1,nbmax-length(gs1))];

% Computation of the fBm signal.
%-------------------------------
tmp = conv(randn(1,len+nbmax),ckbeta);
tmp = cumsum(tmp);
CA  = wkeep(tmp,len,'c');
for j=0:nblev-1
    CD  = 2^(j/2)*4^(-s)*2^(-j*s)*randn(1,len);
    len = 2*len-nbmax;
    CA  = idwt(CA,CD,fs1,gs1,len);
end
fBm  = wkeep(CA,L,'c');
fBm  = fBm-fBm(1);

% Final sampling.
%----------------
fBm  = fBm(1:delta:end);

% Optional plot.
%---------------
if plot_flag
    tfBm = 1:length(fBm);
    plot(tfBm,fBm);
    title(['fractional Brownian motion - parameter: ',num2str(H)]);
    set(gca,'XLim',[min(tfBm) max(tfBm)]);
end

%======================================================%
% INTERNAL FUNCTIONS
%======================================================%

function cka = alphacfs(alpha,prec)
%
% Convergence: -1/2 < alpha <1/2
% Vectorized function

if abs(alpha)<eps , cka = [1 0]; return; end
I   = 1:1000;
cka = gamma(alpha+1)./(gamma(I).*gamma(alpha+2-I));
I   = find(abs(cka)<=prec);
if isempty(I) , cka = [1 0]; return; end
cka = cka(1:I(1));
%------------------------------------------------------%

function ckb = betacfs(alpha,prec)
%
% Convergence: -1/2 < alpha <1/2
% beta(k,d) = (-1)^k cka(k,-d)
% Vectorized function

if abs(alpha)<eps , ckb = [1 0]; return; end
I   = 1:1000;
ckb = gamma(I-1+alpha)./(gamma(alpha)*gamma(I));
I   = find(abs(ckb)<=prec);
if isempty(I) , ckb = [1 0]; return; end
ckb = ckb(1:I(1));
%------------------------------------------------------%

%======================================================%
