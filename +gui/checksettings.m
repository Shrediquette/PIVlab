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
if get(handles.enable_highpass, 'value')==1
	if isnan(str2double(get(handles.highp_size, 'string')))
		mess{size(mess,2)+1}='Highpass filter size contains NaN';
	end
end
if get(handles.wienerwurst, 'value')==1
	if isnan(str2double(get(handles.wienerwurstsize, 'string')))
		mess{size(mess,2)+1}='Wiener2 filter size contains NaN';
	end
end
%if get(handles.enable_clip, 'value')==1
%    if isnan(str2double(get(handles.clip_thresh, 'string')))==1
%        mess{size(mess,2)+1}='Clipping threshold contains NaN';
%    end
%end
if isnan(str2double(get(handles.intarea, 'string')))
	mess{size(mess,2)+1}='Interrogation area size contains NaN';
end
if isnan(str2double(get(handles.step, 'string')))
	mess{size(mess,2)+1}='Step size contains NaN';
end
if size(mess,2)>0 %error somewhere
    gui.custom_msgbox('warn',getappdata(0,'hgui'),'Error',['Errors found:' mess],'modal');
	ok=0;
else
	ok=1;
end

