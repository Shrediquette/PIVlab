function [d,p] = ind2depo(order,node)
%IND2DEPO Node index to node depth-position.
%   For a tree of order ORD, [D,P] = IND2DEPO(ORD,N)
%   computes the depths D and the positions P (at 
%   these depths D) for the nodes with indices N.
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   N (indices) is a column vector of integers (N => 0).
%   The outputs D (depths) and P (positions) are column
%   vectors such that:  0 <= D and 0 <= P <= ORD^D-1.
%
%   Note: [D,P] = IND2DEPO(ORD,[D P]).
%
%   See also DEPO2IND.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-Jul-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

% At depth d, the index of the first (left)
% node is ind = (order^d-1)/(order-1)
% All indices at depth d are:
%   ip = (order^d-1)/(order-1) + p
%   with 0 <= p <= (order^d-1)

[r,c] = size(node);
switch c
    case {0,1}
        d = zeros(r,1);
        p = zeros(r,1);
        K = node>0;
        if any(K)
            switch order
                case 1
                  d(K) = node(K);

                otherwise
                  d(K) = floor(log((order-1)*node(K)+1)/log(order));
                  p(K) = node(K)-(order.^d(K)-1)/(order-1);
            end
        end
        d(node<0) = -1;

    case 2
        d = node(:,1);
        p = node(:,2);

    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end
