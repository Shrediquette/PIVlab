classdef sensingDictionary
    %SENSINGDICTIONARY Sensing dictionary for sparse signal recovery
    % A = sensingDictionary creates a sensing dictionary that corresponds
    % to the 100-by-100 identity matrix.
    %
    % A = sensingDictionary('Size',SZ) creates a sensing dictionary
    % corresponding to the identity matrix eye(SZ). SZ can be either a
    % scalar or a two-element vector. By default, the value of 'Size' is
    % [100 100]. Elements in SZ must be positive integers. If SZ is a
    % scalar, the number of rows in the dictionary is set to SZ, and the
    % number of columns is calculated based on the type of dictionary. For
    % random dictionaries, SZ must be specified as a two-element vector.
    %
    % A = sensingDictionary(...,'Type',TYPE) creates a sensing dictionary
    % with columns corresponding to the basis types specified by TYPE, a
    % cell array of character vectors. Each element in TYPE must be one of
    % the following basis types:
    %       'eye' (default)
    %       'dct'
    %       'dwt'
    %       'fourier'
    %       'poly'   
    %       'rand'    
    %       'walsh'
    %
    % A = sensingDictionary(...,'Type',TYPE,'Name',W) creates a sensing
    % dictionary that corresponds to the random distribution or to a
    % wavelet specified by cell array of character vectors W.
    %
    % Valid options for entries in W depend on the dictionary basis type
    % specified in TYPE.
    % 
    % For 'rand', valid options are 'Gaussian' and 'Bernoulli'. The default
    % is 'Gaussian'.
    %
    % For 'dwt', valid options are the wavelets supported by MODWT. The
    % default is 'haar'.
    %
    % For all other types, 'Name' is not supported.
    %
    % A = sensingDictionary(...,'Level',L) creates a dictionary
    % corresponding to the details from the specified level of
    % decomposition L when the dictionary type is 'dwt'. The 'Level'
    % property is invalid for all other types. L can be a positive integer
    % or vector of positive integers. The number of nonzero elements in L
    % must be less than or equal to the number of dwt types. If
    % sensingDictionary 'Type' is a combination of wavelet and non-wavelet
    % bases, the level entry corresponding to the non-wavelet basis is set
    % to 0. See the documentation for more information. By default, the
    % dictionary corresponds to the level floor(log2(N)) details, where N =
    % A.Size(1), for the corresponding wavelet.
    %
    % A = sensingDictionary('CustomDictionary',PHI) creates a sensing
    % dictionary that corresponds to the user-specified matrix PHI.
    % Elements in PHI can be real- or complex-valued single- or double-
    % precision numbers. The sensing dictionary 'Type' is set to 'custom'
    % when PHI is specified.
    %
    % SENSINGDICTIONARY Properties:
    %
    % Size             - Size of the sensingDictionary
    % Type             - Dictionary basis type
    % Name             - Name of the wavelet or random distribution 
    % Level            - Level of decomposition
    % CustomDictionary - User-specified sensing dictionary matrix
    %
    % SENSINGDICTIONARY Methods:
    %
    % matchingPursuit - Recover sparse signal using matching pursuit                             
    % basisPursuit    - Recover sparse signal using basis pursuit
    % horzcat         - Concatenate two sensing dictionaries
    % subdict         - Extract submatrix of a sensing dictionary
    %
    %   % Example 1:
    %   %   Obtain the sensing dictionary of the form [D,I], where D is the
    %   %   DCT basis and I is the identity matrix.
    %   A = sensingDictionary('Type',{'dct','eye'});
    %
    %   % Example 2:
    %   %   Obtain the sensing dictionary with basis that corresponds to
    %   %   the level 3 sym4 wavelet details.
    %   load wecg
    %   A = sensingDictionary('Size',length(wecg),'Type',{'dwt'},...
    %                  'Name',{'sym4'},'Level',3);
    %
    %   % Example 3:
    %   %   Obtain the sensing dictionary that is a concatenation of the 
    %   %   level 2 db1 wavelet and DCT bases.   
    %   A = sensingDictionary('Size',200,'Type',{'dwt','dct'},...
    %                  'Name',{'db1'},'Level',[2 0]);

    %   Copyright 2021 The MathWorks, Inc.

    properties (Access = public)
        % Dictionary basis type. sensingDictionary supports the following
        % basis types:
        %
        % 'eye'    - dictionary corresponds to an identity matrix (default)
        % 'dct'    - dictionary matrix columns correspond to the discrete
        %           cosine transform basis
        % 'dwt'    - dictionary matrix columns correspond to a specific 
        %          wavelet basis from a certain level of decomposition
        % 'fourier'- dictionary matrix columns correspond to the Fourier 
        %           basis
        % 'poly'   - the k-th column of the dictionary matrix corresponds 
        %          to monomials of the form t.^(k-1), where t is the time
        %          interval specified by linspace(0,1,N) and k = 1,...,N.
        % 'rand'   - dictionary matrix entries are i.i.d. Gaussian (default) 
        %          or Bernoulli matrix
        % 'walsh'  - dictionary matrix entries are generated from Walsh
        %          code
        Type
        % Name of the wavelet or random distribution. For wavelet, Name is
        % a cell array of character vectors specifying the names of
        % orthogonal wavelets. Orthogonal wavelets are designated as type 1
        % wavelets in the wavelet manager. Valid built-in orthogonal
        % wavelet families begin with 'haar', 'dbN', 'fkN', 'coifN', or
        % 'symN', where N is the number of vanishing moments for all
        % families except 'fk'. For 'fk', N is the number of filter
        % coefficients. You can determine valid values for N by using
        % waveinfo. For example, waveinfo('db'). You can check if your
        % wavelet is orthogonal by using wavemngr('type',wname) to see if a
        % 1 is returned. For example, wavemngr('type','db2').
        %
        % If the sensing dictionary entries are i.i.d. random numbers, then
        % Name can be either 'Gaussian' or 'Bernoulli'. Name is not
        % supported for other sensingDictionary types.
        Name
        % Level of wavelet decomposition. Level is valid only if TYPE is
        % 'dwt'. In that case sensingDictionary columns correspond to the
        % wavelet of the specified LEVEL and TYPE.
        Level
        % User-specified sensing dictionary matrix. This property is only
        % set when you specify your own dictionary.
        CustomDictionary
    end

    properties (SetAccess = private) % read-only property
        % Size of the sensing dictionary. Size is a two-element vector [m,n],
        % where m is the number of rows and n is the number of columns in
        % the sensingDictionary.
        Size
    end

    properties(Access = private,Hidden)
        % Seed to reproduce the columns of random sensing dictionary
        % without needing to store the entire matrix. This property is set
        % when TYPE is RAND.
        Seed
    end

    properties(Access = private)
        % The number of columns for each dictionary type in the
        % sensingDictionary.
        nDict
    end

    methods
        function obj = sensingDictionary(varargin)
            narginchk(0,8);
            if (nargin == 0)
                obj.Size = [100,100];
                obj.Type = {'eye'};
                obj.Name = {''};
                obj.Level = 0;
                obj.CustomDictionary = [];            
                obj.Seed = 0;
                obj.nDict = 100;
            else
                obj = parseInputs(obj,varargin{:});
            end
        end
    end

    methods (Access = private)
        function obj = parseInputs(obj,varargin)

            % parser for the name value-pairs
            parms = {'Size','Type','Name', 'Level','CustomDictionary'};

            % Select parsing options.
            poptions = struct('PartialMatching','unique');
            pstruct = coder.internal.parseParameterInputs(parms,poptions,...
                varargin{:});

            tmpsz = coder.internal.getParameterValue(pstruct.Size, [],...
                varargin{:});
            tmptp = coder.internal.getParameterValue(pstruct.Type, [],...
                varargin{:});
            tmpName = coder.internal.getParameterValue(pstruct.Name, [],...
                varargin{:});
            tmplvl = coder.internal.getParameterValue(pstruct.Level, [],...
                varargin{:});
            usr = coder.internal.getParameterValue(...
                pstruct.CustomDictionary, [],varargin{:}); 

            if ~isempty(usr)
                 if ~isempty(tmptp) || ~isempty(tmpName) || ...
                        ~isempty(tmplvl) || ~isempty(tmpsz)
                    error(message('Wavelet:sensingDictionary:unsupportedTypeCustom'));
                end
                obj.CustomDictionary = usr;
                if isempty(tmptp)
                    obj.Type = {'custom'};
                    obj.Name = {''};
                    if istall(usr)
                        obj.Size = [];
                        obj.nDict = [];
                    else
                        obj.Size = size(usr);
                    end
                    obj.Level = 0;
                    obj.Seed = 0;
                    obj.nDict = size(usr,2);
                    return;
                end
            else
                obj.CustomDictionary = [];
            end

            obj.Type = tmptp;
            nTp = numel(obj.Type);
            
            % No. of rand entries in Type
            Nrnd = nnz(strncmpi(tmptp,{'rand'},1));
            Ncust = nnz(strncmpi(tmptp,{'custom'},1));

            if (Nrnd == 0) && ~isempty(tmpsz) && (nTp == 1) && (Ncust == 0)
                if ~isscalar(tmpsz) && (tmpsz(1)~=tmpsz(2))
                    error(message('Wavelet:sensingDictionary:nonrandSize'));
                end
            end

