function [Ts,Tsduration,plotstring] = convertDuration(Ts)
%   This function is for internal use only. It may change in a future
%   release. This function formats a datetime array or duration array into
%   reasonable units for more stable numerical computation.

%   Copyright 2016-2020 The MathWorks, Inc.

Ts = Ts(:);
% Create a copy of Ts to work on because for datetime arrays we want to
% look at Ts-Ts(1)
Tstmp = Ts;
if isdatetime(Ts)
    Ts = Ts-Ts(1);
    % We do not want to determine most significant unit based on 00:00:00
    % which will be the first element of Ts
    Tstmp = Ts(2:end);
end
tsformat = Tstmp.Format;
% Use first character of format string to determine correct
% duration object method.

if strcmpi(tsformat,'hh:mm:ss') || strcmpi(tsformat,'dd:hh:mm:ss') ...
        || strcmpi(tsformat,'mm:ss') || strcmpi(tsformat,'hh:mm')
    % Convert to Hours,Minutes,Seconds
    [h,m,s] = hms(Tstmp);
    
    % Find the biggest unit
    units = [h m s];
    timeidx = find(units,1,'first');
    [~,timecol] = ind2sub(size(units),timeidx);
    
    switch timecol
        case 1
            if any(h > 4320) 
                tsformat = 'y';
            elseif any(h >= 24) && all(h < 4320)
                tsformat = 'd';
            else
                tsformat = 'h';
            end
        case 2
            tsformat = 'm';
        case 3
            tsformat = 's';
        
    end
else
    tsformat = tsformat(1);
    
end

% Call the appropriate method to create a vector or doubles

switch tsformat
    case 's'
        Ts = seconds(Ts);  
        % we will return the duration array to be consistent but the 
        % internal computation is done on a floating point vector
        Tsduration = seconds(Ts);
        plotstring = 'second';
        
    case 'm'
        Ts = minutes(Ts);        
        Tsduration = minutes(Ts);
        plotstring = 'minute';
        
    case 'h'
        Ts = hours(Ts);        
        Tsduration = hours(Ts);
        plotstring = 'hour';
        
    case 'd'
        Ts = days(Ts);        
        Tsduration = days(Ts);
        plotstring = 'day';
        
    case 'y'
        Ts = years(Ts);
        Tsduration = years(Ts);
        plotstring = 'year';
        
        
end


