function [psi,X] = shanwavf(LB,UB,N,IN4,IN5)
%SHANWAVF Complex Shannon wavelet.
%   [PSI,X] = SHANWAVF(LB,UB,N,FB,FC) returns values of
%   the complex Shannon wavelet defined by a bandwidth parameter,
%   FB, a wavelet center frequency, FC.
%   FB and FC must be such that FC > 0 and FB > 0.
%
%   The function PSI is computed using the explicit expression:
%   PSI(X) = (FB^0.5)*(sinc(FB*X).*exp(2*i*pi*FC*X))
%   on an N point regular grid in the interval [LB,UB].
%
%   Output arguments are the wavelet function PSI
%   computed on the grid X.
%
%   See also WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jun-99.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
if nargin > 3
    IN4 = convertStringsToChars(IN4);
end

Fb = 1;
Fc = 1;
nbIn = nargin;
switch nbIn
    case {0,1,2,3}
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));

    case 5 , Fb = IN4; Fc = IN5;
    case 4
        if ischar(IN4)
            label = deblank(IN4);
            ind   = strncmpi('shan',label,4);
            if isequal(ind,1)
                label(1:4) = [];
                len = length(label);
                if len>0
                    ind = strfind(label,'-');
                    if isempty(ind)
                        Fb = []; % error 
                    else
                        Fb = str2num(label(1:ind-1));
                        label(1:ind) = [];
                        Fc = str2num(label);    
                    end
                else
                    Fc = []; % error     
                end
            else
                Fc = []; % error 
            end
        else
            Fc = []; % error 
        end
end

err = isempty(Fc) || isempty(Fb);
if ~err 
    err = ~isnumeric(Fc) || ~isnumeric(Fb) || (Fc<=0) || (Fb<=0);
end
if err
    error(message('Wavelet:WaveletFamily:Invalid_WavNum'))
end
X = linspace(LB,UB,N);  % wavelet support.
psi = (Fb^0.5)*(sinc(Fb*X).*exp(2*1i*pi*Fc*X));


function y = sinc(x)
%
%               | sin(pi*x)/(pi*x)  if x ~= 0
% y = sinc(x) = |
%               | 1                 if x == 0

y = ones(size(x));
k = find(x);
y(k) = sin(pi*x(k))./(pi*x(k));
