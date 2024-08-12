function wft = waveft2(WAV,omegaX,omegaY,varargin)
%WAVEFT2 Wavelet Fourier transform 2-D.
%   WAVEFT2 computes the wavelet values in the frequency plane.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-Aug-2010.
%   Last Revision: 15-Apr-2013.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<2
    wft = getDefault(WAV);
    return
elseif isequal(nargin,2) && isequal(omegaX,'Control_PARAM')
    wft = Control_WAV_Param(WAV);
    return
else
    wname = WAV.wname;
    varargin = WAV.param;
    if ~iscell(varargin) , varargin = {varargin}; end
end

%---------------------------------------------------
% 'cauchy'      - 2D Cauchy Wavelet in frequency plane
% 'endstop1'    - Single 2D EndStop Wavelet in frequency plane
% 'morl'        - 2D Morlet Wavelet in frequency plane
% 'rmorl'       - Real 2D Morlet Wavelet in frequency plane
%---------------------------------------------------
switch wname
    case 'mexh' ,      wft = mexh(omegaX,omegaY,varargin{:});
    case 'dog' ,       wft = dog(omegaX,omegaY,varargin{:});
    case 'cauchy' ,    wft = cauchy(omegaX,omegaY,varargin{:});
    case 'dogpow' ,    wft = dogpow(omegaX,omegaY,varargin{:});
    case 'endstop1' ,  wft = endstop1(omegaX,omegaY,varargin{:});
    case 'endstop2' ,  wft = endstop2(omegaX,omegaY,varargin{:});
    case 'escauchy' ,  wft = escauchy(omegaX,omegaY,varargin{:});
    case 'esmorl' ,    wft = esmorl(omegaX,omegaY,varargin{:});
    case 'esmexh' ,    wft = esmexh(omegaX,omegaY,varargin{:});
    case 'gaus' ,      wft = gaus(omegaX,omegaY,varargin{:});
    case 'gaus2' ,     wft = gaus2(omegaX,omegaY,varargin{:});
    case 'gaus3' ,     wft = gaus3(omegaX,omegaY,varargin{:});
    case 'isodog' ,    wft = isodog(omegaX,omegaY,varargin{:});
    case 'isomorl' ,   wft = isomorl(omegaX,omegaY,varargin{:});
    case 'morl' ,      wft = morlet(omegaX,omegaY,varargin{:});
    case 'pethat' ,    wft = pethat(omegaX,omegaY,varargin{:});
    case 'rmorl' ,     wft = rmorlet(omegaX,omegaY,varargin{:});
    case 'sdog' ,      wft = sdog(omegaX,omegaY,varargin{:});
    case 'dog2' ,      wft = dog2(omegaX,omegaY,varargin{:});
    case 'wheel' ,     wft = wheel(omegaX,omegaY,varargin{:});
    case 'paul' ,      wft = paul(omegaX,omegaY,varargin{:});
    case 'gabmexh' ,   wft = gabmexh(omegaX,omegaY,varargin{:});
    case 'sinc' ,      wft = sincw(omegaX,omegaY,varargin{:});
    case 'fan' ,       wft = fan(omegaX,omegaY,varargin{:});
end
%--------------------------------------------------------------------------
function OkWAV = Control_WAV_Param(WAV)

OkWAV = true;
wname = WAV.wname;
param = WAV.param;   %#ok<*NASGU>
return;

