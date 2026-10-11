function [models, labels] = disparity_models
%DISPARITY_MODELS The smooth models of the disparity map (stereo.fit_disparity), in the order of the
%popup menu of the Stereo-PIV panel (setting stereo_disp_model).
models = ["poly2", "poly1", "projective"];
labels = {'2nd-order polynomial', 'Plane (1st order)', 'Projective'};
end
