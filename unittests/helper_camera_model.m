function cp = helper_camera_model(sz)
%HELPER_CAMERA_MODEL Camera model with strong barrel distortion for images of size sz (similar to
%   the fisheye lens of the sphere_wake_distorted example images).
f = 0.9*sz(2);
K = [f 0 sz(2)/2; 0 f sz(1)/2; 0 0 1];
cp = cameraParameters('K', K, 'RadialDistortion', [-0.25 0.06], 'ImageSize', sz);
end
