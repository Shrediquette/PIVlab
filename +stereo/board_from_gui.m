function board = board_from_gui(handles)
%BOARD_FROM_GUI ChArUco board definition of the camera calibration panels (for stereo.calibrate).
if nargin < 1
    handles = gui.gethand;
end
board.PatternDims = [str2double(get(handles.calib_rows, 'String')), str2double(get(handles.calib_columns, 'String'))];
board.CheckerSize = str2double(get(handles.calib_checkersize, 'String'));
board.MarkerSize = str2double(get(handles.calib_markersize, 'String'));
board.MarkerFamily = "DICT_4X4_1000"; % the only board type of the calibration panels
colors = get(handles.calib_origincolor, 'String');
board.OriginCheckerColor = string(lower(colors{get(handles.calib_origincolor, 'Value')}));
end
