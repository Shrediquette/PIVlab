function CWTStruct = cwtft2(X,varargin)
% CWTFT2 Continuous 2-D wavelet transform using FFT.
%   CWTSTRUCT = CWTFT2(X) computes the continuous 2-D wavelet 
%   transform of the input matrix X using a Fourier transform  
%   based algorithm.
%
%   CWTSTRUCT is a structure which contains six fields:
%      cfs:       coefficients of wavelet transform.
%      scales:    vector of scales. 
%      angles:    vector of angles. 
%      wav:       wavelet used for the analysis (see WAV below).
%      wav_norm:  wavelet normalization values.
%      meanSIG:   mean of the analyzed matrix.
% 
%   CWTSTRUCT = CWTFT2(X,'scales',SCA,'angles',ANG,'wavelet',WAV) let you 
%   define the scales, the angles  or the wavelet (or all) used for
%   the analysis.
%
%   WAV can be a string, a structure or a cell array.
%   If WAV is a string, it contains the name of the wavelet used 
%   for the analysis.
%   If WAV is a structure, WAV.name and WAV.param are respectively 
%   the name of the wavelet and, if necessary, one or more associated
%   parameters.  
%   If WAV is a cell array, WAV{1} and WAV{2} contain the name of 
%   the wavelet and optional parameters (see CWTFTINFO2 for the 
%   admissible wavelets). 
%
%   Using CWTSTRUCT = CWTFT2(...,'plot'), the image and its
%   continuous wavelet transform are plotted.
%
%   CWTSTRUCT = CWTFT2(...,'norm',NT) let you choose the normalization
%   used to compute the transform. NT may be equal either to 'L1', 'L2' 
%   or 'L0'. The default is NT = L2.
%
%   CAUTION:
%     For an image X of size M by N, CWTFT2 uses a ND-array of
%     size (M by N by nbScales by nbAngles by nbPlans) to store
%     the cwt transform (nbPlans = 1 or 3). So the memory can be
%     insufficient.
%
%   REFERENCES
%     Two-Dimensional Wavelets and their Relatives
%     J.-P. Antoine, R. Murenzi, P. Vandergheynst andS. Twareque Ali 
%     Cambridge University Press - 2004
%
%     Two-dimensional wavelet transform profilometry
%     Fringe Pattern Analysis Using Wavelet
%     Liverpool John Moores University 
%     http://www.ljmu.ac.uk
%
%   See also CWTFTINFO2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jun-2010.
%   Last Revision: 04-Jul-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2013/08/23 23:44:54 $

% Check Callback.
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin==0 , OK_Cb = Cb_PopBTN; if OK_Cb , return; end; end

% Check input arguments.
nbIN = length(varargin);
if nbIN==0 , varargin = {}; end

% Check other inputs.
flag_PLOT = false;
WAV_Input     = [];
normOPT = [];
SCA     = [];
ScType  = '';  %#ok<*NASGU>
ANG     = 0;
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
            case 'angles'  , ANG = ArgVAL;
            case 'scales'  , SCA = ArgVAL;
            case 'wavelet' , WAV_Input = ArgVAL;
            case 'norm'    , normOPT = ArgVAL;
            case 'plot'    , k = k-1; flag_PLOT = true;
            otherwise
                error(message('Wavelet:FunctionInput:ArgumentName'));
        end
    end
end

% Define wavelet.
if isempty(WAV_Input) , WAV_Input = 'morl'; end
param = [];
if isstruct(WAV_Input)
    wname = WAV_Input.name;
    param = WAV_Input.param;
elseif iscell(WAV_Input)
    wname = WAV_Input{1};
    if length(WAV_Input)>1 , param = WAV_Input{2}; end
else
    wname = WAV_Input;
end
if isempty(param)  
    param = waveft2(wname); param = param(2:2:end);
end
WAV.wname = wname;
WAV.param = param;

% Choice of the normalization.
if isempty(normOPT) , normOPT = 'L2'; end
switch lower(normOPT)
    case 'l2' , normPOW = 1;
    case 'l1' , normPOW = 0;
    case 'l0' , normPOW = 2;
    otherwise , normPOW = 1;   % Default: the L2 normalization.
end

% Define Scales
if isempty(SCA)
    
    scales = 1:10;
    scales = 2.^(0:5);
    nbSca = length(scales);
    
elseif isnumeric(SCA)
    validateattributes(SCA,{'numeric'},{'finite','>=',1,'vector'},...
        'CWTFT2','SCALES');
    scales = SCA;
    nbSca = length(scales);
    DF2 = sum(diff(SCA,2));
    if abs(DF2)<sqrt(eps)
        ScType = 'lin';
    else
        B = log(SCA/SCA(1));
        if abs(B/B(2)-round(B/B(2))) < sqrt(eps) , ScType = 'pow'; end
    end  

   
