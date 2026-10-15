function update_board_info_3d(handles)
% Text of the panel "3D particle image generator" with the board of the marker board setup.
if nargin < 1
    handles = gui.gethand;
end
b = stereo.board_from_gui(handles);
set(handles.sim3d_boardinfo, 'String', sprintf('Board (marker board setup): %d x %d, %g / %g mm, %s origin', b.PatternDims, b.CheckerSize, ...
    b.MarkerSize, char(b.OriginCheckerColor)));
end
