function [A,D,Ascale] = dualtree(x,varargin)
% Kingsbury Q-shift 1-D Dual-tree complex wavelet transform
%   [A,D] = dualtree(X) returns the 1-D dual-tree complex wavelet transform
%   (DTCWT) of X. X is a real-valued vector, matrix, or timetable
%   containing a single vector or matrix variable, or with multiple
%   variables, each containing a column vector. If X is a matrix, the DTCWT
%   operates on the columns of X. X must have at least two samples. The
%   DTCWT is obtained by default down to level floor(log2(N)) where N is
%   the length of X if X is a vector and the row dimension of X if X is a
%   matrix. If N is odd, X is extended by one sample by reflecting the last
%   element of X.
%
%   By default, DUALTREE uses the near-symmetric biorthogonal filter pair
%   with lengths 5 (scaling filter) and 7 (wavelet filter) for level 1 and
%   the orthogonal Q-shift Hilbert wavelet filter pair of length 10 for
%   levels greater than or equal to 2. A is the matrix of real-valued
%   final-level scaling (lowpass) coefficients. D is a LEV-by-1 cell array
%   of complex-valued wavelet coefficients, where LEV is the level of the
%   transform.
%  
%   [A,D] = dualtree(X,'Level',LEV) obtains the 1-D dual-tree transform
%   down to level, LEV. LEV is a positive integer less than or equal to
%   floor(log2(N)) where N is the length of X if X is a vector and the row
%   dimension of X if X is a matrix.
%
%   [A,D] = dualtree(...,'LevelOneFilter',FAF) uses the biorthogonal
%   filter specified by the string or character array FAF, as the 
%   first-level analysis filter. Valid options for FAF are 'nearsym5_7'
%   ("nearsym5_7"), 'nearsym13_19', 'antonini', or 'legall'. If
%   unspecified, FAF defaults to 'nearsym5_7'.
%  
%   [A,D] = dualtree(...,'FilterLength',FLEN) uses the orthogonal Hilbert
%   Q-shift filter pair with length FLEN for levels two and higher. Valid
%   options for FLEN are 6, 10, 14, 16, and 18. If unspecified, FLEN
%   defaults to 10.
%
%   [A,D,Ascale] = dualtree(...) returns the scaling (lowpass) coefficients
%   at each level.
%  
%   % Example:
%   load noisdopp
%   [A,D] = dualtree(noisdopp,'Level',3,'LevelOneFilter','antonini',...
%       'FilterLength',10);
%
%   See also dualtree2, qorthwavf, qbiorthfilt

%   Kingsbury, N.G. (2001) Complex wavelets for shift invariant analysis 
%   and filtering of signals, Journal of Applied and Computational Harmonic
%   Analysis, vol 10, no. 3, pp. 234-253.

% Copyright 2019-2020 The MathWorks, Inc.
 


%#codegen

narginchk(1,7);
nargoutchk(0,3);
coder.internal.errorIf(isa(x,'timetable') && ~coder.target('MATLAB'),...
    'Wavelet:dualtree:ttcodegen');
if isa(x,'timetable') && coder.target('MATLAB')
    x = wavelet.internal.CheckAndExtractTT(x);
end
    
% Works only on real-valued input signals
validateattributes(x,{'double','single'},...
    {'real','finite','nonempty','2d'},'dualtree','X');

% Row convenience. Declare xtmp as coder.varsize because this may have to
% grow
coder.varsize('xtmp');
if isrow(x)
    xtmp = x(:);
else
    xtmp = x;
end

% Check for even-length, if not extend by one sample
Nr  = size(xtmp,1);
% Nr must be at least two.
coder.internal.errorIf(Nr < 2,'Wavelet:dualtree:siginputlen');
% If odd length, then we need to reflect the end by one row (sample) to
% obtain an even length vector.
if signalwavelet.internal.isodd(Nr)
   xtmp = [xtmp ; xtmp(Nr-1,:)]; 
end
params = parseinputs(Nr,varargin{:});


% Get the filters. For the first-level analysis filters we just get LoD and
% HiD. This is a biorthogonal filter
[LoD,HiD] = qbiorthfilt(params.biorth);
% For levels 2 and on, we use Q-shift filters
[LoDa,LoDb,HiDa,HiDb] = qorthwavf(params.qlen);
% cast filters 
LoD = cast(LoD,'like',xtmp);
HiD = cast(HiD,'like',xtmp);
LoDa = cast(LoDa,'like',xtmp);
LoDb = cast(LoDb,'like',xtmp);
HiDa = cast(HiDa,'like',xtmp);
HiDb = cast(HiDb,'like',xtmp);

% Initial lowpass and highpass filter outputs. At this point, we do not
% have two trees. Use the same biorthogonal linear-phase filter to filter x
% into the lowpass and highpass outputs.
coder.varsize('Lo','Hi');
Lo = wavelet.internal.colfilter(xtmp,LoD);
H1 = wavelet.internal.colfilter(xtmp,HiD);

% Allocate cell arrays for DTCWT coefficients. These will change size as we
% go down in resolution. As a result, we need a heterogenous data
% container.
if ~coder.target('MATLAB')
    D = assgnwav(x,params.level);
    Ascale = assgnscale(x,params.level);