else
    error(message('Wavelet:cwtft:CWTFT2_SCALES'));
end

% Compute the mean of data. (Ajout MiMi)
meanSIG = mean(X(:));

% Define Angles
angles = ANG;
nbAng  = length(angles);

% Compute the 2D fft.
fimg = fft2(X);
if isempty(fimg) , fimg = 0; end
nbPlans = size(X,3); 

% Creation of the frequency plane.
S = size(fimg);
H = S(1);
W = S(2);
W2      = floor((W-1)/2);
H2      = floor((H-1)/2);
W_puls  = 2*pi/W*[ 0:W2  (W2-W+1):-1 ];
H_puls  = 2*pi/H*[ 0:H2  (H2-H+1):-1 ];
[xx,yy] = meshgrid(W_puls,H_puls);
dxxdyy  = abs( (xx(1,2) - xx(1,1)) * (yy(2,1) - yy(1,1)));

% Initialization of the CWT computation.
cwtcfs   = zeros(H,W,nbPlans,nbSca,nbAng);
wav_norm = zeros(nbSca,nbAng);
pipow = 0.5/(2*pi);
for nbp = 1:nbPlans
    for idxSca = 1:nbSca
        for idxAng = 1:nbAng
            valSca = scales(idxSca);
            valAng = angles(idxAng);
            factor = valSca;
            nxx = factor * (cos(valAng).*xx - sin(valAng).*yy);
            nyy = factor * (sin(valAng).*xx + cos(valAng).*yy);
            mask = valSca^normPOW * waveft2(WAV,nxx,nyy);
            cwtcfs(:,:,nbp,idxSca,idxAng) = ifft2(fimg(:,:,nbp).*conj(mask));
            wav_norm(idxSca,idxAng) = (sum(abs(mask(:)).^2)*dxxdyy)^pipow;
        end
    end
end

% Build output structure
CWTStruct = struct(...
    'wav',WAV,'wav_norm',wav_norm, ...
    'cfs',cwtcfs,'scales',scales,'angles',angles, ...
    'meanSIG',meanSIG);

if ~flag_PLOT , return; end



% Plot analysis if required.
figName = getWavMSG('Wavelet:cwtfttool2:cwtft2_figName',upper(wname));
fig = figure(...
    'Name',figName, ...
    'Units','normalized','Position',[0.1 0.1 0.5 0.75],...
    'Tag','Win_CWTFT_2D');
ax = subplot(3,2,1);
pos = get(ax,'Position');
pos(2) = pos(2)+0.02;
set(ax,'Position',pos);
trueColorIMG = (size(X,3)==3); 
if ~trueColorIMG
    colormap(pink(222))
    imagesc(X,'Parent',ax);
    Add_ColorBar(ax);
else
    image(X,'Parent',ax);
end
wtitle(getWavMSG('Wavelet:cwtfttool2:Original_Data'),'Parent',ax)
numSca = 1;
numAng = 1;
wtbxappdata('set',fig,'CWTStruct',CWTStruct);

Ysc = cwtcfs(:,:,:,numSca,numAng);
axHdl = plotAnalysis('init',fig,Ysc,numSca,numAng);
axHdl(1) = ax;
wtbxappdata('set',fig,'axHdl',axHdl);

