function margplot(wt,marg,freq,coi,varargin)
%

%   Copyright 2020 The MathWorks, Inc.

N = size(wt,2);
Ns = size(wt,1);
assert(size(marg,1) == Ns || size(marg,2) == N,...
    'Wavelet:cwt:UnsupportedMarg');
fs = [];
ut = '';
stype = varargin{1};
sampfreq = true;
sampperiod = false;
normfreqflag = false;

if islogical(varargin{2})
    normfreqflag = varargin{2};
    sampfreq = false;
elseif isnumeric(varargin{2})
    fs = varargin{2};    
    
elseif isduration(varargin{2}) 
    Ts = varargin{2};
    [~,ut,dtfunch] = wavelet.internal.getDurationandUnits(Ts);
    Ts = dtfunch(Ts);
    sampfreq = false;
    sampperiod = true;
    
end
if sampfreq && ~isempty(fs)
    t = 0:1/fs:(N*1/fs)-1/fs;
elseif normfreqflag
    t = 0:N-1;
elseif ~sampfreq && sampperiod
    t = 0:Ts:(N-1)*Ts;
end

if normfreqflag || sampfreq
    margfreqplot(wt,marg,freq,t,coi,fs,stype);
else
    margperiodplot(wt,marg,freq,t,coi,stype,ut);
end



%--------------------------------------------------------------------------
function margfreqplot(wt,marg,freq,t,coi,fs,stype)
ut = 'secs';
Ns = size(wt,1);
% Obtain color limits for scalogram plot
cmin = min(abs(wt(:)));
cmax = max(abs(wt(:)));
% Edge case. MATLAB allows single to be added to double. This should never
% get hit in practice
if cmax <= cmin
     cmax = cmin+sqrt(eps('single'));
end
% Determine whether we have a complex-valued signal input
antiAnalytic = (ndims(wt) == 3);
if antiAnalytic
    hax = gobjects(4,1);
else
    hax = gobjects(2,1);
end
margtime = false;
if size(marg,1) == Ns
    margtime = true;
end

[labsR,labsC] = labelstructfreq(stype,margtime,ut,fs);

hf = gcf;
clf;
sSize = getSizeforPlot;
wpos = ceil(sSize(3)/2.75);
Lpos = (sSize(3)-wpos)/2;
hpos = ceil(sSize(4)/2.5);
Bpos = (sSize(4)-hpos)/2;
wneg = ceil(sSize(3)/2);
hneg = ceil(sSize(4)/1.75);
Lneg = (sSize(3)-wneg)/2;
Bneg = (sSize(4)-hneg)/2;
% Change Width and Height of figure to accommodate double title
if antiAnalytic
    hf.Position = [Lneg Bneg wneg hneg];    
else
    hf.Position = [Lpos Bpos wpos hpos];    
end

if ~antiAnalytic
    
    if margtime
        tiledlayout(1,2,'Parent',hf);
        hax(1) = nexttile;
        hax(2) = nexttile;
    else
        tiledlayout(2,1,'Parent',hf);
        hax(1) = nexttile;
        hax(2) = nexttile;
    end  
       
    % The following axes hold must occur before any plotting or the default
    % interactivity is restored
    
    image('Parent',hax(1),...
        'XData',t,'YData',freq,...
        'CData',abs(wt), ...
        'CDataMapping','scaled');
    hax(1).YLim = [min(freq),max(freq)];
    hax(1).XLim = [min(t) max(t)];
    hax(1).CLim = [cmin cmax];
    hax(1).Layer = 'top';
    hax(1).YDir = 'normal';
    hax(1).YScale = 'log';
    title(hax(1), getString(message('Wavelet:cwt:ScalogramTitle')));
    xlabel(hax(1), labsR.scx);
    ylabel(hax(1), labsR.scy);
    hcol = colorbar('peer', hax(1));
    hcol.Label.String = getString(message('Wavelet:cwt:Magnitude'));
    hold(hax(1),'on');
    plot(hax(1),t,coi,'w--','linewidth',2);
    baselevel = min([min(hax(1).YLim) min(coi)]);
    A1 = area(hax(1),t,coi,baselevel);
    A1.EdgeColor = 'none';
    A1.FaceColor = [0.8 0.8 0.8];
    alpha(A1,0.4);
    A1.PickableParts = 'none';
    % Plot time-averaged marginal
    
    if margtime
        semilogy(hax(2),marg,freq);
        grid(hax(2),'on');
        hax(2).YLim = [min(freq),max(freq)];
        tspec = getString(message('Wavelet:cwt:tavgp'));
        title(hax(2),tspec);
        xlabel(hax(2),labsR.margx);        
        linkaxes(hax,'y');
    else
        plot(hax(2),t,marg);
        hax(2).XLim = [min(t), max(t)];
        tspec = getString(message('Wavelet:cwt:savgp'));
        title(hax(2),tspec);
        xlabel(hax(2),labsR.margx);
        ylabel(hax(2),labsR.margy);
        grid(hax(2));
        linkaxes(hax,'x');
       
    end
    
   
