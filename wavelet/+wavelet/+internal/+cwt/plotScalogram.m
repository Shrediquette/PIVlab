function [hAX,hs,hcoi,hArea] = plotScalogram(wt,freq,t,NVargs)
% This function is for internal use only. It may change or be removed in a
% future release.
% plotScalogram(hfig,wt,freq,t,NVargs)

%   Copyright 2021 The MathWorks, Inc.

arguments
    wt
    freq
    t
    NVargs.ga (1,1) {mustBeFloat} = 3
    NVargs.be (1,1) {mustBeFloat} = 20
    NVargs.wavelet {mustBeMember(NVargs.wavelet,{'morse','amor','bump'})} = 'morse'
    NVargs.normfreqflag {mustBeNumericOrLogical} = true
    NVargs.SampleRate {mustBeScalarOrEmpty} = []
    NVargs.ComplexPlot {mustBeMember(NVargs.ComplexPlot,{'separate','oneplot'})} = 'separate';
end
wav = char(NVargs.wavelet);
ga = NVargs.ga;
be = NVargs.be;
normfreqflag = NVargs.normfreqflag;
dataType = underlyingType(wt);
if ~isempty(NVargs.SampleRate)
    normfreqflag = false;
end
SampleRate = NVargs.SampleRate;
TimeTbl = isdatetime(t) || isduration(t);
if TimeTbl
    OrigTimes = t;
    if isdatetime(OrigTimes)
        t = OrigTimes - OrigTimes(1);
    end
    t = seconds(t);
end

[FourierFactor,sigmaT] = wavelet.internal.cwt.wavCFandSD(wav,ga,be);
[wt,freq] = gather(wt,freq);
cmin = min(wt(:));
cmax = max(wt(:));
if cmax <= cmin
    cmax = cmin+eps(dataType);
end

antiAnalytic = (ndims(wt) == 3);
coifactorfreq = 1;
coifactortime = 1;
if normfreqflag
    frequnitstrs = wavelet.internal.wgetfrequnitstrs;
    ylbl = frequnitstrs{1};
elseif ~normfreqflag
    [freq,eng_exp,uf] = engunits(freq,'unicode');
    coifactorfreq = eng_exp;
    ylbl = wavelet.internal.wgetfreqlbl([uf 'Hz']);

end

if normfreqflag
    ut = 'Samples';
    dt = 1;
    coifactortime = 1;
elseif ~normfreqflag
    [t,eng_exp,ut] = engunits(t,'unicode','time');
    coifactortime = eng_exp;
    dt = mean(diff(t));
end

N = size(wt,2);

% We have to recompute the cone of influence for whatever scaling
% is done in time and frequency by engunits

FourierFactor = FourierFactor/coifactorfreq;
sigmaT = sigmaT*coifactortime;
coiScalar = FourierFactor/sigmaT;
samples = createCoiIndices(N);
coi = coiScalar*dt*samples;
invcoi = 1./coi;
invcoi(invcoi>max(freq)) = max(freq);
if TimeTbl && isdatetime(OrigTimes)
    T = datenum(OrigTimes);
    datetimeLabelFlag = true;
else
    T = t;
    datetimeLabelFlag = false;

end

if datetimeLabelFlag
    xlbl = getString(message('Wavelet:getfrequnitstrs:Date'));
