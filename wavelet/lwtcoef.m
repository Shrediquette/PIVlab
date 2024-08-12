function OUT = lwtcoef(CA,CD,varargin)
%LWTCOEF Extract 1-D LWT wavelet coefficients or orthogonal projections.
%
%   Y = LWTCOEF(CA,CD) returns the approximation coefficients at level 1
%   that correspond to the approximation and detail coefficients CA and CD,
%   respectively. CA and CD are outputs of LWT. By default, LWTCOEF assumes
%   that you used the 'db1' wavelet with periodic boundary handling and you
%   did not preserve integer-valued data to obtain the CA and CD.
%
%   Y = LWTCOEF(...,'LiftingScheme',LS) uses the LIFTINGSCHEME object, LS.
%   LS must be the same lifting scheme that was used to obtain CA and CD.
%   By default, LS corresponds to the Haar wavelet.
%       
%   Y = LWTCOEF(...,'Wavelet',W) uses the wavelet specified by the
%   character vector W. The wavelet must be one that is supported by
%   LIFTINGSCHEME (default Haar). W must be the same wavelet that was used
%   to obtain CA and CD. You cannot specify a wavelet name and lifting
%   scheme at the same time.
%
%   Y = LWTCOEF(...,'OutputType',OUTTYPE) specifies whether to extract the 
%   coefficients or return the projections (reconstructions) of the
%   coefficients. Valid values for 'OutputType' are
%      - 'coefficients' for approximation or details coefficients (default)
%      - 'projection' for projection corresponding to the approximation and
%      details coefficients
%
%   Y = LWTCOEF(...,'Type',TYPE) specifies the coefficients to extract or
%   reconstruct. Valid values for 'Type' are 'approximation' (default) and
%   'detail'.
%                                              
%   Y = LWTCOEF(...,'Level',LEVEL) extracts or reconstructs the
%   coefficients at Level LEVEL. LEVEL is a positive integer less than or
%   equal to the length of CD.
%
%   Y = LWTCOEF(...,'Int2Int',INTEGERFLAG) specifies how integer-valued
%   data is handled during the extraction or reconstruction of the
%   coefficients. 
%   true            - does preserve integer-valued data.
%   false (default) - does not preserve integer-valued data. 
%   INTEGERFLAG must match the value used in LWT to generate CA and CD.
%
%   Y = LWTCOEF(...,'Extension',EXTMODE) uses the specified extension mode
%   EXTMODE to extract or reconstruct the coefficients. EXTMODE specifies
%   how to extend the signal at the boundaries. Valid options for EXTMODE
%   are 'periodic' (default), 'zeropad', or 'symmetric'. EXTMODE must match
%   the value used in LWT to generate CA and CD.
%
%   %  Example: Obtain the level 2 wavelet decomposition using db1 wavelet.
%   %  Extract approximation and detail coefficients of level 1.
%   wname = 'db1';
%   LS = liftingScheme('Wavelet',wname);
%   load noisdopp
%   x = noisdopp;
%   level = 2;
%   [CA,CD] = lwt(x, 'LiftingScheme',LS, 'Level',level);
%   
%   % Extract level 1 approximation and detail coefficients
%   ca1 = lwtcoef(CA,CD, 'LiftingScheme',LS, 'OutputType',...
%     'coefficients','Type','approximation','Level',1);
%   cd1 = lwtcoef(CA,CD, 'LiftingScheme',LS, 'OutputType',...
%     'coefficients','Type','detail','Level',1);
%
%   See also ILWT, LWT, LIFTINGSCHEME.

%   Copyright 1995-2022 The MathWorks, Inc.

%#codegen

[LS,outType,type,level,ext,I2I] = parseArgs(varargin{:});

r = size(CD,1);
validateattributes(level,{'numeric'},{'scalar','integer','<=',r,'>=',1},...
                           'lwtcoef','LEVEL');