%             if (Nrnd ~=0) && isempty(tmpsz)
%                 error(message('Wavelet:sensingDictionary:randSize'));
%             end

            [tmpsz,obj] = validateSizebyType(obj,tmpsz);
            obj.Size = tmpsz;
            obj.Name = tmpName;
            obj.Level = tmplvl;

            Sd = zeros(1,nTp);
            for ii = 1:nTp
                if strcmpi(obj.Type{ii},'rand')
                    Sd(ii) = randi(10);
                end
            end
            obj.Seed = Sd;
        end
    end

    % setter/getter methods
    methods
        function obj = set.Type(obj,Tp)
            if isempty(Tp)
                obj.Type = {'eye'};
            else
                validateattributes(Tp,{'cell'},{'nonempty','nrows', 1},...
                    'sensingDictionary','Tp');

                    strType = {'eye','dwt','rand','dct',...
                        'fourier','custom','poly','walsh'};

                    for ii = 1:numel(Tp)
                        Tp{ii} = validatestring(Tp{ii},strType);
                    end
                obj.Type = Tp;
            end
         
            obj = ObjbyType(obj);
        end

        function obj = set.Size(obj,sz)
            if isempty(sz)
                obj.Size = [];
            else
                validateattributes(sz,{'numeric'},...
                    {'2d','nonempty','nonnan','finite','nonnegative'},...
                    'sensingDictionary','Size');
                obj.Size = sz;
            end
        end

        function obj = set.Name(obj,nm)
            nm = validateNamebyType(obj,nm);
            obj.Name = nm;
        end

        function obj = set.Level(obj,lvl)
            lvl = validateLevelbyType(obj,lvl);
            obj.Level = lvl;
        end

        function obj = set.CustomDictionary(obj,usr)
            if istall(usr)
                obj.CustomDictionary = usr;
            elseif isnumeric(usr)
                if isempty(usr)
                    obj.CustomDictionary = [];
                else
                    validateattributes(usr,{'numeric'},{'2d','nonempty',...
                        'nonnan','finite'},'sensingDictionary','usr');
                    obj.CustomDictionary = usr;
                end
            else
                error(message(...
                    'Wavelet:sensingDictionary:unsupportedCustomDictionary'));
            end

            if ~isempty(usr)
                obj = ObjbyCustomType(obj);
            end
        end

        function sz = get.Size(obj)
            sz = obj.Size;
        end

        function tp = get.Type(obj)
            tp = obj.Type;
        end

        function lvl = get.Level(obj)
            lvl = obj.Level;
        end

        function nm = get.Name(obj)
            nm = obj.Name;
        end
    end

    methods (Access = public)
        function Anew = horzcat(A1, A2)
            % HORZCAT Horizontal concatenation of two sensing dictionaries
            % Anew = horzcat(A1,A2) creates a custom sensingDictionary by
            % appending the columns in A2 after the columns in A1.
            % Dictionaries in A1 and A2 must have the same number of rows.
            % Depending on the inputs A1 and A2, their concatenation has
            % the following properties:
            %
            %   A1 sensingDictionary, A2 matrix
            %           - Anew.Type = {A1.type,'custom'}
            %           - Anew.customDictionary = [A1.customDictionary A2]
            %
            %   A1, A2 sensingDictionaries
            %           - Anew.Type = {A1.type,A2.type}
            %           - Anew.customDictionary
            %               = [A1.customDictionary A2.customDictionary] 
            %
            %   % Example:
            %   %   Obtain the sensing dictionary of the form [D I] by
            %   %   concatenating two sensing dictionaries. Here D is the
            %   %   DCT basis and I is the identity matrix.
            %   D = sensingDictionary('Size',2048,'Type',{'dct'});
            %   I = sensingDictionary('Size',2048);
            %   A = [D I];
            %
            %  See also SUBDICT.

            narginchk(2,2);

            if istall(A1.CustomDictionary) || istall(A2)
                error(message('Wavelet:sensingDictionary:unsupportedTall',...
                    'horzcat'));
            end
            
            m1 = A1.Size(1);
            n1 = A1.Size(2);

            if isnumeric(A2)
                validateattributes(A2,{'numeric'},{'2d','nonempty',...
                    'nonnan','finite'},'sensingDictionary','A2');
                m2 = size(A2,1);
                n2 = size(A2,2);
            
            elseif isa(A2,'sensingDictionary')
                if istall(A2.CustomDictionary)
                    error(message('Wavelet:sensingDictionary:unsupportedTall',...
                        'horzcat'));
                end
                m2 = A2.Size(1);
                n2 = A2.Size(2);
            else
                error(message('Wavelet:sensingDictionary:unsupportedHorzcat'));
            end

            if m1 ~= m2
                error(message('Wavelet:sensingDictionary:rowDimensionMismatch'));
            end

            n = n1+n2;

            if isa(A2,'sensingDictionary')

                newTp = appendCellstr(A1.Type,A2.Type);
                newNm = appendCellstr(A1.Name,A2.Name);
                newlvl = [A1.Level A2.Level];

                Anew = sensingDictionary('Size',[m1 n],'Type',newTp,...
                    'Name',newNm,'Level',newlvl);
                Anew.CustomDictionary = [A1.CustomDictionary A2.CustomDictionary];
                Anew.nDict =  [A1.nDict A2.nDict];
                Anew.Size = [m1 sum(Anew.nDict)];

            elseif isnumeric(A2)
                A2new = sensingDictionary('CustomDictionary',A2);
                newTp = appendCellstr(A1.Type,A2new.Type);
                newNm = appendCellstr(A1.Name,{''});
                newlvl = [A1.Level 0];

                Anew = sensingDictionary('Size',[m1 n],'Type',newTp,...
                    'Name',newNm,'Level',newlvl);
                Anew.CustomDictionary = [A1.CustomDictionary A2];
                Anew.nDict =  [A1.nDict size(A2,2)];
                Anew.Size = [m1 n];           
            end
        end

        function As = subdict(A,rowIndices, colIndices,indr)
            % SUBDICT Extract submatrix from sensing dictionary
            % Ar = subdict(A,rowIndices,colIndices) returns the submatrix
            % Ar that corresponds to the rows and columns specified by
            % rowIndices and colIndices.
            %
            %   % Example 1:
            %   %   Extract a submatrix from a random sensing dictionary.  
            %   A = sensingDictionary('Size',[2048 4096],'Type',{'rand'});
            %   Ar = subdict(A,1:2048,101:200);
            %
            %   % Example 2:
            %   %   Extract a submatrix from a sensingDictionary that 
            %   %   corresponds to 'db1' details at the specified level. 
            %   A = sensingDictionary('Size',100,'Type',{'dwt'});
            %   Ar = subdict(A,1:100,1:50);
            %
            %  See also HORZCAT.

            narginchk(1,4);
            if nargin < 2
                rowIndices = 1:(A.Size(1));
            end

            if nargin < 3
                colIndices = 1:(A.Size(2));
            end

            if nargin <4
                indr = [];
            end

            if any(strcmpi(A.Type,'custom')) && istall(A.CustomDictionary)
                error(message('Wavelet:sensingDictionary:unsupportedTall',...
                    'subdict'));
            end

            validateattributes(rowIndices,{'numeric'},{'2d','nonnan',...
                'real','positive','<=',(A.Size(1))},'subdict','rowIndices');

            validateattributes(colIndices,{'numeric'},{'2d','nonnan',...
                'real','positive','<=',(A.Size(2))},'subdict','colIndices');
           
            ind2 = cumsum(A.nDict);
            ind1 = [1 ind2(1:end-1)+1];

            N = A.Size(1);
            As = zeros(numel(rowIndices),numel(colIndices));

            for nn = 1:numel(A.Type)
                dictCol = ind1(nn):ind2(nn);
                [indI,ia,ib] = intersect(dictCol,colIndices);
                if ~isempty(indI)
                    switch A.Type{nn}
                        case 'dwpt'
                            if isempty(indr)
                                indr = 1;
                            end
                            Ar = getWPDict(rowIndices,ia,N,A.Level(nn),...
                                A.Name{nn},1);
                            As(1:length(rowIndices),ib) = Ar;
                        case 'custom'
                            usr = A.CustomDictionary;
                            As(1:length(rowIndices),ib) = usr(rowIndices,ia);
                        otherwise
                            Ar = getDictByType(A.Type{nn}, indI, rowIndices,...
                                ia,N, A.nDict(nn),A.Level(nn), A.Name{nn},...
                                A.Seed(nn));
                            As(1:length(rowIndices),ib) = Ar;
                    end
                end
            end
        end

        function [Xr, YI, I, R] = matchingPursuit(A,Y,varargin)
            % MATCHINGPURSUIT Recover sparse signal using matching pursuit
            % algorithm
            % [Xr, YI, I, R] = matchingPursuit(A,Y) recovers the sparse
            % signal Xr using the sensingDictionary A and sensor
            % measurement vector Y. Y can be a single- or double-precision
            % real- or complex-valued vector. The sensor measurements Y are
            % such that Y = AX, where X is a sparse signal. By default, the
            % sparse recovery algorithm is basic matching pursuit. The
            % residue R is calculated as R = Y-(A(:,I)*Xr(I,:)) = Y - YI,
            % where I is the support of Xr identified by the matching
            % pursuit algorithm, and YI is the best fit for Y corresponding
            % to the bases indexed by the elements of I. For matching
            % pursuit algorithms, the number of elements in I corresponds
            % to the number of iterations the algorithm needed before
            % termination.
            %
            % [...] = matchingPursuit(...,'Algorithm',ALG) recovers Xr by
            % using the matching pursuit algorithm ALG. Valid options for
            % ALG are as follows:
            % 	'BMP' 	    - Basic Matching pursuit (default)
            % 	'OMP' 		- Orthogonal matching pursuit
            % 	'WMP' 		- Weak matching pursuit
            %
            % [...] = matchingPursuit(...,'Algorithm','WMP','wmpcfs',WCFS)
            % recovers Xr by using the optimality factor WCFS for weak
            % orthogonal matching pursuit. WCFS is a positive scalar in
            % the interval (0,1]. This option is only valid when ALG is
            % 'WMP'. Default for WCFS is 0.6.
            %
            % [...] = matchingPursuit(...,'maxIterations',ITER) recovers Xr
            % by performing the pursuit algorithm for the maximum number of
            % iterations ITER (default 25).
            %
            % [...] = matchingPursuit(...,'maxerr',{NORME,ME}) recovers Xr
            % using the maximum error criteria specified in the cell array
            % entries NORME and ME. NORME is a character vector that
            % specifies the name of the norm used in the error computation.
            % Valid options for NORME are 'L1', 'L2', or 'Linf'. ME is a
            % positive scalar in the interval (0,100] and specifies the
            % maximum percentage of the relative admissible value. Default
            % for maximum error is {'L2',1}.
            %
            %   % Example:
            %   %   Load the wecg signal and create a sensingDictionary 
            %   %   with the DCT basis. 
            %   load wecg
            %   D = sensingDictionary('Size',length(wecg),'Type',{'dct'});
            %   % Obtain the best fit YI for the signal using orthogonal
            %   % matching pursuit.
            %   [Xr, YI, I, R] = matchingPursuit(D,wecg,'Algorithm','OMP');
            %   % Calculate the mean squared error for the reconstruction.
            %   norm(wecg-YI)
            %
            %  See also BASISPURSUIT.

            narginchk(2,10);

            if istall(Y) || istall(A.CustomDictionary)
                error(message('Wavelet:sensingDictionary:unsupportedTall',...
                    'matchingPursuit'));
            end

            validateattributes(Y,{'numeric'},{'vector','nonempty',...
                'nonnan','finite'},'matchingPursuit','Y');
           
            Y = Y(:);

            isYsingle = isa(Y,'single');
            Yd = double(Y);

            if length(Yd) ~= A.Size(1)
                error(message('Wavelet:sensingDictionary:sizeMismatchMP'));
            end

            parms = {'maxIterations','maxerr','Algorithm','wmpcfs'};

            % Select parsing options.
            poptions = struct('PartialMatching','unique');
            pstruct = coder.internal.parseParameterInputs(parms,poptions,...
                varargin{:});
            tmpit = coder.internal.getParameterValue(...
                pstruct.maxIterations, [], varargin{:});

            if isempty(tmpit)
                maxIt = 25;
            else
                validateattributes(tmpit,{'numeric'},{'scalar','real','nonnan',...
                    'finite','positive'},'matchingPursuit','maxIterations');
                maxIt = tmpit;
            end

            tmpME = coder.internal.getParameterValue(pstruct.maxerr, [],...
                varargin{:});

            if isempty(tmpME)
                ME = 1;
                namERR = 'L2';
            else
                validateattributes(tmpME,{'cell'},{'nonempty'...
                    },'matchingPursuit','tmpME');
                if numel(tmpME) == 1
                    if isnumeric(tmpME{1})
                        validateattributes(tmpME{1},{'numeric'},...
                            {'scalar','finite','nonnan','positive','<=',100},...
                            'matchingPursuit','maxError value');
                        ME = tmpME{1};
                        namERR = 'L2';
                    elseif ischar(tmpME{1}) || isstring(tmpME{1})
                        namERR = validatestring(tmpME{1},{'L1','L2',...
                            'Linf','NONE'});
                        ME = 10;
                    end
                else                    
                     validateattributes(tmpME{2},{'numeric'},...
                            {'scalar','finite','nonnan','positive','<=',100},...
                            'matchingPursuit','maxError value');
                     ME = tmpME{2};
                     namERR = validatestring(tmpME{1},{'L1','L2',...
                            'Linf','NONE'});
                end
            end

            tmpALG = coder.internal.getParameterValue(pstruct.Algorithm,...
                [],varargin{:});

            if isempty(tmpALG)
                ALG = 'BMP';
            else
                ALG = validatestring(tmpALG,{'BMP','OMP','WMP'},...
                    'sensingDictionary','tmpALG');
            end

            tmpwmpcfs = coder.internal.getParameterValue(...
                pstruct.wmpcfs, [], varargin{:});

            if ~strcmpi(ALG,'WMP') && ~isempty(tmpwmpcfs)
                error(message('Wavelet:sensingDictionary:unsupportedWMPCFS'))
            end

            if isempty(tmpwmpcfs)
                wmpcfs = 0.6;
            else
                validateattributes(tmpwmpcfs,{'numeric'},...
                            {'scalar','real','finite','nonnan','positive','<=',1},...
                            'matchingPursuit','maxError value');
                wmpcfs = tmpwmpcfs;
            end

            Tp = A.Type;
            if (numel(Tp) == 1) && strcmpi(Tp,'custom')
                if isnumeric(A.CustomDictionary)                    
                    [YI,R,COEFF,I,~,~] = wmpalg(ALG,Y,A.CustomDictionary,...
                        'itermax',maxIt,'maxerr',{namERR,ME});
                    Xr = zeros(A.Size(2),1);
                    Xr(I,:) = COEFF;
                    return;
                end
            end

            nVect = A.nDict;
            ind2 = cumsum(nVect);
            ind1 = [1 ind2(1:end-1)+1];

            R = Yd;
            N = length(R);
            N2Y = Yd'*Yd;
            J = 1:A.Size(2);
            tmpIOPT  = zeros(1,maxIt);
            tmpqual  = zeros(1,maxIt);
            YFIT  = zeros(size(R)) ;
            tmpCOEFF = zeros(A.Size(2),1);

            switch ALG
                case {'BMP'}
                    for it = 1:maxIt
                        % storage for the largest absolute coefficient for
                        % each type
                        cMATp = zeros(1,numel(Tp));
                        cmTp = cMATp;
                        indTp = cMATp;
                        indDict = cMATp;

                        for ii = 1:numel(Tp)
                            dictCol = ind1(ii):ind2(ii);
                            switch (Tp{ii})
                                case 'dwpt'
                                    [C,~] = getCoefsWp(R,A.Name{ii},A.Level(ii));
                                    [cMATp(ii),indTp(ii)] = max(abs(C));
                                    cmTp(ii) = C(indTp(ii));
                                case 'custom'
                                    Amat = A.CustomDictionary;
                                    nAr = sqrt(sum((Amat.^2),1));
                                    normAr = repmat(nAr,size(Amat,1),1);
                                    Amat = Amat./normAr;
                                    C = transpose(Amat)*R;
                                    [cMATp(ii),indTp(ii)] = max(abs(C));
                                    cmTp(ii) = C(indTp(ii));
                                otherwise
                                    C = getCoefs(R,Tp{ii},A.Name{ii},...
                                        A.Seed(ii),A.Level(ii),...
                                        [N,nVect(ii)],A,dictCol);

                                    % find the largest coefficient
                                    [cMATp(ii),indTp(ii)] = max(abs(C));
                                    cmTp(ii) = C(indTp(ii));
                            end
                         
                            % convert indTp into corresponding sensing
                            % matrix column index
                            indDict(ii) = dictCol(indTp(ii));
                        end

                        % Find which subdictionary Type produces the
                        % largest coefficient
                        [~,i] = max(cMATp);
                        kopt  = indDict(i);
                        tmpIOPT(it)	 = kopt;
                        tmpCOEFF(it) = cmTp(i);

                        % update support
                        J = setdiff(J,kopt);

                        % projection onto the basis corresponding to the
                        % largest coefficient
                        Z = getProjBMP(tmpCOEFF(it),i,kopt,R,N,A);
                        YFIT = YFIT + Z;
                        R = R-Z;
                        tmpqual(it)	= norm(tmpCOEFF)^2/N2Y;  % cumulated quality

                        if ~isempty(namERR)
                            switch upper(namERR)
                                case 'NONE' , curERR = Inf;
                                case 'L1'   , curERR = 100*(norm(R,1)/norm(Y,1));
                                case 'L2'   , curERR = 100*(norm(R)/norm(Y));
                                case 'LINF' , curERR = 100*(norm(R,Inf)/norm(Y,Inf));
                            end
                        end

                        if curERR < ME || isempty(J)
                            break;
                        end
                    end

                    I = tmpIOPT(1:it);
                    YI = YFIT;
                    Xr = zeros(A.Size(2),1);
                    Xr(I,:) = tmpCOEFF(1:it);

                    if isYsingle
                        Xr = single(Xr);
                        YI = single(YI);
                    end

                case {'OMP','WMP'}

                    for k = 1:maxIt
                        cMATp = zeros(1,numel(Tp));
                        cmTp = cMATp;
                        indTp = cMATp;
                        indDict = cMATp;
                        scalProd = zeros(A.Size(2),1);

                        for ii = 1:numel(Tp)
                            dictCol = ind1(ii):ind2(ii);

                            switch Tp{ii}
                                case 'dwpt'
                                    [C,indr] = getCoefsWp(R,A.Name{ii},A.Level(ii));
                                case 'custom'
                                    Amat = A.CustomDictionary;
                                    nAr = sqrt(sum((Amat.^2),1));
                                    normAr = repmat(nAr,size(Amat,1),1);
                                    Amat = Amat./normAr;
                                    C = transpose(Amat)*R;
                                    indr = [];
                                otherwise
                                    C = getCoefs(R,Tp{ii},A.Name{ii},...
                                        A.Seed(ii),A.Level(ii),...
                                        [N,nVect(ii)],A,dictCol);
                                    indr = [];
                            end

                            % find the largest coefficient
                            [cMATp(ii),indTp(ii)] = max(abs(C));
                            cmTp(ii) = C(indTp(ii));
                            
                            scalProd(dictCol,:) = abs(C);

                            % convert indTp into corresponding sensing
                            % matrix column index
                            indDict(ii) = dictCol(indTp(ii));
                        end

                        okALG = false;                     % false for OMP
                        if strcmpi(ALG,'WMP')
                            i = find(scalProd>wmpcfs*norm(R),1,'first');
                            if ~isempty(i) , okALG = true; end
                        end

                        % If ALG is 'OMP' or i = [], then the coefficients
                        % are calculated in the following way
                        if ~okALG , [~,i] = max(abs(scalProd)); 
                        end    % OMP and ...
                        kopt  = i;
                        tmpIOPT(k)	= kopt;                    % update support
                        tmpCOEFF(k) = scalProd(i);
                        J    = setdiff(J,kopt);
                        P = subdict(A,1:A.Size(1), tmpIOPT(1:k),indr);
                        TMP  = P\Yd;                            % least square estimate
                        R = Yd - P*TMP;
                        YFIT = P*TMP;
                        tmpqual(k)  = norm(YFIT)^2 / N2Y;

                        if ~isempty(namERR)
                            switch upper(namERR)
                                case 'NONE' , curERR = Inf;
                                case 'L1'   , curERR = 100*(norm(R,1)/norm(Y,1));
                                case 'L2'   , curERR = 100*(norm(R)/norm(Y));
                                case 'LINF' , curERR = 100*(norm(R,Inf)/norm(Y,Inf));
                            end
                        end

                        if (curERR < ME) || isempty(J)
                            break;
                        end
                    end

                    I = tmpIOPT(1:k);
                    COEFF = P\Yd;
                    YI  = P * COEFF;
                    Xr = zeros(A.Size(2),1);
                    Xr(I,:) = COEFF;

                    if isYsingle
                        Xr = single(Xr);
                        YI = single(YI);
                    end
            end
        end

        function [XBP,MSE,lambda] = basisPursuit(A,Y,varargin)
            % BASISPURSUIT Recover sparse signal using basis pursuit 
            % algorithm
            % [Xr, MSE, lambda] = basisPursuit(A,Y) recovers the sparse
            % signal Xr by solving the basis pursuit denoising problem:
            %   minimize 1/2 ||Y-AX||^2 + lambda ||X||_1
            %       X
            % where A is a sensingDictionary, Y is a measurement vector, X
            % is a solution vector, and lambda is the Lagrangian parameter.
            % Y can be a single- or double-precision real- or
            % complex-valued vector. For the recovered signal Xr,
            % BASISPURSUIT returns the minimum mean squared error MSE and
            % the corresponding Lagrangian parameter lambda.
            %
            % [...] = basisPursuit(...,'maxIterations',ITER) recovers Xr
            % using the maximum number of iterations ITER (default 200).
            %
            % [...] = basisPursuit(...,'RelTol',RELTOL) recovers Xr using
            % stopping criteria based on the specified relative tolerance
            % RELTOL. If unspecified, RELTOL defaults to 1e-4.
            %
            % [...] = basisPursuit(...,'AbsTol',ABSTOL) recovers Xr using
            % stopping criteria based on the specified absolute tolerance
            % ABSTOL. If unspecified, ABSTOL defaults to 1e-5.
            %
            % [...] = basisPursuit(...,'MaxErr',ME) recovers Xr that
            % satisfies ||Y-AXr||<= ME. If unspecified, the recovered
            % signal Xr corresponds to the minimizer of the objective
            % function 1/2 ||Y-AX||^2 + lambda ||X||_1.
            %
            % % Example:
            % %   Obtain the basis pursuit estimate for the wecg signal 
            % %   using the DCT sensing dictionary.
            % load wecg
            % D = sensingDictionary('Size',length(wecg),'Type',{'dct'});
            % % Obtain the best fit wecgR for the wecg signal using basis
            % % pursuit.
            % [XBP,MSE,lambda] = basisPursuit(D,wecg);
            % % Extract the sensingDictionary matrix.
            % A = subdict(D,1:(D.Size(1)), 1:(D.Size(2)));
            % wecgR = A*XBP;
            % % Calculate the mean squared error for the reconstruction.
            % norm(wecg-wecgR)
            %
            %  See also MATCHINGPURSUIT.

            narginchk(2,8);

            parms = {'maxIterations','AbsTol','RelTol','MaxErr'};

            % Select parsing options.
            poptions = struct('PartialMatching','unique');
            pstruct = coder.internal.parseParameterInputs(parms,poptions,...
                varargin{:});
            tmpit = coder.internal.getParameterValue(...
                pstruct.maxIterations, [],varargin{:});
            tmpAbsTol = coder.internal.getParameterValue(pstruct.AbsTol, ...
                [], varargin{:});
            tmpRelTol = coder.internal.getParameterValue(pstruct.RelTol, ...
                [], varargin{:});
            tmpME = coder.internal.getParameterValue(...
                pstruct.MaxErr, [],varargin{:});

            if isempty(tmpit)
                maxIterations = 200;
            else
                maxIterations = tmpit;
            end

            if isempty(tmpAbsTol)
                absTol = 1e-5;
            else
                validateattributes(tmpAbsTol,{'numeric'},{'scalar','real',...
                    'nonnan','finite','positive'},'basisPursuit','absTol');
                absTol = tmpAbsTol;
            end

            if isempty(tmpRelTol)
                relTol = 1e-4;
            else
                validateattributes(tmpRelTol,{'numeric'},{'scalar','real',...
                    'nonnan','finite','positive'},'basisPursuit','relTol');
                relTol = tmpRelTol;
            end

            if isempty(tmpME)
                ME = 1e-4;
            else
                validateattributes(tmpME,{'numeric'},{'scalar','real',...
                    'nonnan','finite','positive'},'basisPursuit','relTol');
                ME = tmpME;
            end

            if strcmpi(A.Type{1},'custom')
                Amat = A.CustomDictionary;
            else
                Amat = generateAmat(A);
            end
            
            if isnumeric(Amat)
                validateattributes(Y,{'numeric'},{'vector','nonempty',...
                    'nonnan','finite'},'basisPursuit','Y');
                isYSingle = isa(Y,'single');
                Y = Y(:);
                Yd = double(Y);

                [XBP, MSE,lambda] = ...
                    wavelet.internal.sensingDictionary.BPDN(Amat, Yd,...
                    'RelTol', relTol, 'AbsTol',absTol, ...
                                'MaxIter',maxIterations,'MaxErr',ME);

                if isYSingle
                    XBP = single(XBP);
                    MSE = single(MSE);
                    lambda = single(lambda);
                end

            elseif istall(Amat)
                [XBP,MSE,lambda] = ...
                    wavelet.internal.sensingDictionary.tallBPDN(Amat,Y,...
                    'RelTol',relTol, 'AbsTol',absTol,...
                    'MaxIter',maxIterations,'MaxErr',ME);
            end
        end
    end
