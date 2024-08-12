function x = mlptrecon(type,w,t,nj,moments,level,varargin)
%Multiscale 1-D Local Polynomial Transform Reconstruction
%   X = MLPTRECON(TYPE,W,T,NJ,SCALINGMOMENTS,LEVEL) reconstructs an
%   approximation to the data based on the TYPE of coefficients and the
%   LEVEL. TYPE is one of 'a' for approximation or 'd' for details. LEVEL
%   is a positive integer between 1 and length(NJ)-1, which is the level of
%   the multiscale local polynomial transform (MLPT). Increasing values of
%   LEVEL correspond to coarser resolution approximations or details. W, T,
%   NJ, and SCALINGMOMENTS are outputs of MLPT. W is a vector or matrix of
%   detail and scaling coefficients. T is the time vector or duration array
%   output of MLPT. NJ is the number of coefficients by level and
%   SCALINGMOMENTS are the scaling function moments.
%
%   X = MLPTRECON(...,'DualMoments',DM) uses DM dual vanishing moments. DM
%   is a positive integer between 2 and 4. The number of dual moments
%   should match the number used in MLPT. If unspecified, DM defaults to 2.
%
%   The number of primal moments used in the MLPT is captured by the
%   number of columns in SCALINGMOMENTS. It is not necessary to specify
%   a prefilter for MLPTRECON.
%
%   %  Example: 
%   %   Obtain a smoothed estimate of G-force measurements recorded from a
%   %   crash test dummy under motorcycle crash conditions. The smoothed 
%   %   estimate is obtained by reconstructing the level 4 approximation to 
%   %   the data.
%
%   load motorcycledata gmeasurements times;
%   [w,t,nj,scalingmoments] = mlpt(gmeasurements,times,'dualmoments',4,...
%   'primalmoments',4,'prefilter','none');
%   a4 = mlptrecon('a',w,t,nj,scalingmoments,4,'dualmoments',4);
%   plot(times,[gmeasurements a4]); grid on;
%   legend('Original Data','Smooth Fit');
%   xlabel('Seconds'); ylabel('G-force');
%
%   See also IMLPT, MLPT, MLPTDENOISE 

%   Copyright 2016-2020 The MathWorks, Inc.

%   References
%   The theory of the multiscale local polynomial transform and efficient 
%   algorithms for its computation were developed by Maarten Jansen. 
%
%   Jansen, M. (2013). Multiscale local polynomial smoothing in a lifted 
%   pyramid for non-equispaced data. IEEE Transactions on Signal
%   Processing, 61(3), 545-555.
%
%   Jansen, M. & Oonincx, P. (2005). Second Generation Wavelets and 
%   Applications. Springer Verlag. 

% Check number of input and output arguments
narginchk(6,8);
nargoutchk(0,1);

% Check for duration array input and convert
if isduration(t)
    t = wavelet.internal.convertDuration(t);
end
% Validating inputs
validatestring(type,{'a','d'},'MLPTRECON','TYPE');
validateattributes(w,{'double'},{'finite','nonempty','2d'},'MPLTRECON','W');
M = size(w,1);
validateattributes(nj,{'double'},{'nonempty','integer','increasing'},...
    'MLPTRECON','NJ');
Lmax = length(nj)-1;
validateattributes(level,{'numeric'},{'positive','integer','scalar',...
    'nonempty','<=',Lmax},'MLPTRECON','LEVEL');
LenT = nj(end);
Numcoefs = cumsum(nj);
if Numcoefs(end) ~= M
    error(message('Wavelet:mlpt:MLPTNJAgree','NJ','W'));
end
validateattributes(t,{'double'},{'finite','nonempty','increasing',...
    'size',[LenT 1]},'MLPTRECON','T');
validateattributes(moments,{'double'},{'finite','2d'},'MLPTRECON',...
    'SCALINGMOMENTS');
if size(moments,1) ~= M
    error(message('Wavelet:mlpt:MLPTMomentAgree','SCALINGMOMENTS','W'));
end


% Get the number of dual moments if provided
ndual = 2;
p = inputParser;
validateNdual = @(x)rem(x,1)== 0 && (x>=2 && x<=4);
addParameter(p,'DualMoments',ndual,validateNdual);
parse(p,varargin{:});
ndual = p.Results.DualMoments;

% Obtain the desired projection
Idx = coeffsubset(type,nj,level);
wtmp = zeros(size(w));
wtmp(Idx,:) = w(Idx,:);
x = wavelet.internal.imlpt(wtmp,t,nj,moments,ndual);



%------------------------------------------------------------------------
function Idx = coeffsubset(type,nj,level)
L = length(nj);
LevelIdx = cumsum(nj);
if strcmpi(type,'d')
    LevelIdx = flipud(LevelIdx);
    level = level+1;
    Idx = LevelIdx(level)+1:LevelIdx(level-1);
elseif strcmpi(type,'a')
    level = L-level;
    Idx = 1:LevelIdx(level+1);
end
