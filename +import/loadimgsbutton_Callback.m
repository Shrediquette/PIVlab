function loadimgsbutton_Callback(~,~,useGUI,path)
hgui=getappdata(0,'hgui');
if ispc==1
	pathname=[gui.retr('pathname') '\'];
else
	pathname=[gui.retr('pathname') '/'];
end
handles=gui.gethand;
gui.displogo(0)
batchModeActive=gui.retr('batchModeActive');
if isempty (batchModeActive)
	batchModeActive = 0;
end
%remember imagesize of currently loaded images
try
    old_img_size=size(import.get_img(1));
catch
    old_img_size=0;
end
if useGUI ==1
    if ~verLessThan('matlab','25')
        if ispc==1
            try
                [path, multitiff]=gui.uipickfiles ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            catch
                [path, multitiff]=gui.uipickfiles ('FilterSpec', pwd, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            end
        else
            try
                [path, multitiff]=gui.uipickfiles ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            catch
                [path, multitiff]=gui.uipickfiles ('FilterSpec', pwd, 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            end
        end
    else
        if ispc==1
            try
                [path, multitiff]=gui.uipickfiles_pre_2025 ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            catch
                [path, multitiff]=gui.uipickfiles_pre_2025 ('FilterSpec', pwd, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            end
        else
            try
                [path, multitiff]=gui.uipickfiles_pre_2025 ('FilterSpec', pathname, 'REFilter', '\.bmp$|\.jpg$|\.png$|\.tif$|\.jpeg$|\.tiff$|\.b16$', 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            catch
                [path, multitiff]=gui.uipickfiles_pre_2025 ('FilterSpec', pwd, 'numfiles', [1 inf], 'output', 'struct', 'prompt', 'Select images. Images from one set should have identical dimensions to avoid problems.');
            end
        end
    end
    gui.put('expected_image_size',[])
end

if ~isequal(path,0)
    %remove directories from list
    for kk=size(path,1):-1:1
		if path(kk).isdir == 1
			path(kk)=[];
		end
	end

	cla(gui.retr('pivlab_axis'))
	setappdata(hgui,'video_selection_done',0);
	if get(handles.zoomon,'Value')==1
		set(handles.zoomon,'Value',0);
		gui.zoomon_Callback(handles.zoomon)
	end
	if get(handles.panon,'Value')==1
		set(handles.panon,'Value',0);
		gui.panon_Callback(handles.zoomon)
	end
	gui.put('xzoomlimit',[]);
	gui.put('yzoomlimit',[]);
	extract.clear_plot_Callback

	sequencer=gui.retr('sequencer');% 0=time resolved, 1 = pairwise, 2=reference
	if exist('multitiff','var') && ~isempty(multitiff)
		gui.put('multitiff',multitiff); %save in GUI if user opened a multitiff file.
	else
		multitiff=gui.retr('multitiff');
	end

	% check if filenames end with "A" and "B", if yes: warn the user that he probably wants to use pairwise sequencing and not timeresolved.
	if size(path,1) > 1 && multitiff == 0
		[~,checkname_1,~]=fileparts(path(1).name);
		[~,checkname_2,~]=fileparts(path(2).name);
		if (strcmp(checkname_1(end),'A') || strcmp(checkname_1(end),'a')) && (strcmp(checkname_2(end),'B') || strcmp(checkname_2(end),'b'))
			proposed_sequencing = 1;
		else
			proposed_sequencing = 2;
		end
		if sequencer==0 && proposed_sequencing==1 && ~batchModeActive
			ans_w = gui.custom_msgbox('quest',getappdata(0,'hgui'),'Sure?',['File name ending "A" and "B" detected. This indicates that you should use the "Pairwise" sequencing style instead of "Time resolved".' newline newline 'Should I fix this for you?'],'modal',{'Yes','No'},'Yes');
			if strcmp(ans_w,'Yes')
				sequencer=1;
				gui.put('sequencer',sequencer);
				save('PIVlab_settings_default.mat','sequencer','-append');
			end
		end
	end

	pcopanda_dbl_image=0;
	if multitiff 	 %check if frames captured by pco panda as double image array.
		temp_info=imfinfo(path(1).name);
		if isfield(temp_info,'Software')
			if strcmp (temp_info(1).Software,'PCO_Recorder')
				pcopanda_dbl_image=1;
			end
		end

		if pcopanda_dbl_image==1 && sequencer ~=1
			if ~batchModeActive
                gui.custom_msgbox('success',getappdata(0,'hgui'),'Double image multi-tiff file',['Detected a pco.panda generated double image multi-tiff file.' newline newline 'Sequencing style was changed to "pairwise" to account for the double images.'],'modal');
			end
			sequencer=1;
			gui.put('sequencer',sequencer);
			save('PIVlab_settings_default.mat','sequencer','-append');
		end
	end
	gui.put('pcopanda_dbl_image',pcopanda_dbl_image);

	if multitiff
		frames_per_image_file=zeros(size(path,1),1);
		for jj=1:size(path,1)
			frames_per_image_file(jj)=size(imfinfo(path(jj).name),1);
		end
		loopcntr=sum(frames_per_image_file);
	else % single image files.
		loopcntr=size(path,1);
	end

	if sequencer==1 % AB
		if ~multitiff
			for i=1:loopcntr
				if exist('filepath','var')==0 %first loop
					filepath{1,1}=path(i).name;
					framenum(1,1)=1;
				else
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
					framenum(size(framenum,1)+1,1)=1;
				end
			end
		else % multitiff
			if ~pcopanda_dbl_image

				filepath=cell(0);
				framenum=[];
				cntr=1;
				for i=1:size(path,1)
					for jj=1:frames_per_image_file(i)
						filepath{cntr,1}=path(i).name;
						framenum(cntr,1)=jj;
						cntr=cntr+1;
					end
				end
			else
				filepath=cell(0);
				framenum=[];
				framepart=[];
				cntr=1;
				img_height=size(imread(path(1).name,1),1); %read one file to detect image height to devide it by two later.
				for i=1:size(path,1)
					for jj=1:frames_per_image_file(i)
						filepath{cntr,1}=path(i).name;
						filepath{cntr+1,1}=path(i).name;
						framenum(cntr,1)=jj;
						framenum(cntr+1,1)=jj;
						framepart(cntr,1)=1;
						framepart(cntr,2)=img_height/2;
						framepart(cntr+1,1)=img_height/2+1;
						framepart(cntr+1,2)=img_height;
						cntr=cntr+2;
					end
				end
			end
		end
	elseif sequencer==0 %time-resolved
		if ~multitiff
			for i=1:loopcntr
				if exist('filepath','var')==0 %first loop
					filepath{1,1}=path(i).name;
					framenum(1,1)=1;
				else
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
					framenum(size(framenum,1)+1,1)=1;
					framenum(size(framenum,1)+1,1)=1;
				end
			end
		else % multitiff
			filepath=cell(0);
			framenum=[];
			cntr=1;
			for i=1:size(path,1)
				for jj=1:frames_per_image_file(i)
					if jj == 1 || jj== frames_per_image_file
						filepath{cntr,1}=path(i).name;
						framenum(cntr,1)=jj;
						cntr=cntr+1;
					else
						filepath{cntr,1}=path(i).name;
						filepath{cntr+1,1}=path(i).name;
						framenum(cntr,1)=jj;
						framenum(cntr+1,1)=jj;
						cntr=cntr+2;
					end
				end
			end
		end
	elseif sequencer == 2 % Reference image style
		if ~multitiff
			for i=1:loopcntr
				if exist('filepath','var')==0 %first loop
					reference_image_i=i;
					filepath=[];
					framenum=[];
				else
					filepath{size(filepath,1)+1,1}=path(reference_image_i).name; %#ok<AGROW>
					filepath{size(filepath,1)+1,1}=path(i).name; %#ok<AGROW>
					framenum(size(framenum,1)+1,1)=1;
					framenum(size(framenum,1)+1,1)=1;
				end
			end
		else %multitiff
			filepath=cell(0);
			framenum=[];
			cntr=1;
			for i=1:size(path,1)
				for jj=1:frames_per_image_file(i)
					filepath{cntr,1}=path(1).name;
					filepath{cntr+1,1}=path(i).name;
					framenum(cntr,1)=1;
					framenum(cntr+1,1)=jj;
					cntr=cntr+2;
				end
			end
		end
	end

	if ~pcopanda_dbl_image %for non pco files, we also generate this list which tells us which pixels to load from the image file
		[~,~,ext] = fileparts(path(1).name);
		if strcmpi(ext,'.tif') || strcmpi(ext,'.tiff') %for a tiff file, imread accepts a layer index as additional argument, for other files not, WTF!!!
			img_height=size(imread(path(1).name,1),1);
        else
            if ~strcmpi(ext,'.b16')
    			img_height=size(imread(path(1).name),1);
            else
                img_height=size(import.f_readB16(path(1).name),1);
            end
		end
		framepart(1,1)=1;
		framepart(1,2)=img_height;
		framepart=repmat(framepart,[size(filepath,1),1]);
	end

	%% Make error reporting for sequencing easier.
	if numel(framenum) ~= numel(filepath)
		disp('Error during sequencing.')
		disp('Please send this debug file to William:')
		disp([pwd filesep 'sequencing_error_report.mat'])
		comp_info = computer;
		matlab_info=ver;
		myVarList=who;
		for indVar = 1:length(myVarList)
			assignin('base',myVarList{indVar},eval(myVarList{indVar}))
		end
		save sequencing_error_report.mat;
		if ~isdeployed
			commandwindow
		end
	end

	if loopcntr >= 1
		if size(filepath,1) >1 && mod(size(filepath,1),2)==1
			cutoff=size(filepath,1);
			filepath(cutoff)=[];
			framenum(cutoff)=[];
			framepart(cutoff,:)=[];
		end
		filename=cell(1);
		for i=1:size(filepath,1)
			if ispc==1
				zeichen=strfind(filepath{i,1},'\');
			else
				zeichen=strfind(filepath{i,1},'/');
			end
			currentpath=filepath{i,1};
			if ~multitiff
				if mod(i,2) == 1
					filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
				else
					filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end)];
				end
			else
				if mod(i,2) == 1
					filename{i,1}=['A: ' currentpath(zeichen(1,size(zeichen,2))+1:end) ', layer: ' num2str(framenum(i))];
				else
					filename{i,1}=['B: ' currentpath(zeichen(1,size(zeichen,2))+1:end) ', layer: ' num2str(framenum(i))];
				end
			end
		end
		
		if size(framepart,1)>=2 %check if enough images loaded
		%extract path:
		pathname=currentpath(1:zeichen(1,size(zeichen,2))-1);
		gui.put ('pathname',pathname); %last path
		gui.put ('filename',filename); %only for displaying
		gui.put ('filepath',filepath); %full path and filename for analyses
		gui.put ('framenum',framenum); %important layer information for multi tiffs.
		gui.put ('framepart',framepart); %Only needed for pco panda multi-frame tiffs.
		gui.sliderrange(1)
		set (handles.filenamebox, 'string', filename);
		gui.put ('resultslist', []); %clears old results
		gui.put ('derived',[]);
		gui.put('displaywhat',1);%vectors
		gui.put('ismean',[]);
		gui.put('framemanualdeletion',[]);
		gui.put('manualdeletion',[]);
		gui.put('streamlinesX',[]);
		gui.put('streamlinesY',[]);
		gui.put('bg_img_A',[]);
		gui.put('bg_img_B',[]);
		set(handles.bg_subtract,'Value',1);
		set(handles.fileselector, 'value',1);

		set(handles.minintens, 'string', 0);
		set(handles.maxintens, 'string', 1);

		%Clear all things
		validate.clear_vel_limit_Callback([],[]) %clear velocity limits
		if old_img_size ~= 0%ROI should be cleared only when image size of loaded imgs is different from before...
			new_img_size=size(import.get_img(1));
			if new_img_size(1) ~= old_img_size(1) || new_img_size(2) ~= old_img_size(2)
				roi.clear_roi_Callback
			end
		end

		gui.put('masks_in_frame',[]);

		%reset zoom
		set(handles.panon,'Value',0);
		set(handles.zoomon,'Value',0);
		gui.put('xzoomlimit', []);
		gui.put('yzoomlimit', []);
		%filelistbox auf erste position
		set(handles.filenamebox,'value',1);
		gui.sliderdisp(gui.retr('pivlab_axis')) %displays raw image when slider moves
		zoom reset
		
		if ~isdeployed
			appname='PIVlab';
		else
			appname='PIVlab standalone';
		end
        set(getappdata(0,'hgui'), 'Name',[appname ' ' gui.retr('PIVver') '   [Path: ' pathname ']']) %for people like me that always forget what dataset they are currently working on...
        set (handles.amount_nans, 'BackgroundColor',[0.9 0.9 0.9])
        set (handles.amount_nans,'string','')
        set (handles.remove_imgs,'enable','on');
        else
            gui.displogo(0)
            gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Selection must contain at least two images ( = 1 pair of images)','modal');
        end
    else
        gui.displogo(0)
        gui.custom_msgbox('error',getappdata(0,'hgui'),'Error','Selection must contain at least two images ( = 1 pair of images)','modal');
    end
end