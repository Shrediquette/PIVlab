function Xrec = icwtft(S,varargin)
% ICWTFT Inverse continuous wavelet transform using FFT.
%   XREC = ICWTFT(CWTSTRUCT) returns the inverse continuous
%   wavelet transform using a Fourier transform based algorithm.
%   CWTSTRUCT is a structure returned by CWTFT containing seven fields:
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
%   With XREC = ICWTFT(...,'plot') plots the reconstructed signal from
%   the continuous wavelet coefficients.
%
%   In addition, with XREC = ICWTFT(...,'signal',SIG,'plot') provides a 
%   checkbox to superimpose the original signal SIG on the plot.
%
%   SIG can be a vector, a structure or a cell array. If SIG is a vector,
%   it contains the values of the original analyzed signal. If SIG is a
%   structure, SIG.val and SIG.period contain respectively the signal
%   values and the sampling period. If SIG is a cell array, SIG{1} and
%   SIG{2} contain respectively the values of the signal and the sampling
%   period.
%
%   XREC = ICWTFT(...,'IdxSc',IdxSc2Inv) returns the reconstructed 
%   signal obtained by using the scales in IdxSc2Inv. IdxSc2Inv is a subset
%   of the scales used in the continuous wavelet transform.
%
%   %Example:
%   load kobe;
%   dt = 1;
%   s0 = 2*dt;
%   a0 = 2^(1/16);
%   scales = s0*a0.^(0:7*16);
%   cwtkobe = cwtft(kobe,'wavelet',{'bump',[4 0.7]},'scales',scales);
%   xrec = icwtft(cwtkobe);
%   subplot(2,1,1)
%   plot(kobe); title('Kobe Earthquake Data');
%   subplot(2,1,2)
%   plot(xrec); title('Inverse CWT');
%
%   See also CWTFT, CWTFTINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check input arguments.
nbIN = nargin;
if nbIN==0 , OK_Cb = Cb_RadBTN; if OK_Cb , return; end; end
narginchk(1,6);
flag_PLOT = false;
flag_SIG = false;
IdxSc2Inv = 1:length(S.scales);

if nbIN>1
    nbIN = nbIN-1;
    k = 1;
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
            case 'mulwav'
                mulWAV = varargin{k+1}; %#ok<NASGU>
                k = k+2;
            otherwise
                error(message('Wavelet:FunctionInput:ArgumentName'));
        end
    end
end

param = [];
WAV = S.wav;
if isstruct(WAV)
    wname = WAV.name;
    param = WAV.param;
elseif iscell(WAV)
    wname = WAV{1};
    if length(WAV)>1 , param = WAV{2}; end
else
    wname = WAV;
end

[NbSc,N] = size(S.cfs);
cwtcfs = zeros(NbSc,N); 
cwtcfs(IdxSc2Inv,:) = S.cfs(IdxSc2Inv,:);
scales = S.scales(:);

    if strcmpi(wname,'bump')
        Xrec = invertBumpCWT(cwtcfs,S.scales,param,S.dt);
        Xrec = Xrec+S.meanSIG;
        nbSamp = length(Xrec);
    
    end
    if ~strcmpi(wname,'bump')
        [NbSc,N] = size(S.cfs);
        cwtcfs = zeros(NbSc,N); 
        cwtcfs(IdxSc2Inv,:) = S.cfs(IdxSc2Inv,:);

        % Real part of the wavelet transform.
        Wr = real(cwtcfs);

        % Compute the sum.
        repSca = repmat(scales,[1,size(cwtcfs,2)]);
        summand = sum(Wr./sqrt(repSca),1);

        % Compute the constant factor.
        wft = waveft(S.wav,S.omega,scales);
        Wdelta = sum(wft,2)/N;
        RealWdelta = real(Wdelta);
        RealWdelta = RealWdelta(:);
        C = sum(RealWdelta./sqrt(scales));

        % Compute the inverse transform.
        mulWAV = get_mulWAV(S.wav);
        Xrec = (1/C)*summand;
        Xrec = (Xrec-mean(Xrec))/mulWAV + S.meanSIG;
        nbSamp = length(Xrec);
    end

