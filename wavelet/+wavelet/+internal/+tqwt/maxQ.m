function [validQ,msg] = maxQ(n,qrange)
% This code is for internal use only. It may change or be removed in a
% a future release.
%
% %Example:
%   [validQ,msg] = wavelet.internal.tqwt.maxQ(128,[1 100]);
%   [wt,info] = tqwt(randn(128,1),Q = validQ(2));
%   info.Level


arguments
    n {mustBeA(n,["double","single","int32","uint32"]), mustBePositive} 
    qrange {mustBeA(qrange,["double","single"]),mustBePositive,mustBeVector} = [1 100]
end

msg = "";
Nq = numel(qrange);
qz = qrange(Nq);
qz1 = ...
    log(n/(4*qrange(1)+4))-log(3*qrange(1)+3)+log(3*qrange(1)+1);
qzEnd = ...
    log(n/(4*qrange(Nq)+4))-log(3*qrange(Nq)+3)+log(3*qrange(Nq)+1);
if sign(qz1) == sign(qzEnd) 
    msg = "No zero in interval";
    validQ = qrange;    
else
    qz = fzero(@(q)log(n/(4*q+4))-log(3*q+3)+log(3*q+1),qrange);
    % To guard against precision loss move the maximum allowable Q down by
    % 100*eps(value)
    qz = qz-100*eps(qz);
    validQ = [1 qz];
end
Jmax = floor(log(n/(4*qz+4))/log((3*qz+3)/(3*qz+1)));
% This assert is for debugging, it should never be hit.
assert(Jmax >= 1,'Q < 1');








