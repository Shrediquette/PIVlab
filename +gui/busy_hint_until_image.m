function busy_hint_until_image
%BUSY_HINT_UNTIL_IMAGE The status strip and the busy mouse pointer go away when a camera shows its image.
%   Call after gui.toolsavailable(0,busy_msg) when the controls stay locked while a camera runs (live
%   image, PIV preview, PIV capture). The capture code of every camera makes a new image object in
%   pivlab_axis when the camera is ready and then updates it in a loop with drawnow. gui.busy_watchdog
%   (once per second) removes the strip and the busy pointer as soon as such a new image is there.
%   The controls stay locked and the watchdog keeps running: an error during the capture still shows
%   the strip with "Unlock controls". gui.toolsavailable clears this state.
pivlab_axis=gui.retr('pivlab_axis');
if isempty(pivlab_axis) || ~isvalid(pivlab_axis)
	return
end
until_image.axis=pivlab_axis;
until_image.images_before=findobj(pivlab_axis,'Type','image');
gui.put('busy_until_image',until_image);
