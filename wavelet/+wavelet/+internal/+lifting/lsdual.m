function [LSD,KD] = lsdual(LS,K)
%LSDUAL Dual lifting scheme.
%   LSD = LSDUAL(LS) returns the lifting scheme LSD associated to LS. LS
%   and LSD originate from the same polyphase matrix factorization PMF,
%
%   For more information about lifting schemes type: lsinfo.
%
%   N.B.: LS = LSDUAL(LSDUAL(LS)).

%   Copyright 2020 The MathWorks, Inc.

%#codegen

KD = fliplr(K);
n = nCell(LS);
s = struct('Type','','Coefficients',zeros(1,0),'MaxOrder',0);
LSD = repmat(s,1,10);
coder.varsize('LSD.Type');
coder.varsize('LSD.Coefficients');

coder.unroll;
for ii = 1:10
    if (ii <= n)
        
        jj = n+1-ii;
        
        tp = LS(jj).Type;
        
        if strcmpi(tp,'update')
            LSD(ii).Type = 'predict';
        elseif strcmpi(tp,'predict')
            LSD(ii).Type = 'update';
        else
            LSD(ii).Type = '';
        end
        
        LSD(ii).Coefficients = -fliplr(LS(jj).Coefficients);
        LSD(ii).MaxOrder = LS(jj).MaxOrder;
    end
end
end

function n = nCell(LS)
n = 0;
coder.unroll;
for ii = 1:length(LS)
    if ~isempty(LS(ii).Type)
        n = n+1;
    end
end
end
