function cam_board_param_edited_Callback(~,~,~)
%User changed a marker board parameter by hand --> parameters are no longer the ones read from a QR code
gui.put('charuco_qr_params',[]);
