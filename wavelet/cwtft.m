function CWTStruct = cwtft(SIG,varargin)
% CWTFT Continuous wavelet transform using FFT.
%   CWTSTRUCT = CWTFT(SIG) returns the continuous wavelet transform (CWT) 
%   of the 1-D real-valued SIG using a Fourier transform based algorithm. 
%   SIG can be a vector, a structure array, or a cell array.
%   If SIG is a vector, SIG contains the data. If SIG is a structure array, 
%   SIG contains two fields: SIG.val and SIG.period. SIG.val is the data 
%   and SIG.period is the sampling period. If SIG is a cell array, SIG{1}
%   and SIG{2} respectively contain the signal and the sampling period.
%
%   By default, CWTFT use the analytic Morlet wavelet and logarithmic 
%   scales (see SCA below) are used to compute the CWT. The sampling period
%   is one by default.
%
%   CWTFT outputs a structure array with seven fields:
%      cfs:         CWT coefficients
%      scales:      vector of scales. 
%      frequencies: frequencies in cycles per unit time (or space)
%                   corresponding to the scales. If the sampling period
%                   units are seconds, the frequencies are in hertz.
%                   The elements of frequencies are in decreasing order to
%                   correspond to the elements in the scales vector. Use
%                   this field to examine the CWT in the time-frequency
%                   plane.
%      wav:         wavelet used for the analysis (see WAV below).
%      omega:       angular frequencies used in the Fourier transform of
%                   the wavelet. This field is used in ICWTFT and ICWTLIN
%                   for the inversion of the CWT.
%      meanSIG:     mean of SIG
%      dt:          sampling period
% 
%   CWTSTRUCT = CWTFT(SIG,'scales',SCA,'wavelet',WAV) lets you 
%   define the scales and the wavelet. Supported analyzing wavelets are:
%   
%   'morl' -    Morlet wavelet (analytic)
%   'morlex' -  Morlet wavelet (nonanalytic)
%   'morl0' -   Exact zero-mean Morlet wavelet (nonanalytic)
%   'bump' -    Bump wavelet (analytic)
%   'paul' -    Paul wavelet (analytic)
%   'dog'  -    N-th order derivative of Gaussian (nonanalytic)
%   'mexh' -    Second derivative of Gaussian (nonanalytic)
%
%   See the help for CWTFTINFO for definitions of the supported wavelets
%   and their default parameter values.
%
%   SCA can be a vector, a structure array, or a cell array.
%   If SCA is a vector, it contains the scales.
%   If SCA is a structure, it may contain at most five fields
%   (s0,ds,nb,type,pow). The last two fields are optional. 
%   s0, ds, and nb are respectively the smallest scale, the spacing
%   between scales, and the number of scales. The field, type, determines 
%   the spacing used for the scales vector: 'pow' (logarithmic spacing) 
%   which is the default or 'lin' (linear spacing).
%   For 'pow' : scales = s0*pow.^((0:nb-1)*ds); 
%   For 'lin' : scales = s0 + (0:nb-1)*ds;
%   When type is 'pow', if SCA.pow exists SCA.pow = pow. Otherwise, pow is
%   set to 2.
%   If SCA is a cell array, SCA{1}, SCA{2}, and SCA{3} contain 
%   the smallest scale, the spacing between scales, 
%   and the number of scales. If SCA{4} and SCA{5} exist, they
%   contain the type of scaling and the power.
%   When s0, ds, or nb are empty, the default values are used.
%   If you specify a sampling period different from one, you must multiply
%   your scales by the sampling period.
%   The minimum normalized scale (scale/sampling period) should be strictly
%   greater than 1 and less than the length of the input signal.
%
%   WAV can be a string, a structure, or a cell array.
%   If WAV is a string, it contains the name of the wavelet used 
%   for the analysis.
%   If WAV is a structure, WAV.name and WAV.param are respectively 
%   the name of the wavelet and one or more associated
%   parameters.  
%   If WAV is a cell array, WAV{1} and WAV{2} contain the name of 
%   the wavelet and optional parameters (see CWTFTINFO for the 
%   admissible wavelets and parameters). 
%   
%   CWTSTRUCT = CWTFT(...,'padmode',PADMODE) uses the signal extension mode
%   PADMODE before computing the Fourier transforms of the signal and
%   wavelet. In a Fourier-transform-based CWT algorithm, extending a signal
%   can mitigate wraparound effects. The number of CWT coefficients in
%   each row of the output matrix CWTSTRUCT.cfs is truncated to match the
%   length of the input signal.
% 
%   PADMODE can be on of the following strings:
%
%     'zpd' - zero extension
%     'sp0' - smooth extension of order 0
%     'spd' - (or 'sp1') smooth extension of order 1
%     'sym' - (or 'symh') half-point symmetric extension
%     'symw' - whole-point symmetric extension
%     'asym' - (or 'asymh') half-point antisymmetric extension
%     'asymw' - whole-point antisymmetric extension
%     'ppd' - periodized extension (1)
%     'per' - periodized extension (2):
%        If the signal length is odd, an extra-sample is added that is
%        equal to the last value on the right. Then, the signal is extended
%        using the 'ppd' mode. Otherwise, 'per' reduces to 'ppd'.
% 
%   If you do not specify an extension mode, the default is no extension.
%
%   Using CWTSTRUCT = CWTFT(...,'plot') plots the signal and the continuous
%   wavelet transform. 
%
%   % Example 1:
%   %   Obtain the CWT of a signal consisting of two sinusoids with 
%   %   disjoint support in additive noise using the analytic bump wavelet. 
%   %   The signal has two transients at 0.2 and 0.8 seconds. The sampling 
%   %   period is one millisecond.
%   dt = 0.001;
%   t = 0:dt:1-dt;
%   x = ...
%   cos(2*pi*150*t).*(t>=0.1 & t<0.3)+sin(2*pi*200*t).*(t>0.7);
%   wgnNoise = 0.05*randn(size(t));
%   y = x+wgnNoise;
%   y([200 800]) = x([200 800])+2;
%   s0 = 2*dt;
%   a0 = 2^(1/32);
%   scales = s0*a0.^(1:5*32);
%   cwtBump = ...
%   cwtft({y,dt},'wavelet','bump','scales',scales,'padmode','symw');
%   cfs = cwtBump.cfs; freq = cwtBump.frequencies;
%   contour(t,freq,abs(cfs)); grid on;
%   axis tight;
%   xlabel('Seconds'); ylabel('Hz');
%   title('CWT with Bump Wavelet');
%
%   %Example 2:
%   %   Obtain the CWT of the Kobe earthquake data with the analytic bump
%   %   wavelet. The data are sampled at 1 Hz.
%   load kobe;
%   dt = 1;
%   s0 = 2*dt;
%   a0 = 2^(1/16);
%   scales = s0*a0.^(0:7*16);
%   cwtkobe = cwtft(kobe,'wavelet',{'bump',[4 0.7]},'scales',scales);
%   contour(1:numel(kobe),cwtkobe.frequencies,abs(cwtkobe.cfs))
%   xlabel('Time'); ylabel('Hz'); grid on;
%
%   See also CWT, CWTFTINFO, ICWTFT, ICWTLIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Mar-2010.
%   Copyright 1995-2020 The MathWorks, Inc.


