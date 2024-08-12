function varargout = wrepcoef(coefs,longs,levels,varargin)
%WREPCOEF Replication of coefficients.
%
%   VARARGOUT = WREPCOEF(COEFS,LONGS,LEVELS)
%   VARARGOUT = WREPCOEF(COEFS,LONGS) is equivalent to
%   VARARGOUT = WREPCOEF(COEFS,LONGS,[1:LEVMAX]) where
%   LEVMAX = length(LONGS)-2;
%
%   VARARGOUT = WREPCOEF(COEFS,LONGS,LEVELS,'notrunc')

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Sep-98.
%   Last Revision: 19-Feb-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<4 , trunc = 1; else trunc = 0; end
len    = longs(end);
levmax = length(longs)-2;
if nargin<3 , levels = 1:levmax; end
nblev  = length(levels);
first  = cumsum(longs)+1;
first  = first(end-2:-1:1);
tmp    = longs(end-1:-1:2);
last   = first+tmp-1;

repcoefs = cell(1,nblev);
for j = 1:length(levels)
    k = levels(j);
    nbind = 2^k;
    tmp   = coefs(first(k):last(k));
    tmp   = tmp(ones(1,nbind),:);
    tmp   = tmp(:)';
    if trunc , tmp   = wkeep1(tmp,len); end
    repcoefs{j} = tmp;
end
if trunc
    dim =1;
    varargout{1} = cat(dim,repcoefs{:});
else
    varargout{1} = repcoefs;
end
