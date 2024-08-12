function x = waverec(c,l,varargin)
%WAVEREC Multilevel 1-D wavelet reconstruction.
%   WAVEREC performs a multilevel 1-D wavelet reconstruction
%   using either a specific wavelet ('wname', see WFILTERS) or
%   specific reconstruction filters (Lo_R and Hi_R).
%
%   X = WAVEREC(C,L,'wname') reconstructs the signal X
%   based on the multilevel wavelet decomposition structure
%   [C,L] (see WAVEDEC).
%
%   For X = WAVEREC(C,L,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%
%   See also APPCOEF, IDWT, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.
%#codegen

narginchk(3,4)
x = appcoef(c,l,varargin{:},0);
