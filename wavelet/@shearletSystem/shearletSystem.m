% Shearlet system
%   SLS = shearletSystem creates a cone-adapted real-valued shearlet system
%   for an image size of 128-by-128 with the number of scales set to 4. SLS
%   is a nondecimated shearlet system. Shearlets extending beyond the 2-D
%   frequency boundaries are periodically extended. Using real-valued
%   shearlets with periodic boundary conditions results in real-valued
%   shearlet coefficients.
%
%   SLS = shearletSystem(Name,Value) creates a shearlet system, SLS, with
%   the specified property Name set to the specified Value. You can specify
%   additional name-value pair arguments in any order as
%   (Name1,Value1,...,NameN,ValueN).
%
%   shearletSystem methods:
%
%   sheart2                         - Shearlet transform
%   isheart2                        - Inverse shearlet transform
%   framebounds                     - Frame bounds
%   filterbank                      - Shearlet filters
%   numshears                       - Number of shearlets
%
%   shearletSystem properties:
%
%   ImageSize           - Image size
%   NumScales           - Number of scales 
%   TransformType       - Real- or complex-valued shearlet system
%   FilterBoundary      - Filter boundary conditions
%   PreserveEnergy      - Shearlet normalization
%   Precision           - Shearlet system precision
%
%   See also CWTFT2, DDDTREE2

