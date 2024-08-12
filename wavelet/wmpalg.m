function [YFIT,R,COEFF,IOPT,qual,X] = wmpalg(AlgNAM,Y,varargin)
%WMPALG Matching Pursuit
%   Matching Pursuit computes the adaptive greedy decomposition
%   of a vector in a dictionary.
%
%   YFIT = WMPALG(ALGNAM,Y,X) returns an adaptive greedy approximation of Y
%   in the dictionary X.
%
%   ALGNAM is a string giving the name of the algorithm.
%   Valid values for ALGNAM are:
%     - 'BMP' for (Basic) Matching Pursuit
%     - 'OMP' Orthogonal Matching Pursuit
%     - 'WMP' Weak Matching Pursuit
%   Y is the N-by-1 vector to be modeled.
%   X is a N-by-P dictionary matrix. The columns of X are scaled to have L2
%   unit norm. You can build X with the WMPDICTIONARY function.
%
%   [YFIT,R,COEFF,IOPT,QUAL,X] = WMPALG(...), returns:
%     - R the residual Y-YFIT
%     - IOPT the vector of indices of the retained
%       columns of X
%     - COEFF the corresponding vector of coefficients
%     - QUAL the proportion of retained energy
%
%   By default the algorithm stops after at most 25 iterations.
%   The stopping rule can be relaxed using the following
%   syntax:
%     [...] = WMPALG(...,'PropName1',PropValue1,...
%                         'PropName2',PropValue2,...)
%       'itermax': PropValue is a positive integer fixing the maximum
%                  number of iterations of the decomposition algorithm.
%       'maxerr' : PropValue is a cell array which contains the name of
%                  the norm used in the error computation and the maximum
%                  percentage of the relative admissible value. The
%                  available error names are 'L1', 'L2' or 'Linf'.
%
%   When ALGNAM is equal to 'WMP', you may specify a real coefficient, CFS,
%   in the interval (0,1] (see the algorithm section in the algorithm
%   section in the documentation). If unspecified, CFS defaults to 0.60.
%     [...] = WMPALG(...,'wmpcfs',CFS)
%
%   Instead of providing the dictionary X as an input argument,
%   you can generate the dictionary by using
%     [...] = WMPALG(ALGNAM,Y,'PropName1',PropValue1,...
%                            'PropName2',PropValue2,...)
%   and specifying the parameters corresponding to the property names
%   'LstCpt', 'addbeg', and 'addend' (see WMPDICTIONARY for more details).

%   Copyright 1995-2021 The MathWorks, Inc.

% Default and initialization for parameters.
%-------------------------------------------

narginchk(3,14);
validstr = {'BMP','OMP','WMP'};
AlgNAM = validatestring(AlgNAM,validstr);
AlgNAM = upper(AlgNAM);
onceFLAG = false;

% Check input arguments.
Y = Y(:);
validateattributes(Y,{'numeric'},{'2d','finite','nonnan'},'wmpalg','Y');
N = length(Y);
isMatDict =  false;

if isnumeric(varargin{1})
    validateattributes(varargin{1},{'numeric'},{'2d','finite','nonnan'},...
        'wmpalg','varargin{1}');
    X = varargin{1};
    isMatDict = true;
end

if isnumeric(varargin{1}) && ismatrix(varargin{1})
    X = varargin{1};
    varargin = varargin(2:end);
    isMatDict = true;
end

[itermax,namERR,valERR,wmpcfs,argDICT,isbeg,isend] = parseArgs(N,varargin{:});

indxlst = find(strcmpi(varargin,'lstcpt'));


% Initialization of the dictionnary.
%-----------------------------------
if isMatDict && ~isempty(argDICT)
    error(message('Wavelet:FunctionInput:Invalid_ArgDic'))
end

if ~isMatDict
    if ~isempty(indxlst) 
        if isempty(isbeg) && isempty(isend)
            [X,~] = wmpdictionary(N,varargin{indxlst:indxlst+1});
        elseif ~isempty(isbeg)
            [X,~] = wmpdictionary(N,varargin{indxlst:indxlst+1},'addbeg',isbeg);
        elseif ~isempty(isend)
            [X,~] = wmpdictionary(N,varargin{indxlst:indxlst+1},'addend',isend);
        end
    else
        [X,~] = wmpdictionary(N);
    end
end

p = size(X,2);

if ~(itermax>0 && isequal(itermax,fix(itermax)))
    itermax = min([p,25]);
end

J     = 1:p;                                  % index of remaining vectors
                                              % in the dictionary
YFIT  = zeros(N,1) ;
tmpqual  = zeros(1,itermax);
tmpIOPT  = zeros(1,itermax);                  % Index of the selected vectors

