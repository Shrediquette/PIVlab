function xout = wextend(type,mode,x,lf,location)
%WEXTEND Extend a Vector or a Matrix.
%
%   Y = WEXTEND(TYPE,MODE,X,L,LOC) or
%   Y = WEXTEND(TYPE,MODE,X,L)
%
%   The valid extension types (TYPE) are:
%     1,'1','1d' or '1D'    : 1-D extension
%     2,'2','2d' or '2D'    : 2-D extension
%     'ar' or 'addrow'      : add rows
%     'ac' or 'addcol       : add columns
%
%   The valid extension modes (MODE) are:
%     'zpd' zero extension.
%     'sym' (or 'symh') symmetric extension (half-point).
%     'symw' symmetric extension (whole-point).
%     'asym' (or 'asymh') antisymmetric extension (half-point).
%     'asymw' antisymmetric extension (whole-point).
%     'ppd' periodized extension (1).
%     'per' periodized extension (2):
%        If the signal length is odd, WEXTEND adds an extra-sample
%        equal to the last value on the right and performs extension
%        using the 'ppd' mode. Otherwise, 'per' reduces to 'ppd'.
%        The same kind of rule stands for images.
%
%   The following extension modes cast the data internally to double
%   precision before performing the extension. For integer datatypes,
%   WEXTEND warns if the conversion to double causes a loss of precision
%   or the requested extension results in integers beyond the range where
%   double precision numbers can represent consecutive integers exactly.
%     'sp0' smooth extension of order 0.
%     'spd' (or 'sp1') smooth extension of order 1.
%
%   With TYPE = {1,'1','1d' or '1D'}:
%     LOC = 'l' (or 'u') for left (up) extension.
%     LOC = 'r' (or 'd') for right (down) extension.
%     LOC = 'b' for extension on both sides.
%     LOC = 'n' nul extension
%     The default is LOC = 'b'.
%     L is the length of the extension.
%
%   With TYPE = {'ar','addrow'}
%     LOC is a 1D extension location.
%     The default is LOC = 'b'.
%     L is the number of rows to add.
%
%   With TYPE = {'ac','addcol'}
%     LOC is a 1D extension location.
%     The default is LOC = 'b'.
%     L is the number of columns to add.
%
%   With TYPE = {2,'2','2d' or '2D'}:
%     LOC = [locrow,loccol] where locrow and loccol are 1D
%     extension locations or 'n' (none).
%     The default is LOC = 'bb'.
%     L = [lrow,lcol] where lrow is the number of rows
%     to add and lcol is the number of columns to add.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Nov-97.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(4,5);

% Early exit if extension length is zero
validateattributes(lf,{'numeric'},{'integer','nonnegative'},'wextend','L');
if all(lf == 0, "all")
    xout = x;
    return;
end

type = convertStringsToChars(type);
mode = convertStringsToChars(mode);
if nargin > 4
    location = convertStringsToChars(location);
end

if ischar(mode)
    isSymOrPer = any(strcmp(mode, ["sym","per"]));
else
    isSymOrPer = 0;
end

isDefaultLoc = (nargin == 4);
isExtInOneDim = isscalar(lf);

type = lower(type);
if isnumeric(type)
    isOptimizedType = isequal(type,1);
elseif ischar(type)
    isOptimizedType = any(strcmpi(type, ["1", "1d", "addrow", "addcol"]));
else
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

if isSymOrPer && isDefaultLoc && isOptimizedType && isExtInOneDim
    % Optimized code path for arrays with sym or per mode
    % with default location and types, with extension in one dimension
    xout = wavelet.internal.wextend(type,mode,x,lf);
    return;
elseif isa(x,"gpuArray")
    % gpuArrays are not supported for any non-optimized path
    iThrowGpuError(isSymOrPer,isDefaultLoc,isOptimizedType,isExtInOneDim);
end

