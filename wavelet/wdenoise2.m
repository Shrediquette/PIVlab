function varargout = wdenoise2(im,varargin)
% WDENOISE2 Wavelet image denoising
%   IMDEN = WDENOISE2(IM) denoises the image IM using an empirical Bayesian
%   method. The 'bior4.4' wavelet is used with a posterior median threshold
%   rule. Denoising is down to the minimum of floor(log2(min([M N]))) and
%   wmaxlev([M N],'bior4.4') where M and N are the row and column sizes of
%   the image. IM is a real-valued 2-D or 3-D matrix. If IM is 3-D, IM is
%   assumed to be a color image in the RGB color space and the third
%   dimension of IM must be 3. For RGB images, WDENOISE2 projects the
%   image onto its PCA color space before denoising by default. To
%   denoise an RGB image in the original color space, use the 'ColorSpace'
%   name-value pair. IMDEN is the denoised version of the grayscale or
%   RGB image IM.
%
%   IMDEN = WDENOISE2(IM,LEVEL) denoises the image IM down to resolution
%   level, LEVEL. LEVEL is a positive integer less than or equal to
%   floor(log2(min([M N]))) where M and N are the row and column sizes of
%   the image. If unspecified, LEVEL defaults to the minimum of
%   floor(log2(min([M N]))) and wmaxlev([M N],'bior4.4') or
%   floor(log2(min([M N]))) and wmaxlev([M N],WNAME) if you specify a
%   wavelet other than the default 'bior4.4'.
%
%   IMDEN = WDENOISE2(...,'Wavelet',WNAME) uses the orthogonal or
%   biorthogonal wavelet WNAME for denoising. Orthogonal and biorthogonal
%   wavelets are designated as type 1 and type 2 wavelets respectively in
%   the wavelet manager. Valid built-in orthogonal wavelet families begin
%   with 'haar', 'dbN', 'fkN', 'coifN', or 'symN' where N is the number of
%   vanishing moments for all families except 'fk'. For 'fk', N is the
%   number of filter coefficients. Valid biorthogonal wavelet families
%   begin with 'biorNr.Nd' or 'rbioNd.Nr', where Nr and Nd are the number
%   of vanishing moments in the reconstruction (synthesis) and
%   decomposition (analysis) wavelet respectively. Determine valid values
%   for the vanishing moments by using waveinfo with the wavelet family
%   short name. For example, enter waveinfo('db') or waveinfo('bior'). Use
%   wavemngr('type',WNAME) to determine if a wavelet is orthogonal (returns
%   1) or biorthogonal (returns 2). If unspecified, the default wavelet for
%   image denoising is 'bior4.4'.
%
%   IMDEN = WDENOISE2(...,'DenoisingMethod',DMETHOD) uses the denoising
%   method DMETHOD to determine the denoising thresholds for the image IM.
%   DMETHOD can be one of 'Bayes','FDR','Minimax','SURE', or
%   'UniversalThreshold'. If unspecified, DMETHOD defaults to the empirical
%   Bayesian method, 'Bayes'.
%
%       * For 'FDR', there is an optional argument for the Q-value, which
%       is the desired proportion of false positives. Q is a real-valued
%       scalar between 0 and 1/2, (0<Q<=1/2). To specify FDR with a
%       Q-value, use a cell array where the second element is the Q-value.
%       For example, 'DenoisingMethod',{'FDR',0.01}. If unspecified, Q
%       defaults to 0.05.
%
%   IMDEN = WDENOISE2(...,'ThresholdRule',THRESHRULE) uses the threshold
%   rule THRESHRULE to shrink the wavelet coefficients. THRESHRULE is valid
%   for all denoising methods but the valid options and defaults depend on
%   the denoising method.
%
%   For 'SURE','Minimax', and 'UniversalThreshold', valid options are
%   'Soft' or 'Hard'. The default is 'Soft'.
%
%   For 'Bayes', valid options are 'Median', 'Mean', 'Soft', or
%   'Hard'. The default is 'Median'.
%
%   For 'FDR', the only supported option is 'Hard'. You do not need to
%   specify THRESHRULE for 'FDR'.
%
%   IMDEN = WDENOISE2(...,'NoiseEstimate',NOISEESTIMATE) estimates the
%   variance of the noise in the image using NOISEESTIMATE. Valid options
%   are 'LevelIndependent' and 'LevelDependent'. If unspecified, the
%   default is 'LevelIndependent'. 'LevelIndependent' estimates the
%   variance of the noise based on the finest-scale (highest-resolution)
%   wavelet coefficients. Which wavelet coefficients are used in the noise
%   estimate depends on the value of the 'NoiseDirection' parameter.
%   'LevelDependent' estimates the variance of the noise based the wavelet
%   coefficients at each resolution level.
%
%   IMDEN = WDENOISE2(...,'NoiseDirection',NOISEDIR) estimates the variance
%   of the noise based on the wavelet subbands specified in NOISEDIR.
%   NOISEDIR is a string vector or scalar string. Valid entries for
%   NOISEDIR are "h", "v",or "d" for the horizontal, vertical, and diagonal
%   details. If unspecified, NOISEDIR defaults to ["h" "v" "d"].
%
%   IMDEN = WDENOISE2(...,'CycleSpinning',NUMSHIFTS) uses cycle spinning to
%   denoise the image. In cycle spinning, circular shifts of the image
%   along the row and column dimensions are denoised, shifted back, and
%   averaged together to provide the final result. NUMSHIFTS is a
%   nonnegative integer specifying the number of shifts in both the row and
%   column dimension. For example, specifying NUMSHIFTS equal to 1 results
%   in 4 copies of IM being denoised: the original image (unshifted), a
%   single-element shift along the row dimension, a single-element shift
%   along the column dimension, and a version where IM is circularly
%   shifted one element along both the row and column dimensions. The 4
%   denoised copies of IM are denoised, reconstructed, shifted back to
%   their original positions, and averaged together. NUMSHIFTS represents
%   the maximum shift along both the row and column dimensions. For RGB
%   images, there are no shifts applied along the color space dimension.
%   Generally, SNR improvements are observed with cycle spinning up to 3-4
%   shifts and asymptote after that. Because of this asymptotic effect on
%   SNR and the fact that you are denoising (NUMSHIFTS+1)^2 versions of the
%   image, it is recommended to start with NUMSHIFTS equal to 0 and
%   gradually increase it to determine if there is any improvement in SNR
%   to justify the computational expense. If unspecified, NUMSHIFTS
%   defaults to 0.
%
%   IMDEN = WDENOISE2(...,'ColorSpace',CSPACE) denoises an RGB image in the
%   color space specified by CSPACE. The 'ColorSpace' name-value pair is
%   only valid for RGB images. Valid options for CSPACE are 'Original' and
%   'PCA'. If CSPACE equals 'Original', denoising is done in the same color
%   space as the input image. If CSPACE is 'PCA', the image is first
%   projected onto its PCA color space, denoised in the PCA color space,
%   and returned to the original color space after denoising. If
%   unspecified, CSPACE defaults to 'PCA' for an RGB image.
%
%   [IMDEN,DENOISEDCFS] = WDENOISE2(...) returns the scaling and denoised
%   wavelet coefficients in DENOISEDCFS. DENOISEDCFS is a
%   (NUMSHIFTS+1)^2-by-N matrix where N is the number of wavelet
%   coefficients in the decomposition of IM and NUMSHIFTS is the value of
%   the 'CycleSpinning' name-value pair. Each row of DENOISEDCFS
%   contains the denoised wavelet coefficients for one of (NUMSHIFTS+1)^2
%   shifted versions of IM. For RGB images, DENOISEDCFS are the denoised
%   coefficients in the specified color space.
%
%   [IMDEN,DENOISEDCFS,ORIGCFS] = WDENOISE2(...) returns the scaling and
%   wavelet coefficients of the input image in ORIGCFS. ORIGCFS is a
%   (NUMSHIFTS+1)^2-by-N matrix where N is the number of wavelet
%   coefficients in the decomposition of IM and NUMSHIFTS is the value of
%   the 'CycleSpinning' name-value pair. Each row of ORIGCFS contains the
%   wavelet coefficients for one of (NUMSHIFTS+1)^2 shifted versions of IM.
%   For RGB images, ORIGCFS are the original coefficients in the
%   specified color space.
%
%   [...,S] = WDENOISE2(...) returns the sizes of the approximation
%   coefficients at the coarsest scale along with the sizes of the wavelet
%   coefficients at all scales. S is a matrix with the same structure as
%   the S output of WAVEDEC2.
%
%   [...,SHIFTS] = WDENOISE2(...) returns the shifts along the row and
%   column dimensions for cycle spinning. SHIFTS is 2-by-(NUMSHIFTS+1)^2
%   matrix where each column of SHIFTS contains the shifts along the row
%   and column dimension used in cycle spinning.
%
%   WDENOISE2(....) with no output arguments plots the original image along
%   with the denoised image in the current figure.
%
%   % Example 1:
%   %   Denoise a gray scale image down to level 2 using Bayesian
%   %   denoising. Plot the results in the current figure.
%
%   load flower
%   wdenoise2(flower.Noisy,2)
%
%   % Example 2:
%   %   Denoise a color image down to level 2 using Bayesian
%   %   denoising and cycle spinning with (1+1)^2 shifts. Compute the
%   %   resulting SNR.
%
%   load colorflower;
%   imden = wdenoise2(colorflower.Noisy,2,'CycleSpinning',1);
%   SNR = ...
%       20*log10(norm(colorflower.Orig(:))/norm(colorflower.Orig(:)-imden(:)));
%
%
%   % Example 3: Denoise a gray scale image down to level 2 using false
%   %   discovery rate with a Q-value of 0.01. Denoise only based on the
%   %   diagonal (HH) wavelet coefficients.
%   load flower
%   wdenoise2(flower.Noisy,2,'DenoisingMethod', {'FDR',0.01},...
%       'NoiseDirection','d');
%
%   See also WAVEDEC2, WDENOISE.

