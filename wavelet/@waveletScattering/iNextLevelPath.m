function [nextpath,parentchild,updated3dB,nextLevelStart] = ...
    iNextLevelPath(prevtable,prev3dB,ftable,OSfac,OptimizePath,startidx)
% This file is for internal use only. It may change or be removed in a
% future release.
%
% ParentChild = ...
%   nextLevelPath(PrevPathMat,ftable,OSfac,OptimizePath,decimate);

%   Copyright 2020-2022 The MathWorks, Inc.


% table variables are path, log2ds, log2res
%#codegen
prevpath = prevtable.path;
M = size(prevpath,1);
N = size(prevpath,2);
ResFactor = prevtable.log2res;
updatedPath = zeros(0,N+1);
updatedDS = zeros(0,1);
updatedRes = zeros(0,1);
updated3dB = zeros(0,1);
tmpParentChild = repmat({zeros(0,1)},M,1);
nextLevelStart = startidx;
jj = 1;
for kk = 1:M    
    curr3dBbw = prev3dB(kk);    
    currRes = ResFactor(kk);
    % For the current resolution and the next filterbank, which
    % filters can be downsampled at least as much as the current
    % value
    vwav =  waveletScattering.frequencyoverlap(currRes,ftable);
    if OptimizePath
        vwav = waveletScattering.optimizePath(vwav,curr3dBbw,ftable);
    end
    Nvaw = numel(vwav);    
    if Nvaw
        [~, log2_psi_os] = waveletScattering.log2DecimationFactor(ftable,...
            currRes,OSfac,vwav);
        newds = log2_psi_os;
        % Now we need to update the resolutions
        newres = -log2_psi_os+currRes;
        % Reshape as column vectors
        vwav = vwav(:);
        newds = newds(:);
        newres = newres(:);
        curr3dB = ftable.psi3dBbw(vwav);
        curr3dB = curr3dB(:);
        prevdata = prevpath(kk,:);
        prevdata = repmat(prevdata,Nvaw,1);
        newPath = [prevdata vwav];
        updatedPath = [updatedPath ; newPath]; %#ok<*AGROW>
        updatedDS = [updatedDS ; newds];
        updatedRes =  [updatedRes ; newres];
        updated3dB = [updated3dB ; curr3dB];
        tmpParentChild{jj} = startidx:startidx+Nvaw-1;
        nextLevelStart = startidx+Nvaw;
        startidx = startidx+Nvaw;
        jj = jj+1;
    end    
end
Nchild = jj-1;
nextpath = table(updatedPath,updatedDS,updatedRes,'VariableNames',...
    {'path','log2ds','log2res'});
parentchild = cell(Nchild,1);
for ii = 1:Nchild
    parentchild{ii} = tmpParentChild{ii};
end









