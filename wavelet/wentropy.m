function [ent,Pij] = wentropy(x,LegacyType,LegacyOpt,NVargs)
%Wavelet entropy
%   ENT = WENTROPY(X) returns the normalized Shannon wavelet entropy of X.
%   X is a double- or single-precision real-valued row or column vector, a
%   cell array of real-valued row or column vectors, or a real-valued
%   matrix with at least two rows. If X is a row or column vector, X must
%   have at least 4 samples and is assumed to be time data. If X is a cell
%   array, X is assumed to be a decimated wavelet or wavelet packet
%   transform of a real-valued row or column vector. If X is a matrix with
%   at least two rows, X is assumed to be the maximal overlap discrete
%   wavelet or wavelet packet transform of a real-valued row or column
%   vector. If X is a time series, the maximal overlap discrete wavelet
%   transform of X is obtained using the 'sym4' wavelet down to level
%   floor(log2(N))-1, where N is the length of the data. ENT is a
%   real-valued (Ns+1)-by-1 vector of entropy estimates by scale if X is
%   time data, where Ns is the number of scales. If X is a wavelet or
%   wavelet packet transform input, ENT is a real-valued column vector with
%   length equal to the length of X if X is a cell array, or the row
%   dimension of X if X is a matrix. See the 'Distribution' option to
%   obtain global estimates of the wavelet entropy. WENTROPY uses the
%   natural logarithm to compute the entropy.
%
%   ENT = WENTROPY(...,Entropy=ETRPY) specifies the entropy returned by
%   WENTROPY. Valid entries for ETRPY are "Shannon", "Renyi", and
%   "Tsallis". If unspecified, ETRPY defaults to "Shannon".
%
%   ENT = WENTROPY(...,Exponent=EXPVAL) specifies the exponent used in the
%   Renyi and Tsallis entropy. In both cases, EXPVAL is a real-valued
%   scalar. For the Renyi entropy, EXPVAL must be nonnegative. For the
%   Tsallis entropy, EXPVAL must be greater than or equal to -1/2. For the
%   Renyi and Tsallis entropies, the value EXPVAL=1 is a limiting case and
%   produces the Shannon entropy. Specifying EXPVAL is only valid when
%   ETRPY is "Renyi" or "Tsallis". EXPVAL defaults to 2 for the Renyi and
%   Tsallis entropies.
%
%   ENT = WENTROPY(X,Transform=WT) uses the transform WT to obtain the
%   wavelet or wavelet packet coefficients for the real-valued row or
%   column vector, X. Valid options for WT are "modwt", "modwpt", "dwt",
%   and "dwpt". Periodic extension is used for all transforms. For
%   Transform="modwt" and Transform="dwt", the wavelet coefficients are
%   calculated using the 'sym4' wavelet. For Transform="dwpt" and
%   Transform="modwpt", the wavelet packet coefficients are calculated
%   using the 'fk18' wavelet. Specifying a transform is only valid when X
%   is time series data.
%
%   ENT = WENTROPY(...,Level=LEV) obtains the wavelet transform down to
%   level, LEV, if the input is time data. LEV is a positive real-valued
%   scalar. If unspecified, LEV defaults to floor(log2(N))-1 for "modwt"
%   and "dwt", where N is the signal length. For "modwpt" and "dwpt", LEV
%   defaults to min(4,floor(log2(N))-1). Specifying a level is invalid if
%   the input data are wavelet or wavelet packet coefficients.
%
%   ENT = WENTROPY(...,Wavelet=WNAME) uses the specified wavelet, WNAME, to
%   obtain the wavelet or wavelet packet transform for a real-valued row or
%   column vector input. For Transform="modwt" and Transform="modwpt", the
%   wavelet must be orthogonal. Specifying a wavelet name is invalid if the
%   input data are wavelet or wavelet packet coefficients.
%
%   ENT = WENTROPY(...,Distribution=DIST) obtains the empirical probability
%   distribution for the wavelet transform coefficients based on DIST.
%   Valid options for DIST are "scale" and "global". If unspecified, DIST
%   defaults to "scale". When DIST is "global", the squared magnitudes of
%   the coefficients are normalized by the total sum of squared magnitudes
%   of all coefficients. Each scale in the wavelet transform yields a
%   scalar and the vector of these values forms a probability vector.
%   Entropy calculations are performed on this vector and the overall
%   entropy is a scalar. If DIST="scale", the wavelet coefficients at each
%   scale are normalized separately and the entropy calculation is done by
%   scale yielding a vector output of size (Ns+1)-by-1, where Ns is the
%   number of scales if the input is time series data. If the input is a
%   cell array or matrix, the output is M-by-1, where M is the length of the 
%   cell array or number of rows in the matrix.
%
%   ENT = WENTROPY(...,Scaled=TF) with TF set to true scales the wavelet
%   entropy by the factor corresponding to a uniform distribution for the
%   specified entropy. For the Shannon and Renyi entropies, the factor is
%   1/log(Nj), where Nj is the length of the data in samples by scale if
%   'Distribution' is "scale", or the number of scales if 'Distribution' is
%   "global". For the Tsallis entropy, the factor is
%   (EXPVAL-1)/(1-Nj^(1-EXPVAL)), where EXPVAL is the value of 'Exponent'
%   for the Tsallis entropy. Setting Scaled=false does not scale the
%   wavelet entropy. If unspecified, TF defaults to true.
%   
%   ENT = WENTROPY(...,EnergyThreshold=THRESH) replaces all coefficients
%   with energy by scale below THRESH with 0. THRESH is a nonnegative
%   scalar. If unspecified, THRESH defaults to 1e-8. A positive
%   'EnergyThreshold' prevents wavelet or wavelet packet coefficients with
%   non-significant energy from being treated as a sequence with high
%   entropy.
%
%   [ENT,RE] = WENTROPY(...) returns the relative wavelet energies by
%   coefficient and scale if DIST is equal to "scale" or by scale if DIST
%   is equal to "global". Scales where the coefficient energy is below the
%   value of 'EnergyThreshold' are equal to 0.
%
%   %Example 1:
%   %   Obtain the wavelet entropy estimates by scale for a signal designed
%   %   to have the maximum normalized entropy for a one-level wavelet
%   %   transform.
%   n = 0:511;
%   x = (-1).^n+1;
%   ent = wentropy(x,Level=1);
%
%   %Example 2:
%   %   Obtain the tunable Q-factor wavelet transform of the Kobe
%   %   earthquake data with the quality factor equal to 2. Obtain the 
%   %   Renyi entropy estimates for the tunable Q-factor transform.
%   load kobe
%   wt = tqwt(kobe,QualityFactor=2);
%   ent = wentropy(wt,Entropy="Renyi");
%
%   %Example 3:
%   %   Obtain the DWT of an electrocardiogram signal. Package the wavelet
%   %   and approximation coefficients into a cell array suitable for
%   %   computing the wavelet entropy. Obtain the Renyi entropy by scale.
%   load wecg
%   [C,L] = wavedec(wecg,floor(log2(numel(wecg))),'db4');
%   X = detcoef(C,L,'cells');
%   X{end+1} = appcoef(C,L,'db4');
%   ent = wentropy(X,Entropy="Renyi");
%
%   See Also modwt, modwpt, wavedec, tqwt, dwpt

