function fact_and_ls(IN1,IN2,IN3)
%FACT_AND_LS Factorizations and lifting schemes for wavelets. 
%   === NOT DOCUMENTED ===

%   Copyright 1995-2020 The MathWorks, Inc.

% Initialization.
%----------------
tolerance = 1.E-8;
waveCell_ALL = wavenames('all');

% FLAGS and type of display.
%---------------------------
filterFLAG = false;   % Flag for writing filters.
fileFLAG   = true;     % Flag for writing on files.   
typeDISP_VAL = {'fact' , 'LS'};

% Defaults.
%----------
waveCell_DEFAULT = {...
        'db1','db2','db3','db4','db5','db6',...
        'sym2','sym3','sym4','sym5','sym6',...
        'coif1','coif2',  ...
    };

% Check argument.
%----------------
if nargin<1
    waveCell = waveCell_DEFAULT;
elseif iscell(IN1)
    waveCell = IN1;
elseif ischar(IN1)
    if isequal(IN1,'all')
        waveCell = waveCell_ALL;
    elseif isequal(IN1,'haar')
        waveCell = {'db1'};
    else
        if any(strcmp(IN1,waveCell_ALL))
            waveCell = {IN1};
        else
            error(message('Wavelet:FunctionArgVal:Invalid_WavName'))
        end
    end
end

% Power Max setting.
%-------------------
powMAX_AUTO = false;
if nargin<2
    powMAX_AUTO = true;
elseif isequal(IN2,'auto')
    powMAX_AUTO = true;
elseif isequal(IN2,'set_1')
    powMAX_VAL  = [0,1,NaN];
elseif isnumeric(IN2)
    powMAX_VAL  = IN2;
end

% Diff. Power setting.
%---------------------
difPOW_AUTO = false;
if nargin<3
    if ~powMAX_AUTO
        difPOW_VAL = 0;
    else
        difPOW_AUTO = true;
    end
else
    difPOW_VAL = IN3;
end

% Begin display.
%---------------
dispSTR_1 = '#====#====#====#====#====#====#====#====#====#====#====#====#====#====#';
dispSTR_2 = '=================================';
dispSTR_3 = '+---+---+---+---+';
dispSTR_4 = '-------------------';

