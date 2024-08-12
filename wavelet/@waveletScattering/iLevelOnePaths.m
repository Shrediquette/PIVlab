function [levelOneTable,nextLevelStart] = iLevelOnePaths(self)
% This function is for internal use only. It may change or be removed
% in a future release.
% 

%  Copyright 2020-2022 The MathWorks, Inc.
%#codegen
% Intialize paths
OSfac = self.OversamplingFactor;
% Read in MATLAB table that holds level-one filter bank.
gparams = self.filterparams{1};
% Initial resolution is 2^0
res = 0;
% For the first filterbank all wavelets are valid
Nwav = numel(gparams.omegapsi);
vwav = (1:Nwav)';
levelOneTable = table(zeros(Nwav,2),zeros(Nwav,1),zeros(Nwav,1),'VariableNames',...
    {'path','log2ds','log2res'});
[~,log2_psi_os] = waveletScattering.log2DecimationFactor(gparams,res,...
    OSfac,vwav);
% Initial downsampling factors
DSFactor = log2_psi_os;
DSFactor = DSFactor(:);
U0 = zeros(Nwav,1);
tmppath = [U0 vwav];
levelOneTable.path = tmppath;
levelOneTable.log2ds = DSFactor;
levelOneTable.log2res = -1*DSFactor;
nextLevelStart = Nwav+1;
































