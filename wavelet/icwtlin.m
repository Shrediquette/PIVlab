function Xrec = icwtlin(varargin)
%ICWTLIN Inverse continuous wavelet transform using linear scales.
%   XREC = ICWTLIN(CWTSTRUCT) returns the reconstructed signal XREC
%   using the data contained in the structure CWTSTRUCT.
%   CWTSTRUCT may be obtained from CWTFT or built from the output of CWT.
%   If CWTSTRUCT is the output of CWTFT, the structure array contains seven 
%   fields:
%
%      cfs:         coefficients of wavelet transform.
%      scales:      vector of scales used for CWT. 
%      frequencies: frequencies in cycles per unit time (or space)
%                   corresponding to the scales.
%      wav:         wavelet used for the analysis.
%      omega:       angular frequencies for the Fourier transform.
%      meanSIG:     mean of the analyzed signal.
%      dt:          sampling period.
%	
%   If the continuous wavelet transform was obtained using CWT, CWTSTRUCT 
%   must be a structure containing the following five fields:
%
%       cfs:        coefficients of wavelet transform.
%       scales:      vector of scales used for CWT.
%       wav:         wavelet used for the analysis.
%       meanSIG:     mean of the analyzed signal.
%       dt:          sampling period.
%
%   For the CWT, supported wavelets for reconstruction are:
%      - coif1, coif2, coif3, coif4, coif5
%      - bior2.2, bior2.4, bior2.6, bior2.8, bior4.4, bior5.5, bior6.8
%      - rbio2.2, rbio2.4, rbio2.6, rbio2.8, rbio4.4, rbio5.5, rbio6.8
%      - gau2, gau4, gau6, gau8
%      - cgau2, cgau4, cgau6, cgau8
%      - morl, mexh
%
%   XREC = ICWTLIN(...,'IdxSc',IdxSc2Inv) returns the reconstructed
%   signal using only the scales indicated by the indices in IdxSc2Inv.
%   The subset of selected scales should be a linearly-spaced set.
%
%   XREC = ICWTLIN(WAV,meanSIG,cfs,scales,dt) reconstructs the signal based
%   on the CWT-supported wavelet WAV, the mean signal value, the CWT
%   coefficients, the scales, and the sampling period.
%
%   XREC = ICWTLIN(...,'plot') plots the reconstructed signal.
%
%   XREC = ICWTLIN(...,'signal',SIG,'plot') provides a checkbox to
%   superimpose the original signal SIG on the plot.
%
%   %Example:
%   load kobe;
%   scales = 2:256;
%   cwtkobe = cwtft(kobe,'wavelet',{'bump',[4 0.7]},'scales',scales);
%   xrec = icwtlin(cwtkobe);
%   subplot(2,1,1)
%   plot(kobe); title('Kobe Earthquake Data');
%   subplot(2,1,2)
%   plot(xrec); title('Inverse CWT');
%
%   See also CWT, CWTFT, ICWTFT, CWTFTINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.


nbIN = nargin;
if nbIN==0 , OK_Cb = Cb_RadBTN; if OK_Cb , return; end; end
narginchk(1,10);
flag_PLOT = false;
flag_SIG = false;
if isstruct(varargin{1})
    CWTS = varargin{1};
    WAV = CWTS.wav;
    meanSIG = CWTS.meanSIG;
    cfs     = CWTS.cfs;
    scales  = CWTS.scales;
    dt      = CWTS.dt;
    nextARG = 2;
    if isfield(CWTS,'omega') 
        recTYPE = 'cwtft'; 
    else
        recTYPE = 'cwt';
    end
else
    [WAV,meanSIG,cfs,scales,dt] = varargin{1:5};
    CWTS.WAV = WAV;
    CWTS.meanSIG = meanSIG;
    CWTS.cfs = cfs;
    CWTS.scales = scales;
    CWTS.dt = dt;
    recTYPE = 'cwt';
    nextARG = 6;
end
IdxSc2Inv = 1:length(scales);
if nbIN>nextARG-1
    k = nextARG;
    while k<=nbIN
        argNAM = lower(varargin{k});
        switch argNAM
            case 'plot'
                flag_PLOT = true;
                k = k+1;
                
            case 'signal'
                flag_SIG = true;
                SIG = varargin{k+1};
                k = k+2;
                
            case 'idxsc'
                IdxSc2Inv = varargin{k+1};
                k = k+2;
                
            otherwise
                error(message('Wavelet:FunctionInput:ArgumentName'));
        end
    end
end

if isstruct(WAV)
    wname = WAV.name;
    par   = WAV.param;
elseif iscell(WAV)
    wname = WAV{1};
    par   = WAV{2};
