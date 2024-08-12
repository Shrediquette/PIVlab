function [coefs,varargout] = cwtext(SIG,scales,WAV,varargin)
%CWTEXT Real or Complex Continuous 1-D wavelet coefficients using
%       extension parameters.
%   COEFS = CWTEXT(S,SCALES,'wname') computes the continuous
%   wavelet coefficients of the vector S at real, positive
%   SCALES, using wavelet whose name is 'wname'.
%   The signal S is real, the wavelet can be real or complex. 
%
%   COEFS = CWTEXT(S,SCALES,'wname',PropName1,PropVal1, ...) 
%   computes and, in addition, plots the continuous wavelet  
%   transform coefficients using extra parameters. The valid  
%   values for PropName are:
%       'ExtMode' , 'ExtSide' , 'ExtLen' , 'PlotMode', 'XLim'
%
%   The continuous wavelet transform coefficients are computed
%   using the extension parameters: 'ExtMode', 'ExtSide' and 'ExtLen'.
%   Valid values for EXTMODE are:
%       'zpd' (zero padding)
%       'sp0' (smooth extension of order 0) 
%       'sp1' (smooth extension of order 1) 
%       ... 
%   Valid values for EXTSIDE are: 
%       EXTSIDE = 'l' (or 'u') for left (up) extension.
%       EXTSIDE = 'r' (or 'd') for right (down) extension.
%       EXTSIDE = 'b' for extension on both sides.
%       EXTSIDE = 'n' nul extension
%   For the complete list of valid values for EXTMODE and EXTSIDE
%   see WEXTEND.
%   EXTLEN is the length of extension.
%   Default values for extension parameters are: 'zpd', 'b' and 
%   EXTLEN is computed using the maximum of SCALES.
%   Instead of 3 parameters you may use the following syntaxes:
%     EXTMODE = struct('Mode',ModeVAL,'Side',SideVAL,'Len',LenVAL);
%     EXTMODE = {ModeVAL,SideVAL,LenVAL};
%
%   COEFS = CWTEXT(...,'PlotMode',PLOTMODE) computes and plots 
%   the continuous wavelet transform coefficients.
%   Coefficients are colored using PLOTMODE.
%     PLOTMODE = 'lvl' (By scale) or 
%     PLOTMODE = 'glb' (All scales) or
%     PLOTMODE = 'abslvl' or 'lvlabs' (Absolute value and By scale) or
%     PLOTMODE = 'absglb' or 'glbabs' (Absolute value and All scales)
%   You get 3-D plots (surfaces) using the same keywords listed
%   above for the PLOTMODE parameter, preceded by '3D'.
%   For example: PLOTMODE = '3Dlvl'.
%
%   When PLOTMODE = 'scal' or  'scalCNT' the continuous wavelet 
%   transform coefficients and the corresponding scalogram 
%   (percentage of energy for each  coefficient) are computed.
%   When PLOTMODE is equal to 'scal', a scaled image of 
%   scalogram is displayed and when PLOTMODE is equal to 
%   'scalCNT', a contour representation of scalogram is displayed.
%
%   If the XLIM parameter is given, the continuous wavelet
%   transform coefficients are colored using PLOTMODE and XLIM.
%   XLIM = [x1 x2] with 1 <= x1 < x2 <= length(S).
%
%   For each given scale a within the vector SCALES, the wavelet 
%   coefficients C(a,b) are computed for b = 1 to ls = length(S),
%   and are stored in COEFS(i,:) if a = SCALES(i).
%    
%   Output argument COEFS is a la-by-ls matrix where la is
%   the length of SCALES. COEFS is a real or complex matrix
%   depending on the wavelet type.
%
%   Examples of valid uses are:
%     t = linspace(-1,1,512);
%     s = 1-abs(t);
%     c = cwtext(s,1:32,'cgau4');
%     c = cwtext(s,[64 32 16:-2:2],'morl');
%     c = cwtext(s,[3 18 12.9 7 1.5],'db2');
%     c = cwtext(s,1:32,'sym2','plotMode','lvl');
%     c = cwtext(s,1:64,'sym4','plotMode','abslvl','XLim',[100 400]);
%
%     [c,Sc] = cwtext(s,1:64,'sym4','plotMode','scal');
%     [c,Sc] = cwtext(s,1:64,'sym4','plotMode','scalCNT');
%     [c,Sc] = cwtext(s,1:64,'sym4','plotMode','scalCNT','extMode','sp1');
%
%     c = cwtext(s,1:64,'sym4','plotMode','lvl','extMode','sp0');
%     c = cwtext(s,1:64,'sym4','plotMode','lvl','extMode','sp1');
%     c = cwtext(s,1:64,'sym4','plotMode','lvl','extMode',{'sp1','b',300});
%
%     ext = struct('Mode','sp1','Side','b','Len',300);
%     c = cwtext(s,1:64,'sym4','plotMode','lvl','extMode',ext);
%
%     load wcantor
%     cwtext(wcantor,(1:256),'mexh','extmode','sp0','extLen',2000, ...
%               'plotMode','absglb');
%     colormap(pink(4))
%
%   See also CWT, WAVEDEC, WAVEFUN, WAVEINFO, WCODEMAT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Aug-2007.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check number of input arguments.
%---------------------------------
narginchk(3,11)
nbInMore = length(varargin);
extMode  = 'none';
extLen   = 'auto';
extSide  = 'b';
if nbInMore>0    
    plotMode = 'none';
    xlim     = [];
    for k = 1:2:nbInMore
        argNam = lower(varargin{k});
        argVal = varargin{k+1};
        switch argNam
            case 'plotmode'
                plotMode = argVal;
            case 'extmode'
                extMode  = argVal;
            case 'extlen'
                extLen   = argVal;
            case 'extside'
                extSide  = argVal;    
            case 'xlim'
                xlim     = argVal;
        end
    end    
