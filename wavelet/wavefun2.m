function [s2,w1,w2,w3,xy] = wavefun2(wname,in2,in3)
%WAVEFUN2 Wavelets and scaling functions 2-D.
%   WAVEFUN2 returns approximations of the wavelet functions
%   'wname' and the associated scaling function.
%
%   [S,W1,W2,W3,XYVAL] = WAVEFUN2('wname',ITER) returns the 
%   scaling function and the three wavelet functions resulting
%   from the tensor products of one dimensional scaling and
%   wavelet functions, for an orthogonal wavelet.
%
%   More precisely, if [PHI,PSI,XVAL] = WAVEFUN('wname',ITER),
%   the scaling function S is the tensor product of PHI and PHI.
%   The wavelet functions W1, W2 and W3 are respectively the tensor
%   product (PHI,PSI), (PSI,PHI) and (PSI,PSI).
%   The two dimensional variable XYVAL is a (2^ITER) x (2^ITER)
%   points grid obtained from the tensor product (XVAL,XVAL).
%   The positive integer ITER is the number of iterations.
%
%   ... = WAVEFUN2(...,'plot') computes and, in addition, 
%   plots the functions.
%
%   WAVEFUN2('wname',A,B), where A and B are positive integers,
%   is equivalent to WAVEFUN2('wname',max(A,B)), and plots are
%   produced.
%   WAVEFUN2('wname',0) is equivalent to WAVEFUN2('wname',4,0).
%   WAVEFUN2('wname')   is equivalent to WAVEFUN2('wname',4).
%
%   See also INTWAVE, WAVEFUN, WAVEINFO, WFILTERS.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-2000.
%   Last Revision 08-May-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

% Convert string to char array
if isStringScalar(wname)
    wname = convertStringsToChars(wname);
end

wname = deblankl(wname);
wtype = wavemngr('fields',wname,'type');

% Check arguments.
if ~isequal(wtype,1)
    errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Invalid_WaveType'),'msg');
    error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end

iter = 4; 
pflag = 0;
switch nargin
	case 1 
		
	case 2 
        if in2 == 0 
            pflag = 1; 
        else 
            iter = in2; 
        end
		
	otherwise	
        pflag = 1;
        if  ischar(in2)
            if ~ischar(in3) 
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
            iter = 4;
        end
end

[s,w,x] = wavefun(wname,iter);
s2 = kron(s,s');
w1 = kron(s,w');
w2 = kron(w,s');
w3 = kron(w,w');
if nargout>4 , xy  = kron(x,x'); end

if pflag
    newplot;
	colormap(pink(128));
	a(1) = subplot(2,2,1); surf(x,x,s2); shading interp
	title(getWavMSG('Wavelet:moreMSGRF:Scale_FUN'))
	a(2) = subplot(2,2,2); surf(x,x,w1); shading interp
	title(getWavMSG('Wavelet:moreMSGRF:Wavelet_FUN','(1)'))
	a(3) = subplot(2,2,3); surf(x,x,w2); shading interp
	title(getWavMSG('Wavelet:moreMSGRF:Wavelet_FUN','(2)'))
	a(4) = subplot(2,2,4); surf(x,x,w3); shading interp
	title(getWavMSG('Wavelet:moreMSGRF:Wavelet_FUN','(3)'))
	minX = min(x); maxX = max(x);
	set(a,'XLim',[minX,maxX],'YLim',[minX,maxX])
	set(a(1),'Zlim',[min(min(s2)) max(max(s2))]);
	set(a(2),'Zlim',[min(min(w1)) max(max(w1))])
	set(a(3),'Zlim',[min(min(w2)) max(max(w2))])
	set(a(4),'Zlim',[min(min(w3)) max(max(w3))])
	set(a,'XGrid','On','YGrid','On','Zgrid','On')
end
