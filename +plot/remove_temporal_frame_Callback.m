function remove_temporal_frame_Callback (~,~,~)
handles=gui.gethand;
filepath=gui.retr('filepath');
filename=gui.retr('filename');
resultslist=gui.retr('resultslist');

if isempty(resultslist)==0
	if size(filepath,1)>0
		sizeerror=0;
		typevectormittel=ones(size(resultslist{1,1}));
		ismean=gui.retr('ismean');
		if isempty(ismean)==1
			ismean=zeros(size(resultslist,2),1);
		end
		%dont remove all, but only the current one.
		%probably shift the remaining ones....?
		currentframe=floor(get(handles.fileselector, 'value'));

		if ismean(currentframe,1)==1
			filepath(currentframe*2,:)=[];
			filename(currentframe*2,:)=[];
			filepath(currentframe*2-1,:)=[];
			filename(currentframe*2-1,:)=[];
			resultslist(:,currentframe)=[];
			ismean(currentframe,:)=[];
			gui.put('filepath',filepath);
			gui.put('filename',filename);
			gui.put('resultslist',resultslist);
			gui.put('ismean',ismean);
			gui.sliderrange(0)
			if get(handles.fileselector,'value')>1
				gui.fileselector_Callback
				set(handles.fileselector, 'value', currentframe-1);
			end
			gui.sliderdisp(gui.retr('pivlab_axis'));
		else
			uiwait(msgbox('You can only delete frames with derived temporal parameters.','Notice','modal'));
		end
	end
end