end


% Check scales.
%--------------
err = 0;
if isempty(scales) ,         err = 1;
elseif min(size(scales))>1 , err = 1;
elseif min(scales)<eps,      err = 1;
end
if err
    errargt(mfilename, ...
        getWavMSG('Wavelet:FunctionArgVal:Invalid_ScaVal'),'msg');
    error(message('Wavelet:FunctionArgVal:Invalid_ScaVal'))
end


% Check wavelet.
%---------------
getINTEG = 1;
getWTYPE = 1;
if ischar(WAV)
    precis = 10; % precis = 15;
    [val_WAV,xWAV] = intwave(WAV,precis);
    stepWAV = xWAV(2)-xWAV(1);
    wtype = wavemngr('type',WAV);
    if wtype==5 , val_WAV = conj(val_WAV); end
    getINTEG = 0;
    getWTYPE = 0;

elseif isnumeric(WAV)
    val_WAV = WAV;
    lenWAV  = length(val_WAV);
    xWAV = linspace(0,1,lenWAV);
    stepWAV = xWAV(2)-xWAV(1);
    
elseif isstruct(WAV)
    try
        val_WAV = WAV.y;
    catch ME  %#ok<NASGU>
        err = 1;
    end
    if err~=1
        lenWAV = length(val_WAV);
        try
            xWAV = WAV.x; stepWAV = xWAV(2)-xWAV(1);
        catch ME  %#ok<NASGU>
            try
                stepWAV = WAV.step;
                xWAV = (0:stepWAV:(lenWAV-1)*stepWAV);
            catch ME  %#ok<NASGU>
                try
                    xlim = WAV.xlim;
                    xWAV = linspace(xlim(1),xlim(2),lenWAV);
                    stepWAV = xWAV(2)-xWAV(1);
                catch ME  %#ok<NASGU>
                    xWAV = linspace(0,1,lenWAV);
                    stepWAV = xWAV(2)-xWAV(1);
                end
            end
        end
    end
    
elseif iscell(WAV)
    if isnumeric(WAV{1})
        val_WAV = WAV{1};
    elseif ischar(WAV{1})
        precis  = 10;
        val_WAV = intwave(WAV{1},precis);
        wtype = wavemngr('type',WAV{1});        
        getINTEG = 0;
        getWTYPE = 0;
    end
    xATTRB  = WAV{2};
    lenWAV  = length(val_WAV);
    len_xATTRB = length(xATTRB);
    if len_xATTRB==lenWAV
        xWAV = xATTRB; stepWAV = xWAV(2)-xWAV(1);

    elseif len_xATTRB==2
        xlim = xATTRB;
        xWAV = linspace(xlim(1),xlim(2),lenWAV);
        stepWAV = xWAV(2)-xWAV(1);

    elseif len_xATTRB==1
        stepWAV = xATTRB;
        xWAV = (0:stepWAV:(lenWAV-1)*stepWAV);
    else
        xWAV = linspace(0,1,lenWAV);
        stepWAV = xWAV(2)-xWAV(1);
    end