% Check input arguments.
nbIN = nargin;
if nbIN==0 , OK_Cb = Cb_RadBTN; if OK_Cb , return; end; end
narginchk(1,Inf)

% Handle strings in cell arrays or structs
if ~isempty(varargin)
    [varargin{:}] = wavelet.internal.wconvertStringsToChars(varargin{:});
end

% Signal.
if isstruct(SIG)
    val = SIG.val; dt = SIG.period;
elseif iscell(SIG)
    val = SIG{1};  dt = SIG{2};
else
    val = SIG;
end

% signal is row vector
val = val(:)';
nbSamp = length(val);

% Check other inputs.
flag_PLOT = false;
SCA = [];
ScType = ''; 
WAV = [];
pad_MODE  = 'none';
if nbIN>1
    nbArg = length(varargin);
    k = 1;
    while k<=nbArg
        ArgNAM = lower(varargin{k});
        if k<nbArg  
            ArgVAL = varargin{k+1}; 
            if ischar(ArgVAL) , lower(ArgVAL); end
        end
        k = k+2;
        switch ArgNAM
            case 'scales'  , SCA = ArgVAL;
            case 'wavelet' , WAV = ArgVAL;
            case 'plot'    , k = k-1; flag_PLOT = true;
            case 'padmode' , pad_MODE = lower(ArgVAL);
            otherwise
                error(message('Wavelet:FunctionInput:ArgumentName'));
        end
    end
