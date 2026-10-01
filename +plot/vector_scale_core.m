function vecscale = vector_scale_core(x, y, u, v, autoscale_vec, vecskip, vectorscale)
%VECTOR_SCALE_CORE Scale factor for the vector display (no GUI needed).
%   vecscale = plot.vector_scale_core(x, y, u, v, autoscale_vec, vecskip, vectorscale)
%   autoscale_vec true: like QUIVER's autoscaling (longest vector ~ grid spacing * vecskip),
%   false: vectorscale is used. Used by plot.scale_vector_display (GUI) and pivlab.display.
if autoscale_vec == 1
    autoscale=1;
    %from quiver autoscale function:
    if min(size(x))==1, n=sqrt(numel(x)); m=n; else; [m,n]=size(x); end
    delx = diff([min(x(:)) max(x(:))])/n;
    dely = diff([min(y(:)) max(y(:))])/m;
    del = delx.^2 + dely.^2;
    if del>0
        len = sqrt((u.^2 + v.^2)/del);
        maxlen = max(len(:));
    else
        maxlen = 0;
    end
    if maxlen>0
        autoscale = autoscale/ maxlen * vecskip;
    end
    vecscale=autoscale;
else %autoscale off
    vecscale=vectorscale;
end
end
