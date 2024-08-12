function [LS,K] = coiflift(Num)
%COIFLIFT Coiflets lifting schemes.
%   [LS,K] = COIFLIFT(NUM) returns the lifting scheme specified by NUM. The
%   valid values for NUM are:
%      'coif1', 'coif2'
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
    case 1
        type = {'predict';'update';'predict';'update'};
        
        Coefficients = { 4.6457513110481772;...
            [ -0.1171567416519999 -0.2057189138840000]; ...
            [  7.4686269664352070 -0.6076252184992341];...
            0.0728756555332089};
        MaxOrder = [ 0; 1; -1; 2];
        K(1) = -1.7186236496830642;
        K(2) = -0.5818609561112537;
        LS = repmat(s,4,1);
        coder.varsize('LS');
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        
        for ii = 1:numel(type)
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    case 2
        
        Coefficients = {2.5303036209828274;...
            [  0.2401406244344829  -0.3418203790296641];...
            [ -3.1631993897610227 -15.2683787372529950];...
            [ -0.0057171329709620   0.0646171619180252];...
            [ 63.9510482479880200 -13.5911725693075900];...
            [ -0.0005087264425263   0.0018667030862775];...
            3.7930423341992774};
        type = {...
            'predict';'update';'predict';'update';'predict';'update';'predict'};
        
        MaxOrder = [0;1;-1;3;-3;5;-5];
        K(1) = 9.2878701738310099;
        K(2) = 0.1076673102965570;
        LS = repmat(s,7,1);
        coder.varsize('LS.Type');
        coder.varsize('LS.Coefficients');
        for ii = 1:7
            LS(ii).Type = type{ii,1};
            LS(ii).Coefficients = Coefficients{ii,1};
            LS(ii).MaxOrder = MaxOrder(ii);
        end
        
    otherwise
        
        coder.internal.error('Wavelet:Lifting:InvalidWavNum', Num);
end

end
