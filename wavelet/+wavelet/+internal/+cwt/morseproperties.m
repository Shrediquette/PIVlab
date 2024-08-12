function [width,skew,kurt,sigmaT,sigmaF] = morseproperties(ga,be)
% [width,skew,kurt,sigmaT,sigmaF] = morseproperties(ga,be);
% Returns the time width, skew, kurtosis, and the products in the 
% Heisenberg area of the Morse (\beta,\gamma) wavelet.
% 
% This function is for internal use only, it may change in a future
% release.
%
% Algorithm due to JM LilLy
% 
% Lilly, J. M. (2015), jLab: A data analysis package for Matlab, v. 1.6.1, 
% http://www.jmlilly.net/jmlsoft.html.

%   Copyright 2017-2020 The MathWorks, Inc.
%#codegen


narginchk(2,2);
coder.internal.prefer_const(ga);
coder.internal.prefer_const(be);
width = sqrt(ga*be);
skew = (ga-3)/width;
kurt=3-skew.^2-(2/width^2);


logsigo1=frac(2,ga).*log(frac(ga,2*be))+gammaln(frac(2*be+1+2,ga))-gammaln(frac(2*be+1,ga));
logsigo2=frac(2,ga).*log(frac(ga,2*be))+2.*gammaln(frac(2*be+2,ga))-2.*gammaln(frac(2*be+1,ga));

sigo=sqrt(exp(logsigo1)-exp(logsigo2));  
ra=2*morse_loga(ga,be)-2*morse_loga(ga,be-1)+morse_loga(ga,2*(be-1))-morse_loga(ga,2*be);
rb=2*morse_loga(ga,be)-2*morse_loga(ga,be-1+ga)+morse_loga(ga,2*(be-1+ga))-morse_loga(ga,2*be);
rc=2*morse_loga(ga,be)-2*morse_loga(ga,be-1+ga./2)+morse_loga(ga,2*(be-1+ga./2))-morse_loga(ga,2*be);

logsig2a=ra+frac(2,ga).*log(frac(be,ga))+2*log(be)+gammaln(frac(2*(be-1)+1,ga))-gammaln(frac(2*be+1,ga));
logsig2b=rb+frac(2,ga).*log(frac(be,ga))+2*log(ga)+gammaln(frac(2*(be-1+ga)+1,ga))-gammaln(frac(2*be+1,ga));
logsig2c=rc+frac(2,ga).*log(frac(be,ga))+log(2)+log(be)+log(ga)+gammaln(frac(2*(be-1+ga./2)+1,ga))-gammaln(frac(2*be+1,ga));

sig2a=exp(logsig2a);
sig2b=exp(logsig2b);
sig2c=exp(logsig2c);
sigt=sqrt(sig2a+sig2b-sig2c);

sigmaT=real(sigt);
sigmaF=real(sigo);

% Equation 
if ~isfinite(sigmaT) 
   sigmaT = morseSigma(ga,be);
end


function[loga]=morse_loga(ga,be)
loga=frac(be,ga).*(1+log(ga)-log(be));


function fracout = frac(a,b)
fracout = a/b;


function sigmaT = morseSigma(ga,be)
% Equation 46 Lilly and Ohlede Higher-Order Properties of Analytic Wavelets
cfSq = wavelet.internal.cwt.morsepeakfreq(ga,be)^2;
derivSq = @(om)(be*om.^(be-1)-ga*om.^(be+ga-1)).^2.*exp(-2*om.^ga);
Fsq = @(om)om.^(2*be).*exp(-2*om.^ga);
intDsq = quadgk(derivSq,0,Inf);
intFsq = quadgk(Fsq,0,Inf);
sigmaT = sqrt(cfSq*(intDsq/intFsq));