end

% helper functions for matching pursuit
function C = getCoefs(R,Tp,Name,Seed,Level,sz,A,dictCol)
N = length(R);

switch Tp
    case 'dct'
        % inner product with dct basis
        C = wavelet.internal.sensingDictionary.dct(R);

    case 'fourier'
        % inner product with FFT basis
        C = fft(R)/sqrt(length(R));

    case 'walsh'
        Cw = wavelet.internal.sensingDictionary.fwht(R);
        % Cw will have treturns the coefficients to the next 2^n power. It
        % needs to be truncated to ensure that the length(C) = N.
        C = Cw(1:N,:);

    case 'dwt'
        w = modwt(R,Name,Level);
        C = w(end-1,:);

    case 'poly'
        Ar = subdict(A,1:N,dictCol);
        C = transpose(Ar)*R;

    case 'rand'
        rng(Seed);
        C = zeros(sz(2),1);

        for ii = 1:sz(2)   
            switch Name
                case 'Gaussian'
                    Ai = randn(N,1);
                    Ai = Ai/norm(Ai);
                case 'Bernoulli'
                    Ai = getBernoulliCols(N);
            end
            C(ii) = transpose(Ai)*R;
        end
    case 'eye'
        C = R;
end
end

function [C,indr] = getCoefsWp(R,Name,Level)
indr = 1;
if isreal(R)
    Wp  = modwpt(R,Name,Level);
    C = Wp(1,:);
