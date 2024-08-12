function [psi,X] = gauswavf(LB,UB,N,NumWAW)
%GAUSWAVF Gaussian wavelet.
%   [PSI,X] = GAUSWAVF(LB,UB,N) returns the 1st order derivative of
%   Gaussian wavelet, PSI, on an N-point regular grid, X for the interval
%   [LB,UB]. The wavelet is scaled such that the L2-norm of the 1st
%   derivative of PSI is equal to 1. The effective support of the Gaussian
%   wavelets is [-5,5].
%
%   [PSI,X] = GAUSWAVF(LB,UB,N,P) returns the Pth derivative. P is an
%   integer in the range [1,8].
%
%   [PSI,X] = GAUSWAVF(LB,UB,N,WAVNAME) uses the valid wavelet family short
%   name, 'gaus', plus the number of the derivative, for example: 'gaus3'.
%   You can find the valid combinations by entering: waveinfo('gaus') at
%   the MATLAB command prompt. Alternatively, you can enter
%   wavemngr('read',1) at the MATLAB command prompt and find the Gaussian
%   family.
%
%   %  EXAMPLE:
%   %   Obtain the 2nd derivative of Gaussian wavelet and plot the
%   %   result. Use 1000 points over the grid [-5,5]. Demonstrate that the
%   %   L2 norm is equal to 1.
%   [psi,x] = gauswavf(-5,5,1000,2);
%   plot(x,psi)
%   trapz(x,abs(psi).^2)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
if nargin > 3
    NumWAW = convertStringsToChars(NumWAW);
end

narginchk(3,4);
nbIn = nargin;
switch nbIn
    
    case 3 , NumWAW = 1;
        
    case 4
        if ischar(NumWAW)
            [~,NumWAW] = wavemngr('fam_num',NumWAW);
            NumWAW = str2double(NumWAW);
        end
        
    otherwise
        error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end
if errargt(mfilename,NumWAW,'int')
    error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

% Compute values of the Gauss wavelet.
X = linspace(LB,UB,N);  % wavelet support.
if find(NumWAW==1:8,1)
    X2 = X.^2;
    F0 = (2/pi)^(1/4)*exp(-X2);
end

switch NumWAW
    case 1
        psi = -2*X.*F0;
        
    case 2
        psi = 2/(3^(1/2)) * (-1+2*X2).*F0;
        
    case 3
        psi = 4/(15^(1/2)) * X.* (3-2*X2).*F0;
        
    case 4
        psi = 4/(105^(1/2)) * (3-12*X2+4*X2.^2).*F0;
        
    case 5
        psi = 8/(3*(105^(1/2))) * X.* (-15+20*X2-4*X2.^2).*F0;
        
    case 6
        psi = 8/(3*(1155^(1/2))) * (-15+90*X2-60*X2.^2+8*X2.^3).*F0;
        
    case 7
        psi = 16/(3*(15015^(1/2))) *X.*(105-210*X2+84*X2.^2-8*X2.^3).*F0;
        
    case 8
        psi = 16/(45*(1001^(1/2))) * (105-840*X2+840*X2.^2-224*X2.^3+16*X2.^4).*F0;
        
    otherwise
        error(message('Wavelet:FunctionInput:InvalidGaussDeriv'));
end
switch rem(NumWAW,4)
    case {2,3} , psi = -psi;
end
