function [varargout] = dwpt(x,varargin)
%DWPT Wavelet packet 1-D transform
%   WPT = DWPT(X) returns the terminal (final-level) nodes of the discrete
%   wavelet packet transform (DWPT) of X. The Fejer-Korovkin 18, 'fk18',
%   wavelet is used for the DWPT. The decomposition level is
%   floor(log2(Ns)) where Ns is the number of data samples. X is a
%   real-valued vector, matrix, or timetable. If X is a matrix, the
%   transform is applied to each column of X. If X is a timetable, X must
%   either contain a matrix in a single variable or column vectors in
%   separate variables. X must be uniformly sampled. The output WPT is a
%   1-by-N cell array where N = 2^floor(log2(Ns)). Each
%   element of WPT is a vector or matrix. The coefficients in the j-th row
%   correspond to the signal in the j-th column of X. The packets are
%   sequency-ordered.
%
%   WPT = DWPT(...,WNAME) uses the wavelet specified by the character array,
%   WNAME. WNAME must be recognized by WAVEMNGR. The default wavelet is
%   'fk18'.
%
%   WPT = DWPT(...,LoD,HiD) uses the scaling filter, LoD, and wavelet
%   filter, HiD. LoD and HiD are both row or column vectors. You cannot
%   specify both WNAME and a filter pair, LoD and HiD. DWPT does not check
%   that LoD and HiD satisfy the requirements for a perfect reconstruction
%   wavelet packet filter bank. See the documentation for an example of how
%   to take a published biorthogonal filter and ensure that the analysis
%   and synthesis filters produce a perfect reconstruction wavelet packet
%   filter bank using DWPT.
%
%   WPT = DWPT(...,'Level',LEVEL) specifies the decomposition level. LEVEL
%   is a positive integer less than or equal to floor(log2(Ns)) where Ns is
%   the number of samples in the data. If unspecified, LEVEL defaults to
%   floor(log2(Ns)).
%
%   WPT = DWPT(...,'FullTree',TREEFLAG) specifies whether the full wavelet
%   packet tree is returned. When TREEFLAG is set to true, WPT is the full
%   wavelet packet tree. When TREEFLAG is set to false, WPT contains only
%   the terminal nodes. TREEFLAG defaults to false.
%
%   WPT = DWPT(...,'Boundary',ExtensionMode) specifies the mode to extend
%   the input during decomposition. ExtensionMode is one of 'reflection'
%   (default) and 'periodic'. Setting ExtensionMode to 'periodic' or
%   'reflection', the wavelet packet coefficients at each level are
%   extended based on the modes 'per' or 'sym' in dwtmode, respectively.
%
%   [WPT,L] = DWPT(...) returns the bookkeeping vector. L is a vector
%   containing the length of the input signal and the number of
%   coefficients by level. The output L is required for perfect
%   reconstruction.
%
%   [WPT,L,PACKETLEVELS] = DWPT(...) returns the transform levels of the
%   nodes in WPT as a vector. The i-th element of PACKETLEVELS corresponds
%   to the i-th element of WPT. If WPT contains only the terminal nodes,
%   PACKETLEVELS is a vector with each element equal to the terminal level.
%   If WPT contains the full wavelet packet tree, PACKETLEVELS is a vector
%   with 2^j elements for each level, j.
%
%   [WPT,L,PACKETLEVELS,F] = DWPT(...) returns the center frequencies of
%   the approximate passbands in cycles/sample. The j-th element of F
%   corresponds to the j-th wavelet packet node of WPT. You can multiply
%   the elements in F by a sampling frequency to convert to cycles/unit
%   time.
%
%   [WPT,L,PACKETLEVELS,F,RE] = DWPT(...) returns the relative energy for
%   the wavelet packets in WPT. The relative energy is the proportion of
%   energy contained in each wavelet packet by level. RE is a cell array
%   where the j-th element corresponds to the j-th wavelet packet node of
%   WPT. Each element of RE is a scalar if taking the DWPT of one signal.
%   If taking the DWPT of M signals, each element of RE is a M-by-1
%   vector, where the i-th element is the relative energy of the i-th
%   signal channel. For each channel, the sum of relative energies in the
%   wavelet packets at a given level is equal to 1.
%
%   % Example: 
%   %   Load the Espiga3 dataset. The data consists of 23 EEG signals 
%   %   sampled at 200 Hz. Compute the 1-D DWPT of the dataset using the
%   %   wavelet 'sym3' down to level of 4. Extract the final-level 
%   %   coefficients of the 5-th channel.
%
%   load Espiga3
%   wpt = dwpt(Espiga3,'sym3','Level',4); 
%   p5 = cell2mat(cellfun(@(x) x(5,:).',wpt,'UniformOutput', false));
%
%   See also dwtmode, idwpt, modwpt.

%   Copyright 2019-2020 The MathWorks, Inc.

%#codegen

narginchk(1,9);
nargoutchk(0,5);

% Parse input
[data,opts] = parseInput(x,varargin{:});

% Compute decomposition
dec= wavelet.internal.mwptdec('c',data,opts.Level,opts.Lowpass,...
    opts.Highpass,opts.FullTree,opts.ExtensionMode);

% Compute the level indexes of the nodes in the coefficient cell array
levelIndex = cast(repelem((1:opts.Level).',2.^(1:opts.Level).'),opts.DataType);
 
varargout{1} = dec.cfs;
 
if nargout > 1
    varargout{2} = cast(dec.sx,opts.DataType);   
end

if nargout > 2
    if opts.FullTree  
        varargout{3} = levelIndex;
    else % just one level
        varargout{3} = levelIndex(end-2^opts.Level+1:end);
    end   
end

% Generating vector of frequencies by level if needed
if nargout > 3
    F = computeCentralFreq(levelIndex,opts);
    varargout{4} = F;
end

% Generating vector of frequencies by level if needed
if nargout > 4
    RE = computeRE(dec.cfs,length(levelIndex),opts);
    varargout{5} = RE;
end

end

% Parse input--------------------------------------------------------------
function [data,opts] = parseInput(x,varargin)
% Parse input signal and check for valid inputs
% Parse the input    
isTT = isa(x,'timetable');
if isTT
    if ~coder.target('MATLAB')
        error(message('Wavelet:dwpt:TimetableNotSupportedCodegen')); 
    else
        signalwavelet.internal.util.utilValidateattributesTimetable(x,...
            {'sorted','multichannel','regular'});
        % ensure data type is double or single for all the variables
        if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform'))...
                && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
            error(message('Wavelet:dwpt:InvalidTimeTableMixedType'));
        end
        x = x{:,:};
    end     
    validateattributes(x, {'single','double',},{'nonnan',...
        'finite','real', 'nonsparse','2d'},'dwpt','the variable of the timetable X');
else
    validateattributes(x, {'single','double','timetable'},{'nonnan',...
            'finite','real', 'nonsparse','2d'},'dwpt','X');
    if isrow(x)
        x = x(:);
    end
end
coder.internal.errorIf(size(x,1)<2,'Wavelet:dwpt:InvalidNumDataSamples');

%Check for valid parameter inputs
opts = wavelet.internal.dwptParser(size(x,1),size(x,2),class(x),'dwpt',varargin{:});

%Convert data type
data = cast(x,opts.DataType);
end

function F = computeCentralFreq(levelIndex,opts)
% Compute central frequency at each level
    Ftemp = zeros(size(levelIndex),opts.DataType);
    idx = 0;
    for k = 1:double(opts.Level)
        p2 = bitshift(1,k);
        df = cast(1/(p2*2),opts.DataType);
        idx = idx + 1;
        Ftemp(idx) = df/2;
            for i = 2:p2
                idx = idx + 1;
                Ftemp(idx) = Ftemp(idx - 1) + df;
            end
    end
    if ~opts.FullTree
        F = Ftemp(end-2^opts.Level+1:end);
    else
        F = Ftemp;
    end
end


function RE = computeRE(W,L,opts)
% Compute relative energy
    coder.varsize('RE');
    if ~opts.FullTree
        RE = coder.nullcopy(cell(length(W),1));
        RE{1} = zeros(opts.NumChannels,1,opts.DataType);
        toltalE = zeros(opts.NumChannels,1,opts.DataType);
        for iNode = 1:length(W)
            RE{iNode} = diag(W{iNode}*W{iNode}.');
            toltalE = toltalE + RE{iNode}; 
        end
        for iNode = 1:length(W)
            RE{iNode} = RE{iNode}./toltalE;
        end
    else
        RE = coder.nullcopy(cell(L,1));
        count = 0;
        RE{1} = zeros(opts.NumChannels,1,opts.DataType);
        for iLev = 1:opts.Level
            nodeIndex = count+1:count+2^iLev;
            toltalE = zeros(opts.NumChannels,1,opts.DataType);
            for iNode = nodeIndex(1):nodeIndex(end)
                RE{iNode} = diag(W{iNode}*W{iNode}.');
                toltalE = toltalE + RE{iNode};
            end
            for iNode = nodeIndex(1):nodeIndex(end)
                RE{iNode} = RE{iNode}./toltalE;
            end
            count = count+2^iLev;
        end
    end
end
