function ord = wpfrqord(node)
%WPFRQORD Frequency ordered wavelet packets coefficients.
%   ord = wpfrqord(node)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 17-Jul-2009.
%   Copyright 1995-2020 The MathWorks, Inc.

order = 2;
[depths,pos_nat]= ind2depo(order,node);
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
    pos = [pos , (2^d-1)-pos];
end

[nul,pos] = sort(pos);
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
[nul,tmp] = sort(node);
[nul,pos] = sort(pos);
[nul,pos] = sort(pos);
ord       = tmp(pos);
