function [fridge,iridge] = wsstridge(sst,varargin)
%Time-Frequency Ridges from Wavelet Synchrosqueezing
% FRIDGE = WSSTRIDGE(SST) extracts the maximum energy time-frequency ridge
% from the wavelet synchrosqueezed transform, SST. SST is the output of
% WSST. FRIDGE contains the frequencies in cycles/sample corresponding to
% the maximum energy time-frequency ridge at each sample.
%
% [FRIDGE,IRIDGE] = WSSTRIDGE(SST) returns the row indices in SST
% corresponding to maximum time-frequency ridge at each sample. Use IRIDGE
% to reconstruct along a time-frequency ridge using IWSST.
%
% [...] = WSSTRIDGE(SST,PENALTY) penalizes changes in frequency by scaling
% the squared distance between frequency bins by the nonnegative scalar
% PENALTY. If unspecified, PENALTY defaults to 0.
%
% [...] = WSSTRIDGE(...,F) outputs the maximum energy time-frequency ridge
% in cycles per unit time based on the input frequency vector, F. F is the
% frequency output of WSST. FRIDGE has the same units as F.
%
% [...] = WSSTRIDGE(...,'NumRidges',NR) extracts the NR highest energy
% time-frequency ridges. NR is a positive integer. If NR is greater than 1,
% WSSTTRIDGE iteratively determines the maximum energy time-frequency ridge
% by removing the previously computed ridges +/- 4 frequency bins. FRIDGE
% and IRIDGE are N-by-NR matrices where N is the number of time samples
% (columns) in SST. The first column of the matrices contains the
% frequencies or indices for the maximum energy time-frequency ridge in
% SST. Subsequent columns contain the frequencies or indices for the
% time-frequency ridges in decreasing energy order. You can specify the
% name-value pair NumRidges anywhere in the input argument list after the
% synchrosqueezed transform, SST.
%
% [...] = WSSTRIDGE(...,'NumRidges',NR,'NumFrequencyBins',NBINS) specifies
% the number of frequency bins to remove from the synchrosqueezed transform
% WSST when extracting multiple ridges. NBINS is a positive integer less
% than or equal to round(size(WSST,1)/4). Specifying NBINS is only valid
% when you extract more than one ridge. After extracting the highest energy
% time-frequency ridge, WSSTRIDGE removes energy from the synchrosqueezed
% transform, WSST, along the time-frequency ridge +/- NBINS before
% extracting the next highest-energy time-frequency ridge. If the index of
% the time-frequency ridge +/- NBINS exceeds the number of frequency bins
% at any time step, WSSTRIDGE truncates the removal region at the first or
% last frequency bin. If unspecified, NBINS defaults to 4.
%
%   %Example
%   %   Extract the two highest energy modes from a multicomponent signal.
%   %   Plot the wavelet synchrosqueezed transform, then extract two modes
%   %   and plot the result.
%   load multicompsig;
%   sig = sig1+sig2;
%   [sst,F] = wsst(sig,sampfreq);
%   contour(t,F,abs(sst));
%   xlabel('Time'); ylabel('Hz');
%   grid on;
%   title('Synchrosqueezed Transform of Two-Component Signal');
%   [fridge,iridge] = wsstridge(sst,10,F,'NumRidges',2);
%   hold on;
%   plot(t,fridge,'k','linewidth',2);
%   
%   See also iwsst, wsst

%   Copyright 2015-2020 The MathWorks, Inc.

%Check number of input arguments
narginchk(1,7)
validateattributes(sst,{'numeric'},{'finite','nonempty'},'wsstridge','sst');
if (iscolumn(sst) || isrow(sst))
    error(message('Wavelet:synchrosqueezed:InvalidMatrixInput'));
end
    

M = size(sst,1);
params = parseinputs(M,varargin{:});

penalty = params.penalty;
nbins = params.nbins;
nr = params.nr;
freqvector = params.freqvector;

if isempty(freqvector)
    Na = size(sst,1);
    N = size(sst,2);
    log2Fund = log2(1/N);
    log2Nyquist = log2(1/2);
    freqvector = 2.^linspace(log2Fund,log2Nyquist,Na);
end

% Call ExtractRidges
iridge = signalwavelet.internal.tfridge.extractRidges(sst,penalty,nr,nbins);


% Use indices of curve to extract physical frequencies
fridge = freqvector(iridge);

%-------------------------------------------------------------------------
function params = parseinputs(numrows,varargin)
% Set up defaults
% First convert any strings to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});
params.nr = 1;
params.nbins = 4;
params.penalty = 0;
params.freqvector = [];

tfnumridges = find(strncmpi(varargin,'numridges',4));

if any(tfnumridges)
    params.nr = varargin{tfnumridges+1};
    validateattributes(params.nr,{'numeric'},...
        {'integer','positive','scalar'},'wsstridge','NumRidges');
    varargin(tfnumridges:tfnumridges+1)  = [];
    if isempty(varargin)
        return;
    end
end

tfnumbins = find(strncmpi(varargin,'numfrequencybins',4));

%Error out if user specifies a number of frequency bins to clear
%without asking for more than 1 ridge.

if (any(tfnumbins) && params.nr==1)
    error(message('Wavelet:synchrosqueezed:InvalidRidgeNumber'));
elseif any(tfnumbins)
    params.nbins = varargin{tfnumbins+1};
    varargin(tfnumbins:tfnumbins+1)  = [];
    validateattributes(params.nbins,{'numeric'},{'positive','scalar',...
       '<=',round(numrows/4)},'wsstridge','NumFrequencyBins');
end

tfpenalty = cellfun(@(x) (isnumeric(x) & isscalar(x)),varargin);

if any(tfpenalty)
    params.penalty = varargin{tfpenalty};
    validateattributes(params.penalty,{'numeric'},{'scalar','>=',0},...
        'wsstridge','PENALTY');
    varargin(tfpenalty) = [];
end

tffreqvector = ...
    (cellfun(@isvector,varargin) & cellfun(@numel,varargin)== numrows);

if any(tffreqvector)
    params.freqvector = varargin{tffreqvector};
    validateattributes(params.freqvector,{'numeric'},...
        {'nonnegative','increasing'},'wsstridge','F');
end

% If there are any string inputs left after parsing, error out.
tfchar = cellfun(@ischar,varargin);
if any(tfchar)
    error(message('Wavelet:FunctionInput:UnrecognizedString'));
end
















