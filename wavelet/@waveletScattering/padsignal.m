function y = padsignal(x,npad,type)
% This function is for internal use only. It may change or be removed in a
% future release.

%   Copyright 2018-2022 The MathWorks, Inc.
%#codegen
% Valid for vectors or matrices
OrigSize = size(x,1);
% npad should be greater than or equal to size(x,1)
if strcmpi(type,'periodic')
    Npad = ceil(npad/OrigSize);
    y = repmat(x,Npad,1);
    y = y(1:npad,:,:);
else
    % For reflection extension we start with twice the original signal
    % length
    Npad = ceil(npad/(2*OrigSize));
    xflip = flip(x);
    x = [x ; xflip];
    y = repmat(x,Npad,1);
    y = y(1:npad,:,:);
end
