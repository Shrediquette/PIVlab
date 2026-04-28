function cam_show_cam_position_Callback(~, ~, ~)
%handles=gui.gethand;
cameraParams = gui.retr('cameraParams');
cam_selected_target_images = gui.retr('cam_selected_target_images');
if ~isempty(cameraParams) && ~isempty (cam_selected_target_images)
    fig=figure('Name','Camera positions','DockControls','off','WindowStyle','normal','Scrollable','off','ToolBar','none','MenuBar','none','Resize','on','NumberTitle','off');
    opencv.showExtrinsicsOpenCV(cameraParams,fig)
    cameratoolbar(fig,'Show'); % Show the toolbar
    cameratoolbar(fig,"SetCoordSys","y")
    cameratoolbar(fig,"SetMode","orbit")
end