function infowave
%INFOWAVE Information on wavelets.
%
%   Wavelets
%
%1. Crude wavelets.
%
%   Wavelets: gaussian wavelets (gaus), morlet, mexican hat (mexihat).
%
%   Properties: only minimal properties 
%      - phi does not exist.
%      - the analysis is not orthogonal.
%      - psi is not compactly supported.
%      - the reconstruction property is not insured.
%   Possible analysis: 
%      - continuous decomposition.
%   Main nice properties: symmetry, psi has explicit expression.
%   Main difficulties: fast algorithm and reconstruction
%      unavailable.
%
%2. Infinitely regular wavelets.
%
%   Wavelets: meyer (meyr).
%
%   Properties: 
%      - phi exists and the analysis is orthogonal.
%      - psi and phi are indefinitely derivable.
%      - psi and phi are not compactly supported.
%   Possible analysis:
%      - continuous transform.
%      - discrete transform but with non FIR filters.
%   Main nice properties: symmetry, infinite regularity.
%   Main difficulties: fast algorithm unavailable.
%
%   Wavelets: discrete Meyer wavelet (dmey).
%
%   Properties: 
%      - FIR approximation of the Meyer wavelet
%   Possible analysis:
%      - continuous transform.
%      - discrete transform.
%
%3. Orthogonal and compactly supported wavelets.
%
%   Wavelets: Daubechies (dbN), symlets (symN), coiflets (coifN).
%
%   General properties: 
%      - phi exists and the analysis is orthogonal.
%      - psi and phi are compactly supported.
%      - psi has a given number of vanishing moments.
%   Possible analysis:
%      - continuous transform.
%      - discrete transform using FWT.
%   Main nice properties: support, vanishing moments, FIR filters.
%   Main difficulties: poor regularity.
%
%   Specific properties:
%      For dbN  : asymmetry 
%      For symN : near symmetry
%      For coifN: near symmetry and phi as psi, has also 
%         vanishing moments.
%
%4. Biorthogonal and compactly supported wavelet pairs.
%
%   Wavelets: B-splines biorthogonal wavelets (biorNr.Nd and rbioNr.Nd).
%
%   Properties: 
%      - phi functions exist and the analysis is biorthogonal.
%      - psi and phi both for decomposition and reconstruction
%    are compactly supported.
%      - phi and psi for decomposition have vanishing moments.
%      - psi and phi for reconstruction have known regularity.
%   Possible analysis:
%      - continuous transform.
%      - discrete transform using FWT.
%   Main nice properties: symmetry with FIR filters, desirable 
%      properties for decomposition and reconstruction are split
%      and nice allocation is possible.
%   Main difficulties: orthogonality is lost.
%
%5. Complex wavelets.
%
%   Wavelets: Complex Gaussian wavelets (cgauN), complex Morlet 
%       wavelets (cmorFb-Fc), complex Shannon wavelets (shanFb-Fc), 
%       complex frequency B-spline wavelets (fbspM-Fb-Fc).
%
%   Properties: only minimal properties 
%      - phi does not exist.
%      - the analysis is not orthogonal.
%      - psi is not compactly supported.
%      - the reconstruction property is not insured.
%   Possible analysis: 
%      - complex continuous decomposition.
%   Main nice properties: symmetry, psi has explicit expression.
%   Main difficulties: fast algorithm and reconstruction unavailable.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 02-Jul-1999.
%   Copyright 1995-2020 The MathWorks, Inc.

