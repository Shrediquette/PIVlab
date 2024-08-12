function [t,x,rec] = nodejoin(t,nodes)
%NODEJOIN Recompose node.
%   T = NODEJOIN(T,N) returns the modified tree T
%   corresponding to a recomposition of the node N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   T = NODEJOIN(T) is equivalent to T = NODEJOIN(T,0).
%
%   This method overloads the NTREE method and 
%   calls the right overloaded method MERGE.
%
%   See also MERGE, NODESPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 22-Dec-2006.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin == 1, nodes = 0; end
x   = [];
rec = [];
order = treeord(t);
nodes = depo2ind(order,nodes);
nbNodes = length(nodes);
for idx = 1:nbNodes
    N = nodes(idx);
    tn = leaves(t);
    n_rank = tnRANK(tn,N);
    if n_rank>0
        x = getNodeDATA(t,n_rank);
    else
        t_copy = t.ntree;
        [~,rec] = nodejoin(t_copy,N);
        nbREC = length(rec);
        elim = zeros(order,nbREC);
        for k=1:nbREC
            N = rec(k);
            i_child = N*order + (1:order)';
            elim(:,k) = i_child;
            
            tn = leaves(t_copy);
            n_rank  = zeros(order,1);
            for jj = 1:order
                n_rank(jj) = tnRANK(tn,i_child(jj));
            end 
            t_copy = nodejoin(t_copy,N);
            
            % Modify: terNI - Terminal Nodes Information (DATA).
            [t,x] = modififyDATA(t,N,n_rank);
        end
        
        % Modify: allNI - All Nodes Information.
        allN = t.allNI(:,1);
        idx = gidxsint(allN,elim(:));
        t.allNI(idx,:) = [];
        
        % Modify: Parent Object.
        t.ntree = t_copy;
    end
end


%----------------------------------------------------------------------
function n_rank = tnRANK(tn,n)
n_rank = find(n==tn);
if isempty(n_rank)
    n_rank = 0;
end
%----------------------------------------------------------------------
function x = getNodeDATA(t,n_rank)

sizes   = t.terNI{1};
cfs     = t.terNI{2};
sizDATA = sizes(n_rank,:);
len     = prod(sizDATA,2);
if n_rank ~= 1
    beg = sum(prod(sizes(1:n_rank-1,:),2)) + 1;
else
    beg = 1;
end
lim = beg + len - 1;
if beg <= lim
    x = zeros(sizDATA);
    x(:) = cfs(beg:lim);
else
    x = [];
end
%----------------------------------------------------------------------
function [t,x] = modififyDATA(t,N,n_rank)

sizes   = t.terNI{1};
cfs     = t.terNI{2};
nbnodes = length(n_rank);    % nbnodes = order
sizDATA = sizes(n_rank,:);
beg     = zeros(nbnodes,1);
len     = prod(sizDATA,2);
for k=1:nbnodes
    % attention prod([])=1
    if n_rank(k) ~= 1
        beg(k) = sum(prod(sizes(1:n_rank(k)-1,:),2));
    end
end
beg = beg + 1;
lim = beg + len - 1;
tndata = cell(1,nbnodes);
for k=1:nbnodes
    if beg(k)<=lim(k)
        tndata{k}    = zeros(sizDATA(k,:));
        tndata{k}(:) = cfs(beg(k):lim(k));
    else
        tndata{k} = [];
    end
end
x = merge(t,N,tndata);

% Compute begin and length of insert DATA.
beg = beg(1);
len = sum(len);

% Modification of sizes.
tmp = t.terNI{1};
tmp = [tmp(1:n_rank(1)-1,:) ; size(x) ; tmp(n_rank(nbnodes)+1:end,:)];
t.terNI{1} = tmp;

% Modification of data.
tmp = t.terNI{2};
insertDATA = x(:)';
tmp = [tmp(1,1:beg-1) , insertDATA , tmp(1,beg+len:end)];
t.terNI{2} = tmp;
%----------------------------------------------------------------------
