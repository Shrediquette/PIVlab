function varargout = wfusimg(varargin)
%WFUSIMG Wavelet fusion of two images
%   XFUS = WFUSIMG(X1,X2,WNAME,LEVEL,AFUSMETH,DFUSMETH) returns the image
%   XFUS obtained by fusion of the two original images X1 and X2. AFUSMETH
%   is the fusion method for the approximation coefficients. DFUSMETH is
%   the approximation for the detail coefficients. Each fusion method
%   merges X1 and X2 at level LEVEL using wavelet WNAME. X1 and X2 must
%   be the same size (to resize images, see WEXTEND) and must be either
%   M-by-N matrices or M-by-N-by-3 matrices.
%
%   Available methods for AFUSMETH and DFUSMETH are:
%
%    - 'max', 'min', 'mean', 'img1', 'img2', or 'rand', which merge the two
%      approximation or detail coefficient arrays obtained from X1 and X2 
%      element-wise by taking the maximum, the minimum, the mean, the first
%      element, the second element, or a randomly chosen element.
%
%    - Parameter-dependent methods, specified as a structure array of the
%      following form
%
%      Fusmeth = struct('name',nameMETH,'param',paramMETH)
%
%      where nameMETH is one of:
%
%         'linear'    : C = A*paramMETH + B*(1-paramMETH) 
%                             where 0 <= paramMETH <= 1   
%         'UD_fusion' : Up-Down fusion, with paramMETH >= 0  
%                         x = linspace(0,1,size(A,1));
%                         P = x.^paramMETH;
%                         Then each row of C is computed with:
%                         C(i,:) = A(i,:)*(1-P(i)) + B(i,:)*P(i);
%                         So C(1,:)= A(1,:) and C(end,:)= A(end,:) 
%         'DU_fusion' : Down-Up fusion
%         'LR_fusion' : Left-Right fusion (column-wise fusion)
%         'RL_fusion' : Right-Left fusion (column-wise fusion)
%         'userDEF'   : paramMETH is a string 'userFUNCTION' containing
%                         a function name such that:
%                         C = userFUNCTION(A,B).
%
%   [XFUS,TXFUS,TX1,TX2] = WFUSIMG(X1,X2,WNAME,LEVEL,AFUSMETH,DFUSMETH)
%   returns the wavelet decomposition tree objects for XFUS, X1, and X2.
%   For more information, see WDECTREE.
%
%   WFUSIMG(X1,X2,WNAME,LEVEL,AFUSMETH,DFUSMETH,FLAGPLOT) plots the wavelet
%   tree objects for XFUS, X1, and X2. 
%
%   For the description of these options and the corresponding parameter
%   paramMETH, see WFUSMAT.
%
%   %Example:
%       load mask; 
%       X1 = X;
%       load bust;
%       X2 = X;
%       [XFUS,TXFUS,TX1,TX2] = wfusimg(X1,X2,'db2',5,'max','max','plot');
%       imagesc(XFUS)
%       colormap gray
%
%   See also WDECTREE, WFUSMAT 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 
%   Copyright 1995-2020 The MathWorks, Inc.

% Syntax 2:
% ---------
%  VARARGOUT = WFUSIMG('PropName1',PropValue1,'PropName2',PropValue2,...)
%
%  The valid PropNames are:
%     'X1' , 'X2' , 'wname' , 'level' , 'flagPlot' and
%     'AfusMeth' : method of fusion for approximation
%     'DfusMeth' : method of fusion for details
%
%    'X1' and 'X2' are required fields.
%
% The default values are:
%    wname_DEF     = 'db1';
%    level_DEF     = 2;
%    AfusMeth_DEF  = struct('name','linear','param',0.5);
%    DfusMeth_DEF  = struct('name','linear','param',0.5);
%    flagPlot_DEF  = 'plot';
%
% To avoid plots you can set 'flagPlot' to 'noplot'
%
% -----------------------------------------------------------------------
% Examples:
% ---------
%    load mask; X1 = X;
%    load bust; X2 = X;
%    wfusimg('X1',X1,'X2',X2,'wname','db3','level',2);
%    [X,t,t1,t2] = wfusimg('X1',X1,'X2',X2,'AfusMeth','max');