%   Copyright 1996-2022 The MathWorks, Inc. 
arguments
    x 
    LegacyType = []
    LegacyOpt = []
    NVargs.Wavelet = ''
    NVargs.Transform = ''
    NVargs.Entropy = 'Shannon'
    NVargs.Exponent = []
    NVargs.Scaled = true
    NVargs.Level = []
    NVargs.Distribution = "scale"  
    NVargs.EnergyThreshold = []
end
% Make legacy call if needed
if ~isempty(LegacyType) && isempty(LegacyOpt)
    ent = wavelet.internal.wentropy(x,LegacyType);
    return;
elseif ~isempty(LegacyType) && ~isempty(LegacyOpt)
    ent = wavelet.internal.wentropy(x,LegacyType,LegacyOpt);
    return;
end
% Cannot validate input before legacy call
mustBeValidInput(x);
% Is the data a wavelet transform and return data type
[tfTransform,dataType] = isTransformData(x);
% Is the threshold specified
if isempty(NVargs.EnergyThreshold) && strcmp(dataType,'double')
    thresh = 1e-8;
elseif isempty(NVargs.EnergyThreshold) && strcmp(dataType,'single')
    thresh = single(1e-8);
else
    validateattributes(NVargs.EnergyThreshold,{'double','single'}, {'scalar',...
        'nonnegative'});
    thresh = cast(NVargs.EnergyThreshold,dataType);
