function [freq,xval,recfreq] = centfrq(wname,iter,plotflag)
%CENTFRQ Wavelet center frequency.
%   FREQ = CENTFRQ('wname') returns the center frequency in hertz
%   of the wavelet function 'wname' (see WAVEFUN).
%
%   For FREQ = CENTFRQ('wname',ITER), ITER is the number
%   of iterations used by the WAVEFUN function to compute
%   the wavelet. ITER has a default value of 8 when not specified.
%
%   [FREQ,XVAL,RECFREQ] = CENTFRQ('wname',ITER, 'plot')
%   returns in addition the associated center frequency based
%   approximation RECFREQ on the 2^ITER points grid XVAL
%   and plots the wavelet function and RECFREQ.
%
%   See also SCAL2FRQ, WAVEFUN, WFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Mar-98.
%   Last Revision: 20-Oct-2014.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 0
    wname = convertStringsToChars(wname);
end

if nargin > 2
    plotflag = convertStringsToChars(plotflag);
end

narginchk(1,3)

if nargin==1
    iter = 8;
end

validateattributes(iter, {'numeric'}, ...
    {'integer', 'positive', 'scalar'}, 'centfrq', 'iter');

% Retrieve wavelet.
wname = deblankl(wname);
wtype = wavemngr('type',wname);
switch wtype
  case 1
      [~,psi,xval] = wavefun(wname,iter);
  case 2
      [~,psi,~,~,xval] = wavefun(wname,iter);
  case 3
      [~,psi,xval] = wavefun(wname,iter);
  case 4
      [psi,xval] = wavefun(wname,iter);
  case 5
      [psi,xval] = wavefun(wname,iter);
end

T = max(xval)-min(xval);         % T is the size of the domain of psi.
n = length(psi);
psi = psi-mean(psi);             % psi is numerically centered.
psiFT = fft(psi);                % computation of the modulus
sp = (abs(psiFT));               % of the FT.

% Compute arg max of the modulus of the FT (center frequency).
Is_BIOR31 = isequal(wname,'bior3.1');
if ~Is_BIOR31
    [vmax,indmax] = max(sp);
    if indmax > n/2
        indmax = n-indmax+2;         % indmax is always >= 2.
    end
else
    [~,I,~] = localmax(sp(:)',1,false);
    indmax = I(1);                   % first local max 
    vmax = sp(indmax);    
end
per = T/(indmax-1);              % period corresponding to the maximum.
freq = 1/per;                    % associated frequency.

if (nargin > 2) && strcmp(plotflag, 'plot')

    % Recontruct the signal from only the largest magnitude element of FFT.
    psiFT(sp<vmax) = 0;
    if Is_BIOR31
        psiFT(sp>vmax) = 0;
    end
    recfreq = ifft(psiFT);
    recfreqreal = 0.75*max(abs(psi))*real(recfreq)/max(abs(recfreq));
    recfreqimag = 0.75*max(abs(psi))*imag(recfreq)/max(abs(recfreq));

    if wtype <= 4
        % For real valued wavelets, show only the real part
        plot(xval,psi,'-b',...
             xval,recfreqreal,'-r');
        title([getString(message('Wavelet:centfrq:PeriodLabel')) ': ' ...
            num2str(per) ' ' ...
            getString(message('Wavelet:centfrq:FreqLabel')) ': ' ...
            num2str(freq)])
        legend({[getString(message('Wavelet:centfrq:WaveletLegend')) ...
            ': ' wname], ...
            getString(message('Wavelet:centfrq:ApproxLegend'))})
    else
        % for complex wavelet without scale function (Type 5), show both
        % real and imaginary parts
        subplot(211)
        plot(xval,real(psi),'-b',...
             xval,recfreqreal,'-r');
        title([getString(message('Wavelet:centfrq:PeriodLabel')) ': ' ...
            num2str(per) ' '...
            getString(message('Wavelet:centfrq:FreqLabel')) ': ' ...
            num2str(freq)])
        legend({[getString(message('Wavelet:centfrq:WaveletLegend')) ...
            ': ' wname], ...
            getString(message('Wavelet:centfrq:ApproxLegend'))})
        ylabel(getString(message('Wavelet:centfrq:RealLabel')))

        subplot(212),
        plot(xval,imag(psi),'-b',...
             xval,recfreqimag ,'-r')
        legend({[getString(message('Wavelet:centfrq:WaveletLegend')) ...
            ': ' wname], ...
            getString(message('Wavelet:centfrq:ApproxLegend'))})
        ylabel(getString(message('Wavelet:centfrq:ImagLabel')))
    end
else
    recfreq = [];
end
