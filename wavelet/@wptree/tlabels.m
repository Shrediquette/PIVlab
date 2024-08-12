function labels = tlabels(t,varargin)
%TLABELS Labels for the nodes of a wavelet packet tree.
%   LABELS = TLABELS(T,TYPE,N) returns the labels for
%   the nodes N of the tree T.
%   The valid values for TYPE are:
%       'i'  or 1 --> indices.
%       'p'  or 2 --> depth-position.
%       'e'  or 3 --> entropy.
%       'eo' or 4 --> optimal entropy.
%       's'  or 5 --> size.
%       'n'  or 6 --> none.
%       't'  or 7 --> type.
%   
%   LABELS = TLABELS(T,TYPE) returns the labels
%   for all nodes of T.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

labtype = varargin{1};
if length(varargin)<2
    nodes = allnodes(t);
else
    nodes = varargin{2};
end
nbnodes	= length(nodes);
labels  = [];

switch labtype
   case {3,'e'}
     entropies = read(t,'ent',nodes);
     labels = num2str(entropies(:),5);

   case {4,'eo'}
     ent_opt = read(t,'ento',nodes);
     labels  = num2str(ent_opt(:),5);

   case {5,'s'}
     order = treeord(t);
     sizes = read(t,'sizes',nodes);
     switch order
       case 2
         for k=1:nbnodes
           labels = strvcat(labels,sprintf('%0.f',max(sizes(k,:))));
         end

       case 4
         for k=1:nbnodes
           labels = strvcat(labels,sprintf('(%0.f,%0.f)',sizes(k,:)));
         end
     end

   case {7,'t'}
     order = treeord(t);
     [~,p] = ind2depo(order,nodes);
     p = rem(p,order);
     pstr = repLine('a',nbnodes);
     if order==2
         I = find(p==1); pd = repLine('d',length(I)); pstr(I,:) = pd;
     else
         I = find(p==1); pd = repLine('h',length(I)); pstr(I,:) = pd;
         I = find(p==2); pd = repLine('v',length(I)); pstr(I,:) = pd;
         I = find(p==3); pd = repLine('d',length(I)); pstr(I,:) = pd;
     end
     lp = repLine('(',nbnodes);
     rp = repLine(')',nbnodes);
     labels = [lp pstr rp];

   case {8,'en'}
     [~,K] = leaves(t,'s');
     E = wenergy(t);
     E = E(K);
     for k=1:nbnodes
         n   = nodedesc(t,nodes(k));
         idx = istnode(t,n);
         idx(idx==0) = [];
         lab = sprintf('%2.2f',sum(E(idx)));
         labels = strvcat(labels,lab); 
     end

   otherwise
     labels = tlabels(t.dtree,varargin{:});  
end

%--------------------------%
function m = repLine(c,n)
%REPLINE Replicate Lines.

m = c(ones(n,1),:);
%--------------------------%
