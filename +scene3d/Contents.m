% +SCENE3D  The 3D views of cameras and ChArUco board, with one look and one mouse handling:
% "Show camera position" (calibration images and rectification image), "Show 3D setup" (multi-camera
% PIV) and the 3D preview of the particle image generator.
%
% Everything is drawn in the axes of the results (simulate.result_axes): origin at the '0' printed on
% the board, x right, y up, z out of the board. The data of the callers stay in board coordinates
% (origin at the first inner corner, x right, y down, z into the board); scene3d.to_result converts.
% Below the scene is a floor with a grid, the shadows of the cameras and lines down to the floor.
% "Board upright" puts the floor below the board, "Board lying flat" behind it (a per-user
% preference, gui.get_preference('scene3d_board_lying')).
%
% Mouse: drag to rotate about the vertical axis, right drag to pan, wheel to zoom, double click or
% "Reset view" to look at everything again.
%
%   window       figure with a 3D scene: [fig, ax] = scene3d.window(@draw, Name=...)
%   init         scene state and mouse handling of an existing axes (simulate.preview_3d)
%   clear        forget the cameras and points of the last drawing (or everything)
%   board        the board as printed (or a plain plate with the corners) and the axes of the results
%   camera       camera symbol, label, line of sight and the view on the board (frustum)
%   add_points   further points that floor and view take into account (light sheet)
%   finish       floor, grid, shadows (after everything else)
%   reset_view   look at everything; fit_view: look from a direction; view_points: what the view shows;
%                view_tangents: half-angle tangents of the view
%   up           the vertical direction of the scene (upright / lying board)
%   up_control   the "Board upright / lying flat" switch
%   custom_drag  replace the rotation of the view by a drag of an object (simulate.preview_3d)
%   caption, info  header line and text box of the window
%   to_result    board coordinates <-> axes of the results; result, to_board: with the frame of the scene
%   frame_transform  coordinates of an estimation -> printed board (mirrored, turned), for board Frame
%   view_outline outline of the image of a camera on the board
%   colors       colours of the axes, of many cameras, mixing, shadows
