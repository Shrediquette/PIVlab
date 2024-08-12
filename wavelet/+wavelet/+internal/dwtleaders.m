function [leaders,scales,ncount] = dwtleaders(x,Lo,Hi)
% This function is for internal use only and may change in a future
% release.
%
% The wavelet leader algorithm used here is due to Dr. Stephane Roux
% and colleagues:
% http://www.ens-lyon.fr/PHYSIQUE/teams/signaux-systemes-physique
% http://perso.ens-lyon.fr/stephane.roux/
%
% and is described in these references:
%
% Herwig Wendt, Patrice Abry, 
% "Multifractality Tests using Bootstrapped Wavelet Leaders", 
% IEEE Trans. Signal Processing, vol. 55, no. 10, pp. 4811-4820, 2007.
%
% Wendt,H., Abry, P. & Jaffard, S. (2007)
% "Bootstrap for Empirical Multifractal Analysis", IEEE Signal Processing
% Magazine, 24, 4, 38-48. 
%
% Wendt,H (2008) "Contributions of Wavelet Leaders and 
% Bootstrap to Multifractal Analysis: Images, Estimation Performance,
% Dependence Structure and Vanishing Moments. Confidence Intervals 
% and Hypothesis Tests."

%   Copyright 2016-2020 The MathWorks, Inc.

% Obtain the length of the scaling filter
nwav = numel(Lo);
nvalid = nwav-1;

% Obtain the length of the signal and determine the level of the DWT
n = numel(x);
Nlevels = min(fix(log2(n/(nwav+1))),fix(log2(n)));

% This makes sure we have at least three levels but due to boundary effects
% we still may not have enough leaders at the end, so we will check again
% before returning
if Nlevels < 3
   error(message('Wavelet:mfa:InsufficientLeaders'));
end

% Shifts for wavelet and scaling coefficients
x0=2;
x0Appro=2*(nwav/2);
% Initialize to empty
wleaders(1).values = [];


% Begin transform
for jj = 1:Nlevels
    nj = numel(x);
    approxcoefs = conv(x,Lo);
    details = conv(x,Hi);
    % Set any NaNs equal to Infs
    approxcoefs(isnan(approxcoefs)) = Inf;
    details(isnan(details)) = Inf;
    % Remove boundary coefficients from scaling and wavelet coefficients
    approxcoefs([1:nvalid-1 nj+1:end]) = Inf;
    details([1:nvalid-1 nj+1:end]) = Inf;
    % Decimate
    approxcoefs = approxcoefs((1:2:nj)+x0Appro-1);
    details = details((1:2:nj)+x0-1);
    % Replace data with approximation coefficients
    x = approxcoefs;
    
    
    % Use L1 normalization of coefficients
    Abscoefs = abs(details)*2^(-jj/2);
   
    
  
       
    % Determine wavelet leaders
    if jj == 1
        
        %compute and store leaders
        wleaders(jj).nnallvalues = Abscoefs; %#ok<*AGROW>
        % Form neighbors as a matrix. The leaders are obtained
        % by taking the maximum over the columns
        neighbors = max([Abscoefs(1:end-2) ; Abscoefs(2:end-1); Abscoefs(3:end)]);
        idxfinite = isfinite(neighbors);
        % Determine leaders
        leaders{jj} = neighbors(idxfinite);
        % How many wavelet leaders do we have at a given level
        ncount(jj) = numel(leaders{jj});
       
        
        
    else
        nc = floor(numel(wleaders(jj-1).nnallvalues)/2);
        wleaders(jj).nnallvalues = ...
            max([Abscoefs(1:nc); wleaders(jj-1).nnallvalues(1:2:2*nc); wleaders(jj-1).nnallvalues(2:2:2*nc)]);
        neighbors = ...
            max([wleaders(jj).nnallvalues(1:end-2) ; wleaders(jj).nnallvalues(2:end-1); wleaders(jj).nnallvalues(3:end)]);
        idxfinite = isfinite(neighbors);
        leaders{jj} = neighbors(idxfinite);
        ncount(jj) = numel(leaders{jj});
        
        
    end
end


scales = 2.^(1:Nlevels);







