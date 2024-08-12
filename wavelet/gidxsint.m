function [ja,jb,c] = gidxsint(a,b)
%GIDXSINT Get indices of elements in a set intersection. 
%   [IA,IB,C] = GIDXSINT(A,B) returns the intersection C
%   of the sets A and B and the indices vectors (in ascending 
%   order) IA and IB such that C = A(IA) and C = B(IB). 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Oct-96.
%   Last Revision: 29-jun-1999.
%   Copyright 1995-2020 The MathWorks, Inc.

meth = 1;
if nargout<2
   nbmax = 30;
   if length(b)<nbmax ,	meth = 2; end
end

switch meth
  case 1
    [c,ia,ib] = intersect(a,b);
    [~,iib] = sort(ib);
    ja = ia(iib);
    if nargout>1
       [~,iia] = sort(ia);
       jb = ib(iia);
    end

  case 2
    ja = zeros(size(b));
    for k = 1:length(b)
        ok = find(b(k)==a);
        if ok , ja(k) = ok; end
    end
    ja = ja(ja>0);
end

% c = a(ia) = b(ib)
% c(iia) = a(ias)
% c(iib) = b(ibs)
%
% (c ordered like in a)	= b(ib(iia))
% (c ordered like in b)	= a(ia(iib))
