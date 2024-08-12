function x = logscatteringtransform(x,precision)
% This function is for internal use only. It may be removed or changed in a
% future release.

%   Copyright 2018-2022 The MathWorks, Inc.

%#codegen
if strcmpi(precision,'double')
    factor = realmin('double');
elseif strcmpi(precision,'single')
    factor = realmin('single');
end
if any(strcmpi(x{1}.Properties.VariableNames,'signals'))
    type = 'scattering';
elseif any(strcmpi(x{1}.Properties.VariableNames,'coefficients'))
    type = 'wavelet';
end
% We are assuming this is the output of the scattering transform and that
% we have a cell array of structure arrays
nFB = numel(x);
switch type
    case 'scattering'
    for nL = 1:nFB
        for ii = 1:length(x{nL}.signals)
            x{nL}.signals{ii} = log(abs(x{nL}.signals{ii}+factor));
        end
    end
    case 'wavelet'
    for nL = 1:nFB
        for ii = 1:length(x{nL}.coefficients)
            x{nL}.coefficients{ii} = ...
                log(abs(x{nL}.coefficients{ii})+factor);
        end
    end
    otherwise
    coder.internal.error('Wavelet:scattering:needsdata');
end
    