elseif antiAnalytic
    tiledlayout(2,2,'Parent',hf);
    hax(1) = nexttile;
    hax(2) = nexttile;
    hax(3) = nexttile;
    hax(4) = nexttile;
    % Scalogram axes depend on whether we have margtime true or false
    if margtime
        scax = [1 3];
        mrgax = [2 4];
    else
        scax = [1 2];
        mrgax = [3 4];
    end
    
    
    titleStringsc1 = {getString(message('Wavelet:cwt:ScalogramTitle'));...
        getString(message('Wavelet:cwt:ScalogramTitlePos'))};
    titleStringsc2 = getString(message('Wavelet:cwt:ScalogramTitleNeg'));
    
    
    image('Parent',hax(scax(1)),...
        'XData',t,'YData',freq,...
        'CData',abs(wt(:,:,1)), ...
        'CDataMapping','scaled');
    
    hax(scax(1)).YLim = [min(freq),max(freq)];
    hax(scax(1)).XLim = [min(t) max(t)];
    hax(scax(1)).CLim = [cmin cmax];
    hax(scax(1)).Layer = 'top';
    hax(scax(1)).YDir = 'normal';
    hax(scax(1)).YScale = 'log';
    title(hax(scax(1)), titleStringsc1);
    ylabel(hax(scax(1)), labsC.scyP)
    hcol = colorbar('peer', hax(scax(1)));
    hcol.Label.String = getString(message('Wavelet:cwt:Magnitude'));
    hold(hax(scax(1)),'on');
    plot(hax(scax(1)),t,coi,'w--','linewidth',2);
    baselevel = min([min(hax(scax(1)).YLim) min(coi)]);
    A1 = area(hax(scax(1)),t,coi,baselevel);
    A1.EdgeColor = 'none';
    A1.FaceColor = [0.8 0.8 0.8];
    alpha(A1,0.4);
    A1.PickableParts = 'none';
    
    % Marginal plot
    if margtime
        semilogy(hax(mrgax(1)),marg(:,:,1),freq);
        hax(mrgax(1)).YLim = [min(freq),max(freq)];
        tspec = getString(message('Wavelet:cwt:tavgp'));
        title(hax(mrgax(1)),tspec);
        xlabel(hax(mrgax(1)),labsC.margxP);
        linkaxes([hax(scax(1)) hax(mrgax(1))],'y');
        grid(hax(mrgax(1)));
    else
        plot(hax(mrgax(1)),t,marg(:,:,1));
        hax(mrgax(1)).XLim = [min(t), max(t)];
        tspec = getString(message('Wavelet:cwt:savgp'));
        title(hax(mrgax(1)),tspec);
        xlabel(hax(mrgax(1)),labsC.margxP);
        ylabel(hax(mrgax(1)),labsC.margyP);
        grid(hax(mrgax(1)));
        linkaxes([hax(scax(1)) hax(mrgax(1))],'x');
       
    end       
    
    % The following axes hold must occur before any plotting or the default
    % interactivity is restored
    image('Parent',hax(scax(2)),...
        'XData', t,'YData', freq,...
        'CData',abs(wt(:,:,2)), ...
        'CDataMapping','scaled');
    
    hax(scax(2)).YLim = [min(freq),max(freq)];
    hax(scax(2)).XLim = [min(t) max(t)];
    hax(scax(2)).CLim = [cmin cmax];
    hax(scax(2)).Layer = 'top';
    hax(scax(2)).YDir = 'normal';
    hax(scax(2)).YScale = 'log';
    
    title(hax(scax(2)), titleStringsc2);
    xlabel(hax(scax(2)), labsC.scxN);
    ylabel(hax(scax(2)), labsC.scyN);
    hcol2 = colorbar('peer', hax(scax(2)));
    hcol2.Label.String = getString(message('Wavelet:cwt:Magnitude'));
    
    
    hold(hax(scax(2)),'on');
    plot(hax(scax(2)),t,coi,'w--','linewidth',2);
    baselevel = min([min(hax(scax(2)).YLim) min(coi)]);
    A2 = area(hax(scax(2)),t,coi,baselevel);
    A2.EdgeColor = 'none';
    A2.FaceColor = [0.8 0.8 0.8];
    alpha(A2,0.4);
    A2.PickableParts = 'none';
    hold(hax(scax(2)),'off');
    
    
    hax(scax(1)).Tag = 'wpos';
    hax(scax(2)).Tag = 'wneg';
    
    % Marginal plot
    if margtime
        semilogy(hax(mrgax(2)),marg(:,:,2),freq);
        hax(mrgax(2)).YLim = [min(freq),max(freq)];
        xlabel(hax(mrgax(2)),labsC.margxN);
        grid(hax(mrgax(2)));
        linkaxes([hax(scax(2)) hax(mrgax(2))],'y');
    else
        plot(hax(mrgax(2)),t,marg(:,:,2));
        hax(mrgax(2)).XLim = [min(t), max(t)];
        tspec = getString(message('Wavelet:cwt:savgp'));
        title(hax(mrgax(2)),tspec);
        xlabel(hax(mrgax(2)),labsC.margxN);
        ylabel(hax(mrgax(2)),labsC.margyN);
        grid(hax(mrgax(2)));
        linkaxes([hax(scax(2)) hax(mrgax(2))],'x');
        
    end 
    
