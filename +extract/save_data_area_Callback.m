function save_data_area_Callback (~,~,~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if get(handles.extractAreaAll,'Value') == 1
	refresh_data=0;
	startfr=1;
	endfr=size(resultslist,2);
else
	refresh_data=1;
	startfr=currentframe;
	endfr=currentframe;
end
%determine name of output file
current=get(handles.extraction_choice_area,'string');
extractwhat=get(handles.extraction_choice_area,'Value');
current=current{extractwhat};
part1= current(1:strfind(current,'/')-1) ;
part2= current(strfind(current,'/')+1:end);
if isempty(part1)==1
	currentED=current;
else
	currentED=[part1 ' per ' part2];
end
imgsavepath=gui.retr('imgsavepath');
if isempty(imgsavepath)
	imgsavepath=gui.retr('pathname');
end
if get(handles.extractionArea_fileformat,'Value') ==1
	[FileName,PathName] = uiputfile('*.xls','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.xls'])); %framenummer in dateiname
else
	[FileName,PathName] = uiputfile('*.txt','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.txt'])); %framenummer in dateiname
end

if ~isequal(FileName,0) && ~isequal(PathName,0)
	file_selection_ok=1;
	gui.toolsavailable(0,'Busy, extracting data...');drawnow
else
	file_selection_ok=0;
end
if file_selection_ok
	fullpath=fullfile(PathName,FileName);
	write_error=0;
	% Pre-flight: check write access before starting the loop
	if exist(fullpath,'file')==2
		try
			delete(fullpath);
		catch ME
			gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','No write access to file. Is it currently open somewhere else?','modal');
			write_error=1;
		end
	end
	if write_error==0
		num_frames=endfr-startfr+1;
		data_rows=cell(num_frames,1);
		valid_count=0;
		returned_header={};
		cnt=0;
		update_interval=max(1,floor(num_frames/20));
		for i=startfr:endfr
			if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
				[returned_data, returned_header]=extract.plot_data_area(i,refresh_data);
				valid_count=valid_count+1;
				data_rows{valid_count}=returned_data;
			end
			cnt=cnt+1;
			if mod(cnt,update_interval)==0 || cnt==num_frames
				gui.update_progress(round(cnt/num_frames*100))
			end
		end
		if valid_count>0 && ~isempty(returned_header)
			all_data=vertcat(data_rows{1:valid_count});
			if get(handles.extractionArea_fileformat,'Value')==1
				writecell([returned_header; all_data],fullpath,'WriteMode','replacefile');
			else
				writecell([returned_header; all_data],fullpath,'WriteMode','overwrite');
			end
		end
	end
end
gui.update_progress(0)
gui.toolsavailable(1)