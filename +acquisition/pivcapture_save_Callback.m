function pivcapture_save_Callback(inpt,~)
pause(0.1)
drawnow;
handles=gui.gethand;
if inpt.Value == 0
	set (handles.ac_imgamount, 'enable','off')
else
	set (handles.ac_imgamount, 'enable','on')
	acquisition.image_amount_Callback
end
drawnow;