else
    Wpr  = modwpt(real(R),Name,Level);
    Cr = Wpr(1,:);
    WpI  = modwpt(imag(R),Name,Level);
    CI = WpI(1,:);
    C = complex(Cr,CI);
    indr = 1;
end
end

function  Z = getProjBMP(cmTp,i,indTp,R,N,A)

Tp = A.Type;
nVect = A.nDict;
Z = zeros(size(R));
ind2 = cumsum(nVect);
ind1 = [1 ind2(1:end-1)+1];
usr = A.CustomDictionary;

for ii = 1:length(i)
    jj = i(ii);
    switch Tp{jj}
        case {'dct', 'fourier', 'walsh'}
            C = zeros(nVect(jj),1);
            C(indTp(ii)) = cmTp(ii);

            switch Tp{jj}
                case 'dct'
                    Ztmp =  wavelet.internal.sensingDictionary.idct(C);
                case 'fourier'
                    Ztmp =  sqrt(N)*ifft(C);
                case 'walsh'
                    Ztmpw =  wavelet.internal.sensingDictionary.ifwht(C);
                    % This ensures length(Ztmp) = N, instead of the nearest
                    % 2^n that is returned by ifwht.
                    Ztmp = Ztmpw(1:N,:);
            end
            Z = Z + Ztmp(1:N,:);

        case {'dwt', 'dwpt'}
            dictCol = ind1(jj):ind2(jj);
            [~,ia,~] = intersect(dictCol,indTp);

            switch Tp{jj}
                case 'dwt'
                    w = zeros(A.Level(jj)+1,N);
                    w(end-1,ia) = cmTp(ii);
                    Ztmp = imodwt(w,A.Name{jj});

                case 'dwpt'
                    wp = zeros(2^(A.Level(jj)),N);
                    if isreal(cmTp(ii))
                        wp(1,ia) = cmTp(ii);
                        Ztmp =  imodwpt(wp,A.Name{jj},A.Level(jj));
                    else
                        wpI = zeros(2^(A.Level(jj)),N);
                        wpI(1,ia) = imag(cmTp(ii));
                        wp(1,ia) = real(cmTp(ii));
                        Zrtmp =  imodwpt(wp,A.Name{jj},A.Level(jj));
                        ZItmp =  imodwpt(wpI,A.Name{jj},A.Level(jj));
                        Ztmp = complex(Zrtmp,ZItmp);
                    end
            end
            Ztmp = Ztmp(:);
            Z = Z + Ztmp;

        case 'rand'
            dictCol = ind1(jj):ind2(jj);
            [~,ia,~] = intersect(dictCol,indTp);
            rng(A.Seed(jj));

            for nn = 1:nVect(jj)
                switch A.Name{jj}
                    case 'Gaussian'
                        Ai = randn(N,1);
                        Ai = Ai/norm(Ai);
                    case 'Bernoulli'
                        Ai = getBernoulliCols(N);
                end
                if (nn == ia)
                    Ztmp = cmTp*Ai;
                    Z = Z + Ztmp;
                    break;
                end
            end

        case 'poly'
            Ar = subdict(A,1:N,indTp);            
            Ztmp = Ar*cmTp(ii);
            Z = Z + Ztmp;
            
        case 'eye'
            Ztmp = zeros(N,1);
            Ztmp(indTp(ii)) = cmTp(ii);
            Z = Z + Ztmp;

        case 'custom'
            % This enables us to return the projections for Custom
            % Dictionary.
            dictCol = ind1(jj):ind2(jj);
            [~,ia,~] = intersect(dictCol,indTp);
            Amat = usr(:,ia);
            Amat = Amat/norm(Amat);
            Ztmp = Amat*cmTp(ii);
            Z = Z + Ztmp;
    end 
    
