function [a,h,v,d] = dwt2(x,varargin)
%DWT2 Single-level discrete 2-D wavelet transform on the GPU.
%   [CA,CH,CV,CD] = DWT2(X,'wname')
%   [CA,CH,CV,CD] = DWT2(X,Lo_D,Hi_D)
%   [CA,CH,CV,CD] = DWT2(...,'mode',MODE)
%
%   LIMITATION:
%   MODE must be either "sym" or "per", other modes will fall back to
%   "per".

%   Copyright 2020 The MathWorks, Inc.

validateattributes(x,{'numeric','logical'},{'nonempty','3d'},'dwt2','X');
[m,n,p] = size(x);
if p ~= 1 && p~=3
    error(message('Wavelet:FunctionInput:Invalid3D',p));
end

% Check arguments.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbIn = nargin;
narginchk(2,7);
if ischar(varargin{1})
    [Lo_D,Hi_D] = wfilters(varargin{1},'d');
    next = 2;
else
    Lo_D = varargin{1};
    Hi_D = varargin{2};
    next = 3;
    validateattributes(Lo_D,{'numeric'},...
        {'vector','finite','nonempty','real'},'dwt2','Lo_D');
    validateattributes(Hi_D,{'numeric'},...
        {'vector','finite','nonempty','real'},'dwt2','Hi_D');
    TFodd = signalwavelet.internal.isodd(length(Lo_D));
    if TFodd || (length(Lo_D) ~= length(Hi_D))
        error(message('Wavelet:FunctionInput:Invalid_Filt_Length'));
    end
end

if ~isa(x,"gpuArray") && ~isa(Lo_D,"gpuArray") && ~isa(Hi_D,"gpuArray")
    % Decision to run on CPU if X or filters not on GPU
    [varargin{:}] = gather(varargin{:}); % Gather all extra arguments
    [a,h,v,d] = dwt2(x,varargin{:});
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
shift   = DWT_Attribute.shift2D; % Default: Shift.
for k = next:2:nbIn-1
    switch varargin{k}
        case 'mode' 
            dwtEXTM = varargin{k+1};
        case 'shift'
            shift   = mod(varargin{k+1},2);
    end
end

validateattributes(shift,{'numeric'},{'integer','row','ncols', 2, '>=', 0, '<=', 1},'dwt2','shift');

% Compute sizes.
lf = length(Lo_D);
sx = [m n];

% Extend, Decompose &  Extract coefficients.
first = 2-shift;

if dwtEXTM ~= "per"
    sizeEXT = lf-1;
    last = sx+lf-1;
    dwtEXTM = "sym"; % If the mode is not per, it is made sym
else
    sizeEXT = lf/2;
    last = 2*ceil(sx/2);
end

x = double(x);

if p ~= 3
    [a,h,v,d] = implDwt2(x, Lo_D, Hi_D, dwtEXTM, sizeEXT, first, last);
else
    a = cell(0,3);
    h = cell(0,3);
    v = cell(0,3);
    d = cell(0,3);
    for k = 1:3
        S = substruct('()',{':',':',k});        
        [a{k},h{k},v{k},d{k}] = implDwt2(subsref(x,S), Lo_D, Hi_D, dwtEXTM, sizeEXT, first, last);
    end
    a = cat(3,a{:});
    h = cat(3,h{:});
    v = cat(3,v{:});
    d = cat(3,d{:});
end
end
%-------------------------------------------------------%
% Internal Function(s)
%-------------------------------------------------------%
function [a,h,v,d] = implDwt2(x, Lo_D, Hi_D, dwtEXTM, sizeEXT, first, last)
y = wextend('addcol',dwtEXTM,x,sizeEXT);
z = conv2(y,reshape(Lo_D,1,[]),'valid');

S = substruct('()',{':',matlab.internal.ColonDescriptor(first(2),2,last(2))});
z = subsref(z,S);
z = wextend('addrow',dwtEXTM,z,sizeEXT);

a = convdown(z,Lo_D,first,last);
h = convdown(z,Hi_D,first,last);

z = conv2(y,reshape(Hi_D,1,[]),'valid');

z = subsref(z,S);
z = wextend('addrow',dwtEXTM,z,sizeEXT);

v = convdown(z,Lo_D,first,last);
d = convdown(z,Hi_D,first,last);
end

function y = convdown(y,F,first,last)
y = conv2(y',reshape(F,1,[]),'valid');
S = substruct('()',{matlab.internal.ColonDescriptor(first(1),2,last(1)),':'});
y = subsref(y',S);
end