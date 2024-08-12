function [LS,K] = cdflift(numd,numr)
%CDFLIFT Cohen-Daubechies-Feauveau lifting schemes.
%   [LS,K] = CDFLIFT(NUMD,NUMR) returns the lifting scheme specified by NUMD
%   and NUMR. The valid wavelet names are:
%    'cdf1.1', 'cdf1.3', 'cdf1.5', 'cdf2.2', 'cdf2.4', 'cdf2.6'
%    'cdf3.1', 'cdf3.3', 'cdf3.5', 'cdf4.2', 'cdf4.4', 'cdf4.6'
%    'cdf5.1', 'cdf5.3', 'cdf5.5', 'cdf6.2', 'cdf6.4', 'cdf6.6'
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
            case 3 %, T2 = table({'update'},{[-1 8 1]/16},1,'VariableNames',VarNam);
                LS(2).Coefficients = [-1 8 1]/16;
                LS(2).MaxOrder = 1;
            case 5 %, T2 = table({'update'},{[3 -22 128 22 -3]/256},2,'VariableNames',VarNam);
                LS(2).Coefficients = [3 -22 128 22 -3]/256;
                LS(2).MaxOrder = 2;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        
        
        K(1) = sqrt(2);
        K(2) = sqrt(2)/2;
        
    case 2
        LS = repmat(s,2,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        type = {'predict';'update'};
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
        end
        
        LS(1).Coefficients = [-1 -1]/2;
        LS(1).MaxOrder = 1;
        K(1) = sqrt(2);
        K(2) = sqrt(2)/2;
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
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        
    case 3
        K(1) = 3*sqrt(2)/2;
        K(2) = sqrt(2)/3;
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        LS(1).Type = 'update';
        LS(2).Type = 'predict';
        LS(3).Type = 'update';
        
        Coefficients = {-1/3;[-3 -9]/8};
        MaxOrder = [-1;1];
        
        for ii = 1:numel(Coefficients)
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        switch numr
            case 1
                LS(3).Coefficients = 4/9;
                LS(3).MaxOrder = 0;
            case 3
                LS(3).Coefficients = [-3 16 3]/36;
                LS(3).MaxOrder = 1;
            case 5
                LS(3).Coefficients = [5 -34 128 34 -5]/288;
                LS(3).MaxOrder = 2;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
    case 4
        LS = repmat(s,3,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        LS(1).Type = 'update';
        LS(2).Type = 'predict';
        LS(3).Type = 'update';
        
        K(1) = 2*sqrt(2);
        K(2) = sqrt(2)/4;
        
        Coefficients = {[-1 -1]/4;[-1 -1]};
        MaxOrder = [0;1];
        for ii = 1:numel(Coefficients)
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        switch numr
            case 2
                LS(3).Coefficients = [3 3]/16;
                LS(3).MaxOrder = 0;
            case 4
                LS(3).Coefficients = [-5 29 29 -5]/128;
                LS(3).MaxOrder = 1;
            case 6
                LS(3).Coefficients = [35 -265 998 998 -265 35]/4096;
                LS(3).MaxOrder = 2;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        
        
    case 5
        K(1) = 3*sqrt(2);
        K(2) = sqrt(2)/6;
        type = {'predict';'update';'predict';'update'};
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
        end
        
        Coefficients = {-1/5;[-5 -15]/24;[-9 -15]/10};
        MaxOrder = [0;0;1];
        for ii = 1:numel(Coefficients)
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        switch numr
            case 1
                LS(4).Coefficients = 1/3;
                LS(4).MaxOrder = 0;
            case 3
                LS(4).Coefficients = [-5 24 -5]/72;
                LS(4).MaxOrder = 1;
            case 5
                LS(4).Coefficients = [35 -230 768 230 -35]/2304;
                LS(4).MaxOrder = 2;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        
    case 6
        K(1) = 4*sqrt(2);
        K(2) = sqrt(2)/8;
        type = {'predict';'update';'predict';'update'};
        LS = repmat(s,4,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
        end
        Coefficients = {[-1 -1]/6;[-9 -9]/16;[-4 -4]/3};
        MaxOrder = [1;0;1];
        
        for ii = 1:numel(Coefficients)
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
        switch numr
            case 2
                LS(4).Coefficients = [5 5]/32;
                LS(4).MaxOrder = 0;
            case 4
                LS(4).Coefficients = [-35 195 195 -35]/1024;
                LS(4).MaxOrder = 1;
            case 6
                LS(4).Coefficients = [63 -469 1686 1686 -469 63]/8192;
                LS(4).MaxOrder = 2;
            otherwise
                coder.internal.error('Wavelet:Lifting:InvalidWavNum', numr);
        end
        
    otherwise
        coder.internal.error('Wavelet:Lifting:InvalidWavNum', numd);
        
end
end