end
end

% helper functions for subdict
function Ar = getDictByType(Type,colInd,rowIndices,ia,N,nCol,Level,Name,Seed)
    
switch Type
    case {'eye','walsh','dct','fourier'}
        Ic = zeros(N,numel(colInd));
        for ii = 1:numel(ia)
            jj = ia(ii);
            Ic(jj,ii) = 1;
        end

         switch Type
            case 'eye'
                Ar = Ic(rowIndices,:);
            case 'walsh'
                W = wavelet.internal.sensingDictionary.ifwht(Ic);
                Ar = W(rowIndices,:);
            case 'dct'
                As = wavelet.internal.sensingDictionary.idct(Ic);
                Ar = As(rowIndices,:);
            case 'fourier'
                As = ifft(Ic)*sqrt(N);
                Ar = As(rowIndices,:);
         end

    case 'poly'
        t = linspace(0,1,N)';
        k = (1:N)-1;
        kind = k(ia);
        tind = t(rowIndices);
        tr = repmat(tind,1,numel(kind));
        kr = repmat(kind,numel(tind),1);
        Ar = tr.^(kr);
        nAr = sqrt(sum((Ar.^2),1));
        normAr = repmat(nAr,size(Ar,1),1);
        Ar = Ar./normAr;

    case 'rand'
        rng(Seed);
        nR = numel(rowIndices);
        nC = numel(ia);
        Ar = zeros(nR,nC);
        cnt = 0;
        ia = sort(ia,'ascend');

        for nn = 1:nCol
            switch Name
                case 'Gaussian'
                    Ai = randn(N,1);
                case 'Bernoulli'
                    Ai = getBernoulliCols(N);
            end
            
            if ismember(nn,ia)
                Ac = Ai(rowIndices,:);
                cnt = cnt+1;
                Ar(rowIndices,cnt) = Ac/norm(Ac);
            end
        end

    case 'custom'
        if istall(A.CustomDictionary)
            Ar1 = A.CustomDictionary(rowIndices,ia);
            Ar = gather(Ar1);

        elseif isnumeric(A.CustomDictionary)
            Ar = A.CustomDictionary(rowIndices,ia);
        end

    case 'dwt'
        nR = numel(rowIndices);
        nC = numel(ia);
        Ar = zeros(nR,nC);
        zr = zeros(Level+1,N);
        for ii = 1:nC
            w = zr;
            w(end-1,ia(ii)) = 1;
            Ai = imodwt(w,Name);
            Ai = Ai(:);
            Ar(:,ii) = Ai(rowIndices,:);
        end 