nb_WAVE_CUR = length(waveCell);
for k = 1:nb_WAVE_CUR
    wname = waveCell{k};
    
    if powMAX_AUTO
        TMP = wfilters(wname);
        LEN = length(TMP);
        powMAX_VAL  = -LEN:LEN;
        if difPOW_AUTO
            difPOW_VAL = 0:2:LEN;
        end
    end
    
    typeDISP = typeDISP_VAL{1};
    dispGENERAL_Info(typeDISP,fileFLAG,wname,dispSTR_1)
    dispGENERAL_Info(typeDISP,fileFLAG,wname, ...
        getWavMSG('Wavelet:moreMSGRF:BEG_Cur_Wav',wname));
    dispGENERAL_Info(typeDISP,fileFLAG,wname,dispSTR_2)
    
    % Initialization.
    All_dual_APMF = {};
    All_prim_APMF = {};
    All_dual_LS = {};
    All_prim_LS = {};
    All_prim_POW = [];
    All_dual_POW = [];
    All_prim_DIF = [];
    All_dual_DIF = [];
  
    for j = 1:length(powMAX_VAL)
        powMAX = powMAX_VAL(j);
        dispGENERAL_Info(typeDISP,fileFLAG,wname, ...
            getWavMSG('Wavelet:moreMSGRF:Cur_Pow_Max',powMAX));

        for m = 1:length(difPOW_VAL)
            difPOW = difPOW_VAL(m);

            % Compute Laurent Polynomials associated to the wavelet.
            [Hs,Gs,Ha,Ga] = wave2lp(wname,powMAX,difPOW);
            
            % Synthesis Polyphase Matrix, factorizations
            % and Lifting Steps.
            [MatFACT,PolyMAT] = ppmfact(Hs,Gs);
            nbFACT = length(MatFACT);

            % Compute and Display .... 
            if nbFACT>0
                % Compute Analysis Polyphase Matrix Factorizations.
                [dual_APMF,prim_APMF] = pmf2apmf(MatFACT,'twoFact');
                
                % Compute Lifting Steps.
                dual_LS = apmf2ls(dual_APMF);
                prim_LS = apmf2ls(prim_APMF);

                               
                % Display Current diff POW.
                 dispGENERAL_Info(typeDISP,fileFLAG,wname, ...
                     getWavMSG('Wavelet:moreMSGRF:Cur_Dif_Pow',difPOW));

                % Display Laurent Polynomials Information. 
                dispLP_Info_INI(typeDISP,fileFLAG,wname,Ha,Ga,Hs,Gs)
                dispLP_Info(typeDISP,fileFLAG,wname,Hs,Gs,PolyMAT)
                
                % Display factorizations Information. 
                dispFACT_Info(typeDISP,fileFLAG,wname,nbFACT)
                dispFACT_Info(typeDISP,fileFLAG,wname,nbFACT)
                
                % Add new Factorizations and LS ... 
                All_dual_APMF = [All_dual_APMF , dual_APMF]; %#ok<*AGROW>
                All_prim_APMF = [All_prim_APMF , prim_APMF];
                All_dual_LS   = [All_dual_LS   , dual_LS]; 
                All_prim_LS   = [All_prim_LS   , prim_LS]; 
                All_dual_POW  = [All_dual_POW     , powMAX*ones(1,nbFACT)]; 
                All_prim_POW  = [All_prim_POW     , powMAX*ones(1,nbFACT)]; 
                All_dual_DIF  = [All_dual_DIF     , difPOW*ones(1,nbFACT)]; 
                All_prim_DIF  = [All_prim_DIF     , difPOW*ones(1,nbFACT)]; 
                
            end
            dispGENERAL_Info(typeDISP,fileFLAG,wname,dispSTR_3)
            
        end
        dispGENERAL_Info(typeDISP,fileFLAG,wname,dispSTR_4)
    end
    
    % Merge direct and reverse Factorizations
    %----------------------------------------
    All_FACT = [All_dual_APMF , All_prim_APMF]; 
    All_LS   = [All_dual_LS   , All_prim_LS]; 
    All_POW  = [All_dual_POW  , All_prim_POW];
    All_DIF  = [All_dual_DIF  , All_prim_DIF];
    
    % Suppress same factorizations.
    %------------------------------
    eqTAB = tablseq(All_LS,tolerance);
    toDEL = [];
    for j = 1:length(eqTAB)
        num = eqTAB{j};
        if ~isempty(num) && (num > j)
            toDEL = [toDEL , num]; 
        end
    end
    All_FACT(toDEL) = [];
    All_LS(toDEL)  = [];
    All_POW(toDEL) = [];
    All_DIF(toDEL) = [];
    
    for j = 1:length(typeDISP_VAL)
        typeDISP = typeDISP_VAL{j};
        switch typeDISP
            case 'fact'  
                dispFACT(typeDISP,fileFLAG,wname,All_FACT);
            case 'LS'    
                dispLS(typeDISP,fileFLAG,wname,All_LS,...
                    All_POW,All_DIF,filterFLAG);
            case 'All'  
                dispFACT(typeDISP,fileFLAG,wname,All_FACT);
                dispLS(typeDISP,fileFLAG,wname,All_LS,...
                    All_POW,All_DIF,filterFLAG);
        end
    end
    dispGENERAL_Info(typeDISP,fileFLAG,wname,dispSTR_1)
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%



%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dispGENERAL_Info(typeDISP,fileFLAG,wname,dispSTR)

openDIARY(0,typeDISP,fileFLAG,wname)
disp(dispSTR)
diary off
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dispLP_Info_INI(typeDISP,fileFLAG,wname,Ha,Ga,Hs,Gs)

% Open diary.
%------------ 
openDIARY('fact',typeDISP,fileFLAG,wname)

% Perfect Reconstruction and Anti-Aliasing Conditions.
%-----------------------------------------------------
CNS_5_2 = Hs * reflect(Ha) + Gs * reflect(Ga);
CNS_5_3 = Hs * modulate(reflect(Ha)) + Gs * modulate(reflect(Ga));

%--------------------------------------
disp('##############################');
disp(getWavMSG('Wavelet:moreMSGRF:Str_WaveName',wname))
disp('----------------------');
disp(disp(Hs));
disp(disp(Gs));
disp(disp(Ha));
disp(disp(Ga));
disp(disp(CNS_5_2));
disp(disp(CNS_5_3));
disp('----------------------');

% Close diary.
%-------------
diary off
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dispLP_Info(typeDISP,fileFLAG,wname,Hs,Gs,PolyMAT)

% Open diary.
%------------
openDIARY(0,typeDISP,fileFLAG,wname)

% Display.
%---------
len_H   = length(lp2num(Hs));
len_G   = length(lp2num(Gs));
len_E_H = length(lp2num(PolyMAT{1,1}));
len_O_H = length(lp2num(PolyMAT{2,1}));
len_E_G = length(lp2num(PolyMAT{1,2}));
len_O_G = length(lp2num(PolyMAT{2,2}));
str2disp_1 = [...
        'len_Hs = ' , sprintf('%2.0f',len_H) , ' - ' ,...
        'len_Gs = ' , sprintf('%2.0f',len_G)  ...
    ];