%   Copyright 2018-2020 The MathWorks, Inc.

%#codegen

coder.extrinsic('imagesc')

% Check number of input arguments
narginchk(1,16);

% Check number of output arguments
if isempty(coder.target)
    nargoutchk(0,5);
else
    nargoutchk(1,5);
end

% validate image size
[im,isRGB] = checkInput(im);
SzIM = size(im);

% Check if GPU is enabled. As "level" is converted to compile-time constant
% if not passed by the user, and will be taken as it is if passed by the
% user as one of the input arguments. "level" doesn't remain compile-time
% constant after passing it to "parseinputs" function even if user passed it as
% compile-time constant. This condition checks if user passed "level" and 
% will not accept "level" from "parseinputs".
if coder.gpu.internal.isGpuEnabled
    if ~isempty(varargin) && isscalar(varargin{1})
        [ColorSpace,~,qvalue,~,DenoisingMethod,ThresholdRule,...
            NoiseEstimate,noisedir,Ns,Lo_D,Hi_D,Lo_R,Hi_R] = parseinputs(SzIM,varargin{:});
        level = varargin{1};
    else
        [ColorSpace,level,qvalue,~,DenoisingMethod,ThresholdRule,...
             NoiseEstimate,noisedir,Ns,Lo_D,Hi_D,Lo_R,Hi_R] = parseinputs(SzIM,varargin{:});
    end
