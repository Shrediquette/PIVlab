function suggthr = wpbmpen(t,sigma,alpha,arg)
%WPBMPEN Penalized threshold for wavelet packet de-noising.
%   THR = WPBMPEN(T,SIGMA,ALPHA) returns a global 
%   threshold THR for de-noising. THR is obtained by a wavelet  
%   packet coefficients selection rule using a penalization 
%   method provided by Birge-Massart.
%
%   T is a wptree object corresponding to the wavelet packet 
%   decomposition structure of the signal or image to be 
%   de-noised. 
%
%   SIGMA is the standard deviation of the zero mean Gaussian 
%   white noise in the de-noising model (see WNOISEST for more
%   information).
%
%   ALPHA is a tuning parameter for the penalty term, it 
%   must be a real number greater than 1. The sparsity of the
%   wavelet packet representation of the de-noised signal or image 
%   grows with ALPHA. Typically ALPHA = 2.
%
%   THR minimizes the penalized criterion given by:
%   let t* be the minimizer of
%   crit(t) = -sum(c(k)^2,k<=t) + 2*SIGMA^2*t*(ALPHA + log(n/t))
%   where c(k) are the wavelet packet coefficients sorted   
%   in decreasing order of their absolute value and n is the    
%   number of coefficients, then THR = |c(t*)|.
%
%   WPBMPEN(T,SIGMA,ALPHA,ARG) computes the global threshold,
%   and in addition plots three curves: 
%   2*SIGMA^2*t*(ALPHA + log(n/t)), sum(c(k)^2,k<=t) and crit(t).
%   
%   See also WBMPEN, WDEN, WDENCMP, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jul-99.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Retrieve coefficients.
tnods = leaves(t);  % Keep terminal nodes.
                    % Sort terminal nodes from left to right.
                    % Approximation index is 1.
app_coefs = read(t,'data',tnods(1));
last   = length(app_coefs);
c      = read(t,'data');
nbcfs  = length(c);
c      = c(last+1:end);
thresh = sort(abs(c));
thresh = thresh(end:-1:1);
rl2scr = cumsum(thresh.^2);
xpen   = [1:length(thresh)];

pen    = 2*sigma^2*xpen.*(alpha + log(nbcfs./xpen));
[dummy,indmin] = min(pen-rl2scr);
suggthr = thresh(indmin);

if nargin==4
    h = figure;
    subplot(311),plot(xpen,pen),xlabel('pen')
    subplot(312),plot(xpen,rl2scr),xlabel('rl2scr')
    subplot(313),plot(xpen,pen-rl2scr),xlabel('crit')
end