end

% Construct time series to analyze, pad if necessary
meanSIG = mean(val);
x = val - meanSIG;

% Check padmode argument
padmodecheck = strcmp(pad_MODE,{'zpd','sp0','spd','sp1','sym','symw',...
    'asym','asymh','asymw', 'ppd','per','none'});

if ~any(padmodecheck)
    error(message('Wavelet:FunctionArgVal:Invalid_PadMode'));
end

if ~isequal(pad_MODE,'none')
    np2 = 1+fix(log2(nbSamp) + 0.4999);
    x = wextend('1d',pad_MODE,x,2^np2-nbSamp,'r');
end

% Length of data plus any extension
n = length(x);

% Check inputs to select the defaults.
%-------------------------------------
% Check sampling period
if ~exist('dt','var')
    OK_sampling_period = false;
else
    OK_sampling_period = true;
end

% Define wavelet.
if isempty(WAV) , WAV = 'morl'; end

% Define sampling period.
if ~OK_sampling_period , dt = 1; end 



% Define Scales
if isempty(SCA)
    [~,~,~,scales,param] = getDefaultAnalParams(WAV,n,dt);
    NbSc = length(scales);
    ScType = getScType(scales);
   
elseif isnumeric(SCA)
    [~,~,~,~,param] = getDefaultAnalParams(WAV,n,dt);
    scales = SCA;
    NbSc = length(scales);
    ScType = getScType(scales);
        
elseif isstruct(SCA) || iscell(SCA)
    if isstruct(SCA)
        s0 = SCA.s0; ds = SCA.ds; NbSc = SCA.nb;
        if ~isfield(SCA,'type')
            ScType = 'pow'; pow = 2;
        else
            ScType = SCA.type;
            switch ScType
                case 'pow'  
                    if isfield(SCA,'pow') 
                        pow = SCA.pow;
                    else
                        pow = 2;
                    end
                case 'lin'
                otherwise
                    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
            end
        end
    else
        s0 = SCA{1}; ds = SCA{2}; NbSc = SCA{3};
        if length(SCA)<4
            ScType = 'pow'; pow = 2;
        else
            ScType = SCA{4};
            if ~isnumeric(ScType)
                switch ScType
                    case 'pow'
                        if length(SCA)>4 , pow = SCA{5}; else pow = 2; end
                    case 'lin'
                    otherwise
                        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
                end
            else
                pow = ScType; ScType = 'pow'; 
            end
        end
    end
    try
        [s0_def,ds_def,NbSc_def,~,param] = getDefaultAnalParams(WAV,n,dt);
    catch ME
        s0_def = 2*dt; ds_def = 0.25; NbSc_def = 30;
    end
    if isempty(s0) ,  s0 = s0_def;  end
    if isempty(ds) ,  ds = ds_def;   end
    if isempty(NbSc) ,NbSc = NbSc_def; end
    switch lower(ScType)
        case 'pow' , scales = s0*pow.^((0:NbSc-1)*ds);
        case 'lin' , scales = s0 + (0:NbSc-1)*ds;
    end
else
    error(message('Wavelet:FunctionInput:Argval'))
end

% Construct wavenumber array used in transform
omega = (1:fix(n/2));
omega = omega.*((2.*pi)/(n*dt));
omega = [0., omega, -omega(fix((n-1)/2):-1:1)];

% Compute FFT of the (padded) time series
f = fft(x);

% Loop through all scales and compute transform
[psift,frequencies]  = waveft(WAV,omega,scales);
cwtcfs = ifft(repmat(f,NbSc,1).*psift,[],2);
cwtcfs = cwtcfs(:,1:nbSamp);
omega  = omega(1:nbSamp);