else
    % Parse inputs
    [ColorSpace,level,qvalue,~,DenoisingMethod,ThresholdRule,...
        NoiseEstimate,noisedir,Ns,Lo_D,Hi_D,Lo_R,Hi_R] = parseinputs(SzIM,varargin{:});
end

imRGB = im;

if isRGB && ColorSpace
    [temp_im_CMPLX,V,mu] = wavelet.internal.color2pca(im);
    temp_im = real(temp_im_CMPLX);
else
    temp_im = im;
    V = zeros(0,0);
    mu = zeros(0,0);
end

% Select denoising method
if strcmpi(DenoisingMethod,'UniversalThreshold') || ...
        strcmpi(DenoisingMethod,'SURE') || ...
        strcmpi(DenoisingMethod,'Minimax')
    % For Universal threshold, Minimax estimation and Stein's Unbiased Risk
    % Estimation(SURE)
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % If "level" is not passed as one of the input arguments.
        if (isempty(varargin)) || (~isempty(varargin) && ~isscalar(varargin{1}))
            % If the input image is fixed size input.
            if coder.internal.isConst(size(temp_im))
                % Converting "level" to compile-time constant for optimized
                % GPU Code generation.
                coder.internal.const(level);
            else
                % Displaying a warning if input image is a varDim. 
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
            end
        % If "level" is passed as one of the input arguments.
        else
            % Displaying a warning if "level" passed as one of the input arguments is not
            % compile-time constant. 
            if ~coder.internal.isConst(level)
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseNonConstantLevelValue');
                % Displaying a warning if input image is a varDim. 
                if ~coder.internal.isConst(size(temp_im))
                    coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
                end
            end
        end

        [imden,Cden,C,S] = wavelet.internal.gpu.dohonoJohnstone2(temp_im,level,...
            Lo_D,Hi_D,Lo_R,Hi_R,DenoisingMethod,ThresholdRule,...
            NoiseEstimate,noisedir,Ns);
     else
        [imden,Cden,C,S] = wavelet.internal.DonohoJohnstone2(temp_im,level,...
            Lo_D,Hi_D,Lo_R,Hi_R,DenoisingMethod,ThresholdRule,...
            NoiseEstimate,noisedir,Ns);
     end
