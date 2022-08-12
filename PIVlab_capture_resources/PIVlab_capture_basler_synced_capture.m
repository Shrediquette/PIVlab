function [OutputError,basler_vid] = PIVlab_capture_basler_synced_capture(basler_vid,nr_of_images,do_realtime,ROI_live,frame_nr_display)

hgui=getappdata(0,'hgui');

OutputError=0;

basler_frames_to_capture = nr_of_images*2;

%% capture data

[bla blubb]=memory;
initialAvailableMemory = bla.MemAvailableAllArrays - bla.MemUsedMATLAB;



while basler_vid.FramesAcquired < (basler_frames_to_capture) &&  getappdata(hgui,'cancel_capture') ~=1
	set(frame_nr_display,'String',['Image nr.: ' int2str(round(basler_vid.FramesAcquired/2))]);
	drawnow limitrate
	pause(0.5)
	[bla blubb]=memory;
remainingMemory = initialAvailableMemory - bla.MemUsedMATLAB;
	disp(['remaining: ' num2str(remainingMemory / 1024 /1024/1024)])

	
end

stoppreview(basler_vid)
stop(basler_vid);
set(frame_nr_display,'String',['Image nr.: ' int2str(round(basler_vid.FramesAcquired/2))]);
drawnow;