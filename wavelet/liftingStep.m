function S = liftingStep(varargin)
%LIFTINGSTEP Elementary lifting step
%   S = liftingStep('Type',TP,'Coefficients',CFS,'MaxOrder',MAXORDER)
%   returns a structure that corresponds to a single lifting step of the
%   specified type, coefficients, and maximum order. TP can be 'predict' or
%   'update'. CFS and MAXORDER define the Laurent polynomial that
%   corresponds to the Z-transform of the lifting filter. CFS is a vector
%   of Laurent polynomial coefficients. MAXORDER is an integer that
%   specifies the maximum order of the Laurent polynomial. This corresponds
%   to the order of the first element in CFS.
%
%   The liftingStep structure has the following fields:
%
%   Type          - Type of lifting step can be 'predict' and 'update'
%
%   Coefficients  - Laurent polynomial coefficients
%
%   MaxOrder      - Maximum order of the lifting filter
%
%   % Example:
%   % Create an update lifting step that corresponds to the specified
%   % Laurent polynomial coefficients and maximum filter order.
%
%   ls = liftingStep('Type','update','Coefficients',[-sqrt(3) 1],'MaxOrder',0);
%
%   See also LIFTINGSCHEME

%   Copyright 2020 The MathWorks, Inc.

%#codegen

if nargin > 0
    [type,coef,maxOrd] = parseInputs(varargin{:});
    coder.varsize('type',[1 Inf], [0 1]);
    coder.varsize('filtPoly');
    Stmp = struct('Type','','Coefficients',zeros(1,0,'like',coef),'MaxOrder',0);
    coder.varsize('S.Type');
    coder.varsize('S.Coefficients');
    S = repmat(Stmp,1,1);
    S.Type = type;
    S.Coefficients = coef;
    S.MaxOrder = maxOrd;

else
    Stmp = struct('Type','','Coefficients',zeros(1,0),'MaxOrder',0);
    coder.varsize('S.Type');
    coder.varsize('S.Coefficients');
    S = repmat(Stmp,0,1);
end

end

function [type,filtPoly,ordMax] = parseInputs(varargin)
% parser for the name value-pairs
parms = {'Type','Coefficients','MaxOrder'};

% Select parsing options.
poptions = struct('PartialMatching','unique');
pstruct = coder.internal.parseParameterInputs(parms,poptions,varargin{:});
tp = coder.internal.getParameterValue(pstruct.Type, [],...
    varargin{:});
c = coder.internal.getParameterValue(pstruct.Coefficients, [],...
    varargin{:});
ord = coder.internal.getParameterValue(pstruct.MaxOrder, [],...
    varargin{:});

if isempty(tp)
    type = '';
else
    % set the type of the lifting step
    validstr = {'predict','update',''};
    type = validatestring(tp,validstr,'liftingStep');
end

if isempty(c)
    filtPoly = zeros(1,0);
else
    validateattributes(c, {'numeric'},{'vector','nonnan'},'liftingStep');
    filtPoly = c;
end

if isempty(ord)
    ordMax = 0;
else
    validateattributes(ord, {'numeric'},{'integer','scalar','real'},...
    'liftingStep');
    ordMax = ord;
end
end

