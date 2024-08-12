function xr = ilwt(ca,cd,varargin)
%ILWT Inverse 1-D lifting wavelet transform
%
%   XR = ILWT(CA,CD) returns the 1-D inverse wavelet transform based on the
%   approximation coefficients, CA, and cell array of detail coefficients,
%   CD. CA and CD are outputs of LWT. By default, ILWT assumes that you
%   used the lifting scheme associated with the 'db1' wavelet to obtain CA
%   and CD. If you do not modify the coefficients, XR is a perfect
%   reconstruction of the signal. If CA and the elements of CD are
%   matrices, XR is a matrix where each column is the inverse wavelet
%   transform of the corresponding columns in CA and CD.
%
%   XR = ILWT(CA,CD,'Wavelet',W) uses the wavelet specified by the
%   character vector W. W denotes the name of an orthogonal or biorthogonal
%   wavelet and must be one of the wavelet names supported by
%   LIFTINGSCHEME. For perfect reconstruction, W must be the same wavelet
%   that was used to obtain the coefficients CA and CD.
%
%   XR = ILWT(CA,CD,'LiftingScheme',LS) uses the LIFTINGSCHEME object, LS,
%   to obtain the inverse wavelet transform. If unspecified, LS defaults to
%   the lifting scheme associated with the 'db1' wavelet. For perfect
%   reconstruction, LS must be the same lifting scheme that was used to
%   obtain the coefficients CA and CD.
%
%   XR = ILWT(...,'Level',LEVEL) returns the inverse wavelet transform up
%   to level LEVEL. LEVEL is a nonnegative integer less or equal to
%   length(CD)-1. If unspecified, LEVEL defaults to 0 and XR is a perfect
%   reconstruction of the signal.
%
%   XR = ILWT(...,'Extension',EXTMODE) uses the specified extension mode
%   EXTMODE. EXTMODE specifies how to extend the signal at the boundaries.
%   Valid options for EXTMODE are 'periodic' (default), 'zeropad', or
%   'symmetric'.
%
%   XR = ILWT(...,'Int2Int',INTEGERFLAG) specifies how the inverse lifting
%   transform handles integer-valued data.
%   true            - does preserve integer-valued data.
%   false (default) - does not preserve integer-valued data.
%   All coefficients must be integer valued if INTEGERFLAG is set to true.
%
%   % Example: Obtain the level 2 wavelet decomposition of a signal using 
%   % the lifting scheme associated with the 'db2' wavelet. Demonstrate
%   % perfect reconstruction.
%   load noisdopp
%   x = noisdopp;
%   level = 2;
%   LS = liftingScheme('Wavelet','db2');
%   [ca,cd] = lwt(x,'LiftingScheme',LS,'Level',level);
%   xr = ilwt(ca,cd,'LiftingScheme',LS,'Level',0);
%   max(abs(x-xr'))
%
%   See also LWT, HAART, IHAART, LIFTINGSTEP, LIFTINGSCHEME.

%   Copyright 2020-2022 The MathWorks, Inc.

%#codegen

narginchk(2,10);
nargoutchk(0,1);
lvl = numel(cd);

validateattributes(ca, {'numeric'},{'nonempty','finite','nonnan'},...
        'ilwt','CA',1);
    
if ~isreal(ca)
    validateattributes(real(ca), {'numeric'},...
        {'nonempty','finite'},'ilwt','CA',1);
    validateattributes(imag(ca), {'numeric'},...
        {'nonempty','finite'},'ilwt','CA',1);
end

validateattributes(cd, {'numeric','cell'},{'nonempty'},'ilwt','CD',2);

[LS,ext,level,~,isI2I] = ilwtParser(lvl,varargin{:});

if isI2I
    if isreal(ca)
        validateattributes(ca, {'numeric'},{'integer'},'ilwt','CA',1);
    else
        validateattributes(real(ca), {'numeric'},{'integer'},...
            'ilwt','CA',1);
        validateattributes(imag(ca), {'numeric'},{'integer'},...
            'ilwt','CA',1);
    end
    
    if isreal(cd{1,1})
        for ii = 1:size(cd,1)
            validateattributes(cd{ii,1}, {'numeric'},...
                {'nonempty','integer','finite','nonnan'},'ilwt','CD',2);
        end
    else
        for ii = 1:size(cd,1)
            validateattributes(real(cd{ii,1}), {'numeric'},...
                {'nonempty','integer','finite','nonnan'},'ilwt','CD',2);
            validateattributes(imag(cd{ii,1}), {'numeric'},...
                {'nonempty','integer','finite','nonnan'},'ilwt','CD',2);
        end
    end
else
    
    if isreal(cd{1,1})
        for ii = 1:lvl
            validateattributes(cd{ii,1}, {'numeric'},...
                {'nonempty','finite','nonnan'},'ilwt','CD',2);
        end
    else
        for ii = 1:lvl
            validateattributes(real(cd{ii,1}), {'numeric'},...
                {'nonempty','finite','nonnan'},'ilwt','CD',2);
            validateattributes(imag(cd{ii,1}), {'numeric'},...
                {'nonempty','finite','nonnan'},'ilwt','CD',2);
        end
    end
end

if isI2I
    K = [1 1];
else
    K = LS.NormalizationFactors;
end

stp = LS.LiftingSteps;
[isOddLen1,lxr] = checkOddLen(cd);
aRec = liftMerge(ca*K(2),cd{lvl,1}*K(1),stp,ext,isI2I,isOddLen1(lvl));

aR = cell(lvl,1);
for ii = 1:lvl
    aR{ii} = zeros(lxr(ii),size(cd{1,1},2),'like',ca);
end

aR{lvl} = aRec;
xr = coder.nullcopy(aRec);

if level == lvl-1
    xr = aRec;
    return;
end

for ll = (lvl-2):-1:0    
    if (ll == level-1)
        xr = aR{ll+2};
        break;
    else
        aR{ll+1} = liftMerge(aR{ll+2}*K(2),cd{ll+1,1}*K(1),stp,ext,isI2I,isOddLen1(ll+1));
        xr = aR{ll+1};
    end
end
end

function d = inverseLift(z1,z2,lF,maxOrd,ext,isI2I)
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
    d = z1 - floor(s1+0.5);
else
    d = z1 - s1;
end

end

function [LS,ext,level,wv,I2I] = ilwtParser(lvl,varargin)

if numel(varargin) == 0
    wv = 'db1';
    LS = liftingScheme('Wavelet',wv);
    ext = 'periodic';
    level = 0;
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
    
    isext = coder.internal.getParameterValue(pArg.extension, [],varargin{:});
    
    if isempty(isext)
        ext = 'periodic';
    else
        extType = {'zeropad','periodic','symmetric'};
        ext = validatestring(isext,extType,'ilwt','EXT');
    end
    
    islevel = coder.internal.getParameterValue(pArg.level, [],varargin{:});
    
    % parse level
    if isempty(islevel)
        % default level of decomposition
        level = 0;
    else
        level = islevel;
    end
    validateattributes(level, {'numeric'},...
        {'integer','scalar','<=',lvl-1,'>=',0},'ilwt','LEVEL');
    
    isI2I = coder.internal.getParameterValue(...
        pArg.Int2Int, [],varargin{:});
    
    if isempty(isI2I)
        I2I = 0;
    else
        I2I = isI2I;
    end
    
    validateattributes(I2I, {'logical','numeric'},{'scalar'},'ilwt','ISI2I');
end
end

function xu = upsample(x,u)
[rx,cx] = size(x);
lxu = rx*u;

xu = zeros(lxu,cx,'like',x);

for ii = 1:rx
    jj = 1+((ii-1)*u);
    xu(jj,:) = x(ii,:);
end

end

function aRec = liftMerge(sInv,dInv,stp,ext,isI2I,isOddLen)

r = numel(stp);

for ii = r:-1:1
    switch (stp(ii).Type)
        case {'d','predict'}
            dInv = inverseLift(dInv,sInv,(stp(ii).Coefficients),...
                (stp(ii).MaxOrder),ext,isI2I);
        case {'p','update'}
            sInv = inverseLift(sInv,dInv,(stp(ii).Coefficients),...
                (stp(ii).MaxOrder),ext,isI2I);
    end
end

if isrow(sInv)
    xe = [sInv;zeros(1,size(sInv,2))];
    xo = [zeros(1,size(dInv,2));dInv];
else
    xe = upsample(sInv,2);
    xo = circshift(upsample(dInv,2),1);
end

xs = xo + xe;

if isOddLen
    aRec = xs(1:end-1,:,:);
else
    aRec = xs;
end
    
end

function [isOddLen,lxr] = checkOddLen(cd)
r = numel(cd);
lcd = zeros(r,1);
lxr = lcd;

for ii = 1:r
    lcd(ii) = size(cd{ii,1},1);
end

lxr(2:r) = lcd(1:r-1);
lxr(1) = 2*lcd(1);
isOddLen = logical(mod(lxr,2));
end