% WAV.wname = wname;
% WAV.param = param;
% WAV_Param_Table = {...
%     'morl'      , {'Omega0','6','6';'Sigma',1,1;'Epsilon',1,1}; ...
%     'mexh'      , {'p',2,2;'sigmax',1,1;'sigmay',1,1}; ...
%     'paul'      , {'p',4,4}; ...
%     'dog'       ,
%       defaults: alpha = 1.25;
%     'cauchy'    ,
%       defaults:  alpha = pi/6; sigma = 1; L = 4; M = 4;
%     'escauchy'  , {'alpha','pi/6','pi/6';'L',4,4;'M',4,4;'sigma',1,1;'Omega0',1,1}; ...
%     'gaus'      , {'p',1,1;'sigmax',1,1;'sigmay',1,1}; ...
%     'wheel'     , {'sigma',2,2}; ...
%     'pethat'    , {};...
%     'dogpow'    , {'alpha',1.25,1.25;'p',2,2}; ...
%     'esmorl'    , {'Omega0','6','6';'Sigma',1,1;'Epsilon',1,1}; ...
%     'esmexh'    , {'sigma',1,1;'epsilon',0.5,0.5}; ...
%     'gaus2'     , {'p',1,1;'sigmax',1,1;'sigmay',1,1}; ...
%     'gaus3'     , {'A',1,1;'B',1,1;'p',1,1;'sigmax',1,1;'sigmay',1,1}; ...
%     'isodog'    , {'alpha',1.25,1.25}; ...
%     'dog2'      , {'alpha',1.25,1.25}; ...
%     'isomorl'   , {'Omega0','6','6';'Sigma',1,1}; ...
%     'rmorl'     , {'Omega0','6','6';'Sigma',1,1;'Epsilon',1,1}; ...
%     'endstop1'  , {'Omega0','6','6';'Sigma',1,1;'Epsilon',1,1}; ...
%     'endstop2'  , {'Omega0','6','6';'Sigma',1,1}; ...
%     'gabmexh'   , {'Omega0','5.336','5.336';'Epsilon',1,1}; ...
%     'sinc'      , {'Ax',1,1;'Ay',1,1;'p',1,1;'Omega0X',0,0;'Omega0Y',0,0}; ...
%     'fan'       , {'Omega0','5.336','5.336';'Sigma',1,1;'Epsilon',1,1;'J',6.5,,6.5}}; ...
%     };
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function wft = getDefault(wname)

switch wname
    case 'mexh' ,  wft = {'order',2,'sigmax',1,'sigmay',1};
    case {'gaus','gaus2'} ,  wft = {'order',1,'sigmax',1,'sigmay',1};
    case {'dog'} ,   wft = {'order',2,'sigma',1};
    case {'cauchy','escauchy'} , wft = {'coneAngle',pi/6,'sigma',1,'L',4,'M',4};
    case 'dogpow' ,              wft = {'alpha',1.25,'p',2};
    case{'endstop1'}, wft = {'omega0',6};
    case {'esmorl','morl','rmorl'}
        wft = {'omega0',6,'sigma',1,'epsilon',1};
    case {'endstop2','isomorl'} ,   wft = {'omega0',6,'sigma',1};
    case 'esmexh' ,                 wft = {'sigma',1,'epsilon',0.5};
    case {'gaus3'} ,                wft = {'A',1,'B',1,'order',1,'sigma',1};
    case {'isodog','dog2'}  ,wft = {'alpha', 1.25};
    case 'pethat' ,                 wft = {};
    case 'wheel' ,                  wft = {'sigma',2};
    case 'paul' ,                   wft = {'order',4};
    case 'gabmexh' ,                wft = {'Omega0',5.336,'Epsilon',1};
    case 'sinc' , wft = {'Ax',1,'Ay',1,'p',1,'omega0X',0,'omega0Y',0};
    case 'fan' ,  wft = {'omega0',5.336,'sigma',1,'epsilon',1,'J',6.5};
end
%--------------------------------------------------------------------------
function wft = morlet(omegaX,omegaY,varargin)

nbIN = length(varargin);
switch nbIN
    case 0 , epsilon = 1; sigma = 1; omega0 = 2;
    case 1 , epsilon = 1; sigma = 1; omega0 = varargin{1};
    case 2 , epsilon = varargin{2}; sigma = varargin{2}; omega0 = varargin{1};
    case 3 , epsilon = varargin{3}; sigma = varargin{2}; omega0 = varargin{1};
    otherwise
        error(message('Wavelet:FunctionInput:TooManyParams'));
end

% Computing the wavelet in frequency domain
wft = exp( - sigma^2 * ((omegaX - omega0).^2 + (epsilon*omegaY).^2)/2 );
%--------------------------------------------------------------------------
function wft = esmorl(omegaX,omegaY,varargin)

nbIN = length(varargin);
switch nbIN
    case 0 , epsilon = 1; sigma = 1; omega0 = 2;
    case 1 , epsilon = 1; sigma = 1; omega0 = varargin{1};
    case 2 , epsilon = varargin{2}; sigma = varargin{2}; omega0 = varargin{1};
    case 3 , epsilon = varargin{3}; sigma = varargin{2}; omega0 = varargin{1};
    otherwise
        error(message('Wavelet:FunctionInput:TooManyParams'));
