function LS = filt2ls(LoD,HiD,LoR,HiR,outTYPE) %#ok<INUSL>
%FILT2LS Filters to lifting scheme.
%   LS = FILT2LS(LoD,HiD,LoR,HiR) returns the lifting scheme LS associated
%   to the four input filters LoD, HiD, LoR and HiR which are supposed to
%   verify the perfect reconstruction condition.
%     
%   See also LS2FILT, LSINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Jul-2003.
%   Last Revision: 17-Jul-2003.
%   Copyright 1995-2022 The MathWorks, Inc.

if nargin > 4
    outTYPE = convertStringsToChars(outTYPE);
end

if nargin < 5
    flagONE = true;
    outTYPE = 'analysis';
else
    outTYPE = lower(outTYPE);
    switch outTYPE
        case 'analysis' , flagONE = true;
        case 'synthesis' , flagONE = true;
        otherwise    , flagONE = false;
    end
end

[~,~,Hs,Gs,~,~] = filters2lp({LoR,LoD});
[LSs,Ks] = lp2LS('b',Hs,Gs,'s');
[LSa,Ka] = lp2LS('b',Hs,Gs,'a');

switch outTYPE(1)
    case 'a' , LS = liftingScheme('LiftingSteps',LSa,'NormalizationFactors',Ka);
    case 's' , LS = liftingScheme('LiftingSteps',LSs,'NormalizationFactors',Ks);       
end

if flagONE % Only one LS!
    OK = strcmpi(LS.LiftingSteps(1).Type,'predict') || ...
        strcmpi(LS.LiftingSteps(1).Type,'update');
    if ~OK % test for Lazy
        OK = numel(LS.LiftingSteps)==0 &&  ...
            isequal(LS.NormalizationFactors(1),1) && ...
            isequal(LS.NormalizationFactors(2),1);
        if ~OK , LS = liftingScheme; end
    end
end
end