elseif ischar(WAV)
    wname = WAV;
    switch wname
        case {'morl','morlex','morl0'} , par = 6;
        case 'mexh' , par =[];
        case 'paul' , par = 4;
        case 'dog'  , par = 4;
        case 'bump', par = [5 0.6];    
    end
else
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'));
end

NbSc = length(scales);
IdxZER = setdiff(1:NbSc,IdxSc2Inv);
cfs(IdxZER,:) = 0;
    if strcmpi(wname,'bump')
        Xrec = invertBumpCWT(cfs,scales,par,CWTS.dt);
        Xrec = Xrec+CWTS.meanSIG;
    end  

    if (strcmpi(recTYPE,'cwtft') && ~strcmpi(wname,'bump'))
    
        switch wname
            case {'morl','morlex','morl0','paul'}
                cfsINV = 1;
                tab_PAR = [4.25:0.25:7 , 7.5:0.5:14];
                tab_MUL = [...
                    5.3146 , 4.9753 , 4.6791 , 4.4182 , 4.1865 , ...
                    3.9796 , 3.7936 , 3.6255 , 3.4721 , 3.3315 , ...
                    3.2019 , 3.0818 , 2.8675 , 2.6830 , 2.5218 , ...
                    2.3785 , 2.2500 , 2.1353 , 2.0322 , 1.9381 , ...
                    1.8526 , 1.7751,  1.7036 , 1.6371 , 1.5750 , ...
                    1.5178   ...
                    ];
                if isequal(wname,'morl')
                    tab_PAR = [0.25:0.25:4 , tab_PAR];
                    tab_MUL = [ ...
                        21.5465 , 22.4798 , 22.4536 , 21.5719 , 20.0432 ,...
                        18.1186 , 16.0491 , 14.0355 , 12.2127 , 10.6446 ,...
                        9.3427 ,  8.2734 ,  7.4292 ,  6.7393 ,  6.1763 , ...
                        5.7116 , tab_MUL];
                elseif isequal(wname,'morlex')
                    tab_PAR = [0.25 , 0.50 , 3:0.25:4 , tab_PAR];
                    tab_MUL = [...
                        38.7005 , 36.6430 , 8.3756 , 7.4696 , 6.7560 , ...
                        6.1828 ,  5.7092 , tab_MUL];
                elseif isequal(wname,'morl0')
                    tab_PAR = [0.25 , 3:0.25:4 , tab_PAR];
                    tab_MUL = [...
                        38.7005 , 7.9379 , 7.2691 , 6.6698 , 6.1481 , ...
                        5.6983 , tab_MUL];
                else   % 'paul'
                    tab_PAR = (1:11);
                    tab_MUL = [18.8672 , 12.5749, ...
                        9.4250 , 7.5853 , 6.3935 , 5.5629 , 4.9465 ,  ...
                        4.4673 , 4.0806 , 3.7576 , 3.4786 ,  ...
                        ];
                end
                
    
                D = tab_PAR-par;
                [mini,idx] = min(abs(D));
                if mini<sqrt(eps)
                    mulWAV = tab_MUL(idx);
                else
                    I1 = find(D<0,1,'last');
                    I2 = find(D>0,1,'first');
                    T1 = tab_PAR(I1);
                    T2 = tab_PAR(I2);
                    mulWAV = ((T2-par)*tab_MUL(I1)+  ...
                        (par-T1)*tab_MUL(I2))/(T2-T1);
                end
                
            case 'dog'
                cfsINV = (-1)^(1+0.5*par);
                switch par
                    case 2 ,  mulWAV = 19;
                    case 4 ,  mulWAV = 13.158;
                    case 6 ,  mulWAV = 10.571;
                    case 8 ,  mulWAV =  9.028;
                    case 10 , mulWAV = 8.087;
                    otherwise , mulWAV = 8;
                end
                
            case 'mexh' , mulWAV = 19.421;  cfsINV = 1;
            case 'dofg' , mulWAV = 18.9715; cfsINV = 1;
        end
        % The constant mulWAV was computed using a sampling period of 0.05.
        % Also, we must perform a renormalization.
        mulWAV = mulWAV/sqrt(dt/0.05); 
    end      


           
    if strcmpi(recTYPE,'cwt')
        [name,num] = getNameNumWave(wname);
                switch name
                    case 'coif'
                        cfsINV = 1;
                        switch num
                            case 1 , mulWAV = 2.401;
                            case 2 , mulWAV = 2.040;
                            case 3 , mulWAV = 1.905;
                            case 4 , mulWAV = 1.825;
                            case 5 , mulWAV = 1.775;
                        end
                
                    case 'bior'
                        cfsINV = 1;
                        switch num
                            case 2.2 , mulWAV = 2.875;
                            case 2.4 , mulWAV = 2.675;
                            case 2.6 , mulWAV = 2.5875;
                            case 2.8 , mulWAV = 2.548;
                            case 4.4 , mulWAV = 1.942;
                            case 5.5 , mulWAV = 1.5285;
                            case 6.8 , mulWAV = 1.915;
                        end
                
                
                    case 'rbio'
                        cfsINV = 1;
                        switch num
                            case 2.2 , mulWAV = 2.441;
                            case 2.4 , mulWAV = 1.955;
                            case 2.6 , mulWAV = 1.794;
                            case 2.8 , mulWAV = 1.713;
                            case 4.4 , mulWAV = 2.276;
                            case 5.5 , mulWAV = 2.6475;
                            case 6.8 , mulWAV = 1.865;
                        end
                
                    case 'cgau'
                        switch num
                            case 2 , cfsINV = -1; mulWAV = 2.475;  %% OK
                            case 4 , cfsINV =  1; mulWAV = 1.625;  %% OK
                            case 6 , cfsINV = -1; mulWAV = 1.295;  %% OK
                            case 8 , cfsINV =  1; mulWAV = 1.110;  %% OK
                        end
                
                    case 'gaus'
                        cfsINV = 1;
                            switch num
                                case 2 , mulWAV = 3.657;
                                case 4 , mulWAV = 2.475;
                                case 6 , mulWAV = 1.991;
                                case 8 , mulWAV = 1.713;
                            end
                
                    case 'mexh' , cfsINV = 1; mulWAV = 4.348;
                    case 'morl' , cfsINV = 1; mulWAV = 1.319;
                end
    end





    if ~strcmpi(wname,'bump')

        for k = 1:NbSc
            cfs(k,:) = cfs(k,:)/(scales(k)^1.5);
        end
        ds = scales(2)-scales(1);
        INVCWT = cfsINV*2*sum(real(cfs),1)*ds;
        Xrec = INVCWT/mulWAV;
        Xrec = Xrec-mean(Xrec)+meanSIG;
    end



