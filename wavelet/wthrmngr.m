function varargout = wthrmngr(option,varargin)
%WTHRMNGR Threshold settings manager.
%   THR = WTHRMNGR(OPTION,METHOD,COEFS,SIZES) returns a global threshold or
%   level dependent thresholds for the critically sampled discrete wavelet
%   transform (DWT) coefficients, COEFS, and size vector, SIZES. COEFS and
%   SIZES are outputs of WAVEDEC or WAVEDEC2.
%    
%   For example:    [COEFS,SIZES] = wavedec(signal,level,wname) 
%                   [COEFS,SIZES] = wavedec2(image,level,wname)
%
%   Valid discrete wavelet transform options (OPTION) are: 'dw1dcompGBL', 
%   'dw2dcompGBL', 'dw1ddenoLVL', and 'dw2ddenoLVL'. Valid options for
%   METHOD depend on the OPTION input. See Discrete Wavelet 1D Options or
%   Discrete Wavelet 2D Options below for supported methods.
%
%   THR = WTHRMNGR(OPTION,METHOD,WPT) returns thresholds for the wavelet
%   packet tree object, WPT, when OPTION is 'wp1dcompGBL', 'wp2dcompGBL',
%   'wp1ddenoGBL', or 'wp2ddenoGBL'. See Wavelet Packet 1D Options or
%   Wavelet Packet 2D Options below for supported methods.
%
%   THR = WTHRMNGR(OPTION,METHOD,SWTDEC) returns thresholds for the
%   stationary wavelet transform matrix, SWTDEC, when OPTION is
%   'sw1ddenoLVL' or 'sw2ddenoLVL'. See Stationary Wavelet Transform 1D
%   Options or Stationary Wavelet Transform 2D Options below for supported
%   methods.
%
%   THR = WTHRMNGR(OPTION,METHOD,X) returns thresholds for the signal or
%   image, X, when OPTION is 'dw1dcompGBL', 'wp1dcompGBL', 'dw2dcompGBL',
%   or 'wp2dcompGBL' and METHOD is 'rem_n0'. Global thresholds in these
%   cases are determined using the Haar wavelet and are based only on the
%   finest-scale coefficients.
%
%   The complete list of supported methods (METHOD) are:
%
%   - 'scarcehi'            (see WDCBM or WDCBM2 with high
%                                predefined value of parameter M).
%   - 'scarceme'            (see WDCBM or WDCBM2 with medium
%                                predefined value of parameter M).
%   - 'scarcelo'            (see WDCBM or WDCBM2 with low
%                                predefined value of parameter M).
%   - 'sqtwolog'            (see THSELECT option 'sqtwolog'
%                                and see also WDEN).
%   - 'sqtwologuwn'         (see THSELECT option 'sqtwolog'
%                                and see also WDEN option 'sln').
%   - 'sqtwologswn'         (see THSELECT option 'sqtwolog'
%                                and see also WDEN option 'mln').
%   - 'rigrsure'            (see THSELECT option 'rigrsure'
%                                and see also WDEN).
%   - 'heursure'            (see THSELECT option 'heursure'
%                                and see also WDEN).
%   - 'minimaxi'            (see THSELECT option 'minimaxi'
%                                and see also WDEN).
%   - 'penalhi'             (see WBMPEN or WPBMPEN with high
%                                value of parameter ALPHA).
%   - 'penalme'             (see WBMPEN or WPBMPEN with medium
%                                value of parameter ALPHA).
%   - 'penallo'             (see WBMPEN or WPBMPEN with low
%                                value of parameter ALPHA).
%   - 'rem_n0'              this option returns a threshold
%                           close to 0, a typical THR value is
%                           median(abs(coefficients)).
%   - 'bal_sn'              this option returns a threshold
%                           such that the percentages of retained energy
%                           and number of zeros are the same.
%   - 'sqrtbal_sn'          this option returns a threshold
%                           equal to the square root of the value such that
%                           the percentages of retained energy and number
%                           of zeros are the same.
%
%   #################### Discrete Wavelet 1D Options: ####################
%   Compression using a global threshold: C are the 1D DWT coefficients
%   and L is the vector of coefficient lengths by level. Both C and L are
%   obtained from WAVEDEC.
%   
%   THR = WTHRMNGR('dw1dcompGBL','bal_sn',C,L)
%
%   Compression using level dependent thresholds: C are the 1D DWT
%   coefficients and L is the vector of coefficient lengths by level. Both
%   C and L are obtained from WAVEDEC. ALFA is a sparsity parameter (see
%   WDCBM).
%
%   THR = WTHRMNGR('dw1dcompLVL','scarcehi',C,L,ALFA)
%            ALFA must be such that 2.5 < ALFA < 10
%   THR = WTHRMNGR('dw1dcompLVL','scarceme',C,L,ALFA)
%            ALFA must be such that 1.5 < ALFA < 2.5
%   THR = WTHRMNGR('dw1dcompLVL','scarcelo',C,L,ALFA)
%            ALFA must be such that 1 < ALFA < 2
%
%   For the special case of 'rem_n0', WTHRMNGR accepts only the signal
%   input, X, and determines thresholds based on the finest-scale wavelet
%   coefficients obtained using the Haar wavelet.
%
%   THR = WTHRMNGR('dw1dcompGBL','rem_n0',X) 
%
%   1D DWT denoising using level dependent thresholds: [C,L] is the
%   critically sampled discrete wavelet decomposition of the signal, SCAL
%   defines the multiplicative threshold rescaling (see WDEN), and ALFA is
%   a sparsity parameter (see WBMPEN).
%
%   THR = WTHRMNGR('dw1ddenoLVL','sqtwolog',C,L,SCAL) 
%   THR = WTHRMNGR('dw1ddenoLVL','rigrsure',C,L,SCAL)
%   THR = WTHRMNGR('dw1ddenoLVL','heursure',C,L,SCAL) 
%   THR = WTHRMNGR('dw1ddenoLVL','minimaxi',C,L,SCAL)
%
%   THR = WTHRMNGR('dw1ddenoLVL','penalhi',C,L,ALFA)
%            ALFA must be such that 2.5 < ALFA < 10
%   THR = WTHRMNGR('dw1ddenoLVL','penalme',C,L,ALFA)
%            ALFA must be such that 1.5 < ALFA < 2.5
%   THR = WTHRMNGR('dw1ddenoLVL','penallo',C,L,ALFA)
%            ALFA must be such that 1 < ALFA < 2
%
%   ############## Stationary Wavelet Transform 1D Options: ###############
%   Denoising using level dependent thresholds: SWTDEC is the stationary
%   wavelet transform matrix of the noisy signal, SCAL defines the
%   multiplicative threshold rescaling (see WDEN) and ALFA is a sparsity
%   parameter (see WBMPEN).
%
%   THR = WTHRMNGR('sw1ddenoLVL',METHOD,SWTDEC,SCAL)
%   THR = WTHRMNGR('sw1ddenoLVL',METHOD,SWTDEC,ALFA) 
%   The options for METHOD are the same as in the 'dw1ddenoLVL' case.
%
%   ############# Discrete Wavelet 2D Options: ###########################
%   Compression using a global threshold:
%   C are the 2D DWT coefficients and S are the sizes of the coefficients
%   at each level. Both C and S are obtained from WAVEDEC2.
%
%   THR = WTHRMNGR('dw2dcompGBL','bal_sn',C,S)
%   THR = WTHRMNGR('dw2dcompGBL','sqrtbal_sn',C,S)
%
%   Compression using level dependent thresholds:
%   C are the 2D DWT coefficients and S are the sizes of the coefficients
%   at each level. ALFA is a sparsity parameter (see WDCBM2).
%
%   THR = WTHRMNGR('dw2dcompLVL','scarcehi',C,S,ALFA)
%         ALFA must be such that 2.5 < ALFA < 10
%   THR = WTHRMNGR('dw2dcompLVL','scarceme',C,S,ALFA)
%         ALFA must be such that 1.5 < ALFA < 2.5
%   THR = WTHRMNGR('dw2dcompLVL','scarcelo',C,S,ALFA)
%         ALFA must be such that 1 < ALFA < 2
%
%   For the special case of 'rem_n0', WTHRMNGR accepts only the image
%   input, X, and determines thresholds based on the finest-scale wavelet
%   coefficients for all details obtained using the Haar wavelet.
%
%   THR = WTHRMNGR('dw2dcompGBL','rem_n0',X)
%
%   Denoising using level dependent thresholds: C are the 2D DWT
%   coefficients and S are the sizes of the coefficients at each level.
%   SCAL defines the multiplicative threshold rescaling (see WDEN) and ALFA
%   is a sparsity parameter (see WBMPEN).
%
%   THR = WTHRMNGR('dw2ddenoLVL','penalhi',C,S,ALFA)
%         ALFA must be such that 2.5 < ALFA < 10
%   THR = WTHRMNGR('dw2ddenoLVL','penalme',C,S,ALFA)
%         ALFA must be such that 1.5 < ALFA < 2.5
%   THR = WTHRMNGR('dw2ddenoLVL','penallo',C,S,ALFA)
%         ALFA must be such that 1 < ALFA < 2
%   THR = WTHRMNGR('dw2ddenoLVL','sqtwolog',C,S,SCAL)
%   THR = WTHRMNGR('dw2ddenoLVL','sqrtbal_sn',C,S)
%
%   ############### Discrete Stationary Wavelet 2D options: ##############
%   Denoising using level dependent thresholds: SWTDEC is the 2D stationary
%   wavelet transform matrix of the noisy image. SCAL defines the
%   multiplicative threshold rescaling (see WDEN) and ALFA is a sparsity
%   parameter (see WBMPEN).
%
%   THR = WTHRMNGR('sw2ddenoLVL',METHOD,SWTDEC,SCAL)
%   THR = WTHRMNGR('sw2ddenoLVL',METHOD,SWTDEC,ALFA)
%   The options for METHOD are the same as in the 'dw2ddenoLVL' case.
%
%   ################### Discrete Wavelet Packet 1D options: #############
%   Compression using a global threshold:
%   WPT is the wavelet packet tree object for the signal.
%
%   THR = WTHRMNGR('wp1dcompGBL','bal_sn',WPT) 
%
%   For the special case of 'rem_n0', WTHRMNGR accepts only the signal
%   input, X, and determines thresholds based on the finest-scale wavelet
%   packet coefficients (identical to finest-scale DWT coefficients)
%   obtained using the Haar wavelet.
%
%   THR = WTHRMNGR('wp1dcompGBL','rem_n0',X) 
%
%   Denoising using a global threshold:
%   WPT is the wavelet packet tree object for the noisy signal.
%
%   THR = WTHRMNGR('wp1ddenoGBL','sqtwologuwn',WPT) 
%   THR = WTHRMNGR('wp1ddenoGBL','sqtwologswn',WPT) 
%   THR = WTHRMNGR('wp1ddenoGBL','bal_sn',WPT)
%   THR = WTHRMNGR('wp1ddenoGBL','penalhi',WPT)
%         see WPBMPEN with ALFA = 6.25
%   THR = WTHRMNGR('wp1ddenoGBL','penalme',WPT)
%         see WPBMPEN with ALFA = 2
%   THR = WTHRMNGR('wp1ddenoGBL','penallo',WPT)
%         see WPBMPEN with ALFA = 1.5
%
%  ######### Discrete Wavelet Packet 2D options: ###################
%   Compression using a global threshold:
%   WPT is the wavelet packet tree object for the image.
%
%   THR = WTHRMNGR('wp2dcompGBL','bal_sn',WPT) 
%   THR = WTHRMNGR('wp2dcompGBL','sqrtbal_sn',WPT)
%
%   For the special case of 'rem_n0', WTHRMNGR accepts only the image
%   input, X, and determines thresholds based on the finest-scale wavelet
%   packet coefficients obtained using the Haar wavelet.
%
%   THR = WTHRMNGR('wp2dcompGBL','rem_n0',X) 
%
%   Denoising using a global threshold:
%   WPT is the wavelet packet tree object for the noisy image.
%
%   THR = WTHRMNGR('wp2ddenoGBL','sqtwologuwn',WPT) 
%   THR = WTHRMNGR('wp2ddenoGBL','sqtwologswn',WPT) 
%   THR = WTHRMNGR('wp2ddenoGBL','sqrtbal_sn',WPT)
%   THR = WTHRMNGR('wp2ddenoGBL','penalhi',WPT)
%         see WPBMPEN with ALFA = 6.25
%   THR = WTHRMNGR('wp2ddenoGBL','penalme',WPT)
%         see WPBMPEN with ALFA = 2
%   THR = WTHRMNGR('wp2ddenoGBL','penallo',WPT)
%         see WPBMPEN with ALFA = 1.5
%
%   See also THSELECT, WBMPEN, WDCBM, WDCBM2, WDEN, WDENCMP,
%            WNOISEST, WPBMPEN, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Oct-98. Last
%   Revision: 20-Dec-2010. Copyright 1995-2020 The MathWorks, Inc.

