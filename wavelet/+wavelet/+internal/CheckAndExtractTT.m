function [x,VariableNames] = CheckAndExtractTT(tt)
% This function is for internal use only. It may be changed or removed
% in a future release.

%   Copyright 2017-2020 The MathWorks, Inc.

% Copyright, MathWorks, 2017-2019

% Check the number of variables in the time table
NumVar = numel(tt.Properties.VariableNames);
VariableNames = tt.Properties.VariableNames;
% If there is one variable, that variable must be a vector or matrix
if NumVar == 1
which = find(varfun(@(x) ismatrix(x) && all(isfinite(x(:))),tt,'output','uni'));
if isempty(which)
    error(message('Wavelet:FunctionInput:OneVariableTT'));
else
    x = extractWhich(tt,which);
end


% If the number of variables is greater than 1, then each numeric variable must be
% a vector. We do not support multiple matrix inputs.
elseif NumVar>1 
    % Check that the timetable contains only vectors if there are multiple
    % variables
    if width(tt) > 1 && ~all(varfun(@(n)size(n,2),tt,'OutputFormat','uniform') == 1)
             error(message('Wavelet:FunctionInput:MultipleMatrixTT'));
    end
    % If the previous condition passes, extract the column vectors
    which = find(varfun(@(x) isvector(x) && isnumeric(x) && ...
        all(size(x,2) == 1),tt,'output','uni'));
    if isempty(which)
        error(message('Wavelet:FunctionInput:MultipleMatrixTT'));
    else
        x = extractWhich(tt,which);
        
    end
    
end
    
%---------------------------------------------------------------------
function x = extractWhich(tt,which)
x = [];
for kk = 1:length(which)
    x = [x  tt.(which(kk))]; %#ok<AGROW>
end


    
    

