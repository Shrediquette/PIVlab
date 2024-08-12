function [wpt,packetlevels,F,E,RE] = modwpt(x,varargin)
%Maximal overlap discrete wavelet packet transform
%   WPT = MODWPT(X) returns the terminal nodes for the maximal overlap
%   discrete wavelet packet transform (MODWPT) for the real-valued 1-D
%   signal, X. The terminal nodes are at level 4 or level
%   floor(log2(numel(x))), whichever is smaller. The Fejer-Korovkin 18
%   filter, 'fk18', is used to obtain the MODWPT. At level 4, WPT is a
%   16-by-numel(x) matrix with each row containing the sequency-ordered
%   wavelet packet coefficients. The approximate passband for the n-th row
%   of WPT is [n-1/2^5, n/2^5) cycles/sample, n = 1,2,...16.
%
%   WPT = MODWPT(X,WNAME) uses the orthogonal wavelet filter specified by
%   the string, WNAME. Orthogonal wavelets are designated as type 1
%   wavelets in the wavelet manager. Valid built-in orthogonal wavelet
%   families begin with 'haar', 'dbN', 'fkN', 'coifN', 'blN', 'hanSR.LP',
%   'symN', 'vaid', or 'beyl'. Use waveinfo with the wavelet family short
%   name to see supported values for any numeric suffixes and how to
%   interpret those values, for example waveinfo('db'). You can check if
%   your wavelet is orthogonal by using wavemngr('type',wname) to see if a
%   1 is returned. For example, wavemngr('type','db2'). If you have LO and
%   HI as numeric vectors, you can use ISORTHWFB to determine
%   orthogonality. For example: 
%   [~,~,Lo,Hi] = wfilters('db2'); 
%   [tf,checks] = isorthwfb(Lo,Hi);
%
%   WPT = MODWPT(X,Lo,Hi) uses the orthogonal scaling filter, Lo, and
%   wavelet filter, Hi. Lo and Hi are even-length row or column vectors.
%   These filters must satisfy the conditions for an orthogonal wavelet. If
%   you specify WNAME, you cannot also specify a scaling and wavelet
%   filter. To agree with the usual convention in the implementation of
%   MODWPT in numerical packages, the roles of the analysis and synthesis
%   filters returned by WFILTERS are reversed in MODWPT. For example:
%   wt = modwpt(x,'db2') 
%   matches 
%   [~,~,Lo,Hi] = wfilters('db2') 
%   wt = modwpt(x,Lo,Hi)
%
%   WPT = MODWPT(...,LEVEL) returns the terminal nodes of the wavelet
%   packet tree at the positive integer level, LEVEL. The value of LEVEL
%   cannot exceed floor(log2(numel(X))). At level j, WPT is a
%   2^j-by-numel(X) matrix. The approximate passband for the n-th
%   row of WPT at level j is [(n-1)/2^(j+1), n/2^(j+1)) cycles/sample,
%   n = 1,2,...,2^j.
%
%   WPT = MODWPT(...,'FullTree',TREEFLAG) determines the type of wavelet
%   packet tree MODWPT returns. TREEFLAG can be one of the following
%   options [ true | {false}]. If you set 'FullTree' to true, MODWPT
%   returns the full wavelet packet tree down to the specified level. If
%   you specify TREEFLAG as false, MODWPT only returns the terminal
%   (final-level) wavelet packet nodes. If unspecified, TREEFLAG defaults
%   to false. For the full wavelet packet tree, WPT is a 2^(LEVEL+1)-2-by-N
%   matrix where N is the length of the data. The rows of WPT are the
%   sequency-ordered wavelet packet coefficients by level and index. There
%   are 2^j wavelet packets at each level j. You can specify the 'FullTree'
%   name-value pair  in the input argument list anywhere after the input
%   signal, X.
%
%   WPT = MODWPT(..., 'TimeAlign', ALIGNFLAG) circularly shifts the wavelet
%   packet coefficients in all nodes to correct for the delay of the
%   scaling and wavelet filters.  ALIGNFLAG can be one of the following
%   values: [ true | {false} ]. ALIGNFLAG defaults to false. By default,
%   MODWPT does not shift the wavelet packet coefficients. Shifting the
%   coefficients is useful if you want to time align features in the signal
%   with the wavelet packet coefficients. If you want to reconstruct the
%   signal with the inverse MODWPT, do not shift the coefficients. The time
%   alignment is performed in the inversion process. You can specify the
%   'TimeAlign' name-value pair anywhere in the input argument list after
%   the input signal, X.
%
%   [WPT,PACKETLEVELS] = MODWPT(...) returns a vector of transform levels
%   corresponding to the rows of WPT. If WPT contains only the terminal
%   level coefficients, PACKETLEVELS is a vector of constants equal to the
%   terminal level. If WPT contains the full wavelet packet table,
%   PACKETLEVELS is a vector with 2^j elements for each level, j. You can
%   use PACKETLEVELS with logical indexing to select all the wavelet packet
%   nodes at a particular level.
%
%   [WPT,PACKETLEVELS,F] = MODWPT(...) returns the center frequencies in
%   cycles/samples of the approximate passbands corresponding to the rows
%   of WPT. You can multiply F by a sampling frequency to convert to
%   cycles/unit time.
%
%   [WPT,PACKETLEVELS,F,E] = MODWPT(...) returns the energy (squared L2
%   norm) of the wavelet packet coefficients for the nodes in WPT. The sum
%   of energies (squared L2 norms) for the wavelet packets at each level is
%   equal to the energy in the signal.
%
%   [WPT,PACKETLEVELS,F,E,RE] = MODWPT(...) returns the relative energy
%   for the wavelet packets in WPT. The relative energy is the proportion
%   of energy contained in each wavelet packet by level. The sum of
%   relative energies contained in the wavelet packets at each level is
%   equal to 1.
%
%   %Example 1:
%   %   Obtain the MODWPT of an ECG waveform using the default wavelet
%   %   ('fk18') and level. Use the 'FullTree',true option to return the
%   %   full wavelet packet tree. Extract the level-three coefficients.
%   load wecg;
%   [wpt,packetlevels] = modwpt(wecg,'FullTree',true);
%   p3 = wpt(packetlevels==3,:);
%
%   %Example 2:
%   %   Obtain the time-aligned MODWPT of a two intermittent sine waves in
%   %   noise. The sine wave frequencies are 150 and 200 Hz.
%   dt = 0.001;
%   t = 0:dt:1-dt;
%   x = ...
%   cos(2*pi*150*t).*(t>=0.2 & t<0.4)+sin(2*pi*200*t).*(t>0.6 & t<0.9);
%   y = x+0.05*randn(size(t));
%   [wpt,~,F] = modwpt(x,'TimeAlign',true);
%   contour(t,F.*(1/dt),abs(wpt).^2); grid on;
%   xlabel('Time'); ylabel('Hz');
%   title('Time-Frequency Plot');
%
%   See also imodwpt, modwptdetails