if isStringScalar(option)
    option = convertStringsToChars(option);
end

% Convert any strings in varargin to char arrays
[varargin{:}] = convertStringsToChars(varargin{:});
meth = varargin{1};
validoptions = {'dw1dcompGBL','dw1dcompLVL','dw1ddenoLVL','dw1ddenoDEN',...
    'dw2dcompGBL','dw2dcompLVL','dw2ddenoLVL','wp1dcompGBL'...
    'wp2dcompGBL','wp1ddenoGBL','wp2ddenoGBL','sw1ddenoLVL','sw2ddenoLVL'};
option = validatestring(option,validoptions,'WTHRMNGR','OPTION');

switch meth
    case 'sqtwologswn'
        meth = 'sqtwolog';
        scal = 'sln';
    case 'sqtwologuwn'
        meth = 'sqtwolog';
        scal = 'one';
end

flgTYPE = option(1:2);
flgDIM  = str2double(option(3));
flgTOOL = option(5:8);
flgMODE = option(9:11);

if ~isequal(meth,'rem_n0')
    switch option
        case {'dw1dcompGBL','dw1dcompLVL','dw1ddenoLVL','dw1ddenoDEN'}
            level = length(varargin{3})-2;
            
        case {'dw2dcompGBL','dw2dcompLVL','dw2ddenoLVL'}
            level = size(varargin{3},1)-2;
            
        case {'wp1dcompGBL','wp1ddenoGBL','wp2dcompGBL','wp2ddenoGBL'}
            level = treedpth(varargin{2});
            
        case 'sw1ddenoLVL'
            level = size(varargin{2},1)-1;
            
        case 'sw2ddenoLVL'
            ND = ndims(varargin{2});
            switch ND
                case 3
                    level = (size(varargin{2},3)-1)/3;
                case 4
                    level = (size(varargin{2},4)-1)/3;
            end
    end
