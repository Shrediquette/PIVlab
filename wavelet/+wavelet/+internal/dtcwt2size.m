function [szD,szA] = dtcwt2size(Nr,Nc,Nchan,NIm,level)
% This function is for internal use only. It may be changed or removed in a
% future release.
% [szD,szA] = dtcwt2size(Nr,Nc,Nchan,NIm,level);

% Copyright 2019-2020 The MathWorks, Inc.

%#codegen

szD = coder.nullcopy(zeros(level,5));
szA = coder.nullcopy(zeros(level,4));

if signalwavelet.internal.isodd(Nr)
    Nr = Nr+1;
end

if signalwavelet.internal.isodd(Nc)
    Nc = Nc+1;
end

NrA = Nr;
NcA = Nc;
szA(1,:) = [NrA NcA Nchan NIm];


for ii = 2:level

    tfR = mod(NrA,4);
    tfC = mod(NcA,4);
    
    if tfR
        NrA = NrA+2;
    
    end

    if tfC 
        NcA= NcA+2;
    end

    szA(ii,:) = [NrA/2 NcA/2 Nchan NIm];
    NrA = szA(ii,1);
    NcA = szA(ii,2);
   

end

for ii = 1:level

    szD(ii,:) = [ceil(szA(ii,1)/2) ceil(szA(ii,2)/2) Nchan 6 NIm];

end
