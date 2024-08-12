classdef liftingScheme
    %LIFTINGSCHEME Lifting scheme
    %   LS = liftingScheme creates the lifting scheme for the 'lazy'
    %   wavelet with normalization set to 1.
    %
    %   LS = liftingScheme('Wavelet',WNAME) creates the lifting scheme
    %   associated with the wavelet specified by the character vector,
    %   WNAME. WNAME is an orthogonal or biorthogonal wavelet and must be
    %   one of the wavelet names supported by LIFTINGSCHEME.
    %
    %   LS = liftingScheme('CustomLowpassFilter',{Lo}) uses the lowpass
    %   filter, Lo, associated with an orthogonal wavelet. Lo is a row or
    %   column vector.
    %
    %   LS = liftingScheme('CustomLowpassFilter',{LoPrimal,LoDual}) uses
    %   the two lowpass filters, LoPrimal and LoDual, associated with a
    %   biorthogonal wavelet. LoPrimal and LoDual are both row or column
    %   vectors. The lifting steps in LS are obtained from the
    %   factorization of the Laurent polynomials of the lowpass filters
    %   using Euclidean division algorithm. From all the possible
    %   factorizations, we picked the first one.
    %
    %   LS = liftingScheme('LiftingSteps',LIFTSTEPS,'NormalizationFactors',K)
    %   uses the specified lifting steps in LIFTSTEPS and normalization
    %   factor K. LIFTSTEPS is a column array, where each element of
    %   LIFTSTEPS is a liftingStep structure. The normalization factor K
    %   specify the diagonal elements of the 2-by-2 normalization matrix.
    %   The normalization factor can either be specified as a nonzero
    %   scalar K, or as a row vector of the form [K 1/K].
    %
    % LIFTINGSCHEME Properties:
    %
    %   Wavelet              - Wavelet name
    %   LiftingSteps         - Lifting steps of the lifting scheme
    %   NormalizationFactors - Normalization factors of the lifting scheme
    %   CustomLowpassFilter  - Lowpass filters for orthogonal and 
    %                          biorthogonal wavelet
    %
    % LIFTINGSCHEME Methods:
    %
    %   addlift             - Add lifting steps to an existing lifting
    %                         scheme
    %   deletelift          - Delete lifting steps from an existing
    %                         lifting scheme
    %   ls2filt             - Lifting scheme to wavelet filters
    %   disp                - Display lifting scheme
    %
    %   % Example 1:
    %   %   Obtain the lifting scheme for the 'db2' wavelet.
    %   LS = liftingScheme('Wavelet','db2');
    %
    %   % Example 2:
    %   %   Specify two lifting steps. Concatenate the lifting steps to 
    %   %   form an array. Specify the normalization factors. Create the 
    %   %   lifting scheme associated with the lifting steps.
    %
    %   els1 = liftingStep('Type','update','Coefficients',[-sqrt(3) 1],...
    %                   'MaxOrder',0);
    %
    %   els2 = liftingStep('Type','predict','Coefficients',...
    %                           [1 sqrt(3)/4+(sqrt(3)-2)/4],'MaxOrder',1);
    %
    %   ELS = [els1;els2];
    %
    %   K = [(sqrt(3)+1)/sqrt(2) (sqrt(3)-1)/sqrt(2)];
    %
    %   usrLS = liftingScheme('LiftingSteps',ELS,'NormalizationFactors',K);
    %
    %   % Example 3:
    %   %   Obtain the lowpass reconstruction filter and lowpass decomposition
    %   %   filter associated with the 'bior2.2' wavelet. Then obtain the 
    %   %   lifting scheme using the biorthogonal filters.
    %   [LoD,~,LoR,~] = wfilters('bior2.2');
    %   Lo = {LoR,LoD};
    %   LS = liftingScheme('CustomLowpassFilter',Lo);
    %
    %   See also liftingStep, lwt, ilwt, lwt2, ilwt2, laurentPolynomial.
    
    %   Copyright 2020-2021 The MathWorks, Inc.
    
    %#codegen
    
    properties
        % Wavelet name. The wavelet names supported are as follows: 
        %
        %Daubechies wavelet:
        % 'lazy','haar','db1','db2','db3','db4','db5','db6','db7','db8'.
        %
        %Symlet wavelet:
        % 'sym2','sym3','sym4','sym5','sym6','sym7','sym8'.
        %
        %Cohen-Daubechies-Feauveau wavelet:
        % 'cdf1.1','cdf1.3','cdf1.5','cdf2.2','cdf2.4','cdf2.6','cdf3.1',
        % 'cdf3.3','cdf3.5','cdf4.2','cdf4.4','cdf4.6','cdf5.1','cdf5.3',
        % 'cdf5.5','cdf6.2','cdf6.4','cdf6.6'.
        %
        %Coiflet wavelet:
        % 'coif1','coif2'.
        %
        %Biorthogonal wavelet:
        % 'bior1.1','bior1.3','bior1.5','bior2.2','bior2.4','bior2.6',
        % 'bior2.8','bior3.1','bior3.3','bior3.5','bior3.7','bior3.9',
        % 'bior4.4','bior5.5','bior6.8','bs3','9.7'.
        %
        %Reverse biorthogonal wavelet:
        % 'rbs3','r9.7','rbio1.1','rbio1.3','rbio1.5','rbio2.2',
        % 'rbio2.4','rbio2.6','rbio2.8','rbio3.1','rbio3.3',
        % 'rbio3.5','rbio3.7','rbio3.9','rbio4.4','rbio5.5','rbio6.8'
        Wavelet
        % An array of lifting steps. Can be specified in two ways: 1) You
        % can use the 'LiftingSteps' syntax to create a liftingScheme
        % object, or 2) You can specify a wavelet name or filters, and the
        % steps are generated based on that input.
        LiftingSteps
        % A nonzero scalar K or vector [K 1/K] containing the normalization
        % factor of the lifting scheme.
        NormalizationFactors
        % Lowpass filters for orthogonal and biorthogonal wavelets. For
        % orthogonal wavelets, CustomLowpassFilter is a vector containing
        % the coefficients of the associated lowpass filter. For
        % biorthogonal wavelets, CustomLowpassFilter is a 1-by-2 cell array
        % containing the associated lowpass filters.
        CustomLowpassFilter
    end
    
    methods
        
        function obj = liftingScheme(varargin)
            narginchk(0,4);
            
            if nargin > 0
                [obj,wv,LSTP,NF,LPF] = parseInputs(obj,varargin{:});
                %coder.varsize('LPF');
            
                if isempty(wv)
                    
                    coder.internal.assert(~(~isempty(LSTP) && ...
                        ~isempty(LPF)),'Wavelet:Lifting:LSFilter');
                    
                    coder.internal.assert(~(~isempty(NF) && ...
                        ~isempty(LPF)),'Wavelet:Lifting:LPFNF');
                    
                    coder.internal.assert(~(isempty(LSTP)&& ~isempty(NF)),...
                        'Wavelet:Lifting:UnsupportedNormalizationFactor');
                    
                    coder.internal.assert(~(~isempty(LSTP)&& isempty(NF)),...
                        'Wavelet:Lifting:UnsupportedNormalizationFactor');
                    
                    if ~isempty(LSTP) && ~isempty(NF)
                        
                        coder.internal.assert(isa(LSTP,'struct'),...
                            'Wavelet:Lifting:UnsupportedLiftingStep');                        
                        
                        LST = LSTP;
                        coder.varsize('LST',[Inf 1],[1 0]);
                        
                        obj.Wavelet = 'custom';
                        obj.LiftingSteps = LST;
                        obj.NormalizationFactors = NF;
                        obj.CustomLowpassFilter = [];
                        
                    elseif isempty(LSTP) && isempty(NF)
                                               
                        if ~isempty(LPF)
                            obj.Wavelet = 'custom';
                            obj = filt2LS(obj,LPF);
                        else
                            obj.Wavelet = 'lazy';
                            LSlazy = liftingStep();
                            obj.LiftingSteps = LSlazy;
                            obj.NormalizationFactors = [1 1];
                            obj.CustomLowpassFilter = [];
                        end
                    else
                        coder.internal.error(...
                         'Wavelet:Lifting:UnsupportedNormalizationFactor');
                    end
                else
                    coder.internal.assert(isempty(LPF),...
                        'Wavelet:Lifting:WaveNameFilter');
                    
                    coder.internal.assert(isempty(NF),...
                        'Wavelet:Lifting:WaveNameNF');
                    
                    coder.internal.assert(isempty(LSTP), ...
                        'Wavelet:Lifting:WaveNameUser');
                    
                    coder.internal.assert(~isnumeric(wv),...
                        'Wavelet:Lifting:UnsupportedWaveName');
                    
                    T = wavelet.internal.lifting.wavenames('all');
                    
                    if ~any(strcmpi(T.W, wv))
                        coder.internal.error('Wavelet:FunctionArgVal:Invalid_WavName');
                    end

                    [LSwv,K] = WaveName2LS(wv);
                    LS1 = LSwv;
                    coder.varsize('LS1',[Inf 1],[1 0]);
                    
                    coder.internal.assert(isstruct(LSwv) ,...
                        'Wavelet:Lifting:UnsupportedLiftingStep');
                    
                    obj.Wavelet = wv;
                    obj.LiftingSteps = LS1;                    
                    obj.NormalizationFactors = K;
                    obj.CustomLowpassFilter = [];
                end
            else
                obj.Wavelet = 'lazy';
                LSlazy = liftingStep();               
                obj.LiftingSteps = LSlazy;
                obj.NormalizationFactors = [1 1];
                obj.CustomLowpassFilter = [];
            end
        end
        
        function objN = addlift(obj,ELS,loc)
            %ADDLIFT Add elementary lifting steps
            %   LSN = ADDLIFT(LS,ELS) returns the lifting scheme LSN
            %   obtained by appending the array of elementary lifting steps
            %   ELS at the end of the lifting scheme LS. Each element of
            %   ELS is a LIFTINGSTEP.
            %
            %   LSN = ADDLIFT(LS,ELS,LOC) adds the elementary lifting steps
            %   ELS at the location LOC of the existing lifting scheme LS.
            %   LOC is an integer between 1 and N, where N is the number of
            %   lifting steps in the lifting scheme:
            %    LOC = 1                    : Prepends ELS to the lifting
            %                                  scheme LS.
            %    LOC = N                    : Appends ELS at the end of LS.
            %    (default)
            %    Otherwise                  : Inserts ELS after the 
            %                                 (LOC-1)-th step of the 
            %                                 lifting scheme LS.
            %
            %   % Example:
            %   % Create a lifting scheme associated with the 'db2' wavelet.
            %   LS = liftingScheme('Wavelet','db2');
            %   % Create an elementary lifting step.
            %   els = liftingStep('Type','predict','Coefficients',...
            %               [-sqrt(3) 1],'MaxOrder',0);
            %   % Insert the elementary lifting step at the second 
            %   % position.
            %   loc = 2;
            %   LSN = addlift(LS,els,loc);
            %
            %   See also liftingStep.
            
            narginchk(2,3);
            LSstp = obj.LiftingSteps;
            lOrg = numel(LSstp);          
            
            if nargin <3
                loc = lOrg+1;
            end
            
            validateattributes(loc,{'numeric'},...
                {'scalar','>=', 1, '<=', lOrg+1},'addlift','loc');
            
           Nsteps = getNSteps(LSstp,ELS);
           Stmp = struct('Type','','Coefficients',zeros(1,0),'MaxOrder',0);
           S = repmat(Stmp,Nsteps,1);
           coder.varsize('S.Type');
           coder.varsize('S.Coefficients');
           K = obj.NormalizationFactors;
           objN = liftingScheme('LiftingSteps',S,'NormalizationFactors',K);
           
           for ii = 1:Nsteps
               if ii <= loc-1
                   jj = ii;
                   S(ii).Type = LSstp(jj).Type;
                   S(ii).Coefficients = LSstp(jj).Coefficients;
                   S(ii).MaxOrder = LSstp(jj).MaxOrder;
               elseif ii >= (numel(ELS)+loc)
                   jj = ii-numel(ELS);
                   S(ii).Type = LSstp(jj).Type;
                   S(ii).Coefficients = LSstp(jj).Coefficients;
                   S(ii).MaxOrder = LSstp(jj).MaxOrder;
               else
                   jj = ii - (loc-1);
                   S(ii).Type = ELS(jj).Type;
                   S(ii).Coefficients = ELS(jj).Coefficients;
                   S(ii).MaxOrder = ELS(jj).MaxOrder;
               end
           end
           
           objN.LiftingSteps = S;
           objN.Wavelet = 'custom';
           objN.NormalizationFactors = K;
           objN.CustomLowpassFilter = [];
           
        end
                   
        function objD = deletelift(obj,loc)
            %DELETELIFT Remove elementary lifting steps
            %   LSN = DELETELIFT(LS) returns the lifting scheme LSN after
            %   deleting the last lifting step from LS.
            %
            %   LSN = DELETELIFT(LS,LOC) returns the lifting scheme LSN
            %   after deleting the elementary lifting steps at the
            %   positions specified by LOC from the lifting scheme LS. LOC
            %   is an integer or vector of integers and N, where N is the
            %   number of lifting steps in the lifting scheme.
            %
            %   % Example:
            %   % Create a lifting scheme associated with the db2 wavelet.
            %   LS = liftingScheme('Wavelet','db2');
            %   % Delete the elementary lifting steps at the second and
            %   % third positions. 
            %   loc = 2:3;
            %   LSN = deletelift(LS,loc);
            %   disp(LSN)
            %
            %   See also ADDFILT.
            
            narginchk(1,2);
            LSold = obj.LiftingSteps;
            l = numel(LSold);
            
            if nargin < 2
                loc = l;
            end
                        
            validateattributes(loc,{'numeric'},{'2d','>=', 1, '<=', l},...
                'deletelift','loc');
            
            loc = sort(loc,'ascend');
            validateattributes(loc,{'numeric'},{'increasing'},...
                'deletelift','loc');
            
            ind = 1:l;
            indN = setdiff(ind,loc);
            
            Nsteps = l-numel(loc);
            Stmp = struct('Type','','Coefficients',zeros(1,0),'MaxOrder',0);
            S = repmat(Stmp,Nsteps,1);
            coder.varsize('S.Type');
            coder.varsize('S.Coefficients');
            K = obj.NormalizationFactors;
            objD = liftingScheme('LiftingSteps',S,'NormalizationFactors',K);
            
            for ii = 1:Nsteps
                jj = indN(ii);
                S(ii).Type = LSold(jj).Type;
                S(ii).Coefficients = LSold(jj).Coefficients;
                S(ii).MaxOrder = LSold(jj).MaxOrder;
            end
            
            objD.LiftingSteps = S;
            objD.Wavelet = 'custom';
            objD.NormalizationFactors = K;
            objD.CustomLowpassFilter = []; 
        end
        
        function disp(obj)
            % DISP lifting scheme display
            %   disp(LS) displays the details of the lifting scheme LS. The
            %   details include the wavelet name, lifting steps, and
            %   normalization factors. For each lifting step, the type,
            %   Laurent polynomial coefficients, and maximum order of the
            %   corresponding Laurent polynomial.
            %
            %   % Example:
            %   LS = liftingScheme('Wavelet','db2');
            %   disp(LS)
            
            wv = obj.Wavelet;
            N1 = num2str(obj.NormalizationFactors(1),5);
            N2 = num2str(obj.NormalizationFactors(2),4);
            LS = obj.LiftingSteps;
            LO = obj.CustomLowpassFilter;
            
            [r,c] = size(LS);
            if iscell(LO) && (numel(LO) == 2)
                formatSpec = " \t Wavelet %12s : '%s' \n \t LiftingSteps %7s : [%s %s %s] liftingStep \n \t NormalizationFactors : [%s %s] \n \t CustomLowpassFilter %1s: %s %s %s cell array  \n\n";
                fprintf(formatSpec,'',wv,'',num2str(r),char(215),...
                    num2str(c),N1,N2,num2str(numel(LO)),char(215),...
                    num2str(numel(LO)))
            else
                
                if iscell(LO) && (numel(LO) == 1)
                    formatSpec = " \t Wavelet %13s : '%s' \n";
                    fprintf(formatSpec,'',wv)
                    formatSpec = "\t LiftingSteps %8s : [%s %s %s] liftingStep \n";
                    fprintf(formatSpec,'',num2str(r),char(215),...
                        num2str(c))
                    formatSpec = "\t NormalizationFactors %1s: [%s %s] \n";
                    fprintf(formatSpec,'',N1,N2)
                    formatSpec = "\t CustomLowpassFilter %1s : [ %s ] \n\n";
                    fprintf(formatSpec,'',num2str(LO{1}))
                else
                    formatSpec = " \t Wavelet %12s : '%s' \n \t LiftingSteps %7s : [%s %s %s] liftingStep \n \t NormalizationFactors : [%s %s] \n \t CustomLowpassFilter  : %s \n\n";
                    LOP = '[]';
                    fprintf(formatSpec,'',wv,'',num2str(r),char(215),...
                        num2str(c),N1,N2,LOP)
                end
            end
            n = length(obj.LiftingSteps);
            fprintf('\n Details of LiftingSteps :\n')
            
            for kk = 1:n
                disp(obj.LiftingSteps(kk))
            end
        end
        
        function [LOD,HID,LOR,HIR] = ls2filt(LS)
            %LS2FILT lifting scheme to wavelet filters
            %   [LOD,HID,LOR,HIR] = ls2filt(LS) uses the lifting scheme LS
            %   to obtain the corresponding four wavelet filters. The
            %   filters are as follows: decomposition lowpass filter LoD,
            %   decomposition high pass filter HiD, reconstruction lowpass
            %   filter LoR, and reconstruction highpass filter HiR.
            %
            %   % Example: Create two lifting schemes associated with the
            %   % 'db2' wavelet. Use the lowpass reconstruction filter to
            %   % create the first lifting scheme, and the wavelet name to
            %   % create the second scheme. Confirm the filters extracted
            %   % from both schemes are equal.
            %   [~,~,LoR,~] = wfilters('db2');
            %   LS = liftingScheme('CustomLowpassFilter',{LoR});
            %   LSW = liftingScheme('Wavelet','db2');
            %   [lod,hid,lor,hir] = ls2filt(LS);
            %   [lodw,hidw,lorw,hirw] = ls2filt(LSW);
            %   max(abs(lod-lodw))
            %   max(abs(hid-hidw))
            %   max(abs(lor-lorw))
            %   max(abs(hir-hirw))
            
            narginchk(1,1);
            wvstr = {'bior1.1','bior1.3','bior1.5','bior5.5',...
                'rbio1.1','rbio1.3','rbio1.5','rbio5.5'};
            Stp = LS.LiftingSteps;
            nS = numel(Stp);
            K = LS.NormalizationFactors;
            K1 = laurentPolynomial('Coefficients',K(1),'MaxOrder',0);
            K2 = laurentPolynomial('Coefficients',K(2),'MaxOrder',0);
            one = laurentPolynomial;
            zr = laurentPolynomial('Coefficients',0,'MaxOrder',0);
            MP = {K1 zr; zr K2};
            coder.varsize('MP');
         
            for ii = nS:-1:1
                tp = Stp(ii).Type;
                C = Stp(ii).Coefficients;
                m = Stp(ii).MaxOrder;
                lp = laurentPolynomial('Coefficients',C,'MaxOrder',m);
                
                switch tp
                    case 'update'
                        FACT = {one lp;zr one};
                        coder.varsize('FACT');
                    case 'predict'
                        FACT = {one zr;lp one};
                    otherwise
                        FACT = {one zr;zr one};
                end
                
                MA = MP;
                coder.varsize('MA');
                MP = prodCell(MA,FACT);
            end
            
            PM = laurentMatrix('Elements',MP);            
            PMinv = inverse(PM);
            H = dyadup(PM);
            HM = H.Elements;
            G = dyadup(PMinv);
            GM = G.Elements;
            
            % Decomposition
            Z  = laurentPolynomial('Coefficients',1,'MaxOrder',1);
            Z_1  = laurentPolynomial('Coefficients',1,'MaxOrder',-1);
            wv = LS.Wavelet;
            
            if strncmpi(wv,'db',1) || strncmpi(wv,'sy',2)|| ...
                    strcmpi(wv,'haar')
                
                switch wv
                    case {'db4','db5'}
                        
                        H0  = HM{1,1} + Z*HM{1,2};    % low dec LO_D
                        LOD = H0.Coefficients;
                        G0 = reflect(H0);
                        LOR = G0.Coefficients;
                        H1 = Z*reflect(negZ(H0));
                        HID = H1.Coefficients;
                        G1 = Z_1*negZ(H0);
                        HIR = G1.Coefficients;
                         
                    otherwise
                        
                        H0  = HM{1,1} + Z*HM{1,2};
                        LOD = H0.Coefficients;
                        G0 = reflect(H0);
                        LOR = G0.Coefficients;
                        H1 = -Z*reflect(negZ(H0));
                        HID = H1.Coefficients;
                        G1 = -Z_1*negZ(H0);
                        HIR = G1.Coefficients;
                end
            else
                switch wv
                    case wvstr
                        H0  = HM{1,1} + Z*HM{1,2};    % low dec LO_D
                        LOD = H0.Coefficients;
                        H0D = Z*H0;
                        H0_nP1 = reflect(H0D);
                        m0 = H0_nP1.MaxOrder;
                        c0 = H0_nP1.Coefficients;
                        n0 = (0:(length(c0)-1))+m0;
                        HIR = -((-1).^(n0)).*c0;
                        
                        G0  = GM{1,1} + Z_1*GM{2,1};    % High dec HI_D
                        LOR = G0.Coefficients;
                        G0_z = negZ(G0);
                        H1 = -Z_1*G0_z;
                        HID = -flip(H1.Coefficients);
                        
                    otherwise
                        H0  = HM{1,1} + Z*HM{1,2};    % low dec LO_D
                        LOD = H0.Coefficients;
                        H0D = Z*H0;
                        H0_nP1 = reflect(H0D);
                        m0 = H0_nP1.MaxOrder;
                        c0 = H0_nP1.Coefficients;
                        n0 = (0:(length(c0)-1))+m0;
                        HIR = ((-1).^n0).*c0;
                        
                        G0  = GM{1,1} + Z_1*GM{2,1};    % High dec HI_D
                        LOR = G0.Coefficients;
                        G0_z = negZ(G0);
                        H1 = -Z_1*G0_z;
                        HID = flip(H1.Coefficients);
                end
            end
        end
    end
        
   
    methods (Access = private)
        function [obj,wv,LS,NF,LO] = parseInputs(obj,varargin)
            
            % parser for the name value-pairs
            parms = {'Wavelet','LiftingSteps','NormalizationFactors',...
                'CustomLowpassFilter'};
            
            % Select parsing options.
            poptions = struct('PartialMatching','unique');
            pstruct = coder.internal.parseParameterInputs(parms,poptions,varargin{:});
            wv = coder.internal.getParameterValue(pstruct.Wavelet, [],...
                varargin{:});
            LS = coder.internal.getParameterValue(pstruct.LiftingSteps, [],...
                varargin{:});
            NF = coder.internal.getParameterValue(...
                pstruct.NormalizationFactors, [],varargin{:});
            LO = coder.internal.getParameterValue(...
                pstruct.CustomLowpassFilter, [],varargin{:});
            
        end    
        
        function obj = filt2LS(obj,LPF)
            
            validateattributes(LPF,{'cell'},...
                {'nonempty'},'liftingScheme','LPF');
            
            switch numel(LPF)
                case 1
                    validateattributes(LPF{1},{'numeric'},...
                        {'vector','nonnan','finite','real'},...
                        'liftingScheme','LPF');
                    
                    [~,~,Hs,Gs,~,~] = filters2lp(LPF);
                    
                    [LS,K] = lp2LS('o',Hs,Gs);
                    
                    for ii = 1:numel(LS)
                        if isempty(LS(ii).Coefficients)
                            LS(ii).Coefficients = zeros(1,1,'like',LPF{1});
                        end
                    end
                    
                    if isUnderlyingType(LPF{1},'single')
                        
                        Stmp = struct('Type','','Coefficients',....
                            zeros(1,0,'like',LPF{1}),'MaxOrder',0);
                        coder.varsize('S.Type');
                        coder.varsize('S.Coefficients');
                        LSsingle = repmat(Stmp,numel(LS),1);
                        for ii = 1:numel(LS)
                            LSsingle(ii).Type = LS(ii).Type;
                            LSsingle(ii).Coefficients = single(LS(ii).Coefficients);
                            LSsingle(ii).MaxOrder = single(LS(ii).MaxOrder);
                        end
                        obj.Wavelet = 'custom';
                        obj.LiftingSteps = LSsingle;
                        obj.NormalizationFactors = single(K);
                        obj.CustomLowpassFilter = LPF;
                    else
                        
                        obj.Wavelet = 'custom';
                        obj.LiftingSteps = LS;
                        obj.NormalizationFactors = K;
                        obj.CustomLowpassFilter = LPF;
                    end
                case 2
                    LoR = LPF{1,1};
                    LoD = LPF{1,2};
                    validateattributes(LoR,{'numeric'},...
                        {'vector','nonnan','finite','real'},...
                        'liftingScheme','LOR');
                    validateattributes(LoD,{'numeric'},...
                        {'vector','nonnan','finite','real'},...
                        'liftingScheme','LOD');
                    
                    [~,~,Hs,Gs,~,~] = filters2lp({LoR,LoD});
                    [LS,K] = lp2LS('b',Hs,Gs);
                    
                    if isUnderlyingType(LPF{1},'single')
                        
                        Stmp = struct('Type','','Coefficients',....
                            zeros(1,0,'like',LPF{1}),'MaxOrder',0);
                        coder.varsize('S.Type');
                        coder.varsize('S.Coefficients');
                        LSsingle = repmat(Stmp,numel(LS),1);
                        for ii = 1:numel(LS)
                            LSsingle(ii).Type = LS(ii).Type;
                            LSsingle(ii).Coefficients = single(LS(ii).Coefficients);
                            LSsingle(ii).MaxOrder = single(LS(ii).MaxOrder);
                        end
                        obj.Wavelet = 'custom';
                        obj.LiftingSteps = LSsingle;
                        obj.NormalizationFactors = single(K);
                        obj.CustomLowpassFilter = LPF;
                    else
                        
                        obj.Wavelet = 'custom';
                        obj.LiftingSteps = LS;
                        obj.NormalizationFactors = K;
                        obj.CustomLowpassFilter = LPF;
                    end
                otherwise
                    coder.internal.error('Wavelet:Lifting:InvalidInput');
            end
        end
    end
    
    % setter/getter methods
    methods
        function obj = set.Wavelet(obj,wv)
            T = wavelet.internal.lifting.wavenames('all');
            wvNm = T.W;
            coder.internal.assert(~isnumeric(wv),...
                'Wavelet:Lifting:UnsupportedWaveName',wv); 
            
            switch wv
                case 'custom'
                    obj.Wavelet = wv;
                case wvNm
                    obj.Wavelet = wv;
                otherwise
                     coder.internal.error(...
                         'Wavelet:FunctionArgVal:Invalid_WavName');
            end
            
        end
        
        function wv = get.Wavelet(obj)
            wv = obj.Wavelet;
        end
        
        function obj = set.LiftingSteps(obj,LS)
            
            coder.internal.assert(isstruct(LS),...
                'Wavelet:Lifting:UnsupportedLiftingStep');
            
            LS1 = LS;
            coder.varsize('LS1',[Inf 1],[1 0]);
            coder.varsize('LS1.Type');
            coder.varsize('LS1.Coefficients');
            
            if numel(LS) > 0
                for ii = 1:numel(LS1)
                    LS1(ii) = liftingStep('Type',LS(ii).Type,...
                        'Coefficients',LS(ii).Coefficients,'MaxOrder',...
                        LS(ii).MaxOrder);
                end
            end
            
            obj.LiftingSteps = LS1;
            
        end
        
        function LS = get.LiftingSteps(obj)
            LS = obj.LiftingSteps;
        end
        
        function obj = set.NormalizationFactors(obj,K)
            validateattributes(K,{'numeric'},{'2d','nonempty'},...
                'liftingScheme','K')
            if isscalar(K)
                obj.NormalizationFactors = [K 1/K];
            else
                if ((prod(K) - ones(1,1,'like',K)) <= sqrt(eps(underlyingType(K))))
                  obj.NormalizationFactors = K;
                else
                    coder.internal.error('Wavelet:Lifting:NFProd');
                end
            end
        end
        
        function K = get.NormalizationFactors(obj)
            K = obj.NormalizationFactors;
        end
        
        function obj = set.CustomLowpassFilter(obj,LPF)
            
            if isnumeric(LPF)
                LPF2 = {LPF};
                coder.varsize('LPF2');
            else
                LPF2 = LPF;
                coder.varsize('LPF2');
            end
            
            obj.CustomLowpassFilter = LPF2;
        end
        
        function LPF = get.CustomLowpassFilter(obj)
            LPF = obj.CustomLowpassFilter;
        end
    end       
