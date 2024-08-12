function [b,r,bint,t,p] = bisquareregress(X,y)
X = X(:);
y = y(:);
wfun = @bisquare;
tune = 4.685;
[n,p] = size(X);
X = [ones(n,1) X];
p = p+1;
sw = 1;
priorw = ones(size(y));



% Find the least squares solution.
[Q,R,perm] = qr(X,0);
tol = abs(R(1)) * max(n,p) * eps(class(R));
xrank = sum(abs(diag(R)) > tol);
if xrank==p
    b(perm,:) = R \ (Q'*y);
else
    b(perm,:) = [R(1:xrank,1:xrank) \ (Q(:,1:xrank)'*y); zeros(p-xrank,1)];
    perm = perm(1:xrank);
end
b0 = zeros(size(b));

% Adjust residuals using leverage, as advised by DuMouchel & O'Brien
E = X(:,perm)/R(1:xrank,1:xrank);
h = min(.9999, sum(E.*E,2));
adjfactor = 1 ./ sqrt(1-h./priorw);

dfe = n-xrank;
ols_s = norm((y-X*b)./sw) / sqrt(dfe);

% If we get a perfect or near perfect fit, the whole idea of finding
% outliers by comparing them to the residual standard deviation becomes
% difficult.  We'll deal with that by never allowing our estimate of the
% standard deviation of the error term to get below a value that is a small
% fraction of the standard deviation of the raw response values.
tiny_s = 1e-6 * std(y);
if tiny_s==0
    tiny_s = 1;
end

% Perform iteratively re-weighted least squares to get coefficient estimates
D = sqrt(eps(class(X)));
iter = 0;
iterlim = 50;
wxrank = xrank;    % rank of weighted version of x
while((iter==0) || any(abs(b-b0) > D*max(abs(b),abs(b0))))
   iter = iter+1;
   if (iter>iterlim)
      break;
   end
   
   % Compute residuals from previous fit, then compute scale estimate
   r = y - X*b;
   radj = r .* adjfactor ./ sw;
   s = madsigma(radj,wxrank);
   
   % Compute new weights from these residuals, then re-fit
   w = feval(wfun, radj/(max(s,tiny_s)*tune));
   b0 = b;
   [b(perm),wxrank] = wfit(y,X(:,perm),w);
end

if (nargout>1)
   r = y - X*b;
   radj = r .* adjfactor ./ sw;
   mad_s = madsigma(radj,xrank);
   
   % Compute a robust estimate of s
   if all(w<D | w>1-D)
       % All weights 0 or 1, this amounts to ols using a subset of the data
       included = (w>1-D);
       robust_s = norm(r(included)) / sqrt(sum(included) - xrank); 
   else
       % Compute robust mse according to DuMouchel & O'Brien (1989)
       robust_s = robustsigma(wfun, radj, xrank, max(mad_s,tiny_s), tune, h);
   end

   % Shrink robust value toward ols value if the robust version is
   % smaller, but never decrease it if it's larger than the ols value
   sigma = max(robust_s, ...
               sqrt((ols_s^2 * xrank^2 + robust_s^2 * n) / (xrank^2 + n)));

   % Get coefficient standard errors and related quantities
   RI = R(1:xrank,1:xrank)\eye(xrank);
   tempC = (RI * RI') * sigma^2;
   tempse = sqrt(max(eps(class(tempC)),diag(tempC)));
   se = zeros(p,1);
   se(perm) = tempse;
   conf95 = 2*se;
   bint = [b-conf95 b+conf95];
   t = NaN(size(b));
   t(se>0) = b(se>0) ./ se(se>0);
   t = abs(t(2));
   p = 2*tpvalue(-t,dfe);
   if p>1
       p = 1;
   end
end





% -----------------------------
function [b,r] = wfit(y,x,w)
%WFIT    weighted least squares fit

% Create weighted x and y
n = size(x,2);
sw = sqrt(w);
yw = y .* sw;
xw = x .* sw(:,ones(1,n));

% Computed weighted least squares results
[b,r] = linsolve(xw,yw,struct('RECT',true));

% -----------------------------
function s = madsigma(r,p)
%MADSIGMA    Compute sigma estimate using MAD of residuals from 0
rs = sort(abs(r));
s = median(rs(max(1,p):end)) / 0.6745;


function w = bisquare(r)
w = (abs(r)<1) .* (1 - r.^2).^2;
%------------------------------------------------------------------

%--------------------------------------------------------------------
function s = robustsigma(wfun,r,p,s,t,h)
%STATROBUSTSIGMA Compute robust sigma estimate for robust regression
%   Used by robustfit and nlinfit.

% This function computes an s value so that s^2 * inv(X'*X) is a reasonable
% covariance estimate for robust regression coefficient estimates.  It is
% based on the references below.  The expressions in these references do
% not appear to be the same, but we have attempted to reconcile them in a
% reasonable way.
%
% Before calling this function, the caller should have computed s as the
% MAD of the residuals omitting the p-1 smallest in absolute value, as
% recommended by O'Brien and in the material below eq. 8 of Street.  The
% residuals should be adjusted by their leverage according to the
% recommendation of O'Brien.

%   DuMouchel, W.H., and F.L. O'Brien (1989), "Integrating a robust
%     option into a multiple regression computing environment,"
%     Computer Science and Statistics:  Proceedings of the 21st
%     Symposium on the Interface, American Statistical Association.
%   Holland, P.W., and R.E. Welsch (1977), "Robust regression using
%     iteratively reweighted least-squares," Communications in
%     Statistics - Theory and Methods, v. A6, pp. 813-827.
%   Huber, P.J. (1981), Robust Statistics, New York: Wiley.
%   Street, J.O., R.J. Carroll, and D. Ruppert (1988), "A note on
%     computing robust regression estimates via iteratively
%     reweighted least squares," The American Statistician, v. 42,
%     pp. 152-154.


% Copyright 2005-2020 The MathWorks, Inc.


% Include tuning constant in sigma value
st = s*t;

% Get standardized residuals
n = length(r);
u = r ./ st;

% Compute derivative of phi function
phi = u .* feval(wfun,u);
delta = 0.0001;
u1 = u - delta;
phi0 = u1 .* feval(wfun,u1);
u1 = u + delta;
phi1 = u1 .* feval(wfun,u1);
dphi = (phi1 - phi0) ./ (2*delta);

% Compute means of dphi and phi^2; called a and b by Street.  Note that we
% are including the leverage value here as recommended by O'Brien.
m1 = mean(dphi);
m2 = sum((1-h).*phi.^2)/(n-p);

% Compute factor that is called K by Huber and O'Brien, and lambda by
% Street.  Note that O'Brien uses a different expression, but we are using
% the expression that both other sources use.
K = 1 + (p/n) * (1-m1) / m1;

% Compute final sigma estimate.  Note that Street uses sqrt(K) in place of
% K, and that some Huber expressions do not show the st term here.
s = K*sqrt(m2) * st /(m1);

%--------------------------------------------------------------------
 function p = tpvalue(x,v)
%TPVALUE Compute p-value for t statistic.

normcutoff = 1e7;
if length(x)~=1 && length(v)==1
   v = repmat(v,size(x));
end

% Initialize P.
p = NaN(size(x));
nans = (isnan(x) | ~(0<v)); % v == NaN ==> (0<v) == false

% First compute F(-|x|).
%
% Cauchy distribution.  See Devroye pages 29 and 450.
cauchy = (v == 1);
p(cauchy) = .5 + atan(x(cauchy))/pi;

% Normal Approximation.
normal = (v > normcutoff);
p(normal) = 0.5 * erfc(-x(normal) ./ sqrt(2));

% See Abramowitz and Stegun, formulas 26.5.27 and 26.7.1.
gen = ~(cauchy | normal | nans);
p(gen) = betainc(v(gen) ./ (v(gen) + x(gen).^2), v(gen)/2, 0.5)/2;

% Adjust for x>0.  Right now p<0.5, so this is numerically safe.
reflect = gen & (x > 0);
p(reflect) = 1 - p(reflect);

% Make the result exact for the median.
p(x == 0 & ~nans) = 0.5;

