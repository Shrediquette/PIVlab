function varargout = iswt(varargin)
%ISWT Inverse discrete stationary wavelet transform 1-D.
%   ISWT performs a multilevel 1-D stationary wavelet
%   reconstruction using either a specific orthogonal wavelet
%   ('wname', see WFILTERS for more information) or specific
%   reconstruction filters (Lo_R and Hi_R).
%
%   X = ISWT(SWC,'wname') or X = ISWT(SWA,SWD,'wname')
%   or X = ISWT(SWA(end,:),SWD,'wname') reconstructs the
%   signal X based on the multilevel stationary wavelet
%   decomposition structure SWC or [SWA,SWD] (see SWT).
%
%   For X = ISWT(SWC,Lo_R,Hi_R) or X = ISWT(SWA,SWD,Lo_R,Hi_R),
%   or X = ISWT(SWA(end,:),SWD,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%
%   See also IDWT, SWT, WAVEREC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Dec-97.
%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(2,4);
nargoutchk(0,1);

coder.extrinsic('wavemngr','wfilters');

% Convert any strings in varargin to char arrays
temp_parseinputs = cell(1,nargin);
[temp_parseinputs{:}] = convertStringsToChars(varargin{:});

nbIn = nargin;

switch nbIn
    case 2 
        argstr = 1;
        argnum = 2;
    case 4 
        argstr = 0; 
        argnum = 3;
    case 3
        if ischar(temp_parseinputs{3})
            argstr = 1; argnum = 3;
        else
            argstr = 0; argnum = 2;
        end
end

% Compute reconstruction filters.
if argstr && ischar(temp_parseinputs{argnum})
    wtype = coder.const(@wavemngr,'type',varargin{argnum});
    if ~any(wtype == [1 2])
        coder.internal.error('Wavelet:FunctionInput:OrthorBiorthWavelet');
    end
    [lo_R,hi_R] = coder.const(@wfilters,varargin{argnum},'r');
else
    
    coder.internal.assert(~(nargin < argnum+1),'Wavelet:FunctionInput:InvalidLoHiFilters');
    
    lo_R = temp_parseinputs{argnum};
    hi_R = temp_parseinputs{argnum+1};
    
    validateattributes(lo_R,{'numeric'},...
        {'vector','finite','real'},'iswt','Lo_R',argnum);
    validateattributes(hi_R,{'numeric'},...
        {'vector','finite','real'},'iswt','Hi_R',argnum+1);
    
    % The filters must have an even length greater than 2.
    if (length(lo_R) < 2) || (length(hi_R) < 2) || ...
            signalwavelet.internal.isodd(length(lo_R)) ...
            || signalwavelet.internal.isodd(length(hi_R))
        coder.internal.error('Wavelet:FunctionInput:Invalid_Filt_Length');
    end
end

% Get inputs.
if argnum == 2
    validateattributes(varargin{1}, {'numeric'}, {'2d', 'real', ...
        'nonempty','finite'}, 'iswt', 'SWC', 1);
    p = size(temp_parseinputs{1},1);
    n = p-1;
    d = temp_parseinputs{1}(1:n,:);
    a = temp_parseinputs{1}(p,:);
else
    validateattributes(temp_parseinputs{1}, {'numeric'}, {'2d', 'real', ...
        'nonempty','finite'}, 'iswt', 'SWA', 1);
    validateattributes(temp_parseinputs{2}, {'numeric'}, {'2d', 'real', ...
        'nonempty','finite'}, 'iswt', 'SWD', 2);
    a = temp_parseinputs{1};
    d = temp_parseinputs{2};
    coder.internal.errorIf(size(a,2) ~= size(d,2),...
        'Wavelet:FunctionInput:InvSWTCSize',size(a,2),size(d,2));
end

a = a(size(a,1),:);
[n,lx] = size(d);
for k = n:-1:1
    step = 2^(k-1);
    last = step;
    for first = 1:last
        ind = first:step:lx;
        lon = length(ind);
        subind = ind(1:2:lon);
        x1 = idwtLOC(a(subind),d(k,subind),lo_R,hi_R,lon,0);
        subind = ind(2:2:lon);
        x2 = idwtLOC(a(subind),d(k,subind),lo_R,hi_R,lon,-1);
        a(ind) = 0.5*(x1+x2);
    end
end
varargout{1} = a;

%===============================================================%
% INTERNAL FUNCTIONS
%===============================================================%
function y = idwtLOC(a,d,lo_R,hi_R,lon,shift)

y = upconvLOC(a,lo_R,lon) + upconvLOC(d,hi_R,lon);
if shift==-1
    y = y([end,1:end-1]);
end
%---------------------------------------------------------------%
function y = upconvLOC(x,f,l)

lf = length(f);
y  = dyadup(x,0,1);
y  = wextend('1D','per',y,lf/2);
y  = wconv1(y,f);
y  = wkeep1(y,l,lf);
%===============================================================%
