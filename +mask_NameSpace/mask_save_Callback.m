function mask_save_Callback(~,~,~)
masks_in_frame=gui_NameSpace.gui_retr('masks_in_frame');
sessionpath=gui_NameSpace.gui_retr('sessionpath');
if isempty(sessionpath)
	sessionpath=gui_NameSpace.gui_retr('pathname');
end
if  ~isempty(masks_in_frame)
	[maskfile,maskpath] = uiputfile('*.mat','Save mask polygon(s)',fullfile(sessionpath, 'PIVlab_mask.mat'));
	if ~isequal(maskfile,0) && ~isequal(maskpath,0)
		save(fullfile(maskpath,maskfile),'masks_in_frame');
	end
end
