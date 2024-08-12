function Pxx = psdfrommag(Sxx,Fs,onesided,Norig)
% This function is for internal use only. It may change in a future
% release.
% Pxx = psdfrommag(Sxx,Fs,onesided);

%   Copyright 2017-2020 The MathWorks, Inc.

narginchk(4,4);
nargoutchk(0,1);

DT = 1/Fs;
% Input should be magnitude so abs() is not needed
Pxx = DT/Norig*abs(Sxx).^2;
if onesided
    % Correct for one-sided PSD. Do not scale 0
    % This assumes the Nyquist is present
    if rem(Norig,2)
        % odd
        Pxx(2:end,:) = 2*Pxx(2:end,:);
    else
        % even
        Pxx(2:end-1,:) = 2*Pxx(2:end-1,:);
    end
end

