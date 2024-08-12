function [FactorTAB,minmaxTAB] = eucfacttab(A,B,flagConstREM)
%EUCFACTAB Euclidean factor table for Euclidean division algorithm.
%   [FacTAB,MinMaxTAB] = EUCFACTTAB(A,B)
%
%   EUCFACTTAB(...,flagConstREM)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Apr-2001.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<3 , flagConstREM = 1; end

[EuclideTAB,first] = euclidedivtab(A,B);
FactorTAB = {};
idxFactorise = 0;
for k=first:size(EuclideTAB,1)
    add = EuclideTAB(k,1);
    idx = k;
    while idx>1
        add{end+1} = EuclideTAB{idx,3};
        idx = EuclideTAB{idx,5};    
    end
    if flagConstREM
        addDEC = isconst(add{1});
    else
        addDEC = 1;
    end
    if addDEC
        idxFactorise = idxFactorise+1;
        if ~isempty(FactorTAB)
            dFact = size(FactorTAB,2)-length(add);
            if dFact ~= 0
                FactorTAB = modifyFactorTAB(FactorTAB,idxFactorise);
            end
        end
        FactorTAB(idxFactorise,:) = fliplr(add);
    end
end

[nbDec,nbFact] = size(FactorTAB);
minmaxTAB = zeros(nbDec,2);
minmaxTAB(:,1) = Inf;
for i=1:nbDec
    for j=1:nbFact
        C  = abs(get(FactorTAB{i,j},'coefs'));
        mi = min(C);
        if mi<minmaxTAB(i,1) , minmaxTAB(i,1) = mi; end 
        ma = max(C);
        if ma>minmaxTAB(i,2) , minmaxTAB(i,2) = ma; end 
    end
end   


%-------------------------------------------------------------------%
function FTnew = modifyFactorTAB(FT,idx)

disp(getWavMSG('Wavelet:moreMSGRF:Modif_FactorTAB',idx))
N = size(FT,1);
P = laurpoly(0,0);
TMP = cell(N,1);
for k = 1:N , TMP{k} = P; end
FTnew = [FT(:,1:end-1) , cell(N,1) , FT(:,end)];
%-------------------------------------------------------------------%
