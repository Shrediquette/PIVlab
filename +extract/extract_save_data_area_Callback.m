function extract_save_data_area_Callback (~,~,~)
handles=gui.gui_gethand;
resultslist=gui.gui_retr('resultslist');
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
imgsavepath=gui.gui_retr('imgsavepath');
if isempty(imgsavepath)
	imgsavepath=gui.gui_retr('pathname');
end
if get(handles.extractionArea_fileformat,'Value') ==1
	[FileName,PathName] = uiputfile('*.xls','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.xls'])); %framenummer in dateiname
else
	[FileName,PathName] = uiputfile('*.txt','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.txt'])); %framenummer in dateiname
end

if ~isequal(FileName,0) && ~isequal(PathName,0)
	file_selection_ok=1;
	gui.gui_toolsavailable(0,'Busy, extracting data...');drawnow
else
	file_selection_ok=0;
end
if file_selection_ok
	write_error=0;
	cnt=0;
	for i=startfr:endfr
		if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
			[returned_data, returned_header]=extract.extract_plot_data_area(i,refresh_data);
			if i==startfr %generate file with header
				if exist(fullfile(PathName,FileName),'file')==2 %file is already there
					try
						delete(fullfile(PathName,FileName));
						writecell(returned_header,fullfile(PathName,FileName)); %initiate file
					catch ME
						msgbox('No write access to file. Is it currently open somewhere else?','Error','error','modal')
						write_error=1;
					end
				end
				if write_error==0
					if get(handles.extractionArea_fileformat,'Value') ==1
						writecell(returned_header,fullfile(PathName,FileName),'WriteMode','replacefile'); %initiate file
					else
						writecell(returned_header,fullfile(PathName,FileName),'WriteMode','overwrite'); %initiate file
					end
				end
			end
			if write_error==0
				writecell(returned_data,fullfile(PathName,FileName),'WriteMode','Append');
			end
		end
		cnt=cnt+1;
		gui.gui_update_progress(round(cnt/(endfr-startfr+1)*100))
	end
end
gui.gui_update_progress(0)
gui.gui_toolsavailable(1)