%   Copyright 2015-2022 The MathWorks, Inc.

% Check number of input arguments
narginchk(1,8);
% Input parser - Parse remaining varargin inputs
% Assign defaults for variable input arguments
% Validate inputs
N = numel(x);
params = parseinputs(N,varargin{:});
validateinputs(x,params);
%Assign validated level to J
J = params.J;
%Ensure x is a row vector and obtains its squared L2 norm
x = x(:)';
L2NormX = norm(x,2)^2;
% This is the initial DFT length for the input
Nrep = N;
%Obtain the scaling and wavelet filters if specified
if isfield(params,'wname')
    [~,~,LoD,HiD] = wfilters(params.wname);
    wtype = wavemngr('type',params.wname);
    if (wtype ~= 1)
        error(message('Wavelet:modwt:Orth_Filt'));
    end
    %Normalize filters for MODWPT
    Lo = LoD/sqrt(2);
    Hi = HiD/sqrt(2);
    %if user provides filter pair, check to see if they are orthogonal
else
    %Normalize filters for MODWPT
    Lo = params.Lo./sqrt(2);
    Hi = params.Hi./sqrt(2);
    
end

% Ensure Lo and Hi are row vectors and data type matches.
Lo = Lo(:)';
Hi = Hi(:)';
Lo = cast(Lo,underlyingType(x));
Hi = cast(Hi,underlyingType(x));


