function [xnpos,ynpos] = xynodpos(table_node,order,depth)
%XYNODPOS Computes graphical position of a node in a tree.
%   [XNPOS,YNPOS] = XYNODPOS(TABLE_NODE,ORDER,DEPTH)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 28-Apr-2009.
%   Copyright 1995-2020 The MathWorks, Inc.

% SPECIAL CASES
%--------------
if (order<=1) || (depth==0)
   xnpos = zeros(1,depth+1);
   if depth > 0
       pasy = 0.8/depth;
       y = 0.1+pasy*(0:depth-1)';
       ynpos = [y y+pasy];
   else
       ynpos = 0.1;
   end
   return
end

% Create nodes indices table.
%----------------------------
ord_ind = 1:order;
order1  = order+1;
N       = size(table_node,2);
xnpos   = zeros(order1,N);
node_exist = (table_node ~= -1);

% Setting the width of the subtrees.
% The initial width is 1.
%-----------------------------------------
xnpos(1,node_exist) = 1;

% Left Nodes Indices.
%--------------------
i_Ltree = (order.^(0:depth)-1)/(order-1)+1;

for d=depth-1:-1:0
    n_d = i_Ltree(d+1);
    i_fath = n_d+(0:order^d-1);
    i_left_child = (i_fath-1)*order+2;
    for k=1:order^d
        i_f  = i_fath(k);
        i_lc = i_left_child(k);
        if table_node(i_lc) ~= -1
            for i=1:order
                xnpos(i,i_f) = sum(xnpos(ord_ind,i_lc+i-1));
            end
        else
            up    = 1;
            i_asc = i_f;
            while table_node(i_asc) == -1
                up = up+1;
                i_asc = floor((i_asc-2)/order)+1;
            end             
            xnpos(1,i_lc:i_lc+order-1) = 1/(order^up);
        end
    end
end

% Now the rows 1:order contain the width (depth) of the subtrees.

%
% Elimination of the nodes for the maximum depth.
%------------------------------------------------
if N > 1, xnpos(:,(N-1)/order+1:size(xnpos,2)) = []; end

% Normalization : the total width is 1.
%--------------------------------------
xnpos(ord_ind,:) = xnpos(ord_ind,:)/sum(xnpos(ord_ind,1));

% Setting the minimum values of the abscissae of the subtrees.
%-------------------------------------------------------------
xnpos(order1,i_Ltree) = -0.5*ones(size(i_Ltree));
for d=1:depth-1
    n_d = i_Ltree(d+1);
    for p=n_d+1:n_d+order^d-1
        xnpos(order1,p) = sum(xnpos((1:order1),p-1));
    end
end

% Now the row order+1 contains the abscisses of the left extremity
% of the subtrees.

% Change the width of the subtrees.
%----------------------------------
xnpos(ord_ind,:) = cumsum(xnpos(ord_ind,:)) - xnpos(ord_ind,:)/2;
xnpos(ord_ind,:) = xnpos(ord_ind,:)+xnpos((order1)*ones(1,order),:);

% Suppress the last row.
%-----------------------
xnpos = xnpos(1:order,:);
xnpos = [0 xnpos(:)'];

% Y position.
%------------
pasy  = 0.8/depth;
y     = 0.1+pasy*(0:depth-1)';
ynpos = [y y+pasy];
