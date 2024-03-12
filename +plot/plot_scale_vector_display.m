function [vecskip, vecscale] = plot_scale_vector_display(handles, x, y, u, v)
autoscale_vec=get(handles.autoscale_vec, 'Value');
vecskip=str2double(get(handles.nthvect,'String'));
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
	else
		autoscale = autoscale; %#ok<*ASGSL>
	end
	vecscale=autoscale;
else %autoscale off
	vecscale=str2num(get(handles.vectorscale,'string')); %#ok<*ST2NM>
end