% Normalization of columns of X.
S = sum(X.*X).^0.5;
X = X./repmat(S,N,1);                         % the columns norm are set to 1
N2Y = Y'*Y;                                   % square norm
R = Y;                                        % initialization of residual
switch AlgNAM
    case 'BMP'                           % Basic Matching Pursuit Algorithm.
        tmpCOEFF = zeros(itermax,1);
        for k = 1:itermax
            [~,i]	 = max(abs(R' * X));   % choose the max(abs(scalar product)
            kopt     = J(i);                  % index of the kept variable
            tmpCOEFF(k) = R'*X(:,i);          % coefficient
            Z		 = tmpCOEFF(k) * X(:,i);  % projection onto the kept atom
            tmpIOPT(k)	 = kopt;
            if onceFLAG
                J      = setdiff(J,kopt);    %#ok<*UNRCH>
                X(:,i) = [];
            end
            YFIT	= YFIT + Z;                    % fit
            R		= R - Z;                       % residuals
            tmpqual(k)	= norm(tmpCOEFF)^2 / N2Y;  % cumulated quality

            if ~isempty(namERR)
                switch upper(namERR)
                    case 'NONE' , curERR = Inf;
                    case 'L1'   , curERR = 100*(norm(R,1)/norm(Y,1));
                    case 'L2'   , curERR = 100*(norm(R)/norm(Y));
                    case 'LINF' , curERR = 100*(norm(R,Inf)/norm(Y,Inf));
                end
            end

            if curERR<valERR || isempty(J)
                break;
            end

        end
        COEFF = tmpCOEFF(1:k);
        qual = tmpqual(1:k);
        IOPT = tmpIOPT(1:k);

    case {'OMP','WMP'}
        XX  = X;

        for k = 1:itermax
            scalProd = abs(R' * XX);
            okALG = false;                         % false for OMP
            if strcmpi(AlgNAM,'WMP')
                i = find(scalProd>wmpcfs*norm(R),1,'first');
                if ~isempty(i) , okALG = true; end
            end

            if ~okALG , [~,i] = max(scalProd); end         % OMP and ...
            kopt = J(i);                           % index of the kept atom.
            J    = setdiff(J,kopt);
            tmpIOPT(k)	= kopt;                    % update support
            P    = X(:, tmpIOPT(1:k));
            TMP  = P\Y;                            % least square estimate
            R = Y - P*TMP;
            YFIT = P*TMP;
            XX = X(:,J);
            tmpqual(k)  = norm(YFIT)^2 / N2Y;

            if ~isempty(namERR)
                switch upper(namERR)
                    case 'NONE' , curERR = Inf;
                    case 'L1'   , curERR = 100*(norm(R,1)/norm(Y,1));
                    case 'L2'   , curERR = 100*(norm(R)/norm(Y));
                    case 'LINF' , curERR = 100*(norm(R,Inf)/norm(Y,Inf));
                end
            end

            if curERR<valERR || isempty(J)
                break;
            end
        end

        COEFF = P\Y;
        YFIT  = P * COEFF;
        qual = tmpqual(1:k);
        IOPT = tmpIOPT(1:k);
end
end


function [itermax,namERR,valERR,wmpcfs,argDICT,isbeg,isend] = parseArgs(N,varargin)

parms = {'itermax','maxerr','wmpcfs', 'LstCpt','Dictionary','addbeg','addend'};

% Select parsing options.
poptions = struct('PartialMatching','unique');
pstruct = coder.internal.parseParameterInputs(parms,poptions,varargin{:});

isitermax = coder.internal.getParameterValue(pstruct.itermax, [],...
    varargin{:});
isbeg = coder.internal.getParameterValue(pstruct.addbeg, [],...
    varargin{:});
isend = coder.internal.getParameterValue(pstruct.addend, [],...
    varargin{:});

% maximum number of iterations
if isempty(isitermax)
    itermax = 25;
else
    validateattributes(isitermax,{'numeric'},{'scalar','integer',...
        'positive','finite','nonnan'},'wmpalg','isitermax');
    itermax = isitermax;
end

% maximum error parsing
isMaxErr = coder.internal.getParameterValue(pstruct.maxerr, [],varargin{:});

if isempty(isMaxErr)
    valERR = 0;
    namERR = 'NONE';
    if isempty(isitermax)
        itermax = 25;
    end
else
    validateattributes(isMaxErr,{'cell'},{'nonempty','numel',2},...
        'wmpalg','isMaxErr');

    if isempty(isMaxErr{1})
        namERR = 'NONE';
    else
        maxErrType = isMaxErr{1};
        namERR = validatestring(maxErrType,{'NONE','L1','L2','LINF'});
        if isempty(isitermax) , itermax = min([N,500]); end
    end

    if isempty(isMaxErr{2})
        valERR = 0;
    else
        validateattributes(isMaxErr{2},{'numeric'},{'scalar','positive',...
            'finite','nonnan'});
        valERR  = isMaxErr{2};
    end
end

iswmpcfs = coder.internal.getParameterValue(pstruct.wmpcfs, [],...
    varargin{:});

if isempty(iswmpcfs)
    wmpcfs = 0.6;
else
    validateattributes(iswmpcfs,{'numeric'},{'scalar','>',0,'<=',1,...
        'finite','nonnan'});
    wmpcfs = iswmpcfs;
end

argDICT = coder.internal.getParameterValue(pstruct.Dictionary, [],...
    varargin{:});

end
