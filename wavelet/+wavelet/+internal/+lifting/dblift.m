function [LS,K] = dblift(Num)
%DBLIFT Daubechies lifting schemes.
%   [LS,K] = DBLIFT(NUM) returns the lifting scheme specified by NUM.
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
    %== db1 ============================================================%
    case 1
        %         LS = {...
        %             'predict',-1,0; ...
        %             'update',1/2,0 ...
        %             };
        LS = repmat(s,2,1);
        coder.varsize('LS');
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        type = {'predict';'update'};
        Coefficients = {-1;1/2};
        maxOrd = [0 0]';
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = maxOrd(ii);
        end
        K(1) = sqrt(2);
        K(2) = sqrt(2)/2;
       
        %== db2 ============================================================%
    case 2
        %         LS = {...
        %             'predict',-sqrt(3),0; ...
        %             'update',[sqrt(3)-2 sqrt(3)]/4,1; ...
        %             'predict',1,-1 ...
        %             };
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        K(1) = (sqrt(3)+1)/sqrt(2);
        K(2) = (sqrt(3)-1)/sqrt(2);
        type = {'predict';'update';'predict'};
        Coefficients = {-sqrt(3);[sqrt(3)-2 sqrt(3)]/4;1};
        MaxOrder = [0 1 -1]';
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        % %--------------------  Num LS = 1  ----------------------%
        % LSB = {...
        % 'predict'                     [ -1.7320508075722079]                      0
        % 'update'                     [ -0.0669872981075236  0.4330127018915160]  1
        % 'predict'                     [  0.9999999999994959]                     -1
        %   1.9318516525804916    0.5176380902044105                      []
        % };
   
        %== db3 ============================================================%
    case 3
        %--------------------  Num LS = 7  ----------------------%
        % Pow MAX = 0 - diff POW = 0
        %---+----+----+----+----+---%
        %         LS = {...
        %             'predict'                       -2.4254972439123361                       0
        %             'update'                     [ -0.0793394561587384  0.3523876576801823]  1
        %             'predict'                     [  2.8953474543648969 -0.5614149091879961] -1
        %             'update'                        0.0197505292372931                       2
        %             2.3154580432421348    0.4318799914853075                      []
        %             };
        type = {'predict';'update';'predict';'update'};
        Coefficients = {-2.4254972439123361;...
            [ -0.0793394561587384  0.3523876576801823];...
            [  2.8953474543648969 -0.5614149091879961];...
            0.0197505292372931};
        MaxOrder = [0 1 -1 2]';
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        K(1) = 2.3154580432421348;
        K(2) = 0.4318799914853075;
   
        %== db4 ============================================================%
    case 4
        %--------------------  Num LS = 4  ----------------------%
        %         LS = {...
        %             'predict'                       -0.3222758879971411                                           1
        %             'update'                     [ -1.1171236051605939 -0.3001422587485443]                      0
        %             'predict'                     [ -0.0188083527262439  0.1176480867984784]                      2
        %             'update'                     [  2.1318167127552199  0.6364282711906594]                      0
        %             'predict'                     [ -0.4690834789110281  0.1400392377326117 -0.0247912381571950]  0
        %                                                       []
        %             };
        K(1) = 0.7341245276832514;
        K(2) = 1.3621667200737697;
        type = {...
            'predict';'update';'predict';'update';'predict'};
        Coefficients = {...
            -0.3222758879971411;...
            [ -1.1171236051605939 -0.3001422587485443];...
            [ -0.0188083527262439  0.1176480867984784];...
            [  2.1318167127552199  0.6364282711906594];...
            [ -0.4690834789110281  0.1400392377326117 -0.0247912381571950]};
        MaxOrder = [ 1 0 2 0 0]';
        LS = repmat(s,5,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
   
        %== db5 ============================================================%
    case 5
        %         %--------------------  Num LS = 3  ----------------------%
        %         LS = {...
        %             'predict'                       -0.2651451428113514                       1
        %             'update'                     [  0.9940591341382633  0.2477292913288009]  0
        %             'predict'                     [ -0.5341246460905558  0.2132742982207803]  0
        %             'update'                     [  0.2247352231444452 -0.7168557197126235]  2
        %             'predict'                     [ -0.0775533344610336  0.0121321866213973] -2
        %             'update'                       -0.0357649246294110                       3
        %                                   []
        %             };
        K(1) = 0.7632513182465389;
        K(2) = 1.3101844387211246;
        type = {'predict';'update';'predict';'update';'predict';'update'};
        Coefficients = {...
            -0.2651451428113514;...
            [  0.9940591341382633  0.2477292913288009];...
            [ -0.5341246460905558  0.2132742982207803];...
            [  0.2247352231444452 -0.7168557197126235];...
            [ -0.0775533344610336  0.0121321866213973];...
            -0.0357649246294110};
        MaxOrder = [ 1 0 0 2 -2 3]';
        
        LS = repmat(s,6,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
   
    case 6
        %--------------------  Num LS = 1  ----------------------%
        % Pow MAX = 0 - diff POW = 0
        %---+----+----+----+----+---%
        %         LS = {...
        %             'predict'                        -4.4344683000391223                      0
        %             'update'                     [ -0.0633131925095066  0.2145934499409130]  1
        %             'predict'                     [  9.9700156175718320 -4.4931131753641633] -1
        %             'update'                     [ -0.0236634936395882  0.0574139367993266]  3
        %             'predict'                     [  2.3564970162896977 -0.6787843541162683] -3
        %             'update'                     [ -0.0009911655293238  0.0071835631074942]  5
        %             'predict'                        0.0941066741175849                      -5
        %                                   []
        %             };
        K(1) = 3.1214647228121661;
        K(2) = 0.3203624223883869;
        type = {...
            'predict';'update';'predict';'update';'predict';'update';'predict'};
        Coefficients = {...
            -4.4344683000391223;...
            [ -0.0633131925095066  0.2145934499409130 ];...
            [  9.9700156175718320 -4.4931131753641633 ];...
            [ -0.0236634936395882  0.0574139367993266 ];...
            [  2.3564970162896977 -0.6787843541162683 ];...
            [ -0.0009911655293238  0.0071835631074942 ];...
            0.0941066741175849};
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
        %--------------------  Num LS = 1  ----------------------%
        % Pow MAX = 0 - diff POW = 0
        %---+----+----+----+----+---%
        %         LS = {...
        %             'update'                        5.0934984843051252                        0
        %             'predict'                     [ -0.1890420920712265   0.0573987259882762]  0
        %             'update'                     [  5.9592087615113751 -12.2854449956285200]  2
        %             'predict'                     [ -0.0604278631256078   0.0291354832685777] -2
        %             'update'                     [  1.5604402591648248  -3.9707106658519669]  4
        %             'predict'                     [ -0.0126913773028362   0.0033065734202625] -4
        %             'update'                     [  0.0508158836098717  -0.4141984501693177]  6
        %             'predict'                       -0.0004062144890730                       -6
        %                                  []
        %             };
        K(1) = 0.2990107076865977;
        K(2) = 3.3443618381992222;
        type = {...
            'update';'predict';'update';'predict';'update';'predict';'update';'predict'};
        Coefficients = {...
            5.0934984843051252 ;...
            [ -0.1890420920712265   0.0573987259882762 ];...
            [  5.9592087615113751 -12.2854449956285200 ];...
            [ -0.0604278631256078   0.0291354832685777 ];...
            [  1.5604402591648248  -3.9707106658519669 ];...
            [ -0.0126913773028362   0.0033065734202625 ];...
            [  0.0508158836098717  -0.4141984501693177 ];...
            -0.0004062144890730};
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
        %--------------------  Num LS = 2  ----------------------%
        % Pow MAX = 0 - diff POW = 0
        %---+----+----+----+----+---%
        %         LS = {...
        %             'predict'                       -5.7496416141714990                                          0
        %             'update'                     [ -0.0522692017330962  0.1688172436569421]                      1
        %             'predict'                     [ 14.5428210043618850 -7.4021068366100549]                     -1
        %             'update'                     [ -0.0324020739512596  0.0609092564633227]                      3
        %             'predict'                     [  5.8187164907231610 -2.7556987881059287]                     -3
        %             'update'                     [  0.9452952681157910  0.2420216844324576]                      5
        %             'predict'                     [  0.0001888402536823 -0.0018038158742157]                     -3
        %             'update'                     [ -0.9526138318957663 -0.2241381624167550]                      5
        %             'predict'                     [  1.0497432943790195 -0.2469917331775993  0.0271973973533717] -5
        %                                                      []
        %             };
        K(1) = 3.5493622541356347 ;
        K(2) = 0.2817407546481972;
        type = {...
            'predict';'update';'predict';'update';'predict';...
            'update';'predict';'update';'predict'};
        Coefficients = {...
            -5.7496416141714990;...
            [ -0.0522692017330962  0.1688172436569421 ];...
            [ 14.5428210043618850 -7.4021068366100549 ];...
            [ -0.0324020739512596  0.0609092564633227 ];...
            [  5.8187164907231610 -2.7556987881059287 ];...
            [  0.9452952681157910  0.2420216844324576 ];...
            [  0.0001888402536823 -0.0018038158742157 ];...
            [ -0.9526138318957663 -0.2241381624167550 ];...
            [  1.0497432943790195 -0.2469917331775993  0.0271973973533717]};
        MaxOrder = [0 1 -1 3 -3 5 -3 5 -5]';
        
        LS = repmat(s,9,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
    otherwise
        coder.internal.error('Wavelet:Lifting:InvalidWavNum', Num);
end
end
