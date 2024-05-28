function result=check_project_path(projectpath,caller)
handles=gui.gethand;
result=0;
if ~exist(projectpath,'dir')
	button = questdlg('Folder does not exist. Create?','Create?','Yes','Cancel','Yes');
	if strmatch(button,'Yes')==1
		mkdir(projectpath);
		result=1;
		acquisition.update_ac_status(['Created folder ' projectpath]);
	end
else
	result=1;
end
if strcmp(caller,'double_images')
	if result==1 && exist(fullfile(projectpath,'PIVlab_0000_A.tif'),'file') || exist(fullfile(projectpath,'frame_000001.tiff'),'file')
		button = questdlg('Overwrite files?','Overwrite?','Yes','Cancel','Yes');
		if strmatch(button,'Yes')==1
			result=1;
		else
			result=0;
		end
	end
end

