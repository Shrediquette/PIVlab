function y = unpadsignal(x,res,origsize)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
if isscalar(res) && isnumeric(x)
    scfs = true;
else
    scfs = false;
end
if scfs
    szX = size(x,2);
    % Prevent from being empty
    origds = 1+fix((origsize-1)./2^res);
    coder.internal.errorIf(origds > szX,...
        'Wavelet:scattering:resnotmatch',origds);
    y = x(:,1:origds,:,:);
else
    y = iUnpadCell(x,res,origsize);
end
%--------------------------------------------------------------------------
function y = iUnpadCell(x,ds,origsize)
if isempty(x)
    y = x;
    return;
else
    nchan = size(x{1},2);
    nbatch = size(x{1},3);
    y = repmat({zeros(0,nchan,nbatch,'like',x{1})},length(x),1);
    for ii = 1:length(x)
        currds = ds(ii);
        szX = size(x{ii},1);
        % Prevent from being empty
        origds = 1+fix((origsize-1)./2^currds);
        coder.internal.errorIf(origds > szX,...
            'Wavelet:scattering:resnotmatch',origds);
        y{ii} = x{ii}(1:origds,:,:);
    end
end



