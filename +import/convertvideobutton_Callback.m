function convertvideobutton_Callback(~,~,~)
% Convert a video file to lossless grayscale image files, then load these
% images through the standard image-import pipeline (time-resolved).
% PIVlab does NOT read videos on-the-fly anymore (no parallel processing,
% codec issues, more bug-prone). Converting to image files first keeps all
% downstream features working exactly as for a normal image sequence.
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[gui.retr('pathname') '\'];
else
	pathname=[gui.retr('pathname') '/'];
end
gui.displogo(0)
setappdata(hgui,'video_convert_done',0);
setappdata(hgui,'video_selection_done',0); %we never use on-the-fly video reading

%Open the video preview window in "convert to disk" mode (2nd arg = 1)
import.vid_import(pathname,1);
uiwait

if getappdata(hgui,'video_convert_done')
	filelist = getappdata(hgui,'converted_frames_list');
	converted_frames_dir = getappdata(hgui,'converted_frames_dir');

	%Build the path struct that loadimgsbutton_Callback expects (name = full
	%path, isdir = 0), so the file-selection dialog is skipped.
	clear path
	for k=1:numel(filelist)
		path(k,1).name = filelist{k}; %#ok<AGROW>
		path(k,1).isdir = 0; %#ok<AGROW>
	end

	%Force time-resolved sequencing (only sensible style for video frames).
	sequencer=0;
	gui.put('sequencer',sequencer);
	try
		save('PIVlab_settings_default.mat','sequencer','-append');
	catch
	end

	gui.put('pathname',converted_frames_dir);

	%Our converted frames are always single-image tif files. Reset the
	%multitiff flag so a stale value from a previous multi-tiff session does
	%not mis-sequence them (loadimgsbutton reads it from the GUI on the
	%direct-load path).
	gui.put('multitiff',0);

	%loadimgsbutton_Callback only calls toolsavailable(0) when useGUI==1, but
	%always calls toolsavailable(1) at the end. On our direct-load path
	%(useGUI==0) that would re-apply a stale "wasdisabled" snapshot and leave
	%buttons (e.g. "Import images"/"Import video") disabled. Take a fresh
	%snapshot of the current state so toolsavailable(1) restores it correctly.
	gui.toolsavailable(0);

	%Load the freshly written images through the standard pipeline.
	import.loadimgsbutton_Callback([],[],0,path);
end
