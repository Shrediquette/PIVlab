function pixel_data(~, ~, ~)
handles=gui.gui_gethand;
resultslist=gui.gui_retr('resultslist');
if size(resultslist,2)>=1
	startframe=0;
	endframe=0;
	for i=1:size(resultslist,2)
		if numel(resultslist{1,i})>0 && startframe==0
			startframe=i;
		end
		if numel(resultslist{1,i})>0
			endframe=i;
		end
	end
	set(handles.firstframe, 'String',int2str(startframe));
	set(handles.lastframe, 'String',int2str(endframe));
	if strmatch(get(handles.multip08, 'visible'), 'on')
		gui.gui_put('p8wasvisible',1)
	else
		gui.gui_put('p8wasvisible',0)
	end
	gui.gui_switchui('multip16');
else
	msgbox('No analyses yet...')
end
%populate the popup menu
avail_file_formats={'PNG','JPG','PDF','Matlab Figure'};

avail_profiles = VideoWriter.getProfiles();
ArchivalAVI = find(ismember({avail_profiles.Name},'Archival'),1);
MPEG4 = find(ismember({avail_profiles.Name},'MPEG-4'),1);

if ~isempty(ArchivalAVI)
	avail_file_formats = [avail_file_formats {'Archival AVI'}];
end
if ~isempty(MPEG4)
	avail_file_formats = [avail_file_formats {'MPEG-4'}];
end
set(handles.export_still_or_animation,'String',avail_file_formats)
export.export_still_or_animation_Callback()

