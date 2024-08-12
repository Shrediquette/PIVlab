function [Z,aset,bset] = BatchEvenOddFilter(x,hb,ha)
% This function is for internal use only, it may change or be removed in a
% future release.
%
% Z = wavelet.internal.BatchEvenOddFilter(x,hb,ha) filters the columns of x
% using the filters ha and hb. ha belongs to one tree and hb belongs to
% the other tree. hb is the reverse of ha.
%
% % Example
% load qshift6;
% load woman;
% y = wavelet.internal.BatchEvenOddFilter(X,LoDa,LoDb);

% Copyright 2019-2020 The MathWorks, Inc.

%#codegen

Sx = size(x);
WCN = prod(Sx(2:end));
Nr = size(x,1);
% Check that input is multiple of four so we can use the four polyphase
% filters
% Check that input is multiple of four so we can use the four polyphase
% filters
coder.internal.errorIf(mod(Nr,4) ~= 0,'Wavelet:dualtree:modfour');
% ha and hb are identical length (even) filters
coder.internal.assert(numel(ha) == numel(hb),'Wavelet:dualtree:qfiltlength');
% Reshape x to use conv2 and filter along the columns
x = reshape(x,[Nr WCN]);

% Tree A polyphase components
% haEven is the reverse of hbOdd. haOdd is the reverse of hbEven
% Number of filter coefficients
Nh = length(ha);

Nh2 = Nh/2;
haOdd = zeros(Nh2,1,'like',ha);
haEven = zeros(Nh2,1,'like',ha);
hbOdd = zeros(Nh2,1,'like',hb);
hbEven = zeros(Nh2,1,'like',hb);

haOdd(:) = ha(1:2:end);
haEven(:) = ha(2:2:end);
% Tree B polyphase components
hbOdd(:) = hb(1:2:end);
hbEven(:) = hb(2:2:end);
% Nr is even
r2 = Nr/2;
Z = coder.nullcopy(zeros(r2,WCN,'like',x));

% Set up vector for indexing into the matrix
idx = 6:4:Nr+2*Nh-2;

% Obtain indices to extend data. Data is symmetrically extended at the
% beginning and end by Nh
ridx = wavelet.internal.reflectIdx(Nr,Nh);
% Now perform the filtering
% Get indices for indexing into Z, s1 could be 1:2:r2 or 2:2:r2. Each are
% 1/2 the input length

% The following holds for the lowpass filter. We could replace this with a
% flag to denote lowpass vs. highpass filtering
if dot(ha,hb) > 0
    s1 = 1:2:r2;
    s2 = s1 + 1;
else
% Highpass filter
    s2 = 1:2:r2;
    s1 = s2 + 1;
end

% idx-1 and idx-3 are odd indices, idx and idx-2 are even indices.
% By convention, tree B lags tree A. 

% The following implements polyphase filtering where we divide the data x
% into two polyphase components for each tree A and B. Each polyphase
% component is a sequence of length Nr/2
% Odd indices
Z(s1,:) = conv2(x(ridx(idx-1),:),hbOdd(:),'valid') + conv2(x(ridx(idx-3),:),hbEven(:),'valid');
% Even indices
Z(s2,:) = conv2(x(ridx(idx),:),haOdd(:),'valid') + conv2(x(ridx(idx-2),:),haEven(:),'valid');
Z = reshape(Z,[r2 Sx(2:end)]);
if nargout > 1
    bset = [ridx(idx-1) ridx(idx-3)];
    aset = [ridx(idx) ridx(idx-2)];
end
