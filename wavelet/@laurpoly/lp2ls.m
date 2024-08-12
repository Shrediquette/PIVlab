function varargout = lp2ls(Hs,Gs,factMode)
%LP2LS Laurent polynomial to lifting schemes.
%   LS = LP2LS(HS,GS,FACTMODE) returns the lifting scheme or the cell array
%   of lifting schemes LS associated to the Laurent polynomials HS and GS.
%   FACTMODE indicates the type of factorization from which LS is issued.
%   The valid values for FACTMODE are:
%     'd' (dual factorization) or 'p' (primal factorization).
%
%   LS = LP2LS(HS,GS) is equivalent to LS = LP2LS(HS,GS,'d').
%
%   [LS_d,LS_p] = LP2LS(HS,GS,'t') or LS_All = LP2LS(HS,GS,'t') returns the
%   lifting schemes obtained from both factorization.
%
%   In addition, ... = LP2LS(...,TOLERANCE) performs a control about
%   lifting scheme(s) reconstruction property using the tolerance value
%   TOLERANCE. The default value for TOLERANCE is 1.E-8.

%   Copyright 1995-2020 The MathWorks, Inc.

% Check input arguments.
if (nargin == 2)
        factMode = 'd';
end
factMode = lower(factMode(1));

% Synthesis Polyphase Matrix factorizations
[MatFACT,~] = ppmfact(Hs,Gs); 
nbFACT = length(MatFACT);

% Compute lifting schemes. 
if nbFACT>0
    switch factMode
        case 't' 
            % Compute Analyzis Polyphase Matrix Factorizations.
            [dual_APMF,prim_APMF] = pmf2apmf(MatFACT,factMode);

            % Compute Lifting Steps.
            dual_LS = apmf2ls(dual_APMF);
            prim_LS = apmf2ls(prim_APMF);
            
            switch nargout
                case 1 , varargout{1} = [dual_LS , prim_LS];
                case 2 , varargout = {dual_LS , prim_LS};
            end
           
        case {'d','p'}   % dual_LS or prim_LS
            % Compute Lifting Steps.
            APMF = pmf2apmf(MatFACT,factMode);
            LS = apmf2ls(APMF);
            varargout = LS;
            
        otherwise
            error(message('Wavelet:FunctionArgVal:Invalid_FactVal'))
    end
else
    varargout = cell(1,nargout);
end
