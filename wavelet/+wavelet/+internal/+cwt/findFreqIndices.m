function [idxzeropos,idxzeroneg] = findFreqIndices(Na,freqvector,freqrange,isReal)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2021 The MathWorks, Inc.

%#codegen

% The following is needed for code generation
fmin = min(freqvector,[],'all');
fmax = max(freqvector,[],'all');

isVecFreq = isvector(freqrange);

coder.internal.errorIf(~isVecFreq && isReal,'Wavelet:cwt:InvalidFreqMatrix');

switch isVecFreq

    case true
        validateattributes(freqrange,{'numeric'},{'increasing','numel',2 ...
            '>=',fmin,'<=',fmax},'icwt','FREQRANGE');
        idxbegin = find(freqvector >= freqrange(2),1,'last');
        idxend = find(freqvector <= freqrange(1),1,'first');
        idxzeropos = setdiff(1:Na,idxbegin:idxend);
        if ~isReal
            idxzeroneg = idxzeropos;
        else
            idxzeroneg = [];
        end

    case false

        if all(freqrange(1,:)==0)
            idxzeropos = 1:Na;
            validateattributes(freqrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            idxbeginneg = find(freqvector >= freqrange(2,2),1,'last');
            idxendneg = find(freqvector <= freqrange(2,1),1,'first');
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        elseif all(freqrange(2,:) == 0)
            validateattributes(freqrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            idxzeroneg = 1:Na;
            idxbeginpos = find(freqvector >= freqrange(1,2),1,'last');
            idxendpos = find(freqvector <= freqrange(1,1),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
        else

            validateattributes(freqrange(1,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');
            validateattributes(freqrange(2,:),{'numeric'},...
                {'increasing','numel',2,'>=',fmin,'<=',fmax},...
                'icwt','FREQRANGE');

            idxbeginpos = find(freqvector >= freqrange(1,2),1,'last');
            idxendpos = find(freqvector <= freqrange(1,1),1,'first');

            idxbeginneg = find(freqvector >= freqrange(2,2),1,'last');
            idxendneg = find(freqvector <= freqrange(2,1),1,'first');
            idxzeropos = setdiff(1:Na,idxbeginpos:idxendpos);
            idxzeroneg = setdiff(1:Na,idxbeginneg:idxendneg);
        end
    otherwise
        idxzeropos = zeros(1,0);
        idxzeroneg = zeros(1,0);

end

end