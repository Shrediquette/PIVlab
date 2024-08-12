function [psi,X] = fbspwavf(LB,UB,N,IN4,IN5,IN6)
%FBSPWAVF Complex Frequency B-Spline wavelet.
%   [PSI,X] = FBSPWAVF(LB,UB,N,M,FB,FC) returns values of
%   the complex Frequency B-Spline wavelet defined by 
%   the order parameter M (M is an integer >=1),
%   a bandwidth parameter FB, and a wavelet center frequency FC.
%
%   The function PSI is computed using the explicit expression:
%   PSI(X) = (FB^0.5)*((sinc(FB*X/M).^M).*exp(2*i*pi*FC*X))
%   on an N point regular grid for the interval [LB,UB].
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

m  = 1;
Fb = 1;
Fc = 1;
nbIn = nargin;
switch nbIn
    case {0,1,2,3}
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
    case 5
        error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
    case 6 , m = IN4; Fb = IN5; Fc = IN6;
    case 4
        if ischar(IN4)
            label = deblank(IN4);
            ind   = strncmpi('fbsp',label,4);
            if isequal(ind,1)
                label(1:4) = [];
                len = length(label);
                if len>0
                    ind = strfind(label,'-');
                    if isempty(ind)
                        m = []; % error 
                    else
                        ind = ind(1);
                        m = str2num(label(1:ind-1));                
                        label(1:ind) = [];
                        ind = strfind(label,'-');
                        if isempty(ind)
                            Fb = []; % error 
                        else
                            Fb = str2num(label(1:ind-1));
                            label(1:ind) = [];
                            Fc = str2num(label);
                        end              
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
err = isempty(m) || isempty(Fc) || isempty(Fb);
if ~err 
    err = ~isnumeric(Fc) || ~isnumeric(Fb) || (Fc<=0) || (Fb<=0);
end
if err
    error(message('Wavelet:WaveletFamily:Invalid_WavNum'))
end

% Compute values of the Complex Frequency B-Spline wavelet.
X = linspace(LB,UB,N);  % wavelet support.
psi = (Fb^0.5)*((sinc(Fb*X/m).^m).*exp(2*1i*pi*Fc*X));


%-----------------------------------------------
function y = sinc(x)
%
%               | sin(pi*x)/(pi*x)  if x ~= 0
% y = sinc(x) = |
%               | 1                 if x == 0

y = ones(size(x));
k = find(x);
y(k) = sin(pi*x(k))./(pi*x(k));
%-----------------------------------------------