str2disp_2 = [...    
        'len_EvenHs = ' , sprintf('%2.0f',len_E_H) , ' - ' ,...
        'len_OddHs  = ' , sprintf('%2.0f',len_O_H)  ...
    ];
str2disp_3 = [...    
        'len_EvenGs = ' , sprintf('%2.0f',len_E_G) , ' - ' ,...
        'len_OddGs  = ' , sprintf('%2.0f',len_O_G)  ...
    ];
disp(str2disp_1);
disp('%---+---+---+---+---+---+---+---%')
disp(str2disp_2);
disp(str2disp_3);
disp('%---+---+---+---+---+---+---+---+---+---+---%')

% Close diary.
%-------------
diary off
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%


%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dispFACT_Info(typeDISP,fileFLAG,wname,nbFACT)

% Open diary.
%------------
openDIARY(0,typeDISP,fileFLAG,wname)

% Display.
%---------
disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_1',nbFACT));
disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_2',nbFACT))

% Close diary.
%-------------
diary off
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%


%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dispFACT(typeDISP,fileFLAG,wname,All_FACT)

% Format.
%--------
format long

% Open diary.
%------------
openDIARY(1,typeDISP,fileFLAG,wname)

% Display.
%----------
nbFACT = length(All_FACT);
disp('#################################################################')
disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_5',wname,nbFACT));
disp('====================================='); disp(' ')

for k = 1:nbFACT
    disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_6',k))
    disp('--------------------'); disp(' ')
    dec =  All_FACT{k};
    lenFACT = length(dec);
    for j = 1:lenFACT
        dispSTR = disp(dec{j},['M' int2str(j)]);
        disp(dispSTR); disp(' ')
    end
    disp('----------------------------------------------');
end
disp('#################################################################')

% Close diary.
%-------------
format; diary off
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%


%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dispLS(typeDISP,fileFLAG,wname,All_LS,...
    All_POW,All_DIF,filterFLAG)

% Tolerance and format.
%---------------------
tolerance = 1.E-8;
format long

% Open diary.
%------------
openDIARY(1,typeDISP,fileFLAG,wname)

% Display.
%----------
nbLS = length(All_LS);
disp('#################################################################')
disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_5',wname,nbLS));
disp('====================================='); disp(' ')

for k = 1:nbLS
    LSstr = displs(All_LS{k},'%20.16f');
    disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_7',k))
    disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_8',All_POW(k),All_DIF(k)))
    disp('%---+----+----+----+----+---%');
    disp(LSstr)
    disp(' ')
    [LoD,HiD,LoR,HiR,prim_LoD,prim_HiD,prim_LoR,prim_HiR] = ...
        ls2filters(All_LS{k},'a_num');
    
    disp(' ');
    if filterFLAG
        disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_9'))
        disp(['LoD = [', sprintf('%15.8f',LoD) , ' ]']);
        disp(['HiD = [', sprintf('%15.8f',HiD) , ' ]']);
        disp(['LoR = [', sprintf('%15.8f',LoR) , ' ]']);
        disp(['HiR = [', sprintf('%15.8f',HiR) , ' ]']);
        disp(['prim_LoD = [', sprintf('%15.8f',prim_LoD) , ' ]']);
        disp(['prim_HiD = [', sprintf('%15.8f',prim_HiD) , ' ]']);
        disp(['prim_LoR = [', sprintf('%15.8f',prim_LoR) , ' ]']);
        disp(['prim_HiR = [', sprintf('%15.8f',prim_HiR) , ' ]']);
        disp('%=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=%');
    end
    
end
disp('%--------------------------------------------------------%')
eqTAB = tablseq(All_LS,tolerance);
idx = [];
for k = 1:length(eqTAB)
    if ~isempty(eqTAB{k})
        idx = [idx , k]; 
    end
end
if ~isempty(idx)
    disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_10',idx))
    eqTAB(idx)
else
    disp(getWavMSG('Wavelet:moreMSGRF:FactLS_MSG_11'))
end
 
disp('%--------------------------------------------------------%')
disp('#################################################################')

% Close diary.
%-------------
format; diary off

%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function openDIARY(OPT,typeDISP,fileFLAG,wname)

% Open diary.
%------------
diaFILE = [typeDISP '_' wname];
if fileFLAG
    switch OPT
        case 0
            if ~isequal(typeDISP,'All')
                diaFILE = ['Info_' wname];
            end
            
        case 1  
            
        case 'fact'
            if ~isequal(typeDISP,'All')
                diaFILE = ['fact_' wname];
            end
            
        case 'LS'
            if ~isequal(typeDISP,'All')
                diaFILE = ['LS_' wname];
            end
    end
    diaFILE(diaFILE=='.') = '_';
    diaFILE = [diaFILE '.m'];
    diary(diaFILE);
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%

