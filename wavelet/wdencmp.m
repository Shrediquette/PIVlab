function [xc,cxc,lxc,perf0,perfl2] = wdencmp(o,varargin)
%WDENCMP De-noising or compression using wavelets.
%   WDENCMP performs a de-noising or compression process
%   of a signal or an image using wavelets.
%
%   [XC,CXC,LXC,PERF0,PERFL2] =
%   WDENCMP('gbl',X,'wname',N,THR,SORH,KEEPAPP)
%   returns a de-noised or compressed version XC of input
%   signal X (1-D or 2-D) obtained by wavelet coefficients
%   thresholding using global positive threshold THR.
%   Additional output arguments [CXC,LXC] are the
%   wavelet decomposition structure of XC,
%   PERFL2 and PERF0 are L^2 recovery and compression
%   scores in percentages.
%   PERFL2 = 100*(vector-norm of CXC/vector-norm of C)^2
%   where [C,L] denotes the wavelet decomposition structure
%   of X.
%   Wavelet decomposition is performed at level N and
%   'wname' is a string containing the wavelet name.
%   SORH ('s' or 'h') is for soft or hard thresholding
%   (see WTHRESH for more details).
%   If KEEPAPP = 1, approximation coefficients cannot be
%   thresholded, otherwise it is possible.
%
%   WDENCMP('gbl',C,L,W,N,THR,SORH,KEEPAPP)
%   has the same output arguments, using the same
%   options as above, but obtained directly from the
%   input wavelet decomposition structure [C,L] of the
%   signal to be de-noised or compressed, at level N,
%   using  'wname' wavelet.
%
%   For 1-D case and 'lvd' option:
%   WDENCMP('lvd',X, 'wname',N,THR,SORH) or
%   WDENCMP('lvd',C,L, 'wname',N,THR,SORH)
%   have the same output arguments, using the same
%   options as above, but allowing level-dependent
%   thresholds contained in vector THR (THR must be of
%   length N). In addition, the approximation is kept.
%
%   For 2-D case and 'lvd' option:
%   WDENCMP('lvd',X, 'wname',N,THR,SORH) or
%   WDENCMP('lvd',C,L, 'wname',N,THR,SORH)
%   THR must be a matrix 3 by N containing the level
%   dependent thresholds in the three orientations
%   horizontal, diagonal and vertical.
%
%   See also DDENCMP, WAVEDEC, WAVEDEC2, WDEN, WPDENCMP, WTHRESH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments and set problem dimension.
if nargin > 0
    o = convertStringsToChars(o);
end

% This will allow vector strings
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

dim = 1;        % initialize dimension to 1D.
nbIn  = nargin;
nbOut = nargout;
switch o
    case 'gbl' 
        minIn = 7; 
        maxIn = 8;
    case 'lvd' 
        minIn = 6; 
        maxIn = 7;
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
narginchk(minIn,maxIn);
okOut = [0:1 3:5];
if ~any(okOut==nbOut)
    error(message('Wavelet:FunctionOutput:Invalid_ArgNum'));
end

if nbIn == minIn
    x = varargin{1}; indarg = 2;
    if min(size(x))~=1, dim = 2; end
else
    c = varargin{1}; l = varargin{2}; indarg = 3;
    if min(size(l))~=1, dim = 2; end
end

% Get Inputs
w    = varargin{indarg};
n    = varargin{indarg+1};
thr  = varargin{indarg+2};
sorh = varargin{indarg+3};
if strcmp(o,'gbl') , keepapp = varargin{indarg+4}; end

if errargt(mfilename,w,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,n,'int')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,thr,'re0')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
if errargt(mfilename,sorh,'str')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% Wavelet decomposition of x (if not given).
if (strcmp(o,'gbl') && nbIn==7)  || (strcmp(o,'lvd') && nbIn==6)
    if dim == 1
        [c,l] = wavedec(x,n,w);
    else
        [c,l] = wavedec2(x,n,w);
    end
end

% Wavelet coefficients thresholding.
if strcmp(o,'gbl')
    if keepapp
        % keep approximation.
        cxc = c;
        if dim == 1
            inddet = l(1)+1:length(c);
        else
            inddet = prod(l(1,:))+1:length(c);
        end
        % threshold detail coefficients.
        cxc(inddet) = wthresh(c(inddet),sorh,thr);
    else
        % threshold all coefficients.
        cxc = wthresh(c,sorh,thr);
    end
else
    if dim == 1, cxc = wthcoef('t',c,l,1:n,thr,sorh);
    else
        cxc = wthcoef2('h',c,l,1:n,thr(1,:),sorh);
        cxc = wthcoef2('d',cxc,l,1:n,thr(2,:),sorh);
        cxc = wthcoef2('v',cxc,l,1:n,thr(3,:),sorh);
    end
end
lxc = l;

% Wavelet reconstruction of xd.
if dim == 1
    xc = waverec(cxc,lxc,w);
else
    xc = waverec2(cxc,lxc,w);
end

if nbOut<4 , return; end

% Compute compression score.
perf0 = 100*(length(find(cxc==0))/length(cxc));
if nbOut<5 , return; end

% Compute L^2 recovery score.
nc = norm(c);
if nc<eps
    perfl2 = 100;
else
    perfl2 = 100*((norm(cxc)/nc)^2);
end
