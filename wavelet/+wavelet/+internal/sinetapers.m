function [h,bwbins,bw] = sinetapers(N,ord,prec)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% [h,bwbins,bw] = sinetapers(N,ord,prec);

% Copyright 2020 The MathWorks, Inc.

%#codegen
L = cast(N,prec);
ord = cast(ord,prec);
t = linspace(1,L,L);
k = linspace(1,ord,ord);
h = sqrt(2/(N+1))*sin((pi*t'*k)./(N+1));
% Bandwidth of multitaper sine estimate. The following is the bandwidth
% estimate in cycles/sample. Multiply by Fs to obtain the bandwidth in Hz.
bw = (ord+1/2)/(N+1);
% Bandwidth if DFT bins.
bwbins = ceil(N*bw);
