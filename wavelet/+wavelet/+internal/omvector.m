function w = omvector(N,freqtype,freqrange)
% Frequency vector
% This function is for internal use only. It may change or be removed in a
% future release.
% w = omvector(N,'angular','twosided')

% Copyright 2020 The MathWorks, Inc.

%#codegen 
validfreqrange = {'twosided','centered'};
validftype = {'angular','cyclic'};
frange = validatestring(freqrange,validfreqrange,'omvector');
ftype = validatestring(freqtype,validftype,'omvector');


w = 0:(2*pi)/N:2*pi-(2*pi)/N;
w = w(:);

if strcmpi(frange,'centered')
    Mi = floor(N/2);
    w = fftshift(w);
    w(1:Mi)=-2*pi+w(1:Mi);
end


if strcmpi(ftype,'cyclic')
    w = w./(2*pi);
end

