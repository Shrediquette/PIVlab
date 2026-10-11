function helper_verify_same_camera(testCase, a, b)
%HELPER_VERIFY_SAME_CAMERA Two camera settings (import.cam_settings) are equal. The camera model is
%   compared by its lens parameters (a cameraParameters object read from a file differs in empty,
%   unused properties).
testCase.verifyEqual(rmfield(a, 'cameraParams'), rmfield(b, 'cameraParams'));
names = {'K', 'RadialDistortion', 'TangentialDistortion', 'ImageSize'};
for k = 1:numel(names)
    testCase.verifyEqual(a.cameraParams.(names{k}), b.cameraParams.(names{k}), names{k});
end
end