% Plot if necessary.
if ~flag_PLOT , return; end

nbSamp = length(Xrec);

% Signal.
if flag_SIG
    if isstruct(SIG)
        signal = SIG.val; dt = SIG.period;
    elseif iscell(SIG)
        signal = SIG{1};  dt = SIG{2};
    else
        signal = SIG;
    end
    signal = signal(:)';
end

DF2 = sum(diff(scales,2));
if abs(DF2)<sqrt(eps)
    ScType = 'lin';
else
    B = log(scales/scales(1));
    if abs(B/B(2)-round(B/B(2))) < sqrt(eps) , ScType = 'pow'; end
end

cwtcfs = CWTS.cfs;
OK_real = isreal(cwtcfs);
numAXE = 1;
if OK_real 
    nbCOL = 1; 
else
    nbCOL = 2; 
end
fig = figure(...
    'Name',getWavMSG('Wavelet:cwtft:ICWTFT_Name'), ...
    'Units','normalized','Position',[0.1 0.1 0.5 0.75],'Tag','Win_ICWTFT');
ax = subplot(3,nbCOL,numAXE);
titleSTR = getWavMSG('Wavelet:cwtft:ICWTFT_RecSig');
posval = dt*(0:nbSamp-1);
plot(posval,Xrec,'b','Tag','RecSIG','Parent',ax); axis tight;
wtitle(titleSTR,'Parent',ax);
numAXE = numAXE+1;

if nbCOL>1
    ax = subplot(3,nbCOL,numAXE);
    plot(posval,Xrec,'b','Tag','RecSIG','Parent',ax); axis tight;
    wtitle(titleSTR,'Parent',ax);
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
    case 'lin' , ylabSTR = getWavMSG('Wavelet:cwtft:Str_Scales');
    case 'pow' , ylabSTR = getWavMSG('Wavelet:cwtft:Str_Scale_Power');
    otherwise  , ylabSTR = getWavMSG('Wavelet:cwtft:Str_Scales');
end
wylabel(ylabSTR,'Parent',ax);
numAXE = numAXE+1;

ax = subplot(3,nbCOL,numAXE);
if nbCOL>1
    titleSTR = getWavMSG('Wavelet:cwtft:Str_Real_Part');
    decale = 0.02;
    a2 = ax;
else
    titleSTR = getWavMSG('Wavelet:cwtft:Str_Values');
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

