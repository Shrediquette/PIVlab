function [thresh,rl2scr,n0scr,imin,suggthr] = wpcmpscr(Ts,IN2,IN3)
%WPCMPSCR Wavelet packets 1-D or 2-D compression scores.
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE) returns
%   for the input wavelet packets tree TREE compression scores
%   and suggested threshold when approximation is kept:
%   THR the vector of ordered thresholds.
%   and the corresponding vectors of scores induced by
%   a THR(i)-thresholding :
%   RL2 vector of 2-norm recovery score in percent.
%   NZ  vector of relative number of zeros in percent.
%   IMIN is the index of THR for which the two scores are
%   approximately the same.
%   STHR is a suggested threshold.
%
%   When used with two arguments WPCMPSCR(TREE,IN2) 
%   returns the same outputs but all coefficients can be 
%   thresholded.
%
%   See also KEY2INFO, WCMPSCR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-May-2009.
%   Copyright 1995-2020 The MathWorks, Inc.

%--------------%
% NEW VERSION  %
%--------------%
%   Internal uses for compatibility:
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE,TREE)
%     Approximation is kept.
%
%   [THR,RL2,NZ,IMIN,STHR] = WPCMPSCR(TREE,TREE,IN3)
%     All coefficients can be thresholded.


% Check arguments and set problem dimension.
keepapp = (nargin == 1) || (nargin == 2 && isa(IN2,'wptree'));
if keepapp      % approximation is kept.
    tn      = leaves(Ts);
    app     = tn(1);
    sizapp  = read(Ts,'sizes',app);
    dimapp  = prod(sizapp);
end
c = read(Ts,'allcfs');
order = treeord(Ts);
if order==2 , dim = 1; else dim = 2;  end

% Set possible thresholds.
if keepapp      % approximation is kept.
    app    = c(1:dimapp);
    c      = c(dimapp+1:length(c));
    nl2app = sum(app.^2);
    n0app  = length(find(app==0));
else            % all coefs can be thresholded.
    dimapp = 0; nl2app = 0; n0app = 0;
end

% Compute compression scores.
thresh	= sort(abs(c));
Nb_Thr	= length(thresh);
if (nl2app<eps && thresh(Nb_Thr)<eps)
    rl2scr  = 100*ones(1,Nb_Thr);
    n0scr   = 100*ones(1,Nb_Thr);
    suggthr = 0;
    return
end

rl2scr = cumsum(thresh.^2) / (sum(thresh.^2)+nl2app);
n0det  = length(find(c==0));
n0scr  = ((n0app + n0det + ...
               [zeros(1,n0det+1) , 1:(Nb_Thr-n0det)]) / (Nb_Thr+dimapp));
rl2scr = 100 * (1 - rl2scr);
n0scr  = 100 * n0scr;
thresh = [0 thresh];
rl2scr = [100 rl2scr];

% Find threshold for which the two scores are the same.
[dummy,imin] = min(abs(rl2scr-n0scr));

% Set suggested threshold.
suggthr = thresh(imin);
if dim==2, suggthr = sqrt(suggthr); end