end
hf.NextPlot = 'replace';

%-------------------------------------------------------------------------
function margperiodplot(wt,marg,freq,t,coi,stype,ut)
Ns = size(wt,1);
% Obtain color limits for scalogram plot
cmin = min(abs(wt(:)));
cmax = max(abs(wt(:)));
% Determine whether we have a complex-valued signal input
antiAnalytic = (ndims(wt) == 3);
if antiAnalytic
    hax = gobjects(4,1);
else
    hax = gobjects(2,1);
end
margtime = false;
if length(marg) == Ns
    margtime = true;
    
end

[labsR,labsC] = labelstructperiod(stype,margtime,ut);

hf = gcf;
clf;
sSize = getSizeforPlot;
wpos = ceil(sSize(3)/2.75);
Lpos = (sSize(3)-wpos)/2;
hpos = ceil(sSize(4)/2.5);
Bpos = (sSize(4)-hpos)/2;
wneg = ceil(sSize(3)/2);
hneg = ceil(sSize(4)/1.75);
Lneg = (sSize(3)-wneg)/2;
Bneg = (sSize(4)-hneg)/2;
% Change Width and Height of figure to accommodate double title
if antiAnalytic
    hf.Position = [Lneg Bneg wneg hneg];    
else
    hf.Position = [Lpos Bpos wpos hpos];    
end

if ~antiAnalytic
    if margtime
        tiledlayout(1,2,'Parent',hf);
        hax(1) = nexttile;
        hax(2) = nexttile;
    else
        tiledlayout(2,1,'Parent',hf);
        hax(1) = nexttile;
        hax(2) = nexttile;
    end
    
    % The following axes hold must occur before any plotting or the default
    % interactivity is restored
    
    image('Parent',hax(1),...
        'XData',t,'YData',freq,...
        'CData',abs(wt), ...
        'CDataMapping','scaled');
    hax(1).YLim = [min(freq),max(freq)];
    hax(1).XLim = [min(t) max(t)];
    hax(1).CLim = [cmin cmax];
    hax(1).Layer = 'top';
    hax(1).YDir = 'normal';
    hax(1).YScale = 'log';
    xlabel(hax(1),labsR.scx);
    ylabel(hax(1), labsR.scy);
    title(hax(1), getString(message('Wavelet:cwt:ScalogramTitle')));
    hcol = colorbar('peer', hax(1));
    hcol.Label.String = getString(message('Wavelet:cwt:Magnitude'));
    hold(hax(1),'on');
    plot(hax(1),t,coi,'w--','linewidth',2);
    baselevel = max(hax(1).YLim);
    A1 = area(hax(1),t,coi,baselevel);
    A1.EdgeColor = 'none';
    A1.FaceColor = [0.8 0.8 0.8];
    alpha(A1,0.4);
    A1.PickableParts = 'none';
    % Plot time-averaged marginal
    
    if margtime
        semilogy(hax(2),marg,freq);
        grid(hax(2),'on');
        hax(2).YLim = [min(freq),max(freq)];
        xlabel(hax(2),labsR.margx);
        tspec = getString(message('Wavelet:cwt:tavgp'));
        title(hax(2),tspec);
        linkaxes(hax,'y');
    else
        plot(hax(2),t,marg);
        hax(2).XLim = [min(t), max(t)];
        tspec = getString(message('Wavelet:cwt:savgp'));
        title(hax(2),tspec);
        xlabel(hax(2),labsR.margx);
        ylabel(hax(2),labsR.margy);
        grid(hax(2));
        linkaxes(hax,'x');
        
    end
    
    
