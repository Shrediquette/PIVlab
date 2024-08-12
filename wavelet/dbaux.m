function w = dbaux(N,sumw)
%DBAUX Daubechies wavelet filter computation.
%   W = DBAUX(N,SUMW) is the order N Daubechies scaling
%   filter such that SUM(W) = SUMW.
%   Possible values for N are:
%      N = 1, 2, 3, ...
%   Caution: Instability may occur when N is too large.
%
%   W = DBAUX(N) is equivalent to W = DBAUX(N,1)
%   W = DBAUX(N,0) is equivalent to W = DBAUX(N,1)
%
%   See also DBWAVF, WFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin < 2 || sumw==0 , sumw = 1; end

% if P is the "Lagrange a trous" filter of order N
% and if w denotes the order N daub scaling filter,
% one has: P = 2*conv(wrev(w),w).
[~,R] = wlagrang(N);

% R gives partial root location of w. 
% w have N zeros located at -1.
w = real(poly([R(abs(R)<1);-ones(N,1)]));
w = sumw*(w/sum(w)); 