% If the signal length is less than the filter length, need to
% periodize the signal in order to use the DFT algorithm
if (N<numel(Lo))
    x = [x repmat(x,1,ceil(numel(Lo)-N))];
    %Modify DFT length if necessary
    Nrep = numel(x);
end
% Obtain the DFT of the filters
% G is the DFT of the scaling filter, H is DFT of wavelet filter
G = fft(Lo,Nrep);
H = fft(Hi,Nrep);

% Obtain DFT of original data
X = fft(x,Nrep);

% Create array to hold wavelet packets and packet levels
% Initially create full tree
cfs = zeros(2^(J+1)-2,Nrep,'like',x);
cfs(1,:) = X;
packetlevels = repelem(1:J,2.^(1:J));
packetlevels = packetlevels(:);
% Indices for first level
Idx = 1:2;

% MODWPT algorithm

for kk = 1:J
    index = 0;
    %Determine first packet for a given level
    jj = 2^kk-1;
    if (kk>1)
        Idx = find(packetlevels == kk-1);
    end
    for nn = 0:2^kk/2-1
        index = index+1;
        X = cfs(Idx(index),:);
        [vhat,what] = modwptdec(X,G,H,kk);
        
        if isodd(nn)
            cfs(jj+2*nn,:) = what;
            cfs(jj+2*nn+1,:) = vhat;
        else
            cfs(jj+2*nn+1,:) = what;
            cfs(jj+2*nn,:) = vhat;
        end
    end
end

% Take the inverse Fourier transform to obtain the coefficients
wpt = ifft(cfs,[],2);

% Ensure output length matches signal length
wpt = wpt(:,1:N);

% Generating vector of frequencies by level if needed
if nargout > 2
    df = 1./2.^(packetlevels+1);
    idxfirst = 1;
    if (J>1)
        idxfirst = cumsum(2.^(0:J-1))';
    end
    
    df(idxfirst) = df(idxfirst)*(1/2);
    F = cell2mat(accumarray(packetlevels,df,[],@(x){cumsum(x)}));
    if ~params.fulltree
        F = F(end-2^J+1:end);
    end
end

if ~params.fulltree
    wpt = wpt(end-2^J+1:end,:);
    packetlevels = packetlevels(end-2^J+1:end);
end

%Calculate energies and relative energies if needed
if nargout>3
    E = sum(wpt.*conj(wpt),2);
    RE = E./L2NormX;
end

%Time shift packets
if params.timealign
    wpt = modwptphaseshift(wpt,Lo,Hi,J,params.fulltree);
end



%-------------------------------------------------------------------------
function [Vhat,What] = modwptdec(X,G,H,J)
% [Vhat,What] = modwptdec(X,G,H,J)

N = length(X);
upfactor = 2^(J-1);
Gup = G(1+mod(upfactor*(0:N-1),N));
Hup = H(1+mod(upfactor*(0:N-1),N));
Vhat = Gup.*X;
What = Hup.*X;

%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function params = parseinputs(siglen,varargin)
% Parse varargin and check for valid inputs
% Convert any strings to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});
% Assign defaults
params.J = bsxfun(@min,4,floor(log2(siglen)));
params.wname = 'fk18';
params.fulltree = false;
params.timealign = false;

%If varargin is empty, simply return defaults
if isempty(varargin)
    return;
end



% Find if the fulltree option is specified
% There are currently no 'fu..' wavelets
treematches = find(strncmpi('fulltree',varargin,2));

if any(treematches)
    fulltreetf = varargin{treematches+1};
    %validate the value is logical
    if ~isequal(fulltreetf,logical(fulltreetf))
        error(message('Wavelet:FunctionInput:Logical'));
    end
    varargin(treematches:treematches+1) = [];
    params.fulltree = fulltreetf;
end

%Find if the timealign option is specified
alignmatches = find(strncmpi('timealign',varargin,2));

