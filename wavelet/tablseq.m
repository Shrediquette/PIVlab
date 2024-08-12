function eqTAB = tablseq(LSTable,tolerance)
%TABLSEQ Equality table for lifting schemes.
%   For a cell array of lifting schemes LSCell, 
%   EQTAB = TABLSEQ(LSCell) returns a cell array
%   of vectors which is of the same size.
%   Each vector EQTAB(j) contains all the indices k
%   such that LSCell{k} is equal to LSCell{j}.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-May-2001.
%   Last Revision: 30-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<2 , tolerance = 1E-8; end

N = length(LSTable);
eqTAB = cell(1,N);
for i = 1:N
    for j=i+1:N
        if areEQUAL(LSTable{i},LSTable{j},tolerance)
            eqTAB{i}(end+1) = j;
            eqTAB{j}(end+1) = i;
        end
    end
end


%----------------------------------------------------------------
function OK = areEQUAL(LS1,LS2,tolerance)

NBlift = size(LS1,1);
OK = (size(LS1,1) == size(LS2,1)) && ...
    (abs(LS1{NBlift,1}-LS2{NBlift,1})<tolerance);
if ~OK,  return; end
for i=1:NBlift-1
    OK = LS1{i,1}==LS2{i,1} && LS1{i,3}==LS2{i,3} && ...
         isEQ_Filter(LS1{i,2},LS2{i,2},tolerance);
    if ~OK,  return; end
end
%----------------------------------------------------------------
function OK = isEQ_Filter(F1,F2,tolerance)

OK =  (length(F1)==length(F2)) && max(abs(F1-F2))<tolerance;
%----------------------------------------------------------------
