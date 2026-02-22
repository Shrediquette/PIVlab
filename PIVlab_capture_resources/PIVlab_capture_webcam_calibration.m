function [OutputError,ima] = PIVlab_capture_webcam_calibration(not_used)
img_amount=inf;
OutputError=0;
hgui=getappdata(0,'hgui');
%% Prepare camera
web_cam=webcam;

%% prapare axis
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
set(gca,'ytick',[])
set(gca,'xtick',[])
colorbar


%% get images
set(frame_nr_display,'String','');
preview(web_cam,image_handle_webcam)
caxis([0 2^8]); %seems to be a workaround to force preview to show full data range...
displayed_img_amount=0;
while getappdata(hgui,'cancel_capture') ~=1 && displayed_img_amount < img_amount
    ima = image_handle_webcam.CData;
    ima_out = ima; 
    
    %% live charuco
    do_charuco_detection = gui.retr('do_charuco_detection');
    if isempty(do_charuco_detection)
        do_charuco_detection=0;
    end
    if do_charuco_detection
        PIVlab_capture_charuco_detector((ima_out),PIVlab_axis,image_handle_webcam);
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


end
closePreview(web_cam)