end

if tfTransform && (~isempty(NVargs.Transform) || ~isempty(NVargs.Wavelet)...
        || ~isempty(NVargs.Level))
    error(message('Wavelet:entropy:InvalidWithTransform'));
end

pTransform = NVargs.Transform;
if ~tfTransform && isempty(pTransform)
    pTransform = 'modwt';
elseif ~tfTransform && ~isempty(pTransform)
     pTransform = validatestring(pTransform,...
        {'modwt','modwpt','dwt','dwpt'},'wentropy','Transform');
end
%Common orientation
if ~tfTransform && isrow(x)
    xcol = x(:);
else
    xcol = x;
end
% length of data, or cell array, or number of rows
N = size(xcol,1);
pEntropy = validatestring(NVargs.Entropy,{'Shannon','Renyi','Tsallis'}, ...
    'wentropy','Entropy');
pDistribution = validatestring(NVargs.Distribution,{'scale','global'},...
    'wentropy','Distribution');
pLevel = setLevel(N,NVargs.Level,pTransform);
pExp = NVargs.Exponent;
pWavelet = NVargs.Wavelet;
pScaled = NVargs.Scaled;
if ~isempty(pExp) && startsWith(pEntropy,'S'),...
    error(message('Wavelet:entropy:expNoShannon'));
end

if isempty(pExp) && (startsWith(pEntropy,'R') || startsWith(pEntropy,'T'))
    pExp = 2;
end
% Handle limiting case when exponent goes to 1.
if ~isempty(pExp) && ~startsWith(pEntropy,'S')
    [entmethod,expvalue] = validateExponent(pExp,pEntropy,dataType);
else
    entmethod = 'Shannon';
    expvalue = 1;
end

if isempty(pWavelet)
    switch pTransform
        case {'modwpt','dwpt'}
            pWavelet = 'fk18';
        otherwise
            pWavelet = 'sym4';
    end
end

if ~tfTransform
    wt = getTransform(xcol,pTransform,pWavelet,pLevel);
else
    wt = xcol;
end

if iscell(wt)
    Nr = cellfun(@(x)size(x,1),wt);  
    if all(Nr==1)
        wt = cellfun(@(x)transpose(x),wt,'UniformOutput',false);
    end
end

[Pij,N] = getProbability(wt,pDistribution,thresh);
ent = getEntropy(Pij,entmethod,pScaled,expvalue,N);

%-------------------------------------------------------------------------
function se = getEntropy(Pij,entmethod,scaledTF,expvalue,N)
if iscell(Pij)
    datatype = underlyingType(Pij{1});
else
    datatype = underlyingType(Pij);
end
if startsWith(entmethod,'S')
    se = shannonEntropy(Pij,scaledTF,N,datatype);
elseif startsWith(entmethod,'R')
    se = renyiEntropy(Pij,expvalue,scaledTF,N,datatype);
else
    se = tsallisEntropy(Pij,expvalue,scaledTF,N,datatype);
end

%--------------------------------------------------------------------------
function se = shannonEntropy(Pij,scaledTF,N,datatype)
if iscell(Pij)
    fhandl = @(x)-sum(x.*log(x),1,'omitnan');
    se = cellfun(fhandl,Pij);
