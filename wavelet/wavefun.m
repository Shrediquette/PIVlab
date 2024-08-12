function [out1,out2,out3,out4,out5] = wavefun(wname,in2,in3)
%WAVEFUN Wavelet and scaling functions 1-D.
%   WAVEFUN returns approximations of the wavelet function
%   'wname' and the associated scaling function, if it exists.
%
%   For an orthogonal wavelet:
%   [PHI,PSI,XVAL] = WAVEFUN('wname',ITER)
%   returns the scaling and wavelet functions on the 2^ITER
%   points grid XVAL. The positive integer ITER is the number
%   of iterations.
%
%   For a biorthogonal wavelet:
%   [PHI1,PSI1,PHI2,PSI2,XVAL] = WAVEFUN('wname',ITER)
%   returns the scaling and wavelet functions both
%   for decomposition (PHI1, PSI1) and for
%   reconstruction (PHI2, PSI2). 
%
%   For a Meyer wavelet:
%   [PHI,PSI,XVAL] = WAVEFUN('wname',ITER)
%
%   For a wavelet without scaling function (e.g., Morlet, 
%   Mexican Hat, Gaussian derivatives wavelets or complex
%   wavelets):
%   [PSI,XVAL] = WAVEFUN('wname',ITER). 
%   Output argument PSI is a real or complex vector 
%   depending on the wavelet type. 
%
%   ... = WAVEFUN(...,'plot') computes and, in addition, 
%   plots the functions.
%
%   WAVEFUN('wname',A,B), where A and B are positive integers,
%   is equivalent to WAVEFUN('wname',max(A,B)), and plots are
%   produced.
%   WAVEFUN('wname',0) is equivalent to WAVEFUN('wname',8,0).
%   WAVEFUN('wname')   is equivalent to WAVEFUN('wname',8).
%      
%   See also INTWAVE, WAVEINFO, WFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Convert strings to char arrays
if isStringScalar(wname)
    wname = convertStringsToChars(wname);
end

if nargin == 3 && isStringScalar(in3)
    in3 = convertStringsToChars(in3);
end

wname = deblankl(wname);
debut = wname(1:2);

[wtype,fname,family,bounds] =  ...
    wavemngr('fields',wname,'type','file','fn','bounds');

if  nargin == 1
    iter = 8; 
    pflag = 0;
elseif  nargin == 2
    if in2 == 0
        iter = 8;
        pflag = 1;
    else
        iter = in2;
        pflag = 0;
    end
else
    pflag = 1;
    if  ischar(in2)
        if ischar(in3) 
            iter = 8; 
        else 
            iter = in3; 
        end
    else
        if ischar(in3)
            iter = in2;
        else
            iter = max(in2,in3);
        end
    end
    if (ischar(iter) || any(iter < 1) || any(iter ~= fix(iter)))
        iter = 8;
    end
end

coef = (sqrt(2)^iter);
pas  = 1/(2^iter);

