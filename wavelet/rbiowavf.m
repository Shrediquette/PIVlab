function [Rf,Df] = rbiowavf(wname)
%RBIOWAVF Reverse Biorthogonal spline wavelet filters.
%   [RF,DF] = RBIOWAVF(W) returns two scaling filters
%   associated with the biorthogonal wavelet specified
%   by the string W.
%   W = 'rbioNd.Nr' where possible values for Nd and Nr are:
%       Nd = 1  Nr = 1 , 3 or 5
%       Nd = 2  Nr = 2 , 4 , 6 or 8
%       Nd = 3  Nr = 1 , 3 , 5 , 7 or 9
%       Nd = 4  Nr = 4
%       Nd = 5  Nr = 5
%       Nd = 6  Nr = 8
%   The output arguments are filters:
%   RF is the reconstruction filter
%   DF is the decomposition filter
%
%   See also WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-1998
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Find Number.
%-------------
if nargin > 0
    wname = convertStringsToChars(wname);
end

kdot = find(wname=='.');
if length(kdot)~=1
    error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
lw    = length(wname);
Nr    = wname(kdot+1:lw);
wname = wname(1:kdot-1);
lw    = length(wname);
ab    = abs(wname);
ii    = lw+1;
while (ii>1) && (47<ab(ii-1)) && (ab(ii-1)<58) , ii = ii-1; end
Nd    = wname(ii:lw);

% Use direct Biorthogonal spline wavelet filters.
%------------------------------------------------
wname = ['bior' Nd '.' Nr];
[Df,Rf] = biorwavf(wname);
