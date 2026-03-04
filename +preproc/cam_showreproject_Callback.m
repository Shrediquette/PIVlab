function cam_showreproject_Callback(~, ~, ~)
cameraParams = gui.retr('cameraParams');
cameraStats  = gui.retr('cameraStats');
cam_selected_target_images = gui.retr('cam_selected_target_images');
if ~isempty(cameraParams) && ~isempty(cam_selected_target_images)
    figure('Name','Reprojection error','DockControls','off','WindowStyle','normal',...
        'Scrollable','off','ToolBar','none','MenuBar','none','Resize','on','NumberTitle','off');
    err = cameraStats.ReprojectionErrors;
    %% Error
    errNorm = sqrt(err(:,1,:).^2 + err(:,2,:).^2);
    %% mean per image
    barErr = squeeze(mean(errNorm,1,'omitnan'));
    bar(barErr)
    hold on
    %% global mean
    meanErr = mean(errNorm(:),'omitnan');
    yline(meanErr,'--r','LineWidth',1.5);
    xlabel("Image number")
    ylabel("Mean reprojection error (pixels)")
    title("Reprojection Errors")
    grid on
end