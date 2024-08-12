function [zetaq,Dq, Hq, Cp] = mfstructfunctions(wavcoefs, param)
% This function is for internal use only and may change in a future
% release.
%
% The parameterization of the multiresolutions structure functions used
% here is due to Dr. Stephane Roux and colleagues
% http://www.ens-lyon.fr/PHYSIQUE/teams/signaux-systemes-physique
%
% Muzy, Bacry, & Arneodo (1991) Wavelets and multifractal formalism
% for singular signals. Physical Review Letters, pp. 3515-3518
%
% Wendt,H (2008) "Contributions of Wavelet Leaders and 
% Bootstrap to Multifractal Analysis: Images, Estimation Performance,
% Dependence Structure and Vanishing Moments. Confidence Intervals 
% and Hypothesis Tests."
%
% Wendt, H & Abry, P. (2007) "Multifractality Tests using Bootstrapped
% Wavelet Leaders."  IEEE Transactions on Signal Processing, 55, 10,
% 4811-4820.
%
% Wendt,H., Abry, P. & Jaffard, S. (2007)
% "Bootstrap for Empirical Multifractal Analysis", IEEE Signal Processing
% Magazine, 24, 4, 38-48.

%   Copyright 2016-2020 The MathWorks, Inc.

thresh = sqrt(eps);
% The inputs to mfstructfunctions are the absolute values of the wavelet
% coefficients or the wavelet leaders.
wavcoefs = wavcoefs(wavcoefs>thresh);
q = param.q;  
q = q(:);
numcoefs = numel(wavcoefs);
nq=length(q);
% Create matrices for computation
S = repmat(wavcoefs,nq,1);
Q = repmat(q', numcoefs,1)';
% Forming partition function
% Equation 2 p. 3516 (Muzy et al., 1991) 
zkq = S.^Q;
zetaq = log2(mean(zkq,2))';
sumzkq = sum(zkq,2);
% Dq computation is equation 3b, p. 3516 (Muzy et al.) 
% Wendt, p. 34, eq. 2.76
Dq = (sum(zkq .* log2(zkq ./ repmat(sumzkq,1,numcoefs)),2)./ sumzkq + log2(numcoefs))';
% Hq computation is equation 3a, p. 3516
% zkq./sumzkq is R^q(j,k) in Wendt, p. 34 eq. 2.78
Hq = (sum(zkq .* log2(S),2) ./ sumzkq)';

if ~isempty(param.cumulant)
    % Compute cumulants
    logcoefs = log(wavcoefs);
    Cp(1) = mean(logcoefs);
    Cp(2) = mean(logcoefs.^2)-Cp(1)^2;
    Cp(3) = mean(logcoefs.^3) - 3*Cp(2)*Cp(1) - Cp(1)^3 ;
end


