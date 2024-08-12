function Smat = scatteringmatrix(S)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

cfs = S.images;
IsRGB =  all(cell2mat(cellfun(@ndims,cfs,'uni',0)) == 3);
if ~IsRGB
    Smat = cat(3,cfs{:});
    Smat = permute(Smat,[3 2 1]);
else
    Smat = cat(4,cfs{:});
    Smat = permute(Smat,[4 2 1 3]);
end
