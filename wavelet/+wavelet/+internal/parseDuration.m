function [Ts, Tsduration, plotstring, Units, dtFuncHand, funcName] = ...
    parseDuration(Ts, tsformat)
% This function is for internal use only. It may change or be removed in a
% future release.

% Copyright 2018-2020 The MathWorks, Inc.

switch tsformat
    case 's'
        Ts = seconds(Ts);
        Tsduration = seconds(Ts);
        Units = 'secs';
        plotstring = 'seconds';
        dtFuncHand = @(x)seconds(x);
    case 'm'
        Ts = minutes(Ts);
        Tsduration = minutes(Ts);
        Units = 'mins';
        plotstring = 'minutes';
        dtFuncHand = @(x)minutes(x);
    case 'h'
        Ts = hours(Ts);
        Tsduration = hours(Ts);
        Units = 'hrs';
        plotstring = 'hours';
        dtFuncHand = @(x)hours(x);
    case 'd'
        Ts = days(Ts);
        Tsduration = days(Ts);
        Units = 'days';
        plotstring = 'days';
        dtFuncHand = @(x)days(x);
    case 'y'
        Ts = years(Ts);
        Tsduration = years(Ts);
        Units = 'years';
        plotstring = 'years';
        dtFuncHand = @(x)years(x);
    otherwise
        error(message('Wavelet:FunctionInput:IncorrectDuration'));
end
funcName = [plotstring 's'];
