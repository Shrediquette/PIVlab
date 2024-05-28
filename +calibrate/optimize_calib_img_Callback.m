function optimize_calib_img_Callback(~,~,~) %optimize display of calibration image
caliimg=gui.gui_retr('caliimg');
if ~isempty(caliimg)
	calibrate.calibrate_display_cali_img (caliimg)
end

