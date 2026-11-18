function PIVlab_capture_OPTOcam_capture_error(ME,expected_model)
%PIVlab_capture_OPTOcam_capture_error  The OPTOcam driver threw an error: was the camera swapped for the other model?
%
%   PIVlab_capture_OPTOcam_capture_error(ME,expected_model)   (in a catch block around an OPTOcam driver call)
%
%   If the other OPTOcam model is connected now, the GUI is switched to it (PIVlab_capture_OPTOcam_model_changed)
%   and this function returns normally, so the caller can end the capture as after any failed start.
%   Otherwise the original error is thrown again: real errors stay visible.
if ~PIVlab_capture_OPTOcam_model_changed(expected_model)
	rethrow(ME)
end
disp(['OPTOcam driver error (camera model changed): ' ME.message])
