function [sx,sy] = dw1dcoor(x,y,axe,in4)
%DW1DCOOR Discrete wavelet 1-D coordinates.
%   Write function used by DYNVTOOL.
%   [SX,SY] = DW1DCOOR(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 03-Oct-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% in4 = [coefs_axes  level_anal]
% or
% in4 = [coefs_axes -level_anal]
%-------------------------------
indic = 'energy';
sx = ['X = ' , wstrcoor(x,5,7)];
fig_DW1D   = in4(1);
coefs_axes = in4(2:end-1);
level_anal = in4(end);
signe      = sign(level_anal);
if find(axe==coefs_axes)
    if signe>0 
        z = round(level_anal-y+1);
    else
        z = round(y);
    end
    if (1<=z) && (z<=abs(level_anal))
        switch indic
            case 'energy'
                % MemBloc2 of stored values.
                %---------------------------
                n_coefs_longs = 'Coefs_and_Longs';
                [coefs,longs] = wmemtool('rmb',fig_DW1D,n_coefs_longs,1,2);
                [~,Ed] = wenergy(coefs,longs);
                sy = sprintf('E = %2.2f %%',Ed(z));
                %-----------------------------------------------------
            case 'level' 
                sy = getWavMSG('Wavelet:dw1dRF:Level_EQ',z);
        end
    else
        sy = [];
    end
else
    sy = ['Y = ' , wstrcoor(y,5,7)];
end
