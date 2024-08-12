function [LoDN,HiDN,LoRN,HiRN] = liftfilt(LoD,LoR,varargin)
%LIFTFILT Apply elementary lifting steps on filters
%   [LoDN,HiDN,LoRN,HiRN] = LIFTFILT(LoD,LoR,'LiftingSteps',ELS) returns
%   the four filters LoDN, HiDN, LoRN, HiRN obtained by adding an array of
%   elementary lifting steps (ELS) starting from the two filters LoD and
%   LoR. LoD and LoR are lowpass decomposition and reconstruction filters,
%   respectively, associated with a wavelet.
%     If liftingStep.Type = 'update', HiD and LoR are unchanged. Here HiD
%     is the associated highpass decomposition filter.
%     If liftingStep.Type = 'predict', LoD and HiR are unchanged. Here HiR
%     is the associated highpass reconstruction filter.
%
%   [LoDN,HiDN,LoRN,HiRN] = LIFTFILT(LoD,LoR,'NormalizationFactor',NF)
%   scales the filters by the normalization factor NF, where NF is a
%   nonzero scalar.
%
%   LIFTFILT(...) plots the successive "biorthogonal" pairs: ("scaling
%   function", "wavelet").
%
%   % Example: Obtain the four filters for the biorthogonal wavelet bior1.3
%   %  by adding an array of elementary lifting steps to the Haar filters.
%
%   [LoD,HiD,LoR,HiR] = wfilters('haar');
%   els1 = liftingStep('Type','update','Coefficients',[0.125 -0.125],...
%     'MaxOrder',0);
%   els2 = liftingStep('Type','update','Coefficients',[0.125 -0.125],...
%     'MaxOrder',1);
%   twoels = [els1;els2];
%
%   [LoDN,HiDN,LoRN,HiRN] = liftfilt(LoD,LoR,'LiftingSteps',twoels);
% 
%   See also laurentPolynomial, liftingStep.

%   Copyright 1995-2021 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(2,6)
if nargin > 2
    [ELS,NF] = parseInputs(varargin{:});
else
    ELS = liftingStep();
    NF = 1;
end

[Ha,Ga,Hs,Gs] = filters2lp({LoR,LoD}); 
Har = reflect(Ha);
Gar = reflect(Ga);
[HaN,GaN,HsN,GsN] = wlift(Har,Gar,Hs,Gs,ELS,NF);

if nargout > 0
    [LoDN,HiDN,LoRN,HiRN] = lp2filters(reflect(HaN),reflect(GaN),HsN,GsN);
end

if nargout == 0 && coder.target('MATLAB')
    [LoD2,HiD2,LoR2,HiR2] = lp2filters(reflect(HaN),reflect(GaN),HsN,GsN);
    bswfun(LoD2,HiD2,LoR2,HiR2,'plot');
end

if ~coder.target('MATLAB')
    nargoutchk(4,4);
end

end

function [HaN,GaN,HsN,GsN] = wlift(Ha,Ga,Hs,Gs,ELS,NF) 
%WLIFT Make elementary lifting step.
%   [HaN,GaN,HsN,GsN] = WLIFT(Ha,Ga,Hs,Gs,ELS,NF) returns the four Laurent
%   polynomials HaN, GaN, HsN and GsN obtained by an "elementary lifting
%   step" (ELS) starting from the four Laurent polynomials Ha, Ga, Hs and
%   Gs.
%
%   If TYPE = 'update' , Ga and Hs are not changed and
%      GsN(z) = Gs(z) + Hs(z) * T(z^2) 
%      HaN(z) = Ha(z) - Ga(z) * T(1/z^2)   
%
%   If TYPE = 'predict' , Ha and Gs are not changed and
%      HsN(z) = Hs(z) + Gs(z) * T(z^2)  
%      GaN(z) = Ga(z) - Ha(z) * T(1/z^2)
%
%   The normalization factor changes Ha, Ga, Hs and Gs as follows:
%      Hs(z) = Hs(z) * NF ;  Gs(z) = Gs(z) / NF
%      Ha(z) = Ha(z) / NF;   Ga(z) = Ga(z) * NF

% Check arguments.

Ha2 = Ha;
Hs2 = Hs;
Ga2 = Ga;
Gs2 = Gs;

for k = 1:length(ELS)
    type = ELS(k).Type;
    switch type
        case {'predict','update'}
            C = ELS(k).Coefficients;
            M = ELS(k).MaxOrder;
            LP = laurentPolynomial('Coefficients',C,'MaxOrder',M);
            P = dyadup(LP);
            
            switch type
                case 'update'  
                    Gs2 = Gs + Hs * P;
                    Ha2 = Ha - Ga * reflect(P);
                    Hs2 = Hs;
                    Ga2 = Ga;
 
                case 'predict' 
                    Hs2 = Hs + Gs * P;
                    Ga2 = Ga - Ha * reflect(P);
                    Gs2 = Gs;
                    Ha2 = Ha;
            end
    end
    
    Ha = Ha2;
    Ga = Ga2;
    Hs = Hs2;
    Gs = Gs2;
    
end

HsN = rescale(Hs,NF); 
GsN = rescale(Gs,1/NF);
HaN = rescale(Ha,1/NF); 
GaN = rescale(Ga,NF);
end

function [ELS,NF] = parseInputs(varargin)

% parser for the name value-pairs
parms = {'LiftingSteps','NormalizationFactor'};

% Select parsing options.
poptions = struct('PartialMatching','unique');
pstruct = coder.internal.parseParameterInputs(parms,...
    poptions,varargin{:});
LS = coder.internal.getParameterValue(pstruct.LiftingSteps, ...
    [],varargin{:});
NF2 = coder.internal.getParameterValue(pstruct.NormalizationFactor, [],...
    varargin{:});

if isempty(NF2)
    NF = 1;
else
    validateattributes(NF2,{'numeric'},{'scalar','nonempty','finite'},...
        'liftfilt','NF2')
    NF = NF2;
end

if isempty(LS)
    ELS = liftingStep();
else
     coder.internal.assert(isa(LS,'struct'),...
                            'Wavelet:Lifting:UnsupportedLiftingStep');
   ELS = LS;                     
end

end