% Plot if necessary.
if ~flag_PLOT , return; end

% Signal.
dt = S.dt;
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
pA = [xL , yL , w , 0.035];
uicontrol('Style','text','Units','normalized',...
    'Position',pA,'BackgroundColor',colFIG, ...
    'FontSize',10,'FontWeight','bold',...
    'String',BigTitleSTR,'Parent',fig);


%--------------------------------------------------------------------------
function mulWAV = get_mulWAV(WAV)

if isstruct(WAV)
    wname = WAV.name;
    param = WAV.param;
elseif iscell(WAV)
    wname = WAV{1};
    if length(WAV)>1 , param = WAV{2}; end
else
    wname = WAV;
    param = [];
end
switch wname
    case {'morl'}
        if isempty(param) , param = 6; end
        tab_VAL = (1:0.25:10);
        % Medians.
        %---------
        tab_MUL = [...
            9.3414	7.7459	6.3586	5.1910	4.2406	3.4910	2.9152 ...
            2.4802	2.1528	1.9062	1.7165	1.5668	1.4467	1.3499 ...
            1.2730	1.2116	1.1611	1.1163	1.0762	1.0362	1.0014 ...
            0.9820	0.9799	0.9971	1.0332	1.0748	1.1006	1.0956 ...
            1.0550	1.0016	0.8997	0.8060	0.7218	0.6961	0.7392 ...
            0.8171	0.9192	1.0350	1.1008	1.1464 ...
            ];
        % Means.
        %-------
        % tab_MUL = [...
        %     9.2117	7.6503	6.2908	5.1450	4.2108	3.4726	2.9041 ...
        %     2.4741	2.1506	1.9052	1.7159	1.5665	1.4467	1.3503 ...
        %     1.2729	1.2110	1.1599	1.1155	1.0746	1.0367	1.0048 ...
        %     0.9854	0.9834	1.0005	1.0324	1.0676	1.0896	1.0860 ...
        %     1.0497	0.9816	0.8901	0.7966	0.7214	0.6813	0.6862 ...
        %     0.7336	0.8169	0.9218	1.0026	1.0573 ...
        %     ];
        
    case 'morlex'
        if isempty(param) , param = 6; end
        tab_VAL = (1:0.25:10);
        % Medians.
        %---------        
        tab_MUL = [...
            11.7171	9.7067	7.8216	6.1911	4.8720	3.8609	3.1171 ...
            2.5835	2.2033	1.9286	1.7254	1.5706	1.4481	1.3505 ...
            1.2731	1.2116	1.1611	1.1163	1.0762	1.0362	1.0014 ...
            0.9820	0.9799	0.9971	1.0332	1.0748	1.1006	1.0956 ...
            1.0550	1.0016	0.8997	0.8060	0.7218	0.6961	0.7392 ...
            0.8171	0.9192	1.0350	1.1008	1.1464 ...
            ];
        % Means.
        %-------        
        % tab_MUL = [...
        %     11.5299	9.5646	7.7192	6.1215	4.8271	3.8336	3.1013 ...
        %     2.5746	2.1985	1.9267	1.7249	1.5700	1.4480	1.3507 ...
        %     1.2731	1.2110	1.1599	1.1155	1.0746	1.0367	1.0048 ...
        %     0.9854	0.9834	1.0005	1.0324	1.0676	1.0896	1.0860 ...
        %     1.0497	0.9816	0.8901	0.7966	0.7214	0.6813	0.6862 ...
        %     0.7336	0.8169	0.9218	1.0026	1.0573 ...
        %     ];
        
    case 'morl0'
        if isempty(param) , param = 6; end
        tab_VAL = (1:0.25:10);
        % Medians.
        %---------                
        tab_MUL = [...
            3.9209	3.7320	3.5110	3.2655	3.0057	2.7430	2.4887	...
            2.2521	2.0394	1.8531	1.6930	1.5568	1.4429	1.3487	...
            1.2725	1.2114	1.1610	1.1163	1.0762	1.0362	1.0014	...
            0.9820	0.9799	0.9971	1.0332	1.0748	1.1006	1.0956	...
            1.0550	1.0016	0.8997	0.8060	0.7218	0.6961	0.7392	...
            0.8171	0.9192	1.0350	1.1008	1.1464 ...           
            ];
        % Means.
        %-------        
        % tab_MUL = [...
        %     11.5299	9.5646	7.7192	6.1215	4.8271	3.8336	3.1013 ...
        %     2.5746	2.1985	1.9267	1.7249	1.5700	1.4480	1.3507 ...
        %     1.2731	1.2110	1.1599	1.1155	1.0746	1.0367	1.0048 ...
        %     0.9854	0.9834	1.0005	1.0324	1.0676	1.0896	1.0860 ...
        %     1.0497	0.9816	0.8901	0.7966	0.7214	0.6813	0.6862 ...
        %     0.7336	0.8169	0.9218	1.0026	1.0573 ...
        %     ];
        
    case 'paul'
        if isempty(param) , param = 4; end
        tab_VAL = (1:0.25:10);
        % Medians.
        %---------                        
        tab_MUL = [...
            5.2631	4.2772	3.5891	3.0903	2.7147	2.4250	2.1950 ...
            2.0092	1.8565	1.7293	1.6224	1.5317	1.4542	1.3877 ...
            1.3302	1.2804	1.2370	1.1990	1.1658	1.1365	1.1107 ...
            1.0879	1.0675	1.0494	1.0330	1.0183	1.0050	0.9927 ...
            0.9813	0.9708	0.9609	0.9516	0.9428	0.9344	0.9262 ...
            0.9182	0.9104	0.9027	0.8950	0.8873
            ];
        % Means.
        %-------        
        % tab_MUL = [...
        %     5.2226	4.2559	3.5781	3.0842	2.7119	2.4230	2.1934 ...
        %     2.0075	1.8546	1.7271	1.6198	1.5286	1.4504	1.3831 ...
        %     1.3247	1.2738	1.2292	1.1898	1.1550	1.1239	1.0961 ...
        %     1.0710	1.0482	1.0274	1.0083	0.9907	0.9743	0.9590 ...
        %     0.9445	0.9308	0.9177	0.9052	0.8933	0.8819	0.8709 ...
        %     0.8604	0.8502	0.8403	0.8308	0.8214 ...
        %     ];
        
        
    case 'dog'
        if isempty(param) , param = 2; end
        tab_VAL = 2:2:20;
        % Medians.
        %---------                                
        tab_MUL = [...
            4.2708	2.8440	2.2734	1.9469	1.7318	1.5811	1.4637 ...
            1.3581	1.2555	1.1720 ...
            ];
        % Means.
        %-------
        % tab_MUL = [...
        %     4.2659	2.8431	2.2727	1.9465	1.7316	1.5803	1.4624 ...
        %     1.3567	1.2572	1.1755 ...
        %     ];
        
    case 'mexh'
        param   = 2;
        tab_VAL = 2;
        tab_MUL = 4.2708; % tab_MUL = 4.2659;
end

D = tab_VAL-param;
[mini,idx] = min(abs(D));
if mini<sqrt(eps)
    mulWAV = tab_MUL(idx);
else
    I1 = find(D<0,1,'last');
    I2 = find(D>0,1,'first');
    T1 = tab_VAL(I1);
    T2 = tab_VAL(I2);
    mulWAV = ((T2-param)*tab_MUL(I1)+  ...
        (param-T1)*tab_MUL(I2))/(T2-T1);
end
% idx = tab_VAL==param;
% if all(idx==0)
%     [~,idx] = min(abs(tab_VAL-param));
% end
% mulWAV = tab_MUL(idx);
%--------------------------------------------------------------------------



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
    wxlabel(LabSTR,'Parent',ax,'FontSize',8)
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
