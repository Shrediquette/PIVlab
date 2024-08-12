function [idxzeropos,idxzeroneg] = findPeriodIndices(Na,periodvector,periodrange,isReal)
% future release.

%   Copyright 2021 The MathWorks, Inc.
%#codegen

% The following is needed for code generation as opposed to simpler
% min(), max()
pmin = min(periodvector,[],'all');
pmax = max(periodvector,[],'all');

isVecPeriod = isvector(periodrange);

coder.internal.errorIf(~isVecPeriod && isReal,'Wavelet:cwt:InvalidPeriodMatrix');

switch isVecPeriod

    case true
        validateattributes(periodrange,{'numeric'},{'increasing','numel',2,...
            '>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
        idxbegin = find(periodvector <= periodrange(1),1,'last');
        idxend = find(periodvector >= periodrange(2),1,'first');
        idxzeropos = setdiff(1:Na,idxbegin:idxend);
        if ~isReal
            idxzeroneg = idxzeropos;
        else
            idxzeroneg = [];
        end

    case false

        if all(periodrange(1,:)==0)
            idxzeropos = 1:Na;

            validateattributes(periodrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');

            idxbeginneg = find(periodvector <= periodrange(2,1),1,'last');
            idxendneg = find(periodvector >= periodrange(2,2),1,'first');
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        elseif all(periodrange(2,:) == 0)
            idxzeroneg = 1:Na;
            validateattributes(periodrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            idxbeginpos = find(periodvector <= periodrange(1,1),1,'last');
            idxendpos = find(periodvector >= periodrange(1,2),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
        else
            validateattributes(periodrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            validateattributes(periodrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',pmin,'<=',pmax},'icwt','PERIODRANGE');
            idxbeginpos = find(periodvector <= periodrange(1,1),1,'last');
            idxendpos = find(periodvector >= periodrange(1,2),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
            idxbeginneg = find(periodvector <= periodrange(2,1),1,'last');
            idxendneg = find(periodvector >= periodrange(2,2),1,'first');
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        end
        % Otherwise needed for code generation to avoid "not defined on
        % some execution paths"
    otherwise
        idxzeropos = [];
        idxzeroneg = [];

end