end

% Computing the wavelet in frequency domain
wft = -omegaY.^2 .* exp( - sigma^2 * ((omegaX - omega0).^2 + (epsilon*omegaY).^2)/2 );
%--------------------------------------------------------------------------
function wft = mexh(omegaX,omegaY,varargin)

nbIN = length(varargin);
switch nbIN
    case 0 , sigmay = 1; sigmax = 1; order = 2;
    case 1 , sigmay = 1; sigmax = 1; order = varargin{1};
    case 2 , sigmay = varargin{2}; sigmax = varargin{2}; order = varargin{1};
    case 3 , sigmay = varargin{3}; sigmax = varargin{2}; order = varargin{1};
    otherwise
        error(message('Wavelet:FunctionInput:TooManyParams'));
end

% Computing the wavelet in frequency domain
wft = - (2*pi) * (omegaX.^2 + omegaY.^2).^(order/2) ...
    .* exp( - ((sigmax*omegaX).^2 + (sigmay*omegaY).^2) / 2 );
%--------------------------------------------------------------------------
function wft = esmexh(omegaX,omegaY,sigma,epsilon)

% Computing the wavelet in frequency domain
T  = atan2(omegaY,omegaX)/epsilon;
wft = sin(T) .* (omegaX.^2 + omegaY.^2) .* ...
    exp( - sigma^2 * (omegaX.^2 + omegaY.^2) / 2 ) .* ...
    exp( - T.^2 / 2);