elseif strcmpi(DenoisingMethod,'bayes')
    % For Empirical Bayes
    % Check if GPU is enabled.
    if coder.gpu.internal.isGpuEnabled
        % If "level" is not passed as one of the input arguments.
        if (isempty(varargin)) || (~isempty(varargin) && ~isscalar(varargin{1}))
            % If the input image is fixed size input.
            if coder.internal.isConst(size(temp_im))
                % Converting "level" to compile-time constant for optimized
                % GPU Code generation.
                coder.internal.const(level);
            else
                % Displaying a warning if input image is a varDim. 
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
            end
        % If "level" is passed as one of the input arguments.
        else
            % Displaying a warning if "level" passed as one of the input arguments is not
            % compile-time constant. 
            if ~coder.internal.isConst(level)
                coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseNonConstantLevelValue');
                % Displaying a warning if input image is a varDim. 
                if ~coder.internal.isConst(size(temp_im))
                    coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseVarDimInputs');
                end
            end
        end
        [imden,Cden,C,S] = wavelet.internal.gpu.ebayesdenoise2(temp_im,Lo_D,Hi_D,Lo_R,Hi_R,level,...
            NoiseEstimate,ThresholdRule,noisedir,Ns);
    else
        [imden,Cden,C,S] = wavelet.internal.ebayesdenoise2(temp_im,Lo_D,Hi_D,Lo_R,Hi_R,level,...
            NoiseEstimate,ThresholdRule,noisedir,Ns);
    end
elseif strcmpi(DenoisingMethod,'FDR')
    % Displaying a warning if GPU is enabled for FDR denoising method.
    if coder.gpu.internal.isGpuEnabled
        % Check if DenoisingMethod passed is compile-time constant.
        if coder.internal.isConst(DenoisingMethod)
            % Displaying a compile-time warning if DenoisingMethod is
            % passed as compile-time constant.
            coder.internal.compileWarning('Wavelet:gpucodegen:wdenoiseUnsupportedMethods');
        end
    end
    % For  False Discovery Rate(FDR)
    [imden,Cden,C,S] = wavelet.internal.FDRDenoise2(temp_im,Lo_D,Hi_D,Lo_R,Hi_R,level,qvalue,...
        NoiseEstimate,noisedir,Ns);
else
    imden = zeros(0,0);
    Cden = zeros(0,0);
    C = zeros(0,0);
    S = zeros(0,0);
end

