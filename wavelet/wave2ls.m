function varargout = wave2ls(wname,factMode,varargin)
%WAVE2LS Lifting schemes associated to a wavelet.
%   LS = WAVE2LS(W,FACTMODE) returns the lifting scheme or 
%   the cell array of lifting schemes LS associated to the  
%   wavelet which name is W. FACTMODE indicates the type 
%   of factorization from which LS is issued. The valid
%   values for FACTMODE are: 
%     'd' (dual factorization) or 'p' (primal factorization).
%
%   LS = WAVE2LS(W) is equivalent to LS = WAVE2LS(W,'d').
%
%   [LS_d,LS_p] = WAVE2LS(W,'t') or LS_All = WAVE2LS(W,'t')
%   returns the lifting schemes obtained from both factorization.
%
%   In addition, ... = WAVE2LS(...,PropName,Value,...) let's 
%   specify:
%      - the maximum power of the low-pass synthesis Laurent
%        polynomial (POWMAX)
%      - the difference between low-pass and high-pass synthesis
%        Laurent polynomials (DIFPOW)
%      - the tolerance value used to perform the control about 
%        lifting scheme(s) reconstruction (TOLERANCE)
%   The corresponding "PropName" are: 
%        'powmax' , 'difpow' , 'tolerance'
%
%   The default values used for POWMAX, DIFPOW and TOLERANCE are
%   0, 0 and 1.E-8 respectively.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 24-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check input arguments and defaults.
if nargin<2 , factMode = 'd'; end
powMAX = 0;
difPOW = 0;
tolerance = 1.E-8;
nbIn = length(varargin);
for k = 1:2:nbIn
    argNAM = lower(varargin{k});
    argVAL = varargin{k+1};
    switch argNAM
        case 'powmax'    , powMAX = argVAL;
        case 'difpow'    , difPOW = argVAL;
        case 'tolerance' , tolerance = argVAL;
    end
end
factMode = lower(factMode(1));

% Compute the laurent polynomials associated to the wavelet.
[Hs,Gs,~,~,~,~] = wave2lp(wname,powMAX,difPOW);

% Compute lifting schemes.
if nargout>0
    [varargout{1:nargout}] = lp2ls(Hs,Gs,factMode,tolerance);
end
