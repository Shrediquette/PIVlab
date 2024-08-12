function varargout = wavsupport(wname)
%WAVSUPPORT Wavelet support.
%   [LB,UB] = WAVSUPPORT(WNAME) returns the lower and upper   
%   bounds of support of the WNAME wavelet.
%   For wavelets of type 3, 4 and 5 (see WAVEMNGR) specify 
%   lower and  upper bounds of effective support.
%   For wavelets of type 1 and 2 (orthogonal and biorthogonal 
%   wavelets) LB and UB are given by LB = -0.5*(LF-1) and 
%   UB = 0.5*(LF-1) where LF is the length of the filters.
%   B = WAVSUPPORT(WNAME) returns a vector containing
%   LB and UB.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Feb-2010.
%   Last Revision: 04-Mar-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if isStringScalar(wname)
    wname = convertStringsToChars(wname);
end
wparams = wavemngr('fields',wname);
bounds = wparams.bounds;
switch wparams.type
    case {1,2}
        LoD = wfilters(wname);
        bounds = [0 length(LoD)-1];
end
bounds = bounds-sum(bounds)/2;
switch nargout
    case 1 , varargout{1} = bounds;
    case 2 , varargout{1} = bounds(1); varargout{2} = bounds(2);
end
