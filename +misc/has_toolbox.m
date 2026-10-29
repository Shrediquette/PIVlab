function ok = has_toolbox(name)
% True when the toolbox is installed and licensed.
% name: 'Computer Vision Toolbox', 'Parallel Computing Toolbox', 'Image Acquisition Toolbox',
%       'MATLAB Compiler'
% Standalone PIVlab has everything compiled in. This matters when PIVlab runs from source
% in a MATLAB that only has the Image Processing Toolbox.
switch name
    case 'Computer Vision Toolbox'
        feature_name = 'Video_and_Image_Blockset';
        probe = 'cameraIntrinsics';
    case 'Parallel Computing Toolbox'
        feature_name = 'Distrib_Computing_Toolbox';
        probe = 'parpool';
    case 'Image Acquisition Toolbox'
        feature_name = 'Image_Acquisition_Toolbox';
        probe = 'videoinput';
    case 'MATLAB Compiler'
        feature_name = 'MATLAB_Compiler';
        probe = 'ctfroot';
    otherwise
        error('PIVlab:unknownToolbox','Unknown toolbox: %s', name)
end
ok = false;
try
    ok = license('test', feature_name) == 1 && exist(probe, 'file') > 0;
catch
end
if isdeployed
    ok = true; % compiled in
end
end
