function [PRCond,AACond] = praacond(Hs,Gs,Ha,Ga)
%PRAACOND Perfect reconstruction and anti-aliasing conditions.
%   If (Hs,Gs) and (Ha,Ga) are two pairs of Laurent polynomials,
%   [PRCond,AACond] = PRAACOND(Hs,Gs,Ha,Ga) returns the values of
%   PRCond(z) and AACond(z) which are the Perfect Reconstruction 
%   and the Anti-Aliasing "values":
%      PRCond(z) = Hs(z) * Ha(1/z)  + Gs(z) * Ga(1/z)
%      AACond(z) = Hs(z) * Ha(-1/z) + Gs(z) * Ga(-1/z)
%
%   The pairs (Hs,Gs) and (Ha,Ga) are associated to perfect
%   reconstruction filters if and only if: 
%      PRCond(z) = 2 and AACond(z) = 0.
%
%   If PRCond(z) = 2 * z^d, a delay is introduced in the 
%   reconstruction process.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jul-2003.
%   Last Revision: 06-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

PRCond = Hs * reflect(Ha) + Gs * reflect(Ga);
AACond = Hs * modulate(reflect(Ha)) + Gs * modulate(reflect(Ga));

% In an equivalent way:
%   PRCond = -z*(Hs(z)*Gs(-z)-Hs(-z)*Gs(z))
