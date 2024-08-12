function [LS,K] = biorlift(numd,numr)
%BIORLIFT Biorthogonal spline lifting schemes.
%   [LS,K] = BIORLIFT(NUMD,NUMR) returns the lifting scheme specified by
%   NUMD and NUMR. The valid wavelet names are:
%       'bior1.1', 'bior1.3' , 'bior1.5', ...
%       'bior2.2', 'bior2.4' , 'bior2.6', 'bior2.8'
%       'bior3.1', 'bior3.3' , 'bior3.5', 'bior3.7'
%       'bior3.9', 'bior4.4' , 'bior5.5', 'bior6.8'
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

switch numd
    case 1
        type = {'predict';'update'};
        LS = repmat(s,2,1);
        coder.varsize('LS');
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
        end
        LS(1).Coefficients = -1;
        LS(1).MaxOrder = 0;
        
        switch numr
            case 1
                LS(2).Coefficients = 1/2;
                LS(2).MaxOrder = 0;
                
            case 3
                LS(2).Coefficients = [-1 8 1]/16;
                LS(2).MaxOrder = 1;
                
            case 5
                LS(2).Coefficients = ([3 -22 128 22 -3]/256);
                LS(2).MaxOrder = 2;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        K(1) = sqrt(2);
        K(2) = sqrt(2)/2;
        
    case 2
        type = {'predict';'update'};
        LS = repmat(s,2,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
        end
        LS(1).Coefficients = -[1 1]/2;
        LS(1).MaxOrder = 1;
        
        switch numr
            case 2
                LS(2).Coefficients = [1 1]/4;
                LS(2).MaxOrder = 0;
            case 4
                LS(2).Coefficients = [-3 19 19 -3]/64;
                LS(2).MaxOrder = 1;
            case 6
                
                LS(2).Coefficients = [5 -39 162 162 -39 5]/512;
                LS(2).MaxOrder = 2;
            case 8
                
                LS(2).Coefficients = [-35  335  -1563  5359  5359  -1563  335  -35]/16384;
                LS(2).MaxOrder = 3;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        K(1) = sqrt(2);
        K(2) = sqrt(2)/2;
        
    case 3
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        LS(1).Coefficients = -1/3;
        LS(2).Coefficients = -[3 9]/8;
        LS(1).MaxOrder = -1;
        LS(2).MaxOrder = 1;
        switch numr
            case 1
                type = {'update';'predict';'update'};
                for ii = 1:numel(type)
                    LS(ii).Type = type{ii,1};
                end
                LS(3).Coefficients = 4/9;
                LS(3).MaxOrder = 0;
                
            case 3
                type = {'update';'predict';'update'};
                for ii = 1:numel(type)
                    LS(ii).Type = type{ii,1};
                end
                LS(3).Coefficients = [-3 16 3]/36;
                LS(3).MaxOrder = 1;
                
            case 5
                type = {'update';'predict';'update'};
                for ii = 1:numel(type)
                    LS(ii).Type = type{ii,1};
                end
                
                LS(3).Coefficients = [5 -34 128 34 -5]/288;
                LS(3).MaxOrder = 2;
                
            case 7
                type = {'update';'predict';'update'};
                for ii = 1:numel(type)
                    LS(ii).Type = type{ii,1};
                end
                LS(3).Coefficients = [-35/9216  25/768  -421/3072  4/9  421/3072  -25/768  35/9216];
                LS(3).MaxOrder = 3;
            case 9
                type = {'update';'predict';'update'};
                for ii = 1:numel(type)
                    LS(ii).Type = type{ii,1};
                end
                LS(3).Coefficients = [7/8192  -185/20729  547/12288  -938/6295  4/9  938/6295  -547/12288  185/20729  -7/8192];
                LS(3).MaxOrder = 4;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        K(1) = 3*sqrt(2)/2;
        K(2) = sqrt(2)/3;
        
        
    case 4
        type = {'predict';'update';'predict';'update'};
        
        Coefficients = { [ -1.5861343420693648 -1.5861343420693648] ; ...
            [  1.0796367753628087 -0.0529801185718856];...
            [ -0.8829110755411875 -0.8829110755411875];...
            [  0.4435068520511142  1.5761237461483639]};
        
        MaxOrder = [1;0;0;2];
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        K(1) = -1.1496043988602418;
        K(2) = -0.8698644516247808;
        
    case 5
        type = {'predict';'update';'predict';'update';'predict';'update'};
        Coefficients = {[  4.9932745216378791  4.9932745216378791];...
            ([-0.1833932736462213 -0.0043674455906250 ]);...
            [  5.5857862011365809  5.5857862011365809];...
            ([-3.0949380770116637 0.1732056148062267]);...
            [  0.2900930732401870  0.2900930732401881];...
            -3.4471695202783086};
        maxOrd = [1 0 0 2 -2 3]';
        LS = repmat(s,6,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = maxOrd(ii);
        end
        K(1) = 0.9249619350590361;
        K(2) = 1.0811255707902991;
        
        
    case 6
        
        type = {'predict';'update';'predict';'update';'predict';'update'};
        LS = repmat(s,6,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        
        LS(1).Coefficients = -fliplr([ -2.6589963611977199  0.9971506910514433]);
        LS(2).Coefficients = -fliplr([  0.2735119746851613  0.2735119746851613]);
        LS(3).Coefficients = -fliplr([  3.8778221455598287 -3.2686866117960300]);
        LS(4).Coefficients = -fliplr([ -0.2865032579680539 -0.2865032579680544]);
        LS(5).Coefficients = -fliplr([ -0.5485941682554034  2.9417675368512870]);
        LS(6).Coefficients = -fliplr([  0.0998232169757517 -0.3438132627628235 -0.3438132627531770  0.0998232170102641]);
        
        maxOrd = [1 1 -1 3 -3 5]';
        
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).MaxOrder = maxOrd(ii);
        end
        K(1) = 1.1513061546402219;
        K(2) = 0.8685786973079247;
    otherwise
        coder.internal.error('Wavelet:Lifting:InvalidWavNum', numd);
end
end