%   Copyright 2019 MathWorks, Inc.
classdef shearletSystem < handle
    
    %#codegen
    
    properties (SetAccess = private)
        
        %ImageSize Size of the input image.
        %   ImageSize is a two-element vector, [numrows numcolumns].
        %   shearletSystem only supports 2-D images. If unspecified,
        %   ImageSize defaults to [128 128]. 
        %   ImageSize is a read-only property.
        ImageSize
        %NumScales Number of scales.
        %   NumScales is a positive integer less than or equal to
        %   log2(min([M N]))-3, where M and N are the row and column
        %   dimensions of the input image. This means that the
        %   smallest image compatible with shearletSystem has a minimum
        %   dimension of 16.
        %   NumScales is a read-only property.
        NumScales
        %PreserveEnergy Shearlet system analysis normalization.
        %   PreserveEnergy is a logical property. If you specify
        %   'PreserveEnergy', true, the shearlet system is normalized to be
        %   a Parseval frame and the energy of the input image is preserved
        %   in the shearlet transform coefficients. If unspecified,
        %   PreserveEnergy defaults to false. 
        %   PreserveEnergy is a read-only property.
        PreserveEnergy
        %TransformType Shearlet system type.
        %   Specify TransformType as 'real' or 'complex'. TransformType
        %   defaults to 'real'. Real-valued shearlets have two-sided 2-D
        %   frequency spectra while complex-valued shearlets have one-sided
        %   2-D spectra. If 'FilterBoundary' is set to 'periodic',
        %   shearlets at the finest spatial scales will have energy that
        %   wraps around in the 2-D frequency response. For both 'real' and
        %   'complex' shearlet systems, the Fourier transforms of the
        %   shearlets are real-valued. 
        %   TransformType is a read-only property.
        TransformType
        %FilterBoundary Shearlet filter boundary handling.
        %   Determines how shearlets are treated at the 2-D
        %   frequency boundaries. Valid options are 'periodic' (default)
        %   and 'truncated'. When 'FilterBoundary' is 'periodic',
        %   shearlets extending beyond the 2-D frequency boundaries are
        %   periodically extended. If you set 'FilterBoundary' to
        %   'truncated', shearlets are truncated at the 2-D frequency
        %   boundaries. 
        %   FilterBoundary is a read-only property.
        FilterBoundary
        %Precision Shearlet system precision.
        %   Valid options for Precision are 'double' or 'single'. When you
        %   specify 'Precision' as 'single', all computations are done
        %   using single-precision arithmetic. Precision defaults to
        %   'double'. 
        %   Precision is a read-only property.
        Precision
        
        
        
    end
    
    properties (SetAccess = private, Hidden = true)
        xmin
        xmax
        ymin
        ymax
        Alphas
        hori_scale_fun
        vert_scale_fun
        hori_lowpass_fun
        vert_lowpass_fun
        
    end
    
    properties (SetAccess = private, Hidden = true)
        width
        height
        x_values
        y_values
        Scales
        Shears
        Cones
        hor_quo_grids
        ver_quo_grids
        lowpassfilter
        shearlets
        hor_scale_fac
        hor_shift_fac
        vert_scale_fac
        vert_shift_fac
        SpatialNorms
        FourierNorms
        DualFrameWeights
        % Haeuser and Meyer functions
        ScaleFunction
        DirectionFunction
        LowpassFunction
        % Number of shearlets for code generation
        NumShearlets
        hori_scale_low_pass
        vert_scale_low_pass
    end
    
    methods
        function self = shearletSystem(varargin)
            if isempty(varargin)
                self.ImageSize = [128 128];
                self.Precision = 'double';
                self.width = self.ImageSize(2)*ones(1,self.Precision);
                self.height = self.ImageSize(1)*ones(1,self.Precision);
                self.FilterBoundary = 'periodic';
                self.PreserveEnergy = false;
                self.TransformType = 'real';
                self.NumScales = 4;
                self.Alphas = 0.5*ones(self.NumScales,1);
                
            else
                self = setProperties(self,varargin{:});
                
                
            end
            % Calculate number of shearlets
            determineShearletNumber(self);
            % Calculate centered grid for image
            calculate_bounds(self);
            % Determine indices for shearlet system
            calculate_indices(self);
            % Define Haeuser scale function
            setScaleFunction(self);
            % Define Haeuser direction function
            setDirectionFunction(self);
            % Define Meyer lowpass function
            setLowpassFunction(self);
            % Scale filters depending on image size
            rescale_filters(self);
            % Calculate grids including periodization if required and
            % return lowpass filter, \phi. These grids are used in the
            % direction function
            calculate_grids(self);
            % Calculate shearlets
            calculateTIshearlets(self);
            
            
            
        end
        
        function coefs = sheart2(self,im)
            % Shearlet transform
            %   COEFS = SHEART2(SLS,IM) returns the shearlet transform or
            %   analysis of the real-valued 2-D image, IM, for the shearlet
            %   system specified by SLS. The size and class of IM must
            %   match the 'ImageSize' and 'Precision' of the shearlet
            %   system, SLS. COEFS is an M-by-N-by-K possibly
            %   complex-valued matrix, where M and N are the row and column
            %   dimensions of the input image. K is the number of shearlets
            %   in SLS plus the lowpass filter, K = numshears(SLS)+1.
            %
            %   % Example: Obtain the shearlet transform of the shapes
            %   %   image.
            %   load shapes
            %   sls = shearletSystem('ImageSize',[512 512],'NumScales',4);
            %   cfs = sheart2(sls,shapes);
            
            CLim = class(im);
            if ~strcmpi(self.Precision,CLim) 
                coder.internal.error('Wavelet:shearletSystem:imwrongtype');
            end
            
            validateattributes(im,{'double','single'},{'2d','finite','nonempty','real'},'sheart2','IM');
            if isrow(im) || iscolumn(im)
                coder.internal.error('Wavelet:shearletSystem:ExpectedImage');
            end
            
            Szim = size(im);
            Ns = size(self.shearlets,3);
            if ~all(Szim == self.ImageSize)
                coder.internal.error('Wavelet:shearletSystem:ImageSize',...
                    Szim(1),Szim(2),self.ImageSize(1),self.ImageSize(2));
            end
            
            % Fourier transform of image
            imdft = shearletSystem.orthofft2(im);
            % For us the Y-frequencies are in descending order from top to
            % bottom
            imdft = flip(fftshift(imdft),1);
            spect = freqconv(self,imdft);

            coefs = complex(zeros(size(spect),self.Precision));

            for ns = 1:Ns
                coefs(:,:,ns) = shearletSystem.orthoifft2(ifftshift(flip(spect(:,:,ns),1)),'nonsymmetric');
            end

        end
        
        function imrec = isheart2(self,coefs)
            % Inverse shearlet transform
            %   IMREC = ISHEART2(SLS,CFS) returns the inverse shearlet
            %   transform or synthesis based on the shearlet system, SLS,
            %   and the shearlet transform coefficients, CFS. ISHEART2
            %   assumes SLS is the same shearlet system used to obtain
            %   the transform coefficients, CFS. CFS is an M-by-N-by-K
            %   matrix where M and N are equal to the row and column
            %   dimensions of the original image. K is the number of
            %   shearlets including the lowpass filter, K =
            %   numshears(SLS)+1.
            %
            %   % Example: Demonstrate perfect reconstruction with the
            %   %   shearlet system.
            %   load shapes
            %   sls = shearletSystem('ImageSize',[512 512],'NumScales',4);
            %   cfs = sheart2(sls,shapes);
            %   imrec = isheart2(sls,cfs);
            %   norm(imrec-shapes,'fro')
            
            if ~isequal(size(coefs),size(self.shearlets))
                coder.internal.error('Wavelet:shearletSystem:coefswrong');
            end
            imdft = zeros(self.height,self.width,self.Precision);
            Ns = size(self.shearlets,3);
            if isempty(self.DualFrameWeights)
                dualWeights(self);
            end
            if isempty(self.SpatialNorms)
                SFnorms(self);
            end
            Snorms = reshape(self.SpatialNorms,1,1,Ns);
            % Re-normalize coefficients
            renormedcoefs = bsxfun(@times,coefs,Snorms);
            % If Parseval frame use the adjoint operator
            if self.PreserveEnergy
                imdft = adjointTransform(self,renormedcoefs);
            else
                for ns = 1:Ns
                    coefDFT =   flip(fftshift(shearletSystem.orthofft2(coefs(:,:,ns))),1);
                    imdft = imdft+(self.shearlets(:,:,ns).*coefDFT./self.DualFrameWeights);
                end
            end
            % Symmetry type not supported for code generation.
            % We are currently supporting just real-valued 2-D inputs. We
            % can easily modify this to accept complex-valued if we have
            % use cases
            imrec = real(shearletSystem.orthoifft2(ifftshift(flip(imdft,1)),'nonsymmetric'));
            
            
            
        end
        
        
        function [A,B] = framebounds(self)
            % Frame Bounds
            %   [A,B] =  FRAMEBOUNDS(SLS) returns the lower (A) and upper
            %   (B) frame bounds for the shearlet system, SLS. If you
            %   specify 'PreserveEnergy',true, the shearlet system is a
            %   Parseval frame and the frame bounds are both equal to 1.
            %   Otherwise, the energy in the analysis coefficients CFS is
            %   bounded by the energy in the input image IM and the frame
            %   bounds by the frame inequality
            %   A*norm(IM,'fro') <= norm(CFS(:)) <= B*norm(IM,'fro')
            %
            %   % Example: Obtain the shearlet transform of an input image
            %   %   and verify the frame inequality.
            %   load xbox
            %   sls = shearletSystem('ImageSize',[128 128]);
            %   cfs = sheart2(sls,xbox);
            %   [A,B] = framebounds(sls);
            %   A*norm(xbox,'fro')^2 <= norm(cfs(:))^2 && ...
            %   B*norm(xbox,'fro')^2 >= norm(cfs(:))^2
            
            if isempty(self.DualFrameWeights)
                dualWeights(self);
            end
            
            if self.PreserveEnergy
                A = ones(1,'like',self.DualFrameWeights);
                B = ones(1,'like',self.DualFrameWeights);
            else
                A = min(min(self.DualFrameWeights));
                B = max(max(self.DualFrameWeights));
            end
        end
        
        function [psi,scale,shear,cone] = filterbank(self)
            % Shearlet filters
            %   PSI = FILTERBANK(SLS) returns the Fourier transforms of the
            %   shearlet filters defined by the shearlet system, SLS. PSI
            %   is an M-by-N-by-K matrix where M is the row size of the
            %   input image, N is the column size, and K is the number of
            %   shearlets including the lowpass filter, 
            %   K = numshears(SLS)+1. 
            %
            %   [PSI,SCALE,SHEAR,CONE] = FILTERBANK(SLS) returns the
            %   geometric interpretation of the shearlets. SCALE, SHEAR,
            %   and CONE are K-by-1 where K is the number of shearlets in
            %   SLS, including the lowpass filter, K = numshears(SLS)+1.
            %   SCALE and SHEAR are numeric vectors containing the scale
            %   and shearing parameters respectively for the corresponding
            %   k-th element in the third dimension of PSI. CONE is a cell
            %   array of characters. The first elements of SCALE, SHEAR,
            %   and CONE are -1,0,'X' respectively and denote the lowpass
            %   filter. The remaining elements of SCALE are integers
            %   between 0 and NumScales-1. The SHEAR values are integers in
            %   the range from -ceil(2^(S/2)) to ceil(2^(S/2)) where S
            %   denotes the scale. The elements of CONE denote the
            %   frequency cone in which the corresponding shearlet has its
            %   frequency support, expressed as a character.
            %
            %   For complex-valued shearlets, the frequency plane
            %   is divided into four cones: 'R' (right), 'T' (top), 'L'
            %   (left), and 'B' (bottom). For real-valued shearlets, the
            %   frequency cones are 'H' (horizontal) or 'V' (vertical).
            %
            %   % Example: For a complex-valued shearlet system with
            %   %   truncated filter boundaries and one scale, plot the
            %   %   0,0,'T' shearlet.
            %   sls = shearletSystem('TransformType','complex',...
            %       'NumScales',1,'FilterBoundary','truncated');
            %   [psi,scale,shear,cone] = filterbank(sls);
            %   omegax = -1/2:1/128:1/2-1/128;
            %   omegay = omegax;
            %   surf(omegax,flip(omegay),psi(:,:,6),'EdgeColor','none');
            %   view(0,90);
            %   xlabel('\omega_x'); ylabel('\omega_y');
            %   title('0,0,''T'' Shearlet');
            
            
            psi = self.shearlets;
            if nargout > 1
                scale = self.Scales;
                shear = self.Shears;
                cone = self.Cones;
            end
            
        end
        
        function ns = numshears(self)
            % Number of shearlets
            %    NS = NUMSHEARS(SLS) returns the number of shearlets in the
            %    shearlet system, SLS. Note the number of shearlets does
            %    not include the lowpass filter, which is not sheared. The
            %    total filter size of the shearlet system is
            %    M-by-N-by-NS+1, where M and N are the row and column
            %    dimensions of the image.
            %
            %    % Example: Return the number of shearlets in the default 
            %    %  shearlet system.
            %    sls = shearletSystem; ns = numshears(sls);            
            
            
            ns = self.NumShearlets-1;
            
        end
        
        
    end
    
    methods (Hidden = true)
        
        function calculate_bounds(self)
            % Calculate centered grid for image
            % If width is even, the epsilon_width is 1, else 0.
            epsilon_width = 1-mod(self.width,2);
            % Same for epsilon_height
            epsilon_height = 1-mod(self.height,2);
            N = floor((self.width-1-epsilon_width)/2);
            M = floor((self.height-1-epsilon_height)/2);
            % Check that image centering is correct
            coder.internal.assert(2*N+1+epsilon_width == self.width, ...
                'Wavelet:shearletSystem:ImageCenterIncorrect');
            coder.internal.assert(2*M+1+epsilon_height == self.height, ...
                'Wavelet:shearletSystem:ImageCenterIncorrect');
            % Image bounds: We center the image dimensions as
            % [-xmin xmax] and [-ymin ymax] with 0 in the center. The
            % bounds are identical for an odd dimension and one sample
            % biased toward negative side for even.
            self.xmin = -N-epsilon_width;
            self.xmax = N;
            self.ymin = -M-epsilon_height;
            self.ymax = M;
            
        end
        
        function spect = freqconv(self,imdft)
            spect = bsxfun(@times,imdft,self.shearlets);
        end
        
        function imdft = adjointTransform(self,coefs)
            imdft = complex(zeros(self.height,self.width,self.Precision));
            Ns = size(self.shearlets,3);
            Snorms = reshape(self.SpatialNorms,1,1,Ns);
            spect = bsxfun(@rdivide,self.shearlets,Snorms);
            for ns = 1:Ns
                imdft = imdft + spect(:,:,ns).*flip(fftshift(shearletSystem.orthofft2(coefs(:,:,ns))),1);
            end
            
            
        end
        
        
        
        function rescale_filters(self)
            % This method rescales the ScaleFunction and lowpass functions
            % for the image size and maximum number of scales. The large
            % supports of the scale functions (both horizontal and
            % vertical) will extend to the width and height of the image.
            
            % The negative side of the centered interval always has the
            % largest in absolute value number.
            
            % Take the negative. The largest value in absolute value is
            % always on the negative side. This is the way calculate grids
            % is designed to work.
            Xmax = -self.xmin;
            Ymax = -self.ymin;
            % Take the minimum for worst-case scenario
            R = min(Xmax,Ymax);
            maxScale = 2^(-(self.NumScales-1));
            lowerbound = self.ScaleFunction.LargeSupport(1);
            upperbound = self.ScaleFunction.LargeSupport(2);
            a = maxScale*lowerbound/upperbound*R;
            % The above is the support of the lowpass filter at the largest
            % requested scale. This must be at least 4, [-2,2] for the
            % Meyer lowpass filter.
            coder.internal.assert(a >=4,'Wavelet:shearletSystem:ScaleAssert');
            % How big is the $\psi_1$ large support region at the maximum
            % scale? We want the large support of \psi_1 to match the
            % frequency extent of the original image
            scale_numerator = (upperbound-lowerbound)/maxScale;
            hor_scale = scale_numerator/(Xmax-a/maxScale);
            vert_scale = scale_numerator/(Ymax-a/maxScale);
            scaleLargeSupportDiff = upperbound-lowerbound;
            hor_shift = hor_scale*a-scaleLargeSupportDiff;
            vert_shift = vert_scale*a-scaleLargeSupportDiff;
            self.hor_shift_fac = hor_shift;
            self.vert_shift_fac = vert_shift;
            % At the maximum scales, these should match the width. But
            % because of the way MATLAB does things, we will actually apply
            % operations to the ScaleFunction
            self.hori_scale_fun = ...
                shearletSystem.scale(shearletSystem.translate(self.ScaleFunction,hor_shift),1/hor_scale);
            self.hor_scale_fac = 1/hor_scale;
            % And height of the image
            self.vert_scale_fun = ...
                shearletSystem.scale(shearletSystem.translate(self.ScaleFunction,vert_shift),1/vert_scale);
            self.vert_scale_fac = 1/vert_scale;
            self.hori_scale_low_pass = a/self.LowpassFunction.LargeSupport(2);
            self.vert_scale_low_pass = a/self.LowpassFunction.LargeSupport(2);
            self.hori_lowpass_fun = shearletSystem.scale(self.LowpassFunction,self.hori_scale_low_pass);
            self.vert_lowpass_fun = shearletSystem.scale(self.LowpassFunction,self.vert_scale_low_pass);
            
            
            
        end
        
        function setScaleFunction(self)
            % The Haeuser scale function is defined in the original paper
            % for values of \omega from 1 \geq \omega \leq 4 with "large"
            % support on [1.5,3]. Here we use only the positive frequency
            % range. In the original paper it is symmetric with respect to 
            % DC.
            
            % Initialize structure array
            self.ScaleFunction = struct('Support',NaN(1,2,self.Precision),'LargeSupport',NaN(1,2,self.Precision));
            self.ScaleFunction.Support = cast([1 4],self.Precision);
            self.ScaleFunction.LargeSupport = cast([3/2 3],self.Precision);
            
        end
        
        function setDirectionFunction(self)
            % Initialize structure array
            self.DirectionFunction = struct('Support',NaN(1,2,self.Precision),'LargeSupport',NaN(1,2,self.Precision));
            self.DirectionFunction.Support = cast([-1 1],self.Precision);
            self.DirectionFunction.LargeSupport = cast([-1/2 1/2],self.Precision);
            
        end
        
        function setLowpassFunction(self)
            self.LowpassFunction = struct('Support',NaN(1,2,self.Precision),'LargeSupport',NaN(1,2,self.Precision));
            self.LowpassFunction.Support = cast([-2 2],self.Precision);
            self.LowpassFunction.LargeSupport = cast([-3/2 3/2],self.Precision);
            
        end
        
        
        
        function dualWeights(self)
            Ns = size(self.shearlets,3);
            self.DualFrameWeights = zeros(self.height,self.width,self.Precision);
            
            for ns = 1:Ns
                self.DualFrameWeights =  ...
                    self.DualFrameWeights+self.shearlets(:,:,ns).*self.shearlets(:,:,ns);
                
            end
            if self.PreserveEnergy
                self.DualFrameWeights = sqrt(self.DualFrameWeights);
            end
        end
        
        function SFnorms(self)
            % Compute space and frequency norms
            Ns = size(self.shearlets,3);
            self.FourierNorms = zeros(Ns,1,self.Precision);
            self.SpatialNorms = zeros(Ns,1,self.Precision);
            for ns = 1:size(self.shearlets,3)
                self.FourierNorms(ns) = norm(self.shearlets(:,:,ns),'fro');
                self.SpatialNorms(ns) = ...
                    self.FourierNorms(ns)/sqrt(self.width*self.height);
                
            end
            
        end
        
        
        function calculate_grids(self)
            % This method creates the grids for computing the shearlets.
            % If we use the default periodized boundary, then the grids are
            % periodized -1,0,1 in both the X and Y directions
            %
            % This method also computes the lowpass filter.
            [xval,yval] = self.xy_values();
            M = numel(yval);
            N = numel(xval);
            if strcmpi(self.FilterBoundary,'periodic')
                self.x_values = NaN(9,N,self.Precision);
                self.y_values = NaN(M,9,self.Precision);
                self.hor_quo_grids = NaN(M,N,9,self.Precision);
                self.ver_quo_grids = NaN(M,N,9,self.Precision);
            else
                self.x_values = NaN(1,N,self.Precision);
                self.y_values = NaN(M,1,self.Precision);
                self.hor_quo_grids = NaN(M,N,self.Precision);
                self.ver_quo_grids = NaN(M,N,self.Precision);
            end
            
            if strcmpi(self.FilterBoundary,'periodic')
                shifts = [-1 0 1];
                kk = 1;
                    for ii = 1:3
                        for jj = 1:3
                            % Shift starting values
                            xmintmp = self.xmin+shifts(ii)*self.width;
                            xmaxtmp = self.xmax+shifts(ii)*self.width;
                            ymintmp = self.ymin+shifts(jj)*self.height;
                            ymaxtmp = self.ymax+shifts(jj)*self.height;
                            [self.x_values(kk,:),self.y_values(:,kk)] = self.xy_values(xmintmp,xmaxtmp,...
                                ymintmp,ymaxtmp);
                            % Obtain quotient grids. To obtain horizontal
                            % grids, y/x, to obtain vertical x/y
                            self.hor_quo_grids(:,:,kk) = shearletSystem.div0(self.y_values(:,kk),self.x_values(kk,:));
                            self.ver_quo_grids(:,:,kk) = shearletSystem.div0(self.x_values(kk,:),self.y_values(:,kk));
                            kk = kk+1;
                            
                            
                        end
                    end
                               
                
            else
                
                self.x_values = xval;
                self.y_values = yval;
                self.hor_quo_grids = ...
                    shearletSystem.div0(yval,xval);
                self.ver_quo_grids = ...
                    shearletSystem.div0(xval,yval);
            end
            % Calculate the lowpass filter, \phi
            self.lowpassfilter = ...
                bsxfun(@times,shearletSystem.meyer_low_pass(xval./self.hori_scale_low_pass),...
                shearletSystem.meyer_low_pass(yval./self.vert_scale_low_pass));
            
            
        end
        
        
        function  calculate_indices(self)
            % indices = calculate_indices(alphas,type);
            % Returns a MATLAB cell array with scale, shear, and cone.
            % The third dimension of the CFS output of transform() matches
            % the length of the indices property. The tuple (-1,0,0)
            % indicates the lowpass function and is always the first
            % element of indices.
            %
            % The first element in indices is the scale, which ranges from
            % 0 to NumScales-1. The second element is the shear which
            % ranges from -ceil(2^(j/2)) to ceil(2^(j/2)) where j is the
            % scale.
            %
            % The final element is a scalar string indicating the cone. For
            % 'TransformType', 'real', the only cones are horizontal and
            % vertical, "H" and "V". For 'TransformType', 'complex', the
            % options are "R", "T","L","B"
            
            
            % These are the cones of the shearlet in the Fourier domain
            if strcmpi(self.TransformType,'real')
                cones = {'H','V'};
                
            else
                % String arrays not supported for code gen
                cones = {'R','T','L','B'};
                
            end
            % N = 1 reserved for lowpass filter
            N = 2;
            for jj = 0:numel(self.Alphas)-1
                for nc = 1:numel(cones)
                    currC = cones{nc};
                    k = ceil(2^((1-self.Alphas(jj+1))*jj));
                    % shear values
                    shear_range = -k:k;
                    
                    if any(strcmpi(currC,{'T','B','V'}))
                        % Reverse shears
                        shear_range = k:-1:-k;
                    end
                    % For the given shears, allocate scale and cones
                    for kk = 1:numel(shear_range)
                        % Set scale
                        self.Scales(N) = jj;
                        % Set shear
                        self.Shears(N) = shear_range(kk);
                        % Set cone
                        self.Cones{N} = currC;
                        N = N+1;
                    end
                end
            end
            
            
        end
        
        function [x_values,y_values] = xy_values(self,xmin,xmax,ymin,ymax)
            
            if nargin == 1
                xmin = self.xmin;
                xmax = self.xmax;
                ymin = self.ymin;
                ymax = self.ymax;
            end
            x_values = cast(xmin:xmax,self.Precision);
            y_values = cast(ymax:-1:ymin,self.Precision);
            y_values = y_values(:);
            
            
        end
        
        function calculateTIshearlets(self)
            
            self.shearlets = zeros(self.height,self.width,self.NumShearlets,self.Precision);
            % The lowpass filter has already been computed
            sc = self.Scales(2:end,:);
            sh = self.Shears(2:end,:);
            cn = cell(numel(self.Cones)-1,1);
            for ii = 1:numel(cn)
                cn{ii} = self.Cones{ii+1};
            end
            
            for ii = 1:numel(sc)
                jj = sc(ii);
                kk = sh(ii);
                cone = cn{ii};
                self.shearlets(:,:,ii+1) = TIshearlet(self,jj,kk,cone);
                
                
                
            end
            self.shearlets(:,:,1) = self.lowpassfilter;
            
            % Compute dual frame weights
            dualWeights(self);
            
            SFnorms(self);
            % If we want a Parseval frame, then normalize by the dual frame
            % weights
            if self.PreserveEnergy
                self.shearlets = bsxfun(@rdivide,self.shearlets,self.DualFrameWeights);
            end
            
            
            
            
        end
        
        
        
        
        
        function curr_shearlet = TIshearlet(self,sc,k,cone)
            % For a given scale, shear, and cone, compute the corresponding
            % shearlet
            curr_shearlet = zeros(self.height,self.width,self.Precision);
            hs = 2^sc*self.hor_scale_fac;
            vs = 2^sc*self.vert_scale_fac;
            ds = 2^((self.Alphas(sc+1)-1)*sc);
            rowfac1 = zeros(self.height,1,self.Precision);
            colfac1 = zeros(1,self.width,self.Precision);
            % The third dimension of self.hor_quo_grids, determines whether
            % or not the grids are periodized
            for kk = 1:size(self.hor_quo_grids,3)
                if strcmpi(self.TransformType,'real')
                    % Initialize to zeros
                    fac2 = zeros(size(self.hor_quo_grids,1),size(self.hor_quo_grids,2),self.Precision);
                    % For the real-valued case, we only have horizontal and
                    % vertical cones
                    if strcmpi(cone,"H")
                        col_first_fact1 = shearletSystem.haeuser_scale_function(self.x_values(kk,:)./hs,self.hor_shift_fac);
                        
                        % Symmetry for real-valued shearlets
                        col_first_fact2 = shearletSystem.haeuser_scale_function(-self.x_values(kk,:)./hs,self.hor_shift_fac);
                        % Row vector
                        colfac1 = col_first_fact1 + col_first_fact2;
                        tmp = self.hor_quo_grids(:,:,kk);
                        
                        if any(colfac1 > 0)
                            fac2(:,colfac1 > 0) = shearletSystem.haeuser_direction_function(tmp(:,colfac1 > 0)./ds-k*ones(size(tmp(:,colfac1>0))));
                        end
                    elseif strcmpi(cone,"V")
                        % Column vectors
                        row_first_fact1 = shearletSystem.haeuser_scale_function(self.y_values(:,kk)./vs,self.vert_shift_fac);
                        row_first_fact2 = shearletSystem.haeuser_scale_function(-self.y_values(:,kk)./vs,self.vert_shift_fac);
                        % Column vector
                        rowfac1 = row_first_fact1+row_first_fact2;
                        tmp = self.ver_quo_grids(:,:,kk);
                        % Setting empty equal to empty is OK.
                        if any(rowfac1 > 0)
                            fac2(rowfac1 > 0,:) = shearletSystem.haeuser_direction_function(tmp(rowfac1 > 0,:)./ds-k*ones(size(tmp(rowfac1>0,:))));
                        end
                    end
                    
                    
                    % when self.TransformType = 'complex'
                else
                    fac2 = zeros(self.height,self.width,self.Precision);
                    if strcmpi(cone,"R")
                        % Row vector
                        colfac1 = shearletSystem.haeuser_scale_function(self.x_values(kk,:)./hs,self.hor_shift_fac);
                        tmp = self.hor_quo_grids(:,:,kk);
                        if any(colfac1 > 0)
                            fac2(:,colfac1 > 0) = shearletSystem.haeuser_direction_function(tmp(:,colfac1 > 0)./ds-k*ones(size(tmp(:,colfac1>0))));
                        end
                    elseif strcmpi(cone,"T")
                        % Column vector
                        rowfac1 = shearletSystem.haeuser_scale_function(self.y_values(:,kk)./vs,self.vert_shift_fac);
                        tmp = self.ver_quo_grids(:,:,kk);
                        if any(rowfac1 > 0)
                            fac2(rowfac1 > 0,:) = shearletSystem.haeuser_direction_function(tmp(rowfac1 > 0,:)./ds-k*ones(size(tmp(rowfac1 > 0,:))));
                        end
                    elseif strcmpi(cone,"L")
                        % Row vector
                        colfac1 = shearletSystem.haeuser_scale_function(-self.x_values(kk,:)./hs,self.hor_shift_fac);
                        tmp = self.hor_quo_grids(:,:,kk);
                        if any(colfac1 > 0)
                            fac2(:,colfac1>0) = shearletSystem.haeuser_direction_function(tmp(:,colfac1 > 0)./ds-k*ones(size(tmp(:,colfac1 > 0))));
                        end
                    elseif strcmpi(cone,"B")
                        % Column vector
                        rowfac1 = shearletSystem.haeuser_scale_function(-self.y_values(:,kk)./vs,self.vert_shift_fac);
                        tmp = self.ver_quo_grids(:,:,kk);
                        if any(rowfac1 > 0)
                            fac2(rowfac1>0,:) = shearletSystem.haeuser_direction_function(tmp(rowfac1 > 0,:)./ds-k*ones(size(tmp(rowfac1 > 0,:))));
                        end
                    end
                    
                    
                end
                if any(strcmpi(cone,{'V','T','B'}))
                    curr_shearlet = curr_shearlet+bsxfun(@times,rowfac1,fac2);
                else
                    curr_shearlet = curr_shearlet+bsxfun(@times,colfac1,fac2);
                end
                
                
            end
            
            
            
            
        end
        
        function determineShearletNumber(self)
            
            kk = 0:self.NumScales-1;
            % This is currently only for a shearlet system. In the future,
            % we may support other systems where \alpha takes on other
            % values
            alph = self.Alphas(1);
            Nshears = 2*ceil(2.^(kk*(1-alph)))+1;
            if strcmpi(self.TransformType,'real')
                ns = sum(2*Nshears)+1;
            else
                ns = sum(4*Nshears)+1;
            end
            self.NumShearlets = cast(ns,self.Precision);
            
            %Initializing Cones,Scales, and Shears
            X = {'X'};
            self.Cones = repmat(X,self.NumShearlets,1);
            self.Scales = -1*ones(self.NumShearlets,1,self.Precision);
            self.Shears = zeros(self.NumShearlets,1,self.Precision);
            
        end
        
        function self = setProperties(self,varargin)
            % These defaults apply to both coder.target('MATLAB') and
            % codegen
            defaultTransformType = 'real';
            defaultImageSize = [128 128];
            defaultNumScales = NaN;
            validTransformType = {'real','complex'};
            validFilterBoundary = {'periodic','truncated'};
            defaultBoundary = 'periodic';
            defaultPrecision = 'double';
            validPrecision = {'double','single'};
            
            
            if coder.target('MATLAB')
                % Use input parser for MATLAB target
                p = inputParser;
                addParameter(p,'TransformType',defaultTransformType);
                addParameter(p,'ImageSize',defaultImageSize);
                addParameter(p,'FilterBoundary',defaultBoundary);
                addParameter(p,'NumScales',defaultNumScales);
                addParameter(p,'PreserveEnergy',false);
                addParameter(p,'Precision',defaultPrecision);
                parse(p,varargin{:});
                % Assign property values from parser results
                ttype = p.Results.TransformType;
                self.TransformType = validatestring(ttype,validTransformType,'shearletSystem','TransformType');
                self.ImageSize = p.Results.ImageSize;
                self.NumScales = p.Results.NumScales;
                self.PreserveEnergy = p.Results.PreserveEnergy;
                
                if ~any(strcmpi(p.UsingDefaults, 'NumScales'))
                    validateattributes(self.NumScales, ...
                        {'numeric'}, ...
                        {'scalar', 'real', 'finite', 'integer', ...
                            'positive', 'nonsparse'}, ...
                        'shearletSystem', 'NumScales');
                end
                filtbound = p.Results.FilterBoundary;
                self.FilterBoundary = validatestring(filtbound,validFilterBoundary,'shearletSystem','FilterBoundary');
                DataType = p.Results.Precision;
                self.Precision = validatestring(DataType,validPrecision,'shearletSystem','Precision');
                
                
                
            else
                parms = struct('TransformType',uint32(0),...
                    'ImageSize',uint32(0),...
                    'FilterBoundary',uint32(0),...
                    'NumScales',uint32(0),...
                    'PreserveEnergy',uint32(0),...
                    'Precision',uint32(0));
                popts = struct('CaseSensitivity',false, ...
                    'PartialMatching',true);
                
                pstruct = coder.internal.parseParameterInputs(parms,popts,varargin{:});
                ttype = ...
                    coder.internal.getParameterValue(pstruct.TransformType,defaultTransformType,varargin{:});
                self.TransformType = validatestring(ttype,validTransformType,'shearletSystem','TransformType');
                imsz = coder.internal.getParameterValue(pstruct.ImageSize,defaultImageSize,varargin{:});
                self.ImageSize = imsz;
                filtbound = coder.internal.getParameterValue(pstruct.FilterBoundary,defaultBoundary,varargin{:});
                self.FilterBoundary = validatestring(filtbound,validFilterBoundary,'shearletSystem','FilterBoundary');
                DataType = coder.internal.getParameterValue(pstruct.Precision,defaultPrecision,varargin{:});
                self.Precision = validatestring(DataType,validPrecision,'shearletSystem','Precision');
                ns = coder.internal.getParameterValue(pstruct.NumScales,defaultNumScales,varargin{:});
                Parseval = coder.internal.getParameterValue(pstruct.PreserveEnergy,false,varargin{:});
                self.PreserveEnergy = Parseval;
                self.NumScales = ns;
                
                
                
            end
            % Check ImageSize parameter
            
            validateattributes(self.ImageSize, ...
                {'double','single'}, ...
                {'vector', 'real', 'finite', 'numel', 2, 'integer', ...
                'positive', 'nonsparse'}, ...
                'shearletSystem', 'ImageSize');
            validateattributes(self.PreserveEnergy,{'logical'},...
                {'scalar'},'shearletSystem','PreserveEnergy');
            self.width = self.ImageSize(2)*ones(1,self.Precision);
            self.height = self.ImageSize(1)*ones(1,self.Precision);
            MaxNumScales = floor(log2(min(self.ImageSize)))-3;
            % If the number of scales is not set, set to the default
            % maximum number
            if isnan(self.NumScales)
                self.NumScales = MaxNumScales;
            end
            coder.internal.assert(self.NumScales >= 1,'Wavelet:shearletSystem:ImageTooSmall');
            % Set Alphas
            self.Alphas = 0.5*ones(self.NumScales,1);
            coder.internal.assert(numel(self.Alphas) == self.NumScales,'Wavelet:shearletSystem:AlphaMatch');
            coder.internal.errorIf(self.NumScales > MaxNumScales, ...
                   'Wavelet:shearletSystem:NumScalesTooLarge',min(self.ImageSize),MaxNumScales);
            end
        end
        
        
    
    
    methods(Static,Hidden=true)
        
        
        function psi1 = haeuser_scale_function(omega,translate)
            % Subtract translate. Need bsxfun for code generation 
            omega = bsxfun(@minus,omega,translate);         
            risingPart = sin(pi/2*meyeraux(omega-1));
            fallingPart = cos(pi/2*meyeraux(omega./2-1));
            psi1 = risingPart.*(omega > 1 & omega <= 2)+...
                fallingPart.*(omega > 2 & omega <=4);
        end
        
        function psi2 = haeuser_direction_function(omega)
            
            
            B = meyeraux(1+omega);
            C = meyeraux(1-omega);
            psi2 = sqrt(B).*(omega <= 0) + sqrt(C).*(omega > 0);
        end
        
        function phi = meyer_low_pass(omega)
            phi = meyeraux(4-2*abs(omega));            
        end
        
        
        
        function f = translate(f,k)
            f.Support = f.Support+k;
            f.LargeSupport = f.LargeSupport+k;
            
        end
        
        function f = scale(f,a)
            f.Support = f.Support.*a;
            f.LargeSupport = f.LargeSupport.*a;
            
        end
        
        
        
        function c = div0(a,b)
            % c = div0(a,b);
            % divide values in a by the values in b. If something nonfinite occurs, set
            % it equal to 0.
            
            % Use bsxfun for code generation
            c = bsxfun(@rdivide,a,b);
            c(~isfinite(c)) = 0;
        end
        
        function imdft = orthofft2(im)
            % Implementation of 2-D DFT as a unitary operator
            N = size(im,1)*size(im,2);
            imdft = fft2(im)./sqrt(N);
        end
        
        function im = orthoifft2(imdft,symmetry)
            % Implementation of 2-D DFT as a unitary operator
            N = size(imdft,1)*size(imdft,2);
            im = sqrt(N)*ifft2(imdft,symmetry);
            
        end
        
        function props = matlabCodegenNontunableProperties(~)
           props = {'Precision'}; 
        end
        
        
        
        
    end
    
    
end

