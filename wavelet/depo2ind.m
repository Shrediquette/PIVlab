function n = depo2ind(order,node)
%DEPO2IND Node depth-position to node index.
%   For a tree of order ORD, N = DEPO2IND(ORD,[D P])
%   computes the indices N of the nodes whose
%   depths and positions are encoded within [D,P].
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   D (depths) and P (positions) are column vectors.
%   such that:
%     0 <= D and 0 <= P <= ORD^D-1.
%   Output indices N is a column vector of integers such that:
%     0 <= N < ((ORD^(max(D)+1))-1)/(ORD-1).
%
%   Note: for a column vector X, DEPO2IND(ORD,X) = X.
%
%   See also IND2DEPO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 27-Jul-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

% At depth d, the index of the first (left)
% node is ind = (order^d-1)/(order-1)
% All indices at depth d are:
%     ip = (order^d-1)/(order-1) + p
%     with 0 <= p <= (order^d-1)

[r,c] = size(node);
switch c
    case {0,1} , opt = 'ind';
    case 2     , opt = 'depo';
    otherwise  ,  if r <2 , opt = 'ind'; else opt = 'error'; end
end

switch opt
    case 'ind' , n = node;
    case 'depo'
        n = zeros(r,1);
        K = node(:,1)>0;
        switch order
          case 1 ,    n(K) = node(K,1);
          otherwise , n(K) = (order.^node(K,1)-1)/(order-1)+node(K,2);
        end
    case 'error'
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