end
if err
    errargt(mfilename, ...
        getWavMSG('Wavelet:FunctionArgVal:Invalid_WavVal'),'msg');
    error(message('Wavelet:FunctionArgVal:Invalid_WavVal'))
end
xWAV = xWAV-xWAV(1);
xMaxWAV = xWAV(end);
if getWTYPE ,  wtype = 4; end
if getINTEG ,  val_WAV = stepWAV*cumsum(val_WAV); end


% Check signal.
%--------------
err = 0;
if isnumeric(SIG)
    val_SIG = SIG;
elseif isstruct(SIG)
    try
        val_SIG = SIG.y;
    catch ME  %#ok<NASGU>
        err = 1;
    end
elseif iscell(SIG)
    val_SIG = SIG{1};
else
    err = 1;
end
if err
    errargt(mfilename, ...
        getWavMSG('Wavelet:FunctionArgVal:Invalid_SigVal'),'msg');
    error(message('Wavelet:FunctionArgVal:Invalid_SigVal'))
end

lenSIG  = length(val_SIG);
stepSIG = 1;
xSIG    = (1:lenSIG);

if isnumeric(SIG)
    
elseif isstruct(SIG)
    try
        xSIG = SIG.x;
        stepSIG = xSIG(2)-xSIG(1);
    catch ME  %#ok<NASGU>
        try
            stepSIG = SIG.step;
            xSIG = (0:stepSIG:(lenSIG-1)*stepSIG);
        catch ME  %#ok<NASGU>
            try
                xlim = SIG.xlim;
                xSIG = linspace(xlim(1),xlim(2),lenSIG);
                stepSIG = xSIG(2)-xSIG(1);
            catch ME  %#ok<NASGU>
                xSIG = (1:lenSIG);
            end
        end
    end

elseif iscell(SIG)
    xATTRB  = SIG{2};
    len_xATTRB = length(xATTRB);
    if len_xATTRB==lenSIG
        xSIG = xATTRB;
        stepSIG = xSIG(2)-xSIG(1);
    elseif len_xATTRB==2
        xlim = xATTRB;
        xSIG = linspace(xlim(1),xlim(2),lenSIG);
        stepSIG = xSIG(2)-xSIG(1);
    elseif len_xATTRB==1
        stepSIG = xATTRB;
        xSIG = (0:stepSIG:(lenSIG-1)*stepSIG);
    end
end

if err
    errargt(mfilename,'Invalid Value for Signal !','msg');
    error(message('Wavelet:FunctionArgVal:Invalid_SigVal'))
end


% Test if extension mode is used.
%--------------------------------
if ~isequal(extMode,'none')
    if isstruct(extMode)
        try
            extSide = extMode.Side;
            extLen  = extMode.Len;
            extMode = extMode.Mode;
        catch ME  
            error(message('Wavelet:FunctionArgVal:Invalid_ExtMVal'))
        end

    elseif iscell(extMode)
        extLen  = extMode{3};
        extSide = extMode{2};
        extMode = extMode{1};

    else
        maxScale = max(scales);
        if isequal(extLen,'auto')
            extLen = min([ceil(lenSIG/2),2*maxScale]);
        end
    end
    SAV_val_SIG = val_SIG;
    val_SIG = wextend('1d',extMode,val_SIG,extLen,extSide);
    lenSIG  = length(val_SIG);
end


% Compute the CWT.
%-----------------
val_SIG   = val_SIG(:)';
nb_SCALES = length(scales);
coefs     = zeros(nb_SCALES,lenSIG);
ind  = 1;
for k = 1:nb_SCALES
    a = scales(k);
    a_SIG = a/stepSIG;
    j = 1+floor((0:a_SIG*xMaxWAV)/(a_SIG*stepWAV));     
    if length(j)==1 , j = [1 1]; end
    f            = fliplr(val_WAV(j));
    coefs(ind,:) = -sqrt(a)*wkeep1(diff(wconv1(val_SIG,f)),lenSIG);
    ind          = ind+1;
