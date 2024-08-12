function [wpws,x] = wpfun(wname,num,prec)
%WPFUN Wavelet packet functions.
%   [WPWS,X] = WPFUN('wname',NUM,PREC) computes the
%   wavelets packets for a wavelet 'wname' (see WFILTERS),
%   on dyadic intervals of length 1/2^PREC. PREC must be
%   a positive integer.
%   Output matrix WPWS contains the W functions of index
%   from 0 to NUM, stored rowwise as [W0; W1;...; Wnum].
%   Output vector X is the corresponding common X-grid 
%   vector.
%
%   [WPWS,X] = WPFUN('wname',NUM) is equivalent to
%   [WPWS,X] = WPFUN('wname',NUM,7).
%
%   See also WAVEFUN, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if isStringScalar(wname)
    wname = convertStringsToChars(wname);
end

if nargin<3 , prec = 7; end
[hr,gr] = wfilters(wname,'r');
NBP = 2^prec;
N   = fix(length(hr)/2);
NBVal = (2*N-1)*NBP;
phi = wavefun(wname,prec);

dd  = NBVal-length(phi);
if dd<0
    phi = wkeep1(phi,NBVal);
elseif dd>0
    phi = [zeros(1,floor(dd/2)) phi zeros(1,ceil(dd/2))];
end
wpws      = zeros(num+1,NBVal);
wpws(1,:) = phi;
lg = 2*NBP*N;
F  = zeros(2,lg);
F(1,1:NBP:lg) = hr;
F(2,1:NBP:lg) = gr;
for k=1:num
    m = fix(k/2);
    Wm   = wpws(m+1,:);
    indF = rem(k,2)+1;
    tmp  = wconv1(Wm,F(indF,:));
    tmp  = tmp(2:2:end);
    wpws(k+1,:) = sqrt(2)*tmp(1:NBVal);
end

%---------------------- Another Algorithm ------------------%
% ip  = NBP*[0:2*N-1];
% for k=1:num
%     m  = fix(k/2);
%     Wm = wpws(m+1,:);
%     W  = zeros(1,NBVal);
%     if rem(k,2)==0 , fr = hr; else fr = gr; end
%     ind = -ip;
%     for j = 1:NBVal
%     ind  = ind+2;
%     i_p  = find(ind>0 & ind<=NBVal);
%     W(j) = sum(fr(i_p).*Wm(ind(i_p)));
%     end
%     wpws(k+1,:)  = sqrt(2)*W;
% end
%-----------------------------------------------------------%

wpws = [zeros(num+1,1) wpws zeros(num+1,1)];
x    = linspace(0,2*N-1,NBVal+2);
