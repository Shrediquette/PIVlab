% Velocity magnitude notch filter in PIVlab
function [u_out,v_out] = PIVlab_notch_filter (u,v,calu,calv,vL,vH)
magn=((u*calu).^2+(v*calv).^2).^0.5;

u(magn<vH & magn>vL)=nan;
v(magn<vH & magn>vL)=nan;
u_out=u;
v_out=v;