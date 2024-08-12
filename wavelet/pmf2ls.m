function  varargout = pmf2ls(PMF,factMode)
%PMF2LS Polyphase matrix factorization(s) to lifting scheme(s).
%   LS = PMF2LS(PMF,FACTMODE) returns the lifting scheme LS 
%   corresponding to the Laurent polyphase matrices factorization
%   PMF which is a cell array of Laurent matrices. FACTMODE 
%   indicates the type of factorization to be use with PMF.
%   The valid values for FACTMODE are: 
%      'd' (dual factorization) or 'p' (primal factorization).
%
%   LS = PMF2LS(PMF), is equivalent to LS = PMF2LS(PMF,'d') .
%
%   If PMFC is a cell array of factorizations, LSC = PMF2LS(PMFC,...)
%   returns a cell array of Lifting Schemes. For each k, LSC{k} 
%   is associated to the factorization PMFC{k}.
%
%   [LS_d,LS_p] = PMF2LS(PMF,'t') returns the two possible lifting
%   schemes.
%
%   See also LS2PMF.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Apr-2001.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if isempty(PMF) , varargout = cell(1,nargout); return; end
if nargin<2 , factMode = 'd'; end

%-------------------------------------------%
% PMF2APMF is an involutive transformation. %
% So:  M == PMF2APMF(PMF2APMF(M))           %
% And: APMF2PMF == PMF2APMF                 %
%-------------------------------------------%
factMode = lower(factMode(1));
switch factMode
    case 't' 
        [APMF_d,APMF_p] = pmf2apmf(PMF,factMode);
        varargout{1} = apmf2ls(APMF_d);
        varargout{2} = apmf2ls(APMF_p);
    case {'d','p'}
        APMF = pmf2apmf(PMF,factMode);
        varargout{1} = apmf2ls(APMF);
        
    otherwise
        error(message('Wavelet:FunctionArgVal:Invalid_FactVal'))
end
