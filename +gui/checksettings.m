function ok=checksettings
handles=gui.gethand;
mess={};
filepath=gui.retr('filepath');
if size(filepath,1) <2 && gui.retr('video_selection_done') == 0
	mess{size(mess,2)+1}='No images were loaded';
end
if get(handles.clahe_enable, 'value')==1
	if isnan(str2double(get(handles.clahe_size, 'string')))
		mess{size(mess,2)+1}='CLAHE window size contains NaN';
	end
end
if get(handles.highpass_enable, 'value')==1
	if isnan(str2double(get(handles.highpass_size, 'string')))
		mess{size(mess,2)+1}='Highpass filter size contains NaN';
	end
end
if get(handles.wiener_enable, 'value')==1
	if isnan(str2double(get(handles.wiener_size, 'string')))
		mess{size(mess,2)+1}='Wiener2 filter size contains NaN';
	end
end
%if get(handles.enable_clip, 'value')==1
%    if isnan(str2double(get(handles.clip_thresh, 'string')))==1
%        mess{size(mess,2)+1}='Clipping threshold contains NaN';
%    end
%end
if isnan(str2double(get(handles.pass1_size, 'string')))
	mess{size(mess,2)+1}='Interrogation area size contains NaN';
end
if isnan(str2double(get(handles.pass1_step, 'string')))
	mess{size(mess,2)+1}='Step size contains NaN';
end
%the analysed area must hold the interrogation area, with several passes one step more (two vectors
%in each direction for the interpolation between the passes); same rule as in piv.piv_FFTmulti
ia=str2double(get(handles.pass1_size, 'string'));
step=str2double(get(handles.pass1_step, 'string'));
roirect=gui.retr('roirect');
if ~isempty(roirect)
	area_size=[roirect(3)+1 roirect(4)+1]; %the ROI includes its last pixel
else
	image_size=gui.retr('expected_image_size');
	area_size=[];
	if ~isempty(image_size)
		area_size=[image_size(2) image_size(1)];
	end
end
algorithm=get(handles.algorithm_selection,'Value'); %1 fft, 2 ensemble, 3 dcc, 4 optical flow
if ~isnan(ia) && ~isnan(step) && ~isempty(area_size) && algorithm~=4
	min_size=ia;
	if algorithm~=3 && get(handles.pass2_enable,'value')==1
		min_size=ia+step;
	end
	if min(area_size) < min_size
		mess{size(mess,2)+1}=sprintf(['The analysed area (%d x %d px) is too small for an interrogation area of %d px: ' ...
			'at least %d x %d px are needed. Use a smaller interrogation area or a larger ROI.'], ...
			area_size(1), area_size(2), ia, min_size, min_size);
	end
end
if size(mess,2)>0 %error somewhere
    gui.custom_msgbox('warn',getappdata(0,'hgui'),'Error',['Errors found:' mess],'modal');
	ok=0;
else
	ok=1;
end

