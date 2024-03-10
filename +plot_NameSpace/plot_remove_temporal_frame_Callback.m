function plot_remove_temporal_frame_Callback (~,~,~)
handles=gui_NameSpace.gui_gethand;
filepath=gui_NameSpace.gui_retr('filepath');
filename=gui_NameSpace.gui_retr('filename');
resultslist=gui_NameSpace.gui_retr('resultslist');

if isempty(resultslist)==0
	if size(filepath,1)>0
		sizeerror=0;
		typevectormittel=ones(size(resultslist{1,1}));
		ismean=gui_NameSpace.gui_retr('ismean');
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
			gui_NameSpace.gui_put('filepath',filepath);
			gui_NameSpace.gui_put('filename',filename);
			gui_NameSpace.gui_put('resultslist',resultslist);
			gui_NameSpace.gui_put('ismean',ismean);
			gui_NameSpace.gui_sliderrange(0)
			if get(handles.fileselector,'value')>1
				gui_NameSpace.gui_fileselector_Callback
				set(handles.fileselector, 'value', currentframe-1);
			end
			gui_NameSpace.gui_sliderdisp(gui_NameSpace.gui_retr('pivlab_axis'));
		else
			uiwait(msgbox('You can only delete frames with derived temporal parameters.','Notice','modal'));
		end
	end
end