if isRGB && ColorSpace
    temp_imden = wavelet.internal.pca2color(imden,V,mu);
else
    temp_imden = imden;
end
imden = temp_imden;

if nargout > 0 && nargout < 5
    varargout{1} = imden;
    varargout{2} = Cden;
    varargout{3} = C;
    varargout{4} = S;
elseif nargout == 5
    shifts = wavelet.internal.getCycleSpinShifts2(Ns);
    shifts = shifts(1:2,:);
    varargout{1} = imden;
    varargout{2} = Cden;
    varargout{3} = C;
    varargout{4} = S;
    varargout{5} = shifts;
elseif ~isRGB && nargout == 0
    subplot(1,2,1,'replace')
    ax = gca;
    imagesc(ax,temp_im); axis off;
    title(getString(message('Wavelet:FunctionOutput:origImage')));
    ax.Tag = 'Original';
    subplot(1,2,2,'replace')
    ax = gca;
    imagesc(ax,imden); axis off;
    title(getString(message('Wavelet:FunctionOutput:denoisedImage')));
    ax.Tag = 'Denoised';
    colormap gray;
elseif isRGB && nargout == 0
    imden = bsxfun(@rdivide,imden,max(max(abs(imden),[],1),[],2));
    imRGB = double(imRGB);
    imRGB = bsxfun(@rdivide,double(imRGB),max(max(imRGB,[],1),[],2));
    subplot(1,2,1,'replace')
    ax = gca;
    imagesc(ax,imRGB); axis off;
    title(getString(message('Wavelet:FunctionOutput:origImage')));
    ax.Tag = 'Original';
    subplot(1,2,2,'replace')
    ax = gca;
    imagesc(ax,imden); axis off;
    title(getString(message('Wavelet:FunctionOutput:denoisedImage')));
    ax.Tag = 'Denoised';
end
end
%--------------------------------------------------------------------------

function [im,isRGB] = checkInput(im)
isRGB = false;
validateattributes(im,{'numeric'},{'real','finite','3d','nonempty'},...
    'WDENOISE2','IM');
SZ = size(im);
if (isrow(im) || iscolumn(im)) || ...
        (ndims(im) > 3 || (ndims(im) == 3 && SZ(3) ~= 3)) || ...
        (ndims(im) == 3 && (SZ(1) == 1 || SZ(2) == 1))
    coder.internal.error('Wavelet:FunctionInput:InvalidImageWDENOISE2');
end

if numel(SZ) == 3
    isRGB = true;
end
end
%--------------------------------------------------------------------------

function [ColorSpace,Level,Q,Wavelet,DenoisingMethod,ThresholdRule,...
    noiseEstimate,noiseDirection,CycleSpinning,LO_D,HI_D,LO_R,HI_R,wavtype] = parseinputs(SzIM,varargin)

coder.extrinsic('wfilters','wavemngr');
% Default parameter values (logical PCA = true else false)
defaultColorSpace = (1*numel(SzIM) == 3);
isRGB = defaultColorSpace == 1;
% Filter length of bior4.4 is max(2Nr,2Nd)+2 equals 10
defaultLevel = wavelet.internal.dwtmaxlev(SzIM(1:2),10);
maxLevel = floor(log2(min(SzIM(1:2))));
defaultLevel = (maxLevel*(defaultLevel<1)) +  (defaultLevel*(defaultLevel>=1));
defaultQ = [];
defaultWavelet = 'bior4.4';
defaultDenoisingMethod = 'Bayes';
defaultThresholdRule = 'Median';
defaultNoiseEstimate = 'LevelIndependent';
defaultNoiseDirection = ['h';'v';'d'];
defaultCycleSpinning = 0;

if isempty(varargin)
    Wavelet = defaultWavelet;
    DenoisingMethod = defaultDenoisingMethod;
    ThresholdRule = defaultThresholdRule;
    noiseEstimate = defaultNoiseEstimate;
    noiseDirection = defaultNoiseDirection;
    CycleSpinning = defaultCycleSpinning;
    ColorSpace = defaultColorSpace;
    [LO_D,HI_D,LO_R,HI_R] = coder.const(@wfilters, "bior4.4");
    Level = defaultLevel;
    Q = defaultQ;
