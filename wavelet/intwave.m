function [out1,xval,out3] = intwave(wname,in2,in3)
%INTWAVE Integrate wavelet function psi.
%   [INTEG,XVAL] = INTWAVE('wname',PREC) computes the integral INTEG,
%   of the wavelet function psi (from -inf to XVAL values).
%   The function psi is approximated on the 2^PREC
%   points grid XVAL where PREC is a positive integer. 
%   'wname' is a string containing the name of the wavelet
%   (see WFILTERS for more information).
%   Output argument INTEG is a real or complex vector 
%   depending on the wavelet type.
%
%   For biorthogonal wavelets:
%   [INTDEC,XVAL,INTREC] = INTWAVE('wname',PREC)
%   computes the integrals INTDEC and INTREC of the wavelet 
%   decomposition function psi_dec and the wavelet 
%   reconstruction function psi_rec.
%
%   INTWAVE('wname',PREC) is equivalent to
%   INTWAVE('wname',PREC,0).
%   INTWAVE('wname') is equivalent to INTWAVE('wname',8).
%
%   When used with three arguments INTWAVE('wname',IN2,IN3),
%   PREC = MAX(IN2,IN3) and plots are displayed.
%   When IN2 is equal to the special value 0
%   INTWAVE('wname',0) is equivalent to
%   INTWAVE('wname',8,IN3).
%   INTWAVE('wname') is equivalent to INTWAVE('wname',8).
%
%   See also WAVEFUN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Jul-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 0
    wname = convertStringsToChars(wname);
end

iterDEF = 8;
switch nargin 
  case 1 
      iter = iterDEF; pflag = 0;
  case 2
      if in2 == 0
          pflag = 1;
          iter = iterDEF;   
      else
          pflag = 0;
          if isnumeric(in2)
              iter = in2; 
          else
              iter = iterDEF;
          end
          
      end
  otherwise
      pflag = 1;
      in2NUM = isnumeric(in2);
      in3NUM = isnumeric(in3);
      if in2NUM
          if in3NUM
              iter = max(in2,in3); 
          else
              iter = in2;
          end
          
      elseif in3NUM
          iter = in3;
      else 
          iter = iterDEF;
      end
end
if iter~=fix(iter) || iter<1 || iter>20
     iter = iterDEF;
end

wtype = wavemngr('type',wname);
switch wtype
  case {1,3} , [~,psi,xval] = wavefun(wname,iter);
  case 2     , [~,psi1,~,psi2,xval] = wavefun(wname,iter);
  case {4,5} , [psi,xval] = wavefun(wname,iter);
end

step = xval(2)-xval(1);
switch wtype
  case {1,3,4,5} , out1 = cumsum(psi)*step;
  case 2         , out1 = cumsum(psi1)*step; out3 = cumsum(psi2)*step;
end

if pflag
    switch wtype
      case {1,3,4}
        ax(1) = subplot(211); plot(xval,psi,'r'); title('psi function');grid
        ax(2) = subplot(212); plot(xval,out1,'g');
        title('psi function integral value from 0 to x-value');grid
        set(ax,'XLim',[xval(1),xval(end)])

      case 2
        ax(1) = subplot(221);
        plot(xval,psi1,'r');title('psi dec. funct.');grid
        ax(2) = subplot(222); plot(xval,out1,'g');
        title('psi dec. funct. integ. value from 0 to x-value');grid
        ax(3) = subplot(223);
        plot(xval,psi2,'r');title('psi rec. funct');grid
        ax(4) = subplot(224);plot(xval,out3,'g');
        title('psi rec. funct. integ. value from 0 to x-value');grid
        set(ax,'XLim',[xval(1),xval(end)])

      case {5}
        ax(1) = subplot(221);
        plot(xval,real(psi),'r');title('real part of psi funct.');grid
        ax(2) = subplot(222);plot(xval,real(out1),'g');
        title('real part of psi funct. integ. value from 0 to x-value');grid
        ax(3) = subplot(223);
        plot(xval,imag(psi),'r');title('imag. part of psi funct');grid
        ax(4) = subplot(224);plot(xval,imag(out1),'g');
        title('imag. part of psi funct. integ. value from 0 to x-value');grid
        set(ax,'XLim',[xval(1),xval(end)])
    end
end
