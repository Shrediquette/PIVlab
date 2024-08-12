function Fmats = getFmatPyramid(M,PyramidLevels)

%check if the filter matrix exists, if it doesn't generate them
if ~exist(['+wOFV/Filter Matrices/bior6.8/' num2str(M) '/Fmats.mat'],'file')
    uiwait(warndlg(['Wavelet filter matrices do not exist. They are downloaded and stored for later use now.' newline newline 'Please watch the command window for progress messages.'],'No filter matrices found','modal'));
    wOFV.FetchFilterMatrices();
end

load(['+wOFV/Filter Matrices/bior6.8/' num2str(M) '/Fmats.mat'],'Fw','FwInv','N0','N1','N2','N3','N4');
Fmats.FmatPy{1} = cat(3,Fw,FwInv);
Fmats.NiPy{1} = cat(3,N0,N1,N2,N3,N4);

load(['+wOFV/FD Matrices/' num2str(M) '/Dmat.mat'],'Dmat');
Fmats.DmatPy{1} = Dmat;

for iii = 1:(PyramidLevels-1)
    load(['+wOFV/Filter Matrices/bior6.8/' num2str(2^(log2(M)-iii)) '/Fmats.mat'],'Fw','FwInv','N0','N1','N2','N3','N4')
    Fmats.FmatPy{iii+1} = cat(3,Fw,FwInv);
    Fmats.NiPy{iii+1} = cat(3,N0,N1,N2,N3,N4);
end


for iii = 1:(PyramidLevels-1)
    load(['+wOFV/FD Matrices/' num2str(2^(log2(M)-iii)) '/Dmat.mat'],'Dmat')
    Fmats.DmatPy{iii+1} = Dmat;
end