function [psi,X] = cgauwavf(LB,UB,N,NumWAW)
%CGAUWAVF Complex Gaussian wavelet.
%   [PSI,X] = CGAUWAVF(LB,UB,N) returns the 1st order derivative of the
%   complex-valued Gaussian wavelet, PSI, on an N-point regular grid, X,
%   for the interval [LB,UB]. The wavelet is scaled such that the L2-norm
%   of the 1st derivative of PSI is equal to 1. The effective support of
%   the complex-valued Gaussian wavelets is [-5,5].
%
%   [PSI,X] = CGAUWAVF(LB,UB,N,P) returns the Pth derivative of the complex
%   Gaussian wavelet. P is an integer in the range [1,8].
%
%   [PSI,X] = CGAUWAVF(LB,UB,N,WAVNAME) uses the valid wavelet family short
%   name, 'cgau', plus the number of the derivative, for example: 'cgau3'.
%   You can find the valid combinations by entering: waveinfo('cgau') at
%   the MATLAB command prompt. Alternatively, you can enter
%   wavemngr('read',1) at the MATLAB command prompt and find the Complex
%   Gaussian family.
%
%   %  EXAMPLE:
%   %   Obtain the 2nd derivative of the complex Gaussian wavelet and plot
%   %   the result. Use 1000 points over the interval [-5,5]. Demonstrate 
%   %   that the L2 norm is equal to 1.
%   [psi,x] = cgauwavf(-5,5,1000,2);
%   trapz(x,abs(psi).^2)
%   subplot(2,1,1)
%   plot(x,real(psi))
%   title('Real Part')
%   subplot(2,1,2)
%   plot(x,imag(psi))
%   title('Imaginary Part')
%   

%   See also GAUSWAVF, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-99.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
narginchk(3,4);

if nargin > 3
    NumWAW = convertStringsToChars(NumWAW);
end

nbIn = nargin;
switch nbIn
    
    case 3
        NumWAW = 1;
    case 4
        if ischar(NumWAW)
            [~,NumWAW] = wavemngr('fam_num',NumWAW);
            NumWAW = str2num(NumWAW);
        end
end

if errargt(mfilename,NumWAW,'int')
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

% Compute values of the Complex Gauss wavelet.
X = linspace(LB,UB,N);  % wavelet support.
if find(NumWAW==1:8)
    X2 = X.^2;
    F0 = exp(-X2);
    F1 = exp(-1i*X);
    F2 = (F1.*F0)/(exp(-1/2)*2^(1/2)*pi^(1/2))^(1/2);
end

switch NumWAW
    case 1
        psi = F2.*(-1i-2*X)*2^(1/2);
        
    case 2
        psi = 1/3*F2.*(-3+4*1i*X+4*X2)*6^(1/2);
        
    case 3
        psi = 1/15*F2.*(7*1i+18*X-12*1i*X.^2-8*X.^3)*30^(1/2);
        
    case 4
        psi = 1/105*F2.*(25-56*1i*X-72*X.^2+32*1i*X.^3+16*X.^4)*210^(1/2);
        
    case 5
        psi = 1/315*F2.*(-81*1i-250*X+280*1i*X.^2+240*X.^3-80*1i*X.^4-32*X.^5)*210^(1/2);
        
    case 6
        psi = 1/3465*F2.*(-331+972*1i*X+1500*X.^2-1120*1i*X.^3-720*X.^4+192*1i*X.^5+64*X.^6)*2310^(1/2);
        
    case 7
        psi = 1/45045*F2.*(1303*1i+4634*X-6804*1i*X.^2-7000*X.^3+3920*1i*X.^4+2016*X.^5-448*1i*X.^6-128*X.^7)*30030^(1/2);
        
    case 8
        psi = 1/45045*F2.*(5937-20848*1i*X-37072*X.^2+36288*1i*X.^3+28000*X.^4-12544*1i*X.^5-5376*X.^6+1024*1i*X.^7+256*X.^8)*2002^(1/2);
        
    otherwise
        error(message('Wavelet:FunctionInput:InvalidGaussDeriv'));
end
intL2 = sum(psi.*conj(psi));
norL2 = intL2(end)*(X(2)-X(1));
psi   = psi/sqrt(norL2);
