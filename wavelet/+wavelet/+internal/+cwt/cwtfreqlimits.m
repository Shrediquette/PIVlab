function [minfreq,maxperiod,maxscale,minscale,maxfreq,minperiod] = ...
    cwtfreqlimits(WAV,N,cutoff,ga,be,varargin)
%   This function is for internal use only. It may change or be removed
%   in a future release.
%   Determine high frequency cutoff (small scale) for
%   wavelets. This determines s0, the finest scale, in the CWT.
%   If the sampling period is entered, then the minperiod is given in those
%   units, while the maxfreq is normalized (Nyquist = 1/2). If the sampling
%   frequency is entered (in Hz), then the maxfreq is in Hz while the
%   minperiod is in samples.
%   [~,~,maxScale,s0] = wavelet.internal.cwt.cwtfreqlimits(...
%    wname,nbSamp,cutoff,ga,be,[],p,nv);

% Copyright 2017-2020 The MathWorks, Inc.
%#codegen

if coder.target('MATLAB')
    T = seconds(1);
else
    T = 1;
end
Fs = 1;
numsd = 2;
nv = 10;
WAV = lower(char(WAV));
omegac = pi;


if coder.target('MATLAB')
    if ~isempty(varargin) && isduration(varargin{1})
        T = varargin{1};
    end
end

if ~isempty(varargin) && isscalar(varargin{1}) && isnumeric(varargin{1})
    Fs = varargin{1};
    validateattributes(Fs,{'numeric'},{'positive','scalar'});
    if coder.target('MATLAB')
        T = seconds(1/Fs);
    else
        T = 1/Fs;
    end
end

 
if numel(varargin) >= 2
        numsd = varargin{2};
end
if numel(varargin) >= 3
        nv = varargin{3};
end


validateattributes(numsd,{'numeric'},{'integer','positive','scalar'});
validateattributes(nv,{'numeric'},{'integer','positive','scalar'});
% Cutoff is entered as percentage
cutoff = cutoff/100;
validateattributes(cutoff,{'double'},{'>=',0,'<=',1,'scalar'});

[FourierFactor, sigmat, cf] = wavelet.internal.cwt.wavCFandSD(WAV, ga, be);
maxscale = N/(sigmat * numsd);

% Translate cutoff to value on the wavelet magnitude response
switch WAV

    case 'morse'

        omegac = getFreqFromCutoffMorse(cutoff, cf, ga, be);

    case 'bump'

        omegac = getFreqFromCutoffBump(cutoff, cf);

    case 'amor'

        omegac = getFreqFromCutoffAmor(cutoff, cf);
end

if isempty(omegac)
    omegac = pi;
end

% Minimum scale
minscale = omegac/pi;

% If the max scale (min freq) is beyond the max freq, set it one step away
if maxscale < minscale*2^(1/nv)
    maxscale = minscale*2^(1/nv);
end

minperiod = minscale * FourierFactor * T;
maxfreq = 1 / (minscale * FourierFactor) * Fs;

maxperiod = maxscale * FourierFactor * T;
minfreq = 1 / (maxscale * FourierFactor) * Fs;

% guard against edge case

if maxfreq > Fs/2 || minperiod < 2*T
    maxfreq = Fs/2;
    minperiod = 2*T;
end


end



function omegac = getFreqFromCutoffAmor(cutoff, cf)
%
    alpha = 2*cutoff; 
    psihat = @(omega)alpha - 2*exp(-(omega-cf).^2/2);
    % maximum limit on zero search ensures frequency response goes to 0
    omax = ((2*750).^0.5+cf);
    if psihat(cf) > 0
        omegac = omax;
    else
        omegac = fzero(psihat,[cf omax]);
    end
end

function omegac = getFreqFromCutoffBump(cutoff, cf)
%
    sigma = 0.6;
    
    if cutoff < 10*eps(0)
        omegac = cf+sigma - 10*eps(cf+sigma);
    else
        alpha = 2*cutoff;
        psihat = @(om)1/(1-om^2)+log(alpha)-log(2)-1;
        epsilon = fzero(psihat,[0+eps(0) 1-eps(1)]);
        omegac = sigma*epsilon+cf;
    end
end

function omegac = getFreqFromCutoffMorse(cutoff, cf, ga, be)
%
    % the normalizing constant so that the 0-th order Morse wavelet at the
    % peak frequency is equal to 2. \gamma and \beta must be real-valued
    % and positive
    anorm = 2*exp(be/ga*(1+(log(ga)-log(be))));

    alpha = 2*cutoff;

    % Psi hat is how far above the desired frequency
    psihat = @(om)alpha - anorm*om.^be*exp(-om.^ga);
    % maximum limit on zero search ensures frequency response goes to 0
    omax = ((750).^(1/ga));
    if psihat(cf) >= 0
        if psihat(omax)==psihat(cf)
            omegac = omax;
        else
            omegac = cf;
        end
    else
        omegac = fzero(psihat,[cf omax]);
    end

end