% Build output structure
if isstruct(WAV)
    WAV.param = param;
elseif iscell(WAV)
    WAV{2} = param;
end
CWTStruct = struct('cfs',cwtcfs,'scales',scales, 'frequencies',frequencies,...
    'omega',omega,'meanSIG',meanSIG,'dt',dt);
CWTStruct.wav = WAV;

% Plot if necessary.
if ~flag_PLOT , return; end

OK_real = isreal(cwtcfs);
numAXE = 1;
if OK_real , nbCOL = 1; else nbCOL = 2; end
fig = figure(...
    'Name',...
    getWavMSG('Wavelet:cwtft:fig_CWT_FT_Alg'), ...
    'Units','normalized','Position',[0.1 0.1 0.5 0.75],'Tag','Win_CWTFT');
ax = subplot(3,nbCOL,numAXE);
titleSTR = getWavMSG('Wavelet:cwtft:Analyzed_signal');
posval = dt*(0:nbSamp-1);
plot(posval,val,'r','Tag','SIG','Parent',ax); axis tight;
wtitle(titleSTR,'Parent',ax)
numAXE = numAXE+1;

if nbCOL>1
    ax = subplot(3,nbCOL,numAXE);
    plot(posval,val,'r','Tag','SIG','Parent',ax); axis tight;
    wtitle(titleSTR,'Parent',ax)
    numAXE = numAXE+1;
end

ax = subplot(3,nbCOL,numAXE);
a1 = ax;
if nbCOL>1
    titleSTR = getWavMSG('Wavelet:cwtft:Str_Modulus');
else
    titleSTR = getWavMSG('Wavelet:cwtft:Str_AbsoluteVAL');
end
plotIMAGE(ax,posval,scales,abs(cwtcfs),ScType,titleSTR,0.02);
switch ScType
    case 'lin' , ylabSTR = getWavMSG('Wavelet:cwtft:ylab_Scales');
    case 'pow' , ylabSTR = getWavMSG('Wavelet:cwtft:ylab_Scale_Power');
    otherwise  , ylabSTR = getWavMSG('Wavelet:cwtft:ylab_Scales');
end

wylabel(ylabSTR,'Parent',ax);
numAXE = numAXE+1;

ax = subplot(3,nbCOL,numAXE);
if nbCOL>1
    titleSTR =  getWavMSG('Wavelet:cwtft:Str_Real_Part');
    decale = 0.02;
    a2 = ax;
else
    titleSTR = getWavMSG('Wavelet:cwtft:Str_Real_Part');
    decale = 0;
    wylabel(ylabSTR,'Parent',ax);
    a2 = [];
end
plotIMAGE(ax,posval,scales,real(cwtcfs),ScType,titleSTR,decale);
numAXE = numAXE+1;

if nbCOL>1
    ax = subplot(3,nbCOL,numAXE);
    titleSTR = getWavMSG('Wavelet:cwtft:Str_Angle');
    plotIMAGE(ax,posval,scales,angle(cwtcfs),ScType,titleSTR);
    wylabel(ylabSTR,'Parent',ax);
    numAXE = numAXE+1;
    ax = subplot(3,nbCOL,numAXE);
    titleSTR = getWavMSG('Wavelet:cwtft:Str_Imaginary_Part');
    plotIMAGE(ax,posval,scales,imag(cwtcfs),ScType,titleSTR);
end
colFIG = get(fig,'Color');
st = dbstack; name = st(end).name;
if isequal(name,'mdbpublish') , colFIG = 'w'; end

btn = uicontrol(fig,'Style','checkbox', ...
    'String',getWavMSG('Wavelet:cwtft:Uic_RecSigOnOff'), ...
    'FontSize',11, ...
    'Units','normalized',...
    'BackgroundColor',colFIG, ...
    'Position',[0.02  0.015  0.4  0.03], ...
    'Tag','CWTFT_Rad_Rec' ...
    );
set(btn,'Callback',mfilename);

