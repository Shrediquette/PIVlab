function load_Callback(~,~,~)
filepath=gui.retr('filepath');
handles=gui.gethand;
if size(filepath,1) > 1 %did the user load images?
	sessionpath=gui.retr('sessionpath');
	if isempty(sessionpath)
		sessionpath=gui.retr('pathname');
	end
	[maskfile,maskpath] = uigetfile('*.mat','Load PIVlab mask',fullfile(sessionpath, 'PIVlab_mask.mat'));
	pause(0.01)
	if ~isequal(maskfile,0) && ~isequal(maskpath,0)
		warning('off','MATLAB:load:variableNotFound');
		gui.toolsavailable(0,'Busy, loading masks');drawnow nocallbacks
		load(fullfile(maskpath,maskfile),'masks_in_frame');
		warning('on','MATLAB:load:variableNotFound');
		if exist('masks_in_frame','var')
			gui.put('masks_in_frame',masks_in_frame);
			gui.sliderdisp(gui.retr('pivlab_axis'))
			gui.toolsavailable(1)
		else
			gui.toolsavailable(1)
			gui.custom_msgbox('error',getappdata(0,'hgui'),'No masks found','No masks found in file.','modal');
		end
	end
else
    gui.custom_msgbox('warn',getappdata(0,'hgui'),'No image data yet','Before loading masks, you need to import images for your analyses.','modal');
end

