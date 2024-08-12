function lev = wmaxlev(sizeX,wname)
%WMAXLEV Maximum wavelet decomposition level.
%   WMAXLEV can help you avoid unreasonable maximum level value.
%
%   L = WMAXLEV(S,'wname') returns the maximum level
%   decomposition of signal or image of size S using the wavelet
%   named in the string 'wname' (see WFILTERS for more information).
%   S must be a vector with positive integer elements. The maximum
%   level is not defined when any dimension is zero-length. 
%
%   WMAXLEV gives the maximum allowed level decomposition,
%   but in general, a smaller value is taken.
%   Usual values are 5 for the 1-D case, and 3 for the 2-D case.
%
%   See also WAVEDEC, WAVEDEC2, WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(2,2);
% Handle string input for wname
if isStringScalar(wname)
    wname = convertStringsToChars(wname);
end
validateattributes(sizeX, {'numeric'}, ...
    {'vector', 'positive', 'nonempty', 'integer'}, ...
    'wmaxlev', 'S');

if (numel(sizeX)>3)
    error(message('Wavelet:FunctionInput:InvalidSizeVector'));
end

if length(sizeX)==1
    lx = sizeX;
elseif (length(sizeX)==2)&&(min(sizeX)==1)
    % columns or rows, choose the non-singular dimension
    lx = max(sizeX);
elseif length(sizeX)==3
    % for images, choose the smaller of the x and y dimension
    if sizeX(3) > 3
        error(message('Wavelet:FunctionInput:InvalidImageType'));
    end
    lx = min(sizeX(1:2));
else
    lx = min(sizeX);
end

wname = deblankl(wname);
[wtype,bounds] = wavemngr('fields',wname,'type','bounds');
switch wtype
    case {1,2}
        Lo_D = wfilters(wname);
        lw = length(Lo_D);
    case {3,4,5}
        lw = bounds(2)-bounds(1)+1;
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% the rule is the last level for which at least one coefficient 
% is correct : (lw-1)*(2^lev) < lx

lev = fix(log2(lx/(lw-1)));
if lev<1
    lev = 0;
end
