function  LS = pm2ls(PM,factMode)
%PM2LS Polyphase matrix to lifting scheme.
%   LS = PM2LS(PMF,FACTMODE) returns the lifting scheme LS 
%   corresponding to the Laurent polyphase matrice. FACTMODE
%   indicates the type of PM, the valid values for FACTMODE are: 
%      'd' (dual factorization) or 'p' (primal factorization).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 24-Jun-2003.
%   Last Revision: 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if isempty(PM) , LS = []; return; end

%-------------------------------------------%
% PMF2APMF is an involutive transformation. %
% So:  M == PMF2APMF(PMF2APMF(M))           %
% And: APMF2PMF == PMF2APMF                 %
%-------------------------------------------%
PMF  = mftable(PM);
APMF = pmf2apmf(PMF,factMode);
LS   = apmf2ls(APMF);
