% Wavelet image scattering 
%   SF = waveletScattering2 creates a framework for a wavelet image
%   scattering decomposition with two complex-valued 2-D Morlet
%   filter banks. Both filter banks have quality factors of 1 wavelet per
%   octave. There are six rotations linearly spaced between 0 and pi
%   radians for each wavelet filter. By default, waveletScattering2 assumes
%   an image input size of 128-by-128. The scale invariance is 64. 
%
%   SF = waveletScattering2(Name,Value) creates a framework for wavelet
%   image scattering, SF, with the specified property Name set to the
%   specified Value. You can specify additional name-value pair arguments
%   in any order as (Name1,Value1,...,NameN,ValueN).
%
%   waveletScattering2 methods:
%
%   scatteringTransform             - Wavelet 2-D scattering transform
%   featureMatrix                   - Scattering feature matrix
%   log                             - Natural logarithm of scattering
%                                     transform
%   filterbank                      - Wavelet and scaling filters
%   littlewoodPaleySum              - Littlewood-Paley sum
%   coefficientSize                 - Size of the scattering coefficients 
%   numorders                       - Number of scattering orders
%   numfilterbanks                  - Number of scattering filter banks
%   paths                           - Scattering paths
%
%
%   waveletScattering2 properties:
%
%   ImageSize           - Image size
%   InvarianceScale     - Invariance scale
%   NumRotations        - Number of rotations 
%   QualityFactors      - Scattering 2-D filter bank Q factors
%   Precision           - Precision of scattering decomposition
%   OversamplingFactor  - Oversampling factor
%   OptimizePath        - Optimize scattering paths
%
%   See also CWTFT2, DDDTREE2, WAVEDEC2

%   Copyright 2018-2020 The MathWorks, Inc.