end

% Exit if there is no extension and no plot.
%-------------------------------------------
if nbInMore<1 , return; end

% Test if extension mode is used.
%--------------------------------
if ~isequal(extMode,'none')
    val_SIG = SAV_val_SIG(:)';
    lenSIG  = length(val_SIG);    
    coefs = wkeep(coefs,[Inf lenSIG]);
end
    
% Exit if there is no plot.
%--------------------------
if isequal(plotMode,'none') 
    return; 
else
    clf; 
end

% Display Continuous Analysis.
%-----------------------------
[plotMode,dim_plot,lev_mode,abs_mode,beg_title] = ...
                getPlotAttrb(wtype,plotMode);
dummyCoefs = getCOEFS_toPlot(coefs,plotMode,abs_mode,lenSIG,xlim);

NBC = 240;
nb    = min(5,nb_SCALES);
level = '';
for k=1:nb , level = [level ' '  num2str(scales(k))]; end %#ok<AGROW>
if nb<nb_SCALES , level = [level ' ...']; end
nb     = ceil(nb_SCALES/20);
ytics  = 1:nb:nb_SCALES;
tmp    = scales(1:nb:nb*length(ytics));
ylabs  = num2str(tmp(:));
plotPARAMS = {NBC,lev_mode,abs_mode,ytics,ylabs,'',xSIG};

