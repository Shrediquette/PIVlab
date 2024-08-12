function [thresh,rl2scr,n0scr,imin,suggthr] = wcmpscr(c,l,varargin)
%WCMPSCR Wavelet 1-D or 2-D Compression Scores.
%   [THR,RL2,NZ,IMIN] = WCMPSCR(C,L) returns for
%   the input wavelet decomposition structure [C,L],
%   compression scores for detail coefficients
%   thresholding and suggested threshold.
%   Outputs are :
%   THR the vector of ordered thresholds.
%   and vectors of scores induced by a THR(i)-thresholding :
%   RL2 vector of 2-norm recovery score in percent.
%   NZ  vector of relative number of zeros in percent.
%   IMIN is the index of THR for which the two scores are
%   approximately the same.
%   STHR is a suggested threshold.
%
%   When used with three arguments WCMPSCR(C,L,IN3) returns
%   the same outputs but for approximation and details
%   coefficients thresholding.
%
%   See also KEY2INFO, WPCMPSCR.
                    
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-May-2009.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments and set problem dimension.
dim = 1;    if min(size(l))~=1, dim = 2; end
keepapp = (nargin == 2);

% Set possible thresholds.
if keepapp      % only detail coeffs can be thresholded.
    if dim == 1
        last = l(1);
    else
        last = prod(l(1,:));
    end
    app    = c(1:last);
    c      = c(last+1:end);
    dimapp = length(app);
    nl2app = sum(app.^2);
    n0app  = length(find(app==0));
else            % all coeffs can be thresholded.
    dimapp = 0; nl2app = 0; n0app = 0;
end

% Compute compression scores.
thresh  = sort(abs(c));
Nb_Thr  = length(thresh);
if (nl2app<eps && thresh(Nb_Thr)<eps)
    rl2scr  = 100*ones(1,Nb_Thr);
    n0scr   = 100*ones(1,Nb_Thr);
    suggthr = 0;
    return
end
rl2scr  = cumsum(thresh.^2) / (sum(thresh.^2)+nl2app);
n0det   = length(find(c==0));
n0scr   = ((n0app + n0det + ...
                [zeros(1,n0det+1) , 1:(Nb_Thr-n0det)]) / (Nb_Thr+dimapp));
rl2scr  = 100 * (1 - rl2scr);
n0scr   = 100 * n0scr;
thresh  = [0 thresh];
rl2scr  = [100 rl2scr];

% Find threshold for which the two scores are the same.
[~,imin] = min(abs(rl2scr-n0scr));
if nargout<5 , return; end

% Set suggested threshold.
suggthr = thresh(imin);
if dim==2, suggthr = sqrt(suggthr); end



