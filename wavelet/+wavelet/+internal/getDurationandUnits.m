function [dt,Units,dtFuncHand,PlotString] = getDurationandUnits(Ts)
%   This function is for internal use only. It may change or be removed in 
%   a future release.
%   This function returns the sampling interval and a format string
%   for plotting the wavelet coherence in time and frequency.
%   The Units string is only for plotting.

%   Copyright 2015-2020 The MathWorks, Inc.

% Store original format for plotting
origformat = Ts.Format;
% From this we will compute the right unit for conversion from hms()
% we find the first nonzero entry of hms().
tsformat = origformat;
% Use first character of format string to determine correct
% duration object method.

% if strcmpi(tsformat,'hh:mm:ss') || strcmpi(tsformat,'dd:hh:mm:ss') ...
%         || strcmpi(tsformat,'mm:ss') || strcmpi(tsformat,'hh:mm')
%     % Convert to Hours,Minutes,Seconds
%     [h,m,s] = hms(Ts);
%     % Find the biggest unit
%     timeidx = find([h m s],1,'first');
%     switch timeidx
%         case 1
%             if h>=24
%                 tsformat = 'd';
%             else
%                 tsformat = 'h';
%             end
%         case 2
%             tsformat = 'm';
%         case 3
%             tsformat = 's';
%         
%     end
% else
    tsformat = tsformat(1);
    
% end

% Using the same time units as engunits. Units in engunits are
% not localized.
% time_units = {'secs','mins','hrs','days','years'};
switch tsformat
    case 's'
        dt = seconds(Ts);
        Units = 'secs';
        PlotString = 'second';
        dtFuncHand = @(x)seconds(x);
    case 'm'
        dt = minutes(Ts);
        Units = 'mins';
        PlotString = 'minute';
        dtFuncHand = @(x)minutes(x);
    case 'h'
        dt = hours(Ts);
        Units = 'hrs';
        PlotString = 'hour';
        dtFuncHand = @(x)hours(x);
    case 'd'
        dt = days(Ts);
        Units = 'days';
        PlotString = 'day';
        dtFuncHand = @(x)days(x);
    case 'y'
        dt = years(Ts);
        Units = 'years';
        PlotString = 'year';
        dtFuncHand = @(x)years(x);
    otherwise
        error(message('Wavelet:FunctionInput:IncorrectDuration'));
end

