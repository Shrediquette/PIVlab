function [XBP,MSE,lambda] = tallBPDN(tX, Y, varargin)
%TALLBPDN Perform Basis Pursuit De-noising for tall arrays.
% Internal use only.
%   [XBP, MSE,lambda] = BPDN(A,Y,'RelTol',rTol,'AbsTol',aTol,'MaxIter',maxIt)
%   returns the estimate XBP of the sparse signal X such that Y = AX using
%   the basis pursuit denoising algorithm. Both A and Y must be tall
%   arrays. XBP corresponds to the estimate with minimum mean squared error
%   MSE. lambda is the lagrangian parameter that corresponds to the
%   estimate. The algorithm uses a relative tolerance rTol, absolute
%   tolerance aTol and maximum number of iterations maxIt for calculating
%   the estimate.
%
%   See also lasso.

%   Copyright 2021 The MathWorks, Inc.

% Parse and validate input arguments
narginchk(2, 10);
tall.checkIsTall(upper('basisPursuit'), 2, Y);
Y = tall.validateColumn(Y, 'Wavelet:sensingDictionary:unsupportedtallY');
isYSingle = isaUnderlying(Y,'single');
tY = double(Y);

if nargin > 3
    tall.checkNotTall(upper('basisPursuit'), 2, varargin{:});
    [varargin{:}] = convertStringsToChars(varargin{:});
end

par = parseArgs(varargin{:});
relTol = par.Results.RelTol;
absTol = par.Results.AbsTol;
maxIter = par.Results.MaxIter;
maxErr = par.Results.MaxErr;

% Filter out bad data
isAllFiniteRows = @(x)all(isfinite(x),2);
okrows = isAllFiniteRows(tX) & isAllFiniteRows(tY);
tX = hFilterslices(okrows,tX);
tY = hFilterslices(okrows,tY);

% Standardization and apply weights
[tX0, tY0] = standardizeWithWeights(tX,tY);
[n,p] = size(tX);

ATA = tX0'*tX0;
ATb = tX0'*tY0;
bTb = tY0'*tY0;

import matlab.bigdata.internal.broadcast
ATA = hSlicefun(@(tf, x) iCastIfSingle(tf, x), broadcast(isYSingle), ATA);
ATb = hSlicefun(@(tf, x) iCastIfSingle(tf, x), broadcast(isYSingle), ATb);
bTb = hSlicefun(@(tf, x) iCastIfSingle(tf, x), broadcast(isYSingle), bTb);

[ATA, ATb, bTb, n, p] = gather(ATA,ATb,bTb, n, p);

% Initialization
z = zeros(p,1,'like',ATA);
u = zeros(p,1,'like',ATA);
lambdaSeq = defaultLambdaSeq(ATb,n);
rho = optimRho(ATA);
relaxation = 1.5;

if isa(ATA,'single')
    lambdaSeq = single(lambdaSeq);
    rho = single(rho);
    relaxation = single(relaxation);
    n = single(n);
    p = single(p);
end

% Initialize outputs
l = length(lambdaSeq);
B = zeros(p,l,'like',ATA);
history = cell(1,l);

[L,U] = cholFactors(ATA,rho);
C = U\(L\ATb);

% Start with the first lambda
[B(:,l),u,history{l}] = ADMM(L,U,ATA,ATb,bTb,C,n,p,...
    lambdaSeq(l),rho,relaxation,z,u,absTol,relTol,maxIter);

nullMSE = bTb/n;
if l >1
    for i = (l-1):-1:1
        % Warm start with the results of the previous lambda
        [B(:,i), u,history{i}] = ADMM(L,U,ATA,ATb,bTb,...
            C,n,p,lambdaSeq(i),rho,relaxation,B(:,i+1),u,absTol,relTol,maxIter);
        
        if history{i}.mse(end) < 1e-3*nullMSE
            B = B(:,i:end);
            history = history(:,i:end);
            lambdaSeq = lambdaSeq(i:end);
            break;
        end
    end
