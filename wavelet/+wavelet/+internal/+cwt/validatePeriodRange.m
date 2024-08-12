function validatePeriodRange(N,sampperiod,p,nv)
% This function is for internal use only. It may change or be removed in a
% future release.

% Copyright 2020 The MathWorks, Inc.

%#codegen

sampPformat = sampperiod.Format;
% Duration arrays must have the same format for all elements.
tsformat1 = p(1).Format;
coder.internal.errorIf(~strcmpi(tsformat1,sampPformat),...
    'Wavelet:cwt:InvalidPeriodFormat');         

switch tsformat1
    case 's'
        p1 = seconds(p(1));
        p2 = seconds(p(2));     
        sampperiod = seconds(sampperiod);
    case 'm'
        p1 = minutes(p(1));
        p2 = minutes(p(2));
        sampperiod = minutes(sampperiod);
    case 'h'
        p1 = hours(p(1));
        p2 = hours(p(2));
        sampperiod = hours(sampperiod);
    case 'd'
        p1 = days(p(1));
        p2 = days(p(2));
        sampperiod = days(sampperiod);
        
    case 'y'
        p1 = years(p(1));
        p2 = years(p(2));   
        sampperiod = years(sampperiod);
end
% Currently this is only being used by scaleSpectrum method.
validateattributes([p1 p2],{'double'},{'increasing'},'scaleSpectrum','PeriodLimits');
NyquistRange = [2*sampperiod N*sampperiod];
if p2 <= NyquistRange(1) || p1 >= NyquistRange(2)
    coder.internal.error('Wavelet:cwt:InvalidPeriodBand',...
        sprintf('%f', NyquistRange(1)),sprintf('%f',NyquistRange(2)));
end
periodsep = log2(p1)-log2(p2) <= -1/nv;

coder.internal.errorIf(~periodsep,'Wavelet:cwt:periodsep',...
    sprintf('%2.2f',-1.0/nv));
