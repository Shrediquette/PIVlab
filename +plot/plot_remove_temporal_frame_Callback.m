function plot_remove_temporal_frame_Callback (~,~,~)
handles=gui.gui_gethand;
filepath=gui.gui_retr('filepath');
filename=gui.gui_retr('filename');
resultslist=gui.gui_retr('resultslist');

if isempty(resultslist)==0
	if size(filepath,1)>0
		sizeerror=0;
		typevectormittel=ones(size(resultslist{1,1}));
		ismean=gui.gui_retr('ismean');
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
			gui.gui_put('filepath',filepath);
			gui.gui_put('filename',filename);
			gui.gui_put('resultslist',resultslist);
			gui.gui_put('ismean',ismean);
			gui.gui_sliderrange(0)
			if get(handles.fileselector,'value')>1
				gui.gui_fileselector_Callback
				set(handles.fileselector, 'value', currentframe-1);
			end
			gui.gui_sliderdisp(gui.gui_retr('pivlab_axis'));
		else
			uiwait(msgbox('You can only delete frames with derived temporal parameters.','Notice','modal'));
		end
	end
end

