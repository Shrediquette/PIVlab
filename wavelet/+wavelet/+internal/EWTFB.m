function [mfb,adjboundaries] = EWTFB(w,boundaries,N,gamma,sigtype)
% EWT Filter Bank
% This function is for internal use only. It may change or be removed in a
% future release.
% [wfb,boundaries] = EWTFB(w,boundaries,N,gamma,sigtype)

% Copyright 2020 The MathWorks, Inc.
%#codegen

isReal = strcmpi(sigtype,'real');
% Obtain number of boundary points.
Npic = length(boundaries);


% Frequency vector
if ~isReal
    boundaries(boundaries > pi) = boundaries(boundaries > pi)-(2*pi);
    if ~any(boundaries < 0)
        boundaries = [-pi/2 ; boundaries];
        Npic = Npic+1;
    elseif ~any(boundaries > 0)
        boundaries = [boundaries ; pi/2];
        Npic = Npic+1;
    end
    
end



% The first element will be the Meyer scaling function for real-valued
% signals, the [-pi, boundaries(1)] for complex-valued
mfb = zeros(N,Npic+1,'like',boundaries);

% We start by generating the scaling function
lpbounds = scalingbounds(boundaries,sigtype);
if ~isReal
    mfb(:,1) = ...
        wavelet.internal.CMeyerWavNegNyquist(boundaries(1),gamma,w);
        
   mfb(:,Npic+1) = ...
       wavelet.internal.CMeyerWavPosNyquist(boundaries(end),gamma,w);
   for kk = 2:Npic
       mfb(:,kk) = ...
           wavelet.internal.CMeyerWav(boundaries(kk-1),boundaries(kk),gamma,w);
   end
else
    % For real-valued signals, the first is the scaling function
    mfb(:,1) = wavelet.internal.ReMeyerSF(lpbounds,gamma,w);
    for k=1:Npic-1
        mfb(:,k+1) = wavelet.internal.ReMeyerWav(boundaries(k),boundaries(k+1),gamma,w); 
    end
    mfb(:,Npic+1) = wavelet.internal.ReNyqMeyerWav(boundaries(Npic),gamma,w);
end

adjboundaries = boundaries;

if isReal
    mfb = flip(mfb,2);
    
end



%------------------------------------------------------------------------
function [lpbounds,lpboundneg,lpboundpos] = scalingbounds(boundaries,sigtype)
lpboundneg = NaN;
lpboundpos = NaN;
if strcmpi(sigtype,'real')
    lpbounds = boundaries(1);
else
    lpboundneg = find(boundaries < 0, 1,'last');
    lpboundpos = find(boundaries > 0,1,'first');
    lpbounds = [boundaries(lpboundneg) ; boundaries(lpboundpos)];
end
    
