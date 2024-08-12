function varargout = lwt(X,varargin)
%LWT 1-D Lifting wavelet transform
%
%   [CA,CD] = LWT(X) returns the wavelet decomposition of the signal X. X
%   is a real- or complex-valued vector or matrix. If X is a matrix, LWT
%   operates on the columns of X. X must have at least two samples. If X
%   has even length, the wavelet transform is obtained down to level
%   floor(log2(N)), where N is the length of X if X is a vector and the row
%   dimension of X if X is a matrix. If N is odd, X is extended by one
%   sample by duplicating the last element of X. By default, LWT uses the
%   lifting scheme for the 'db1' wavelet and does not preserve
%   integer-valued data. CA is the matrix of final level approximation
%   (lowpass) coefficients. CD is an L-by-1 cell array of detail
%   coefficients, where L is the level of the transform. The elements of CD
%   are in order of decreasing resolution.
%
%   [CA,CD] = LWT(X,'Wavelet',W) uses the wavelet specified by the
%   character vector W to obtain the wavelet transform of X. W denotes the
%   name of an orthogonal or biorthogonal wavelet and must be one of the
%   wavelet names supported by LIFTINGSCHEME.
%
%   [CA,CD] = LWT(X,'LiftingScheme',LS) uses the LIFTINGSCHEME object LS to
%   obtain the wavelet transform of X. 
%
%   [CA,CD] = LWT(...,'Level',LEVEL) obtains the wavelet transform of X
%   down to Level LEVEL. LEVEL is a positive integer less than or equal to
%   floor(log2(length(X))).
%
%   [CA,CD] = LWT(...,'Extension',EXTMODE) uses the specified extension
%   mode EXTMODE to obtain the wavelet transform of X. EXTMODE specifies
%   how to extend the signal at the boundaries. Valid options for EXTMODE
%   are 'periodic' (default), 'zeropad', or 'symmetric'.
%
%   [CA,CD] = LWT(X,...,'Int2Int',INTEGERFLAG) specifies how the lifting
%   transform handles integer-valued data.
%   true            - does preserve integer-valued data.
%   false (default) - does not preserve integer-valued data.
%   All coefficients must be integer valued if INTEGERFLAG is set to true.
%
%   % Example 1: Obtain the level 2 wavelet decomposition of a signal using
%   % the lifting scheme associated with the Haar wavelet.
%   X = 1:8;
%   [CA,CD] = lwt(X,'Wavelet','haar','Level',2);
%
%   % Example 2: Obtain the level 4 wavelet decomposition of a signal 
%   % using the lifting scheme associated with the 'db2' wavelet. 
%   X = rand(16,4);
%   wv = 'db2';
%   level = 4;
%   [CA,CD] = lwt(X,'Wavelet','db2','Level',4);
%
%   % Example 3: Obtain the integer-to-integer wavelet decomposition of a
%   % signal using the lifting scheme associated with the Haar wavelet.
%   X = 1:8;
%   INTEGERFLAG = true;
%   [CA,CD] = lwt(X,'Wavelet','haar','Int2Int',INTEGERFLAG);
%
%   See also ILWT, HAART, IHAART, LIFTINGSTEP, LIFTINGSCHEME.

%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(1,10);

tempArgs = cell(size(varargin));

[tempArgs{:}] = convertStringsToChars(varargin{:});

if isrow(X)
    x2 = transpose(X);
else
    x2 = X;
end

validateattributes(x2, {'numeric'},{'2d','finite','nonnan'},'lwt','X2',1);
lx = size(x2,1);

[LS,ext,level,wv,isI2I] = lwtParser(lx,tempArgs{:});

if isI2I
    validateattributes(x2, {'numeric'},{'2d','finite','nonnan','integer'},...
        'lwt','X2',1);
else
    validateattributes(x2, {'numeric'},{'2d','finite','nonnan'},'lwt','X2',1);
end


lval = ceil(log2(lx));
coder.internal.assert(~(lx< (2^level)),...
                        'Wavelet:Lifting:InvalidLevelWavelet',lval,length(X));

if (~strcmpi(wv,'')) && strcmpi(wv,'lazy')
    [ca,cDet] = multLvlLazy(x2,level);
    varargout{1} = ca;
    varargout{2} = cDet;
    return;
end

[ca,cDet] = multLvlDec(x2,level,LS,ext,isI2I);
varargout{1} = ca; varargout{2} = cDet;

end

function [ca,cd] = predictUpdate(x,LS,ext,isI2I)

steps = LS.LiftingSteps;
r = size(steps,1);
[sl,dl] = split(x);

for ii = 1: r
    C = steps(ii).Coefficients;
    ord = (steps(ii).MaxOrder);
    switch (steps(ii).Type)
        case {'d','predict'}
            dl = forwardLift(dl,sl,C,ord,ext,isI2I);
            
        case {'p','update'}
            sl = forwardLift(sl,dl,C,ord,ext,isI2I);
    end
end

if isI2I
    cd = dl;
    ca = sl;
else
    K = LS.NormalizationFactors;
    cd = dl*K(2);
    ca = sl*K(1);
end

end

function d = forwardLift(z1,z2,lF,maxOrd,ext,isI2I)

s1z = lF;
lz = size(z2,1);
lf = length(lF);
delay = maxOrd+1-(1:lf);

s = zeros(3*size(z1,1),size(z1,2),'like',z1);

