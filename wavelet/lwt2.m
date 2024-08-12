function [LL,LH,HL,HH] = lwt2(x,varargin)
%LWT2 2-D Lifting wavelet transform
%
%   [LL,LH,HL,HH] = LWT2(X) returns the 2-D wavelet decomposition of a
%   real- or complex-valued matrix X. X is a 2-D, 3-D, or 4-D matrix. The
%   wavelet decomposition is first performed along the row dimension of X.
%   This is followed by decomposition along the columns. X must have at
%   least two samples in the row and column dimensions.
%
%   If the row and column dimensions of X are powers of two, the wavelet
%   transform is obtained down to level log2(min([size(X,1), size(X,2)])).
%   If the row and column dimensions of X are even, but at least one is not
%   a power of two, the wavelet transform is obtained down to level
%   floor(log2(min([size(X,1) size(X,2)]/2))). If size(X,1) is odd, then X
%   is extended by duplicating the last row. Similarly, if size(X,2) is
%   odd, the last column of X is duplicated to extend the input. By
%   default, LWT2 uses the lifting scheme for the 'db1' wavelet and does
%   not preserve integer-valued data. If X is a single-precision input, the
%   numeric type of the wavelet transform coefficients is single precision.
%   For all other numeric types, the numeric type of the coefficients is
%   double precision. The outputs LL, LH, HL, and HH correspond to the
%   approximation, horizontal, vertical, and diagonal coefficients
%   respectively. The outputs LH, HL, and HH are LEV-by-1 cell arrays,
%   where LEV is the level of decomposition. The elements of LH, HL, and HH
%   are in order of decreasing resolution.
%   
%   [LL,LH,HL,HH] = LWT2(X,'Wavelet',W) uses the wavelet specified by the
%   character vector W to obtain the 2-D wavelet transform of X. W denotes
%   the name of an orthogonal or biorthogonal wavelet and must be one of
%   the wavelet names listed in the description of the Wavelet property of
%   LIFTINGSCHEME.
%
%   [LL,LH,HL,HH] = LWT2(X,'LiftingScheme',LS) uses the LIFTINGSCHEME
%   object LS to obtain the wavelet transform of X. 
%
%   [LL,LH,HL,HH] = LWT2(...,'Level',LEVEL) computes the lifting wavelet
%   decomposition at level LEVEL. LEVEL is a positive integer less than or
%   equal to floor(log2(N/2)), where N = min([size(X,1),size(X,2)]).
%
%   [LL,LH,HL,HH] = LWT2(...,'Extension',EXTMODE) uses the specified
%   extension mode EXTMODE to obtain the wavelet transform of X. EXTMODE
%   specifies how to extend the signal at the boundaries. Valid options for
%   EXTMODE are 'periodic' (default), 'zeropad', or 'symmetric'.
%
%   [LL,LH,HL,HH] = LWT2(...,'Int2Int',INTEGERFLAG) specifies how the
%   lifting transform handles integer-valued data.
%   true            -       preserves integer-valued data.
%   false (default) -       does not preserve integer-valued data.
%   All coefficients must be integer valued if INTEGERFLAG is set to true.
%
%   % Example: Obtain the 2-D wavelet decomposition of an RGB image using
%   % the lifting scheme associated with the Haar wavelet.
%   x = imread('ngc6543a.jpg');
%   [LL,LH,HL,HH] = lwt2(x,'Int2Int',true);
%
%   See also ILWT2, HAART2, IHAART2, LIFTINGSTEP, LIFTINGSCHEME.

%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(1,9);

validateattributes(x,{'numeric'},{'finite','nonempty'},'lwt2',...
    'X',1);

coder.internal.assert(~((isvector(x)) || (numel(size(x))> 4)),...
    'Wavelet:Lifting:UnsupportedInputType');

lx = min(size(x,1),size(x,2));

[LS,ext,level,wv,isI2I] = lwtParser(lx,varargin{:});

isSingle = false;

if ~isUnderlyingType(x,'single')
    tempx = double(x);
else
    tempx = x;
    isSingle = true;
end
%===================%
% LIFTING ALGORITHM %
%===================%

