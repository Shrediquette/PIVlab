function [pts_Opt,kopt,t_est] = wvarchg(y,K,d)
%WVARCHG Find variance change points.
%   [PTS_OPT,KOPT,T_EST] = WVARCHG(Y,K,D) computes the estimated
%   change points of the variance of signal Y for j change
%   points, with j = 0, 1, 2,..., K.
%   Integer D is the minimum delay between two change points.
%
%   Integer KOPT is the proposed number of change points
%   (0 <= KOPT <= K).
%   The vector PTS_OPT contains the corresponding change points.
%   For 1 <= k <= K, T_EST(k+1,1:k) contains the k instants
%   of the variance change points and then,
%   if KOPT > 0, PTS_OPT = T_EST(KOPT+1,1:KOPT)
%   else PTS_OPT = [].
%
%   K and D must be integers such that 1 < K << length(Y) and
%   1 <= D << length(Y).
%   Signal Y should be zero mean.
%
%   WVARCHG(Y,K) is equivalent to WVARCHG(Y,K,10).
%   WVARCHG(Y)   is equivalent to WVARCHG(Y,6,10).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jun-1999.
%   Last Revision: 04-Jan-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Set defaults.
if nargin == 2
    d = 10;
elseif nargin == 1
    K = 6;
    d = 10;
end

% Center y.
y = y(:)-mean(y);

% Increment K.
K = K+1;

% t_est computation using dynamic programming.
N  = length(y);
y2 = y.^2;
matD = NaN(N,N);
for i=1:N-d
    vi = 1:N-i+1;
    dummy = vi.*log(cumsum(y2(i:N))'./vi);
    matD(i,i+d-1:N) = dummy(d:end);
end

ind = isinf(-matD);
matD(ind) = -matD(ind);
ind = isnan(matD);
matD(ind) = Inf;

I      = zeros(K,N);
I(1,:) = matD(1,:);
t = zeros(K,N);
if K>2
    for k=2:K-1
        for L=k:N
            [I(k,L),t(k-1,L)] = min(I(k-1,1:L-1) + matD(2:L,L)');
        end
    end
end
t_est = diag(ones(1,K)*N);
[I(K,N),t(K-1,N)] = min(I(K-1,1:N-1) + matD(2:N,N)');
for j=2:K
    for k=j-1:-1:1
        col = t_est(j,k+1);
        if col>0
            t_est(j,k) = t(k,col);
        end
    end
end

% Kopt computation using penalization.
V  = I(:,N);
g2 = zeros(1,K);
for j=2:K
    g2(j) = min((V(1:j-1)-V(j))./(j-1:-1:1)');
end
k=0;
for j=2:K
    if g2(j) > max(g2(j+1:K))
        k = k+1; G2(k) = g2(j); M(k)=j; %#ok<AGROW>
    end
end

M(k+1) = K;
G2(k+1) = g2(K);
M = M';
G2 = G2';

G1 = [G2(1:k+1);0];
G2 = [inf;G2];
M = [1;M]-1;

% G1 (resp G2) contains the lower (resp upper) bounds of
% penalty intervals, M(i) contains the number of change points
% found for a penalty within the interval from G1(i) to G2(i)
% The length of G1 is at least 2.
% When the length of G1 is equal to 2, kopt = 0,
% else we select kopt as M(i) corresponding to the maximum
% penalty interval range.

if length(G1) == 2
    kopt = 0;
    pts_Opt = [];
else
    [lmax,indopt] = max(G2(2:end-1)-G1(2:end-1));
    kopt = M(indopt+1)*(lmax>G2(end));
    pts_Opt = t_est(kopt+1,1:kopt);
end