end

Lambda = lambdaSeq(:)';
histMSE = cellfun(@(x)x.mse(end),history);
indMSE = find(histMSE <= maxErr,1);

if isempty(indMSE)
    [mMSE,immse] = min(histMSE);
    MSE = real(mMSE);
    XBP = B(:,immse);
    lambda = Lambda(immse);
else
    mMSE = histMSE(indMSE);
    MSE = real(mMSE);
    XBP = B(:,indMSE);
    lambda = Lambda(indMSE);
end

% Helper functions:
function par = parseArgs(varargin)
par = inputParser();
validator = @(x,sz,varargin)validateattributes(x,{'numeric'},...
    [{sz,'real','positive','finite','nonnan'},varargin],'basisPursuit');
par.addParameter('RelTol', 1e-4,@(x)validator(x,'scalar'));
par.addParameter('AbsTol', 1e-5,@(x)validator(x,'scalar'));
par.addParameter('MaxIter', 1e4, @(x)validator(x,'scalar'));
par.addParameter('MaxErr', 1e-4, @(x)validator(x,'scalar'));
par.parse(varargin{:});


function rho =  optimRho(Q)
if (Q == 0)
    rho = eps;
else
    eigValues = eig(Q);
    eigValues = eigValues(eigValues > length(eigValues)*eps(max(eigValues)));
    rho = sqrt(max(eigValues)*min(eigValues));
end

function lambdaSeq = defaultLambdaSeq(ATy,n)
numLambda = 100;
lambdaRatio = 1e-4;
lambdaMax = max(abs(ATy/n));
seqFun = @(m,r,n)exp(linspace(log(m*r),log(m),n));
lambdaSeq = seqFun(lambdaMax,lambdaRatio,numLambda);

function [wX0, wy0] = standardizeWithWeights(A,y)
muY = 0;
sigmaA = 1;
wX0 = (A)./sigmaA;
wy0 = y - muY;

function [L, U] = cholFactors(xtx, rho)
L = chol(xtx+rho*eye(size(xtx,1)), 'lower');
U = L';

function[z,u,history] = ADMM(L,U,ATA,ATY,yTy,C,n,p,lambda, rho,alpha,z,u,...
    absTol,relTol,maxIt)


objFun = @(beta,z)BPDNObjective(ATA,ATY,yTy,beta,z,lambda,n);

for k = 1: maxIt
    
    % x-update
    x = C + (U)\(L\(rho*(z-u)));
    
    % z-update
    zold = z;
    x_hat = alpha*x + (1-alpha) * zold;
    z = softThresholding(x_hat + u, lambda*n/rho);
    
    % u-update
    u = u + (x_hat -z);
    
    % convergence check
    history.r_norm(k)  = norm(x - z);
    history.s_norm(k)  = norm(-rho*(z - zold));

    history.eps_pri(k) = sqrt(p)*absTol + relTol*max(norm(x), norm(-z));
    history.eps_dual(k)= sqrt(p)*absTol + relTol*norm(rho*u);
    
    % Objective
    [history.objective(k), history.mse(k)] = objFun(x,z);      
    
    % Convergence
    if (history.r_norm(k) < history.eps_pri(k) && ...
       history.s_norm(k) < history.eps_dual(k))
         break;
    end    
end


function z = softThresholding(x, k)
z = max(0, x-k) - max(0, -x-k );

function [f, mse] = BPDNObjective(ATA,ATy,yTy,b,z,lambda,n)
mse = (b'*ATA*b - 2*b'*ATy + yTy)/n;
f = mse/2 + lambda*sum(abs(z));

function varargout = iCastIfSingle(tf, varargin)
% Cast to single if tf == true
varargout = varargin;

if tf
    for k = 1:numel(varargout)
        varargout{k} = cast(varargout{k}, 'single');
    end
end