if strcmpi(wv,'lazy')
    [LL,LH,HL,HH] = multLvlLazy(tempx,level);
else
    [LL,LH,HL,HH] = multLvlDec(tempx,level,LS,ext,isI2I,isSingle);
end

end

function xrc = appendRowCol(x)

if isodd(size(x,1))
    xr = [x;x(end,:,:)];
else
    xr = x;
end

if isodd(size(xr,2))
    xrc = [xr xr(:,end,:)];
else
    xrc = xr;
end

end

function [ca,ch,cv,cd] = multLvlLazy(x,level)
ca = zeros(size(x),'like',x);
coder.varsize('ca');
ch = cell(level,1);
cv = cell(level,1);
cd = cell(level,1);

% check for odd row or columns
isOddRow = isodd(size(x,1));
isOddCol = isodd(size(x,2));

if isOddRow || isOddCol
    x = appendRowCol(x);
end

xIn = x;
coder.varsize('xIn');

for ll = 1:level
    sx = size(xIn);

    if numel(sx) >= 3
        s = [sx(1) sx(2) prod(sx(3:end))];
    else
        s = [sx 1];
    end

    % collapse nD array to 3D array
    xc = reshape(xIn,s);
    isOddRow = isodd(s(1));
    isOddCol = isodd(s(2));

    if isOddRow || isOddCol
        xc = appendRowCol(xc);
    end

    src = size(xc);
    a = zeros(src,'like',xIn);
    az = zeros(src(1:2),'like',xIn);
    h = zeros(src,'like',xIn);
    hz = zeros(src(1:2),'like',xIn);
    v = zeros(src,'like',xIn);
    vz = zeros(src(1:2),'like',xIn);
    d = zeros(src,'like',xIn);
    dz = zeros(src(1:2),'like',xIn);
    coder.varsize('a');
    coder.varsize('h');
    coder.varsize('d');
    coder.varsize('v');
    coder.varsize('az');
    coder.varsize('hz');
    coder.varsize('dz');
    coder.varsize('vz');

    for nn = 1:s(3)
        xrc = appendRowCol(xc(:,:,nn));
        [Li,Hi] = rowSpilt(xrc);
        [az,hz] = split(Li);
        [vz,dz] = split(Hi);

        if (nn == 1)
            src(1:2) = size(az);
            a = zeros(src,'like',xIn);
            src(1:2) = size(hz);
            h = zeros(src,'like',xIn);
            src(1:2) = size(vz);
            v = zeros(src,'like',xIn);
            src(1:2) = size(dz);
            d = zeros(src,'like',xIn);
        end

        a(:,:,nn) = az;
        h(:,:,nn) = hz;
        v(:,:,nn) = vz;
        d(:,:,nn) = dz;
    end

    ca = reshape(a,[size(az) sx(3:end)]);
    ch{ll,1} = reshape(h,[size(hz) sx(3:end)]);
    cv{ll,1} = reshape(v,[size(vz) sx(3:end)]);
    cd{ll,1} = reshape(d,[size(dz) sx(3:end)]);

    if (level > 1)
        xIn = ca;
    end
end

end

function [ca,ch,cv,cd] = multLvlDec(x,level,LS,ext,isI2I,isSingle)
ca = zeros(size(x),'like',x);
coder.varsize('ca');
ch = cell(level,1);
cv = cell(level,1);
cd = cell(level,1);

% check for odd row or columns
isOddRow = isodd(size(x,1));
isOddCol = isodd(size(x,2));

if isOddRow || isOddCol
    x = appendRowCol(x);
end

xIn = x;
coder.varsize('xIn');

