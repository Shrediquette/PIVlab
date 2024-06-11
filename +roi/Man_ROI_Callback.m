function Man_ROI_Callback(~,~,~)
handles=gui.gethand;
filepath=gui.retr('filepath');
if size(filepath,1) >1 || gui.retr('video_selection_done') == 1
	try
		x=round(str2num(get(handles.ROI_Man_x,'String')));
		y=round(str2num(get(handles.ROI_Man_y,'String')));
		w=round(str2num(get(handles.ROI_Man_w,'String')));
		h=round(str2num(get(handles.ROI_Man_h,'String')));
	catch
	end
	if isempty(x)== 0 && isempty(y)== 0 && isempty(w)== 0 && isempty(h)== 0 && isnumeric(x) && isnumeric(y) && isnumeric(w) && isnumeric(h)
		roirect(1)=x;
		roirect(2)=y;
		roirect(3)=w;
		roirect(4)=h;
		imagesize=gui.retr('expected_image_size');
		if roirect(1)<1
			roirect(1)=1;
		end
		if roirect(2)<1
			roirect(2)=1;
		end
		if roirect(3)>imagesize(2)-roirect(1)
			roirect(3)=imagesize(2)-roirect(1);
		end
		if roirect(4)>imagesize(1)-roirect(2)
			roirect(4)=imagesize(1)-roirect(2);
		end
		gui.put ('roirect',roirect);
		roi.select_Callback
	end
end