if flag_SIG
    btn = uicontrol(fig,'style','checkbox', ...
        'String',getWavMSG('Wavelet:cwtft:OrigSig_OnOff'), ...
        'FontSize',11', ...
        'Units','normalized',...
        'BackgroundColor',colFIG, ...
        'Position',[0.02  0.015  0.4  0.03], ...
        'Tag','ICWTFT_Rad_Rec' ...
        );
    set(btn,'Callback',mfilename);
    wtbxappdata('set',fig,'Signal',signal,'stepSIG',dt,'OK_real',OK_real);
end

% Display main title.
BigTitleSTR = getWavMSG('Wavelet:divGUIRF:CWT_Coefficients');
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
    'String',BigTitleSTR,'Parent',fig);

%---------------------------------------------------------
function Add_ColorBar(hA)

pA = get(hA,'Position');
hC = colorbar('peer',hA,'EastOutside');
set(hA,'Position',pA);
pC = get(hC,'Position');
set(hC,'Position',[pA(1)+pA(3)+0.01  pC(2)+pC(4)/15 pC(3)/2 4*pC(4)/5])
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
SCA = SCA(:);
imagesc(posval,SCA,C,'Parent',ax);
Add_ColorBar(ax)
wxlabel(titleSTR,'Parent',ax);
set(ax,'YDir','normal')
if isequal(ScType,'pow')
    yt = zeros(1,NbSc-1);
    for k = 1:NbSc-1 , yt(k)  = 0.5*(SCA(k)+SCA(k+1)); end
    for k = 1:NbSc-1
        hold on
        plot(posval,yt(k)*ones(1,length(posval)),':k','Parent',ax);
    end
    nb = min([5,NbSc-2]);
    YTaff = yt(end-nb:end);
    maxYT = max(YTaff);
    set(ax,'YTick',YTaff,'FontSize',9);
    if maxYT>0.05
        if maxYT<0.1
            precFormat = '%0.3f';
        elseif maxYT<1
            precFormat = '%0.2f';
        else
            precFormat = '%0.1f';
        end
        YTlab = num2str(SCA(end-nb:end),precFormat);
        set(ax,'YTickLabel',YTlab);
    end
else
    YTaff = linspace(SCA(1),SCA(end),10);
    YTlab = num2str(YTaff','%2.1f');
    set(ax,'YTick',YTaff,'YTickLabel',YTlab,'FontSize',9);
end
%-----------------------------------------------------------------------
function OK_Cb = Cb_RadBTN

[obj,fig] = gcbo;
if isempty(obj) , OK_Cb = false; return; end

[signal,OK_real] = wtbxappdata('get',fig,'Signal','OK_real');
if OK_real 
    nbCOL = 1; 
else
    nbCOL = 2;
end
ax = subplot(3,nbCOL,1);
hR = findobj(ax,'Tag','RecSIG');
h  = findobj(ax,'Tag','SIG');
Xrec = get(hR,'YData');
if isempty(h)
    xd = get(hR,'XData');
    errMAX = 100*max(abs(signal(:)-Xrec(:)))/max(abs(signal(:)));
    errL2  = 100*norm(signal(:)-Xrec(:))/norm(signal(:));
    LabSTR = sprintf(getWavMSG('Wavelet:cwtft:sprintf_RelativeErrorsMAX32fL232f',...
        sprintf('%3.2f',errMAX),sprintf('%3.2f',errL2)));
    wxlabel(LabSTR,'Parent',ax)
    hold on ;
    line('XData',xd,'YData',signal,'Color','r','Tag','SIG','Parent',ax);
    axis tight;
    strT = getWavMSG('Wavelet:cwtft:ICWTFT_RecOriSig');
else
    xl = get(ax,'XLabel');
    v = lower(get(h,'Visible'));
    if isequal(v,'on')
        v = 'off';
        strT = getWavMSG('Wavelet:cwtft:ICWTFT_RecSig');
    else
        v = 'on';
        strT = getWavMSG('Wavelet:cwtft:ICWTFT_RecOriSig');
    end
    set([h,xl],'Visible',v);
    if ~isequal(v,'on')
        set(ax,'YLim',[min(signal),max(signal)])
    else
        axis tight;
    end
end
wtitle(strT,'Parent',ax)
OK_Cb = true;
%-----------------------------------------------------------------------


%--------------------------------------------------------------
function [name,num] = getNameNumWave(wname)

lw = length(wname);
ab = abs(wname);
absNum = [43,45:46,48:57];
ii = lw;
while ii>1
    if ismember(ab(ii),absNum)
        ii = ii-1;
    else
        break
    end
end
num = str2num(wname(ii+1:lw));
name = wname(1:ii);
%--------------------------------------------------------------

