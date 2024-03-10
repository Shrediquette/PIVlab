function gui_set_bg_color_for_mean_imgs(currentframe, handles)
ismean=gui_NameSpace.gui_retr('ismean');
if size(ismean,1)>=(currentframe+1)/2
	if ismean((currentframe+1)/2,1) ==1
		currentwasmean=1;
	else
		currentwasmean=0;
	end
else
	currentwasmean=0;
end

if currentwasmean==1
	set (handles.filenameshow,'BackgroundColor',[0.65 0.65 1]);
else
	set (handles.filenameshow,'BackgroundColor',[0.9412 0.9412 0.9412]);
end
