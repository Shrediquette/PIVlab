function [MatFACT,PM,OkFACT] = ppmfact(H,G,flagCONTROL) %#ok<INUSD>
%PPMFACT Polyphase matrix factorizations.
%    [MATFACT,PM] = PPMFACT(H,G) returns the polyphase matrix 
%    PM associated with two Laurent polynomials H and G and
%    the factorizations MATFACT of PM.
%    This polyphase matrix (see PPM) is such that:
%  
%                 | even(H(z)) even(G(z)) |
%         PM(z) = |                       |
%                 | odd(H(z))   odd(G(z)) |
%
%    MATFACT is a cell array such that each cell contains
%    a factorization of PM.
%
%    In addition, [MATFACT,PM,OKFACT] = PPMFACT(H,G,flagCONTROL) 
%    returns a logical array OKFACT. Each factorization is
%    controlled and OKFACT is such that:
%       OKFACT(k) = true if an only if prod(MATFACT{k}{:}) == PM;
%
%   Each "elementary factor" F = MatFACT{j}{k} is of one
%   of the two following form:
%
%            | 1     0 |            | 1     P |
%            |         |            |         |
%        F = |         |   or   F = |         |
%            |         |            |         |
%            | P     1 |            | 0     1 |
%
%   where P is a Laurent polynomial.
%
%   Example:
%      [Hs,Gs,Ha,Ga] = wave2lp('db2');
%      [MatFACT,PM]  = ppmfact(Hs,Gs);
%      disp(PM);
%      displmf(MatFACT{1});
%
%    See also EVEN, ODD, PPM.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Apr-2001.
%   Last Revision: 30-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Polyphase Matrix.
PM = ppm(H,G);

% Compute factorizations.
MatFACT = mftable(PM);

% Control of factorizations under request.
if nargin>2
    nbFACT = length(MatFACT);
    OkFACT = true(1,nbFACT);
    for k = 1:nbFACT
        OkFACT(k) = prod(MatFACT{k}{:}) == PM;
    end
end
