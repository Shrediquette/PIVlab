function E = wenergy(t)
%WENERGY Energy for a wavelet packet decomposition.
%   For a wavelet packet tree T, (see WPTREE, WPDEC, WPDEC2) 
%   E = WENERGY(T) returns a vector E, which contains the
%   percentages of energy corresponding to the terminal nodes
%   of the tree T. 
%
%   Examples:
%     % example 1 - one-dimensional
%     % Wavelet packet decomposition and percentages of energy
%     load noisbump
%     T = wpdec(noisbump,3,'sym4');
%     E = wenergy(T)
%
%     % example 2 - two-dimensional
%     % Wavelet packet decomposition and percentages of energy 
%     load detail
%     T = wpdec2(X,2,'sym4');
%     E = wenergy(T)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-May-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

C = read(t,'allcfs');
Et = sum(C(:).^2);
tn = leaves(t,'s');
nbtn = length(tn);
E  = zeros(1,nbtn);
for k=1:nbtn
    C = read(t,'data',tn(k));
    E(k) = sum(C(:).^2);
end
E = 100*E/Et;
