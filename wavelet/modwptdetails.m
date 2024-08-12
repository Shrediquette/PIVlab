function [W,packetlevels,F] = modwptdetails(x,varargin)
%Maximal overlap discrete wavelet packet details
%   W = MODWPTDETAILS(X) returns the maximal overlap discrete wavelet packet
%   (MODWPT) details for the real-valued 1-D signal, X.  The details are
%   returned for the terminal nodes of the wavelet packet transform at
%   level 4 or at level floor(log2(numel(X))), whichever is smaller. The
%   Fejer-Korovkin 18 filter, 'fk18', is used to obtain the MODWPT details.
%   At level 4, W is a 16-by-numel(X) matrix with each row containing the
%   sequency-ordered wavelet packet details. The approximate passband for
%   the n-th row of WPT is [(n-1)/2^5, n/2^5) cycles/sample, n = 1,2,...16.
%   The MODWPT details are zero-phase filtered projections of the signal
%   onto the subspaces corresponding to the wavelet packet nodes. The sum
%   of the MODWPT details over each sample reconstructs the original
%   signal.
%
%   W = MODWPTDETAILS(X,WNAME) uses the orthogonal wavelet filter specified
%   by the character vector WNAME. Orthogonal wavelets are designated as
%   type 1 wavelets in the wavelet manager. Valid built-in orthogonal
%   wavelet families begin with 'haar', 'dbN', 'fkN', 'coifN', 'blN',
%   'hanSR.LP', 'symN', 'vaid', or 'beyl'. Use waveinfo with the wavelet
%   family short name to see supported values for any numeric suffixes and
%   how to interpret those values, for example waveinfo('db'). You can
%   check if your wavelet is orthogonal by using wavemngr('type',wname) to
%   see if a 1 is returned. For example, wavemngr('type','db2'). If you
%   have LO and HI as numeric vectors, you can use ISORTHWFB to determine
%   orthogonality. For example:
%   [Lo,Hi] = wfilters('db2');
%   [tf,checks] = isorthwfb(Lo,Hi);
%
%   W = MODWPTDETAILS(X,Lo,Hi) uses the orthogonal scaling filter, Lo, and
%   wavelet filter, Hi. Lo and Hi are even-length row or column vectors.
%   These filters must satisfy the conditions for an orthogonal wavelet.
%   You can only specify either Lo and Hi or WNAME.
%
%   W = MODWPTDETAILS(...,LEVEL) returns the terminal nodes of the
%   wavelet packet tree at the positive integer level, LEVEL. The value of
%   LEVEL cannot exceed floor(log2(numel(X))). At level j, W is a
%   2^j-by-numel(x) matrix. The approximate passband for the n-th
%   row of W at level j is [(n-1)/2^(j+1), n/2^(j+1)) cycles/sample, n =
%   1,2,...2^j.
%
%   W = MODWPTDETAILS(...,'FullTree',TREEFLAG) determines the type of
%   wavelet packet tree MODWPTDETAILS returns. TREEFLAG can be one of the
%   following options [ true | {false}]. If you set 'FullTree' to true,
%   MODWPTDETAILS returns the full wavelet packet tree down to the
%   specified level. If you specify TREEFLAG as false, MODWPTDETAILS only
%   returns the terminal (final-level) wavelet packet nodes. If
%   unspecified, TREEFLAG defaults to false. For the full wavelet packet
%   tree, W is a 2^(level+1)-2-by-N matrix where N is the length of the
%   data. The rows of W are the sequency-ordered wavelet packet details by
%   level and index. There are 2^j wavelet packet details at each level j.
%   You can specify the 'FullTree' name-value pair in the input argument
%   list anywhere after the input signal, X.
%
%   [W,PACKETLEVELS] = MODWPTDETAILS(...) returns a vector of transform
%   levels corresponding to the rows of W. If W contains only the terminal
%   level coefficients, PACKETLEVELS is a vector of constants equal to the
%   terminal level. If W contains the full wavelet packet tree of details,
%   PACKETLEVELS is a vector with 2^j elements for each level, j. You
%   can use PACKETLEVELS with logical indexing to select all the MODWPT
%   details at a particular level.
%
%   [W,PACKETLEVELS,F] = MODWPTDETAILS(...) returns the center frequencies
%   in cycles/samples of the approximate passbands corresponding to the
%   MODWPT details in W. You can multiply F by a sampling frequency to
%   convert to cycles/unit time.
%
%   %Example 1:
%   %   Obtain the MODWPT details for an ECG signal sampled using the
%   %   default wavelet ('fk18') and level. Demonstrate that summing the
%   %   MODWPT details over each sample reconstructs the signal.
%   load wecg;
%   wptdetails = modwptdetails(wecg);
%   xrec = sum(wptdetails);
%   max(abs(wecg-xrec'))
%
%   %Example 2
%   %   Obtain the MODWPT details for a 100-Hz time-localized sine wave in
%   %   noise. The sampling rate is 1000 Hz. Obtain the MODWPT at level 4
%   %   using the 'fk22' wavelet. Plot the MODWPT details for packet number
%   %   4. The MODWPT details for the fourth packet at level four represent
%   %   a zero-phase filtering of the input signal with an approximate
%   %   passband of [3Fs/2^5, 4Fs/2^5) where Fs is the sampling frequency.
%   dt = 0.001;
%   t = 0:dt:1;
%   x = cos(2*pi*100*t).*(t>0.3 & t<0.7)+0.25*randn(size(t));
%   wptdetails = modwptdetails(x,'fk22');
%   p4 = wptdetails(4,:);
%   plot(t,cos(2*pi*100*t).*(t>0.3 & t<0.7));
%   hold on;
%   plot(t,p4,'r')
%   legend('Sine Wave','MODWPT Details');
%
%   See also modwpt, imodwpt

%   Copyright 2015-2021 The MathWorks, Inc.

%Check number of input arguments is between 1 and 6.
narginchk(1,6);



%Parse and validate input arguments
N = numel(x);
params = parseinputs(N,varargin{:});
validateinputs(x,params);

J = params.J;



%Ensure input signal is row vector
x = x(:)';
Nrep = N;

%Obtain the scaling and wavelet filters if specified
if isfield(params,'wname')
    [~,~,LoD,HiD] = wfilters(params.wname);
    wtype = wavemngr('type',params.wname);
    if (wtype ~= 1)
        error(message('Wavelet:modwt:Orth_Filt'));
    end
    Lo = LoD/sqrt(2);
    Hi = HiD/sqrt(2);
    %if user provides filter pair, check to see if they are orthogonal
else
    Lo = params.Lo./sqrt(2);
    Hi = params.Hi./sqrt(2);
    
end

% Ensure Lo and Hi are row vectors
Lo = Lo(:)';
Hi = Hi(:)';

% If the signal length is less than the filter length, need to
% periodize the signal in order to use the DFT algorithm

if (N <numel(Lo))
    x = [x repmat(x,1,ceil(numel(Lo)-N))];
    Nrep = numel(x);
end

% Obtain the DFT of the filters
G = fft(Lo,Nrep);
H = fft(Hi,Nrep);

% Obtain DFT of original data
X = fft(x,Nrep);


% Create array to hold wavelet packets
cfs = zeros(2^(J+1)-2,Nrep);
cfs(1,:) = X;
packetlevels = repelem(1:J,2.^(1:J));
packetlevels = packetlevels(:);
Idx = 1:2;

%MODWPT algorithm
for kk = 1:J
    index = 0;
    jj = 2^kk-1;
    if (kk>1)
        Idx = find(packetlevels == kk-1);
    end
    for nn = 0:2^kk/2-1
        index = index+1;
        X = cfs(Idx(index),:);
        [vhat,what] = modwptdecxcorr(X,G,H,kk);
        
        if isodd(nn)
            cfs(jj+2*nn,:) = what;
            cfs(jj+2*nn+1,:) = vhat;
            
        else
            cfs(jj+2*nn,:) = vhat;
            cfs(jj+2*nn+1,:) = what;
            
            
        end
    end
end

W = ifft(cfs,[],2);
%Ensure that column size of output is the length of the input signal
W = W(:,1:N);



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

%If 'FullTree' is false, reduce details to terminal nodes
if ~params.fulltree
    W = W(end-2^J+1:end,:);
    packetlevels = packetlevels(end-2^J+1:end);
end



%-------------------------------------------------------------------------
function [Vhat,What] = modwptdecxcorr(X,G,H,J)
% [Vhat,What] = modwptdecxcorr(X,G,H,J)

N = length(X);
upfactor = 2^(J-1);
Gup = abs(G(1+mod(upfactor*(0:N-1),N))).^2;
Hup = abs(H(1+mod(upfactor*(0:N-1),N))).^2;
Vhat = Gup.*X;
What = Hup.*X;


%-------------------------------------------------------------------------
function params = parseinputs(siglen,varargin)
% Parse varargin and check for valid inputs
% Convert any strings in varargin to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});



% Assign defaults
params.J = bsxfun(@min,4,floor(log2(siglen)));
params.wname = 'fk18';
params.fulltree = false;

if isempty(varargin)
    return;
end

%Look to see that the user has specified a fulltree option
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

% Only remaining char variable must be wavelet name
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
    
    if (length(params.Lo) < 2 || length(params.Hi) < 2)
        error(message('Wavelet:modwt:Invalid_Filt_Length'));
    end
    
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
validateattributes(x,{'double'},{'real','finite'},'modwptdetails','X');
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
validateattributes(J,{'double'},{'integer','positive'},...
    'modwptdetails','LEVEL');

%Check the transform level does not exceed the maximum
N = numel(x);
if (J>floor(log2(N)))
    error(message('Wavelet:modwt:MRALevel'));
end
