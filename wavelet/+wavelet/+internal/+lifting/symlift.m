function [LS,K] = symlift(Num)
%SYMLIFT Symlets lifting schemes.
%   [LS,K] = SYMLIFT(NUM) returns the lifting scheme specified by NUM. The
%   valid values for wavelet are:
%      'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8'
%
%   A lifting scheme LS is a 1 x N struct such that:
%     for k = 1:N
%       | LS(k).Type is the lifting "type": 'update' or 'predict'.
%       | LS(k).Coefficients is the corresponding lifting filter coefficients.
%       | LS(k).MaxOrder is the maximum order of the lifting filter
%
%     The normalization factor vector K is such that
%     K(1) is the update normalization.
%     K(2) is the predict normalization.
%
%   For more information about lifting schemes type: LIFTINGSCHEME.

%   Copyright 2020 The MathWorks, Inc.

%#codegen

s = struct('Type','','Coefficients',zeros(1,0),'MaxOrder',0);

K = coder.nullcopy(zeros(1,2));

switch Num
    %== sym2 ============================================================%
    case 2
        type = {'predict';'update';'predict'};
        Coefficients = {-sqrt(3) ; [sqrt(3)-2 sqrt(3)]/4;1 };
        MaxOrder = [0;1;-1];
        LS = repmat(s,3,1);
        coder.varsize('LS');
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = (sqrt(3)+1)/sqrt(2);
        K(2) = (sqrt(3)-1)/sqrt(2);
        
    case 2.1
        type = {'predict' ;'update';'predict'};
        
        Coefficients = {...
            -0.5773502691885155;[0.2009618943233436  0.4330127018926641];...
            -0.3333333333327671};
        MaxOrder = [1;0;0];
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 1.1153550716496254;
        K(2) = 0.8965754721686846;
        
    case 2.2
        
        type = {'predict';'update';'predict'};
        
        Coefficients = {...
            0.5773502691900463;[ -0.4330127018915159  2.7990381056783082];...
            -0.3333333333332407};
        MaxOrder = [0;0;1];
        
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 0.2988584907223872;
        K(2) = 3.3460652149545598;
        
    case 2.3
        type = {'predict';'update';'predict'};
        Coefficients = {...
            1.7320508075676158;...
            [ -0.4330127018926641 -0.9330127018941287];...
            0.9999999999980750};
        MaxOrder = [1;-1;2];
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = -0.5176380902041495;
        K(2) = -1.9318516525814655;
        
        %== sym3 ============================================================%
    case 3
        
        type = {'predict' ;'update';'predict';'update'};
        Coefficients = {...
            0.4122865950085308;[ -0.3523876576801823  1.5651362801993258];...
            [ -0.4921518447467098 -0.0284590895616518];...
            0.3896203901445617};
        MaxOrder = [0 0 1 0]';
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 0.5213212719156450;
        K(2) = 1.9182029467652528;
        
    case 3.1
        type = {'predict';'update';'predict';'update'};
        
        Coefficients = {...
            -0.4122865950517414;...
            [  0.4667569466389586  0.3523876576432496];...
            [ -0.4921518449249469  0.0954294390155849];...
            -0.1161930919191620};
        MaxOrder = [1 0 0 1]';
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 0.9546323126334674;
        K(2) = 1.0475237290484967;
        
    case 3.2
        type = {'predict';'update';'predict';'update'};
        
        Coefficients = {...
            -0.4122865950517414;[ -1.5651362796324981  0.3523876576432496];...
            [ -2.5381416988469603  0.4921518449249469];...
            0.3896203899372190};
        MaxOrder = [1 0 1 -1]';
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 4.9232611941772104;
        K(2) = 0.2031173973021602;
        
    case 3.3
        type = {'predict';'update';'predict';'update'};
        
        Coefficients = {...
            2.4254972441665452;[ -0.3523876576432495 -0.2660422349436360];...
            [  2.8953474539232271  0.1674258735039567];...
            -0.0662277660392190};
        MaxOrder = [1 -1 2 -1]';
        K(1) = -1.2644633083567955;
        K(2) = -0.7908493614571760;
        
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        %== sym4 ============================================================%
    case 4
        type = {'predict';'update';'predict';'update';'predict'};
        
        Coefficients = {...
            0.3911469419700402;...
            [ -0.1243902829333865 -0.3392439918649451];...
            [ -1.4195148522334731  0.1620314520393038];...
            [  0.4312834159749964  0.1459830772565225];...
            -1.0492551980492930};
        MaxOrder = [0 1 0 0 1]';
        
        LS = repmat(s,5,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 1.5707000714496564;
        K(2) = 0.6366587855802818;
        
    case 4.1
        type = {'predict';'update';'predict';'update';'predict'};
        
        Coefficients = {...
            -0.3911469419692201;...
            [  0.3392439918656564  0.1243902829339031];...
            [ -0.1620314520386309 -0.8991460629746448];...
            [  0.4312834159764773 -0.2304688357916146]; ...
            0.6646169843776997};
        MaxOrder = [1 -1 2 -1 2]';
        
        LS = repmat(s,5,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 1.2500817546829417;
        K(2) = 0.7999476804248136;
        
        %== sym5 ============================================================%
    case 5
        
        K(1) = 2.0348614718930915;
        K(2) = 0.4914339446751972;
        type = {'predict';'update';'predict';'update';'predict';'update'};
        
        Coefficients = {...
            -0.9259329171294208;[  0.4985231842281166  0.1319230270282341];...
            [ -0.4293261204657586 -1.4521189244206130];...
            [ -0.0948300395515551  0.2804023843755281];...
            [  1.9589167118877153  0.7680659387165244];...
            -0.1726400850543451};
        MaxOrder = [0 0 1 1 0 0]';
        LS = repmat(s,6,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    case 5.1
        %--------------------  Num LS = 23  ----------------------%
        
        K(1) = -2.6517078902691829;
        K(2) = -0.3771154446044534 ;
        type = {'predict';'update';'predict';'update';'predict';'update'};
        
        Coefficients = {...
            1.0799918455239754;...
            [  0.1131044403334987 -0.4985231842281165];...
            [  2.4659476305614541 -0.5007584249312305];...
            [ -0.0558424247659369 -0.2404034797205558];...
            [  3.3265774193213002  1.3043080355478955];...
            -0.1016623108755641};
        MaxOrder = [0 1 0 1 0 0]';
        LS = repmat(s,6,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    case 5.2
        
        K(1) = 3.0742840094152357;
        K(2) = 0.3252789907950670;
        type = {'predict';'update';'predict';'update';'predict';'update'};
        
        Coefficients = {...
            1.0799918455239754;...
            [  0.1131044403334987 -0.4985231842281165];...
            [ -1.6937259364035369 -0.5007584249312305];...
            [  0.2404034797205558 -0.0813027019760201];...
            [  0.8958585825127051 -4.4713044896913088];...
            0.1480132819787044};
        MaxOrder = [0 1 0 0 1 0]';
        LS = repmat(s,6,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    case 6
        
        K(1) = -1.6707087396895259;
        K(2) = -0.5985483742581210;
        type = {'predict';'update';'predict';'update';'predict';'update';'predict'};
        
        Coefficients = {...
            0.2266091476053614;...
            [  1.2670686037583443 -0.2155407618197651];...
            [ -0.5047757263881194  4.2551584226048398];...
            [ -0.0447459687134724 -0.2331599353469357];...
            [ 18.3890008539693710 -6.6244572505007815];...
            [ -0.1443950619899142  0.0567684937266291];...
            5.5119344180654508};
        MaxOrder = [0 1 -1 3 -3 5 -5]';
        
        LS = repmat(s,7,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    case 7
        K(1) = 2.1423821239872392;
        K(2) = 0.4667701381576485;
        type = { 'update'; 'predict';'update' ;'predict';'update';'predict';'update';'predict'};
        
        Coefficients = {...
            0.3905508237124110;...
            [ -0.3388639272262041  7.1808202373094066];...
            [ -0.0139114610261505 -0.1372559452118446];...
            [ 29.6887047769035310  0.1338899561610895];...
            [  0.1284625939282921 -0.0001068796412094];...
            [ -7.4252008608107740 -2.3108058612546007];...
            [  0.0532700919298021  0.2886088139333021];...
            -1.1987518309831993};
        MaxOrder = [0 0 2 -2 4 -4 6 -6]';
        
        LS = repmat(s,8,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    case 8
        
        type =  {...
            'predict';'update';'predict';'update';'predict';'update';'predict';'update';'predict'};
        
        Coefficients =  {...
            0.1602796165947262;...
            [  0.7102593464144563 -0.1562652322408773];...
            [ -0.4881496179387070  1.8078532235524318];...
            [  1.7399180943774144 -0.4863315213006700];...
            [ -0.5686365236759819 -0.2565755576271975];...
            [ -0.8355308510520870  3.7023086183759020];...
            [  0.5881022226370752 -0.3717452749902822];...
            [ -2.1580699620177337  0.7491890598341392];...
            0.3531271830147090};
        MaxOrder = [0 1 -1 3 -3 5 -5 7 -7]';
        
        LS = repmat(s,9,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 0.4441986800900797;
        K(2) = 2.2512448704197152;
    otherwise
        coder.internal.error('Wavelet:Lifting:InvalidWavNum');
end

end