elseif antiAnalytic
    tiledlayout(2,2,'Parent',hf);
    hax(1) = nexttile;
    hax(2) = nexttile;
    hax(3) = nexttile;
    hax(4) = nexttile;
    % Scalogram axes depend on whether we have margtime true or false
    if margtime
        scax = [1 3];
        mrgax = [2 4];
    else
        scax = [1 2];
        mrgax = [3 4];
    end
    
    titleStringsc1 = {getString(message('Wavelet:cwt:ScalogramTitle'));...
        getString(message('Wavelet:cwt:ScalogramTitlePos'))};
    titleStringsc2 = getString(message('Wavelet:cwt:ScalogramTitleNeg'));
        
    image('Parent',hax(scax(1)),...
        'XData',t,'YData',freq,...
        'CData',abs(wt(:,:,1)), ...
        'CDataMapping','scaled');
    
    hax(scax(1)).YLim = [min(freq),max(freq)];
    hax(scax(1)).XLim = [min(t) max(t)];
    hax(scax(1)).CLim = [cmin cmax];
    hax(scax(1)).Layer = 'top';
    hax(scax(1)).YDir = 'normal';
    hax(scax(1)).YScale = 'log';
    
    
    title(hax(scax(1)), titleStringsc1);
    ylabel(hax(scax(1)), labsC.scyP);
    hcol = colorbar('peer', hax(scax(1)));
    hcol.Label.String = getString(message('Wavelet:cwt:Magnitude'));
    hold(hax(scax(1)),'on');
    plot(hax(scax(1)),t,coi,'w--','linewidth',2);
    baselevel = max(hax(scax(1)).YLim);
    A1 = area(hax(scax(1)),t,coi,baselevel);
    A1.EdgeColor = 'none';
    A1.FaceColor = [0.8 0.8 0.8];
    alpha(A1,0.4);
    A1.PickableParts = 'none';
    
    % Marginal plot
    if margtime
        tspec1 = getString(message('Wavelet:cwt:tavgp'));
        semilogy(hax(mrgax(1)),marg(:,:,1),freq);
        title(hax(mrgax(1)),tspec1);
        xlabel(hax(mrgax(1)),labsC.margxP);
        hax(mrgax(1)).YLim = [min(freq),max(freq)];
        linkaxes([hax(scax(1)) hax(mrgax(1))],'y');
        grid(hax(mrgax(1)));
    else
        plot(hax(mrgax(1)),t,marg(:,:,1));
        hax(mrgax(1)).XLim = [min(t), max(t)];
        tspec1 = getString(message('Wavelet:cwt:savgp'));
        title(hax(mrgax(1)),tspec1);
        xlabel(hax(mrgax(1)),labsC.margxP);
        ylabel(hax(mrgax(1)),labsC.margyP);
        grid(hax(mrgax(1)));
        linkaxes([hax(scax(1)) hax(mrgax(1))],'x');
        
    end
    
    
    
    % The following axes hold must occur before any plotting or the default
    % interactivity is restored
    image('Parent',hax(scax(2)),...
        'XData', t,'YData', freq,...
        'CData',abs(wt(:,:,2)), ...
        'CDataMapping','scaled');
    
    hax(scax(2)).YLim = [min(freq),max(freq)];
    hax(scax(2)).XLim = [min(t) max(t)];
    hax(scax(2)).CLim = [cmin cmax];
    hax(scax(2)).Layer = 'top';
    hax(scax(2)).YDir = 'normal';
    hax(scax(2)).YScale = 'log';
    
    title(hax(scax(2)), titleStringsc2);
    ylabel(hax(scax(2)), labsC.scyN);
    xlabel(hax(scax(2)),labsC.scxN);
    hcol2 = colorbar('peer', hax(scax(2)));
    hcol2.Label.String = getString(message('Wavelet:cwt:Magnitude'));
    hold(hax(scax(2)),'on');
    plot(hax(scax(2)),t,coi,'w--','linewidth',2);
    baselevel = max(hax(scax(2)).YLim);
    A2 = area(hax(scax(2)),t,coi,baselevel);
    A2.EdgeColor = 'none';
    A2.FaceColor = [0.8 0.8 0.8];
    alpha(A2,0.4);
    A2.PickableParts = 'none';
    hold(hax(scax(2)),'off');
    hax(scax(1)).Tag = 'wpos';
    hax(scax(2)).Tag = 'wneg';
    % Marginal plot
    if margtime
        semilogy(hax(mrgax(2)),marg(:,:,2),freq);
        tspec2 = getString(message('Wavelet:cwt:tavgp'));
        title(hax(mrgax(2)),tspec2);
        hax(mrgax(2)).YLim = [min(freq),max(freq)];
        xlabel(hax(mrgax(2)),labsC.margxN);
        grid(hax(mrgax(2)));
        linkaxes([hax(scax(2)) hax(mrgax(2))],'y');
    else
        plot(hax(mrgax(2)),t,marg(:,:,2));
        hax(mrgax(2)).XLim = [min(t), max(t)];
        tspec2 = getString(message('Wavelet:cwt:savgp'));
        title(hax(mrgax(2)),tspec2);
        xlabel(hax(mrgax(2)),labsC.margxN);
        ylabel(hax(mrgax(2)),labsC.margyN);
        grid(hax(mrgax(2)));
        linkaxes([hax(scax(2)) hax(mrgax(2))],'x');
        
    end
