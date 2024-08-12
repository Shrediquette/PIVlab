function LSR = lsdual(LS)
%LSDUAL Dual lifting scheme.
%   LSD = LSDUAL(LS) returns the lifting scheme LSD associated to LS. LS
%   and LSD originate from the same polyphase matrix factorization PMF,
%   where PMF = LS2PMF(LS). So [LS,LSD] = PMF2LS(PMF,'t').
%
%   For more information about lifting schemes type: lsinfo.
%
%   N.B.: LS = LSDUAL(LSDUAL(LS)).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Jun-2002.
%   Last Revision: 26-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

[PMF,~] = ls2pmf(LS,'t');
[~,LSR] = pmf2ls(PMF,'t');