end
end

function Ar = getWPDict(rowIndices,ia,N,Level,Name,indr)
nR = numel(rowIndices);
nC = numel(ia);
Ar = zeros(nR,nC);
WP = zeros(2^Level,N);

for ii = 1:nC
    indcol = ia(ii);
    WP(1,indcol) = 1;   
    Ai = imodwpt(WP,Name,Level);
    Ai = Ai(:);
    Ar(:,ii) = Ai(rowIndices,:)/norm(Ai(rowIndices,:));
    WP(indr,:) = zeros(1,N);
end
end

% helper function for appending entries of two cellstr 
function cellNew = appendCellstr(cell1,cell2)
cellNew = cell(1,(numel(cell1) +numel(cell2)));
for ii = 1:numel(cellNew)
    if (ii <= numel(cell1))
        cellNew{ii} = cell1{ii};
    else
        cellNew{ii} = cell2{ii-numel(cell1)};
    end
end
end

% helper function to generate the sensing matrix
function Amat = generateAmat(A)
Amat = subdict(A,1:(A.Size(1)), 1:(A.Size(2)));
end

function Ai = getBernoulliCols(N)
p = 0.5;
Ai = rand(N,1);
Ai = (2*(Ai<p)) - 1;
Ai = Ai/norm(Ai);
end

