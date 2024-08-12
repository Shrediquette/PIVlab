function boundaries = geomeanBounds(DFTKeptBins,Norig)
% This function is for internal use only. It may change or be removed in a
% future release.
% boundaries = geomeanBounds(DFTKeptBins,Norig);

% Copyright 2020 The MathWorks, Inc.

%#codegen
DFTKeptBins = DFTKeptBins(:);
posboundaries = cast([],'like',DFTKeptBins);
negboundaries = cast([],'like',DFTKeptBins);
M = floor(Norig/2)+1;
DFTpos = DFTKeptBins(DFTKeptBins < M);
DFTneg = DFTKeptBins(DFTKeptBins > M);
if ~isempty(DFTpos)
    Npos = length(DFTpos);
    if Npos == 1
        posboundaries = ceil(wavelet.internal.geomean([DFTpos M],2));
    else
        posboundaries = zeros(Npos-1,1,'like',DFTpos);
        for ii = 1:Npos-1
            posboundaries(ii) = ...
                ceil(wavelet.internal.geomean([DFTpos(ii) DFTpos(ii+1)],2));
            
        end
        
    end
    
end

if ~isempty(DFTneg)
    % Always apped Norig to the negative boundaries
    DFTnegtmp = [DFTneg ; Norig];
    Nneg = length(DFTnegtmp);
    negboundaries = zeros(Nneg-1,1,'like',DFTneg);
    for ii = 1:Nneg-1
        negboundaries(ii) = ...
            ceil(wavelet.internal.geomean([DFTnegtmp(ii) DFTnegtmp(ii+1)],2));
        
    end
    
end

boundaries = [posboundaries ; negboundaries];





