function [hAX,hs] = plotAntiAnalyticScalogram(cfs,freq,t)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2021 The MathWorks, Inc.

arguments
    cfs
    freq
    t
end

dataType = underlyingType(cfs);
cfs = cat(1,cfs(:,:,1), flip(cfs(:,:,2)));
freq = cat(1,freq,flip(-freq));

[cfs,freq] = gather(cfs,freq);
cmin = min(cfs(:));
cmax = max(cfs(:));
if cmax <= cmin
    cmax = cmin+eps(dataType);
end

hAX = uiaxes('parent',[]);
hAX.Visible = 'off';

hold(hAX,'on');
hs = image('Parent',hAX,...
    'XData',t,'YData',freq,...
    'CData',cfs, ...
    'CDataMapping','scaled');
hAX.YLim = [min(freq),max(freq)];
hAX.XLim = [min(t) max(t)];
hAX.CLim = [cmin cmax];
hAX.Layer = 'top';
hAX.YDir = 'normal';
title(hAX, getString(message('Wavelet:cwt:ScalogramTitle')));