switch wtype
    case 1
      [Lo_R,Hi_R] = wfilters(wname,'r');
      long  = length(Lo_R);
      nbpts = (long-1)/pas+1;
      phi   = coef*upcoef('a',1,Lo_R,'dummy',iter);
      psi   = coef*upcoef('d',1,Lo_R,Hi_R,iter);

      [nbpts,nb,dn] = getNBpts(nbpts,iter,long);
      phi = [0 wkeep1(phi,nb) zeros(1,1+dn)];
      psi = [0 wkeep1(psi,nb) zeros(1,1+dn)];

      % sign depends on wavelet
      if strcmp(debut,'co') || strcmp(debut,'sy') || ... % coiflet or symlet
         strcmp(debut,'dm')                            % dmeyer
          psi = -psi ;
      end
      out1 = phi; out2 = psi;
      out3 = linspace(0,(nbpts-1)*pas,nbpts);

    case 2
      [Lo_D1,~,Lo_R2,Hi_R1,~,~,Lo_R1,Hi_R2] = wfilters(wname);

      mul = 1;
      isBior = wavemngr('isbior',wname);
      if isBior
          Nr = str2num(wname(5));
          if rem(Nr,4)~=1 , mul = -1; end
      end

      long  = length(Lo_D1);
      nbpts = (long-1)/pas;
      phi1  = coef*upcoef('a',1,Lo_R1,'dummy',iter);
      psi1  = mul*coef*upcoef('d',1,Lo_R1,Hi_R2,iter);

      [nbpts,nb,dn] = getNBpts(nbpts,iter,long);
      phi1  = [0 wkeep1(phi1,nb) zeros(1,1+dn)];
      psi1  = [0 wkeep1(psi1,nb) zeros(1,1+dn)];

      long  = length(Lo_R2);
      % Hi_R2 = wrev(Hi_D2);

      phi2  = coef*upcoef('a',1,Lo_R2,'dummy',iter);
      psi2  = mul*coef*upcoef('d',1,Lo_R2,Hi_R1,iter);

      [nbpts,nb,dn] = getNBpts(nbpts,iter,long);
      phi2 = [0 wkeep1(phi2,nb) zeros(1,1+dn)];
      psi2 = [0 wkeep1(psi2,nb) zeros(1,1+dn)];
      out1 = phi1; out2 = psi1;
      out3 = phi2; out4 = psi2;
      out5 = linspace(0,(nbpts-1)*pas,nbpts);

    case 3
        [~,~,ext] = fileparts(fname);
        if ~isequal(ext,'.mat')
            np = 2^iter;
            lb = bounds(1); ub = bounds(2);
            [out1,out2,out3] = feval(fname,lb,ub,np,wname);
        else
            load(fname);
            out3 = X;
            out2 = Z;
            out1 = Y;
        end
        
    case {4,5}
      [~,~,ext] = fileparts(fname);
      if ~isequal(ext,'.mat')
          np = 2^iter;
          lb = bounds(1); ub = bounds(2);
          [out1,out2] = feval(fname,lb,ub,np,wname);
      else
            load(fname);
            out2 = X;
            out1 = Y;
      end
end

if pflag    % plots required.
    switch wtype
      case 1
        nb   = length(phi); xmax = nb*pas; xmin = 0;
        xval = linspace(xmin,xmax,nb);
        subplot(121);plot(xval,phi,'r');grid;
        title([wname ' : phi']);
        subplot(122);plot(xval,psi,'g');grid;
        title([wname ' : psi']);

      case 2
        nb   = length(phi1); xmax = nb*pas; xmin = 0;
        xval = linspace(xmin,xmax,nb);
        subplot(221);plot(xval,phi1,'r');grid;
        title([wname ' : phi dec.']);
        subplot(222);plot(xval,psi1,'g');grid;
        title([wname ' : psi dec.']);
        nb   = length(phi2); xmax = nb*pas; xmin = 0;
        xval = linspace(xmin,xmax,nb);
        subplot(223);plot(xval,phi2,'r');grid;
        title([wname ' : phi rec.']);
        subplot(224);plot(xval,psi2,'g');grid;
        title([wname ' : psi rec.']);

      case 3
        subplot(121);plot(out3,out1,'r');grid;
        title([family '  scaling function'])
        subplot(122);plot(out3,out2,'g');grid;
        title([family '  wavelet function'])

      case 4
        plot(out2,out1,'g');grid;
        title([family '  wavelet function'])

      case 5
        subplot(221);
        plot(out2,real(out1),'r');
        title([wname ' : psi real part.']);grid
        subplot(222);
        plot(out2,imag(out1),'g');
        title([wname ' : psi imaginary part.']);grid
        subplot(223);
        plot(out2,abs(out1),'r');
        title([wname ' : psi complex modulus.']); grid
        subplot(224);
        plot(out2,angle(out1),'g');
        title([wname ' : psi phase angle.']);grid
    end
end


%----------------------%
% Internal Function(s) %
%----------------------%
function [nbpts,nb,dn] = getNBpts(nbpts,iter,long)
%
lplus = long-2;
nb = 1; for kk = 1:iter, nb = 2*nb+lplus; end
dn = nbpts-nb-2;
if dn<0 , nbpts = nbpts-dn; dn = 0; end    % HAAR 