for ll = 1:level
    sx = size(xIn);

    if numel(sx) >= 3
        s = [sx(1) sx(2) prod(sx(3:end))];
    else
        s = [sx 1];
    end

    % collapse nD array to 3D array
    xc = reshape(xIn,s);
    isOddRow = isodd(s(1));
    isOddCol = isodd(s(2));

    if isOddRow || isOddCol
        xc = appendRowCol(xc);
    end

    src = size(xc);
    a = zeros(src,'like',xIn);
    az = zeros(src(1:2),'like',xIn);
    h = zeros(src,'like',xIn);
    hz = zeros(src(1:2),'like',xIn);
    v = zeros(src,'like',xIn);
    vz = zeros(src(1:2),'like',xIn);
    d = zeros(src,'like',xIn);
    dz = zeros(src(1:2),'like',xIn);
    coder.varsize('a');
    coder.varsize('h');
    coder.varsize('d');
    coder.varsize('v');
    coder.varsize('az');
    coder.varsize('hz');
    coder.varsize('dz');
    coder.varsize('vz');

    steps = LS.LiftingSteps;
    K = LS.NormalizationFactors;

    for nn = 1:s(3)
        xrc = appendRowCol(xc(:,:,nn));
        [xe,xo] = rowSpilt(xrc);
        if isreal(xe)
            [Li,Hi] = predictUpdate(transpose(xe),transpose(xo),steps,...
                K,ext,isI2I,isSingle);
            [Le,Lo] = split(transpose(Li));
            [az,hz] = predictUpdate(Le,Lo,steps,K,ext,isI2I,isSingle);
            [He,Ho] = split(transpose(Hi));
            [vz,dz] = predictUpdate(He,Ho,steps,K,ext,isI2I,isSingle);
        else
            [Lri,Hri] = predictUpdate(real(transpose(xe)),...
                real(transpose(xo)),steps,K,ext,isI2I,isSingle);
            [Lii,Hii] = predictUpdate(imag(transpose(xe)),...
                imag(transpose(xo)),steps,K,ext,isI2I,isSingle);
            Li = Lri+(1i*Lii);
            Hi = Hri+(1i*Hii);
            [Le,Lo] = split(transpose(Li));
            [azr,hzr] = predictUpdate(real(Le),real(Lo),steps,K,ext,...
                isI2I,isSingle);
            [azi,hzi] = predictUpdate(imag(Le),imag(Lo),steps,K,ext,...
                isI2I,isSingle);
            az = azr + (1i*azi);
            hz = hzr + (1i*hzi);
            [He,Ho] = split(transpose(Hi));
            [vzr,dzr] = predictUpdate(real(He),real(Ho),steps,K,ext,...
                isI2I,isSingle);
            [vzi,dzi] = predictUpdate(imag(He),imag(Ho),steps,K,ext,...
                isI2I,isSingle);
            vz = vzr + (1i*vzi);
            dz = dzr + (1i*dzi);
        end

        if (nn == 1)
            src(1:2) = size(az);
            a = zeros(src,'like',xIn);
            src(1:2) = size(hz);
            h = zeros(src,'like',xIn);
            src(1:2) = size(vz);
            v = zeros(src,'like',xIn);
            src(1:2) = size(dz);
            d = zeros(src,'like',xIn);
        end

        a(:,:,nn) = az;
        h(:,:,nn) = hz;
        v(:,:,nn) = vz;
        d(:,:,nn) = dz;
    end

    ca = reshape(a,[size(az) sx(3:end)]);
    ch{ll,1} = reshape(h,[size(hz) sx(3:end)]);
    cv{ll,1} = reshape(v,[size(vz) sx(3:end)]);
    cd{ll,1} = reshape(d,[size(dz) sx(3:end)]);

    if (level > 1)
        xIn = ca;
    end
end

end

function [ca,cd] = predictUpdate(s,d,steps,K,ext,isI2I,isSingle)

r = size(steps,1);

switch ext
    case 'zeropad'
        sl = [zeros(8,size(s,2),'like',s); s; zeros(8,size(s,2),'like',s)];
        dl = [zeros(8,size(d,2),'like',d); d; zeros(8,size(d,2),'like',d)];
    case 'symmetric'
        lz = size(s,1);
        if (lz > 1)
            indS = [1:lz lz-1:-1:2]';
        else
            indS = [1 1 1]';
        end
        sl = s(indS,:,:,:);
        dl = d(indS,:,:,:);
    otherwise
        sl = s;
        dl = d;
end