switch type
    case 'approximation'
        switch outType
            case 'coefficients'
                if (level == r)
                    OUT = CA;
                else
                    OUT = ilwt(CA,CD,'LiftingScheme',LS,'Level',level,...
                        "Extension",ext,"Int2Int",I2I);
                end
            case 'projection'     
        
                if level == r
                    CD2 = cell(r,1);
                    for ii = 1:r
                        CD2{ii} = zeros(1,'like',CA)*CD{ii};
                    end
                    OUT = ilwt(CA,CD2,'LiftingScheme',LS,'Level',0,...
                        "Extension",ext,"Int2Int",I2I);
                else
                    
                    for ii = 1:size(CD,1)
                        if ii < level+1
                            CD{ii} = zeros(1,'like',CA)*CD{ii};
                        end
                    end
                    OUT = ilwt(CA,CD,'LiftingScheme',LS,'Level',0,...
                        "Extension",ext,"Int2Int",I2I);
                end

            otherwise
                coder.internal.error('Wavelet:Lifting:UnsupportedOutType');
        end
    case 'detail'
        switch outType
            case 'coefficients'
                cl = zeros([1,1],'like',CA);
                coder.varsize('cl');
                for ii = 1:r
                    if (ii == level)
                        cl = CD{ii,1};
                        break;
                    end
                end
                OUT = cl;
                
            case 'projection'
                if (level == r)
                    CA = zeros(size(CA),'like',CA);
                    for ii = 1:r
                        if (ii < level)
                            CD{ii,1} = zeros(size(CD{ii,1}),'like',CA);
                        end
                    end
                    OUT = ilwt(CA,CD,'LiftingScheme',LS,'Level',0,...
                        "Extension",ext,"Int2Int",I2I);
                else

                    for ii = 1:size(CD,1)
                        if ii ~= level
                            CD{ii} = zeros(1,'like',CA)*CD{ii};
                        end
                    end

                    CA = zeros(1,'like',CA)*CA;

                    OUT = ilwt(CA,CD,'LiftingScheme',LS,'Level',0,...
                        "Extension",ext,"Int2Int",I2I);
                end
            otherwise
                coder.internal.error('Wavelet:Lifting:UnsupportedOutType');
        end
    otherwise
        coder.internal.error('Wavelet:Lifting:UnsupportedCoefProjType');
end
end

function [LS,outType,type,level,ext,I2I] = parseArgs(varargin)

% Parse name value inputs
parms = {'Wavelet','OutputType','Level','LiftingScheme','Type',...
    'Extension','Int2Int'};

% Select parsing options.
poptions = struct('PartialMatching','unique');
pArg = coder.internal.parseParameterInputs(parms,poptions,varargin{:});

iswv = coder.internal.getParameterValue(pArg.Wavelet, [],...
    varargin{:});
isLS = coder.internal.getParameterValue(pArg.LiftingScheme, [],...
    varargin{:});

if isempty(iswv)  
    if isempty(isLS)
        wv = 'db1';
        LS = liftingScheme('Wavelet',wv);
    else
        LS = isLS;
    end
  
else
    coder.internal.assert(isempty(isLS),'Wavelet:Lifting:WaveNameLScheme');
    
    T = wavelet.internal.lifting.wavenames('all');
    wv = char(iswv);
    
    coder.internal.assert(any(strcmpi(T.W, wv)),...
                'Wavelet:FunctionArgVal:Invalid_WavName');
    
    LS = liftingScheme('Wavelet',wv);
end

islvl = coder.internal.getParameterValue(pArg.Level, [],varargin{:});

if isempty(islvl)
    level = 1;
else
    level = islvl;
end

validateattributes(level,{'numeric'},{'scalar','integer'},...
                           'lwtcoef','LEVEL');

isOut = coder.internal.getParameterValue(pArg.OutputType, [],varargin{:});

if isempty(isOut)
    outType = 'coefficients';
else
    outType = isOut;    
end
outType = validatestring(outType,{'coefficients','projection'},...
    'lwtcoef','OUTTYPE');

isType = coder.internal.getParameterValue(pArg.Type, [],varargin{:});
if isempty(isType)
    type = 'approximation';
else
    type = isType;
end

type = validatestring(type,{'approximation','detail'},...
    'lwtcoef','TYPE');

isext = coder.internal.getParameterValue(...
    pArg.Extension, [],varargin{:});

if isempty(isext)
    ext = 'periodic';  
else
    ext = isext;
end

extType = {'zeropad','periodic','symmetric'};
ext = validatestring(ext,extType,'lwt','EXT');

isI2I = coder.internal.getParameterValue(...
    pArg.Int2Int, [],varargin{:});

if isempty(isI2I)
    I2I = 0;
else
    I2I = isI2I;
end

validateattributes(I2I, {'logical','numeric'},{'scalar'},'lwt','ISI2I');
end