if any(alignmatches)
    aligntruefalse = varargin{alignmatches+1};
    %validate the value is logical
    if ~isequal(aligntruefalse,logical(aligntruefalse))
        error(message('Wavelet:FunctionInput:Logical'));
    end
    varargin(alignmatches:alignmatches+1) = [];
    params.timealign = aligntruefalse;
end

% Only remaining char variable must be wavelet name
% We have already removed name-value pairs

tfchar = cellfun(@ischar,varargin);
if (nnz(tfchar) == 1)
    params.wname = varargin{tfchar>0};
elseif nnz(tfchar)>1
    error(message('Wavelet:FunctionInput:InvalidChar'));
end

% Only scalar input must be the level
tfscalar = cellfun(@isscalar,varargin);

% Check for numeric inputs
tffilters = cellfun(@isnumeric,varargin);

% At most 3 numeric inputs are supported
if nnz(tffilters)>3
    error(message('Wavelet:modwt:Invalid_Numeric'));
end

% If there are at least two numeric inputs, the first two must be the
% scaling and wavelet filters
if (nnz(tffilters)>1)
    idxFilt = find(tffilters,2,'first');
    params.Lo = varargin{idxFilt(1)};
    params.Hi = varargin{idxFilt(2)};
    params = rmfield(params,'wname');
    
end

% Any scalar input must be the level
if any(tfscalar)
    params.J = varargin{tfscalar>0};
end

% If the user specifies a filter, use that instead of default wavelet
if (isfield(params,'Lo') && any(tfchar))
    error(message('Wavelet:FunctionInput:InvalidWavFilter'));
end

%------------------------------------------------------------------------
function validateinputs(x,params)
%Input must be real-valued, double with no Infs or NaNs
validateattributes(x,{'double','single'},{'real','finite'},'modwpt','X');
%Input must be 1-D
if (~isrow(x) && ~iscolumn(x))
    error(message('Wavelet:modwt:OneD_Input'));
end

%Input must contain at least two samples
if (numel(x)<2)
    error(message('Wavelet:modwt:LenTwo'));
end

%J is the transform level
J = params.J;
validateattributes(J,{'double'},{'integer','positive'},'modwpt','LEVEL');

%Check the transform level does not exceed the maximum
N = numel(x);
if (J>floor(log2(N)))
    error(message('Wavelet:modwt:MRALevel'));
end

%------------------------------------------------------------------------
function shiftedwpt = modwptphaseshift(wpt,Lo,Hi,level,fulltreetf)
%   Provides time-aligned wavelet packets depending on the configuration of
%   the wavelet packet tree.
%   The time alignment is provided by Wickerhauser's center of energy
%   argument.

%Determine the size of the wavelet packets
if ~fulltreetf
    numnodes = 2^level;
    levels = level;
else
    numnodes = 2^(level+1)-2;
    levels = 1:level;
end

%Determine the center of energy
L = numel(Lo);
eScaling = sum((0:L-1).*Lo.^2);
eScaling = eScaling/norm(Lo,2)^2;
eWavelet = sum((0:L-1).*Hi.^2);
eWavelet = eWavelet/norm(Hi,2)^2;


bitvaluehigh = zeros(1,numnodes);
bitvaluelow = zeros(1,numnodes);
shiftedwpt = zeros(size(wpt),underlyingType(wpt));

% Compute phase shifts
m = 1;
for jj = 1:numel(levels)
    J = levels(jj);
    for nn = 0:2^J-1
        bitvaluehigh(m) = bitReversal(J,nn);
        bitvaluelow(m) = 2^J-1-bitvaluehigh(m);
        m = m+1;
    end
end


pJN = round(bitvaluelow*eScaling+bitvaluehigh*eWavelet);

for nn = 1:numnodes
    shiftedwpt(nn,:) = circshift(wpt(nn,:),[0 -pJN(nn)]);
end



%------------------------------------------------------------------------
function bitvalue = bitReversal(J,N)

L = J;
filtsequence = zeros(1,J);
while J>=1
    
    remainder = mod(N,4);
    if (remainder == 0 || remainder == 3)
        filtsequence(J) = 0;
        
    else
        filtsequence(J) = 1;
    end
    J = J-1;
    N = floor(N/2);
    
end

bitvalue = sum(filtsequence.*2.^(0:L-1));






