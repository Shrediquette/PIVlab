function t = wpthcoef(t,keepapp,sorh,thr)
%WPTHCOEF Wavelet packet coefficients thresholding.
%   NEWT = WPTHCOEF(T,KEEPAPP,SORH,THR) 
%   returns the new wavelet packet tree NEWT 
%   obtained from the wavelet packet tree T 
%   by coefficients thresholding.
%
%   If KEEPAPP = 1, approximation coefficients are not
%   thresholded, otherwise it is possible.
%   If SORH = 's', soft thresholding is applied,
%   if SORH = 'h', hard thresholding is applied (see WTHRESH).
%   
%   THR is the threshold value.
%
%   See also WPDEC, WPDEC2, WPDENCMP, WTHRESH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 2 && isStringScalar(sorh)
    sorh = convertStringsToChars(sorh);
end

tnods = leaves(t);  % Keep terminal nodes.
                    % Sort terminal nodes
                    % from left to right.
                    % Approximation index is 1.
if keepapp==1
    % Save approximation.
    app_coefs = read(t,'data',tnods(1));
end

coefs = read(t,'data');
coefs = wthresh(coefs,sorh,thr);
t     = write(t,'data',coefs);
if keepapp==1
    % Restore approximation.
    t  = write(t,'data',tnods(1),app_coefs);
end
