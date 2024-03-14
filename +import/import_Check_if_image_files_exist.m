function filepath = import_Check_if_image_files_exist(filepath, selected)
%if the images are not found on the current path, then let user choose new path
%not found: assign new path to all following elements.
%check next file. not found -> assign new path to all following.
%and so on...
if isempty(filepath) == 0 && exist(filepath{selected},'file') ~=2
	for i=1:size(filepath,1)
		while exist(filepath{i,1},'file') ~=2
			errordlg(['The image ' sprintf('\n') filepath{i,1} sprintf('\n') '(and probably some more...) could not be found.' sprintf('\n') 'Please select the path where the images are located.'],'File not found!','on')
			uiwait
			new_dir = uigetdir(pwd,'Please specify the path to all the images');
			if new_dir==0
				break
			else
				for j=i:size(filepath,1) %apply new path to all following imgs.
					if ispc==1
						zeichen=strfind(filepath{j,1},'\');
					else
						zeichen=strfind(filepath{j,1},'/');
					end
					currentobject=filepath{j,1};
					currentpath=currentobject(1:(zeichen(1,size(zeichen,2))));
					currentfile=currentobject(zeichen(1,size(zeichen,2))+1:end);
					if ispc==1
						filepath{j,1}=[new_dir '\' currentfile];
					else
						filepath{j,1}=[new_dir '/' currentfile];
					end
				end
			end
			gui.gui_put('filepath',filepath);
		end
		if new_dir==0
			break
		end
	end
	if gui.gui_retr('video_selection_done') == 1 %create new video object with the updated file location.
		gui.gui_put('video_reader_object',VideoReader(filepath{1}));
	end
end

