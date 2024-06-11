function suggest_contrast_filter_Callback (~,~,~)
handles=gui.gethand;
resultslist=gui.retr('resultslist');
frame=floor(get(handles.fileselector, 'value'));
if size(resultslist,2)>=frame
	%image-based filtering
	set(handles.do_contrast_filter, 'value',1);
	%do_contrast_filter=1
	selected=2*floor(get(handles.fileselector, 'value'))-1;
	x=resultslist{1,frame};
	y=resultslist{2,frame};
	u=resultslist{3,frame};
	v=resultslist{4,frame};
	contrast_filter_thresh=str2double(get(handles.contrast_filter_thresh, 'String'));
	[A,rawimageA]=import.get_img(selected);
	[B,rawimageB]=import.get_img(selected+1);
	[~,~,threshold_suggestion,~,~] = PIVlab_image_filter (1,0,x,y,u,v,contrast_filter_thresh,0,A,B,rawimageA,rawimageB);
	set(handles.contrast_filter_thresh, 'String',num2str(threshold_suggestion));
	[u,v,~,~,~] = PIVlab_image_filter (1,0,x,y,u,v,threshold_suggestion,0,A,B,rawimageA,rawimageB);
end

