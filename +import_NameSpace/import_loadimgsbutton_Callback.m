function import_loadimgsbutton_Callback(~,~,useGUI,path)
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[gui_NameSpace.gui_retr('pathname') '\'];
else
	pathname=[gui_NameSpace.gui_retr('pathname') '/'];
end
handles=gui_NameSpace.gui_gethand;
gui_NameSpace.gui_displogo(0)
%remember imagesize of currently loaded images
try
	old_img_size=size(import_NameSpace.import_get_img(1));
catch
	old_img_size=0;
end
if useGUI ==1
	if ispc==1
		try
			path=uipickfiles ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		catch
			path=uipickfiles ('FilterSpec', pwd, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		end
	else
		try
			path=uipickfiles ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		catch
			path=uipickfiles ('FilterSpec', pwd, 'numfiles', [2 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
		end
	end
	gui_NameSpace.gui_put('expected_image_size',[])
end
if ~isequal(path,0)
	cla(gui_NameSpace.gui_retr('pivlab_axis'))
	setappdata(hgui,'video_selection_done',0);
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		gui_NameSpace.gui_zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		gui_NameSpace.gui_panon_Callback(handles.zoomon)
	end
	gui_NameSpace.gui_put('xzoomlimit',[]);
	gui_NameSpace.gui_put('yzoomlimit',[]);
	extract_NameSpace.extract_clear_plot_Callback

	sequencer=gui_NameSpace.gui_retr('sequencer');% 0=time resolved, 1 = pairwise, 2=reference

	% check if filenames end with "A" and "B", if yes: warn the user that he probably wants to use pairwise sequencing and not timeresolved.
	[~,checkname_1,~]=fileparts(path(1).name);
	[~,checkname_2,~]=fileparts(path(2).name);
	if (strcmp(checkname_1(end),'A') || strcmp(checkname_1(end),'a')) && (strcmp(checkname_2(end),'B') || strcmp(checkname_2(end),'b'))
		proposed_sequencing = 1;
	else
		proposed_sequencing = 2;
	end
	if sequencer==0 && proposed_sequencing==1
		ans_w=questdlg(['File name ending "A" and "B" detected. This indicates that you should use the "Pairwise" sequencing style instead of "Time resolved".' newline newline 'Should I fix this for you?'],'Sure?','Yes','No','Yes');
		if strcmp(ans_w,'Yes')
			sequencer=1;
			gui_NameSpace.gui_put('sequencer',sequencer);
			save('PIVlab_settings_default.mat','sequencer','-append');
		end
	end

	if sequencer==1
		for i=1:size(path,1)
			if path(i).isdir == 0 %remove directories from selection
				if exist('filepath','var')==0 %first loop
					filepath{1,1}=path(i).name;
				else
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
				end
			end
		end
	elseif sequencer==0
		for i=1:size(path,1)
			if path(i).isdir == 0 %remove directories from selection
				if exist('filepath','var')==0 %first loop
					filepath{1,1}=path(i).name;
				else
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
				end
			end
		end
	elseif sequencer == 2 % Reference image style
		for i=1:size(path,1)
			if path(i).isdir == 0 %remove directories from selection
				if exist('filepath','var')==0 %first loop
					reference_image_i=i;
					filepath=[];
				else
					filepath{size(filepath,1)+1,1}=path(reference_image_i).name; %#ok<AGROW>
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
				end
			end
		end
	end
	if size(filepath,1) > 1
		if mod(size(filepath,1),2)==1
			cutoff=size(filepath,1);
			filepath(cutoff)=[];
		end
		filename=cell(1);
		for i=1:size(filepath,1)
			if ispc==1
				zeichen=strfind(filepath{i,1},'\');
			else
				zeichen=strfind(filepath{i,1},'/');
			end
			currentpath=filepath{i,1};
			if mod(i,2) == 1
				filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
			else
				filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
			end
		end
		%extract path:
		pathname=currentpath(1:zeichen(1,size(zeichen,2))-1);
		gui_NameSpace.gui_put('pathname',pathname); %last path
		gui_NameSpace.gui_put ('filename',filename); %only for displaying
		gui_NameSpace.gui_put ('filepath',filepath); %full path and filename for analyses
		gui_NameSpace.gui_sliderrange(1)
		set (handles.filenamebox, 'string', filename);
		gui_NameSpace.gui_put ('resultslist', []); %clears old results
		gui_NameSpace.gui_put ('derived',[]);
		gui_NameSpace.gui_put('displaywhat',1);%vectors
		gui_NameSpace.gui_put('ismean',[]);
		gui_NameSpace.gui_put('framemanualdeletion',[]);
		gui_NameSpace.gui_put('manualdeletion',[]);
		gui_NameSpace.gui_put('streamlinesX',[]);
		gui_NameSpace.gui_put('streamlinesY',[]);
		gui_NameSpace.gui_put('bg_img_A',[]);
		gui_NameSpace.gui_put('bg_img_B',[]);
		set(handles.bg_subtract,'Value',0);
		set(handles.fileselector, 'value',1);

		set(handles.minintens, 'string', 0);
		set(handles.maxintens, 'string', 1);

		%Clear all things
		validate_NameSpace.validate_clear_vel_limit_Callback %clear velocity limits
		if old_img_size ~= 0%ROI should be cleared only when image size of loaded imgs is different from before...
			new_img_size=size(import_NameSpace.import_get_img(1));
			if new_img_size(1) ~= old_img_size(1) || new_img_size(2) ~= old_img_size(2)
				roi_NameSpace.roi_clear_roi_Callback
			end
		end

		gui_NameSpace.gui_put('masks_in_frame',[]);

		%reset zoom
		set(handles.panon,'Value',0);
		set(handles.zoomon,'Value',0);
		gui_NameSpace.gui_put('xzoomlimit', []);
		gui_NameSpace.gui_put('yzoomlimit', []);
		%filelistbox auf erste position
		set(handles.filenamebox,'value',1);
		gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis')) %displays raw image when slider moves
		zoom reset
		set(getappdata(0,'hgui'), 'Name',['PIVlab ' gui_NameSpace.gui_retr('PIVver') '   [Path: ' pathname ']']) %for people like me that always forget what dataset they are currently working on...
		set (handles.amount_nans, 'BackgroundColor',[0.9 0.9 0.9])
		set (handles.amount_nans,'string','')
	else
		errordlg('Please select at least two images ( = 1 pair of images)','Error','on')
	end
end
