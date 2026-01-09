function cam_showreproject_Callback(~, ~, ~)
%handles=gui.gethand;
cameraParams = gui.retr('cameraParams');
cam_selected_target_images = gui.retr('cam_selected_target_images');
if ~isempty(cameraParams) && ~isempty (cam_selected_target_images)
    figure('Name','Camera calibration','DockControls','off','WindowStyle','normal','Scrollable','off','MenuBar','none','Resize','on','ToolBar','none','NumberTitle','off');
    tiledlayout(1,2)
    nexttile
    try
    	showExtrinsics(cameraParams)%,'Parent',gui.retr('pivlab_axis'));
    catch
        disp('Could not display fisheye Extrinsics.')
    end
    nexttile
    showReprojectionErrors(cameraParams,'BarGraph');
end