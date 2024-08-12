function [psi,X] = cmorwavf(LB,UB,N,Fb,Fc)
%CMORWAVF Complex Morlet wavelet.
%   [PSI,X] = CMORWAVF(LB,UB,N) returns the complex Morlet wavelet PSI with
%   time-decay parameter, FB, and center frequency, FC, equal to 1. The
%   general expression for the complex Morlet wavelet is: 
%   PSI(X) = ((pi*FB)^(-0.5))*exp(2*pi*i*FC*X)*exp(-(X^2)/FB). 
%   X is evaluated on an N-point regular grid in the interval [LB,UB].
%
%   [PSI,X] = CMORWAVF(LB,UB,N,FB,FC) returns values of the complex Morlet
%   wavelet defined by a positive time-decay parameter, FB, and positive
%   center frequency, FC. Adjusting the time-decay parameter, FB, results
%   in a reciprocal decay in the frequency domain. Increasing FB results in
%   slower decay of the wavelet in the time domain and narrower bandwidth
%   in the frequency domain. Decreasing FB results in faster decay of the
%   wavelet in the time domain and increased bandwidth in frequency.
%
%
%   See also WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jun-99.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
if nargin > 3
    Fb = convertStringsToChars(Fb);
    if nargin > 4
        Fc = convertStringsToChars(Fc);
    end
end


nbIn = nargin;
switch nbIn
    case {0,1,2} 
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
    case 3 
        Fc = 1; Fb = 1;
    case 4 
        if ischar(Fb)
            label = deblank(Fb);
            ind   = strncmpi('cmor',label,4);
            if isequal(ind,1)
                label(1:4) = [];
                len = length(label);
                if len>0
                    ind = strfind(label,'-');
                    if isempty(ind)
                        Fc = []; Fb = []; % error
                    else
                        Fb = str2num(label(1:ind-1));
                        label(1:ind) = [];
                        Fc = str2num(label);
                    end
                else
                    Fb = []; Fc = [];
                end
            else
                Fb = []; Fc = []; % error
            end
        else
            Fb = []; Fc = []; % error
        end
        
    case 5 
end
if isempty(Fc) || isempty(Fb) , err = 1; else err = 0; end
if ~err , err = ~isnumeric(Fc) | ~isnumeric(Fb) | (Fc<=0) | (Fb<=0); end
if err
    error(message('Wavelet:WaveletFamily:Invalid_WavNum'))
end

% Validate attributes on LB,UB, and N
validateattributes(N,{'numeric'},{'scalar','integer','positive'},...
    'cmorwavf','N');
validateattributes(LB,{'numeric'},{'scalar'},'cmorwavf','LB');
validateattributes(UB,{'numeric'},{'scalar','>',LB},'cmorwavf','UB');

% compute linearly-spaced grid of X values for wavelet
X = linspace(LB,UB,N);  

% Compute values of the Complex Morlet wavelet.
psi = ((pi*Fb)^(-0.5))*exp(2*1i*pi*Fc*X).*exp(-(X.*X)/Fb);