% Convert any strings to char arrays
%-----------------
[varargin{:}] = convertStringsToChars(varargin{:});

nbIN     = nargin;
stdINPUT = true;
if nbIN>0 , stdINPUT = ~ischar(varargin{1}); end
if stdINPUT
    narginchk(6,7);
    X1 = varargin{1};
    X2 = varargin{2};
    wname = varargin{3};
    level = varargin{4};
    AfusMeth = varargin{5};
    DfusMeth = varargin{6};
    if nargin>6
        if strcmpi(varargin{7},'plot')
            flagPlot = true;
        else
            flagPlot = false;
        end
    else
        flagPlot = false;
    end
else
    % Defaults.
    %----------
    wname_DEF    = 'db1';
    level_DEF    = 2;
    fusMeth_DEF  = struct('name','linear','param',0.5);
    flagPlot_DEF = true;
    %--------------------------------------------------
    wname = wname_DEF;
    level = level_DEF;
    AfusMeth = fusMeth_DEF;
    DfusMeth = fusMeth_DEF;
    flagPlot = flagPlot_DEF;
    %--------------------------------------------------
    k    = 1;
    while k<=nbIN
        switch varargin{k}
            case 'X1'       , X1       = varargin{k+1};
            case 'X2'       , X2       = varargin{k+1};
            case 'wname'    , wname    = varargin{k+1};
            case 'level'    , level    = varargin{k+1};
            case 'AfusMeth' , AfusMeth = varargin{k+1};
            case 'DfusMeth' , DfusMeth = varargin{k+1};
            case 'flagPlot' , flagPlot = varargin{k+1};
            otherwise
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
        end
        k = k+2;
    end
    if isempty(X1) || isempty(X2)
        error(message('Wavelet:FunctionArgVal:Invalid_X1X2Val'));
    end
    if isempty(wname)    , wname = wname_DEF;  end
    if isempty(level)    , level = level_DEF;  end
    if isempty(AfusMeth)  , AfusMeth = fusMeth_DEF;  end
    if isempty(DfusMeth)  , DfusMeth = fusMeth_DEF;  end
    if strcmp(flagPlot,'noplot') || isempty(flagPlot)
        flagPlot = false;
    end
    if ischar(X1) , dummy = load(X1); X1 = dummy.X; end
    if ischar(X2) , dummy = load(X2); X2 = dummy.X; end
end
%--------------------------------------------------
validateattributes(X1,{'numeric'},...
    {'finite','real'},'wfusimg','X1');
validateattributes(X2,{'numeric'},...
    {'finite','real'},'wfusimg','X2');


if (size(X1,3) ~= 1 && size(X1,3) ~= 3) || ...
        (size(X2,3) ~= 1 && size(X2,3) ~=3)
    error(message('Wavelet:FunctionArgVal:InvalidThirdDim'));
end



if (numel(size(X1))~=2 && numel(size(X1)) ~= 3) || ...
        (numel(size(X2)) ~= 2 && numel(size(X2)) ~= 3)
    error(message('Wavelet:FunctionArgVal:InvalidXYSizes'));
end




if ~all(size(X1)==size(X2))
    error(message('Wavelet:FunctionArgVal:Invalid_ImgSiz'));
end

% Decomposition.
%---------------
tIMG1 = wfustree(X1,level,wname);
clear X1
tIMG2 = wfustree(X2,level,wname);
clear X2

% Fusion.
%--------
[XFus,tFus] = wfusdec(tIMG1,tIMG2,AfusMeth,DfusMeth);

% Plot trees.
%------------
if flagPlot
    plot(tIMG1); plot(tIMG2); plot(tFus);
end

% Outputs
%--------
switch nargout
    case 0
    case {1,2} , varargout = {XFus , tFus};
    otherwise  , varargout = {XFus , tFus, tIMG1,tIMG2};
end
