function part_img_3d_Callback(~, ~, ~)
% Menu "Synthetic particle image generation -> 3D particle image generator": the panel and the 3D preview.
gui.switchui('multip31')
handles = gui.gethand;
simulate.update_board_info_3d(handles);
gui.update_dependent_controls(handles);
if ~isequal(gui.retr('batchModeActive'), 1)
    simulate.preview_3d_Callback();
end
end
