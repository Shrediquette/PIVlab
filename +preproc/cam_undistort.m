function img_out = cam_undistort(img_in,method,view,cam_use_calibration,cam_use_rectification,cameraParams,rectification_tform)
%tic
if cam_use_calibration
    if strcmpi (class(cameraParams),'cameraParameters')
        %disp(['Size of the incoming image to cam_undistort: ' num2str(size(img_in))])
        %disp(['Size of the camera params: ' num2str(cameraParams.ImageSize)]);
        img_out = undistortImage(img_in,cameraParams,method,'OutputView',view);
        %disp(['Size of the outgoing image from cam_undistort: ' num2str(size(img_out))])
    elseif strcmpi (class(cameraParams),'fisheyeParameters')
        %disp(['Size of the incoming image to cam_undistort: ' num2str(size(img_in))])
        %disp(['Size of the camera params: ' num2str(cameraParams.Intrinsics.ImageSize)]);
        %disp('calibrated with:')
        %cameraParams.Intrinsics.ImageSize
        %disp('Input image:')
        %size(img_in)
        try
            img_out = undistortFisheyeImage(img_in,cameraParams.Intrinsics,method,'OutputView',view,'ScaleFactor',2);
        catch ME
            gui.toolsavailable(1)
            gui.custom_msgbox('error',getappdata(0,'hgui'),'Error',ME.message,'modal');
            img_out=img_in;
            return
        end
        %disp(['Size of the outgoing image from cam_undistort: ' num2str(size(img_out))])
    end
    if cam_use_rectification
        img_out = imwarp(img_out,rectification_tform);
        %disp(['Size of the outgoing image from rectify: ' num2str(size(img_out))])
    end
else
    img_out=img_in;
end
%toc