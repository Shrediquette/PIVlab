function extract_save_data_Callback(~, ~, ~)
handles=gui.gui_gethand;
resultslist=gui.gui_retr('resultslist');
currentframe=floor(get(handles.fileselector, 'value'));
if get(handles.extractLineAll, 'value')==0
	startfr=currentframe;
	endfr=currentframe;
else
	startfr=1;
	endfr=size(resultslist,2);
end
selected=0;
for i=startfr:endfr
	%set(handles.fileselector, 'value',i)
	%sliderdisp(retr('pivlab_axis'))
	currentframe=i;%floor(get(handles.fileselector, 'value'));
	if size(resultslist,2)>=currentframe && numel(resultslist{1,currentframe})>0
		delete(findobj('tag', 'derivplotwindow'));
		caller.Tag=i;
		extract.extract_plot_data_Callback(caller) %make sure that data was calculated
		%close figure...
		%delete(findobj('tag', 'derivplotwindow'));
		extractwhat=get(handles.extraction_choice,'Value');
		current=get(handles.extraction_choice,'string');
		current=current{extractwhat};
		if selected==0
			imgsavepath=gui.gui_retr('imgsavepath');
			if isempty(imgsavepath)
				imgsavepath=gui.gui_retr('pathname');
			end
			%find '\', replace with 'per'
			part1= current(1:strfind(current,'/')-1) ;
			part2= current(strfind(current,'/')+1:end);
			if isempty(part1)==1
				currentED=current;
			else
				currentED=[part1 ' per ' part2];
			end
			if get(handles.extractionLine_fileformat,'Value')==1
				[FileName,PathName] = uiputfile('*.xls','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.xls'])); %framenummer in dateiname
			else
				[FileName,PathName] = uiputfile('*.txt','Save extracted data as...',fullfile(imgsavepath,['PIVlab_Extr_' currentED '.txt'])); %framenummer in dateiname
			end
			selected=1;
			gui.gui_toolsavailable(0,'Busy, extracting data...');drawnow
		end
		if isequal(FileName,0) | isequal(PathName,0)
			%exit for
			break;
		else
			gui.gui_put('imgsavepath',PathName);
			pointpos=strfind(FileName, '.');
			pointpos=pointpos(end);
			FileName_final=[FileName(1:pointpos-1) '_' num2str(currentframe) '.' FileName(pointpos+1:end)];
			c=gui.gui_retr('c');
			distance=gui.gui_retr('distance');
			%also retrieve coordinates of polyline points if possible
			cx=gui.gui_retr('cx');
			cy=gui.gui_retr('cy');
			%normal : 300 x 1
			if size(c,2)>1 %circle series
				if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
					header=['circle nr., Distance on line [px], x-coordinate [px], y-coordinate [px], ' current];
				else
					header=['circle nr., Distance on line [m], x-coordinate [m], y-coordinate [m], ' current];
				end
				wholeLOT=[];
				for z=1:size(c,1)
					wholeLOT=[wholeLOT;[linspace(z,z,size(c,2))' distance(z,:)' cx(z,:)' cy(z,:)' c(z,:)']]; %#ok<AGROW> %anders.... untereinander
				end
			else

				if (gui.gui_retr('calu')==1 || gui.gui_retr('calu')==-1) && gui.gui_retr('calxy')==1
					header=['Distance on line [px], x-coordinate [px], y-coordinate [px], ' current];
				else
					header=['Distance on line [m], x-coordinate [m], y-coordinate [m], ' current];
				end
				wholeLOT=[distance cx cy c];
			end
			write_error=0;
			if exist(fullfile(PathName,FileName_final),'file')==2 %file is already there
				try
					delete(fullfile(PathName,FileName_final));
					writecell(strsplit(header,','),fullfile(PathName,FileName_final))
				catch ME
					uiwait(msgbox('No write access to file. Is it currently open somewhere else?','Error','error','modal'))
					write_error=1;
				end
			end
			if write_error==0
				if get(handles.extractionLine_fileformat,'Value')==1
					writecell(strsplit(header,','),fullfile(PathName,FileName_final),'WriteMode','replacefile')
				else
					writecell(strsplit(header,','),fullfile(PathName,FileName_final),'WriteMode','overwrite')
				end
				writematrix(wholeLOT,fullfile(PathName,FileName_final),'WriteMode','Append')
			end
		end
	end
end
gui.gui_toolsavailable(1)
gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'))

