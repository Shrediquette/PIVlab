function xrec = uidft(xdft,isReal)
% This function is for internal use only. It may change or be removed in a
% future release.
%

% Copyright 2021 The MathWorks, Inc.

%#codegen
N = size(xdft,1);
% Note that MATLAB Coder does not support the 'symmetric' option
if isReal && isempty(coder.target)
    xrec = sqrt(N)*ifft(xdft,'symmetric');
elseif isReal && ~isempty(coder.target)
    xrec = real(sqrt(N)*ifft(xdft));
else
    xrec = sqrt(N)*ifft(xdft);
end
