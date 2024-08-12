function xrec = idwpt(wpt,varargin)
%IDWPT Inverse wavelet packet 1-D transform
%   XREC = IDWPT(WPT,L) returns the inverse discrete wavelet packet
%   transform (idwpt) of the terminal node cell array WPT. The cell array
%   WPT and bookkeeping vector L are obtained from DWPT using the 'fk18'
%   wavelet and default settings. The input for IDWPT must have been
%   obtained from DWPT using the 'FullTree', false option. The 'FullTree'
%   false option is the default in DWPT. The wavelet packets must be
%   sequency-ordered. XREC is a column vector if the input to DWPT was a
%   single signal or a matrix if the DWPT was obtained from a multichannel
%   signal. Each matrix column corresponds to a channel.
%
%   XREC = IDWPT(...,WNAME) uses the wavelet specified in the character
%   array, WNAME, to invert the DWPT. WNAME must be recognized by WAVEMNGR.
%   WNAME must be the same wavelet used in the analysis with DWPT.
%
%   XREC = IDWPT(...,LoR,HiR) uses the scaling filter, LoR, and wavelet
%   filter, HiR. The synthesis filter pair LoR and HiR are both row or
%   column vectors. The synthesis filter pair must be associated to the
%   same wavelet used in the DWPT. You cannot specify both WNAME and a
%   filter pair, LoR and HiR. IDWPT does not check that LoR and HiR satisfy
%   the requirements for a perfect reconstruction wavelet packet filter
%   bank. See the documentation for an example of how to take a published
%   biorthogonal filter and ensure that the analysis and synthesis filters
%   produce a perfect reconstruction wavelet packet filter bank using
%   IDWPT.
%
%   XREC = IDWPT(...,'Boundary',ExtensionMode) specifies the mode to extend
%   the signal. ExtensionMode is one of 'reflection' (default) and
%   'periodic'. Setting ExtensionMode to 'periodic' or 'reflection', the
%   wavelet packet coefficients at each level are extended based on the
%   modes 'per' or 'sym' in dwtmode, respectively. ExtensionMode must be
%   the same mode used in the DWPT.
%
%   %Example: 
%   %   Obtain the DWPT of an ECG waveform. Invert the transform and
%   %   demonstrate perfect reconstruction by showing the maximum absolute
%   %   reconstruction error.
%
%      load wecg
%      [wpt,L] = dwpt(wecg);
%      XREC = idwpt(wpt,L);
%      max(abs(XREC-wecg))
%
%   See also dwpt, dwtmode, imodwpt.

%   Copyright 2019-2020 The MathWorks, Inc.

%#codegen

narginchk(2,7);
nargoutchk(0,1);

% Parse input
opts = parseInput(wpt,varargin{:});

% Construct decomposition struct
dec = constructDec(wpt,opts);

% Compute decomposition
xrec = wavelet.internal.mwptrec(dec);

end


% Parse input--------------------------------------------------------------
function opts = parseInput(wpt,varargin)
% Parse input signal and check for valid inputs
% Parse the input
validateattributes(wpt,{'cell'},{'nonempty'},'idwpt','input');
firstNode = wpt{1};
firstDataType = class(firstNode);

numNodes = length(wpt);
numLevel = log2(numNodes);
coder.internal.errorIf(numLevel ~= round(numLevel),...
    'Wavelet:idwpt:InvalidTerminalNode');

[channelInx,sampleInx,typeInx]= checkWPT(wpt,numNodes,firstDataType);
coder.internal.errorIf(~all(typeInx),'Wavelet:idwpt:InputMixedDataType');
coder.internal.errorIf(any(channelInx(2:end)~=channelInx(1)),...
    'Wavelet:idwpt:InvalidNumChannels');
coder.internal.errorIf(any(sampleInx(2:end)~=sampleInx(1)),...
    'Wavelet:idwpt:InvalidNumSamples')

opts = wavelet.internal.dwptParser(sampleInx(2),channelInx(1),...
    firstDataType,'idwpt',varargin{:});
opts.Level = numLevel;
coder.internal.errorIf(~isempty(opts.BookKeeping) &&...
    length(opts.BookKeeping)~=numLevel+1,...
    'Wavelet:idwpt:InvalidBookeepingLength',numLevel+1)
end

function dec = constructDec(wpt,opts)
% construct decomposition struct
Filters = struct('LoR',opts.Lowpass,'HiR',opts.Highpass);

if coder.target('MATLAB') || isa(wpt{1},opts.DataType)
    dec = struct('dirDec','c',...
    'dwtFilters',Filters,...
    'dwtEXTM',opts.ExtensionMode,...
    'sx',opts.BookKeeping,...
    'cfs',{wpt});
else
    wptConverted = coder.nullcopy(cell(1,length(wpt)));
    for iNode = 1:length(wpt)
        wptConverted{iNode} = cast(wpt{iNode},opts.DataType);
    end
end

end


function  [channelInx,sampleInx,typeInx]= checkWPT(wpt,numNodes,firstDataType)
% Check if the output cell array is valid
    if coder.target('MATLAB')
        arrayfun(@(x) validateattributes(x{:},{'single','double'},...
            {'nonnan','finite','2d','real'},'idwpt','WPT'),...
            wpt,'UniformOutput',true);
        channelInx = arrayfun(@(x) size(x{:},1),wpt,'UniformOutput',true);
        sampleInx = arrayfun(@(x) size(x{:},2),wpt,'UniformOutput',true);
        typeInx = arrayfun(@(x) strcmp(firstDataType,class(x{:})),wpt,'UniformOutput',true);
    else
         channelInx = zeros(1,numNodes);
         sampleInx = channelInx;
         typeInx = channelInx;
         for ii = 1:numNodes
             temp = wpt{ii};
             validateattributes(temp,{'single','double'},{'nonnan','finite','2d','real'});
             channelInx(ii) = size(temp,1);
             sampleInx(ii) = size(temp,2);
             typeInx(ii) = strcmp(firstDataType,class(temp));      
         end
    end

end
