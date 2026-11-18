function stereo_val_Callback(~, ~, ~)
%Validation -> Stereo based validation
gui.switchui('multip32')
gui.sliderdisp(gui.retr('pivlab_axis')) %the residual map, if "Show residual map" is ticked
