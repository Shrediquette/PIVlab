function autothresh_Callback(~, ~, ~)
ok=gui.checksettings;
if ok==1
	handles=gui.gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	ismean=gui.retr('ismean');
	if size(ismean,1)>=(selected+1)/2
		if ismean((selected+1)/2,1) ==1
			currentwasmean=1;
		else
			currentwasmean=0;
		end
	else
		currentwasmean=0;
	end
	if currentwasmean==0
		tic;
		[image1,~]=import.get_img(selected);

		clahe=get(handles.clahe_enable,'value');
		highp=get(handles.enable_highpass,'value');
		%clip=get(handles.enable_clip,'value');
		intenscap=get(handles.enable_intenscap, 'value');
		clahesize=str2double(get(handles.clahe_size, 'string'));
		highpsize=str2double(get(handles.highp_size, 'string'));
		wienerwurst=get(handles.wienerwurst, 'value');
		wienerwurstsize=str2double(get(handles.wienerwurstsize, 'string'));
		preproc.Autolimit_Callback
		minintens=str2double(get(handles.minintens, 'string'));
		maxintens=str2double(get(handles.maxintens, 'string'));
		%clipthresh=str2double(get(handles.clip_thresh, 'string'));
		roirect=gui.retr('roirect');
		if get(handles.Autolimit, 'value') == 1 %if autolimit is desired: do autolimit for each image seperately
			if size(image1,3)>1
				stretcher = stretchlim(rgb2gray(image1));
			else
				stretcher = stretchlim(image1);
			end
			minintens = stretcher(1);
			maxintens = stretcher(2);
		end
		image1 = preproc.PIVlab_preproc (image1,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens);
			
		current_mask_nr=floor(get(handles.fileselector, 'value'));
		masks_in_frame=gui.retr('masks_in_frame');
		if isempty(masks_in_frame)
			%masks_in_frame=cell(current_mask_nr,1);
			masks_in_frame=cell(1,current_mask_nr);
		end
		if numel(masks_in_frame)<current_mask_nr
			mask_positions=cell(0);
		else
			mask_positions=masks_in_frame{current_mask_nr};
		end
		
	end
	%find binarization threshold
	autothresh = graythresh(image1);
	set(handles.psv_threshold,'String',num2str(autothresh))
end

