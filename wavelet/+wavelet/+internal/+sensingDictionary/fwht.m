function y = fwht(x)
% This function is for internal use only, it may change or be removed in a
% future release.
%FWHT Fast Discrete Walsh-Hadamard Transform
%   Y = FWHT(X) is the discrete Walsh-Hadamard transform of vector X. The
%   transform coefficients are stored in Y. If X is a matrix, the function
%   operates on each column.
%
%   % EXAMPLE 1: 
%      % Walsh-Hadamard transform of a signal made up of Walsh functions
%      w1 = [1 1 1 1 1 1 1 1];
%      w2 = [1 1 1 1 -1 -1 -1 -1];
%      w3 = [1 1 -1 -1 -1 -1 1 1];
%      w4 = [1 1 -1 -1 1 1 -1 -1];
%      x = w1 + w2 + w3 + w4; % signal formed by adding Walsh functions
%      y = fwht(x); % first four values of y should be equal to one

%   Copyright 2021 The MathWorks, Inc.
%#codegen

% error out if number of input arguments is not between 1 and 3
narginchk(1,3)
isMATLAB = coder.target('MATLAB');

validateattributes(x,{'double','single'},{'2d'},'fwht','x',1)

if isempty(x)
    y = cast([],'like',x);
    return
end
% check optional inputs' specifications and/or make default assignments
if nargin < 2 || (nargin >= 2 && isempty(N))
    if isvector(x)
        N1 = length(x);
    else
        N1 = size(x,1);
    end
    if isMATLAB
        isPowerof2 = bitand(uint64(N1),uint64(N1-1)) == uint64(0);
    else
        isPowerof2 = coder.internal.sizeIsPow2(N1);
    end
    if ~isPowerof2
        N1 = 2^nextpow2(N1);
    end
end
% do pre-processing on input signal if necessary
[x1,tFlag] = preprocessing(x,N1);
% calculate first stage coefficients and store in x
for i = 1:2:N1-1
    x1(i,:) = x1(i,:)   + x1(i+1,:);
    x1(i+1,:) = x1(i,:) - 2 * x1(i+1,:);
end
L = 1;
% same data type as x to enforce precision rules
y1 = zeros(size(x1),'like',x1);
for nStage = 2:log2(N1) % log2(N) = number of stages in the flow diagram
    % calculate coefficients for the ith stage specified by nStage
    M = 2^L;
    J = 0; K = 1;
    while (K < N1)
        for j = J+1:2:J+M-1
            y1(K,:)   = x1(j,:)   +  x1(j+M,:);
            y1(K+1,:) = x1(j,:)   -  x1(j+M,:);
            y1(K+2,:) = x1(j+1,:) -  x1(j+1+M,:);
            y1(K+3,:) = x1(j+1,:) +  x1(j+1+M,:);
            K = K + 4;
        end
        J = J + 2*M;
    end

    % store coefficients in x at the end of each stage
    x1 = y1;
    L = L + 1;
end
% perform scaling of coefficients
y1 = x1 ./ N1;
if tFlag
    y = transpose(y1);
else
    y = y1;
end
end


function [x1,tFlag] = preprocessing(x,N)
% this function performs zero-padding, truncation or input bit-reversal if
% necessary. NROWS amd MCOLS specify the output orientation which is kept
% same as that of input.

if isrow(x)
    xtemp = reshape(x,[],1);% column vectorizing input sequence
    tFlag = true;
else
    xtemp = x;
    tFlag = false;
end
n = size(xtemp,1);

if n < N
    x1 = [xtemp ; zeros(N-n,size(xtemp,2))];  % zero-pad
else
    % truncate
    x1 = xtemp(1:N,:);
end
end
%--------------------------------------------------------------------------

% LocalWords:  FWT sequency walsh IFWHT ith NROWS MCOLS
% LocalWords:  ispowerof nextpow