else
    xlbl = [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
end

if ~antiAnalytic
    
    AX = uiaxes('parent',[],'Visible','off');
    % The following axes hold must occur before any plotting or the default
    % interactivity is restored
    hold(AX,'on');
    hs = image('Parent',AX,...
        'XData',T,'YData',freq,...
        'CData',wt, ...
        'CDataMapping','scaled');
    AX.YLim = [min(freq),max(freq)];
    AX.XLim = [min(T) max(T)];
    AX.Layer = 'top';
    AX.YDir = 'normal';
    AX.YScale = 'log';

    title(AX, getString(message('Wavelet:cwt:ScalogramTitle')));
    ylabel(AX, ylbl)
    xlabel(AX, xlbl)

    hcoi = plot(AX,T,invcoi,'w--','linewidth',2);

    baselevel = min([min(AX.YLim) min(invcoi)]);
    A1 = area(AX,T,invcoi,baselevel);
    A1.EdgeColor = 'none';
    A1.FaceColor = [0.8 0.8 0.8];
    alpha(A1,0.4);
    A1.PickableParts = 'none';

    hold(AX,'off');
    hArea = A1;
    hAX = AX;

elseif antiAnalytic && startsWith(NVargs.ComplexPlot,'s')

    titleString = {getString(message('Wavelet:cwt:ScalogramTitle'));...
        getString(message('Wavelet:cwt:ScalogramTitlePos'))};
    titleString2 = getString(message('Wavelet:cwt:ScalogramTitleNeg'));


    hAX = gobjects(2,1);
    hAX(1) = uiaxes('Parent',[],'Visible','off');

    hold(hAX(1),'on');
    hs1 = image('Parent',hAX(1),...
        'XData',T,'YData',freq,...
        'CData',wt(:,:,1), ...
        'CDataMapping','scaled');

    hAX(1).YLim = [min(freq),max(freq)];
    hAX(1).XLim = [min(T) max(T)];
    hAX(1).CLim = [cmin cmax];
    hAX(1).Layer = 'top';
    hAX(1).YDir = 'normal';
    hAX(1).YScale = 'log';

    title(hAX(1), titleString);

    hcoi1 = plot(hAX(1),T,invcoi,'w--','linewidth',2);
    if datetimeLabelFlag
        datetick('x','KeepLimits');
    end
    baselevel = min([min(hAX(1).YLim) min(invcoi)]);
    A1 = area(hAX(1),T,invcoi,baselevel);
    A1.EdgeColor = 'none';
    A1.FaceColor = [0.8 0.8 0.8];
    alpha(A1,0.4);
    A1.PickableParts = 'none';
    hold(hAX(1),"off");

    hAX(2) = uiaxes('Parent',[],'Visible','off');

    hold(hAX(2),'on');
    hs2 = image('Parent',hAX(2),...
        'XData', T,'YData', freq,...
        'CData',wt(:,:,2), ...
        'CDataMapping','scaled');

    hAX(2).YLim = [min(freq),max(freq)];
    hAX(2).XLim = [min(T) max(T)];
    hAX(2).CLim = [cmin cmax];
    hAX(2).Layer = 'top';
    hAX(2).YDir = 'normal';
    hAX(2).YScale = 'log';

    title(hAX(2), titleString2);


    hcoi2 = plot(hAX(2),T,invcoi,'w--','linewidth',2);
    if datetimeLabelFlag
        datetick('x','KeepLimits');
    end
    baselevel = min([min(hAX(2).YLim) min(invcoi)]);
    A2 = area(hAX(2),T,invcoi,baselevel);
    A2.EdgeColor = 'none';
    A2.FaceColor = [0.8 0.8 0.8];
    alpha(A2,0.4);
    A2.PickableParts = 'none';

    ylabel(hAX,ylbl);
    xlabel(hAX,xlbl);

    hAX(1).Tag = 'wpos';
    hAX(2).Tag = 'wneg';
    hold(hAX(2),'off');
    hs = [hs1 hs2];
    hcoi = [hcoi1 hcoi2];
    hArea = [A1 A2];
else
    [hAX,hs] = ...
        wavelet.internal.cwt.plotAntiAnalyticScalogram(wt,freq,t);
    hAX.XLabel.String = xlbl;
    hAX.YLabel.String = ylbl;
end



function indices = createCoiIndices(N)
if signalwavelet.internal.isodd(N)  % is odd
    indices = 1:ceil(N/2);
    indices = [indices, fliplr(indices(1:end-1))];
else % is even
    indices = 1:N/2;
    indices = [indices, fliplr(indices)];
end


