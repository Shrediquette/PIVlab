function xrec = imlpt(w,t,nj,moments,varargin)
%Inverse Multiscale Local 1-D Polynomial Transform
%   XREC = IMLPT(W,T,NJ,SCALINGMOMENTS) returns the inverse multiscale
%   local polynomial transform (MLPT) of W. The inputs to IMLPT must be
%   outputs of MLPT. W is a vector or matrix of detail and scaling
%   coefficients. T is the time vector or duration array used in the MLPT. 
%   NJ is the number of coefficients by level and SCALINGMOMENTS are
%   the scaling function moments.
%
%   XREC = IMLPT(...,'DualMoments',DM) uses DM dual vanishing moments in
%   inverting the MLPT. DM is a positive integer between 2 and 4. The
%   number of dual moments must match the number used in MLPT. If
%   unspecified, DM defaults to 2.
%
%   The number of primal moments used in the inverse MLPT is captured by
%   the number of columns in SCALINGMOMENTS. It is not necessary to specify
%   a prefilter for IMLPT.
%
%   % Example:
%   %   Obtain the MLPT of the noisy skyline signal. Invert the MPLT
%   %   and demonstrate perfect reconstruction.
%
%   load skyline;
%   [w,t,nj,scalingmoments] = mlpt(y,T);
%   yrec = imlpt(w,t,nj,scalingmoments);
%   max(abs(yrec-y))
%
%   See also MLPT, MLPTDENOISE, MLPTRECON

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


% There must be at least 4 inputs
narginchk(4,6);
% There is only 1 output of IMLPT
nargoutchk(0,1);
if isduration(t)
    t = wavelet.internal.convertDuration(t);
end
% Validating inputs
validateattributes(w,{'double'},{'finite','nonempty','2d'},'IMPLT','W');
M = size(w,1);
validateattributes(nj,{'double'},{'nonempty','integer','increasing'},...
    'IMPLT','NJ');
LenT = nj(end);
Numcoefs = sum(nj);
if Numcoefs ~= M
    error(message('Wavelet:mlpt:MLPTNJAgree','NJ','W'));
end
validateattributes(t,{'double'},{'finite','nonempty','increasing',...
    'size',[LenT 1]},'IMLPT','T');
validateattributes(moments,{'double'},{'finite','2d'},'IMLPT',...
    'SCALINGMOMENTS');
if size(moments,1) ~= M
    error(message('Wavelet:mlpt:MLPTMomentAgree','SCALINGMOMENTS','W'));
end

% Get the number of dual moments if provided
p = inputParser;
% Default number of vanishing moments
ndual = 2;
validateNdual = @(x)rem(x,1)== 0 && (x>=2 && x<=4);
addParameter(p,'DualMoments',ndual,validateNdual);
parse(p,varargin{:});
ndual = p.Results.DualMoments;

xrec = wavelet.internal.imlpt(w,t,nj,moments,ndual);


