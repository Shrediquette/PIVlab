function [OutputError,camera_sub_type] = PIVlab_capture_OPTRONIS_unified_cam_detect(~)
% Unified camera detector — tries the GenTL grabber first, falls back to
% BitFlow. Appends '-bitflow' to the sub_type when the BitFlow adapter is
% used so that all downstream dispatch code can route accordingly.
OutputError = 0;
camera_sub_type = 'unknown';

warning off
hwinf = imaqhwinfo;
warning on
warning('off','imaq:gentl:noSupportedPixelFormat')

has_gentl   = any(strcmp(hwinf.InstalledAdaptors, 'gentl'));
has_bitflow = any(strcmp(hwinf.InstalledAdaptors, 'bitflow'));

if has_gentl
    try
        [OutputError, camera_sub_type] = PIVlab_capture_OPTRONIS_cam_detect();
        if ~strcmp(camera_sub_type, 'unknown') && ~isempty(strtrim(camera_sub_type))
            disp(['Detected via GenTL: ' camera_sub_type])
            return
        end
    catch
    end
end

if has_bitflow
    try
        [OutputError, sub] = PIVlab_capture_OPTRONIS_bitflow_cam_detect();
        if ~strcmp(sub, 'unknown') && ~isempty(strtrim(sub))
            camera_sub_type = [sub '-bitflow'];
            disp(['Detected via BitFlow: ' camera_sub_type])
            return
        end
    catch
    end
end
