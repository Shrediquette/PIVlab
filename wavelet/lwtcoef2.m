function OUT = lwtcoef2(LL,LH,HL,HH,varargin)
%LWTCOEF2 Extract 2-D LWT wavelet coefficients and orthogonal projections
%
%   Y = LWTCOEF2(LL,LH,HL,HH) returns the level 1 reconstructed
%   approximation coefficients that correspond to the approximation
%   coefficients, LL, and cell arrays of horizontal (LH), vertical (HL),
%   and diagonal (HH) wavelet coefficients. The coefficients in LL, LH, HL,
%   and HH are the outputs of LWT2. By default, LWTCOEF2 assumes
%   that you used the 'db1' wavelet with periodic boundary handling and you
%   did not preserve integer-valued data to obtain LL,LH,HL,and HH.
%
%   Y = LWTCOEF2(...,'LiftingScheme',LS) uses the LIFTINGSCHEME object, LS.
%   LS must be the same lifting scheme that was used to obtain LL,LH,HL,
%   and HH. By default, LS corresponds to the Haar wavelet.
%
%   Y = LWTCOEF2(...,'Wavelet',W) uses the wavelet specified by the
%   character vector W. The wavelet must be one that is supported by
%   LIFTINGSCHEME (default Haar). W must be the same wavelet that was used
%   to obtain LL, LH, HL, and HH. You cannot specify a wavelet name and
%   lifting scheme at the same time.
%
%   Y = LWTCOEF2(...,'OutputType',OUTTYPE) specifies whether to extract the 
%   coefficients or return the projections (reconstructions) of the
%   coefficients. Valid values for 'OutputType' are
%      - 'coefficients' for approximation, horizontal, vertical, and
%      diagonal coefficients (default) 
%      - 'projection' for orthogonal projection corresponding to the
%      approximation, horizontal, vertical, and diagonal coefficients
%
%   Y = LWTCOEF2(...,'Type',TYPE) specifies the type of coefficients to
%   extract or reconstruct. Valid values for 'Type' are 'LL' (default),
%   'LH', 'HL', and 'HH', for approximation, horizontal, vertical, and
%   diagonal coefficients, respectively.
%                                              
%   Y = LWTCOEF2(...,'Level',LEVEL) extracts or reconstructs the
%   coefficients at Level LEVEL. LEVEL is a positive integer less than or
%   equal to the length of HH.
%
%   Y = LWTCOEF2(...,'Int2Int',INTEGERFLAG) specifies how integer-valued
%   data is handled during the extraction or reconstruction of the
%   coefficients. 
%   true            - does preserve integer-valued data.
%   false (default) - does not preserve integer-valued data. 
%   INTEGERFLAG must match the value used in LWT2 to generate LL,LH,HL,HH.
%
%   Y = LWTCOEF2(...,'Extension',EXTMODE) uses the specified extension mode
%   EXTMODE to extract or reconstruct the coefficients. EXTMODE specifies
%   how to extend the signal at the boundaries. Valid options for EXTMODE
%   are 'periodic' (default), 'zeropad', or 'symmetric'. EXTMODE must match
%   the value used in LWT2 to generate LL, LH, HL, and HH.
%
%   %  Example: Obtain the wavelet decomposition of an RGB image down to
%   %  level 2. Extract the approximation and diagonal coefficients at 
%   %  level 1.
%   
%   x = imread('ngc6543a.jpg');
%   level = 2;
%   LS = liftingScheme('Wavelet','db2');
%   [LL,LH,HL,HH] = lwt2(x, 'LiftingScheme',LS, 'Level',level);
%   LL1 = lwtcoef2(LL,LH,HL,HH, 'LiftingScheme',LS, 'OutputType',...
%     'coefficients','Type','LL','Level',1);
%   HH1 = lwtcoef2(LL,LH,HL,HH, 'LiftingScheme',LS, 'OutputType',...
%     'coefficients','Type','HH','Level',1);
%
%   See also ILWT2, LWT2, LIFTINGSCHEME.

%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

[LS,outType,type,level,ext,I2I] = parseArgs(varargin{:});

r = numel(HH);
validateattributes(level,{'numeric'},{'scalar','integer','<=',r,'>=',1},...
                           'lwtcoef','LEVEL');
                 
                       
