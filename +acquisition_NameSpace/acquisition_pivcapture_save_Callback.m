function acquisition_pivcapture_save_Callback(inpt,~)
pause(0.1)
handles=gui_NameSpace.gui_gethand;
if inpt.Value == 0
	set (handles.ac_imgamount, 'enable','off')
else
	set (handles.ac_imgamount, 'enable','on')
	acquisition_NameSpace.acquisition_image_amount_Callback
end