else
    if size(Pij,2) == 1
        se = squeeze(-sum(Pij.*log(Pij),1,'omitnan'));
        se = se';
        se(se<eps(datatype)) = zeros(1,1,datatype);
    else
        se = squeeze(-sum(Pij.*log(Pij),2,'omitnan'));
        se(se < eps(datatype)) = zeros(1,1,datatype);
    end
end
se(~isfinite(se)) = zeros(1,1,datatype);
if scaledTF     
    se = se./log(N);
    se(N==1) = zeros(1,1,datatype);
end
if isrow(se)
    se = se(:);
end
%--------------------------------------------------------------------------
function re = renyiEntropy(Pij,alpha,scaledTF,N,datatype)
if iscell(Pij)    
    fhandl = @(x)1/(1-alpha)*log(sum(x.^alpha,"omitnan"));
    re = cellfun(fhandl,Pij);
else
    if size(Pij,2) == 1
        re = 1/(1-alpha)*log(sum(Pij.^alpha,1,'omitnan'));
        re = reshape(re,1,[]);
    else
        re = 1/(1-alpha)*log(sum(Pij.^alpha,2,'omitnan'));
    end
end
re(~isfinite(re)) = zeros(1,1,datatype);
if scaledTF
    re = re./log(N);
    re(N==1) = zeros(1,1,'like',re);
end
if isrow(re)
    re = re(:);
end

%--------------------------------------------------------------------------
function te = tsallisEntropy(Pij,q,scaledTF,N,datatype)
qMinus1 = q-1;
if iscell(Pij)
    fhandl = @(x)1/qMinus1*sum(x-x.^q,'omitnan');
    te = cellfun(fhandl,Pij);
else
    if size(Pij,2) == 1
        te = 1/qMinus1*sum(Pij-Pij.^q,1,'omitnan');
        te = reshape(te,1,[]);
    else
        te = 1/qMinus1*sum(Pij-Pij.^q,2,'omitnan');
    end
end
normFactor = qMinus1./(1-N.^-qMinus1);
if scaledTF
    te = normFactor.*te;
    te(N==1) = zeros(1,1,datatype);
end
if isrow(te)
    te = te(:);
end

%--------------------------------------------------------------------------
function [entmethod,expvalue] = validateExponent(exponent,entropy,type)
entmethod = 'Shannon';
expvalue = ones(1,1,type);
tmpexp = cast(exponent,type);
switch entropy
    case 'Renyi'
        validateattributes(exponent,{'numeric'},...
            {'scalar','real','nonnegative','nonempty','finite'},'WENTROPY','Exponent');
        if abs(expvalue - tmpexp) > eps(type)
            expvalue = tmpexp;
            entmethod = 'Renyi';
        end
    case 'Tsallis'
        validateattributes(exponent,{'numeric'},...
            {'scalar','real', 'nonempty','finite', '>=',-1/2},'WENTROPY','Exponent');
        if abs(expvalue - tmpexp) > eps(type)
            expvalue = tmpexp;
            entmethod = 'Tsallis';
        end
end

%-------------------------------------------------------------------------
function [Pij,N] = getProbability(cfs,pNormalization,energyThresh)
cellT = iscell(cfs);
if startsWith(pNormalization,'s')
    if cellT
        Energy = cellfun(@(x)norm(x,2)^2,cfs);
        zeroEnergy = Energy < energyThresh;
        cfs(zeroEnergy) = {zeros(1,1,'like',energyThresh)};
        Energy(zeroEnergy) = ones(1,1,'like',energyThresh);
        Energy = num2cell(Energy);
        Pij = cellfun(@(x,y)abs(x).^2./y,cfs,Energy,'UniformOutput',false);
        N = cellfun(@(x)size(x,1),cfs);
    else        
        Energy = sum(abs(cfs).*abs(cfs),2);
        zeroEnergy = Energy < energyThresh;
        cfs(zeroEnergy,:) = zeros(1,1,'like',energyThresh);
        Energy(zeroEnergy) = ones(1,1,'like',energyThresh);
        Pij = (abs(cfs).*abs(cfs))./Energy;
        N = size(Pij,2);
    end    
