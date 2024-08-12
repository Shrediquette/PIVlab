function tt = createTimeTable(rowtimes,x,variablenames)
% This function is for internal use only and may change in a future
% release.

%   Copyright 2017-2020 The MathWorks, Inc.

% Determine the size of x
Xsize = size(x);
% Find the number of variables
NumVar = numel(variablenames);

if NumVar == 1
    tt = timetable(rowtimes,x);
    tt.Properties.VariableNames = variablenames;
elseif NumVar > 1 && Xsize(2) == NumVar
    tt = array2timetable(x,'RowTimes',rowtimes,'VariableNames',variablenames);
else
    error(message('Wavelet:FunctionInput:TTSizeVariableMismatch'));
end
    
         
    