end
hf.NextPlot = 'replace';

%--------------------------------------------------------------------------
function [labsR,labsC] = labelstructfreq(stype,margtime,ut,fs)
labsR = struct('margx','','margy','','scx','','scy','');
labsC = struct('margxP','','margxN','','margyP','','margyN','',...
        'scxP','','scxN','','scyP','','scyN','');

if strcmpi(stype,'power') && margtime
    labsR.margx = getString(message('Wavelet:cwt:Power'));
    labsC.margxN = getString(message('Wavelet:cwt:Power'));
    if isempty(fs)
        labsR.scy = getString(message('Wavelet:cwt:normfreq'));
        labsR.scx = getString(message('Wavelet:cwt:samples'));
        labsC.scxN = getString(message('Wavelet:cwt:samples'));
        labsC.scyP = getString(message('Wavelet:cwt:normfreq'));
        labsC.scyN = getString(message('Wavelet:cwt:normfreq'));
        
    else
        labsR.scy = getString(message('Wavelet:cwt:hz'));
        labsR.scx = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.scxN = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.scyP = getString(message('Wavelet:cwt:hz'));
        labsC.scyN = getString(message('Wavelet:cwt:hz'));
    end
    
elseif strcmpi(stype,'density') && margtime
    
    labsR.margx = getString(message('Wavelet:cwt:Density'));
    labsC.margxN = getString(message('Wavelet:cwt:Density'));
    if isempty(fs)
        labsR.scy = getString(message('Wavelet:cwt:normfreq'));
        labsR.scx = getString(message('Wavelet:cwt:samples'));
        labsC.scyP = getString(message('Wavelet:cwt:normfreq'));
        labsC.scyN = getString(message('Wavelet:cwt:normfreq'));
        labsC.scxN = getString(message('Wavelet:cwt:samples'));
        
    else
        labsR.scy = getString(message('Wavelet:cwt:hz'));
        labsR.scx = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.scyP = getString(message('Wavelet:cwt:hz'));
        labsC.scyN = getString(message('Wavelet:cwt:hz'));
        labsC.scxN = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    end
   