else
    if length(varargin)>2 , level = varargin{3}; end
end

switch option
    case 'sw1ddenoLVL'
        tmp = varargin{2};
        varargin{4} = varargin{3};
        varargin{2} = [];
        varargin{3} = size(tmp,2);
        for k=1:level
            cfs  = tmp(k,1:2^k:end);
            varargin{2} = [cfs , varargin{2}];
            varargin{3} = [length(cfs) , varargin{3}];
        end
        cfs = tmp(level+1,1:2^level:end);
        varargin{2} = [cfs , varargin{2}];
        varargin{3} = [length(cfs) , varargin{3}];
        
    case 'sw2ddenoLVL'
        tmp = varargin{2};
        % Handle RGB images
        rgb = ndims(tmp) == 4 && size(tmp,3) == 3;
        varargin{4} = varargin{3};
        varargin{2} = [];
        if rgb
            varargin{3} = size(tmp(:,:,:,1));
        else
        varargin{3} = size(tmp(:,:,1));
        end
        % Vector for 3 wavelet detail matrices
        numwaveletdetails = 3*level;
        matidx = 1:numwaveletdetails;
        matidx = matidx(:);
        matidx = reshape(matidx,level,3)';
        for k=1:level
            dvh = flipud(matidx(:,k));
            if rgb
                cfs = tmp(1:2^k:end,1:2^k:end,:,dvh(1));
                varargin{2} = [cfs(:)' , varargin{2}];
                cfs  = tmp(1:2^k:end,1:2^k:end,:,dvh(2));
                varargin{2} = [cfs(:)' , varargin{2}];
                cfs  = tmp(1:2^k:end,1:2^k:end,:,dvh(3));
                varargin{2} = [cfs(:)' , varargin{2}];
                varargin{3} = [size(cfs) ; varargin{3}];
            elseif ~rgb
            cfs  = tmp(1:2^k:end,1:2^k:end,dvh(1));
            varargin{2} = [cfs(:)' , varargin{2}];
            cfs  = tmp(1:2^k:end,1:2^k:end,dvh(2));
            varargin{2} = [cfs(:)' , varargin{2}];
            cfs  = tmp(1:2^k:end,1:2^k:end,dvh(3));
            varargin{2} = [cfs(:)' , varargin{2}];
            varargin{3} = [size(cfs) ; varargin{3}];
            end
            
        end
        if rgb
        cfs = tmp(1:2^level:end,1:2^level:end,:,end);
        elseif ~rgb
            cfs = tmp(1:2^level:end,1:2^level:end,end);
        end
        varargin{2} = [cfs(:)' , varargin{2}];
        varargin{3} = [size(cfs) ; varargin{3}];
        
end

switch flgTOOL
    %============================= COMPRESSION ==============================%
    case 'comp'
        switch flgMODE
            case 'GBL'
                switch meth
                    case 'rem_n0'
                        % sig = varargin{2};
                        %----------------------
                        varargout{1} = remNearZero(flgTOOL,flgTYPE,varargin{2});
                        
                    case {'bal_sn','sqrtbal_sn'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        %------------------------------
                        % tree or wptree = varargin{2};
                        % data = varargin{3};
                        %-------------------------------
                        if length(varargin)<3 , varargin{3} = []; end
                        [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
                            balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
                        varargout = {valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR};
                end
                
            case 'LVL'
                switch meth
                    case {'scarcehi','scarceme','scarcelo'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        % alfa  = varargin{4};
                        %----------------------
                        varargout{1} = scarceStrategies(meth,flgDIM,varargin{2:4});
                        
                    case 'rem_n0'
                        % sig = varargin{2};
                        % lev = varargin{3};
                        %-------------------
                        valTHR = remNearZero(flgTOOL,flgTYPE,varargin{2});
                        varargout{1} = expandTHR(valTHR,flgDIM,level);
                        
                    case {'bal_sn','sqrtbal_sn'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        %----------------------
                        valTHR = balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
                        varargout{1} = expandTHR(valTHR,flgDIM,level);
                end
        end
        %========================================================================%
        
        %============================= Denoising ===============================%
    case 'deno'
        switch flgMODE
            case 'GBL'        % WP only.
                % tree or wptree = varargin{2};
                % data = varargin{3};
                %-----------------------------
                if length(varargin)==2 , varargin{3} = []; end
                switch meth
                    case 'sqtwolog'
                        [valTHR,maxTHR,cfs] = fixedFormWP(flgDIM,varargin{2:3},scal);
                        varargout = {valTHR,maxTHR,cfs};
                        
                    case {'bal_sn','sqrtbal_sn'}
                        [valTHR,maxTHR,thresVALUES] = ...
                            balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
                        varargout = {valTHR,maxTHR,thresVALUES};
                        
                    case {'penalhi','penalme','penallo'}
                        [valTHR,maxTHR,cfs] = WPpenalStrategies(meth,flgDIM,varargin{2});
                        varargout = {valTHR,maxTHR,cfs};
                end
                
            case 'LVL'
                switch meth
                    case 'sqtwolog' % DW & SW only.
                        switch flgDIM
                            case 1
                                varargout{1} = fixedForm1D(varargin{2:4});
                                if strcmpi(option,'sw1ddenoLVL') || strcmpi(option,'sw2ddenoLVL')
                                    varargout{2} = varargin{2};
                                    varargout{3} = varargin{3};
                                end
                            case 2
                                varargout{1} = fixedForm2D(varargin{2:4},level);
                                if strcmpi(option,'sw1ddenoLVL') || strcmpi(option,'sw2ddenoLVL')
                                    varargout{2} = varargin{2};
                                    varargout{3} = varargin{3};
                                end
                        end
                        
                    case {'rigrsure','heursure','minimaxi'}  % DW1D & SW1D only.
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        % scal  = varargin{4};
                        %----------------------
                        coefs = detcoef(varargin{2:3},'all');
                        sigma = sigmaHAT(varargin{4},coefs);
                        varargout{1} = getTHR(meth,sigma,coefs);
                        
                    case {'penalhi','penalme','penallo'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        % alfa  = varargin{4};
                        %----------------------
                        valTHR = penalStrategies(meth,flgDIM,varargin{2:4});
                        varargout{1} = expandTHR(valTHR,flgDIM,level);
                        if strcmpi(option,'sw1ddenoLVL') || strcmpi(option,'sw2ddenoLVL')
                            varargout{2} = varargin{2};
                            varargout{3} = varargin{3};
                        end
                        
                    case {'scarcehi','scarceme','scarcelo'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        % alfa  = varargin{4};
                        %----------------------
                        varargout{1} = scarceStrategies(meth,flgDIM,varargin{2:4});
                        
                    case {'bal_sn','sqrtbal_sn'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        %----------------------
                        valTHR = balanceSparsityNorm(meth,flgTYPE,varargin{2:3});
                        varargout{1} = expandTHR(valTHR,flgDIM,level);
                end
                
                
            case 'DEN'  % estimation de densite
                switch meth
                    case 'globalth'
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        %----------------------
                        varargout{1} = GlobDens(varargin{2:3});
                        
                    case {'bylevth1'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        %----------------------
                        varargout{1} = LvldDens(varargin{2:3},1);
                        
                    case {'bylevth2'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        %----------------------
                        varargout{1} = LvldDens(varargin{2:3},2);
                        
                    case {'bylevsth'}
                        % coefs = varargin{2};
                        % sizes = varargin{3};
                        % alfa  = varargin{4};
                        %----------------------
                        varargout{1} = LvdsDens(varargin{2:4});
                end
        end
        %========================================================================%
        
end


%=============================================================================%
% INTERNAL FUNCTIONS
%=============================================================================%
%-----------------------------------------------------------------------------%
function [valTHR,maxTHR,thresVALUES,rl2SCR,n0SCR] = ...
    balanceSparsityNorm(meth,flgTYPE,A,B)

switch flgTYPE
    case {'dw','sw'}
        % coefs = A;
        % sizes = B;
        %-----------
        [thresVALUES,rl2SCR,n0SCR,imin] = wcmpscr(A,B);
        
    case 'wp'
        % WP_Tree = varargin{2};
        %-----------------------
        [thresVALUES,rl2SCR,n0SCR,imin] = wpcmpscr(A);
end
valTHR = thresVALUES(imin);
maxTHR = thresVALUES(end);
if isequal(meth,'sqrtbal_sn') , valTHR = min(sqrt(valTHR),maxTHR); end
%-----------------------------------------------------------------------------%
function valTHR = remNearZero(flgTOOL,flgTYPE,X)

switch flgTOOL
    case 'comp' 
        argTOOL = 'cmp';
    case 'deno' 
        argTOOL = 'den';
end
switch flgTYPE
    case 'dw' 
        argTYPE = 'wv';
    case 'wp' 
        argTYPE = 'wp';
end
valTHR = ddencmp(argTOOL,argTYPE,X);
%-----------------------------------------------------------------------------%
function valTHR = scarceStrategies(meth,flgDIM,coefs,sizes,alfa)

switch flgDIM
    case 1 
        M = [1 , 1.5 ,   2] * sizes(1);
    case 2 
        M = 4 * [1 , 4/3 , 8/3] * prod(sizes(1,:));
end
switch meth
    case 'scarcehi' 
        M = M(1);
    case 'scarceme' 
        M = M(2);
    case 'scarcelo' 
        M = M(3);
end
if flgDIM==1
    valTHR = wdcbm(coefs,sizes,alfa,M);
else
    valTHR = wdcbm2(coefs,sizes,alfa,M);
end
%-----------------------------------------------------------------------------%
function valTHR = penalStrategies(meth,flgDIM,coefs,sizes,sliBMVal)

switch flgDIM
    case 1
        sigma = wnoisest(coefs,sizes,1);
    case 2
        det   = detcoef2('compact',coefs,sizes,1);
        sigma = wnoisest(det);
end
switch meth
    case 'penalhi' 
        alfa = 5*(3*sliBMVal+1)/8;
    case 'penalme' 
        alfa = (sliBMVal+5)/4;
    case 'penallo' 
        alfa = (sliBMVal+3)/4;
end
valTHR = wbmpen(coefs,sizes,sigma,alfa);
%-----------------------------------------------------------------------------%
function [valTHR,maxTHR,cfs] = WPpenalStrategies(meth,flgDIM,wpt)

sliBMVal = 3;
switch meth
    case 'penalhi' 
        alfa = 5*(3*sliBMVal+1)/8;
    case 'penalme' 
        alfa = (sliBMVal+5)/4;
    case 'penallo' 
        alfa = (sliBMVal+3)/4;
end

% Compute sigma.
%---------------
depth = treedpth(wpt);
if depth==0 , valTHR = 0; return; end
switch flgDIM
    case 1
        cD1 = wpcoef(wpt,[1,1]);
        sigma = wnoisest(cD1);
    case 2
        cH1 = wpcoef(wpt,[1,1]);
        cV1 = wpcoef(wpt,[1,2]);
        cD1 = wpcoef(wpt,[1,3]);
        sigma = wnoisest([cH1(:)',cV1(:)',cD1(:)']);
end
cfs = read(wpt,'allcfs');
valTHR = wpbmpen(wpt,sigma,alfa);
maxTHR = max(abs(cfs));
valTHR = min(valTHR,maxTHR);
%-----------------------------------------------------------------------------%
function valTHR = expandTHR(valTHR,flgDIM,nbLEV)
switch flgDIM
    case 1 
        nbDIR = 1;
    case 2 
        nbDIR = 3;
end
valTHR = valTHR*ones(nbDIR,nbLEV);
%-----------------------------------------------------------------------------%
function s = sigmaHAT(scal,coefs)

level = length(coefs);
switch scal
    case 'one' 
        s = ones(1,level);
    case 'sln' 
        s = ones(1,level)*wnoisest(coefs{1});
    case 'mln' 
        s = wnoisest(coefs);
end
%-----------------------------------------------------------------------------%
function thr = getTHR(meth,s,coefs)

switch meth
    case 'minimaxi'
        nbcfs = 0;
        for k=1:length(s) , nbcfs = nbcfs+length(coefs{k}); end
        if nbcfs <= 32
            thr = 0*s;
        else
            thr = (0.3936 + 0.1829*(log(nbcfs)/log(2)))*s;
        end
        
    case {'rigrsure','heursure'}
        thr = zeros(size(s));
        for k=1:length(s)
            mk = max(coefs{k});
            if (mk<sqrt(eps)) || (s(k)<sqrt(eps)*mk)
                thr(k) = 0;
            else
                thr(k) = sureTHR(meth,coefs{k}/s(k));
            end
        end
        thr = thr.*s;
end
%-----------------------------------------------------------------------------%
function thr = sureTHR(meth,x)

x = x(:)';
n = length(x);
switch meth
    case 'rigrsure'
        sx2 = sort(abs(x)).^2;
        risks = (n-(2*(1:n))+(cumsum(sx2)+(n-1:-1:0).*sx2))/n;
        [~,best] = min(risks);
        thr = sqrt(sx2(best));
        
    case 'heursure'
        hthr = sqrt(2*log(n));
        eta = (norm(x).^2-n)/n;
        crit = (log(n)/log(2))^(1.5)/sqrt(n);
        if eta < crit
            thr = hthr;
        else
            thr = min(sureTHR('rigrsure',x),hthr);
        end
end
%-----------------------------------------------------------------------------%
function valTHR = fixedForm1D(coefs,sizes,scal)
scal = validatestring(scal,{'one','sln','mln'},'WTHRMNGR','SCAL');
coefs  = detcoef(coefs,sizes,'all');
sigma  = sigmaHAT(scal,coefs);
nbcfs = 0;
for k=1:length(coefs)
    nbcfs = nbcfs+length(coefs{k});
end
valTHR = sqrt(2*log(nbcfs))*sigma;
%-----------------------------------------------------------------------------%
function valTHR = fixedForm2D(coefs,sizes,scal,level)
scal = validatestring(scal,{'one','sln','mln'},'WTHRMNGR','SCAL');
% Note the following differs from the ordering of the coefficients
strDET = ['h','d','v'];
s = ones(3,level);
switch scal
    case 'one'
    case 'sln'
        det  = detcoef2('compact',coefs,sizes,1);
        s = wnoisest(det) * s;
    case 'mln'
        for k = 1:level
            det = detcoef2('compact',coefs,sizes,k);
            s(:,k) = wnoisest(det) * ones(3,1);
        end
end
valTHR = zeros(3,level);
for d = 1:3
    for k = 1:level
        det = detcoef2(strDET(d),coefs,sizes,k);
        univTHR     = sqrt(2*log(numel(det)));
        valTHR(d,k) = univTHR*s(d,k);
    end
end
%-----------------------------------------------------------------------------%
function [valTHR,maxTHR,cfs] = fixedFormWP(flgDIM,A,B,scal) %#ok<INUSL>

order = treeord(A);
nodes = (2:order)'; % nodes for details of level 1.
det = [];
for k =1:length(nodes)
    tmp = wpcoef(A,nodes(k));
    det = [det , tmp(:)']; %#ok<AGROW>
end
cfs = read(A,'allcfs');
univTHR = sqrt(2*log(length(det)));
switch scal
    case 'one' 
        s = 1;
    case 'sln' 
        s = wnoisest(det);
end
valTHR = s*univTHR;
maxTHR = max(abs(cfs));
valTHR = min(valTHR,maxTHR);
%-----------------------------------------------------------------------------%
function valTHR = GlobDens(coefs,sizes)

n = sizes(end);
J = size(sizes,2)-2;
coefs = coefs(sizes(1)+1:end);
valTHR = max(abs(coefs))*log(n)/sqrt(n);
valTHR = expandTHR(valTHR,1,J);
%-----------------------------------------------------------------------------%
function valTHR = LvldDens(coefs,sizes,flag)

J = size(sizes,2)-2;
valTHR = zeros(1,J);
for j=1:J
    d = detcoef(coefs,sizes,j);
    switch flag
        case 1 
            valTHR(j) = 0.4*max(abs(d));
        case 2 
            valTHR(j) = 0.8*max(abs(d));
    end
end
%-----------------------------------------------------------------------------%
function valTHR = LvdsDens(coefs,sizes,alfa)

J = size(sizes,2)-2;
valTHR = zeros(1,J);
for j=1:J
    d = detcoef(coefs,sizes,j);
    valTHR(j) = max(abs(d));
end
valTHR = valTHR * (alfa/(5-sqrt(eps)));
%-----------------------------------------------------------------------------%
function medad = med_ad(x) %#ok<DEFNU>

medad = median(abs(x-median(x)));
%-----------------------------------------------------------------------------%
%=============================================================================%