switch ext
    case 'zeropad'
        
        zZpd = [zeros(size(z2));z2;zeros(size(z2))];
        z2new = repmat(zZpd,1,lf);
        sz = repmat(s1z,numel(zZpd),1);
        
    case 'periodic'
        zPer = [z2;z2;z2];
        z2new = repmat(zPer,1,lf);
        sz = repmat(s1z,numel(zPer),1);
        
    case 'symmetric'
        
        if (lz ~= 1)
            indSym = [1 lz:-1:2 1:lz lz-1:-1:1 2];
        else
            indSym = [ 1 1 1];
        end
        zSym = z2(indSym,:,:);
        z2new = repmat(zSym,1,lf);
        sz = repmat(s1z,numel(zSym),1);
    otherwise
        coder.internal.error('Wavelet:Lifting:UnsupportedExt');
        
end

sz = reshape(sz,size(z2new,1),[]);
sf = sz.*z2new;
c = size(z2,2);

for jj = 1:lf
    indc = (1:c)+ ((jj-1)*c);
    sd = circshift(sf(:,indc),-delay(jj));
    s = s + sd;
end

if (lz == 1) && strcmpi(ext,'symmetric')
    s1 = s(2,:,:);
else
    s1 = s(lz+1:(2*lz),:,:);
end

if isI2I
    d = z1 + floor(s1+0.5);
else
    d = z1 + s1;
end

end

function [xe,xo] = split(x)

if isodd(size(x,1))
    x1 = [x;x(end,:,:)];
else
    x1 = x;
end

sx = size(x1,1);

% even indexed input
indEv = 1:2:sx;

% odd indexed input
indOd = 2:2:sx;

xe = x1(indEv,:,:);
xo = x1(indOd,:,:);
end

function [ca,cDet] = multLvlDec(x,level,LS,ext,isI2I)
[ca,cDet] = cDetAlloc(x,level);

xIn = x;
coder.varsize('xIn');

for ll = 1:level
    
    if (ll == 1)
        [ca,cd] = predictUpdate(x,LS,ext,isI2I);
    else
        [ca,cd] = predictUpdate(xIn,LS,ext,isI2I);
    end
    
    cDet{ll,1} = cd;
    
    if level>1
        xIn = ca;
    end
end
end

function [ca,cDet] = multLvlLazy(x,level)
[ca,cDet] = cDetAlloc(x,level);
xIn = x;
coder.varsize('xIn');

for ll = 1:level
        
    if isodd(size(xIn,1))       % odd signal length
        x1 = [xIn;xIn(end,:,:)];
    else
        x1 = xIn;
    end
    
    sx = size(x1,1);
    indEv = 1:2:sx;           % even indexed input
    indOd = 2:2:sx;           % odd indexed input
    
    ca = x1(indEv,:,:);
    cDet{ll} = x1(indOd,:,:);
    
    if level>1
        xIn = ca;
    end
end
end

function [ca,cDet] = cDetAlloc(x,level)
lx = length(x);
cDet = cell(level,1);
ex = (1:level)-1;
den = 2.^(ex);
lc = ceil(lx./den);

for ll = 1 : level
    cDet{ll,1} = zeros(lc(ll),1,'like',x);
end

ca = cDet{1,1};

end

function [LS,ext,level,wv,I2I] = lwtParser(lx,varargin)

if numel(varargin) == 0
wv = 'db1';
LS = liftingScheme('Wavelet',wv);
ext = 'periodic';
level = floor(log2(lx));
I2I = 0;

else
% parser for the name value-pairs
parms = {'Wavelet','extension','level','LiftingScheme','Int2Int'};

% Select parsing options.
poptions = struct('PartialMatching','unique');
pArg = coder.internal.parseParameterInputs(parms,poptions,varargin{:});

iswv = coder.internal.getParameterValue(pArg.Wavelet, [],...
    varargin{:});
isLS = coder.internal.getParameterValue(pArg.LiftingScheme, [],...
    varargin{:});

% parse wavelet name and liftingScheme
if isempty(iswv)
    if isempty(isLS)
        wv = 'db1';
        coder.varsize('wv');
        LS = liftingScheme('Wavelet',wv);
    else
        if isa(isLS,'liftingScheme')
            LS = isLS;
            wv = LS.Wavelet;
        else
            coder.internal.error('Wavelet:Lifting:UnsupportedLiftingScheme');
        end
    end
    
else
    switch isempty(isLS)
        case 1
            T = wavelet.internal.lifting.wavenames('all');
            if ~any(strcmpi(T.W,iswv))
                coder.internal.error('Wavelet:FunctionArgVal:Invalid_WavName');
            end
            wv = char(iswv);
            LS = liftingScheme('Wavelet',wv);
        otherwise
            coder.internal.error('Wavelet:Lifting:WaveNameLScheme');
    end
end

isext = coder.internal.getParameterValue(...
    pArg.extension, [],varargin{:});

if isempty(isext)
    ext = 'periodic';  
else
    ext = isext;
end

extType = {'zeropad','periodic','symmetric'};
ext = validatestring(ext,extType,'lwt','EXT');

islevel = coder.internal.getParameterValue(...
    pArg.level, [],varargin{:});

% parse level
if isempty(islevel) 
    % default level of decomposition
    level = floor(log2(lx));
else
    level = islevel;
end
validateattributes(level, {'numeric'}, {'scalar','integer','positive'},...
                          'lwt','LEVEL');

isI2I = coder.internal.getParameterValue(...
    pArg.Int2Int, [],varargin{:});

if isempty(isI2I)
    I2I = 0;
else
    I2I = isI2I;
end
   
validateattributes(I2I, {'logical','numeric'},{'scalar'},'lwt','ISI2I'); 
end

end
