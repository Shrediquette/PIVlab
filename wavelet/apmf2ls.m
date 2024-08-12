function  LS = apmf2ls(APMF)
%APMF2LS Analyzis polyphase matrix factorization to lifting scheme.
%   LS = APMF2LS(APMF) returns the lifting scheme LS corresponding 
%   to the analyzis polyphase matrix factorization APMF. 
%   APMF is a cell array of Laurent Matrices.
%
%   If APMFC is a cell array of factorizations, LSC = APMF2LS(APMFC)
%   returns a cell array of lifting schemes. For each k, LSC{k}
%   is associated to the factorization APMFC{k}.
%
%   See also LS2APMF.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jun-2003.
%   Last Revision: 27-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if isempty(APMF) , LS = [];  return; end

cellMODE = ~isa(APMF{1},'laurmat');
if cellMODE
    nbFACT = length(APMF);
    LS = cell(1,nbFACT);
    for k = 1:nbFACT
        LS{k} = ONE_apmf2ls(APMF{k});
    end
else
    LS = ONE_apmf2ls(APMF);
end

%---+---+---+---+---+---+---+---+---+---+---+---+---%
function LS = ONE_apmf2ls(APMF)

nbLIFT = length(APMF);
LS = cell(nbLIFT,3);
for jj = nbLIFT:-1:2
    k = 1+nbLIFT-jj;
    M = APMF{jj};
    P = M{1,2};
    if P~=0
        LS{k,1} = 'p';
    else
        P = M{2,1};
        LS{k,1} = 'd';
    end
    [LS{k,2},LS{k,3}] = get(P,'coefs','maxDEG');
end
M = APMF{1}; 
P = M{1,1};
C = get(P,'coefs');
LS(nbLIFT,1:3) = {C,1/C,[]};
%---+---+---+---+---+---+---+---+---+---+---+---+---%