else
    if cellT 
        N = length(cfs);
        globalEnergy = sum(cellfun(@(x)norm(x,2)^2,cfs));
        if globalEnergy < energyThresh
            Pij = zeros(N,1,'like',energyThresh);
        else
          Pij = cellfun(@(x)sum(abs(x).*abs(x))./globalEnergy,cfs);
        end
        Pij = Pij(:);
    else
        TimeEnergy = sum(abs(cfs).*abs(cfs),2);
        globalEnergy = sum(TimeEnergy,1);
        if globalEnergy < energyThresh
            cfs = zeros(size(cfs),'like',energyThresh);
            globalEnergy = ones(1,1,'like',energyThresh);
        end
        Pij = sum(abs(cfs).*abs(cfs)./globalEnergy,2);
        if isrow(Pij)
            Pij = Pij(:);
        end
        N = size(Pij,1);
    end       
end

%-------------------------------------------------------------------------
function [tfTransform,dataType] = isTransformData(x)
tfTransform = true;
if iscell(x)
    % Assume data type is the same for all elements
    dataType = underlyingType(x{1});
elseif ismatrix(x) && isnumeric(x)
    dataType = underlyingType(x);
end
if ~iscell(x) && (isrow(x) || iscolumn(x))
    tfTransform = false;    
end
%-------------------------------------------------------------------------
function mustBeValidInput(x)
validFormat = (iscell(x) || ismatrix(x)) && ~isstruct(x);
if ~validFormat
    error(message('Wavelet:entropy:MustBeCellOrNumeric'));
end
if iscell(x)
    allNotFinite = ~all(cellfun(@(x)allfinite(x),x));
    allNotNonEmpty = ~all(cellfun(@(x)~isempty(x),x));
    allNotReal = ~all(cellfun(@(x)~any(imag(x(:))),x));
    dataType = string(cellfun(@(x)underlyingType(x),x,'UniformOutput',false));
else
    allNotFinite = ~allfinite(x);
    allNotNonEmpty = isempty(x);
    allNotReal = any(imag(x(:)));
    dataType = underlyingType(x);
end

if allNotFinite || allNotNonEmpty || allNotReal
        error(message('Wavelet:entropy:MustbeRealFiniteNonEmpty'));
end

if ~ (all(strcmpi(dataType,'double')) || all(strcmpi(dataType,'single')))
    error(message('Wavelet:entropy:SingleorDouble'));
end

if ~iscell(x) && (isrow(x) || iscolumn(x)) && numel(x) < 4
    error(message('Wavelet:entropy:FourSamples'));
end

%--------------------------------------------------------------------------
function wt = getTransform(xcol,pTransform,pWavelet,pLevel)
switch pTransform
    case 'modwpt'
        wt = modwpt(xcol,pWavelet,pLevel,TimeAlign=true);
    case 'modwt'
        wt = modwt(xcol,pWavelet,pLevel,TimeAlign=true);
    case 'dwpt'
        wt = dwpt(xcol,pWavelet,level = pLevel,boundary='periodic');
    case 'dwt'
        currMode = dwtmode('status','nodisplay');
        dwtmode('per','nodisplay');
        [C,L] = wavedec(xcol,pLevel,pWavelet);
        wt = detcoef(C,L,'cell');
        wt{end+1} = appcoef(C,L,pWavelet);    
        dwtmode(currMode,'nodisplay');
end
%--------------------------------------------------------------------------
function pLevel = setLevel(N,level,transform)
if isempty(level) && ...
        (strcmp(transform,'modwpt') || strcmp(transform,'dwpt'))
    pLevel = min(4,floor(log2(N))-1);
elseif isempty(level) && ~strcmp(transform,'modwpt')
    pLevel = floor(log2(N))-1;
else
    pLevel = level;
end
   


    