%--------------------------------------------------------------------------
function wft = paul(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , order = 4; else order = varargin{1}; end
factor1 = (2.^order)./sqrt(order.*gamma(2*order));
sqr_mod_D2 = (omegaX.^2 + omegaY.^2)/2;

wft = factor1 .* sqr_mod_D2.^order .* exp( -sqr_mod_D2 );
for i=1:size(wft,1)
    for j=1:size(wft,2)
        if j < size(wft,2)/2+4
            wft(i,j) = 0;
        end
    end
end
%--------------------------------------------------------------------------
function wft = gaus(omegaX,omegaY,varargin)

nbIN = length(varargin);
switch nbIN
    case 0 , sigmay = 1; sigmax = 1; order = 1;
    case 1 , sigmay = 1; sigmax = 1; order = varargin{1};
    case 2 , sigmay = varargin{2}; sigmax = varargin{2}; order = varargin{1};
    case 3 , sigmay = varargin{3}; sigmax = varargin{2}; order = varargin{1};
    otherwise
        error(message('Wavelet:FunctionInput:TooManyParams'));
end

% Computing the wavelet in frequency domain
wft = (1i*omegaX) .^ order ...
    .* exp( - ((sigmax*omegaX).^2 + (sigmay*omegaY).^2) / 2 );
%--------------------------------------------------------------------------
function wft = dog(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , alpha = 1.25; else alpha = varargin{1}; end

% Computing the wavelet in frequency domain
M = (omegaX.^2 + omegaY.^2)/2;
wft = - exp( - M ) + exp( - alpha^2 * M );
%--------------------------------------------------------------------------
function wft = isodog(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , alpha = 1.25; else alpha = varargin{1}; end

% Computing the wavelet in frequency domain
M = (omegaX.^2 + omegaY.^2)/2;
wft = (- exp( - M ) + alpha^2 * exp( - alpha^2 * M ))/(alpha^2 -1);
%--------------------------------------------------------------------------
function wft = dogpow(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , alpha = 1.25; else alpha = varargin{1}; end
if nbIN<2 , pow   = 2;    else pow = varargin{2}; end

% Computing the wavelet in frequency domain
M = (omegaX.^2 + omegaY.^2)/2;
wft = (- exp( - M ) + exp( - alpha^2 * M )).^pow;
%--------------------------------------------------------------------------
function wft = dog2(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , alpha = 1.25; else alpha = varargin{1}; end

% % Computing the wavelet in frequency domain
% M = (omegaX.^2 + omegaY.^2);
% A = alpha^2;
% wft = ( 0.5 * exp(-M/4) + 1/(2*A) * exp (-A*M /4) ...
%             - 2/(A+1) * exp (-A*M/(2*(A+1)) ))/(2*pi);

M = (omegaX.^2 + omegaY.^2)/2;
wft = (- exp( - M ) + exp( - alpha^2 * M )).^3;
%--------------------------------------------------------------------------
function wft = cauchy(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , coneAngle = pi/6; else coneAngle = varargin{1}; end
if nbIN<2 , sigma = 1; else sigma = varargin{2}; end
if nbIN<3 , L = 4; else L = varargin{3}; end
if nbIN<4 , M = 4; else M = varargin{4}; end

% Computing the wavelet in frequency domain
dot1  =  sin(coneAngle)*omegaX + cos(coneAngle)*omegaY;
dot2  = -sin(coneAngle)*omegaX + cos(coneAngle)*omegaY;
coeff = (dot1.^L).*(dot2.^M);

k0    = (L+M)^0.5 * (sigma - 1)/sigma;
rad2  = 0.5 * sigma * ( (omegaX-k0).^2 + omegaY.^2 );
pond  = tan(coneAngle)*omegaX  > abs(omegaY);
wft   = pond .* coeff .* exp(- rad2 );
%--------------------------------------------------------------------------
function wft = endstop1(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , omega0 = 6; else omega0 = varargin{1}; end

% Computing the wavelet in frequency domain
M = (omegaX.^2 + omegaY.^2)/2;
wft = (-1i*omegaX).*exp(-M).*exp(-((omegaY-omega0).^2 + omegaX.^2)/2);
%--------------------------------------------------------------------------
function wft = endstop2(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , omega0 = 6; else omega0 = varargin{1}; end
if nbIN<2 , sigma = 1; else sigma = varargin{2}; end

% Computing the wavelet in frequency domain
sigma2  = sigma^2;
omegaX2 = omegaX^2;
omegaY2 = omegaY^2;
M = (omegaX2 + omegaY2)/2;
wft = -1/(8*sigma2^2) * (omegaX.^2 - sigma2) .* ...
    exp(-((omegaY-omega0).^2 + omegaX.^2)/2) .* ...
    exp(-M/sigma2);
%--------------------------------------------------------------------------
function wft = escauchy(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , coneAngle = pi/6; else coneAngle = varargin{1}; end
if nbIN<2 , sigma = 1; else sigma = varargin{2}; end
if nbIN<3 , L = 4; else L = varargin{3}; end
if nbIN<4 , M = 4; else M = varargin{4}; end

% Computing the wavelet in frequency domain
dot1  =  sin(coneAngle)*omegaX + cos(coneAngle)*omegaY;
dot2  = -sin(coneAngle)*omegaX + cos(coneAngle)*omegaY;
coeff = (dot1.^L).*(dot2.^M);

k0   = (L+M)^0.5 * (sigma - 1)/sigma;
rad2 = 0.5 * sigma * ( (omegaX-k0).^2 + omegaY.^2 );
pond = tan(coneAngle)*omegaX  > abs(omegaY);
wft  = -omegaY.^2 .* pond .* coeff .* exp(- rad2 );
%--------------------------------------------------------------------------
function wft = gaus2(omegaX,omegaY,varargin)

nbIN = length(varargin);
switch nbIN
    case 0 , sigmay = 1; sigmax = 1; order = 1;
    case 1 , sigmay = 1; sigmax = 1; order = varargin{1};
    case 2 , sigmay = varargin{2}; sigmax = varargin{2}; order = varargin{1};
    case 3 , sigmay = varargin{3}; sigmax = varargin{2}; order = varargin{1};
    otherwise
end

% Computing the wavelet in frequency domain
wft = (1i*(omegaX+1i*omegaY)) .^ order ...
    .* exp( - ((sigmax*omegaX).^2 + (sigmay*omegaY).^2) / 2 );
%--------------------------------------------------------------------------
function wft = gaus3(omegaX,omegaY,varargin)

nbIN = length(varargin);
switch nbIN
    case 0 , sigmay = 1; sigmax = 1; order = 1; B = 1; A = 1;
    case 1 , sigmay = 1; sigmax = 1; order = 1; B = 1; A = varargin{1};
    case 2 
        sigmay = 1; sigmax = 1; order = 1;
        B = varargin{2}; A = varargin{1};
    case 3 
        sigmay = 1; sigmax = 1; order = varargin{3};
        B = varargin{2}; A = varargin{1};
    case 4
        sigmay = 1; sigmax = varargin{4}; order = varargin{3};
        B = varargin{2}; A = varargin{1};
    case 5
        sigmay = varargin{5}; sigmax = varargin{4}; order = varargin{3};
        B = varargin{2}; A = varargin{1};
    otherwise
end

% Computing the wavelet in frequency domain
wft = (1i*(A*omegaX +B* 1i*omegaY)) .^ order ...
    .* exp( - ((sigmax*omegaX).^2 + (sigmay*omegaY).^2) / 2 );
%--------------------------------------------------------------------------
function wft = isomorl(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , omega0 = 6; else omega0 = varargin{1}; end
if nbIN<2 , sigma = 1; else sigma = varargin{2}; end

% Computing the wavelet in frequency domain
wft = - exp( - sigma^2 * (abs(omegaX+1i*omegaY) - omega0).^2 /2 );
%--------------------------------------------------------------------------
function wft = rmorlet(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , omega0 = 6; else omega0 = varargin{1}; end
if nbIN<2 , sigma = 1; else sigma = varargin{2}; end
if nbIN<3 , epsilon = 1; else epsilon = varargin{3}; end

% Computing the wavelet in frequency domain
wft = exp( - sigma^2 * ((omegaX - omega0).^2 + (epsilon*omegaY).^2)/2 ) + ...
    exp( - sigma^2 * ((omegaX + omega0).^2 + (epsilon*omegaY).^2)/2 );
%--------------------------------------------------------------------------
function wft = wheel(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , sigma = 2; else sigma = varargin{1}; end
if (sigma<=1)
    error(getWavMSG('Wavelet:dualtree:Err_Sigma'));
end

% Computing the Gaussian in frequency domain
M = abs(omegaX + 1i*omegaY);
M((M < (1/sigma)) | (M >= sigma)) = 1/sigma;
wft = cos( (pi/2)*log(M)/log(sigma)).^2;
%--------------------------------------------------------------------------
function wft = pethat(omegaX,omegaY,varargin)

% Computing the wavelet in frequency domain
M = abs(omegaX + 1i*omegaY);
M((M > 4*pi) | (M <pi)) = 4*pi;
wft = cos((pi/2)*log2(M/(2*pi))).^2;
%--------------------------------------------------------------------------
function wft = gabmexh(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , omega0  = 5.336; else omega0 = varargin{1}; end
if nbIN<2 , epsilon = 1; else epsilon = varargin{2}; end

% Computing the wavelet in frequency domain
wft = sqrt(epsilon) * (epsilon*omegaX.^2 + omegaY.^2) ...
    .* exp( - (epsilon*(omegaX).^2 + (omegaY-omega0).^2) / 2 );
%--------------------------------------------------------------------------
function wft = fan(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , omega0  = 5.336; else omega0 = varargin{1}; end
if nbIN<2 , sigma = 1; else sigma = varargin{2}; end
if nbIN<3 , epsilon = 1; else epsilon = varargin{3}; end
if nbIN<4 , J = 6.5; else J = varargin{4}; end

% Computing the wavelet in frequency domain
% J = nb_teta
total_teta = pi;
dteta = total_teta/(J+1);
wft = 0;
for r=0:J
    wft = wft + exp(-sigma^2*((omegaX-omega0.*cos(dteta.*r)).^2 ...
        + (epsilon*omegaY-omega0.*sin(dteta.*r)).^2)/2 );
end
wft = wft /(J+1);
%--------------------------------------------------------------------------
function wft = sincw(omegaX,omegaY,varargin)

nbIN = length(varargin);
if nbIN<1 , Ax = 1; else Ax = varargin{1}; end
if nbIN<2 , Ay = 1; else Ay = varargin{2}; end
if nbIN<3 , p = 1;  else p = varargin{3}; end
if nbIN<4 , omega0X = 0; else omega0X = varargin{4}; end
if nbIN<5 , omega0Y = 0; else omega0Y = varargin{5}; end

wft = wsinc(Ax*(omegaX-omega0X)).*(wsinc(Ay*(omegaY-omega0Y)).^p);
%--------------------------------------------------------------------------
function v = wsinc(t)

idx = find(t==0);
t(idx)= 1;
v = sin(pi*t)./(pi*t);
v(idx) = 1;
%--------------------------------------------------------------------------