% Display main title.
p1 = get(a1,'Position');
x1 = p1(1);
if ~isempty(a2)
    p2 = get(a2,'Position');
    x2 = p2(1)+p2(3);
else
    x2 = p1(1)+p1(3);
end
xM = (x1+x2)/2;
w  = 0.5;
xL = xM-w/2;
yL = p1(2)+1.05*p1(4);
pos = [xL , yL , w , 0.035];
uicontrol('Style','text','Units','normalized',...
    'Position',pos,'BackgroundColor',colFIG, ...
    'FontSize',10,'FontWeight','bold',...
    'String',getWavMSG('Wavelet:cwtft:BigTitleSTR'),'Parent',fig);
wtbxappdata('set',fig,'CWTStruct',CWTStruct);

%----------------------------------------------------------------------
function [s0,ds,NbSc,scales,param] = getDefaultAnalParams(WAV,nbSamp,dt)

switch nargin
    case 0 , dt = 1; nbSamp = 1024; WAV = {'morl',6};
    case 1 , dt = 1; nbSamp = 1024;
    case 2 , dt = 1;
end
if isstruct(WAV)
    wname = WAV.name;
    param = WAV.param; %#ok<*NASGU>
elseif iscell(WAV)
    wname = WAV{1};
    param = WAV{2};
else
    wname = WAV;
    param = [];
end

switch wname
    case {'morl','morlex','morl0'} 
        s0 = 2*dt; ds = 0.4875; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
        if isempty(param) , param = 6; end
       
    case {'mexh','dog'}
        s0 = 2*dt;  ds = 0.4875; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
        if  isequal(wname,'dog') && isempty(param) , param = 2; end        
        
    case 'paul'
        s0 = 2*dt;  ds = 0.4875; NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
            if isempty(param) , param = 4; end  
        
    case 'bump'
        s0 = 2*dt; ds = 1/10; 
        NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);
        NbSc = numel(scales);
            if isempty(param)
                param = 5; param(2) = 0.6;
            end
        validateattributes(param(1),{'double'},{'scalar','>=',3,'<=',6});
        validateattributes(param(2),{'double'},{'scalar','>=',0.1,'<=',1.2});
              
            
    otherwise
        s0 = 2*dt; ds = 0.25;
        NbSc = fix(log2(nbSamp*dt/s0)/ds);
        scales = s0*2.^((0:NbSc-1)*ds);        
end

%---------------------------------------------------------
function Add_ColorBar(hA)

pA = get(hA,'Position');
hC = colorbar('peer',hA,'EastOutside');
pC = get(hC,'Position');
set(hA,'Position',pA);
set(hC,'Position',[pA(1)+pA(3)+0.01  pC(2)+pC(4)/15 pC(3)/2.1 4*pC(4)/5])
%-----------------------------------------------------------------------
function plotIMAGE(ax,posval,SCA,CFS,ScType,titleSTR,decale)

if nargin<7 , decale = 0; end
if abs(decale)>0
    pos = get(ax,'Position');
    pos(2) = pos(2)- decale;
    set(ax,'Position',pos);
end
NbSc = size(CFS,1);
if isequal(ScType,'pow')
    mul = 200;
    NbSCA = SCA'/SCA(1);
    NbSCA = round(mul*NbSCA/sum(NbSCA));
    NbSCA_TOT = sum(NbSCA);    
    C = zeros(NbSCA_TOT,size(CFS,2));
    first = 1;
    for k = 1:NbSc
        last = first+NbSCA(k)-1;
        C(first:last,:) = repmat(CFS(k,:),NbSCA(k),1);
        first = last+1;
    end
else
    C = CFS;
