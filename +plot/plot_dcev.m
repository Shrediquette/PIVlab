function out=plot_dcev(x,y,u,v)
dUdX=conv2(u,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid')./...
	conv2(x,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid');
dVdX=conv2(v,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid')./...
	conv2(x,[ 0, 0, 0;-1, 0, 1; 0, 0, 0],'valid');
dUdY=conv2(u,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid')./...
	conv2(y,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid');
dVdY=conv2(v,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid')./...
	conv2(y,[ 0,-1, 0; 0, 0, 0; 0, 1, 0],'valid');
res=(dUdX+dVdY)/2+sqrt(0.25*(dUdX+dVdY).^2+dUdY.*dVdX);
d=zeros(size(x));
d(2:end-1,2:end-1)=imag(res);
out=((d/(max(max(d))-(min(min(d)))))+abs(min(min(d))))*255;%normalize