strBTN = [...
    repmat(getWavMSG('Wavelet:cwtfttool2:Str_Idx_Scale'),nbSca,1) num2str((1:nbSca)','%4.0f') ...
    repmat([' -- ' getWavMSG('Wavelet:cwtfttool2:Str_Scale_Value') ' '],nbSca,1) num2str(scales','%3.3f')];
Pop_SCA = uicontrol(fig,'Style','popupmenu', ...
    'String',strBTN, ...
    'Value',1, ...
    'Units','normalized',...
    'Position',[0.02  0.015  0.25  0.03], ...
    'Tag','Pop_SCA' ...
    );
set(Pop_SCA,'Callback',mfilename);

Pus_MOV = uicontrol(fig,'Style','pushbutton', ...
    'String',getWavMSG('Wavelet:cwtfttool2:Str_Movie'), ...
    'Units','normalized',...
    'Position',[0.27  0.012  0.1  0.035], ...
    'Tag','Pus_MOV' ...
    );
set(Pus_MOV,'Callback',mfilename);


tempo = rats(ANG'/pi);
tempo(:,[1:4,end-3:end]) = [];
strBTN = [...
    repmat(getWavMSG('Wavelet:cwtfttool2:Str_Idx_Angle'),nbAng,1) num2str((1:nbAng)','%4.0f') ...
    repmat([' -- ' getWavMSG('Wavelet:cwtfttool2:Str_Angle_Value') ' '],nbAng,1) tempo repmat('pi',nbAng,1)];

Pop_ANG = uicontrol(fig,'Style','popupmenu', ...
    'String',strBTN, ...
    'Value',1, ...
    'Units','normalized',...
    'Position',[0.40  0.015  0.25  0.03], ...
    'Tag','Pop_ANG' ...
    );
set(Pop_ANG,'Callback',mfilename);

Pus_MOV = uicontrol(fig,'Style','pushbutton', ...
    'String',getWavMSG('Wavelet:cwtfttool2:Str_Movie'), ...
    'Units','normalized',...
    'Position',[0.65  0.012  0.1  0.035], ...
    'Tag','Pus_MOV_ANG' ...
    );
set(Pus_MOV,'Callback',mfilename);

if size(X,3)<3    
    strBTN = wtranslate('lstcolormap');
    names = mextglob('get','Lst_ColorMap');
    Pop_MAP = uicontrol(fig,'Style','popupmenu', ...
        'String',strBTN, ...
        'Value',1, ...
        'Units','normalized',...
        'Position',[0.80  0.015  0.1  0.03], ...
        'UserData',names, ...
        'Tag','Pop_MAP' ...
        );
    set(Pop_MAP,'Callback',mfilename);
end

fig.CloseRequestFcn = @(o,e)Close_Function(o,e);

% Select the last scale.
Cb_PopBTN(Pop_SCA,floor(nbSca/3));


%--------------------------------------------------------------------------
function axHdl = plotAnalysis(option,fig,Ysc,numSca,numAng)

switch option
    case 'init' , decale = 0.00;
    case {'pop','pus'}  , axHdl = wtbxappdata('get',fig,'axHdl');
end
for num = 3:6
    if isequal(option,'init')
        ax = subplot(3,2,num);
        axHdl(num) = ax;
        pos = get(ax,'Position');
        pos(2) = pos(2)- decale;
        set(ax,'Position',pos);
    else
        ax = axHdl(num);
    end
    switch num
        case 3
            displayImage(abs(Ysc),ax)
            wxlabel(getWavMSG('Wavelet:cwtft:Str_Modulus'),'Parent',ax);
        case 4
            displayImage(angle(Ysc),ax)            
            wxlabel(getWavMSG('Wavelet:cwtft:Str_Angle'),'Parent',ax);
        case 5
            displayImage(real(Ysc),ax)            
            wxlabel(getWavMSG('Wavelet:cwtft:Str_Real_Part'),'Parent',ax);
        case 6
            displayImage(imag(Ysc),ax)            
            wxlabel(getWavMSG('Wavelet:cwtft:Str_Imaginary_Part'),'Parent',ax);
    end
end

CWTStruct = wtbxappdata('get',fig,'CWTStruct');
TMP = CWTStruct.scales; SCA = TMP(numSca);
TMP = CWTStruct.angles; ANGSTR = getAngleSTR(TMP(numAng));

BigTitleSTR = getWavMSG('Wavelet:cwtfttool2:BigTitleSTR_2D_BIS', ...
        numSca,num2str(SCA,'%3.3f'),numAng,ANGSTR);
if isequal(option,'init')    
    p1 = get(axHdl(3),'Position');
    x1 = p1(1);
    p2 = get(axHdl(4),'Position');
    x2 = p2(1)+p2(3);
    xM = (x1+x2)/2;
    w  = 0.7;
    xL = xM-w/2;
    yL = p1(2)+1.05*p1(4);
    pos = [xL , yL , w , 0.05];
    colFIG = get(fig,'Color');
    st = dbstack; name = st(end).name;
    if isequal(name,'mdbpublish') , colFIG = 'w'; end
    bigTitle = uicontrol('Style','text','Units','normalized',...
        'Position',pos,'BackgroundColor',colFIG, ...
        'FontSize',10,'FontWeight','bold',...
        'String',BigTitleSTR,'Parent',fig);
    wtbxappdata('set',fig,'bigTitle',bigTitle);
else
    bigTitle = wtbxappdata('get',fig,'bigTitle');
    set(bigTitle,'String',BigTitleSTR);
end
if size(Ysc,3)>1 , return; end
for num = 3:6 , Add_ColorBar(axHdl(num)); end
%-----------------------------------------------------------------------
function OK_Cb = Cb_PopBTN(obj,val)

if nargin<1
    [obj,fig] = gcbo;
    if isempty(obj) , OK_Cb = false; return; end
else
    fig = get(obj,'Parent');
    set(obj,'Value',val);
end
OK_Cb = true;
num = get(obj,'Value');
tag = get(obj,'Tag');

Pop_SCA = wfindobj(fig,'tag','Pop_SCA');
Pop_ANG = wfindobj(fig,'tag','Pop_ANG');
numSca = get(Pop_SCA,'Value');
numAng = get(Pop_ANG,'Value');

switch tag
    case 'Pop_SCA'
        CWTStruct = wtbxappdata('get',fig,'CWTStruct');
        Ysc = CWTStruct.cfs(:,:,:,numSca,numAng);
        plotAnalysis('pop',fig,Ysc,numSca,numAng);
        Pus_MOV = wfindobj(fig,'Type','uicontrol','Tag','Pus_MOV');
        set(Pus_MOV,'Userdata',num);
        
    case 'Pop_ANG' 
        CWTStruct = wtbxappdata('get',fig,'CWTStruct');
        Ysc = CWTStruct.cfs(:,:,:,numSca,numAng);
        plotAnalysis('pop',fig,Ysc,numSca,numAng);
        Pus_MOV = wfindobj(fig,'Type','uicontrol','Tag','Pus_MOV');
        set(Pus_MOV,'Userdata',num);
        
    case 'Pop_MAP'
        strPOP = mextglob('get','Lst_ColorMap');
        mapName = strPOP{num};
        if ~ismember(num,10:15)
            map = feval(mapName,222);
        else
            mapName = mapName(5:end);
            map = 1 - feval(mapName,222);
        end
        colormap(map)
        
    case 'Pus_MOV'
        usr = get(obj,'Userdata');
        if isequal(usr,'Movie') , set(obj,'Userdata','Stop'); return; end
        CWTStruct = wtbxappdata('get',fig,'CWTStruct');
        nbSca = length(CWTStruct.scales);
        StrOBJ = getWavMSG('Wavelet:cwtfttool2:Stop_Movie');      
        set(obj,'String',StrOBJ,'Userdata','Movie');
        numInit = usr;
        if isempty(numInit) || isequal(numInit,nbSca) , numInit = 1; end
        Pop_SCA = wfindobj(fig,'Type','uicontrol','Tag','Pop_SCA');
        for numSca = numInit:nbSca
            Ysc = CWTStruct.cfs(:,:,:,numSca,numAng);
            plotAnalysis('pus',fig,Ysc,numSca,numAng);
            set(Pop_SCA,'Value',numSca);
            pause(0.1)
            usr = get(obj,'Userdata');
            if isequal(usr,'Stop') , break; end
        end
        StrOBJ = getWavMSG('Wavelet:cwtfttool2:Str_Movie');
        set(obj,'String',StrOBJ,'Userdata',numSca);
        
    case 'Pus_MOV_ANG'
        usr = get(obj,'Userdata');
        if isequal(usr,'Movie') , set(obj,'Userdata','Stop'); return; end
        CWTStruct = wtbxappdata('get',fig,'CWTStruct');
        nbAng = length(CWTStruct.angles);
        StrOBJ = getWavMSG('Wavelet:cwtfttool2:Stop_Movie');      
        set(obj,'String',StrOBJ,'Userdata','Movie');
        numInit = usr;
        if isempty(numInit) || isequal(numInit,nbAng) , numInit = 1; end
        Pop_SCA = wfindobj(fig,'Type','uicontrol','Tag','Pop_ANG');
        for numAng = numInit:nbAng
            Ysc = CWTStruct.cfs(:,:,:,numSca,numAng);
            plotAnalysis('pus',fig,Ysc,numSca,numAng);
            set(Pop_ANG,'Value',numAng);
            pause(0.1)
            usr = get(obj,'Userdata');
            if isequal(usr,'Stop') , break; end
        end
        StrOBJ = getWavMSG('Wavelet:cwtfttool2:Str_Movie');
        set(obj,'String',StrOBJ,'Userdata',numAng);
        
end
%-----------------------------------------------------------------------
function Add_ColorBar(hA)

pA = get(hA,'Position');
hC = colorbar('peer',hA,'EastOutside');
pC = get(hC,'Position');
set(hA,'Position',pA);
set(hC,'Position',[pA(1)+pA(3)+0.01  pC(2)+pC(4)/15 pC(3)/2.1 4*pC(4)/5])
%-----------------------------------------------------------------------
function displayImage(Y,ax)

if size(Y,3)>2
    for k = 1:3 , Y(:,:,k) = wcodemat((Y(:,:,k)),255,'mat',0); end
    image(uint8(Y),'Parent',ax);
else
    Y = Y-min(Y(:));
    Y = Y/max(abs(Y(:)));
    imagesc(Y,'Parent',ax);
end
%--------------------------------------------------------------------------
function angSTR = getAngleSTR(val)

Deg = (180*val/pi);
tempo = rats(val/pi);
tempo(tempo==' ') = [];
angSTR = [' ' tempo ' pi [rad] = ' num2str(Deg,'%3.2f') ' [dgr]'];
%--------------------------------------------------------------------------

function Close_Function(o,e) %#ok<INUSD>
mextglob('clear')
delete(o);
