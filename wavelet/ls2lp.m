function [H,G,HT,GT] = ls2lp(LS,factMode)
%LS2LP Lifting scheme to Laurent polynomials.
%   [H,G,HT,GT] = LS2LP(LS,FACTMODE) returns the two  pairs of
%   Laurent polynomial associated to the lifting scheme LS. 
%   The pairs (H,G), (HT,GT) are the primal and the dual pair
%   respectively. FACTMODE indicates the type of polyphase
%   matrix factorization. The valid values for FACTMODE are:
%     'd' (dual factorization) or 'p' (primal factorization).
%
%   LS2LP(LS) is equivalent to LS2LP(LS,'d').
%
%   Let: [Hp,Gp,HTp,GTp] = LS2LP(LS,'p') and 
%        [Hd,Gd,HTd,GTd] = LS2LP(LS,'d') 
%
%   If LS is associated to an orthogonal wavelet, then:
%      Hp = Hd  , Gp = Gd  , HTp = HTd , GTp = GTd
%
%   If LS is associated to a biorthogonal wavelet, then:
%      Hp = HTd , Gp = GTd , HTp = Hd  , GTp = Gd

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jan-2003.
%   Last Revision: 27-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<2 , factMode = 'd'; end

PMF = ls2pmf(LS,factMode);
PM  = prod(PMF{:});
Z  = laurpoly(1,-1);    
PM = newvar(PM,'z^2'); 
H  = PM{1,1} + Z*PM{2,1}; 
G  = PM{1,2} + Z*PM{2,2};
HT = -Z*newvar(newvar(G,'1/z'),'-z');
GT =  Z*newvar(newvar(H,'1/z'),'-z');
%--------------------------------------
% HT = -Z*modulate(reflect(G));
% GT =  Z*modulate(reflect(H));
%--------------------------------------
