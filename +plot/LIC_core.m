function out = LIC_core(vx, vy, scalefactor, iterations)
%LIC_CORE Line integral convolution image of a vector field (no GUI needed).
%   out = plot.LIC_core(vx, vy, scalefactor, iterations)
%   vx, vy       vector components (in PIVlab: v and u, as passed by plot.compute_derived)
%   scalefactor  the vector field is resized by this factor before the LIC is computed
%   iterations   number of LIC iterations (PIVlab uses 2)
%   Uses the compiled plot.fastLICFunction. Used by plot.LIC (GUI) and pivlab.derive.
if nargin < 4
    iterations = 2;
end
vx=misc.inpaint_nans(vx); %otherwise LIC will make Matlab crash
vy=misc.inpaint_nans(vy);
vx=imresize(vx,scalefactor,'bicubic');
vy=imresize(vy,scalefactor,'bicubic');

%{
this function is from:
Matlab VFV Toolbox 1.0
by courtesy of:
Nima Bigdely Shamlo (email: bigdelys-vfv@yahoo.com)
Computational Science Research Center
San Diego State University
%}

[width,height] = size(vx);
LIClength = round(max([width,height]) / 30);
kernel = ones(2 * LIClength);
% Making white noise
noiseImage=rand(width,height);
% Making LIC Image
for m = 1:iterations
    [LICImage, ~,~,~] = plot.fastLICFunction(double(vx),double(vy),noiseImage,kernel); % External Fast LIC implemennted in C language
    LICImage = imadjust(LICImage); % Adjust the value range
    noiseImage = LICImage;
end
out=LICImage;
end