end
imagesc(posval,SCA,C,'Parent',ax);
Add_ColorBar(ax)
wxlabel(titleSTR,'Parent',ax);
set(ax,'YDir','normal')
if isequal(ScType,'pow')
    yt = zeros(1,NbSc-1);
    for k = 1:NbSc-1 , yt(k) = 0.5*(SCA(k)+SCA(k+1)); end
    for k = 1:NbSc-1
        hold on
        plot(posval,yt(k)*ones(1,length(posval)),':k','Parent',ax);
    end
    nb = min([5,NbSc-2]);
    YTaff = yt(end-nb:end);
    maxYT = max(YTaff);
    set(ax,'YTick',YTaff,'FontSize',9);
    if maxYT>0.05
        if maxYT<0.1     , precFormat = '%0.4f';
        elseif maxYT<10  , precFormat = '%0.3f';
        elseif maxYT<100 , precFormat = '%0.2f';
        else               precFormat = '%0.1f';
        end
        YTlab = num2str(SCA(end-nb:end)',precFormat);
        set(ax,'YTickLabel',YTlab);
    end
else
    NbSc = length(SCA);
    nb = 10;
    step = 1;
    L = NbSc;
    while L>nb
        step = step+1;
        idxVal = 1:step:NbSc;
        L = length(idxVal);
    end
    maxYT = max(SCA(idxVal));
    if maxYT>0.05
        if maxYT<0.1     , precFormat = '%0.3f';
        elseif maxYT<10  , precFormat = '%0.2f';
        elseif maxYT<100 , precFormat = '%0.2f';
        else               precFormat = '%0.1f';
        end
    end
    YTLab = num2str(SCA(idxVal)',precFormat);
    yl = get(gca,'Ylim');
    D = (yl(2)-yl(1))/NbSc;
    YTaff = (idxVal-0.5)*D;
    set(ax,'YTick',YTaff,'YTickLabel',YTLab,'FontSize',9);
end
%-----------------------------------------------------------------------
function ScType = getScType(scales)

DF2 = sum(diff(scales,2));
if abs(DF2)<sqrt(eps)
    ScType = 'lin';
else
    B = log(scales/scales(1));
    if abs(B/B(2)-round(B/B(2))) < sqrt(eps)  
        ScType = 'pow';
    else
        ScType = 'man';
    end
end
%-----------------------------------------------------------------------
function OK_Cb = Cb_RadBTN

[obj,fig] = gcbo;
if isempty(obj) , OK_Cb = false; return; end

CWTStruct = wtbxappdata('get',fig,'CWTStruct');
typeINV = 'pow';
testTYPE = true;
if testTYPE
    scales = CWTStruct.scales; 
    D = abs(diff(scales/scales(1)));
    if (max(D)-min(D))<sqrt(eps) , typeINV = 'lin'; end
end
switch typeINV
    case 'pow' , XRec = icwtft(CWTStruct);
    case 'lin' , XRec = icwtlin(CWTStruct);
end
OK_real = isreal(CWTStruct.cfs);
if OK_real , nbCOL = 1; else nbCOL = 2; end
ax = subplot(3,nbCOL,1);
hR = findobj(ax,'Tag','RecSIG');
h  = findobj(ax,'Tag','SIG');
Y  = get(h,'YData');
if isempty(hR)
    xd = get(h,'XData');
    errMAX = 100*max(abs(Y(:)-XRec(:)))/max(abs(Y(:)));
    errL2  = 100*norm(Y(:)-XRec(:))/norm(Y(:));
    LabSTR = sprintf(getWavMSG('Wavelet:cwtft:sprintf_RelativeErrorsMAX32fL232f',...
        sprintf('%3.2f',errMAX),sprintf('%3.2f',errL2)));
    wxlabel(LabSTR,'Parent',ax)
    hold on ; 
    line('XData',xd,'YData',XRec,'Color','b','Tag','RecSIG'); 
    axis tight;
    strT = getWavMSG('Wavelet:cwtft:Anal_and_Rec_Sig');
else
    xl = get(ax,'XLabel');
    v = lower(get(hR,'Visible'));
    if isequal(v,'on')
        v = 'off';
        strT = getWavMSG('Wavelet:cwtft:Analyzed_signal');
    else
        v = 'on';
        strT = getWavMSG('Wavelet:cwtft:Anal_and_Rec_Sig');
    end
    set([hR,xl],'Visible',v);
    if ~isequal(v,'on')
        set(ax,'YLim',[min(Y),max(Y)])
    else
        axis tight;
    end
end
wtitle(strT,'Parent',ax)
OK_Cb = true;
%-----------------------------------------------------------------------
