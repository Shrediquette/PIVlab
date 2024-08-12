function gdual = dualcswindow(g,fshifts,bw)
% This function is for internal use only. It may change or be removed in a
% future release.
% gdual = wavelet.internal.dualcswindow(g,shifts,bw) returns the dual
% frames for the nonstationary Gabor constant-q transform.

%   Copyright 2017-2020 The MathWorks, Inc.

%   References:
%   Holighaus, N., Doerfler, M., Velasco, G.A., & Grill,T.
%   (2013) "A framework for invertible real-time constant-Q transforms",
%   IEEE Transactions on Audio, Speech, and Language Processing, 21, 4,
%   pp. 775-785.
%
%   Velasco, G.A., Holighaus, N., Doerfler, M., & Grill, Thomas. (2011)
%   "Constructing an invertible constant-Q transform with nonstationary
%   Gabor frames", Proceedings of the 14th International Conference on
%   Digital Audio Effects (DAFx-11), Paris, France.

%#codegen

gdual = g;
N = length(fshifts);
% Signal length is the sum of the frequency shifts
siglen = sum(fshifts);

positions = cumsum(fshifts);
positions = positions-fshifts(1);

diagonal = zeros(siglen,1);
win_range = cell(N,1);

% Construct the diagonal of the frame operator matrix.
% This is a tight frame so the frame operator is diagonal

% Algorithm for computing canonical dual frame in painless case is due to
% Holighaus and Velasco
for ii = 1:N
    Lg = length(gdual{ii});
    
    tWinRange = 1+mod(positions(ii)+(-floor(Lg/2):ceil(Lg/2)-1),siglen);
    win_range{ii} = tWinRange;
    diagonal(tWinRange) = diagonal(tWinRange) + ...
        (fftshift(gdual{ii}).^2)*bw(ii);
end

% Using the frame operator and the original window sequence, compute
% the dual window sequence
for ii=1:N
    gdual{ii} = ifftshift(fftshift(gdual{ii})./diagonal(win_range{ii}));
end