% validate properties by Type
function [Nmsz,obj] = validateSizebyType(obj,tmpsz)
Nmsz = [100 100];
tp = obj.Type;

if isempty(tp)
    if isempty(tmpsz)
        Nmsz = [];
        obj.nDict = 0;
    else
        validateattributes(tmpsz,{'numeric'},...
            {'2d','nonempty','nonnan','finite','positive'},...
            'sensingDictionary','Size');

        if isscalar(tmpsz)
            Nmsz = [tmpsz tmpsz];
            obj.nDict = tmpsz;
        else
            Nmsz = tmpsz;
            obj.nDict = tmpsz(1);
        end
    end
else
    nTp = numel(tp);
    nCol = zeros(1,nTp);
    if ~isempty(tmpsz)
        validateattributes(tmpsz,{'numeric'},...
            {'2d','nonempty','nonnan','finite','positive'},...
            'sensingDictionary','Size');
        Nmsz(1) = tmpsz(1);
    else
        Nmsz(1) = 100;
    end

    usr = obj.CustomDictionary;

    for ii = 1:nTp
        if strcmpi(tp{ii},'custom')
            if isnumeric(usr) && ismatrix(usr) && ~isempty(usr)
                nCol(ii) = size(usr,2);
                Nmsz(1) = size(usr,1);
            elseif istall(usr)
                nCol(ii) = [];
            end
        else
            switch tp{ii}
                case 'rand'
                    if isempty(tmpsz)
                       nCol(ii) = 100;
                    else
                        if isscalar(tmpsz)
                            error(message(...
                                'Wavelet:sensingDictionary:randSize'));
                        end
                        nCol(ii) = tmpsz(2);
                    end
                    
                case {'dwt','dwpt'}
                    if isempty(tmpsz)
                        nCol(ii) = 100;
                    else
                        nCol(ii) = tmpsz(1);
                    end
                case {'dct','fourier','walsh','poly','eye'}
                    if isempty(tmpsz)
                        nCol(ii) = 100;
                    else
                        nCol(ii) = tmpsz(1);
                    end
            end
        end
    end
    Nmsz(2) = sum(nCol);
    obj.nDict = nCol;
end

end

function NmNew = validateNamebyType(obj,Nm)
tmpsz = obj.Size;
randName = {'Gaussian','Bernoulli',''};
cntName = 0;
cntRand  = 0;
cntwv = 0;
Tp = obj.Type;

if isempty(Tp)
    if isempty(Nm)
        NmNew = {''};
    else
        error(message('Wavelet:sensingDictionary:unsupportedName'));
    end
