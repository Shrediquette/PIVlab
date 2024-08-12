function boundaries = localminBounds(xdft,DFTKeptBins,BW,Norig)
% This function is for internal use only. It may change or be removed in a
% future release
% boundaries = localminBounds(xdft,DFTKeptBins,BW);

% Copyright 2020 The MathWorks, Inc.
%#codegen

M = floor(Norig/2)+1;
DFTKeptBins = DFTKeptBins(:);
posboundaries = cast([],'like',DFTKeptBins);
negboundaries = cast([],'like',DFTKeptBins);
DFTpos = DFTKeptBins(DFTKeptBins < M);
DFTneg = DFTKeptBins(DFTKeptBins > M);
% Logical vector
TFmin = islocalmin(xdft,'MinSeparation',BW);

if ~isempty(DFTpos)
    Npos = length(DFTpos);
    if Npos == 1
        posbnds = [DFTpos M];
    else
        posbnds = DFTpos;
    end
    tmpposbins = zeros(length(posbnds)-1,1,'like',DFTKeptBins);
    for kk = 1:length(tmpposbins)
        LL = posbnds(kk);
        UL = posbnds(kk+1);
        t = 0;
        while LL+BW+t < UL
            if TFmin(LL+BW+t) == 1
                tmpposbins(kk) = LL+BW+t;
                % Break out of while loop
                break;
            end
            t = t+1;
        end
        % If we do not find a local minimum between LL and UL, then default to
        % the geometric mean.
        if tmpposbins(kk) == 0
            tmpposbins(kk) = wavelet.internal.geomean([LL UL],2);
        end
    end
    
    
    posboundaries = tmpposbins;
end

if ~isempty(DFTneg)
    % Always append Norig to negative frequencies
    negbnds = [DFTneg ; Norig];
    
    tmpnegbins = zeros(length(negbnds)-1,1,'like',DFTKeptBins);
    for kk = 1:length(tmpnegbins)
        LL = negbnds(kk);
        UL = negbnds(kk+1);
        t = 0;
        while LL+BW+t < UL
            if TFmin(LL+BW+t) == 1
                tmpnegbins(kk) = LL+BW+t;
                % Break out of while loop
                break;
            end
            t = t+1;
        end
        % If we do not find a local minimum between LL and UL, then default to
        % the geometric mean.
        if tmpnegbins(kk) == 0
            tmpnegbins(kk) = wavelet.internal.geomean([LL UL],2);
        end
        negboundaries = tmpnegbins;
    end
end

boundaries = [posboundaries ; negboundaries];


