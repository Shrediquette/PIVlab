function out=plot_strain(x,y,u,v)
hx = x(1,:);
hy = y(:,1);
[px, junk] = gradient(u, hx, hy);
[junk, qy] = gradient(v, hx, hy); %#ok<*ASGLU>
out = px-qy;

