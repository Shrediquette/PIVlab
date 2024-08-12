function [C,d] = reduce(COld,dOld,precision)
%REDUCE Simplification for Laurent polynomial.
%   [C,D] = REDUCE(COLD,DOLD,PRECISION) returns the "new" values  
%   the cofoefficients C and the maximum degree D for a Laurent
%   polynomial, starting from the corresponding "old" values.
%   COLD and DOLD. The element of COLD which the absolute values
%   are less than PRECISION are set to zero, then the "new"  
%   maximum degree D is computed.
%
%   [C,D] = REDUCE(COLD,DOLD) uses PRECISION = 1E-8.

% Copyright 2004-2020 The MathWorks, Inc.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2001.
%   Last Revision 24-Jun-2003.

if nargin<3 , precision = 1E-8; end

C = COld;
C(abs(C)<precision) = 0;
idxNZ = find(C~=0);
if ~isempty(idxNZ)
    d = dOld-(idxNZ(1)-1);
    idxMin = min(idxNZ);
    idxMax = max(idxNZ);
    C([1:idxMin-1,idxMax+1:length(C)]) = [];
else
    d = 0;
    C = 0;
end

