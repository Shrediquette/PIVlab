function bg_save_Callback(~,~,~)
handles=gui.gethand;
if get(handles.bg_subtract,'Value')>1
	bg_img_A = gui.retr('bg_img_A');
	bg_img_B = gui.retr('bg_img_B');
	if ~isempty(bg_img_A) && ~isempty(bg_img_B)
		bg_mode=get(handles.bg_subtract,'Value');
		sessionpath=gui.retr('sessionpath');
		if isempty(sessionpath)
			sessionpath=gui.retr('pathname');
		end
		[FileName,PathName] = uiputfile('*.mat','Save background as...',fullfile(sessionpath,'background.mat'));
		if isequal(FileName,0) | isequal(PathName,0)
			return
		else
			save(fullfile(PathName,FileName),"bg_mode","bg_img_A","bg_img_B");
		end
		failure=0;
	else
		failure=1;
	end
else
	failure=1;
end
if failure==1
	gui.custom_msgbox("error",getappdata(0,'hgui'),'Error','You need to calculate a background image first.','modal');
end