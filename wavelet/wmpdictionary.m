function [X,nbVect,LstCPT,longs] = wmpdictionary(N,varargin)
%WMPDICTIONARY Dictionary for Matching Pursuit.
%	X = WMPDICTIONARY(N,'lstcpt',LST) returns the dictionary X
%   built using the subdictionaries in LST. LST is a cell array of cell
%   arrays. Each cell array in LST describes one subdictionary. X is a NxP
%   matrix where N is the length of the data vector and P is the total
%   number of dictionary vectors.
%   [X,NBVECT] = WMPDICTIONARY(...) returns the row vector NBVECT
%   containing the number of elements in each subdictionary. The order of
%   the elements in NBVECT corresponds to the order of the subdictionaries
%   in LST and any prepended or appended subdictionaries. The sum of the
%   elements in NBVECT is the column dimension of X.
%   
%   The valid subdictionaries are:
%     - wavelets and complete wavelet packet dictionaries.
%       The description cell may contain 1,2 or 3 
%       elements: {wname,dlev,dextm}.
%       wname is the wavelet name, prefixed by 'wp' for wavelet packets.
%       For example, 'sym4' and 'wpsym4' denote the Daubechies least
%       asymmetric wavelet and wavelet packet with four vanishing moments.
%       dlev and dextm are optional parameters which define 
%       respectively the decomposition level and the
%       signal extension mode (see DWTMODE).
%       The defaults are dlev = 5 and dextm = 'per'.
%     - 'dct', 'sin', 'cos', 'poly' and  'RnIdent'.
%       The description cell contains only the name.
%       The 'sin' subdictionary contains the vectors:
%          Vk = sin(2*k*pi*t) k = 1:ceil(N/2) , t in [0,1]
%       The 'cos' subdictionary contains the vectors:
%          Wk = cos(2*k*pi*t) k = 1:ceil(N/2) , t in [0,1]
%       The 'poly' subdictionary contains the vectors:
%          Pk = t.^(k-1) , k = 1:20 , t in [0,1]
%       The 'RnIdent' is the eye(N,N) matrix.
% 
%   [...] = WMPDICTIONARY(...,'addbeg',DIC) prepends the dictionary 
%   specified by DIC to the dictionary in LST. If you do not specify LST,
%   DIC is preprended to the default dictionary. 
%   [...] = WMPDICTIONARY(...,'addend',DIC) appends the dictionary
%   specified by DIC to the dictionary in LST. If you do not specify LST,
%   DIC is appended to the default dictionary. DIC must be a matrix of size
%   N-by-Q.
% 
%   [X,NBVECT] = WMPDICTIONARY(N) returns the default dictionary
%   with LST = {{'sym4',5},{'wpsym4',5},'dct','sin'}.
%
%   [X,NBVECT,LST,LONGS] = WMPDICTIONARY(...) returns
%   LST modified with 'addBeg' and 'addEnd' if you have prepended
%   or appended the dictionary. 

% More outputs:
%--------------
%   In addition, [X,NBVECT,LST,LONGS] = WMPDICTIONARY(...) returns
%   LST modified with 'addBeg' and 'addEnd' if necessary, and 
%   LONGS which is a cell array ......

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check input arguments.
if nargin > 1
    % The following will handle the cell array or structure array case
    [varargin{:}] = wavelet.internal.wconvertStringsToChars(varargin{:});
end

nbIN = length(varargin);
LstCPT_DEF = {{'sym4',5},{'wpsym4',5},'dct','sin'};
Xbeg_DEF = [];
Xend_DEF = [];
k = 1;
while k<=nbIN
    argNAM = lower(varargin{k});
    switch argNAM
        case 'lstcpt' , LstCPT = varargin{k+1}; k = k+2;
        case 'addbeg' , Xbeg = varargin{k+1}; k = k+2;
        case 'addend' , Xend = varargin{k+1}; k = k+2;
        otherwise
            error(message('Wavelet:FunctionInput:ArgumentName'));
    end
end
if ~exist('LstCPT','var') , LstCPT = LstCPT_DEF; end
if ~exist('Xbeg','var')   , Xbeg = Xbeg_DEF; end
if ~exist('Xend','var')   , Xend = Xend_DEF; end

