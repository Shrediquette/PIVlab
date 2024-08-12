function [LoD,HiD,LoR,HiR] = ls2filt(varargin)
%LS2FILT Lifting scheme to filters.
%   [LoD,HiD,LoR,HiR] = LS2FILT(LS) returns the four
%   filters associated to the lifting scheme LS.
%
%   See also FILT2LS, LSINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(1,1);
[varargin{:}] = wavelet.internal.wconvertStringsToChars(varargin{:});
LS = varargin{1};
[LoD,HiD,LoR,HiR] = ls2filters(LS,'d_num');