switch dim_plot
  case 'SC'
      switch plotMode
          case 'scal',     typePLOT = 'image';
          case 'scalCNT' , typePLOT = 'contour';
      end
      SC = wscalogram(typePLOT,coefs,scales,val_SIG,xSIG);
      if nargout>1 , varargout{1} = SC; end
      
  case '2D'
    if wtype<5
        titleSTR = [beg_title ' Values of Ca,b Coefficients for a = ' level];
        plotPARAMS{6} = titleSTR;
        axeAct = gca;
        plotCOEFS(axeAct,dummyCoefs,plotPARAMS);
    else
        axeAct = subplot(2,2,1);
        titleSTR = ['Real part of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,real(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,2);
        titleSTR = ['Imaginary part of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,imag(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,3);
        titleSTR = ['Modulus of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,abs(dummyCoefs),plotPARAMS);
        axeAct = subplot(2,2,4);
        titleSTR = ['Angle of Ca,b for a = ' level];
        plotPARAMS{6} = titleSTR;
        plotCOEFS(axeAct,angle(dummyCoefs),plotPARAMS);
    end
    colormap(pink(NBC));

  case '3D'
    if wtype<5
        titleSTR = [beg_title ' Values of Ca,b Coefficients for a = ' level];
        axeAct = gca;
        surfCOEFS(axeAct,dummyCoefs,NBC,ytics,ylabs,titleSTR);
    else
        axeAct = subplot(2,2,1);
        titleSTR = ['Real part of Ca,b for a = ' level];
        surfCOEFS(axeAct,real(dummyCoefs),NBC,ytics,ylabs,titleSTR);
        axeAct = subplot(2,2,2);
        titleSTR = ['Imaginary part of Ca,b for a = ' level];
        surfCOEFS(axeAct,imag(dummyCoefs),NBC,ytics,ylabs,titleSTR);
        axeAct = subplot(2,2,3);
        titleSTR = ['Modulus of Ca,b for a = ' level];
        surfCOEFS(axeAct,abs(dummyCoefs),NBC,ytics,ylabs,titleSTR);
        axeAct = subplot(2,2,4);
        titleSTR = ['Angle of Ca,b for a = ' level];
        surfCOEFS(axeAct,angle(dummyCoefs),NBC,ytics,ylabs,titleSTR);
    end
end


%--------------------------------------------------------------------------
function [plotmode,dim_plot,lev_mode,abs_mode,beg_title] = ...
                getPlotAttrb(wtype,plotmode)

if strncmpi('3D',plotmode,2)
    dim_plot = '3D';
elseif strncmpi('scal',plotmode,4)
    dim_plot = 'SC';    
else
    dim_plot = '2D';
end

if isequal(wtype,5)
   if contains(plotmode,'lvl') 
       plotmode = 'lvl';
   elseif isequal(plotmode,'scal') || isequal(plotmode,'scalCNT')
       
   else
       plotmode = 'glb';   
   end
end
switch plotmode
  case {'lvl','3Dlvl'}
    lev_mode  = 'row';   abs_mode  = 0;   beg_title = 'By scale';

  case {'glb','3Dglb'}
    lev_mode  = 'mat';   abs_mode  = 0;   beg_title = '';

  case {'abslvl','lvlabs','3Dabslvl','3Dlvlabs'}
    lev_mode  = 'row';   abs_mode  = 1;    beg_title = 'Abs. and by scale';

  case {'absglb','glbabs','plot','2D','3Dabsglb','3Dglbabs','3Dplot','3D'}
    lev_mode  = 'mat';   abs_mode  = 1;   beg_title = 'Absolute';

  case {'scal','scalCNT'}
    lev_mode  = 'mat';   abs_mode  = 1;   beg_title = 'Absolute';
    
  otherwise
    plotmode  = 'absglb';
    lev_mode  = 'mat';   abs_mode  = 1;   beg_title = 'Absolute';
    dim_plot  = '2D';
end
%--------------------------------------------------------------------------
function [dummyCoefs,xlim] = getCOEFS_toPlot(coefs,plotmode,abs_mode,lenSIG,xlim)

nb_SCALES = size(coefs,1);
if ~abs_mode
    dummyCoefs = coefs;
else
    dummyCoefs = abs(coefs);
end
if nargin==5 && ~isequal(plotmode,'scal') && ...
        ~isequal(plotmode,'scalCNT') && ~isempty(xlim)
    if xlim(2)<xlim(1) , xlim = xlim([2 1]); end    
    if xlim(1)<1      ,  xlim(1) = 1;   end
    if xlim(2)>lenSIG ,  xlim(2) = lenSIG; end
    indices = xlim(1):xlim(2);
    switch plotmode
      case {'glb','absglb'}
        cmin = min(min(dummyCoefs(:,indices)));
        cmax = max(max(dummyCoefs(:,indices)));
        dummyCoefs(dummyCoefs<cmin) = cmin;
        dummyCoefs(dummyCoefs>cmax) = cmax;

      case {'lvl','abslvl'}
        cmin = min(dummyCoefs(:,indices),[],2);
        cmax = max(dummyCoefs(:,indices),[],2);
        for k=1:nb_SCALES
            ind = dummyCoefs(k,:)<cmin(k);
            dummyCoefs(k,ind) = cmin(k);
            ind = dummyCoefs(k,:)>cmax(k);
            dummyCoefs(k,ind) = cmax(k);
        end
    end
end
%--------------------------------------------------------------------------
function plotCOEFS(axeAct,coefs,plotPARAMS)

[NBC,lev_mode,abs_mode,ytics,ylabs,titleSTR] = deal(plotPARAMS{1:6});

coefs = wcodemat(coefs,NBC,lev_mode,abs_mode);
image(coefs);
set(axeAct, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
title(titleSTR,'Parent',axeAct);
xlabel(getWavMSG('Wavelet:divCMDLRF:TimeORSpace'),'Parent',axeAct);
ylabel(getWavMSG('Wavelet:divCMDLRF:Scales_a'),'Parent',axeAct);
%--------------------------------------------------------------------------
function surfCOEFS(axeAct,coefs,NBC,ytics,ylabs,titleSTR)

surf(coefs);
set(axeAct, ...
        'YTick',ytics, ...
        'YTickLabel',ylabs, ...
        'YDir','normal', ...
        'Box','On' ...
        );
title(titleSTR,'Parent',axeAct);
xlabel(getWavMSG('Wavelet:divCMDLRF:TimeORSpace'),'Parent',axeAct);
ylabel(getWavMSG('Wavelet:divCMDLRF:Scales_a'),'Parent',axeAct);
zlabel('COEFS','Parent',axeAct);

xl = [1 size(coefs,2)];
yl = [1 size(coefs,1)];
zl = [min(min(coefs)) max(max(coefs))];
set(axeAct,'XLim',xl,'YLim',yl,'Zlim',zl,'view',[-30 40]);

colormap(pink(NBC));
shading('interp')
%--------------------------------------------------------------------------


