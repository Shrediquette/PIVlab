function s = cam_charuco_scale(img)
%Scale factor for ChArUco detection. Very large markers (high resolution images) are not
%detected reliably, best results are achieved with markers of approx. 30...80 px.
%--> s (power of 2, <= 1) downscales the image so that markers are approx. 60 px.
s = 1;
if max(size(img)) > 2000 % small images: unchanged behaviour
	s_probe = 1280 / max(size(img)); % cheap probe, large markers are detectable here
	[~,locs] = readArucoMarker(imresize(img,s_probe),'DICT_4X4_1000','MarkerSizeRange',[0.005 1]);
	if ~isempty(locs)
		w = median(vecnorm(locs(1,:,:)-locs(2,:,:),2,2)) / s_probe; % marker edge length in full res px
		s = min(1, 2^round(log2(60/w)));
	end % nothing found --> s=1 (as before)
end
