function tf = is_combined(cam)
%IS_COMBINED True when the camera settings combine two cameras into one larger image (cam.fov, fov.maps).
%   tf = fov.is_combined(cam)
tf = isstruct(cam) && isfield(cam, 'fov') && ~isempty(cam.fov);
end
