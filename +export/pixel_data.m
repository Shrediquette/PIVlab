function pixel_data(~, ~, ~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
if size(resultslist,2)>=1
	analysed=find(~cellfun(@isempty, resultslist(1,:)));
	if isempty(analysed)
		analysed=0;
	end
	set(handles.firstframe, 'String',int2str(analysed(1))); %first and last analysed frame
	set(handles.lastframe, 'String',int2str(analysed(end)));
	gui.switchui('multip16');
else
    gui.custom_msgbox('error',getappdata(0,'hgui'),'Nothing to export','No analyses yet...','modal');
end
%populate the popup menu
avail_file_formats={'PNG','JPG','PDF','Matlab Figure'};
profiles = {VideoWriter.getProfiles().Name};
if ismember('Archival',profiles)
	avail_file_formats = [avail_file_formats {'Archival AVI'}];
end
if ismember('MPEG-4',profiles)
	avail_file_formats = [avail_file_formats {'MPEG-4'}];
end
set(handles.export_still_or_animation,'String',avail_file_formats)
gui.apply_pending_popup(handles.export_still_or_animation) %item wanted by a loaded session
export.still_or_animation_Callback()