else
    D = cell(params.level,1);
    Ascale = cell(params.level,1);
end

% Form DTCWT level-one coefficients by downsampling output of filtering the
% columns of the data with the wavelet filter
D{1} = H1(1:2:end,:)+1j*H1(2:2:end,:);


% If we want to keep the lowpass filter outputs at each level, we assign
% those.
if nargout > 2
     Ascale{1} = Lo;
end

% Obtain DTCWT for levels > 1
for kk = 2:params.level
    
    % If the number of elements in the lowpass part is not divisible by 4,
    % we need to extend. Since we are only allowing even-length inputs. The
    % only equivalence class we have to worry about is 2.
    % We achieve mod(L,4) = 0 by just adding two rows for mod(Lo,4) = 2
    if mod(size(Lo,1),4) ~= 0
        % Vert cat
        Lo = [Lo(1,:) ; Lo ; Lo(end,:)]; %#ok<AGROW>


    end
    
    Hi = wavelet.internal.evenOddFilter(Lo,HiDb,HiDa);
    Nhi = size(Hi,1);
    % Interleaved output 1:2:end from tree A, 2:2:end from tree B
    % Real part from tree A, Imaginary part from tree B
    D{kk} = Hi(1:2:Nhi,:)+1j*Hi(2:2:Nhi,:);
    % Filter lowpass filter output with tree B and tree A filters. We do
    % not interleave here.
    Lo = wavelet.internal.evenOddFilter(Lo,LoDb,LoDa);
    
       
    if nargout > 2
       Ascale{kk} = Lo;
    end
    
    
end

A = Lo;

%--------------------------------------------------------------------------
function params = parseinputs(Nr,varargin)
% Set default level
defaultLevel = floor(log2(Nr));
validLevel = @(x)validateattributes(x,{'numeric'},{'positive','integer',...
    '>=',1,'<=',defaultLevel});
validBiorth = {'nearsym5_7','nearsym13_19','antonini','legall'};
defaultBiorth = 'nearsym5_7';
% Default Q-shift filter length 
defaultQlen = 10;
validQ = @(x)ismember(x,[6 10 14 16 18]);


%tmpvarargin = cell(size(varargin));
%[tmpvarargin{:}] = convertStringsToChars(varargin{:});
if coder.target('MATLAB')
    p = inputParser;
    addParameter(p,'Level',defaultLevel,validLevel);
    addParameter(p,'LevelOneFilter',defaultBiorth);
    addParameter(p,'FilterLength',defaultQlen);
    p.parse(varargin{:});
    params.level = p.Results.Level;
    params.biorth = p.Results.LevelOneFilter;
    params.qlen = p.Results.FilterLength;    
    
    
else
    parms = struct('Level',uint32(0),...
        'LevelOneFilter',uint32(0),...
        'FilterLength',uint32(0));
    popts = struct('CaseSensitivity',false, ...
        'StructExpand',true,...
        'PartialMatching',true);
    
    pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
    level = ...
        coder.internal.getParameterValue(pstruct.Level,defaultLevel,varargin{:});
    params.level = level;
    biorth = ...
        coder.internal.getParameterValue(pstruct.LevelOneFilter,defaultBiorth,varargin{:});
    params.biorth = biorth;
    qlen = ...
        coder.internal.getParameterValue(pstruct.FilterLength,defaultQlen,varargin{:});
    params.qlen = qlen;
    
    
    
end

% Validate inputs
validLevel(params.level);
coder.internal.errorIf(~validQ(params.qlen),'Wavelet:dualtree:UnsupportedQ');
params.biorth = validatestring(params.biorth,validBiorth,'dualtree',...
    'LevelOneFilter');

function c = assgnwav(x,level)
% x is a numeric array of any size or type.
% level is a positive integer.
% This function is only needed for MATLAB code generation

c = cell(level,1);
[Nr,Nc] = size(x);
% Define some arbitrary size that depends on the dimensions of x. It might
% depend on other data. Each element, whether constant or not, is an upper
% bound on the actual run-time size of each element of the cell array.
sz = [Nr Nc];
INMATLAB = coder.target('MATLAB');
if ~INMATLAB
    coder.varsize('tmp');
    tmp = coder.nullcopy(complex(zeros(sz,'like',x)));
    % Assign each element of the cell array. Note in the report that the
    % elements have variable size.
    for k = 1:level
        c{k} = tmp;
    end
end

function c = assgnscale(x,level)
% x is a numeric array of any size or type.
% level is a positive integer.
% This function is only needed for MATLAB code generation

c = cell(level,1);
[Nr,Nc] = size(x);
% Define some arbitrary size that depends on the dimensions of x. It might
% depend on other data. Each element, whether constant or not, is an upper
% bound on the actual run-time size of each element of the cell array.
sz = [Nr Nc];
INMATLAB = coder.target('MATLAB');
if ~INMATLAB
    coder.varsize('tmp');
    tmp = coder.nullcopy(zeros(sz,'like',x));
    % Assign each element of the cell array. Note in the report that the
    % elements have variable size.
    for k = 1:level
        c{k} = tmp;
    end
end







