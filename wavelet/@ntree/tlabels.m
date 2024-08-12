function labels = tlabels(t,varargin)
%TLABELS Labels for the nodes of a tree.
%   LABELS = TLABELS(T,TYPE,N) returns the labels for
%   the nodes N of the tree T.
%   The valid values for TYPE are:
%       'p' for depth-position.
%       'i' for indices.
%       'n' for none.
%   
%   LABELS = TLABELS(T,TYPE) returns the labels
%   for all nodes of T.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-98.
%   Last Revision: 15-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

labtype = varargin{1};
if length(varargin)<2
    nodes = allnodes(t);
else
    nodes = varargin{2};
end
nbnodes	= length(nodes);
labels  = [];

switch labtype
  case {'p','dp'}
    order = treeord(t);
    [d,p] = ind2depo(order,nodes);
    
    for k=1:nbnodes
        labels = strvcat(labels,sprintf('(%0.f,%0.f)',d(k),p(k)));
    end

  case 'i'
    for k=1:nbnodes
        labels = strvcat(labels,sprintf('(%0.f)',nodes(k)));
    end

  case 'n'

end
