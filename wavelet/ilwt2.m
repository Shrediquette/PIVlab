function xr = ilwt2(LL,LH,HL,HH,varargin)
%ILWT2 Inverse 2-D lifting wavelet transform.
%
%   XR = ILWT2(LL,LH,HL,HH) returns the 2-D inverse wavelet transform based
%   on the approximation coefficients, LL, and cell arrays of horizontal,
%   vertical, and detail coefficients, LH, HL, and HH respectively.
%   LL, LH, HL, and HH are outputs of LWT2. By default, ILWT2 assumes that
%   you used the lifting scheme associated with the 'db1' wavelet to obtain
%   the coefficients. If you do not modify the coefficients, XR is a
%   perfect reconstruction of the signal. If LL and the elements of LH, HL,
%   and HH have 2, 3, or 4 dimensions, XR will be a matrix of similar
%   dimensions.
%
%   XR = ILWT2(LL,LH,HL,HH,'Wavelet',W) uses the wavelet specified by the
%   character vector W. W denotes the name of an orthogonal or biorthogonal
%   wavelet and must be one of the wavelet names supported by
%   LIFTINGSCHEME. For perfect reconstruction, W must be the same wavelet
%   that was used to obtain the coefficients LL, LH, HL, and HH.
%
%   XR = ILWT(LL,LH,HL,HH,'LiftingScheme',LS) uses the LIFTINGSCHEME
%   object, LS, to obtain the 2-D inverse wavelet transform. If
%   unspecified, LS defaults to the lifting scheme associated with the
%   'db1' wavelet. For perfect reconstruction, LS must be the same lifting
%   scheme that was used to obtain the coefficients LL, LH, HL, and HH. 
%
%   XR = ILWT2(...,'Level',LEVEL) returns the inverse 2-D wavelet transform
%   up to level LEVEL. LEVEL is a nonnegative integer less than or equal to
%   length(HH)-1. If unspecified, LEVEL defaults to 0 and XR is a perfect
%   reconstruction of the signal.
%
%   XR = ILWT2(...,'Extension',EXTMODE) uses the specified extension mode
%   EXTMODE. EXTMODE specifies how to extend the signal at the boundaries.
%   Valid options for EXTMODE are 'periodic' (default), 'zeropad', or
%   'symmetric'.
%
%   XR = ILWT2(...,'Int2Int',INTEGERFLAG) specifies how the 2-D inverse
%   wavelet transform handles integer-valued data.
%   true            - preserves integer-valued data.
%   false (default) - does not preserve integer-valued data.
%   All coefficients must be integer valued if INTEGERFLAG is set to true.
%
%   % Example: Obtain the 2-D wavelet decomposition of an RGB image using
%   % the lifting scheme associated with the Haar wavelet. Then reconstruct
%   % the image from the coefficients using ilwt2. Demonstrate perfect
%   % reconstruction.
%   x = imread('ngc6543a.jpg');
%   [LL,LH,HL,HH] = lwt2(x,'Int2Int',true);
%   xr = ilwt2(LL,LH,HL,HH,'Int2Int',true);
%   max(abs(double(x(:))-xr(:)))
%
%   See also LWT2, IHAART2, LIFTINGSTEP, LIFTINGSCHEME.

%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(4,12);
nargoutchk(0,1);

lvl = numel(LH);

validateattributes(LL, {'numeric'},{'nonempty','finite','nonnan'},...
    'ilwt2','LL',1);

isLLsingle = isa(LL,'single');

% Check arguments.
if ~isreal(LL)
    validateattributes(real(LL),{'numeric'},...
        {'nonempty','finite','nonnan'},'ilwt2','LL',1);
    validateattributes(imag(LL), {'numeric'},...
        {'nonempty','finite','nonnan'},'ilwt2','LL',1);
end

validateattributes(LH, {'numeric','cell'},{'nonempty'},'ilwt2','LH',2);
validateattributes(HL, {'numeric','cell'},{'nonempty'},'ilwt2','HL',2);
validateattributes(HH, {'numeric','cell'},{'nonempty'},'ilwt2','HH',2);

LLin = double(LL);
coder.varsize('LLin');
LHin = cell(size(LH));
HLin = cell(size(HL));
HHin = cell(size(HH));

for kk = 1:numel(LHin)
    LHin{kk} = double(LH{kk});
end

for kk = 1:numel(HLin)
    HLin{kk} = double(HL{kk});
end

