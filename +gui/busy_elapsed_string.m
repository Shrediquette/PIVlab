function str=busy_elapsed_string(seconds)
%BUSY_ELAPSED_STRING Elapsed time for the busy status strip (gui.busy_hint): 0:07, 12:34, 1:02:03
seconds=floor(seconds);
h=floor(seconds/3600);
m=floor(mod(seconds,3600)/60);
s=mod(seconds,60);
if h>0
	str=sprintf('%d:%02d:%02d',h,m,s);
else
	str=sprintf('%d:%02d',m,s);
end
