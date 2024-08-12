function [cfs, numDetCoefs, numCoefs] = repackmdwt(xdec)
%   This function is for internal use only. It may change in a future
%   release.

%   Copyright 2019-2020 The MathWorks, Inc.

%#codegen

    coeff_size = length(xdec.cd)+1;

    if isempty(coder.target)
        cfs = [xdec.cd {xdec.ca}];

        numDetCoefs = cell2mat(cellfun(@(x)size(x,1),xdec.cd,'uni',0));
        numCoefs = sum(numDetCoefs) + size(xdec.ca,1);
    else
        cfs = coder.nullcopy(cell(1,coeff_size));
        for j = 1:length(xdec.cd)
            cfs{j} = xdec.cd{j};
        end
        cfs{coeff_size} = xdec.ca;

        
        numDetCoefs = zeros(1,coeff_size-1);
        for i = 1:length(xdec.cd)
            numDetCoefs(i) = size(xdec.cd{i},1);
        end

        numCoefs = sum(numDetCoefs) + size(xdec.ca,1);
    end
end