end

% Obtain the liftingSteps and Normalization factors for the wavelet name
function [LST,K] = WaveName2LS(wvN)

LST = struct('Type','','Coefficients',zeros(1,0),'MaxOrder',0);
wv = char(wvN);
K = [1 1];

switch length(wv)
    case 3
        switch lower(wv)
            case 'bs3'
                [LST,K] = wavelet.internal.lifting.cdflift(4,2);
                coder.varsize('LST',[Inf 1],[1 0]);
            case '9.7'
                [LST,K] = wavelet.internal.lifting.biorlift(4,4);
            otherwise
                coder.internal.assert(strncmpi(wv,'db',2),...
                    'Wavelet:FunctionArgVal:Invalid_WavName');
                num = real(str2double(wv(3:end)));
                [LST,K] = wavelet.internal.lifting.dblift(num);
        end
    case 4
        switch lower(wv)
            case 'lazy'
                LST = liftingStep();
                K = [1 1];
            case 'haar'
                num = 1;
                [LST,K] = wavelet.internal.lifting.dblift(num);
            case 'rbs3'
                [LSr,K] = wavelet.internal.lifting.cdflift(4,2);
                LST = LSr;
                n = nStruct(LSr);
                
                for ii = 1:length(LSr)
                    if (ii <= n)
                        jj = n+1-ii;
                        m = LSr(ii).Coefficients;
                        LST(jj).Coefficients = m;
                    end
                end
                
            case 'r9.7'
                [LS,K] = wavelet.internal.lifting.biorlift(4,4);
                LST = coder.nullcopy(LS);
                coder.varsize('LST.Type');
                coder.varsize('LST.Coefficients');
                n = nStruct(LS);
                
                for ii = 1:length(LS)
                    if (ii <= n)
                        jj = n+1-ii;
                        LST(jj).Coefficients = LS(ii).Coefficients;
                        LST(jj).Type = LS(ii).Type;
                        LST(jj).MaxOrder = LS(ii).MaxOrder;
                    end
                end
                
            otherwise
                coder.internal.assert(strncmpi(wv,'sym',3),...
                    'Wavelet:FunctionArgVal:Invalid_WavName');
                num = real(str2double(wv(4:end)));
                [LST,K] = wavelet.internal.lifting.symlift(num);
        end
        
    case 5
        num = real(str2double(wv(5:end)));
        [LST,K] = wavelet.internal.lifting.coiflift(num);
        
    case 6
        Nd = real(str2double(wv(4)));
        Nr = real(str2double(wv(6)));
        [LST,K] = wavelet.internal.lifting.cdflift(Nd,Nr);
        
    case 7
        
        switch wv(1)
            case 'b'
                Nd = real(str2double(wv(5)));
                Nr = real(str2double(wv(7)));
                [LST,K] = wavelet.internal.lifting.biorlift(Nd,Nr);
                
            case 'r'
                Nd = real(str2double(wv(5)));
                Nr = real(str2double(wv(7)));
                [LST,K] = wavelet.internal.lifting.rbiorlift(Nd,Nr);
            otherwise
                coder.internal.error('Wavelet:FunctionArgVal:Invalid_WavName');
        end
    otherwise
        coder.internal.error('Wavelet:FunctionArgVal:Invalid_WavName');
