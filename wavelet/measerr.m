function [psnr,mse,maxerr,L2rat] = measerr(X,Xapp,Bps)
%MEASERR PSNR and three error measures.
%   [PSNR,MSE,MAXERR,L2RAT] = MEASERR(X,XAPP) returns the
%   Peak Signal to Noise Ratio (PSNR in dB), the mean square error (MSE), 
%   the maximum absolute error (MAXERR) and the energy ratio between 
%   X and Xapp (L2RAT).
% 	X stands for the original signal or image, and Xapp stands for an 
%   approximation of X.
%   X and Xapp are vectors or matrices.
%
%   You may also specify the bits per sample, BPS using:
%      [...] = MEASERR(X,XAPP,BPS)   
%   The default for BPS is 8, so the maximum possible pixel value  
%   of an image (MAXI), is 255. More generally, when samples  
%   are represented using linear PCM (Pulse Code Modulation) with B 
%   bits per sample, MAXI is 2^BPS-1.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-2010.
%   Last Revision 22-Mar-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check inputs.
narginchk(2,3)
if nargin<3 , Bps = 8; end

X    = double(X);
Xapp = double(Xapp);
absD = abs(X-Xapp);
A    = absD.^2;
maxerr = max(absD(:));
mse  = sum(A(:))/numel(X);
psnr = 20*log10((2^Bps-1)/sqrt(mse));
A = X.*X;
B = Xapp.*Xapp;
L2rat = sum(B(:))/sum(A(:));
