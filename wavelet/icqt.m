function [xrec,gdual] = icqt(cfs,g,fshifts,varargin)
%Inverse constant-Q transform using nonstationary Gabor frames
%   XREC = ICQT(CFS,G,FSHIFTS) returns the inverse constant-Q transform
%   XREC of the coefficients CFS. CFS is a matrix, cell array, or structure
%   array. G is the cell array of nonstationary Gabor constant-Q analysis
%   filters used to obtain the coefficients CFS. FSHIFTS is a vector of
%   frequency bin shifts for the constant-Q bandpass filters in G. ICQT
%   assumes by default that the original signal was real-valued. Use the
%   'SignalType' name-value pair to indicate the original input signal was
%   complex-valued. XREC is a vector if the input to CQT was a single
%   signal or a matrix if the CQT was obtained from a multichannel signal.
%   CFS, G, and FSHIFTS must be outputs of CQT.
%
%   XREC = ICQT(...,'SignalType',SIGTYPE) designates whether the original
%   signal was real- or complex-valued. Valid options for SIGTYPE are
%   'real' and 'complex'. If unspecified, SIGTYPE defaults to 'real'.
%
%   [XREC,GDUAL] = ICQT(...) optionally returns the dual frames used in the
%   synthesis of XREC as a cell array the same size as G. The dual frames
%   are the canonical dual frames derived from the analysis filters.
%
%   %Example:
%   %   Obtain the constant-Q transform of the Handel signal using the
%   %   'sparse' transform option. Invert the CQT and demonstrate perfect
%   %   reconstruction by showing the maximum absolute reconstruction error
%   %   and the relative energy error in dB.
%   load handel;
%   [cfs,f,g,fshifts] = cqt(y,'SamplingFrequency',Fs,...
%                           'TransformType','sparse');
%   xrec = icqt(cfs,g,fshifts);
%   max(abs(xrec-y))
%   20*log10(norm(xrec-y)/norm(y))
%
%   References:
%   Holighaus, N., Doerfler, M., Velasco, G.A., & Grill,T.
%   (2013) "A framework for invertible real-time constant-Q transforms",
%   IEEE Transactions on Audio, Speech, and Language Processing, 21, 4,
%   pp. 775-785.
%
%   Velasco, G.A., Holighaus, N., Doerfler, M., & Grill, Thomas. (2011)
%   "Constructing an invertible constant-Q transform with nonstationary
%   Gabor frames", Proceedings of the 14th International Conference on
%   Digital Audio Effects (DAFx-11), Paris, France.
%
%   See also CQT

%   Copyright 2017-2020 The MathWorks, Inc.

%#codegen

% Check number of input and output arguments
narginchk(3, 5);
nargoutchk(0, 2);
coder.internal.assert(numel(g) == numel(fshifts),...
    'Wavelet:FunctionInput:FrameShiftsNotEqual', 'G', 'FSHIFTS');

% Parse Inputs
nvPairs = struct('SignalType', uint32(0));
options = struct('PartialMatching', true);
pStruct = coder.internal.parseParameterInputs(nvPairs, options,...
    varargin{:});
sigType = validatestring(...
    coder.internal.getParameterValue(pStruct.SignalType, 'real',...
    varargin{:}), {'real', 'complex'}, 'ICQT', 'SignalType');

sigLen = sum(fshifts);
nWin = numel(g);
isMATLAB = isempty(coder.target);

if ~iscell(cfs) && ~isstruct(cfs)
    % The third dimension of the array gives the number of signals
    [nF, nT, nS] = size(cfs);
    % First permute back before reshaping
    tCFSPermute = ipermute(cfs, [2 1 3]);
    tCFSReshape = reshape(tCFSPermute, nF*nT, nS);
    
    if isMATLAB
        cfsCell = mat2cell(tCFSReshape, nT*ones(nF, 1), nS);
    else
        % mat2cell implementation using for loop
        % as there is no code generation support for mat2cell
        cfsCell = cell(nF, 1);
        idx = 0;
        for ii = 1 : nF
            cfsCell{ii} = tCFSReshape(idx + 1:idx + nT, 1 : nS);
            idx = idx + nT;
        end
    end
    
