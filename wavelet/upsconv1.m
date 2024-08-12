function y = upsconv1(x,f,s,dwtARG1,dwtARG2)
%UPSCONV1 Upsample and convolution 1D.
%
%   Y = UPSCONV1(X,F_R,L,DWTATTR) returns the length-L central 
%   portion of the one step dyadic interpolation (upsample and
%    convolution) of vector X using filter F_R. The upsample 
%   and convolution attributes are described by DWTATTR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Special case.
if isempty(x) 
    y = 0; 
    return;
end

% Check arguments for Extension and Shift.
switch nargin
    case 3  
        perFLAG  = 0;  
        dwtSHIFT = 0;
    case 4  % Arg4 is a STRUCT
        perFLAG  = strcmpi(dwtARG1.extMode,'per');
        dwtSHIFT = mod(dwtARG1.shift1D,2);
    case 5  
        perFLAG  = strcmpi(dwtARG1,'per');
        dwtSHIFT = mod(dwtARG2,2);
end

% Define Length.
lx = 2*length(x);
lf = length(f);
if isempty(s)
    if ~perFLAG 
        s = lx-lf+2;
    else
        s = lx;
    end
end

% Compute Upsampling and Convolution.
y = x;
if ~perFLAG
    y = wconv1(dyadup(y,0),f);
    y = wkeep1(y,s,'c',dwtSHIFT);
else
    y = dyadup(y,0,1);
    y = wextend('1D','per',y,lf/2);    
    y = wconv1(y,f);
    y = y(lf:lf+s-1);
    if dwtSHIFT==1 
        y = circshift(y,-1);
    end
end
