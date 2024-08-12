function infowsys
%INFOWSYS Information on wavelet packets.
%
%   Wavelet Packets
%
%1. Wavelet Packets definition.
%
%   Start: 
%      an orthogonal wavelet psi, h and g the two filters 
%      associated with the wavelet.
%      Both h and g are of length 2N.
%
%   Wavelet packets generation:
% 
%      define by induction the set of functions
%      Wn for n = 0, 1, 2, ...
%
%      W2n(x)   = 2^{0.5}*sum ( h(k) Wn(2x-k) : for k = 0 to 2N-1)
%      W2n+1(x) = 2^{0.5}*sum ( g(k) Wn(2x-k) : for k = 0 to 2N-1)
%
%      where W0 = phi and W1 = psi.
%
%      The functions Wn are obtained roughly speaking by 
%      superposition of 1/2-scaled and translated versions
%      of functions of lower index.
%
%   Wavelet packets interpretation: 
%
%      Since all the Wn are supported by the same interval
%      [0,2N-1], Wn oscillates approximately n times and 
%      then n can be interpreted as a frequency parameter. 
%
%
%2. Wavelet Packet Atoms.
%
%   Starting from the Wn, let us consider the three-index 
%   family of wavelet packet atoms, obtained by dyadic 
%   dilations and translations of Wn:
%
%      Wj,n,k (x) = 2^{-j/2} Wn(2^{-j} x - k)
%
%   For a given value of j:
%   Wj,n,k allow to analyze the fluctuations of a given
%   signal roughly:
%      - around the position 2^{j}*k,
%      - at the scale 2^{j}
%      - at various frequencies n/2N, for n = 0 to 2^j-1.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-Jul-1999.
%   Copyright 1995-2020 The MathWorks, Inc.