elseif ~iscell(cfs) && isstruct(cfs)
    % The third dimension of the array gives the number of signals
    [nF, nT, nS] = size(cfs.c);
    % First permute back before reshaping
    tCFSPermute = ipermute(cfs.c, [2 1 3]);
    tCFSReshape = reshape(tCFSPermute, nF*nT, nS);
    cfsCell = cell(nWin, 1);
    
    if isMATLAB
        idx = setdiff(1:nWin, [1 cfs.NyquistBin]);
        cfsCell(idx) = mat2cell(tCFSReshape, nT*ones(nF, 1), nS);
        % Put in DC and Nyquist coefficients
        cfsCell{1} = cfs.DCcfs;
        cfsCell{cfs.NyquistBin} = cfs.Nyquistcfs;
    else
        % mat2cell implementation using for loop
        % as there is no code generation support for mat2cell
        idx = 0;
        for ii = 1 : nWin
            if ii == 1
                %DC coefficients
                cfsCell{ii} = cfs.DCcfs;
            elseif ii == cfs.NyquistBin
                %Nyquist coefficients
                cfsCell{ii} = cfs.Nyquistcfs;
            else
                cfsCell{ii} = tCFSReshape(idx + 1:idx + nT, 1:nS);
                idx = idx + nT;
            end
        end
    end
    
else
    cfsCell = cfs;
    
end

% Scale coefficients prior to inversion
% Note: may be faster to do this prior to reforming into cell array
if  strcmpi(sigType, 'real')
    
    if isMATLAB
        cfsCell = cellfun(@(x)(sigLen/(2*size(x,1)))*x, cfsCell, 'uni', 0);
        
    else
        % Code to replace 'cellfun' function to find maximum number of
        % elements, as there is no code generation support for cellfun
        for ii = 1 : nWin
            cfsCell{ii} = (sigLen/(2*size(cfsCell{ii}, 1)))*cfsCell{ii};
        end
        
    end
    
elseif strcmpi(sigType,'complex')
    
    if isMATLAB
        cfsCell = cellfun(@(x)(sigLen/size(x, 1))*x, cfsCell, 'uni', 0);
        
    else
        % Code to replace 'cellfun' function to find maximum number of
        % elements, as there is no code generation support for cellfun
        for ii = 1 : nWin
            cfsCell{ii} = (sigLen/size(cfsCell{ii}, 1))*cfsCell{ii};
        end
        
    end
end

% This is the number of signals, all signals in the cell array of
% coefficients will have the same column size, so we just use the first one
numSignals = size(cfsCell{1}, 2);
positions = cumsum(fshifts);
N = positions(end);
positions = positions - fshifts(1);
xrec = complex(zeros(N, numSignals));

if isMATLAB
    m = cellfun(@(x)size(x, 1), cfsCell);
    
else
    % Code to replace 'cellfun' function to find maximum number of
    % elements, as there is no code generation support for cellfun
    cfsCellLen = numel(cfsCell);
    m = zeros(cfsCellLen, 1);
    for ii = 1:cfsCellLen
        m(ii) = size(cfsCell{ii}, 1);
    end
    
end

% Compute dual frames
gdual = wavelet.internal.dualcswindow(g, fshifts, m);

% Algorithm for computing inverse CQT due to Holinghaus and Velasco
for kk = 1:numel(gdual)
    gLen = length(gdual{kk});
    temp = fft(cfsCell{kk})*m(kk);
    winRange = mod(positions(kk) + (-floor(gLen/2) : ceil(gLen/2) - 1), N) + 1;
    temp = temp(mod([end - floor(gLen/2) + 1:end, 1:ceil(gLen/2)] - 1,...
        m(kk)) + 1, :);
    gDualTemp = gdual{kk}([gLen - floor(gLen/2) + 1:gLen, 1:ceil(gLen/2)]);
    if isMATLAB
        xrec(winRange, :) = xrec(winRange, :) + temp.*gDualTemp;
        
    else
        % Splitting times(.*) operation to support code generation
        prodTempGDual = complex(zeros(numel(winRange), numSignals));
        for ii = 1:numSignals
            prodTempGDual(:,ii) = temp(:,ii).*gDualTemp ;
        end
        xrec(winRange, :) = xrec(winRange, :) + prodTempGDual;
        
    end
    
end

if isMATLAB
    if strcmpi(sigType, 'real')
        xrec = ifft(xrec, 'symmetric');
        
    elseif strcmpi(sigType, 'complex')
        xrec = ifft(xrec);
        
    end
    
else
    % Code to replace symmetric and non-symmetric operations of ifft
    % as the 'symmetric' option is not supported for code generation
    if strcmpi(sigType, 'real')
        for ii = 1:numSignals
            if mod(N, 2) == 0
                xrec(:,ii) = [real(xrec(1, ii)); xrec(2:N/2, ii); ...
                    real(xrec(N/2 + 1, ii)); conj(xrec(N/2:-1:2, ii))];
                
            else
                xrec(:,ii) = [real(xrec(1)); xrec(2:(N + 1)/2, ii);...
                    conj(xrec((N + 1)/2:-1:2, ii))];
                
            end
        end
    end
    xrec = ifft(xrec);
    
end