else
    nTp = numel(Tp);

    % No. of wavelet entries in Type
    indwv = find(or(strncmpi(Tp,{'dwt'},3),strncmpi(Tp,{'dwpt'},3)));
    Nwv = length(indwv);

    % No. of rand entries in Type
    indrnd = find(strncmpi(Tp,{'rand'},1));
    Nrnd = length(indrnd);
    Ncust = nnz(strncmpi(Tp,{'custom'},1));
    n = Nwv+Nrnd;

    if ~isempty(Nm)
        validateattributes(Nm,{'cell'},{'nonempty','nrows', 1},...
            'sensingDictionary','Name');

        if (n == 0) && (numel(Nm) == 1) && ~strcmpi(Nm{1}, '')
            error(message('Wavelet:sensingDictionary:unsupportedName'));
        end

        if (Nrnd == 0) && ~isempty(tmpsz) && (nTp == 1) && (Ncust == 0)
            if ~isscalar(tmpsz) && (tmpsz(1)~=tmpsz(2))
                error(message('Wavelet:sensingDictionary:nonrandSize'));
            end
        end

        indNmRnd = find(ismember(Nm,{'Gaussian','Bernoulli'}));

        NmNew = cell(1,nTp);
        for ii = 1:nTp
            NmNew{ii} = '';
        end

        if (n ~= 0)
            if (numel(Nm) ~= nTp) && (numel(Nm) > n)
                error(message('Wavelet:sensingDictionary:invalidNameNum'));
            end

            for ii = 1:nTp
                switch Tp{ii}

                    case 'rand'                        
                        cntRand  = cntRand+1;

                        if isempty(Nm)
                            NmNew{ii} = 'Gaussian';
                        else
                            % These checks ensure that the rand types are
                            % set correctly
                            if numel(Nm) == nTp
                                if (numel(indNmRnd) == Nrnd)
                                    NmNew{ii} = validatestring(Nm{ii},...
                                        randName,'sensingDictionary',...
                                        'rand dictionary Name');
                                else
                                    if cntRand > numel(indNmRnd)
                                        NmNew{ii} = 'Gaussian';
                                    else
                                        NmNew{ii} = validatestring(Nm{(cntRand)},...
                                        randName,'sensingDictionary',...
                                        'rand dictionary Name');
                                    end
                                end
                            else
                                if (numel(indNmRnd) == Nrnd)
                                    NmNew{ii} = validatestring(Nm{indNmRnd(cntRand)},...
                                        randName,'sensingDictionary',...
                                        'rand dictionary Name');
                                else
                                    if cntRand > numel(indNmRnd)
                                        NmNew{ii} = 'Gaussian';
                                    else
                                        NmNew{ii} = validatestring(Nm{(cntRand)},...
                                        randName,'sensingDictionary',...
                                        'rand dictionary Name');
                                    end
                                end
                            end
                        end

                    case {'dwt','dwpt'}
                        cntwv = cntwv+1;

                        if isempty(Nm)
                            NmNew{ii} = 'db1';
                        else
                            if numel(Nm) == nTp
                                if isempty(Nm{ii})
                                    NmNew{ii} = 'db1';
                                else
                                    cntName = cntName+1;
                                    wtype = wavemngr('type',Nm{ii});
                                    if (wtype ~= 1)
                                        error(message('Wavelet:sensingDictionary:invalidWaveType',Nm{ii}));
                                    end
                                    NmNew{ii} = Nm{ii};
                                end
                            else
                                if cntwv > numel(Nm)
                                    NmNew{ii} = 'db1';
                                else
                                    cntName = cntName+1;
                                    wtype = wavemngr('type',Nm{cntName});
                                    if (wtype ~= 1)
                                        error(message('Wavelet:sensingDictionary:invalidWaveType',Nm{cntName}));
                                    end

                                    NmNew{ii} = Nm{cntName};
                                end
                            end
                        end

                    case {'dct','fourier','walsh','poly','eye'}

                        if (nTp == 1) || ...
                                ((numel(Nm) == nTp) && ~isempty(Nm{ii}))
                            error(message(...
                                'Wavelet:sensingDictionary:unsupportedName'));
                        end
                end
            end
        end
    else

        NmNew = cell(1,nTp);
        for ii = 1:nTp
            NmNew{ii} = '';
        end
        if (n ~= 0)
            % specify defaults
            for ii = 1:nTp
                switch Tp{ii}
                    case 'rand'
                        cntRand  = cntRand+1;
                        NmNew{ii} = 'Gaussian';

                    case {'dwt','dwpt'}
                        cntwv = cntwv+1;
                        NmNew{ii} = 'db1';
                end
            end
        end
    end
end
end

function Newlvl = validateLevelbyType(obj,tmplvl)
Tp = obj.Type;

% No. of wavelet entries in Type
indwv = union(find(strncmpi(Tp,{'dwt'},3)),find(strncmpi(Tp,{'dwpt'},3)));
Nwv = nnz(strncmpi(Tp,{'dwt'},3))+ nnz(strncmpi(Tp,{'dwpt'},3));

if ~Nwv && nnz(tmplvl)
    error(message(...
        'Wavelet:sensingDictionary:unsupportedNonWaveletLevel'));
end

if isempty(Tp)
    if ~isempty(tmplvl)
        error(message('Wavelet:sensingDictionary:unsupportedNonWaveletLevel'));
    end
    Newlvl = [];
else
    nTp = numel(Tp);
    Newlvl = zeros(1,nTp);
    if isempty(obj.Size)
        N = 100;
    else
        N = obj.Size(1);
    end

    if ~isempty(tmplvl)

        if N~=0
            validateattributes(tmplvl,{'numeric'},...
                {'2d','nonnegative','finite','nonnan','<=',floor(log2(N))},...
                'sensingDictionary','Level');
        end
        if (numel(tmplvl) ~= nTp)
            if numel(tmplvl) > Nwv && (Nwv ~= 0)
                error(message('Wavelet:sensingDictionary:invalidLevelNum'));
            end
        end

       lvlLoc = find(tmplvl);

        if numel(lvlLoc) == Nwv
            for ii = 1:Nwv
                kk = lvlLoc(ii);
                Newlvl(indwv(ii)) = tmplvl(kk);
            end
        else
            for ii = 1:Nwv
                if (ii <= numel(lvlLoc))
                    kk = lvlLoc(ii);
                    Newlvl(indwv(ii)) = tmplvl(kk);
                else
                    Newlvl(indwv(ii)) = floor(log2(N));
                end
            end
        end 
    else
        for ii = 1:Nwv
            jj = indwv(ii);
            switch Tp{jj}
                case {'dwt','dwpt'}
                    Newlvl(jj) = floor(log2(N));
            end
        end

    end
end
end

function obj = ObjbyType(obj)
Tp = obj.Type;
Nm = Tp;
sz = obj.Size;

if isempty(sz)
    N = 100;
    obj.Size = [N N];
else
    N = sz(1);
end

nCol = zeros(1,numel(Tp));
lvl = nCol;
Sd = nCol;
mat = [];

for ii = 1:numel(Tp)
    switch Tp{ii}
        case {'dct','fourier','walsh','poly','eye'}
            Nm{ii} = '';
            nCol(ii) = N;
            obj.CustomDictionary = [];
        case 'rand'
            Nm{ii} = 'Gaussian';
            nCol(ii) = N;
            Sd(ii) = randi(10);
            obj.CustomDictionary = [];
        case {'dwt','dwpt'}
            Nm{ii} = 'db1';
            lvl(ii) = floor(log2(N));
            nCol(ii) = N;
            obj.CustomDictionary = [];
            obj.Size = [N sum(nCol)];
        case {'custom'}
            Nm{ii} = '';            
            usr = obj.CustomDictionary;
            if isnumeric(usr) && ismatrix(usr)
                mat = [mat usr]; %#ok<AGROW>
            end

            nCol(ii) = (istall(usr)*0) + (isnumeric(usr)*size(usr,2));
    end
end

if (numel(Tp) == 1) && strcmpi(Tp{1},'custom')
    if istall(usr)
        obj.Size = [];
        nCol = [];
    elseif isnumeric(usr)
        obj.Size = size(usr);
        nCol = obj.Size(2);
    end
else
     obj.Size = [N sum(nCol)];
end

obj.Name = Nm;
obj.Level = lvl;
obj.Seed = Sd;
obj.nDict = nCol;
end

function obj = ObjbyCustomType(obj)
indCust = find(strncmpi(obj.Type,'custom',1));
nCust = nnz(indCust);

if (isempty(obj.Type) && ~isempty(obj.CustomDictionary)) ||((nCust == 0) && ~isempty(obj.CustomDictionary)) 
    obj.Type = {'custom'};
end
end