for ii = 1: r

    C = steps(ii).Coefficients;
    ord = steps(ii).MaxOrder;

    switch (steps(ii).Type)
        case {'d','predict'}
            if isSingle
                dl = forwardLift(dl,sl,single(C),single(ord),ext,isI2I);
            else
                dl = forwardLift(dl,sl,C,ord,ext,isI2I);
            end

        case {'p','update'}
            if isSingle
                sl = forwardLift(sl,dl,single(C),single(ord),ext,isI2I);
            else
                sl = forwardLift(sl,dl,C,ord,ext,isI2I);
            end
    end
end

if isI2I
    cd = dl;
    ca = sl;
else
    if isSingle
        cd = dl*single(K(2));
        ca = sl*single(K(1));
    else
        cd = dl*K(2);
        ca = sl*K(1);
    end
end

end

function d = forwardLift(z1,z2,lF,maxOrd,ext,isI2I)
s = zeros(size(z2),'like',z2);
sd = coder.nullcopy(z2);
for jj = 1:length(lF)
    d =  maxOrd+1-jj;
    sf = lF(jj)*z2;
    switch ext
        case {'zeropad'}
            sd = timeShift(sf,-d);
        case {'periodic','symmetric'}
            sd = circshift(sf,-d);
        otherwise
            coder.internal.error('Wavelet:Lifting:UnsupportedExt');
    end

    s = s + sd;
end

if isI2I
    if isa(s,'single')
        d = z1 + floor(s+single(0.5));
    else
        d = z1 + floor(s+0.5);
    end
else
    d = z1 + s;
end

end

function [xe,xo] = split(x)

sx = size(x,1);

% even indexed input
xe = x(1:2:sx,:,:);

% odd indexed input
xo = x(2:2:sx,:,:);
end

function [L,H] = rowSpilt(x)
L = x(:,1:2:end,:);
H = x(:,2:2:end,:);
end

function [LS,ext,level,wv,I2I] = lwtParser(lx,varargin)

if numel(varargin) == 0
    wv = 'db1';
    LS = liftingScheme('Wavelet',wv);
    ext = 'periodic';
    I2I = 0;
    if ~rem(log2(lx),1)
        level = log2(lx);
    else
        level = floor(log2(lx/2));
    end

else
    % name value-pairs
    parms = {'Wavelet','Extension','Level','LiftingScheme','Int2Int'};

    % Select parsing options.
    poptions = struct('PartialMatching','unique');
    pArg = coder.internal.parseParameterInputs(parms,poptions,varargin{:});

    iswv = coder.internal.getParameterValue(pArg.Wavelet,[],varargin{:});
    isLS = coder.internal.getParameterValue(pArg.LiftingScheme,[],...
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

    isext = coder.internal.getParameterValue(pArg.Extension,[],varargin{:});

    if isempty(isext)
        ext = 'periodic';
    else
        extType = {'zeropad','periodic','symmetric'};
        ext = validatestring(isext,extType,'lwt2','EXT');
    end

    islevel = coder.internal.getParameterValue(pArg.Level,[],varargin{:});

    % parse level
    if isempty(islevel)
        if ~rem(log2(lx),1)
            level = log2(lx);
        else
            level = floor(log2(lx/2));
        end
        validateattributes(level, {'numeric'}, ...
        {'scalar','integer','positive'},'lwt2','LEVEL');
    else
        level = islevel;
        if ~rem(log2(lx),1)
            N = log2(lx);
        else
            N = floor(log2(lx/2));
        end

        validateattributes(level, {'numeric'}, {'scalar','integer',...
            'positive','<=',N},'lwt2','LEVEL');
    end

    isI2I = coder.internal.getParameterValue(pArg.Int2Int,[],varargin{:});

    if isempty(isI2I)
        I2I = 0;
    else
        I2I = isI2I;
    end

    validateattributes(I2I, {'logical','numeric'},{'scalar'},...
        'lwt2','ISI2I');
end

end

function sd = timeShift(s,d)
indz = 1:size(s,1);
indD = indz + d;
inds = intersect(indz,indD);
n = numel(setdiff(indz,indD));

sd = zeros(size(s),'like',s);
if d >= 0
    sd(inds,:) = s(1:length(inds),:);
else
    sd(inds,:) = s(n+1:end,:);
end
end