for kk = 1:numel(HHin)
    HHin{kk} = double(HH{kk});
end

sL = size(LLin);

coder.internal.assert(~((isvector(LLin) && ~isscalar(LLin))|| ...
    (numel(sL)> 4)),'Wavelet:Lifting:UnsupportedCoefType');

[LS,ext,level,~,isI2I] = ilwtParser(lvl,varargin{:});
xo = zeros(size(LLin),'like',LLin);
coder.varsize('xr');

%===================%
% LIFTING ALGORITHM %
%===================%
LIn = LLin;
coder.varsize('LIn');
for ii = lvl:-1:1
    if ii == (level)
        break;
    end
    
    if isreal(LIn)
        xo = invLWT(LIn,LHin{ii},HLin{ii},HHin{ii},LS,ext,isI2I);
    else
        xor = invLWT(real(LIn),real(LHin{ii}),real(HLin{ii}),...
            real(HHin{ii}),LS,ext,isI2I);
        xoi = invLWT(imag(LIn),imag(LHin{ii}),imag(HLin{ii}),...
            imag(HHin{ii}),LS,ext,isI2I);
        xo = xor + (1i*xoi);
    end
    
    if lvl > 1
        LIn = xo;
    end
end

if isLLsingle
    xr = single(xo);
else
    xr = xo;
end

end

function xs = invLWT(ain,h,v,d,LS,ext,isI2I)
%IHLWT2 Haar (Integer) Wavelet reconstruction 2-D using lifting.
%   IHLWT2 performs the 2-D lifting Haar wavelet reconstruction.
%
%   X = INVLWT(CA,CH,CV,CD) computes the reconstructed matrix X using the
%   approximation coefficients vector CA and detail coefficients vectors
%   CH, CV, CD obtained by the Haar lifting wavelet decomposition.
%
%   X = INVLWT(CA,CH,CV,CD,INTFLAG) computes the reconstructed matrix X,
%   using the integer scheme.
%
% Test for odd input.
a = double(ain);
hin = double(h);
din = double(d);
vin = double(v);

if size(a,2) <size(hin,2)
    hin(:,end,:,:) = [];
elseif size(a,2) > size(hin,2)
    a(:,end,:,:) = [];
end

if size(a,1) <size(hin,1)
    hin(end,:,:,:) = [];
elseif size(a,1) > size(hin,1)
    a(end,:,:,:) = [];
end

if size(din,2) <size(vin,2)
    vin(:,end,:,:) = [];
elseif size(din,2) > size(vin,2)
    din(:,end,:,:) = [];
end

if size(din,1) <size(vin,1)
    vin(end,:,:,:) = [];
elseif size(din,1) > size(vin,1)
    din(end,:,:,:) = [];
end

odd_Col = size(din,2)<size(a,2);
if odd_Col
    sd = size(din);
    sd(2) = sd(2)+1;
    sv = size(vin);
    sv(2) = sv(2)+1;
    
    tempd = zeros(sd,'like',din);
    tempv = zeros(sv,'like',vin);
    
    tempd(:,1:end-1,:,:) = din(:,1:end,:,:);
    tempv(:,1:end-1,:,:) = vin(:,1:end,:,:);
else
    tempd = din;
    tempv = vin;
end

odd_Row = size(din,1) < size(a,1);
if odd_Row
    sd = size(tempd);
    sd(1) = sd(1)+1;
    sh = size(hin);
    sh(1) = sh(1)+1;
    
    tempd_final = zeros(sd,'like',tempd);
    temph = zeros(sh,'like',hin);
    
    tempd_final(1:end-1,:,:,:) = tempd(1:end,:,:,:);
    temph(1:end-1,:,:,:) = hin(1:end,:,:,:);
else
    tempd_final = tempd;
    temph = hin;
end

h = temph;
v = tempv;
d = tempd_final;

sa = size(a);
sh = size(h);
sv = size(v);
sd = size(d);

if numel(sa) >= 3
    sa3 = [sa(1:2) prod(sa(3:end))];
else
    sa3 = [sa(1:2) 1];
end

if numel(sh) >= 3
    sh3 = [sh(1:2) prod(sh(3:end))];
else
    sh3 = [sh(1:2) 1];
end

if numel(sd) >= 3
    sd3 = [sd(1:2) prod(sd(3:end))];
else
    sd3 = [sd(1:2) 1];
end

if numel(sv) >= 3
    sv3 = [sv(1:2) prod(sv(3:end))];