classdef waveletScattering2 < matlab.mixin.CustomDisplay 
    
    properties (SetAccess = private)
        % ImageSize Size of the input image as a two-element vector
        %   [numrows numcolumns]. If your input is a color image, you do
        %   not have to specify the third dimension. waveletScattering2
        %   only supports color images where the third dimension is equal
        %   to 3. If unspecified, ImageSize defaults to [128 128].
        %   ImageSize is a read-only property.
        ImageSize
        % InvarianceScale Invariance scale specified as a scalar integer.
        %   InvarianceScale specifies the spatial support in the row and 
        %   column dimension of the scaling filter. InvarianceScale cannot
        %   exceed the minimum of the row and column dimension of the
        %   image. By default, the InvarianceScale is one-half the minimum
        %   of the row and column size of the image rounded to the nearest
        %   integer. InvarianceScale is a read-only property.         
        InvarianceScale
        % NumRotations Number of rotations per wavelet. For each wavelet in
        %   each filter bank, there are NumRotations linearly spaced angles
        %   between 0 and pi radians. Specify one nonnegative integer less
        %   than or equal to 12 for each filter bank in the scattering
        %   framework. If unspecified, NumRotations defaults to [6 6].
        %   NumRotations is a read-only property.
        NumRotations
        % QualityFactors Quality factors for scattering filter banks.
        %   The quality factor is the number of wavelet filters per octave.
        %   The number of wavelet filter banks in the scattering framework
        %   is equal to the number of elements in QualityFactors. Valid
        %   quality factors are positive integers less than or equal to 4.
        %   If QualityFactors is specified as a vector, the elements of
        %   QualityFactors must be nonincreasing. By default,
        %   QualityFactors is the vector, [1 1]. QualityFactors is a
        %   read-only property.
        QualityFactors
        % Precision Precision of scattering coefficients and filters.
        %   Precision is one of 'single' or 'double'. The default value is
        %   'single'. Precision is a read-only property.
        Precision        
    end
    
    properties (Access = public)
        % OversamplingFactor The oversampling factor determines how much
        %   the image scattering coefficients are oversampled with respect
        %   to the critically downsampled values. The oversampling factor
        %   is on a log2 scale. For example, an oversampling factor of 1
        %   indicates that the scattering transform returns 2^1-by-2^1-by-P
        %   as many coefficients for each scattering path with respect to
        %   the critically sampled number. You can use the coefficientSize
        %   method to determine the number of coefficients obtained for a
        %   scattering framework. If you specify an oversampling factor
        %   which would result in an output image size larger than the
        %   input, the output size is truncated to the size of the input
        %   image. You can also specify the OversamplingFactor as Inf,
        %   which provides a fully undecimated scattering transform where
        %   each scattering path contains coefficient matrices equal in
        %   size to the input image. By default, OversamplingFactor is 0,
        %   indicating that the scattering transform is critically
        %   downsampled. Due to the computational complexity of the
        %   scattering transform, it is recommended that you leave the
        %   OversamplingFactor set to its default value of 0, or only
        %   increase it to 1 or 2, indicating a 2^1-by-2^1-by-P or
        %   2^2-by-2^2-by-P increase in the number of scattering
        %   coefficients per path.
        OversamplingFactor 
        % OptimizePath A logical which determines whether the scattering
        %   transform reduces the number of scattering paths to compute
        %   based on a bandwidth consideration. OptimizePath defaults to
        %   true. When OptimizePath is set to true, a scattering path is
        %   computed only if the bandwidth of the parent node overlaps
        %   significantly with the bandwidth of the child node. Significant
        %   in this context is defined as follows: for a quality factor of
        %   1, 1/2 the 3dB bandwidth of the child node is subtracted from
        %   the child node's wavelet center frequency. If that value is
        %   less than the 3dB bandwidth of the parent, the scattering path
        %   is computed. For quality factors greater than 1, significant
        %   overlap is defined to be an overlap between the center
        %   frequency of the child minus the child's 3dB bandwidth. If that
        %   overlaps with the 3dB bandwidth of the parent, the scattering
        %   path is computed. You can use the PATHS method to determine
        %   which and how many scattering paths are computed with
        %   OptimizePath set to true or false. OptimizePath generally
        %   results in computational savings in the second and subsequent
        %   filter banks only when the quality factors are equal in each
        %   filter bank.
        OptimizePath
    end
    
    properties(SetAccess = private,Hidden)
        CriticalResolution
        filterparams
    end
    
    properties(Access = private,Hidden)
        XSize
        YSize
        XSizePad
        YSizePad
        Theta
        J
        SigmaPhi
        PhiFilter
        PsiFilters
        OmegaPsi
        OBW
        nFilterBanks
        EqualFB
        
    end
    
    methods
        % Constructor
        function self = waveletScattering2(varargin)
            if nargin == 0
                % Default for 2-D scattering is single precision
                self.Precision = 'single';
                self.ImageSize = [128 128];
                % XSize is the column size
                self.XSize = self.ImageSize(2);
                % YSize is the row size
                self.YSize = self.ImageSize(1);
                self.InvarianceScale = 64;
                self.QualityFactors = [1 1];
                self.nFilterBanks = 2;
                self.NumRotations = [6 6];
                % Determine rotations in radians
                self = rotationAngles(self);
                self.OBW = 0.995;
                % Oversampled by powers of two. Inf means no
                % oversampling, 0 indicates critically sampled
                self.OversamplingFactor = 0;
                self.EqualFB = true;
                self.OptimizePath = true;
                
                
            elseif nargin > 0
                self = setProperties(self,varargin{:});
                
                
            end
            self.filterparams = gaborparameters2(self);         
                        
            for nfb = 1:numel(self.filterparams)
                psilog2ds = round(log2((2*pi)./self.filterparams{nfb}.psiftsupport));
                philog2ds = round(log2((2*pi)./self.filterparams{nfb}.phiftsupport));
                self.filterparams{nfb} = addvars(self.filterparams{nfb},...
                    psilog2ds,'NewVariableNames','PsiLog2DS','After','phi3dBbw');
                self.filterparams{nfb} = addvars(self.filterparams{nfb},...
                    philog2ds,'NewVariableNames','PhiLog2DS','After','PsiLog2DS');
            end
            self.CriticalResolution = criticalResolution(self);
            self.SigmaPhi = self.filterparams{1}.spatialsigmaphi;
            % Determine padded image size for finest-scale scaling and
            % wavelet filters
            [self.XSizePad,self.YSizePad] = ...
                waveletScattering2.imagepadSz([self.XSize self.YSize],...
                philog2ds,self.InvarianceScale);
            phiSpatial = gabor2D(self);
            % 2-D DFT of spatial scaling filter. This should be real-valued
            % and will only have a small nonzero imaginary part due to
            % numerical issues
            self.PhiFilter = real(fft2(phiSpatial));
            self = MorletWavelets(self);
            
            
            
        end
        
        function [phif,psifilters,f,filterparams] = filterbank(self,fb)
            % Wavelet and scaling filters
            %   PHIF = FILTERBANK(SF) returns the Fourier transform of the
            %   scaling filter for the 2-D wavelet scattering framework,
            %   SF. PHIF is a single or double-precision matrix depending
            %   on the value of the 'Precision' property of the scattering
            %   framework. PHIF has dimension M-by-N where M and N are the
            %   padded row and column sizes of the scattering framework.
            %
            %   [PHIF,PSIFILTERS] = FILTERBANK(SF) returns the Fourier
            %   transforms for the wavelet filters in PSIFILTERS.
            %   PSIFILTERS is a NFB-by-1 cell array where NFB is the number
            %   of filter banks in the scattering framework. Each element
            %   of PSIFILTERS is a 3-D array. The 3-D arrays are
            %   M-by-N-by-L where M and N are the padded row and column
            %   sizes of the wavelet filters and L is the number of wavelet
            %   filters for each filter bank. The wavelet filters are
            %   ordered by increasing scale with NumRotations wavelet
            %   filters for each scale.
            %
            %   [PHIF,PSIFILTERS,F] = FILTERBANK(SF) returns the center
            %   spatial frequencies for the wavelet filters in PSIFILTERS.
            %   F is a NFB-by-1 cell array where NFB is the number of
            %   filter banks in SF. The j-th element of F contains
            %   the center frequencies for the j-th wavelet filter bank in
            %   PSIFILTERS. Each element of F is a L-by-2 matrix
            %   with each row containing the center frequencies of the
            %   corresponding L-th wavelet. 
            %
            %   [PHIF,PSIFILTERS,F,FILTERPARAMS] = FILTERBANK(SF) returns
            %   the filter parameters for the 2-D scattering framework, SF.
            %   FILTERPARAMS is a NFB-by-1 cell array of MATLAB tables
            %   where the j-th element of FILTERPARAMS is a MATLAB table
            %   containing the filter parameters for the j-th filter bank.
            %   Each table contains the following variables:
            %
            %   Q:                  Quality factor
            %   J:                  Highest factor used in the dilation 
            %                       of the Morlet wavelets, 2^(J/Q)
            %   precision:          Precision of the scattering framework
            %   omegapsi:           Wavelet center frequencies
            %   freqsigmapsi:       Wavelet frequency standard deviations
            %   slant:              slant parameter for the spatial
            %                       vertical semi-major axis
            %   spatialsigmapsi:    Wavelet spatial standard deviations
            %   spatialsigmaphi:    Scaling filter spatial standard
            %                       deviation
            %
            %   psi3dBbw:           Wavelet 3-dB bandwidth
            %   psiftsupport:       Wavelet frequency support
            %   phiftsupport:       Scaling filter frequency support
            %   phi3dBbw:           Scaling filter 3-dB bandwidth
            %   rotations:          Wavelet orientation angles
            %
            %   [...] = FILTERBANK(SF,FB) returns the wavelet filters,
            %   center frequencies, and filter parameters for the filter
            %   banks specified in FB. FB is a scalar or vector of integers
            %   in the range [1,numfilterbanks(SF)]. If FB is a scalar,
            %   PSIFILTERS is M-by-N-by-L matrix and FILTERPARAMS is a
            %   MATLAB table. 
            %
            %   % Example: Obtain the scaling filter, wavelet filters,
            %   %   center frequencies and filter parameters for a wavelet
            %   %   image scattering framework with two filter banks. Plot
            %   %   the wavelet center frequencies for the two filter
            %   %   banks.
            %
            %   sf = waveletScattering2('QualityFactors',[2 1]);
            %   [phif,psifilters,f,filterparams] = filterbank(sf);
            %   plot(f{1}(:,1),f{1}(:,2),'k*'); hold on; grid on;
            %   plot(f{2}(:,1),f{2}(:,2),'r^','MarkerFaceColor',[1 0 0])
            %   xlabel('f_x'); ylabel('f_y');
            %   legend('1st Filter Bank Q=2','2nd Filter Bank Q=1',...
            %       'Location','NorthEastOutside');
            %
            %   % Example: Obtain the wavelet filters and center
            %   %   frequencies for the default scattering framework. Plot
            %   %   a specific wavelet and mark its center frequency.
            %
            %   sf = waveletScattering2;
            %   [~,psifilters,f] = filterbank(sf);
            %   Nx = size(psifilters{1},2);
            %   Ny = size(psifilters{1},1);
            %   fx = -1/2:1/Nx:1/2-1/Nx;
            %   fy = -1/2:1/Ny:1/2-1/Ny;
            %   imagesc(fx,fy,fftshift(psifilters{1}(:,:,2)))
            %   axis xy; hold on; xlabel('f_x'); ylabel('f_y');
            %   plot(f{1}(2,1),f{1}(2,2),'k^','markerfacecolor',[0 0 0])
            
            % Check number of input arguments
            narginchk(1,2);
            % Check number of output arguments
            nargoutchk(0,4);
            Nfb = self.nFilterBanks;
            if nargin > 1
                validateattributes(fb,{'numeric'},...
                    {'>=',1,'<=',Nfb,'integer'},'FILTERBANK','FB');
                fb = unique(fb,'stable');
            end
            phif = self.PhiFilter;
            % Obtain wavelet filters
            psifilters = self.PsiFilters;
            if self.EqualFB
                psif = cat(3,psifilters{:});
            end
            
            % Construct [f_x f_y] frequency pairs
            ftmp = spatialfreq(self);
            filterparams = radianToCyclicFreq(self);   
            filterparams = waveletScattering2.removeLog2DS(filterparams);
            if self.EqualFB
                psifilters = cell(Nfb,1);
                f = cell(Nfb,1);
                for nf = 1:Nfb
                    psifilters{nf} = psif;
                    f{nf} = ftmp;
                end
            else
                f = ftmp;                
            end
            
            if nargin > 1 && numel(fb) > 1
                f = f(fb);
                psifilters = psifilters(fb);
                filterparams = filterparams(fb);
            elseif nargin > 1 && numel(fb) == 1
                f = f{fb};
                psifilters = psifilters{fb};
                filterparams = filterparams{fb};                
                
            end          
            
            
        end     
        
        function S = featureMatrix(self,x,varargin)
            %Scattering feature matrix
            %   SMAT = FEATUREMATRIX(SF,IM) returns the scattering feature
            %   matrix for the image scattering decomposition framework,
            %   SF, and the input image, IM. IM is a real-valued 2-D
            %   (M-by-N) or 3-D matrix (M-by-N-by-3). If IM is a 3-D
            %   matrix, the size of the third dimension must be 3. If IM is
            %   a 2-D matrix, SMAT is Np-by-Ms-by-Ns where Np is the number
            %   of scattering paths and Ms-by-Ns is the resolution of the
            %   scattering coefficients. If IM is a 3-D matrix, SMAT is
            %   Np-by-Ms-by-Ns-by-3.
            %
            %   SMAT = FEATUREMATRIX(SF,S) returns the scattering feature
            %   matrix for the cell array of scattering coefficients, S.
            %   S is obtained from the scatteringTransform method of the
            %   image scattering decomposition framework.
            %
            %   SMAT = FEATUREMATRIX(...,'Transform',TRANSFORMTYPE)
            %   applies the transformation specified by TRANSFORMTYPE to
            %   the scattering coefficients. Valid options for
            %   TRANSFORMTYPE are 'log' and 'none'. If unspecified,
            %   TRANSFORMTYPE defaults to 'none'.
            %
            %   % Example Obtain the scattering feature matrix for the
            %   %   xbox image.
            %   
            %   load xbox;
            %   sf = waveletScattering2('ImageSize',size(xbox));
            %   smat = featureMatrix(sf,xbox);
            
            narginchk(2,4);
            nargoutchk(0,1);
            %Scattering feature matrix
            p = inputParser;
            validtransform = ["log" ; "none"];
            p.addParameter('Transform','none');
            p.parse(varargin{:});
            transform = validatestring(p.Results.Transform,...
                validtransform,'featureMatrix','Transform');
            method = '';
            
            if (ismatrix(x) || (ndims(x) == 3  && size(x,3) == 3)) ...
                    && ~iscell(x)
                method = 'rawdata';
            elseif iscell(x)
                method = 'scattering';
            end
            
            switch method
                % If matrix, scattering transform has not been computed
                case 'rawdata'                    
                    x = scatteringTransform(self,x);
                    Sf = waveletScattering2.flattenscattering2Dtransform(x);
                    S = waveletScattering2.scatteringmatrix(Sf);
                case 'scattering'
                    Sf = waveletScattering2.flattenscattering2Dtransform(x);
                    S = waveletScattering2.scatteringmatrix(Sf);
                otherwise
                    error(message('Wavelet:scattering:InvalidFeatureInput'));
            end
            if strcmpi(transform,'log')                
                S = log(abs(S)+realmin(char(self.Precision)));
            end
        end
        
        function  self = set.OversamplingFactor(self,OSF)
           validOversamplingFactor = @(x) assert((isnumeric(x) && isscalar(x) ...
                && x>=0 && floor(x)==x) || ...
                (isinf(x)&& x>=0 && floor(x) == x),...
                message('Wavelet:scattering:InvalidLOSF'));
           validOversamplingFactor(OSF);
           self.OversamplingFactor = OSF; 
        end
        
        function self = set.OptimizePath(self,OPTPATH)
            validOptimizePath = @(x)assert(islogical(OPTPATH) && ...
                isscalar(OPTPATH), message('Wavelet:scattering:optpath'));
            validOptimizePath(OPTPATH);
            self.OptimizePath = OPTPATH;
        end
        
        function sz = coefficientSize(self)
            % Scattering coefficient size
            %   SZ = COEFFICIENTSIZE(SF) returns the scattering coefficient
            %   sizes for the wavelet image scattering framework, SF. SZ is
            %   a two-element row vector which gives the scattering
            %   coefficient output size in the row and column dimensions.
            %   For an RGB image, the actual output size is [SZ(1) SZ(2) 3].
            %   
            %   % Example: Determine the scattering coefficient size for
            %   %   the default framework. Increase the oversampling
            %   %   factor to 1 and query the scattering coefficient size.
            %
            %   sf = waveletScattering2;
            %   sz = coefficientSize(sf)
            %   sf.OversamplingFactor = 1;
            %   sz = coefficientSize(sf);
            
            % Check number of input arguments
            narginchk(1,1);
            % Check number of output arguments
            nargoutchk(0,1);
            if ~isinf(self.OversamplingFactor) && (self.OversamplingFactor < self.CriticalResolution)
                sz = 1+fix((self.ImageSize-1)./2^(self.CriticalResolution-self.OversamplingFactor));
            else
                sz = self.ImageSize;
            end
        end
        
        function no = numorders(self)
            % Number of scattering orders
            %   NO = NUMORDERS(SF) returns the number of orders for the
            %   scattering decomposition framework, SF. The number of
            %   orders is equal to the number of filter banks+1.
            %
            %   % Example: Return the number of orders for the default
            %   %   image scattering framework.
            %
            %   sn = waveletScattering2;
            %   no = numorders(sn);
            
            % Check number of input arguments
            narginchk(1,1);
            % Check number of output arguments
            nargoutchk(0,1);
            no = self.nFilterBanks+1;
        end
        
        function y = log(self,x)
            %Natural logarithm of scattering transform
            %   Slog = log(SF,S) returns the natural logarithm of the
            %   scattering coefficients in the cell array, S. S is the
            %   output of scatteringTransform and is a cell array of
            %   structure arrays with an images field.
            %
            %   Ulog = log(SF,U) returns the natural logarithm of the
            %   scalogram coefficients in U. U is the output of
            %   scatteringTransform and is a cell array of structure arrays
            %   with a coefficients field.
            %
            %   Xlog = log(SF,X) returns the natural logarithm of the 3-D
            %   or 4-D tensor, X. X is the output of featureMatrix.
            %
            %   % Example Obtain the scattering transform of an image and
            %   %   then obtain the natural log of the scattering 
            %   %   coefficients.
            %   load xbox;
            %   sf = waveletScattering2('ImageSize',size(xbox),...
            %       'InvarianceScale',min(size(xbox)));
            %   S = scatteringTransform(sf,xbox);
            %   Slog = log(sf,S);
            
            % Check number of input arguments
            narginchk(1,2);
            nargoutchk(0,1);
            validateattributes(x,{'cell','numeric'},{'nonempty'},'log','X');
            if iscell(x)
                % Use logscatteringtransform method
                y = waveletScattering2.logscatteringtransform(x,char(self.Precision));
            elseif isnumeric(x) && (ndims(x) == 3 || ...
                    (ndims(x) == 4 && size(x,4) == 3))    
                validateattributes(x,{'numeric'},{'finite'},'log','X');
                y = log(abs(x)+realmin(char(self.Precision)));
            else
                error(message('Wavelet:scattering:logmatrix2'));
                
            end
        end
        
        function nfb = numfilterbanks(self)
            %Number of scattering filter banks
            %   NFB = NUMFILTERBANKS(SF) returns the number of filter banks
            %   in the scattering decomposition framework, SF. The number
            %   of filter banks in a scattering decomposition framework is
            %   equal to the number of orders-1.
            %
            %   % Example: Return the number of filter banks for the default
            %   %   scattering decomposition.
            %   sf = waveletScattering2;
            %   nfb = numfilterbanks(sf);
            
            narginchk(1,1);
            nargoutchk(0,1);
            nfb = self.nFilterBanks;
        end
        
        % Public method signatures
        [S,U] = scatteringTransform(self,im);
        [lpsum,f] = littlewoodPaleySum(self,fb);
        [spaths,npaths] = paths(self);
        
        
        
    end
    
    methods(Access = private,Hidden)
               
        function self = MorletWavelets(self)
            SX = self.XSizePad;
            SY = self.YSizePad;
            
            precision = self.Precision;
            offset = [0 0];
            
            nfb = numel(self.filterparams);
            
            if self.EqualFB
                nfb = 1;
            end
            self.PsiFilters = cell(nfb,1);
                        
            for fb = 1:nfb
                sigmapsi = self.filterparams{fb}.spatialsigmapsi;
                slant = self.filterparams{fb}.slant;
                OmegaC = self.filterparams{fb}.omegapsi;
                theta = self.filterparams{fb}.rotations;
                self.PsiFilters{fb} = waveletScattering2.Morlet2D(SX,SY,...
                    sigmapsi,slant,OmegaC,theta,offset,precision);               
                
                
            end         
 
        end
        
        function F = spatialfreq(self)
           fparams = self.filterparams; 
           if self.EqualFB
                NF = ...
                    numel(fparams{1}.rotations)*numel(fparams{1}.omegapsi);
                Omegay = ...
                    sin(fparams{1}.rotations)'*fparams{1}.omegapsi;
                Omegax = ...
                    cos(fparams{1}.rotations)'*fparams{1}.omegapsi;
                Omegay = reshape(Omegay,NF,1);
                Omegax = reshape(Omegax,NF,1);
                F = [Omegax Omegay]./(2*pi);
           elseif ~self.EqualFB
               F = cell(self.nFilterBanks,1);
               for nfb = 1:self.nFilterBanks
                   fp = fparams{nfb};
                   NF = numel(fp.rotations)*numel(fp.omegapsi);
                   Omegay = ...
                        sin(fp.rotations)'*fp.omegapsi;
                    Omegax = ...
                        cos(fp.rotations)'*fp.omegapsi;
                    Omegay = reshape(Omegay,NF,1);
                    Omegax = reshape(Omegax,NF,1);
                    F{nfb} = [Omegax Omegay]./(2*pi);
               end
                
                
            end 
            
        end
        
        function criticalRes = criticalResolution(self)
            totalBW = 2*pi;
            criticalRes = round(log2(totalBW/self.filterparams{1}.phiftsupport));
        end    
              
                
        function self = setProperties(self,varargin)
            self.OBW = 0.995;
            % Test for Q-factors in scattering architecture
            validQ = @(x)validateattributes(x,{'numeric'},...
                {'vector','real','positive','nonincreasing','integer','<=',4},...
                'waveletScattering2','QualityFactors');
            % We are using a symmetric scaling filter in both the spatial
            % and spatial frequency domains so we use one T value
            validT = @(x)validateattributes(x,{'numeric'},{'positive','scalar',...
                'nonempty'});
            validPrecision = ["double", "single"];
            % 12 is the smallest value where 1/2 the smallest dimension
            % yields a valid framework.
            validImageSize = @(x)validateattributes(x,{'numeric'},{'real',...
                'positive','integer','numel',2,'>=',10},'waveletScattering2','ImageSize');
            validRotations = @(x)validateattributes(x,{'numeric'},...
                {'vector','integer','positive','<=',12},'waveletScattering2','NumRotations');
                      
            p = inputParser;
            p.addParameter('ImageSize',[128 128],validImageSize);
            p.addParameter('QualityFactors',[1 1],validQ);
            p.addParameter('InvarianceScale',[],validT);
            p.addParameter('Precision','single');
            p.addParameter('NumRotations',[6 6],validRotations);
            p.addParameter('OversamplingFactor',0);
            p.addParameter('OptimizePath',true);
            p.parse(varargin{:});
            self.ImageSize = p.Results.ImageSize;
            self.XSize = self.ImageSize(2);
            self.YSize = self.ImageSize(1);
            self.InvarianceScale = p.Results.InvarianceScale;
            self.Precision = ...
                validatestring(p.Results.Precision,validPrecision,...
                'waveletScattering2','Precision');
            self.QualityFactors = p.Results.QualityFactors;
            self.nFilterBanks = numel(self.QualityFactors);
            self.NumRotations = p.Results.NumRotations;
            self.OversamplingFactor = p.Results.OversamplingFactor;
            self.OptimizePath = p.Results.OptimizePath; 
            if isempty(self.InvarianceScale)
                self.InvarianceScale = round(min(self.XSize,self.YSize)/2);
            end
            % Check agreement between number of quality factors and number
            % of rotation angles. Throw error if they are not equal
            NQ = numel(self.QualityFactors);
            NR = numel(self.NumRotations);
            if ~isequal(NQ,NR)
                error(message('Wavelet:scattering:RotQ',NQ,NR));
            end
                    
            % Translate number of rotations to angles in radians between
            % 0 and \pi
            self = rotationAngles(self);
            % If the quality factors and number of rotations are the same
            % we do not compute the same filterbank multiple times
            AllIdenticalQ = ~any(diff(self.QualityFactors));
            AllIdenticalNR = ~any(diff(self.NumRotations));
            if AllIdenticalQ && AllIdenticalNR
                self.EqualFB = true;
            else
                self.EqualFB = false;
            end
            if self.InvarianceScale > min(self.XSize,self.YSize)
                error(message('Wavelet:scattering:ImageSizeT',...
                    self.InvarianceScale,min(self.XSize,self.YSize)));
            end
            
        end
        
        
        
        function self = rotationAngles(self)
            for fb = 1:numel(self.QualityFactors)
                self.Theta{fb} = ...
                    (0:self.NumRotations(fb)-1)*pi./self.NumRotations(fb);
            end
            
        end
        
        function filterparams = radianToCyclicFreq(self)
            filterparams = self.filterparams;
        
            for nl = 1:self.nFilterBanks
                    filterparams{nl}{:,{'omegapsi','freqsigmapsi'}} = ...
                    filterparams{nl}{:,{'omegapsi','freqsigmapsi'}}./(2*pi);
                    filterparams{nl}{:,{'freqsigmaphi','psi3dBbw'}} = ...
                    filterparams{nl}{:,{'freqsigmaphi','psi3dBbw'}}./(2*pi);
                    filterparams{nl}{:,{'psiftsupport','phiftsupport'}} = ...
                    filterparams{nl}{:,{'psiftsupport','phiftsupport'}}./(2*pi);
                     filterparams{nl}{:,{'phi3dBbw'}} = ...
                    filterparams{nl}{:,{'phi3dBbw'}}./(2*pi);
                
                
            end
        end
        
        % Nonstatic private methods declared in separate functions
        [gparams2,slant] = gaborparameters2(self);
        gab = gabor2D(self);               
        
    end
    
    methods(Static,Hidden)
        function filterparams = removeLog2DS(filterparams)
           for nfb = 1:numel(filterparams)
              filterparams{nfb} = removevars(filterparams{nfb},...
                  {'PsiLog2DS','PhiLog2DS'});
           end     
            
        end
        
        % Function signatures for static methods outside class file        
        psif = Morlet2D(Nx,Ny,sigma,slant,omegaC,theta,offset,precision);
        [XSize,YSize] = imagepadSz(origsize,log2maxScale,MaxSupport);
        [R,Rinv] = rotmat2d(theta);
        [log2_phi_os, log2_psi_os] = log2DecimationFactor(gparams,resolution,OSFactor,validwav);
        padimg = padimage(img,padsize);
        [imout,dsfilter] = convdown2(imdft,filter,dsfactor,res);
        y = unpadimage(x,log2ds,origsize);
        [U_phi,U_psi] = Cascade2(U,phift,psift,filtparams,type,OSFactor,optpath);
        tf = frequencyoverlap(res,gparams);
        validwav = optimizePath(validwav,current3dB,gparams);
        [phicoefs,psicoefs,phimeta,psimeta] = ...
            wavelet2D(im,res,phift,psift,filterparams,vwav,path,type,OSFactor);
        X = apply_nonlinearity(option,X);
        x = logscatteringtransform(x,precision)
        Sflat = flattenscattering2Dtransform(S);
        Smat = scatteringmatrix(S);

        
    end
end

