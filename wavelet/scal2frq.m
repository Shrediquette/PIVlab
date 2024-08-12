function f = scal2frq(a,wname,delta)
%SCAL2FRQ Scale to frequency.
%   F = SCAL2FRQ(A,'wname',DELTA) returns the
%   pseudo-frequencies corresponding to the scales given by
%   A, the wavelet function 'wname' and the sampling
%   period DELTA.
%
%   SCAL2FRQ(A,'wname') is equivalent to SCAL2FRQ(A,'wname',1)
%
%   Example:
%     %----------------------------------------------------
%     % This example demonstrates that, starting from the
%     % periodic function x(t) = cos(5t), the scal2frq
%     % function translates the scale corresponding to
%     % the maximum value of the CWT coefficients to a
%     % pseudo-frequency (0.795), which is near to
%     % the true frequency (5/(2*pi) =~ 0.796).
%     %----------------------------------------------------
%     wname = 'db10';
%     A = -64; B = 64; P = 224;
%     delta = (B-A)/(P-1);
%     t = linspace(A,B,P);
%     omega = 5; x = cos(omega*t);
%     freq  = omega/(2*pi);
%     scales = (0.25:0.25:3.75);
%     TAB_PF = scal2frq(scales,wname,delta);
%     [dummy,ind] = min(abs(TAB_PF-freq));
%     freq_APP  = TAB_PF(ind);
%     scale_APP = scales(ind);
%     str1 = ['224 samples of x = cos(5t) on [-64,64] - ' ...
%             'True frequency = 5/(2*pi) =~ ' num2str(freq,3)];
%     str2 = 'Array of pseudo-frequencies and scales: ';
%     str3 = num2str([TAB_PF',scales'],3);
%     str4 = ['Pseudo-frequency = ' num2str(freq_APP,3)];
%     str5 = ['Corresponding scale = ' num2str(scale_APP,3)];
%     figure; cwt(x,scales,wname,'plot'); ax = gca; colorbar;
%     axTITL = get(ax,'title');
%     axXLAB = get(ax,'xlabel');
%     set(axTITL,'String',str1);
%     set(axXLAB,'String',[str4,'  -  ' str5]);
%     disp(char(' ',str1,' ',str2,str3,' ',str4,str5))
%
%   See also CENTFRQ.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-Mar-98.
%   Last Revision: 24-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1
    wname = convertStringsToChars(wname);
end

if isempty(a) , f = a; return; end
if nargin == 2, delta = 1; end
err = (min(size(a))>1) | (min(a)<eps);
if err
    error(message('Wavelet:FunctionArgVal:Invalid_ScaVal'))
end
if delta <= 0
    error(message('Wavelet:FunctionArgVal:Invalid_DeltaVal'))
end

% Compute pseudo-frequencies
f = centfrq(wname)./(a.*delta);     
