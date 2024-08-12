function [a,d] = dwt(x,varargin)
%DWT Single-level discrete 1-D wavelet transform on the GPU.
%
%   [CA,CD] = DWT(X,'wname')
%   [CA,CD] = DWT(X,Lo_D,Hi_D)
%   [CA,CD] = DWT(...,'mode',MODE)
%
%   LIMITATION:
%   MODE must be either "sym" or "per", other modes will fall back to
%   "per".

%   Copyright 2019-2020 The MathWorks, Inc.

filterSingle = false;
% Check arguments.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbIn = nargin;
narginchk(2,7);

validateattributes(x,{'numeric'},{'vector','finite'},'dwt','X');

if ischar(varargin{1})
    [Lo_D,Hi_D] = wfilters(varargin{1},'d'); 
    next = 2;
else
    if nargin < 3
        error(message('Wavelet:FunctionInput:InvalidLoHiFilters'));
    end
    Lo_D = varargin{1};
    Hi_D = varargin{2};
    filterSingle = isUnderlyingType(Lo_D,'single') && ...
        isUnderlyingType(Hi_D,'single');
    next = 3;
    
    validateattributes(Lo_D,{'numeric'},...
        {'vector','finite','nonempty','real'},'dwt','Lo_D');
    validateattributes(Hi_D,{'numeric'},...
        {'vector','finite','nonempty','real'},'dwt','Hi_D');
    TFodd = signalwavelet.internal.isodd(length(Lo_D));
    if TFodd || (length(Lo_D) ~= length(Hi_D))
        error(message('Wavelet:FunctionInput:Invalid_Filt_Length'));
    end
end

isSingle = isUnderlyingType(x,'single');
if isSingle && ~filterSingle
    Lo_D = cast(Lo_D,'single');
    Hi_D = cast(Hi_D,'single');
end

if ~isa(x,"gpuArray") && ~isa(Lo_D,"gpuArray") && ~isa(Hi_D,"gpuArray")
    % Decision to run on CPU if X or filters not on GPU
    [varargin{:}] = gather(varargin{:}); % Gather all extra arguments
    [a,d] = dwt(x,varargin{:});
    return;
else
    x = gpuArray(x);
    Lo_D = gpuArray(Lo_D);
    Hi_D = gpuArray(Hi_D);
end

% Check arguments for Extension and Shift.
DWT_Attribute = getappdata(0,'DWT_Attribute');
if isempty(DWT_Attribute)
    DWT_Attribute = dwtmode('get'); 
end
dwtEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift1D; % Default: Shift.
for k = next:2:nbIn-1
    switch varargin{k}
        case 'mode'
            dwtEXTM = varargin{k+1};
        case 'shift'
            shift   = mod(varargin{k+1},2);
            validateattributes(shift,...
                {'numeric'},...
                {'integer','scalar','nonempty','>=',0, '<=', 1},...
                'dwt','SHIFT');
    end
end

% Compute sizes and shape.
lf = length(Lo_D);
lx = length(x);

% Extend, Decompose &  Extract coefficients.
first = 2-shift;

if dwtEXTM ~= "per"
    lenEXT = lf-1;
    last = lx+lf-1;
    dwtEXTM = "sym"; % If the mode is not per, it is made sym
else
    lenEXT = lf/2;
    last = 2*ceil(lx/2);
end

y = wextend('1D',dwtEXTM,x,lenEXT);

S = substruct('()',{matlab.internal.ColonDescriptor(first,2,last)});

% Compute coefficients of approximation.
z = wconv1(y,Lo_D,'valid'); 
a = subsref(z,S);

% Compute coefficients of detail.
z = wconv1(y,Hi_D,'valid'); 
d = subsref(z,S);
