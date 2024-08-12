function sett_Callback(~, ~, ~)
gui.switchui('multip04')
pause(0.01) %otherwise display isn't updated... ?!?
drawnow;drawnow;
piv.dispinterrog
piv.overlappercent
handles=gui.gethand;
if gui.retr('parallel')==0
	set (handles.text_parallelpatches,'visible','off')
	set (handles.ofv_parallelpatches,'visible','off')
	set (handles.ofv_parallelpatches,'Value',1)
else
	set (handles.text_parallelpatches,'visible','on')
	set (handles.ofv_parallelpatches,'visible','on')
	set (handles.ofv_parallelpatches,'Value',6)
end

