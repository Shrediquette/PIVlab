function Iw=wOFV_warpS(I0,V,Grid)

%Symmetric warping operator that distorts an image to Iw according to the
%vector field V using symmetric boundary conditions. I0 is a 
%griddedInterpolant object of the image. The original image and V must be 
%the same size.

%Define motion matrix with symmetric boundary conditions
% motmat=cat(3,Grid.n-max(Grid.X-V(:,:,1),Grid.n)+max(min(Grid.X-V(:,:,1),Grid.n),2-(Grid.X-V(:,:,1))),...
%     Grid.m-max(Grid.Y-V(:,:,2),Grid.m)+max(min(Grid.Y-V(:,:,2),Grid.m),2-(Grid.Y-V(:,:,2))));
% 
% Iw=I0(motmat(:,:,1),motmat(:,:,2));

Iw = I0(Grid.n-max(Grid.X-V(:,:,1),Grid.n)+max(min(Grid.X-V(:,:,1),Grid.n),2-(Grid.X-V(:,:,1))),...
    Grid.m-max(Grid.Y-V(:,:,2),Grid.m)+max(min(Grid.Y-V(:,:,2),Grid.m),2-(Grid.Y-V(:,:,2))));