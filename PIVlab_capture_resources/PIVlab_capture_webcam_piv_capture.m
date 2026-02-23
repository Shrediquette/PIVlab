function [OutputError,frame_nr_display] = PIVlab_capture_webcam_piv_capture(img_amount,ImagePath)
OutputError=0;
hgui=getappdata(0,'hgui');
%% Prepare camera
web_cam=webcam;
%% prepare axis
A=web_cam.snapshot;
crosshair_enabled = getappdata(hgui,'crosshair_enabled');
sharpness_enabled = getappdata(hgui,'sharpness_enabled');
PIVlab_axis = findobj(hgui,'Type','Axes');
image_handle_webcam=imagesc(zeros(size(A,1),size(A,2)),'Parent',PIVlab_axis,[0 2^8]);
setappdata(hgui,'image_handle_webcam',image_handle_webcam);
frame_nr_display=text(100,100,'Initializing...','Color',[1 1 0]);
colormap default %reset colormap steps
new_map=colormap('gray');
new_map(1:3,:)=[0 0.2 0;0 0.2 0;0 0.2 0];
new_map(end-2:end,:)=[1 0.7 0.7;1 0.7 0.7;1 0.7 0.7];
colormap(new_map);axis image;
set(gui.retr('pivlab_axis'),'ytick',[])
set(gui.retr('pivlab_axis'),'xtick',[])
colorbar

%% get images
set(frame_nr_display,'String','');
%preview(web_cam,image_handle_webcam)
caxis([0 2^8]); %seems to be a workaround to force preview to show full data range...
displayed_img_amount=0;
captured_amount=0;
while getappdata(hgui,'cancel_capture') ~=1 && captured_amount < img_amount
	imgA=web_cam.snapshot;
	pause(0.05)
	imgB=web_cam.snapshot;
	pause(0.2)
	ima = imgA;
	image_handle_webcam.CData = imgA;
	drawnow limitrate
	if ~isinf(img_amount)
		set(frame_nr_display,'String',['Image nr.: ' int2str(round(captured_amount))]);
		imgA_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',captured_amount) '_A.tif']);
		imgB_path=fullfile(ImagePath,['PIVlab_' sprintf('%4.4d',captured_amount) '_B.tif']);
		imwrite(rgb2gray(imgA),imgA_path,'compression','none'); %tif file saving seems to be the fastest method for saving data...
		imwrite(rgb2gray(imgB),imgB_path,'compression','none');
	else
		set(frame_nr_display,'String','PIV preview');
	end
	%% sharpness indicator
	sharpness_enabled = getappdata(hgui,'sharpness_enabled');
	if sharpness_enabled == 1 % sharpness indicator
		[~,~] = PIVlab_capture_sharpness_indicator (ima,1);
	else
		delete(findobj('tag','sharpness_display_text'));
	end
	crosshair_enabled = getappdata(hgui,'crosshair_enabled');
	if crosshair_enabled == 1 %cross-hair
		%% cross-hair
		locations=[0.15 0.5 0.85];
		half_thickness=1;
		brightness_incr=101;
		ima_ed=ima;
		old_max=max(ima(:));
		for loca=locations
			%vertical
			ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)=ima_ed(:,round(size(ima,2)*loca)-half_thickness:round(size(ima,2)*loca)+half_thickness)+brightness_incr;
			%horizontal
			ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)=ima_ed(round(size(ima,1)*loca)-half_thickness:round(size(ima,1)*loca)+half_thickness,:)+brightness_incr;
		end
		ima_ed(ima_ed>old_max)=old_max;
		set(image_handle_webcam,'CData',ima_ed);
	end
	%% HISTOGRAM
	if getappdata(hgui,'hist_enabled')==1
		if isvalid(image_handle_webcam)
			hist_fig=findobj('tag','hist_fig');
			if isempty(hist_fig)
				hist_fig=figure('numbertitle','off','MenuBar','none','DockControls','off','Name','Live histogram','Toolbar','none','tag','hist_fig','CloseRequestFcn', @HistWindow_CloseRequestFcn);
			end
			if ~exist ('old_hist_y_limits','var')
				old_hist_y_limits =[0 35000];
			else
				if isvalid(hist_obj)
					old_hist_y_limits=get(hist_obj.Parent,'YLim');
				end
			end
			hist_obj=histogram(ima(1:2:end,1:2:end),'Parent',hist_fig,'binlimits',[0 2^12]);
		end
		%lowpass hist y limits for better visibility
		if ~exist ('new_hist_y_limits','var')
			new_hist_y_limits =[0 35000];
		end
		new_hist_y_limits=get(hist_obj.Parent,'YLim');
		set(hist_obj.Parent,'YLim',(new_hist_y_limits*0.5 + old_hist_y_limits*0.5))
	else
		hist_fig=findobj('tag','hist_fig');
		if ~isempty(hist_fig)
			close(hist_fig)
		end
	end
	drawnow limitrate;
	if img_amount == 1
		if sum(ima(1:10,1,1)) ~=10 %check if the display was updated, if there is real camera data. I didnt find a more elegant way...
			displayed_img_amount=displayed_img_amount+1;
		end
	end
	captured_amount=captured_amount+1;
end
set(frame_nr_display,'String','Getting image data to GUI');