else
    sv3 = [sv(1:2) 1];
end

a3 = reshape(a,sa3);
h3 = reshape(h,sh3);
v3 = reshape(v,sv3);
d3 = reshape(d,sd3);
Lr = zeros(size([a3;h3]),'like',a3);

for ii = 1:sh3(3)
    Lz = colProc(a3(:,:,ii),h3(:,:,ii),LS,ext,isI2I);
    Lr(:,:,ii) = Lz;
end

Hr = zeros(size([v3;d3]),'like',v3);

for ii = 1:sd3(3)
    Hz = colProc(v3(:,:,ii),d3(:,:,ii),LS,ext,isI2I);
    Hr(:,:,ii) = Hz;
end

iL = 1:numel(size(Lr));
iL(1) = 2;
iL(2) = 1;

Lp = permute(Lr,iL);

iH = 1:numel(size(Hr));
iH(1) = 2;
iH(2) = 1;
Hp = permute(Hr,iH);
xp = zeros(size([Lp;Hp]),'like',Hp);

for ii = 1:size(Lp,3)
    xz = colProc(Lp(:,:,ii),Hp(:,:,ii),LS,ext,isI2I);
    xp(:,:,ii) = xz;
end

xi = ipermute(xp,iL);
s = sd;
s(1) = size(xi,1);
s(2) = size(xi,2);
xs = reshape(xi,s);

% Test for odd output.
if odd_Col
    xs(:,end,:,:) = [];
end
if odd_Row
    xs(end,:,:,:) = [];
end

if strcmpi(ext,'zeropad') && ~strcmpi(LS.Wavelet,'lazy')
    xs(1:16,:,:,:) = [];
    xs(:,1:16,:,:) = [];
    nr = size(xs,1);
    nc = size(xs,2);
    xs((nr-15:nr),:,:,:) = [];
    xs(:,(nc-15:nc),:,:) = [];
elseif strcmpi(ext,'symmetric') && ~strcmpi(LS.Wavelet,'lazy')
    nrs = size(xs,1);
    nr0 = (nrs+4)/2;
    xs((nr0+1):nrs,:,:,:) = [];
    
    ncs = size(xs,2);
    nc0 = (ncs+4)/2;
    xs(:,(nc0+1):ncs,:,:) = [];
end

end
%=========================================================================%
function xs = colProc(c,d,LS,ext,isI2I)
K = LS.NormalizationFactors;
stp = LS.LiftingSteps;
r = numel(stp);

validateattributes(d,{'numeric'},{'nonempty','finite','nonnan'},...
    'ilwt','D');

if isI2I
    dInv = d;
    sInv = c;
else
    dInv = d*K(1);
    sInv = c*K(2);
end

coder.varsize('dInv');
coder.varsize('sInv');

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
    coder.varsize('xe');
    xo = [zeros(1,size(dInv,2));dInv];
    coder.varsize('xo');
else
    xe = upsample(sInv,2);
    xo = circshift(upsample(dInv,2),1);
end

xs = xo + xe;
end

function d = inverseLift(z1,z2,lF,maxOrd,ext,isI2I)
s = zeros(size(z1),'like',z1);

for jj = 1:length(lF)
    d =  maxOrd+1-jj;
    switch ext
        case {'zeropad'}
            sd = timeShift((lF(jj)*z2),-d);
        case {'periodic','symmetric'}
            sd = circshift((lF(jj)*z2),-d);
        otherwise
            coder.internal.error('Wavelet:Lifting:UnsupportedExt');
    end
    s = s + sd;
end

if isI2I
    d = z1 - floor(s+0.5);
else
    d = z1 - s;
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
        ext = validatestring(isext,extType,'ilwt2','EXT');
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
        {'integer','scalar','<=',lvl-1,'>=',0},'ilwt2','LEVEL');
    
    isI2I = coder.internal.getParameterValue(...
        pArg.Int2Int, [],varargin{:});
    
    if isempty(isI2I)
        I2I = 0;
    else
        I2I = isI2I;
    end
    
    validateattributes(I2I, {'logical','numeric'},{'scalar'},'ilwt2','ISI2I');
end
end

function xu = upsample(x,u)
sx = size(x);
sxu = sx;
sxu(1) = sx(1)*u;

xu = zeros(sxu,'like',x);

for ii = 1:sx(1)
    jj = 1+((ii-1)*u);
    xu(jj,:,:,:) = x(ii,:,:,:);
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