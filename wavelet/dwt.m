function [a,d] = dwt(x,varargin)
%DWT Single-level discrete 1-D wavelet transform.
%   DWT performs a single-level 1-D wavelet decomposition
%   with respect to either a particular wavelet ('wname',
%   see WFILTERS for more information) or particular wavelet filters
%   (Lo_D and Hi_D) that you specify.
%
%   [CA,CD] = DWT(X,'wname') computes the approximation
%   coefficients vector CA and detail coefficients vector CD,
%   obtained by a wavelet decomposition of the vector X.
%   'wname' is a character vector containing the wavelet name.
%
%   [CA,CD] = DWT(X,Lo_D,Hi_D) computes the wavelet decomposition
%   as above given these filters as input:
%   Lo_D is the decomposition low-pass filter.
%   Hi_D is the decomposition high-pass filter.
%   Lo_D and Hi_D must be the same length and have an even number of
%   samples.
%
%   Let LX = length(X) and LF = the length of filters; then
%   length(CA) = length(CD) = LA where LA = CEIL(LX/2),
%   if the DWT extension mode is set to periodization.
%   LA = FLOOR((LX+LF-1)/2) for the other extension modes.  
%   For the different signal extension modes, see DWTMODE. 
%
%   [CA,CD] = DWT(...,'mode',MODE) computes the wavelet 
%   decomposition with the extension mode MODE you specify.
%   MODE is a character vector containing the extension mode.
%
%   Example:
%     x = 1:8;
%     [ca,cd] = dwt(x,'db1','mode','sym')
%
%   See also DWTMODE, IDWT, WAVEDEC, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.


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
    % Check if the filters are single-precision
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

% Check arguments for Extension and Shift.
DWT_Attribute = getappdata(0,'DWT_Attribute');
if isempty(DWT_Attribute) , DWT_Attribute = dwtmode('get'); end
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
% Code generation is on a separate path
% Cannot simply cast "like",x here or even real(x) because x may be integer
% type.
isSingle = isUnderlyingType(x,'single');
% If the data is single and the filters are not, cast the filters to
% single. 
if isSingle && ~filterSingle
    Lo_D = cast(Lo_D,'single');
    Hi_D = cast(Hi_D,'single');
end

% Extend, Decompose &  Extract coefficients.
first = 2-shift;
flagPer = isequal(dwtEXTM,'per');
if ~flagPer
    lenEXT = lf-1; 
    last = lx+lf-1;
else
    lenEXT = lf/2; 
    last = 2*ceil(lx/2);
end

y = wextend('1D',dwtEXTM,x,lenEXT);

% Compute coefficients of approximation.
z = wconv1(y,Lo_D,'valid'); 
a = z(first:2:last);

% Compute coefficients of detail.
z = wconv1(y,Hi_D,'valid'); 
d = z(first:2:last);
