function [XBP, MSE,lambda] = BPDN(A, Y, varargin)
%BPDN Basis pursuit denoising
%   [XBP, MSE,lambda] = BPDN(A,Y,'RelTol',rTol,'AbsTol',aTol,'MaxIter',maxIt)
%   returns the estimate XBP of the sparse signal X such that Y = AX using
%   the basis pursuit denoising algorithm. XBP corresponds to the estimate
%   with minimum mean squared error MSE. lambda is the lagrangian parameter
%   that corresponds to the estimate. The algorithm uses a relative
%   tolerance rTol, absolute tolerance aTol and maximum number of
%   iterations maxIt for calculating the estimate.
%
%   See also MATCHINGPURSUIT.

% Parse and validate input arguments
if nargin > 2
    [varargin{:}] = convertStringsToChars(varargin{:});
end

par = parseArgs(varargin{:});
relTol = par.Results.RelTol;
absTol = par.Results.AbsTol;
maxIter = par.Results.MaxIter;
maxErr = par.Results.MaxErr;

% Filter out bad data
isAllFiniteRows = @(x)all(isfinite(x),2);
okrows = isAllFiniteRows(A) & isAllFiniteRows(Y);
A = A(okrows,:);
Y = Y(okrows,:);

% Standardization and apply weights
muX = zeros(1,size(A,2));
muY = 0;
sigX = 1;
tX0 = (A-muX)./sigX;
[n,p] = size(A);

% precalculation
xtx = (tX0)'*tX0;
rho = optimRho(xtx);
[L,U] = cholFactors(xtx,rho);

tY0 = Y-muY;
xty = (tX0)'*tY0;
yty = (tY0)'*tY0;

lambdaSeq = defaultLambdaSeq(xty,n);
C = U\(L\xty);

[B,Lambda,histMSE] = ADMMlamdaSeq(L,U,xtx,xty,yty,C,n,p,...
    lambdaSeq,rho,absTol,relTol,maxIter);

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
end

function rho =  optimRho(Q)
    if (Q == 0)
        rho = eps;
    else
        eigValues = eig(Q);
        eigValues = eigValues(eigValues > length(eigValues)*eps(max(eigValues)));
        rho = sqrt(max(eigValues)*min(eigValues));
    end
end

function lambdaSeq = defaultLambdaSeq(ATy,n)
numLambda = 100;
lambdaRatio = 1e-4;
lambdaMax = max(abs(ATy/n));
seqFun = @(m,r,n)exp(linspace(log(m*r),log(m),n));
lambdaSeq = seqFun(lambdaMax,lambdaRatio,numLambda);
end

function[z,u,history] = ADMM(L,U,ATA,ATY,yTy,C,n,p,lambda, rho,alpha,z,u,...
    absTol,relTol,maxIt)
% Internal use only.

objFun = @(beta,z)BPDNObjective(ATA,ATY,yTy,beta,z,lambda,n);

for k = 1: maxIt
    
    % x-update
    x = C + U\(L\(rho*(z-u)));
    
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

end

function z = softThresholding(x, k)
    z = max(0, x-k) - max(0, -x-k );
end

function [L, U] = cholFactors(ATA, rho)
L = chol(ATA+rho*eye(size(ATA,1)), 'lower');
U = L';
end

function [f, mse] = BPDNObjective(ATA,ATy,yTy,b,z,lambda,n)
mse = (b'*ATA*b - 2*b'*ATy + yTy)/n;
f = mse/2 + lambda*sum(abs(z));
end

function [B,Lambda,histMSE] = ADMMlamdaSeq(L,U,xtx,xty,yty,C,n,p,...
    lambdaSeq,rho,absTol,relTol,maxIter)

% Initialize outputs
l = length(lambdaSeq);
B = zeros(p,l);
history = cell(1,l);

% Initialization
z = zeros(p,1);
u = zeros(p,1);
relaxation = 1.5;
% Start with the first lambda
[B(:,l),u,history{l}] = ADMM(L,U,xtx,xty,yty,C,n,p,...
    lambdaSeq(l),rho,relaxation,z,u,absTol,relTol,maxIter);

nullMSE = yty/n;
if l >1
    for i = (l-1):-1:1
        % Warm start with the results of the previous lambda
        [B(:,i), u,history{i}] = ADMM(L,U,xtx,xty,yty,C,n,p,lambdaSeq(i),...
            rho,relaxation,B(:,i+1),u,absTol,relTol,maxIter);

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
end