function Snorm = iParentChildNormalize(S,Snorm0,parentchild)
% This function is for internal use only. It may change or be removed in a
% future release.
%
% Snorm = iParentChildNormalize(S,Snorm0,parentchild)

% Copyright 2020-2022 The MathWorks, Inc.
%#codegen
type = underlyingType(S);
Eps = realmin(type);
Snorm = coder.nullcopy(zeros(size(S),'like',S));
Snorm(1,:,:,:) = S(1,:,:,:);
pidx = 2;
for ii = 1:length(parentchild)
    L = length(parentchild{ii});
    if L
        for jj = 1:length(parentchild{ii})
            idxChild = parentchild{ii}{jj};
            if ii == 1
                Snorm(idxChild,:,:,:) = ...
                    S(idxChild,:,:,:)./(Snorm0+Eps);
            else
                Snorm(idxChild,:,:,:) = ...
                    S(idxChild,:,:,:)./mean(S(pidx,:,:,:)+Eps,'all');
                pidx = pidx+1;
            end            
        end
    end    
end
