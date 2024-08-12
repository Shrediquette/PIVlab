function [wft,frequencies] = waveft(WAV,omega,scales)
%WAVEFT Wavelet Fourier transform.
%   WAVEFT computes the wavelet values in the frequency plane.
%   For a wavelet defined by WAV, WFT = WAVEFT(WAV,OMEGA,SCALES)
%   returns the wavelet Fourier transform WFT.
%
%   WAV can be a string, structure or a cell array.
%   If WAV is a string, it contains the name of the wavelet
%   used for the analysis.
%   If WAV is a structure, WAV.name and WAV.param are respectively
%   the name of the wavelet and, if necessary, an associated parameter.
%   If WAV is a cell array, WAV{1} and WAV{2} contain the name of
%   the wavelet and an optional parameter.
%   OMEGA is a vector which contains the frequencies at which the
%   transform was computed.
%   SCALES is a vector which contains the scales used for the
%   wavelet analysis.
%   WFT is a matrix of size (NbScales x Nbfreq).
%
%   Admissible wavelets are:
%    - MORLET wavelet (A) - 'morl':
%        PSI_HAT(s) = pi^(-1/4) * exp(-(s>0)*(s-s0).^2/2) * (s>0)
%        Parameter: s0, default s0 = 6.
%
%    - MORLET wavelet (B) - 'morlex': (without Heaviside function)
%        PSI_HAT(s) = pi^(-1/4) * exp(-(s-s0).^2/2);
%        Parameter: s0, default s0 = 6.
%
%    - MORLET wavelet (C) - 'morl0':  (with exact zero mean value)
%        PSI_HAT(s) = pi^(-1/4) * [exp(-(s-s0).^2/2) - exp(-s0.^2/2)]
%        Parameter: s0, default s0 = 6.
%
%    - MEXICAN wavelet - 'mexh':
%        PSI_HAT(s) = (1/gamma(2+0.5))*s^2 .* exp((-s.^2)/2)
%        (DOG wavelet with m = 2)
%
%    - DOG wavelet - 'dog': m-th order Derivative Of Gaussian 
%        PSI_HAT(s) = -(1i^m/sqrt(gamma(m+0.5)))*((s)^m).*exp((-s.^2)/2)
%        Parameter: m (order of derivative), default m = 2. The order
%        m must be even.
%
%    - PAUL wavelet - 'paul':
%        PSI_HAT(s) = K*s^m.*exp(-s)
%        The constant K is such that:
%               K = (2^m)/sqrt(m*fact(2*m-1))
%        Parameter: m, default m = 4.
%   - Bump wavelet:  'bump':
%       PSI_HAT(s) = exp(1-(1/((s-mu)^2./sigma^2))).*(abs((s-mu)/sigma)<1)
%       Parameters: mu,sigma. 
%       default:    mu=5, sigma = 0.6.
%       Allowable parameter ranges:  3 <= mu <= 7
%                          0.1 < sigma <1.2
%       Normalized scales for the bump wavelet must be between 1.8 and 512.
%
%   PSI_HAT denotes the Fourier transform of PSI.
%
%   See also CWTFT, CWT, ICWTFT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Mar-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

param = [];
if isstruct(WAV)
    wname = WAV.name;
    param = WAV.param;
elseif iscell(WAV)
    wname = WAV{1};
    if length(WAV)>1 , param = WAV{2}; end
else
    wname = WAV;
end
StpFrq = omega(2);
NbFrq  = length(omega);
SqrtNbFrq = sqrt(NbFrq);
cfsNORM = sqrt(StpFrq)*SqrtNbFrq;
NbSc = length(scales);
wft = zeros(NbSc,NbFrq);

switch wname
    case 'morl'    % MORLET (A)
        if isempty(param) , gC = 6; else gC = param; end
        mul = (pi^(-0.25))*cfsNORM;
        for jj = 1:NbSc
            expnt = -(scales(jj).*omega - gC).^2/2.*(omega > 0);
            wft(jj,:) = mul*sqrt(scales(jj))*exp(expnt).*(omega > 0);
        end
        
        FourierFactor = gC/(2*pi);
        frequencies = FourierFactor./scales;
        
    case 'morlex'  % MORLET (B)
        if isempty(param) , gC = 6; else gC = param; end
        mul = (pi^(-0.25))*cfsNORM;
        for jj = 1:NbSc
            expnt = -(scales(jj).*omega - gC).^2/2;
            wft(jj,:) = mul*sqrt(scales(jj))*exp(expnt);
        end
        
        FourierFactor = gC/(2*pi);
        frequencies = FourierFactor./scales;
        
    case 'morl0'   % MORLET (C)
        if isempty(param) , gC = pi*sqrt(2/log(2)); else gC = param; end
        mul = (pi^(-0.25))*cfsNORM;
        for jj = 1:NbSc
            expnt  = -(scales(jj).*omega - gC).^2/2;
            correct = -(gC^2 +(scales(jj).*omega).^2)/2;
            wft(jj,:) = mul*sqrt(scales(jj))*(exp(expnt)-exp(correct));
        end
        
        FourierFactor = gC/(2*pi);
        frequencies = FourierFactor./scales;
                
    case 'mexh'
        mul = sqrt(scales/gamma(2+0.5))*cfsNORM;
        for jj = 1:NbSc
            scapowered = (scales(jj).*omega);
            expnt = -(scapowered.^2)/2;
            wft(jj,:) = mul(jj)*(scapowered.^2).*exp(expnt);
        end
        
        FourierFactor = sqrt(2+1/2)/(2*pi);
        frequencies = FourierFactor./scales;
        
    case 'dog'
            if isempty(param) , m = 2; 
            else m = param; 
                validateattributes(m,{'numeric'},{'scalar','even'});
            end
        mul = -((1i^m)/sqrt(gamma(m+0.5)))*sqrt(scales)*cfsNORM;
        for jj = 1:NbSc
            scapowered = (scales(jj).*omega);
            expnt = -(scapowered.^2)/2;
            wft(jj,:) = mul(jj).*(scapowered.^m).*exp(expnt);
        end
        
        FourierFactor = sqrt(m+1/2)/(2*pi);
        frequencies = FourierFactor./scales;

    case 'paul'
        if isempty(param) , m = 4; else m = param; end
        mul = sqrt(scales)*(2^m/sqrt(m*prod(2:(2*m-1))))*cfsNORM;
        for jj = 1:NbSc
            expnt = -(scales(jj).*omega).*(omega > 0);
            daughter = mul(jj)*((scales(jj).*omega).^m).*exp(expnt);
            wft(jj,:) = daughter.*(omega > 0);
        end
        
        FourierFactor = (2*m+1)/(4*pi);
        frequencies = FourierFactor./scales;
        
    case 'bump'
        if isempty(param)
            mu = 5; sigma = 0.6;
        else
            mu = param(1);
            sigma = param(2);
        end    
              
        for jj = 1:NbSc
            w = (scales(jj)*omega-mu)./sigma;
            expnt = -1./(1-w.^2);
            daughter = exp(1)*exp(expnt).*(abs(w)<1-eps(1));
            daughter(isnan(daughter)) = 0;
            wft(jj,:) = daughter;
        end
        
        FourierFactor = mu/(2*pi);
        frequencies = FourierFactor./scales;
        
    otherwise
        error(message('Wavelet:FunctionInput:InvWavNam'));
end

end     % {function}
