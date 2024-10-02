function suggest_bright_filter_Callback (~,~,~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame
	%image-based filtering
	set(handles.do_bright_filter, 'value',1);
	%do_contrast_filter=1
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	bright_filter_thresh=str2double(get(handles.bright_filter_thresh, 'String'));
	[A,rawimageA]=import.get_img(selected);
	[B,rawimageB]=import.get_img(selected+1);
	[~,~,threshold_suggestion,~,~] = postproc.PIVlab_image_filter (0,1,x,y,u,v,0,bright_filter_thresh,A,B,rawimageA,rawimageB);
	set(handles.bright_filter_thresh, 'String',num2str(threshold_suggestion));
	[u,v,~,~,~] = postproc.PIVlab_image_filter (0,1,x,y,u,v,0,threshold_suggestion,A,B,rawimageA,rawimageB);
end

