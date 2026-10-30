function cancel_3d_Callback(~, ~, ~)
% "Cancel" (the buttons "Generate images..." and "Preview particle images" while they compute): the
% computation stops at its next progress message (simulate.progress_control)
gui.put('sim3d_cancel', 1);
end
