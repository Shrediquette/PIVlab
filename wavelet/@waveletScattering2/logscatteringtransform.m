function x = logscatteringtransform(x,precision)
% This function is for internal use only. It may be removed or changed in a
% future release.

%   Copyright 2018-2020 The MathWorks, Inc.

narginchk(2,2);
nargoutchk(0,1);
validateattributes(x,{'cell'},{'nonempty'},'LOGSCATTERINGTRANSFORM','X');
if strcmpi(precision,'double')
    factor = realmin('double');
elseif strcmpi(precision,'single')
    factor = realmin('single');
end

if any(strcmpi(x{1}.Properties.VariableNames,'images'))
    type = 'scattering';
elseif any(strcmpi(x{1}.Properties.VariableNames,'coefficients'))
    type = 'wavelet';
else
    type = 'none';
end

% We are assuming this is the output of the scattering transform and that
% we have a cell array of structure arrays
nFB = numel(x);
switch type
    case 'scattering'
    for nL = 1:nFB
        x{nL}.images = cellfun(@(x)log(abs(x)+factor),x{nL}.images,'uni',0);
    end
    case 'wavelet'

    for nL = 1:nFB
        x{nL}.coefficients = cellfun(@(x)log(abs(x)+factor),x{nL}.coefficients,'uni',0);
    end
    otherwise
    error(message('Wavelet:scattering:needsdata'));
end
    