% scale average    
elseif strcmpi(stype,'power') && ~margtime 
    labsR.margy = getString(message('Wavelet:cwt:Power'));
    if isempty(fs)
       labsR.scy = getString(message('Wavelet:cwt:normfreq'));
       labsC.scyP = getString(message('Wavelet:cwt:normfreq'));
       labsR.margx = getString(message('Wavelet:cwt:samples')); 
       labsC.margxP = getString(message('Wavelet:cwt:samples')); 
       labsC.margxN = getString(message('Wavelet:cwt:samples')); 
    else
        labsR.scy = getString(message('Wavelet:cwt:hz'));
        labsC.scyP = getString(message('Wavelet:cwt:hz'));
        labsR.margx = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.margxP = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.margxN = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        
    end
    
    elseif strcmpi(stype,'density') && ~margtime 
    labsR.margy = getString(message('Wavelet:cwt:Density'));
    labsC.margyP = getString(message('Wavelet:cwt:Density'));
    if isempty(fs)
       labsR.scy = getString(message('Wavelet:cwt:normfreq'));
       labsC.scyP = getString(message('Wavelet:cwt:normfreq'));
       labsR.margx = getString(message('Wavelet:cwt:samples')); 
       labsC.margxP = getString(message('Wavelet:cwt:samples')); 
       labsC.margxN = getString(message('Wavelet:cwt:samples')); 
       labsC.scxN = getString(message('Wavelet:cwt:samples'));
    else
        labsR.scy = getString(message('Wavelet:cwt:hz'));
        labsC.scyP = getString(message('Wavelet:cwt:hz'));
        labsR.margx = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.margxP = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.margxN = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        labsC.scxN = ...
            [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        
    end
end

%-------------------------------------------------------------------------
function [labsR,labsC] = labelstructperiod(stype,margtime,ut)
labsR = struct('margx','','margy','','scx','','scy','');
labsC = struct('margxP','','margxN','','margyP','','margyN','',...
        'scxP','','scxN','','scyP','','scyN','');

if strcmpi(stype,'power') && margtime
    labsR.margx = getString(message('Wavelet:cwt:Power'));
    labsC.margxN = getString(message('Wavelet:cwt:Power'));
    labsR.scy = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsR.scx = ...
         [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    labsC.scyP = ...
            [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
            
    labsC.scyN = ...
         [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
     labsC.scxN = ...
         [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
     
elseif strcmpi(stype,'density') && margtime
    
    labsR.margx = getString(message('Wavelet:cwt:Density'));
    labsC.margxN = getString(message('Wavelet:cwt:Density'));
    labsR.scy = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    
    labsR.scx = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    labsC.scyP = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsC.scyN = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsC.scxN = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
        
    
   
% scale average    
elseif strcmpi(stype,'density') && ~margtime 
    labsR.margy = getString(message('Wavelet:cwt:Density'));
    labsC.margyP = getString(message('Wavelet:cwt:Density'));
    labsR.scy = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsC.scyP = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsR.margx = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    labsC.margxP = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    labsC.margxN = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    
    
    elseif strcmpi(stype,'power') && ~margtime 
    labsR.margy = getString(message('Wavelet:cwt:Power'));
    labsC.margyP = getString(message('Wavelet:cwt:Power'));
    labsR.scy = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsC.scyP = ...
        [getString(message('Wavelet:wcoherence:Period')) ' (' ut ')'];
    labsR.margx = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    labsC.margxP = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    labsC.margxN = ...
        [getString(message('Wavelet:getfrequnitstrs:Time')) ' (' ut ')'];
    
end

%-------------------------------------------------------------------------
function sz = getSizeforPlot

% Compensates for dual monitor
monitorPositions = get(0,'MonitorPositions');
% Are there dual monitors
isDualMonitor = size(monitorPositions,1) > 1;
 
if isDualMonitor
    origins = monitorPositions(:,1:2);
    % Identify the primary monitor
    primaryMonitorIndex = find(origins(:,1)==1 & origins(:,2)==1,1);
    
    if isempty(primaryMonitorIndex)
        % pick the first monitor if this doesn't work.
        primaryMonitorIndex = 1;
    else
        primaryMonitorIndex = max(primaryMonitorIndex,1);
    end
    
    sz = monitorPositions(primaryMonitorIndex, :);
else
    sz = get(0, 'ScreenSize');
end 

    