else
    % Temporary variable for parsing
    ColorSpace = false;
    Q = 0;
    temp_parseinputs = cell(1,nargin-1);
    for i = 1:nargin-1
        temp_parseinputs{i} = varargin{i};
    end
    
    idx = 1;
    % Check for user-specified level in varargin if varargin{1} is not empty
    tlev = isscalar(varargin{1}) && ~isStringScalar(varargin{1});
    if tlev
        Level = temp_parseinputs{1};
        validateattributes(Level,{'numeric'},...
            {'finite','positive','<=',maxLevel},'WDENOISE2','Level');
        idx = 2;
    else
        Level = defaultLevel;
    end
    
    %%% Parsing input arguments.
    if isempty(coder.target)
        p = inputParser;
        p.addParameter("CycleSpinning",0);
        p.addParameter("Wavelet",defaultWavelet);
        p.addParameter("DenoisingMethod",defaultDenoisingMethod);
        p.addParameter("ThresholdRule",char([]));
        p.addParameter("NoiseEstimate",defaultNoiseEstimate);
        p.addParameter("NoiseDirection",defaultNoiseDirection);
        p.addParameter("ColorSpace",char([]));
        p.parse(temp_parseinputs{idx:end});
        
        Wavelet = p.Results.Wavelet;
        temp_DenoisingMethod = p.Results.DenoisingMethod;
        temp_ColorSpace = strtrim(p.Results.ColorSpace);
        ThresholdRule = strtrim(p.Results.ThresholdRule);
        NoiseDirection = unique(lower(deblank(p.Results.NoiseDirection)));
        NoiseEstimate = p.Results.NoiseEstimate;
        CycleSpinning = p.Results.CycleSpinning;
    else
        parms = struct('CycleSpinning',uint32(0),'Wavelet',uint32(0), ...
            'DenoisingMethod',uint32(0),'ThresholdRule',uint32(0),...
            'NoiseEstimate',uint32(0),'NoiseDirection',uint32(0),...
            'ColorSpace',uint32(0));
        popts = struct('CaseSensitivity',false, ...
        'PartialMatching',true);
    
        plength = length(temp_parseinputs) - (idx == 2);
        temp_parseinputs_cg = cell(1,plength);
        for i = 1:plength
            temp_parseinputs_cg{i} = temp_parseinputs{idx};
            idx = idx + 1;
        end
        
        parmsstruct = eml_parse_parameter_inputs(parms,popts,...
            temp_parseinputs_cg{:});
        coder.varsize('ThresholdRule');
        Wavelet = eml_get_parameter_value(parmsstruct.Wavelet,...
            defaultWavelet,temp_parseinputs_cg{:});
        temp_DenoisingMethod = eml_get_parameter_value(parmsstruct.DenoisingMethod,...
            defaultDenoisingMethod,temp_parseinputs_cg{:});
        temp_ColorSpace = eml_get_parameter_value(parmsstruct.ColorSpace,...
            char([]),temp_parseinputs_cg{:});
        ThresholdRule = eml_get_parameter_value(parmsstruct.ThresholdRule,...
            char([]),temp_parseinputs_cg{:});
        NoiseEstimate = eml_get_parameter_value(parmsstruct.NoiseEstimate,...
            defaultNoiseEstimate,temp_parseinputs_cg{:});
        NoiseDirection = eml_get_parameter_value(parmsstruct.NoiseDirection,...
            defaultNoiseDirection,temp_parseinputs_cg{:});
        CycleSpinning = eml_get_parameter_value(parmsstruct.CycleSpinning,...
            0,temp_parseinputs_cg{:});
    end
    
    % Check for Wave type
    wavtype = coder.const(@wavemngr,'type',Wavelet);
    coder.internal.errorIf(~(wavtype == 1 || wavtype == 2),...
        'Wavelet:FunctionInput:OrthorBiorthWavelet');
    
    % Check for Level
    [LO_D,HI_D,LO_R,HI_R] = coder.const(@wfilters, Wavelet);
    % The default level may change depending on the wavelet
    % Check to see that level has not been set.
    if ~strcmpi(Wavelet,"bior4.4") && ~tlev
        defaultLevel = wavelet.internal.dwtmaxlev(SzIM(1:2),length(LO_D));
        if defaultLevel < 1
            Level = maxLevel;
        else
            Level = defaultLevel;
        end        
    end
    
    % Check for DenoisingMethod
    % Only for FDR is a cell array input support
    if iscell(temp_DenoisingMethod)
        Q = temp_DenoisingMethod{2};
        validateattributes(Q,{'numeric'},{'scalar','nonempty','>',0,'<=',1/2},...
            'WDENOISE2','Q');
        DenoisingMethod = validatestring(temp_DenoisingMethod{1},{'FDR'},...
            'WDENOISE2','DENOISINGMETHOD');
    else
        DenoisingMethod = validatestring(temp_DenoisingMethod,...
            {'UniversalThreshold', 'Minimax', 'SURE', 'Bayes','FDR'},...
            'WDENOISE2','DENOISINGMETHOD');
    end
    
    % Check for CycleSpinning
    validateattributes(CycleSpinning,{'numeric'},...
        {'scalar','nonnegative'},'WDENOISE2','CYCLESPINNING');
    
    % Check for ThresholdRule
    if isempty(ThresholdRule) && ...
            (strcmpi(DenoisingMethod,"UniversalThreshold") || ...
            strcmpi(DenoisingMethod,"SURE") || ...
            strcmpi(DenoisingMethod,"Minimax"))
        ThresholdRule = 'soft';
    elseif isempty(ThresholdRule) && ...
            strcmpi(DenoisingMethod,"bayes")
        ThresholdRule = 'median';
    elseif ~isempty(ThresholdRule) && ~any(strcmpi(DenoisingMethod,{'Bayes','FDR'}))
        ThresholdRule = validatestring(ThresholdRule,{'soft','hard'},...
            'WDENOISE2', 'THRESHRULE');
    elseif ~isempty(ThresholdRule) && strcmpi(DenoisingMethod,'FDR')
        ThresholdRule = validatestring(ThresholdRule, {'hard'}, ...
            'WDENOISE2', 'THRESHRULE');
    elseif ~isempty(ThresholdRule) && strcmpi(DenoisingMethod,'Bayes')
        ThresholdRule = validatestring(ThresholdRule,{'median','mean',...
            'soft','hard'}, 'WDENOISE2', 'THRESHRULE');
    end
    
    % Check for Q
    if strcmpi(DenoisingMethod,'fdr') && isempty(Q)
        Q = 0.05;
    end

    % Check for Colorspace
    if isempty(temp_ColorSpace) && isRGB
        ColorSpace = true;
    elseif ~isRGB && ~isempty(temp_ColorSpace)
        coder.internal.error('Wavelet:FunctionInput:ColorSpace');
    elseif isRGB && ~isempty(temp_ColorSpace)
        validatestring(temp_ColorSpace,...
            {'Original','PCA'},'WDENOISE2','ColorSpace');
        ColorSpace = strcmp(temp_ColorSpace,'PCA');
    end
    
    % Check for Nise Direction
    noiseDirection = validateNoiseDir(NoiseDirection);
    
    % Check for Noise Estimate.
    noiseEstimate = validatestring(NoiseEstimate,...
        {'LevelIndependent','LevelDependent'},'WDENOISE2','NOISEESTIMATE');
    
end
end

%-------------------------------------------------------------------------
function noisedir = validateNoiseDir(noisedir)
if isempty(noisedir)
    coder.internal.error('Wavelet:FunctionInput:ValidNoiseDir');
else
    for ndir = 1:numel(noisedir)
        if ~(strcmpi(noisedir(ndir),"h") || strcmpi(noisedir(ndir),"v") || ...
                strcmpi(noisedir(ndir),"d"))
            coder.internal.error('Wavelet:FunctionInput:ValidNoiseDir');
        end
    end
end
end