nbCOMPO = length(LstCPT);
X   = [];
nbVect = [];
longs  = cell(1,nbCOMPO);
for kCOMPO = 1:nbCOMPO
    cptname = LstCPT{kCOMPO};
    if isequal(cptname,'sin')
        nbV = ceil(N/2);
        Z = zeros(N,nbV);
        t = linspace(0,1,N)';
        for k = 1:nbV
            Z(:,k) = sin(2*k*pi*t);
        end
        longs{kCOMPO} = [];
        
    elseif isequal(cptname,'cos')
        nbV = ceil(N/2);        
        Z = zeros(N,nbV);
        t = linspace(0,1,N)';
        for k = 1:nbV
            Z(:,k) = cos(2*k*pi*t);
        end
        longs{kCOMPO} = [];
        
    elseif isequal(cptname,'poly')
        nbV = 20;
        Z = zeros(N,nbV);
        t = linspace(0,1,N)';
        for k = 1:nbV
            Z(:,k) = t.^(k-1);
        end
        longs{kCOMPO} = [];
            
    elseif isequal(cptname,'RnIdent')
        longs{kCOMPO} = [];
        Z = eye(N);
        
    elseif isequal(cptname,'dct')
        longs{kCOMPO} = [];
        Z = widct(eye(N));
       
    else   % Wavelet or Wavelet Packet basis
        if iscell(cptname)
            level = cptname{2};
            if length(cptname)>2 , dwtEXTM =  cptname{3}; end
            cptname = cptname{1}; 
        end
        
        % Change the DWT extension mode if necessary.
        if ~exist('dwtEXTM','var') , dwtEXTM = 'per'; end
        old_dwtEXTM = dwtmode('status','nodisp');
        dwtmode(dwtEXTM,'nodisp')
        
        % Get the level of decomposition.
        if ~exist('level','var') , level = 5; end
        okWAVE = ~isequal(lower(cptname(1:2)),'wp');
        if okWAVE
            [~,lon] = wavedec(zeros(N,1),level,cptname);
            NbCFS = sum(lon(1:end-1));
            DEC = mdwtdec('c',zeros(N,NbCFS),level,cptname);
            sCa = size(DEC.ca);
            for k = 1:sCa(1)
                DEC.ca(k,k) = 1;
            end
            icol = sCa(1)+1;
            for j = level:-1:1
                sCd = size(DEC.cd{j});
                for k = 1:sCd(1)
                    DEC.cd{j}(k,icol) = 1;
                    icol = icol+1;
                end
            end
            longs{kCOMPO} = lon;
            Z = mdwtrec(DEC);
        else
            cptname = cptname(3:end);
            dwtATTR = dwtmode('get');
            dwtEXTM = dwtATTR.extMode;
            dec = wavelet.internal.mwptdec('c',zeros(N,1),level,cptname,dwtEXTM);
            nbCFSbyNode = dec.sx(end);
            NbCFS = nbCFSbyNode*(2^level);
            tmp = eye(NbCFS);
            dCol = dec.sx(end);
            for k=1:2^level
                dec.cfs{k} = tmp(:,(k-1)*dCol+1:k*dCol);
            end
            Z = wavelet.internal.mwptrec(dec);
        end
        clear dwtEXTM level 
        
        % Restore the DWT extension mode if necessary.
        dwtmode(old_dwtEXTM,'nodisp')
    end
    S = sum(Z.*Z,1);
    Z = Z./repmat(S.^0.5,N,1);
    X = [X Z];               %#ok<AGROW>
    nbVect = [nbVect size(Z,2)];   %#ok<AGROW>
end
    
if ~isempty(Xbeg)
    if ~isempty(X) && ~isequal(size(X,1),size(Xbeg,1))
        error(message('Wavelet:FunctionArgVal:Invalid_Input'))
    end
    S = sum(Xbeg.*Xbeg,1);
    Xbeg = Xbeg./repmat(S.^0.5,N,1);
    X = [Xbeg , X];
    nbVect = [size(Xbeg,2) nbVect];
    longs = {[] , longs{:}}; %#ok<CCAT>
    LstCPT = [LstCPT,'AddBeg'];
end
if ~isempty(Xend)
    if ~isempty(X) &&  ~isequal(size(X,1),size(Xend,1))
        error(message('Wavelet:FunctionArgVal:Invalid_Input'))
    end
    S = sum(Xend.*Xend,1);
    Xend = Xend./repmat(S.^0.5,N,1);
    X = [X , Xend];
    nbVect(end+1) = size(Xend,2);
    longs{end+1} = [];
    LstCPT = ['AddEnd',LstCPT];
end
    
X = sparse(X);

%--------------------------------------------------------------------
function a = widct(b)
%IDCT Inverse discrete cosine transform used in Wavelet Toolbox
% Modified copy of idct.m in Signal Toolbox:
%   Author(s): C. Thompson, S. Eddins

% Pad or truncate b if necessary
n = size(b,1);

% Compute weights
ww = sqrt(2*n) * exp(1i*(0:n-1)*pi/(2*n)).';

if isodd(n) % odd case
    % Form intermediate even-symmetric matrix.
    ww(1) = ww(1) * sqrt(2);
    W = ww(:,ones(1,n));
    yy = zeros(2*n,n);
    yy(1:n,:) = W.*b;
    yy(n+2:2*n,:) = -1i*W(2:n,:).*flipud(b(2:n,:));
    y = ifft(yy);
    
    % Extract inverse DCT
    a = y(1:n,:);
    
else % even case
    % Compute precorrection factor
    ww(1) = ww(1)/sqrt(2);
    W = ww(:,ones(1,n));
    yy = W.*b;
    
    % Compute x tilde using equation (5.93) in Jain
    y = ifft(yy);
    
    % Re-order elements of each column according to equations (5.93) and
    % (5.94) in Jain
    a = zeros(n,n);
    a(1:2:n,:) = y(1:n/2,:);
    a(2:2:n,:) = y(n:-1:n/2+1,:);
end
a = real(a);
%--------------------------------------------------------------------


