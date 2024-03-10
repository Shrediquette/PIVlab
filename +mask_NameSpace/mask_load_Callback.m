function mask_load_Callback(~,~,~)
filepath=gui_NameSpace.gui_retr('filepath');
handles=gui_NameSpace.gui_gethand;
if size(filepath,1) > 1 %did the user load images?
	sessionpath=gui_NameSpace.gui_retr('sessionpath');
	if isempty(sessionpath)
		sessionpath=gui_NameSpace.gui_retr('pathname');
	end
	[maskfile,maskpath] = uigetfile('*.mat','Load PIVlab mask',fullfile(sessionpath, 'PIVlab_mask.mat'));
	pause(0.01)
	if ~isequal(maskfile,0) && ~isequal(maskpath,0)
		warning('off','MATLAB:load:variableNotFound');
		gui_NameSpace.gui_toolsavailable(0,'Busy, loading masks');drawnow nocallbacks
		load(fullfile(maskpath,maskfile),'masks_in_frame');
		warning('on','MATLAB:load:variableNotFound');
		if exist('masks_in_frame','var')
			gui_NameSpace.gui_put('masks_in_frame',masks_in_frame);
			gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'))
			gui_NameSpace.gui_toolsavailable(1)
		else
			gui_NameSpace.gui_toolsavailable(1)
			msgbox('No masks found in file.','modal');
		end
	end
else
	msgbox('Before loading masks, you need to import images for your analyses.','modal');
end
