function optimize_calib_img_Callback(~,~,~) %optimize display of calibration image
caliimg=gui.retr('caliimg');
if ~isempty(caliimg)
	calibrate.display_cali_img (caliimg)
end

