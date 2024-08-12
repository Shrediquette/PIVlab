function x = rnodcoef(t,node)
%RNODCOEF Reconstruct node coefficients.
%   X = RNODCOEF(T,N) computes reconstructed coefficients
%   of the node N of the tree T.
%
%   X = RNODCOEF(T) is equivalent to X = RNODCOEF(T,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Oct-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin==1, node = 0; end
if find(isnode(t,node)==0)
    error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
end

% Get node data (coefficients).
[~,x] = nodejoin(t,node);

% Get asc, edges, ...
order = treeord(t);
asc   = nodeasc(t,node);
node  = asc(1);
if length(asc)<2 , return; end
sizes = read(t,'sizes',asc(2:end));
[~,p] = ind2depo(order,asc);
edges = rem(p,order);
edges = edges(1:end-1);

% Reconstruction.
x = recons(t,node,x,sizes,edges);
