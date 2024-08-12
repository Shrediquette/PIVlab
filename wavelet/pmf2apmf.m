function [APMF_1,APMF_2] = pmf2apmf(PMF,factMode)
%PMF2APMF Polyphase matrix factorization to analyzis polyphase 
%         matrix factorization.
%
%   APMF = PMF2APMF(PMF,FACTMODE) returns the analyzis polyphase 
%   matrix factorization APMF starting from the polyphase matrix 
%   factorization PMF. FACTMODE indicates the type of PMF, the
%   valid values for FACTMODE are: 
%     'd' (dual factorization) or 'p' (primal factorization).
%
%   [AMPF_Dual,APMF_Primal] = PMF2APMF(PMF,'t') returns the two
%   possible factorizations.
%
%   N.B.: PMF = pmf2apmf(pmf2apmf(PMF,FactM),FactM)).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Jun-2003.
%   Last Revision: 27-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if isempty(PMF)
    APMF_1 = [];
    APMF_2 = []; 
    return; 
end
factMode = lower(factMode(1));
cellMODE = ~isa(PMF{1},'laurmat');
if cellMODE
    nbFACT = length(PMF);
    APMF_1 = cell(1,nbFACT);
    APMF_2 = cell(1,nbFACT);
    for k = 1:nbFACT
        [APMF_1{k},APMF_2{k}] = ONE_pmf2apmf(PMF{k},factMode);
    end
else
    [APMF_1,APMF_2] = ONE_pmf2apmf(PMF,factMode);
end

%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function [APMF_1,APMF_2] = ONE_pmf2apmf(PMF,factMode)
APMF_1 = {};
APMF_2 = {};
len = length(PMF);
PMF = PMF(len:-1:1);
switch lower(factMode)
    case 'd'    % P-Tilda matrix factorization.
        APMF_1 = dualFact(PMF,len);
    case 'p'    % P matrix factorization.
        APMF_1 = primalFact(PMF,len);
    case 't'    % P-Tilda and P matrices factorization.
        APMF_1 = dualFact(PMF,len);
        APMF_2 = primalFact(PMF,len);
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dec = dualFact(dec,len)    % P-Tilda matrix factorization.
for k = 1:len
    dec{k} = newvar(dec{k}','1/z');
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dec = primalFact(dec,len)  % P matrix factorization.
for k = 1:len
    if dec{k}{1,2}~=0
        dec{k}{1,2} = -dec{k}{1,2};
    elseif dec{k}{2,1}~=0
        dec{k}{2,1} = -dec{k}{2,1};
    else % k = 1 or k = len
        tmp = dec{k}{1,1};
        dec{k}{1,1} = dec{k}{2,2};
        dec{k}{2,2} = tmp;
    end
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
