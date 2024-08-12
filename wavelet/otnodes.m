function [tn_Pal,tn_Seq,I,J] = otnodes(t,varargin)
%OTNODES Ordered terminal nodes for a 1-D wavelet packet tree.
%   [TN_PAL,TN_SEQ] = OTNODES(T) returns two vectors of 
%   ordered terminal nodes of a binary tree.
%   TN_PAL contains the terminal nodes ordered using 
%   Paley (or natural) order, and TN_SEQ contains the 
%   terminal nodes ordered in sequential (or frequential)
%   order.
%
% 	[TN_PAL,TN_SEQ,I,J] = OTNODES(T) also returns the permutation
%   stored in the index vectors I and J such that TN_SEQ = TN_PAL(I) 
%   and TN_PAL = TN_SEQ(J).
%
%   [DP_PAL,DP_SEQ,...] = OTNODES(T,'dp') returns in addition, the
%   depths and positions of terminal nodes. DP_PAL(:,1) and DP_SEQ(:,1)
%   are the depths, and DP_PAL(:,2) and DP_SEQ(:,2) are the positions of 
%   nodes either for Paley ordered or sequentially ordered respectively.
%
% Example
%   t = wptree(2,2,rand(1,512),'haar');
%	t = wpsplt(t,4);
%	t = wpsplt(t,5);
%	t = wpsplt(t,10);
%	plot(t);
%   [tn_Pal,tn_Seq,I,J] = otnodes(t);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Jan-2010.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check input.
narginchk(1,2);
if ~isempty(varargin) && numel(varargin)==1 && (isstring(varargin{1}) ||...
        ischar(varargin{1}))
    termnodes = validatestring(varargin{1},"dp");
else
    termnodes = [];
end
    
ord = treeord(t);
if ~isequal(ord,2)
    error(message('Wavelet:FunctionInput:InvalidTreeOrder'))
end

tn_Pal  = leaves(t);
I = frqord(tn_Pal);
tn_Seq  = tn_Pal(I);
[~,J] = sort(I);

if strcmpi(termnodes,"dp")
    [D,P] = ind2depo(ord,tn_Pal);
    tn_Pal = [D,P];
    [D,P] = ind2depo(ord,tn_Seq);
    tn_Seq = [D,P];    
end

%-------------------------------------------------------------------------
function ord = frqord(node)

order = 2;
[depths,pos_nat] = ind2depo(order,node);
nbtn = length(pos_nat);
dmax = max(depths);

tmp = zeros(1,2^dmax);
beg = 1;
for k = 1:nbtn
    d   = depths(k);
    len = 2^(dmax-d);
    tmp(beg:beg+len-1) = d;
    beg = beg+len;
end
depths = tmp;

pos = 0;
for d = 1:dmax
    pos = [pos , (2^d-1)-pos]; %#ok<AGROW>
end

[~,pos] = sort(pos);
depths = depths(pos);
pos    = pos+2^dmax-2;
for d=dmax-1:-1:1
    tmp = find(depths==d);
    if ~isempty(tmp)
        dd  = dmax-d;
        pow = 2^dd;
        beg = tmp(1:pow:end);
        tmp(1:pow:end) = [];
        pos(beg) = floor((pos(beg)+1-pow)/pow);
        pos(tmp) = NaN;
    end
end
pos = pos(~isnan(pos));
[~,tmp] = sort(node);
[~,pos] = sort(pos);
[~,pos] = sort(pos);
ord     = tmp(pos);
%-------------------------------------------------------------------------