% Check if the data is integer and one of the modes is used that need to be
% cast
origclass = class(x);
if isinteger(x) && any(strcmpi(mode,{'spd','sp0','sp1','asym','asymw','asymh'}))
    
    PrecisionLoss = ~all(cast(double(x(:).'),origclass) == x(:).');
    if PrecisionLoss
        warning(message('Wavelet:FunctionInput:PrecisionLoss',origclass));
    end
    x = double(x);
    integerData = true;
else
    integerData = false;
end

switch type
    case {1,'1','1d'}
        validateattributes(x,{'numeric'},{'vector'},'wextend','X');
        if nargin<5
            loc = 'b';
        else
            loc = testLoc(location);
        end

        if lf == 0
            loc = 'n';
        end

        if isequal(loc,'n')
            if integerData && ~isa(x,origclass)
                xout = cast(x,origclass);
            else
                xout = x;
            end
            return;
        end
        isROW = (size(x,1)<2);
        x  = x(:).';
        sx = length(x);
        switch mode
            case 'zpd'            % Zero Padding.
                [ext_L,ext_R] = getZPD_ext(1,lf,loc);
                x = [ext_L x ext_R];
                
            case {'sym','symh'}   % Half-point Symmetrization .
                I = getSymIndices(sx,lf,loc);
                x  = x(I);
                
            case {'symw'}         % Whole-point Symmetrization.
                x = WP_SymExt(x,lf,loc);
                
            case {'asym','asymh'} % Half-point Anti-Symmetrization.
                x = HP_AntiSymExt(x,lf,loc);
                
            case {'asymw'}        % Whole-point Anti-Symmetrization.
                x = WP_AntiSymExt(x,lf,loc);
                
            case 'sp0'            % Smooth padding of order 0.
                [ext_L,ext_R] = getSP0_ext('row',x(1),x(sx),lf,loc,integerData,origclass);
                x = [ext_L x ext_R];
                
                
            case {'spd','sp1'}    % Smooth padding of order 1.
                if sx<2
                    d = 0;
                else
                    d = 1;
                end
                d_L = x(1)- x(1+d);
                if integerData && (abs(d_L) >= flintmax('double'))
                    warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
                end
                d_R = x(sx)- x(sx-d);
                if integerData && (abs(d_R) >= flintmax('double'))
                    warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
                end
                [ext_L,ext_R] = getSP1_ext('row',x(1),x(sx),d_L,d_R,lf,loc,integerData,origclass);
                x = [ext_L x ext_R];
                
                
            case {'ppd'}          % Periodization.
                I = getPerIndices(sx,lf,loc);
                x = x(I);
                
            case {'per'}          % Periodization.
                if isodd(sx), x(sx+1) = x(sx); sx = sx+1; end
                I = getPerIndices(sx,lf,loc);
                x = x(I);
                
            otherwise
                error(message('Wavelet:FunctionArgVal:Invalid_PadMode'));
        end
        if ~isROW , x = x'; end
        
    case {2,'2','2d'}
        validateattributes(x,{'numeric'},{'nonempty'},'wextend','X');
        
        
        if nargin<5
            locRow = 'b';
            locCol = 'b';
        else
            if length(location)<2
                location(2) = location(1);
            end
            locRow = testLoc(location(1));
            locCol = testLoc(location(2));
        end
        if length(lf)<2
            lf = [lf , lf];
        end
        if lf(1) == 0
            locRow = 'n';
        end
        if lf(2) == 0
            locCol = 'n';
        end
        if ~ismatrix(x)
            y = cell(1,3);
            for k=1:3
                y{k} = wextend('2D',mode,x(:,:,k),lf,[locRow locCol]);
            end
            
            xout = cat(3,y{:});
            if integerData
                xout = cast(xout,origclass);
            end
            return;
        end
        
        
        
        [rx,cx] = size(x);
        switch mode
            case 'zpd'            % Zero Padding.
                if ~isequal(locCol,'n')
                    [ext_L,ext_R] = getZPD_ext(rx,lf(2),locCol);
                    x  = [ext_L x ext_R];
                end
                if ~isequal(locRow,'n')
                    cx = size(x,2);
                    [ext_L,ext_R] = getZPD_ext(lf(1),cx,locRow);
                    x = [ext_L ; x ; ext_R];
                end
                
            case {'sym','symh'}   % Symmetrization half-point.
                if ~isequal(locCol,'n')
                    I = getSymIndices(cx,lf(2),locCol); x = x(:,I);
                end
                if ~isequal(locRow,'n')
                    I = getSymIndices(rx,lf(1),locRow); x = x(I,:);
                end
                
            case {'symw'}         % Symmetrization whole-point.
                if ~isequal(locCol,'n')
                    x = WP_SymExt(x,lf(2),locCol);
                end
                if ~isequal(locRow,'n')
                    x = WP_SymExt(x',lf(1),locRow); x = x';
                end
                
            case {'asym','asymh'} % Half-point Anti-Symmetrization.
                if ~isequal(locCol,'n')
                    x = HP_AntiSymExt(x,lf(2),locCol);
                    
                    
                end
                if ~isequal(locRow,'n')
                    x = HP_AntiSymExt(x',lf(1),locRow); x = x';
                    
                end
                
            case {'asymw'}        % Whole-point Anti-Symmetrization.
                if ~isequal(locCol,'n')
                    x = WP_AntiSymExt(x,lf(2),locCol);
                    
                end
                if ~isequal(locRow,'n')
                    x = WP_AntiSymExt(x',lf(1),locRow); x = x';
                    
                end
                
            case 'sp0'            % Smooth padding of order 0.
                if ~isequal(locCol,'n')
                    [ext_L,ext_R] = getSP0_ext('row',x(:,1),x(:,cx),lf(2),locCol,integerData,origclass);
                    x = [ext_L x ext_R];
                    
                end
                if ~isequal(locRow,'n')
                    [ext_L,ext_R] = getSP0_ext('col',x(1,:),x(rx,:),lf(1),locRow,integerData,origclass);
                    x = [ext_L ; x ; ext_R];
                    
                end
                
            case {'spd','sp1'}    % Smooth padding of order 1.
                if ~isequal(locCol,'n')
                    if cx<2
                        d = 0;
                    else
                        d = 1;
                    end
                    d_L = x(:,1)-x(:,1+d);
                    if integerData && (max(abs(d_L(:))) >= flintmax('double'))
                        warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
                    end
                    d_R = x(:,cx)- x(:,cx-d);
                    if integerData && (max(abs(d_R(:))) >= flintmax('double'))
                        warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
                    end
                    
                    [ext_L,ext_R] = getSP1_ext('row',x(:,1),x(:,cx),d_L,d_R,lf(2),locCol,integerData,origclass);
                    x = [ext_L x ext_R];
                    
                    
                end
                if ~isequal(locRow,'n')
                    if (rx < 2)
                        d = 0;
                    else
                        d = 1;
                    end
                    d_L = x(1,:) - x(1+d,:);
                    if integerData && (max(abs(d_L(:))) >= flintmax('double'))
                        warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
                    end
                    d_R = x(rx,:)- x(rx-d,:);
                    if integerData && (max(abs(d_R(:))) >= flintmax('double'))
                        warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
                    end
                    [ext_L,ext_R] = getSP1_ext('col',x(1,:),x(rx,:),d_L,d_R,lf(1),locRow,integerData,origclass);
                    x = [ext_L ; x ; ext_R];
                    
                    
                end
                
            case 'ppd'            % Periodization.
                if ~isequal(locCol,'n')
                    I = getPerIndices(cx,lf(2),locCol); x = x(:,I);
                end
                if ~isequal(locRow,'n')
                    I = getPerIndices(rx,lf(1),locRow); x = x(I,:);
                end
                
            case 'per'            % Periodization.
                if ~isequal(locCol,'n')
                    if isodd(cx)
                        x(:,cx+1) = x(:,cx);
                        cx = cx+1;
                    end
                    I = getPerIndices(cx,lf(2),locCol);
                    x = x(:,I);
                end
                if ~isequal(locRow,'n')
                    if isodd(rx)
                        x(rx+1,:) = x(rx,:);
                        rx = rx+1;
                    end
                    I = getPerIndices(rx,lf(1),locRow);
                    x = x(I,:);
                end
                
            otherwise
                error(message('Wavelet:FunctionArgVal:Invalid_PadMode'));
        end
        
    case {'ar','ac','addrow','addcol'}
        if nargin<5
            loc = 'b';
        else
            loc = testLoc(location(1));
        end
        switch type
            case {'ar','addrow'} , location = [loc , 'n'];
            case {'ac','addcol'} , location = ['n' , loc];
        end
        if ismatrix(x)
            x = wextend('2D',mode,x,lf,location);
            
        else
            y = cell(1,3);
            
            for k=1:3
                y{k} = wextend('2D',mode,x(:,:,k),lf,location);
            end
            x = cat(3,y{:});
            
            
        end
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

if integerData && ~isa(x,origclass)
    xout = cast(x,origclass);
else
    xout = x;
end

%-------------------------------------------------------------------------%
% Internal Function(s)
%-------------------------------------------------------------------------%
function location = testLoc(location)

if ~ischar(location) , location = 'b'; return; end
switch location
    case {'n','l','u','b','r','d'}
    otherwise , location = 'b';
end
%-------------------------------------------------------------------------%
function [ext_L,ext_R] = getZPD_ext(nbr,nbc,location)

switch location
    case {'n'}     , ext_L = [];             ext_R = [];
    case {'l','u'} , ext_L = zeros(nbr,nbc); ext_R = [];
    case {'b'}     , ext_L = zeros(nbr,nbc); ext_R = zeros(nbr,nbc);
    case {'r','d'} , ext_L = [];             ext_R = zeros(nbr,nbc);
end
%-------------------------------------------------------------------------%
function [ext_L,ext_R] = getSP0_ext(type,x_L,x_R,lf,location,integerData,origclass)

switch type(1)
    case 'r' , ext_V = ones(1,lf);
    case 'c' , ext_V = ones(lf,1);
end
switch location
    case {'n'}
        ext_L = [];
        ext_R = [];
    case {'l','u'}
        ext_L = kron(ext_V,x_L);
        if integerData && (max(abs(ext_L(:))) >= flintmax('double'))
            warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
        end
        ext_R = [];
        
    case {'b'}
        ext_L = kron(ext_V,x_L);
        ext_R = kron(ext_V,x_R);
        if integerData && (max(abs(ext_R(:))) >= flintmax('double') || max(abs(ext_L(:))) >= flintmax('double'))
            warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
        end
    case {'r','d'}
        ext_L = [];
        ext_R = kron(ext_V,x_R);
        if integerData && (max(abs(ext_R(:))) >= flintmax('double'))
            warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
        end
end






%-------------------------------------------------------------------------%
function [ext_L,ext_R] = getSP1_ext(type,x_L,x_R,d_L,d_R,lf,location,integerData,origclass)


switch type(1)
    case 'r' , ext_V0 = ones(1,lf); ext_VL = lf:-1:1;  ext_VR = 1:lf;
    case 'c' , ext_V0 = ones(lf,1); ext_VL = (lf:-1:1)'; ext_VR = (1:lf)';
end
switch location
    case {'n'}
        ext_L = [];
        ext_R = [];
    case {'l','u'}
        ext_L = kron(ext_V0,x_L) + kron(ext_VL,d_L);
        if integerData && (max(abs(ext_L(:))) >= flintmax('double'))
            warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
        end
        ext_R = [];
    case {'b'}
        ext_L = kron(ext_V0,x_L) + kron(ext_VL,d_L);
        ext_R = kron(ext_V0,x_R) + kron(ext_VR,d_R);
        if integerData && (max(abs(ext_R(:))) >= flintmax('double') || max(abs(ext_L(:))) >= flintmax('double'))
            warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
        end
    case {'r','d'}
        ext_L = [];
        ext_R = kron(ext_V0,x_R) + kron(ext_VR,d_R);
        if integerData && (max(abs(ext_R(:))) >= flintmax('double'))
            warning(message('Wavelet:FunctionInput:IntegerOverFlow',origclass));
        end
end


%-------------------------------------------------------------------------%
function I = getPerIndices(lx,lf,location)

switch location
    case {'n'}     , I = 1:lx;
    case {'l','u'} , I = [lx-lf+1:lx , 1:lx];
    case {'b'}     , I = [lx-lf+1:lx , 1:lx , 1:lf];
    case {'r','d'} , I = [1:lx , 1:lf];
end
if lx<lf
    I = mod(I,lx);
    I(I==0) = lx;
end
%-------------------------------------------------------------------------%
function I = getSymIndices(lx,lf,location)

switch location
    case {'n'}     , I = 1:lx;
    case {'l','u'} , I = [lf:-1:1 , 1:lx];
    case {'b'}     , I = [lf:-1:1 , 1:lx , lx:-1:lx-lf+1];
    case {'r','d'} , I = [1:lx , lx:-1:lx-lf+1];
end
if lx<lf
    K = (I<1);
    I(K) = 1-I(K);
    J = (I>lx);
    while any(J)
        I(J) = 2*lx+1-I(J);
        K = (I<1);
        I(K) = 1-I(K);
        J = (I>lx);
    end
end
%-------------------------------------------------------------------------%
function Y = HP_SymExt(X,N,LOC) %#ok<DEFNU> % Half-point Symmetrization.

C = size(X,2);
switch LOC
    case {'n'}     , I = 1:C;
    case {'l','u'} , I = [N:-1:1 , 1:C];
    case {'b'}     , I = [N:-1:1 , 1:C , C:-1:C-N+1];
    case {'r','d'} , I = [1:C , C:-1:C-N+1];
end
if C<N
    K = (I<1);
    I(K) = 1-I(K);
    J = (I>C);
    while any(J)
        I(J) = 2*C+1-I(J);
        K = (I<1);
        I(K) = 1-I(K);
        J = (I>C);
    end
end
Y = X(:,I);
%-------------------------------------------------------------------------%
function Y = WP_SymExt(X,N,LOC) % Whole-point Symmetrization.

[~,c] = size(X);

if c == 1
    switch LOC
        case {'l','u','r','d'}
            Nrep = N+1;
        case {'b'}
            Nrep = 2*N+1;
    end
    Y = repmat(X,1,Nrep);
    return;
end

while (N+1)>c
    N = N-(c-1);
    X = WP_SymExt(X,c-1,LOC);
    [~,c] = size(X);
end

switch LOC
    case {'l','u'}
        I = [N+1:-1:2 , 1:c];
    case {'b'}
        I = [N+1:-1:2 , 1:c , c-1:-1:c-N];
    case {'r','d'}
        I = [1:c , c-1:-1:c-N];
end
Y = X(:,I);
%-------------------------------------------------------------------------%
function Y = HP_AntiSymExt(X,N,LOC) % Half-point Anti-Symmetrization.


[~,c] = size(X);

if c == 1
    switch LOC
        case {'l','u','r','d'}
            Nrep = N+1;
        case {'b'}
            Nrep = 2*N+1;
    end
    Y = repmat(X,1,Nrep);
    return;
end

while N>c
    N = N-c;
    X = HP_AntiSymExt(X,c,LOC);
    [~,c] = size(X);
end

switch LOC
    case {'l','u'}
        Y = [fliplr(-X(:,1:N)), X];
    case {'r','d'}
        Y = [X , fliplr(-X(:,end-N+1:end))];
    case 'b'
        Y = [fliplr(-X(:,1:N)), X];
        Y = [Y , fliplr(-X(:,end-N+1:end))];
end

%-------------------------------------------------------------------------%
function Y = WP_AntiSymExt(X,N,LOC) % Whole-point Anti-Symmetrization.

[~,c] = size(X);

if c == 1
    switch LOC
        case {'l','u','r','d'}
            Nrep = N+1;
        case {'b'}
            Nrep = 2*N+1;
    end
    Y = repmat(X,1,Nrep);
    return;
end

while (N+1)>c
    N = N-(c-1);
    X = WP_AntiSymExt(X,c-1,LOC);
    [~,c] = size(X);
end

N = N+1;
switch LOC
    case {'l','u'}
        Y = [fliplr(-X(:,2:N)+ 2*X(:,ones(1,N-1))) , X];
    case {'r','d'}
        Y = [X , fliplr(-X(:,end-N+1:end-1)+ 2*X(:,c*ones(1,N-1)))];
    case 'b'
        Y = [fliplr(-X(:,2:N)+ 2*X(:,ones(1,N-1))) , X];
        Y = [Y , fliplr(-X(:,end-N+1:end-1)+ 2*X(:,c*ones(1,N-1)))];
end

%-------------------------------------------------------------------------%
function iThrowGpuError(isSymOrPer,isDefaultLoc,isOptimizedType,isExtInOneDim)
% Throws the relevant GPU errors
if ~isSymOrPer
    error(message("Wavelet:FunctionInput:WextendModeGPU"));
elseif ~isDefaultLoc
    error(message("Wavelet:FunctionInput:WextendLocGPU"));
elseif ~isOptimizedType
    error(message("Wavelet:FunctionInput:WextendTypeGPU"));
elseif ~isExtInOneDim
    error(message("Wavelet:FunctionInput:WextendLfGPU"));
end