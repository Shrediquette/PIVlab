function Fmats = getFmatPyramid(M,PyramidLevels)

load(['+wOFV/wOFVBayesPyd_funcs/Filter Matrices/bior6.8/' num2str(M) '/Fmats.mat'],'Fw','FwInv','N0','N1','N2','N3','N4');
Fmats.FmatPy{1} = cat(3,Fw,FwInv);
Fmats.NiPy{1} = cat(3,N0,N1,N2,N3,N4);

load(['+wOFV/wOFVBayesPyd_funcs/Filter Matrices/Diff/' num2str(M) '/Dmat.mat'],'Dmat');
Fmats.DmatPy{1} = Dmat;

for iii = 1:(PyramidLevels-1)
    load(['+wOFV/wOFVBayesPyd_funcs/Filter Matrices/bior6.8/' num2str(2^(log2(M)-iii)) '/Fmats.mat'],'Fw','FwInv','N0','N1','N2','N3','N4')
    Fmats.FmatPy{iii+1} = cat(3,Fw,FwInv);
    Fmats.NiPy{iii+1} = cat(3,N0,N1,N2,N3,N4);
end


for iii = 1:(PyramidLevels-1)
    load(['+wOFV/wOFVBayesPyd_funcs/Filter Matrices/Diff/' num2str(2^(log2(M)-iii)) '/Dmat.mat'],'Dmat')
    Fmats.DmatPy{iii+1} = Dmat;
end