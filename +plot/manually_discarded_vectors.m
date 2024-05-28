function manually_discarded_vectors(target_axis,handles, x, y)
if strncmp(get(handles.multip06, 'visible'), 'on',2) %validation panel visible
	manualdeletion=gui.gui_retr('manualdeletion');
	frame=floor(get(handles.fileselector, 'value'));
	framemanualdeletion=[];
	if numel(manualdeletion)>0
		if size(manualdeletion,2)>=frame
			if isempty(manualdeletion{1,frame}) ==0
				framemanualdeletion=manualdeletion{frame};
			end
		end
	end
	if isempty(framemanualdeletion)==0
		hold on;
		if str2num(get(handles.masktransp,'String')) < 100
			for i=1:size(framemanualdeletion,1)
				scatter (x(framemanualdeletion(i,1),framemanualdeletion(i,2)),y(framemanualdeletion(i,1),framemanualdeletion(i,2)), 'rx', 'tag','manualdot','parent',target_axis)
			end
		end
		hold off;
	end
end

