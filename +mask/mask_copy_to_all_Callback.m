function mask_copy_to_all_Callback(~,~,~)
handles=gui.gui_gethand;
currentframe=floor(get(handles.fileselector, 'value'));
masks_in_frame=gui.gui_retr('masks_in_frame');
if isempty(masks_in_frame)
	%masks_in_frame=cell(currentframe,1);
	masks_in_frame=cell(1,currentframe);
end

if numel(masks_in_frame)<currentframe
	mask_positions=cell(0);
else
	mask_positions=masks_in_frame{currentframe};
end

if ~isempty (mask_positions)
	filepath=gui.gui_retr('filepath');
	for i=1:floor(numel(filepath)/2)
		masks_in_frame{i} = mask_positions;
	end
end
gui.gui_put('masks_in_frame',masks_in_frame);

