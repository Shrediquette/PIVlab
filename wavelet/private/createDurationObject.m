function P = createDurationObject(P,Units)
% This function creates a duration object output for continuous wavelet
% analysis routines. The function is for internal use only and may change
% in a future release.
% The function takes either the Periods or the COI input and outputs
%
% 
% P = createDurationObject(P,Units);

%   Copyright 2015-2020 The MathWorks, Inc.



switch Units
    case 'secs'
        
        P = seconds(P);
        
    case 'mins'
        
        P = minutes(P);
        
    case 'hrs'
        
        P = hours(P);
        
    case 'days'
        
        P = days(P);
        
    case 'years'
        
       P = years(P);
    otherwise
        error(message('Wavelet:FunctionInput:IncorrectDuration'));
        
        
end
