function calibrate_optimize_calib_img_Callback(~,~,~) %optimize display of calibration image
caliimg=gui_NameSpace.gui_retr('caliimg');
if ~isempty(caliimg)
	calibrate_NameSpace.calibrate_display_cali_img (caliimg)
end
