function padimg = padimage(img,padsize)
% This function is for internal use only and may be removed in a future
% release
% padimg = padimage(img,[pady padx]);

%   Copyright 2018-2020 The MathWorks, Inc.


% In the spatial domain, the x-variable is the columns of img. The
% y-variable is the rows of img
szY = size(img,1);
szX = size(img,2);
diffX = padsize(2)-szX;
diffY = padsize(1)-szY;
if any([diffX diffY] < 0)
    error(message('Wavelet:scattering:smallpadsize'));
end
if rem(diffX,2)
    NxRemove = (diffX-1)/2;
else
    NxRemove = diffX/2;
end
if rem(diffY,2)
    NyRemove = (diffY-1)/2;
else
    NyRemove = diffY/2;
end
padidx = SymmetricPad([szY szX],[diffY diffX],'both');
padimg = img(padidx{:},:);
padimg = padimg(NyRemove+1:padsize(1)+NyRemove,NxRemove+1:padsize(2)+NxRemove,:);

%-------------------------------------------------------------------------
function idx = SymmetricPad(aSize, padSize, direction)

numDims = numel(padSize);

% Form index vectors to subsasgn input array into output array.
% Also compute the size of the output array.
idx   = cell(1,numDims);
for k = 1:numDims
    M = aSize(k);
    dimNums = uint32([1:M M:-1:1]);
    p = padSize(k);
    
    switch direction
        case 'pre'
            idx{k}   = dimNums(mod(-p:M-1, 2*M) + 1);
            
        case 'post'
            idx{k}   = dimNums(mod(0:M+p-1, 2*M) + 1);
            
        case 'both'
            idx{k}   = dimNums(mod(-p:M+p-1, 2*M) + 1);
    end
end