switch type
    case 'LL'
        switch outType
            case 'coefficients'
                if (level == r)
                    OUT = LL;
                    coder.varsize('OUT');
                else
                    OUT = ilwt2(LL,LH,HL,HH,'LiftingScheme',LS,'Level',...
                        level,"Extension",ext,"Int2Int",I2I);
                    d = size(OUT,1);
                    for ii = 1:r
                        if (ii == level)
                            d = size(LH{ii},1);
                            break;
                        end
                    end
                    if size(OUT,1) > d
                        OUT(end,:,:,:) = []; 
                    end
                end
            case 'projection'                     
                if level == r
                    for ii = 1:r
                        HH{ii} = zeros(size(HH{ii}),'like',LL);
                        LH{ii} = zeros(size(LH{ii}),'like',LL);
                        HL{ii} = zeros(size(HL{ii}),'like',LL);
                    end
                    OUT = ilwt2(LL,LH,HL,HH,'LiftingScheme',LS,'Level',...
                        0,"Extension",ext,"Int2Int",I2I);
                else
                    LL2 = ilwt2(LL,LH,HL,HH,'LiftingScheme',LS,'Level',...
                        level,"Extension",ext,"Int2Int",I2I);  
                    
                    szhh = zeros(level,numel(size(HH{1,1})));
                    szlh = zeros(level,numel(size(LH{1,1})));
                    szhl = zeros(level,numel(size(HL{1,1})));
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        szhl(ii,:,:,:) = size(HL{ii,1});
                        szhh(ii,:,:,:) = size(HH{ii,1});
                        szlh(ii,:,:,:) = size(LH{ii,1});
                    end
                                    
                    LH2 = cell(level,1);
                    HL2 = cell(level,1);
                    HH2 = cell(level,1);
                    for ii = 1:level
                        HH2{ii,1} = zeros(szhh(ii,:,:,:),'like',HH{1,1});
                        LH2{ii,1} = zeros(szlh(ii,:,:,:),'like',LH{1,1});
                        HL2{ii,1} = zeros(szhl(ii,:,:,:),'like',HL{1,1});
                    end
                    
                    OUT = ilwt2(LL2,LH2,HL2,HH2,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
                end

            otherwise
                coder.internal.error('Wavelet:Lifting:UnsupportedOutType');
        end
    case 'LH'
        switch outType
            case 'coefficients'
                OUT = zeros(size(LH{1,1}),'like',LL);
                coder.varsize('OUT');
                for ii = 1:r
                    if (ii == level)
                        OUT = LH{ii,1};
                        break;
                    end
                end
            case 'projection'   
                
                if (level == r)
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        if (ii ~= level)
                            LH{ii,1} = zeros(size(LH{ii,1}),'like',...
                                LH{ii,1});
                        end
                        HH{ii,1} = zeros(size(HH{ii,1}),'like',HH{ii,1});
                        HL{ii,1} = zeros(size(HL{ii,1}),'like',HL{ii,1});
                    end
                    
                    LL = zeros(size(LL),'like',LL);
                    OUT = ilwt2(LL,LH,HL,HH,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
                else
                    c2 = coder.nullcopy(LH{r,1});
                    l2 = zeros(1,numel(size(LH{1})));
                    coder.varsize('c2');
                    for ii = 1:r
                        if (ii == level)
                            c2 = LH{ii,1};
                            l2 = size(c2);
                            break;
                        end
                    end
                                        
                    szhh = zeros(level,numel(size(HH{1,1})));
                    szlh = zeros(level,numel(size(LH{1,1})));
                    szhl = zeros(level,numel(size(HL{1,1})));
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        szhl(ii,:,:,:) = size(HL{ii,1});
                        szhh(ii,:,:,:) = size(HH{ii,1});
                        szlh(ii,:,:,:) = size(LH{ii,1});
                    end
                    
                    LH2 = cell(level,1);
                    HL2 = cell(level,1);
                    HH2 = cell(level,1);
                    for ii = 1:level
                        HH2{ii,1} = zeros(szhh(ii,:,:,:),'like',HH{1,1});
                        LH2{ii,1} = zeros(szlh(ii,:,:,:),'like',LH{1,1});
                        HL2{ii,1} = zeros(szhl(ii,:,:,:),'like',HL{1,1});
                    end
                    
                    for ii =1:100
                        if (ii == level)
                            LH2{ii} = c2;
                        end
                    end
                    
                    LL2 = zeros(l2,'like',LL);
                    
                    OUT = ilwt2(LL2,LH2,HL2,HH2,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
                end
                
            otherwise
                coder.internal.error('Wavelet:Lifting:UnsupportedOutType');
        end
    case 'HL'
        switch outType
            case 'coefficients'
                OUT = zeros(size(HL{1,1}),'like',LL);
                coder.varsize('OUT');
                for ii = 1:r
                    if (ii == level)
                        OUT = HL{ii,1};
                        break;
                    end
                end
            case 'projection'
               
                if (level == r)
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        if (ii ~= level)
                            HL{ii,1} = zeros(size(HL{ii,1}),'like',...
                                HL{ii,1});
                        end
                        HH{ii,1} = zeros(size(HH{ii,1}),'like',HH{ii,1});
                        LH{ii,1} = zeros(size(LH{ii,1}),'like',LH{ii,1});
                    end
                    
                    LL = zeros(size(LL),'like',LL);
                    OUT = ilwt2(LL,LH,HL,HH,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
                else
                    c2 = coder.nullcopy(HL{r,1});
                    l2 = zeros(1,numel(size(HL{1})));
                    coder.varsize('c2');
                    for ii = 1:r
                        if (ii == level)
                            c2 = HL{ii,1};
                            l2 = size(c2);
                            break;
                        end
                    end
                    
                    szhh = zeros(level,numel(size(HH{1,1})));
                    szlh = zeros(level,numel(size(LH{1,1})));
                    szhl = zeros(level,numel(size(HL{1,1})));
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        szhl(ii,:,:,:) = size(HL{ii,1});
                        szhh(ii,:,:,:) = size(HH{ii,1});
                        szlh(ii,:,:,:) = size(LH{ii,1});
                    end
                    
                    LH2 = cell(level,1);
                    HL2 = cell(level,1);
                    HH2 = cell(level,1);
                    for ii = 1:level
                        HH2{ii,1} = zeros(szhh(ii,:,:,:),'like',HH{1,1});
                        LH2{ii,1} = zeros(szlh(ii,:,:,:),'like',LH{1,1});
                        HL2{ii,1} = zeros(szhl(ii,:,:,:),'like',HL{1,1});
                    end
                    
                    for ii = 1:100
                        if (ii == level)
                            HL2{ii} = c2;
                        end
                    end
                    
                    LL2 = zeros(l2,'like',LL);
                    
                    OUT = ilwt2(LL2,LH2,HL2,HH2,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
                end
            otherwise
                coder.internal.error('Wavelet:Lifting:UnsupportedOutType');
        end
    case 'HH'
        switch outType
            case 'coefficients'
                OUT = zeros(size(HH{1,1}),'like',LL);
                coder.varsize('OUT');
                for ii = 1:r
                    if (ii == level)
                        OUT = HH{ii,1};
                        break;
                    end
                end
                
            case 'projection'
                if (level == r)
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        if (ii ~= level)
                            HH{ii,1} = zeros(size(HH{ii,1}),'like',...
                                HH{ii,1});
                        end
                        LH{ii,1} = zeros(size(LH{ii,1}),'like',LH{ii,1});
                        HL{ii,1} = zeros(size(HL{ii,1}),'like',HL{ii,1});
                    end
                    
                    LL = zeros(size(LL),'like',LL);
                    OUT = ilwt2(LL,LH,HL,HH,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
                else
                    c2 = coder.nullcopy(HH{r,1});
                    l2 = zeros(1,numel(size(HH{1})));
                    coder.varsize('c2');
                    for ii = 1:r
                        if (ii == level)
                            c2 = HH{ii,1};
                            l2 = size(c2);
                            break;
                        end
                    end
                    
                    szhh = zeros(level,numel(size(HH{1,1})));
                    szlh = zeros(level,numel(size(LH{1,1})));
                    szhl = zeros(level,numel(size(HL{1,1})));
                    for ii = 1:r
                        if ii > level
                            break;
                        end
                        szhl(ii,:,:,:) = size(HL{ii,1});
                        szhh(ii,:,:,:) = size(HH{ii,1});
                        szlh(ii,:,:,:) = size(LH{ii,1});
                    end
                    
                    LH2 = cell(level,1);
                    HL2 = cell(level,1);
                    HH2 = cell(level,1);
                    for ii = 1:level
                        HH2{ii,1} = zeros(szhh(ii,:,:,:),'like',HH{1,1});
                        LH2{ii,1} = zeros(szlh(ii,:,:,:),'like',LH{1,1});
                        HL2{ii,1} = zeros(szhl(ii,:,:,:),'like',HL{1,1});
                    end
                    
                    for ii = 1:100
                        if (ii == level)
                            HH2{ii} = c2;
                        end
                    end
                    
                    LL2 = zeros(l2,'like',LL);
                    
                    OUT = ilwt2(LL2,LH2,HL2,HH2,'LiftingScheme',LS,...
                        'Level',0,"Extension",ext,"Int2Int",I2I);
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

iswv = coder.internal.getParameterValue(pArg.Wavelet, [],varargin{:});
isLS = coder.internal.getParameterValue(pArg.LiftingScheme, [],...
    varargin{:});

if isempty(iswv)  
    if isempty(isLS)
        wv = 'db1';
        LS = liftingScheme('Wavelet',wv);
    else
        if isa(isLS,'liftingScheme')
            LS = isLS;
        else
            coder.internal.error('Wavelet:Lifting:UnsupportedLiftingScheme');
        end
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
                           'lwtcoef2','LEVEL');

isOut = coder.internal.getParameterValue(pArg.OutputType, [],varargin{:});

if isempty(isOut)
    outType = 'coefficients';
else
    outType = isOut;    
end
outType = validatestring(outType,{'coefficients','projection'},...
    'lwtcoef2','OUTTYPE');

isType = coder.internal.getParameterValue(pArg.Type, [],varargin{:});
if isempty(isType)
    type = 'LL';
else
    type = isType;
end

type = validatestring(type,{'LL','LH','HL','HH'},'lwtcoef2','TYPE');

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