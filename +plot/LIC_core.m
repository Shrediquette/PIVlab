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
plot_folder = fileparts(mfilename('fullpath'));
if ~isfile(fullfile(plot_folder, ['fastLICFunction.' mexext])) % MEX file not compiled yet: compile it first
    disp('Compiling the LIC MEX file (only once)...');
    try
        mex('-outdir', plot_folder, fullfile(plot_folder, 'fastLICFunction.c'));
    catch err
        error('Could not compile the LIC MEX file %s (%s).', fullfile(plot_folder, 'fastLICFunction.c'), err.message);
    end
    % No .m file named fastLICFunction exists, so rehash finds the new MEX file. Never rmpath / addpath
    % the PIVlab folder here: that unloads the running PIVlab code and classes (MATLAB crashed).
    rehash path
end
for m = 1:iterations
    [LICImage, ~,~,~] = plot.fastLICFunction(double(vx),double(vy),noiseImage,kernel); % External Fast LIC implemennted in C language
    LICImage = imadjust(LICImage); % Adjust the value range
    noiseImage = LICImage;
end
out=LICImage;
end
