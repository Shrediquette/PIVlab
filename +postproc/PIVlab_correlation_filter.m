% Correlation map post processing in PIVlab
function [u_out,v_out] = PIVlab_correlation_filter (u,v,corr2_thresh,corr2_value)
u(corr2_value<corr2_thresh)=nan;
v(corr2_value<corr2_thresh)=nan;
u_out=u;
v_out=v;