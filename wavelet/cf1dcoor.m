function [sx,sy] = cf1dcoor(x,y,axe,in4)
%CF1DCOOR Coefficients 1-D coordinates.
%   Write function used by DYNVTOOL.
%   [SX,SY] = CF1DCOOR(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Nov-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% in4 = [coefs_axes  level_anal]
% or
% in4 = [coefs_axes -level_anal]
%-------------------------------
sx = sprintf('X = %7.2f',x);
coefs_axes = in4(1:end-1);
level_anal = in4(end);
signe      = sign(level_anal);
if find(axe==coefs_axes)
    if signe>0 
        z = round(level_anal-y+1);
    else
        z = round(y);
    end
    if (1<=z) && (z<=abs(level_anal))
        sy = getWavMSG('Wavelet:divGUIRF:CF1D2D_Coor',z);
    elseif (abs(level_anal)<z) && (z<=abs(level_anal)+1)
        sy = getWavMSG('Wavelet:divGUIRF:CF1D2D_Coor',z-1);
    else
        sy = [];
    end
else
    sy = sprintf('Y = %7.2f',y);
end