end
end

function n = nStruct(LS)
n = 0;
for ii = 1:length(LS)
    if ~isempty(LS(ii).Type)
        n = n+1;
    end
end
end

function N = getNSteps(LS,els)
le = numel(els);
l = numel(LS);
N = l+le;
end

function Q = negZ(P)
%NEWVAR Change variable in a Laurent polynomial.
%   Q = NEGZ(P) returns the Laurent polynomial Q which obtained by doing a
%   change of variable.
%       '-z' : P(z) ---> P(-z)        (see MODULATE)
%
%   See also DYADDOWN, DYADUP, REFLECT.

C = P.Coefficients;
D = P.MaxOrder;
L = length(C);
pow = (D:-1:D-L+1);
S = (-1).^pow;
newC = S.*C;
Q = laurentPolynomial('Coefficients',newC,'MaxOrder',D);
end

function MP = prodCell(MA,MB)
%MTIMES Laurent matrices multiplication.
%   P = MTIMES(A,B) returns a Laurent matrix which is the
%   product of the two Laurent matrices A and B.

[rA,cA] = size(MA);
[rB,cB] = size(MB);

S = laurentPolynomial('Coefficients',0,'MaxOrder',0);

MP = cell(rA,cB);
coder.varsize('MP',[2 2],[1 1]);
coder.internal.assert(~(cA~=rB),'Wavelet:Lifting:InvalidMatDim', '*');

for i = 1:rA
    for j = 1:cB        
        switch cA
            case 1
                MP{i,j} = MA{i,1}*MB{1,j};
            case 2
                MP{i,j} = (MA{i,1}*MB{1,j}) + (MA{i,2}*MB{2,j});
            otherwise
                MP{i,j} = S;
        end
    end
end
end