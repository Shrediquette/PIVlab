function mra = tqwtmra(wt,N,varargin)
% Tunable Q-factor multiresolution analysis 
%   MRA = TQWTMRA(WT,N) returns the tunable Q-factor wavelet
%   multiresolution analysis (MRA) for the TQWT analysis, WT, obtained with
%   the default quality factor of 1. WT is the cell array output of TQWT.
%   N is the original signal length in samples. If the original signal 
%   length N is odd, N is extended to N+1 to obtain the MRA and the final 
%   sample is removed before returning MRA.
%
%   MRA is an Ns-by-N-by-C-by-B array where Ns denotes number of subbands
%   in the tunable Q-factor wavelet transform ordered by decreasing center
%   frequency, N is the number of signal samples in time, C is the number
%   of channels, and B is the batch size.
%
%   MRA = TQWTMRA(WT,N,'QualityFactor',Q) uses the quality factor Q in
%   obtaining the tunable Q-factor MRA. Q must match the value used in
%   obtaining WT from TQWT.
%
%   TQWTMRA(...) with no output arguments plots the tunable Q-factor
%   wavelet MRA in a new figure. For complex-valued data, the real part
%   is plotted in the first color in the MATLAB color order matrix and the
%   imaginary part is plotted in the second color. This syntax does not
%   support multidimensional MRAs.
%   
%   % Example: Obtain and plot the tunable Q-factor wavelet MRA for an ECG
%   %   signal down to level 6 with a quality factor of 2.
%   load wecg
%   wt = tqwt(wecg,QualityFactor = 2, Level = 6);
%   tqwtmra(wt,numel(wecg),QualityFactor = 2)
%
%   % Example: Obtain the tunable Q-factor wavelet transform of the Kobe
%   %   earthquake data using a quality factor of 3. Identify the subbands
%   %   containing at least 15% of the total energy. Obtain a
%   %   multiresolution analysis and sum those MRA components corresponding
%   %   to previously identified subbands.
%   load kobe
%   wt = tqwt(kobe,QualityFactor = 3);
%   EnergyBySubband = cellfun(@(x)norm(x,2)^2,wt)./norm(kobe,2)^2*100;
%   bar(EnergyBySubband)
%   title('Percent Energy By Subband')
%   xlabel('Subband'), ylabel('Percent Energy')
%   idx15 = EnergyBySubband >= 15;
%   mra = tqwtmra(wt,numel(kobe),QualityFactor = 3);
%   ts = sum(mra(idx15,:));
%   figure
%   plot([kobe ts'])
%   legend('Original Data','Large Energy Components',...
%       'Location','NorthWest')
%
%   See also, tqwt, itqwt

%   Selesnick, Ivan W. "Wavelet Transform With Tunable Q-Factor."
%   IEEE Transactions on Signal Processing 59, no. 8 (2011): 3560-75. 
%   https://doi.org/10.1109/tsp.2011.2143711. 

% Copyright 2021 The MathWorks, Inc.

%#codegen
validateattributes(wt,{'cell'},{'nonempty'},'TQWTMRA','WT');
validateattributes(N,{'numeric'},{'scalar','positive','integer'},...
    'TQWTMRA','N');
OddSigLength = signalwavelet.internal.isodd(N);
if OddSigLength
    Norig = N;
    N = N+1;
else
    Norig = N;
end
if isempty(coder.target)
    isReal = all(cellfun(@(x)~any(imag(x(:))),wt));
    Ncfs = cellfun(@(x)size(x,1),wt);
%MATLAB Coder does not support cellfun()
else
    realcfs = false(length(wt),1);
    Ncfs = zeros(length(wt),1);
    for ii = 1:length(wt)
        realcfs(ii) = ~any(imag(wt{ii}(:)));
        Ncfs(ii) = size(wt{ii},1);
    end
    isReal = all(realcfs);
end

params = parseinputs(varargin{:});

[~,Nchan,Nbatch] = size(wt{1});
coder.internal.errorIf((Nchan > 1 || Nbatch > 1) && nargout == 0, ...
    'Wavelet:tqwt:MchannelPlot');
coder.internal.errorIf(nargout == 0 && ~isempty(coder.target), ...
    'Wavelet:tqwt:CoderPlot');


Level = length(wt)-1;
% Allocate memory for MRA
if isempty(coder.target)
    mratmp = zeros(Level+1,N,Nchan,Nbatch,'like',wt{end});
else
    mratmp = complex(zeros(Level+1,N,Nchan,Nbatch,'like',wt{end}));
end
for lev = Level:-1:1
    mratmp(lev,:,:,:) = ...
        iTQWTdetails(wt{lev},lev,N,Ncfs(1:end-1),params.Alpha,isReal);
    
end

mratmp(Level+1,:,:,:) = iTQWTsmooth(wt{Level+1},Level,N,Ncfs(1:end-1),...
    params.Alpha,isReal);

if isReal 
    mraNorig = real(mratmp(:,1:Norig,:,:));
else
    mraNorig = mratmp(:,1:Norig,:,:);
end

if nargout == 1
    mra = mraNorig;
elseif nargout == 0 && isempty(coder.target)
    if isReal
        mratype = 'RealTQWT';
    else
        mratype = 'ComplexTQWT';
    end
    hplot = wavelet.internal.mraPlot(mraNorig,mratype,1:Norig);
    % Prepare for next figure
    hplot.hFig.NextPlot = 'replacechildren';

end

%--------------------------------------------------------------------------
function details = iTQWTdetails(w,currlev,N,Ncfs,alpha,isReal)
[~,Nsig,Nbatch] = size(w);
coder.varsize('wavDFT');
coder.varsize('scalDFT');
coder.varsize('v');
wavDFT = wavelet.internal.tqwt.udft(w);
M = 2*round(alpha^currlev*N/2);
v = zeros(M,Nsig,Nbatch,'like',wavDFT);
% The following allocation is needed for codegen only
scalDFT = coder.nullcopy(zeros(M,Nsig,Nbatch,'like',wavDFT));
for jj = currlev:-1:1
    M = 2*round(alpha^(jj-1) * N/2);
    scalDFT = wavelet.internal.tqwt.synthesisFilterBank(v,wavDFT, M);
    if jj > 1
        wavDFT = zeros(Ncfs(jj-1),Nsig,Nbatch,'like',wavDFT);
    end
    v = scalDFT;
end

details = wavelet.internal.tqwt.uidft(scalDFT,isReal);

%--------------------------------------------------------------------------
function smooth = iTQWTsmooth(v,lev,N,Ncfs,alpha,isReal)
[~,Nsig,Nbatch] = size(v);
coder.varsize('scalDFT');
scalDFT = wavelet.internal.tqwt.udft(v);

for jj = lev:-1:1
   nullinput = zeros(Ncfs(jj),Nsig,Nbatch,'like',scalDFT);
   M = 2*round(alpha^(jj-1)*N/2);
   scalDFT =  wavelet.internal.tqwt.synthesisFilterBank(scalDFT,nullinput,M);
   
end
smooth = wavelet.internal.tqwt.uidft(scalDFT,isReal);


%--------------------------------------------------------------------------
function params = parseinputs(varargin)

params = struct('Beta',0.0,'Alpha',0.0);
parms = struct('QualityFactor',uint32(0));
defaultQ = 1;
% In 2021b, the redundancy ratio is fixed at 3.
R = 3;
% Structure array for options
popts = struct('CaseSensitivity',false,'PartialMatching',true);
% Parse structure array with options
pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
qfactor = ...
    coder.internal.getParameterValue(pstruct.QualityFactor,...
    defaultQ,varargin{:});
validateattributes(qfactor,{'numeric'},{'scalar','>=',1,'real'},...
    'TQWTMRA','QualityFactor');
% Both beta and alpha are computed based on the desired Q-factor and r
params.Beta = 2/(qfactor+1);
params.Alpha = 1-params.Beta/R;





