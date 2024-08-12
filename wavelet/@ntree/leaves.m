function [tn,K] = leaves(t,flagdps)
%LEAVES Determine terminal nodes.
%   N = LEAVES(T) returns a column vector N, which 
%   contains the indices of terminal nodes of the tree T.
%
%   The nodes are ordered from left to right as in tree T.   
%
%   [N,K] = LEAVES(T,'s') or [N,K] = LEAVES(T,'sort')
%   returns sorted indices.
%   M = N(K) are the indices reordered as in tree T,
%   from left to right.
%
%   N = LEAVES(T,'dp') returns a matrix N, which contains
%   the depths and positions of terminal nodes.
%   N(i,1) is the depth of i-th terminal node.
%   N(i,2) is the position of i-th terminal node.
%
%   [N,K] = LEAVES(T,'sdp') or [N,K] = LEAVES(T,'pds') or
%   [N,K] = LEAVES(T,'sortdp') or [N,K] = LEAVES(T,'pdsort') 
%   return sorted nodes.
%
%   See also TNODES, NOLEAVES.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    flagdps = convertStringsToChars(flagdps);
end

tn = t.tn;
if nargout>1  
    K = [1:length(tn)]';
end
if nargin>1
    order = t.order;
    switch flagdps
        case {'s','sort'}
            [tn,K] = sort(tn);
            if nargout>1 , [~,K] = sort(K); end
            
        case {'sdp','dps','sortdp','dpsort'}
            [tn,K] = sort(tn);
            if nargout>1 , [~,K] = sort(K); end
            [tn(:,1),tn(:,2)] = ind2depo(order,tn);
            
        case {'dp'}
            [tn(:,1),tn(:,2)] = ind2depo(order,tn);
    end
end
