function ROIallevents(src, evt, camera_type, max_cam_res)
if nargin < 3, camera_type = ''; end
if nargin < 4, max_cam_res = [1920 1080]; end

pos = evt.CurrentPosition;
x = pos(1); y = pos(2); w = pos(3); h = pos(4);

c = roi.get_roi_constraints(camera_type, max_cam_res);
[x, y, w, h] = roi.snap_roi(x, y, w, h, c);

src.Position = [x, y, w, h];
src.Label = [int2str(x) ' ' int2str(y) ' ' int2str(w) ' ' int2str(h)];
