function [HsN,GsN,HaN,GaN] = rescale(Hs,Gs,Ha,Ga,cfsRES)
%RESCALE Rescale Laurent polynomials.
%   If (Hs,Gs) and (Ha,Ga) are two pairs of Laurent 
%   polynomials and cfsRES a non-zero real number different
%   [HsN,GsN,HaN,GaN] = RESCALE(Hs,Gs,Ha,Ga,cfsRES) returns 
%   two "rescaled" pairs such that:
%       HsN = cfsRES * Hs;   GsN = Gs / cfsRES;
%       HaN = Ha / cfsRES;   GaN = cfsRES * Ga;
%
%   If the pairs (Hs,Gs) and (Ha,Ga) are associated to perfect
%   reconstruction filters then so are the two "rescaled" 
%   pairs (HsN,GsN) and (HaN,GaN) (see PRAACOND).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jul-2003.
%   Last Revision: 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.
            
HsN = cfsRES*Hs; 
GsN = Gs/cfsRES;
HaN = Ha/cfsRES; 
GaN = cfsRES*Ga;
