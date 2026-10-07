function P = cam_detectCharucoBoardPoints_scaled(img, varargin)
%Drop-in replacement for detectCharucoBoardPoints. Very large markers (high resolution
%images) are not detected reliably, best results are achieved with markers of approx.
%30...80 px. --> Downscale the image so that markers are approx. 60 px, detect, and map
%the points back to full resolution coordinates.
s = 1;
if max(size(img)) > 2000 % small images: unchanged behaviour
	s_probe = 1280 / max(size(img)); % cheap probe, large markers are detectable here
	[~,locs] = readArucoMarker(imresize(img,s_probe),'DICT_4X4_1000','MarkerSizeRange',[0.005 1]);
	if ~isempty(locs)
		w = median(vecnorm(locs(1,:,:)-locs(2,:,:),2,2)) / s_probe; % marker edge length in full res px
		s = min(1, 2^round(log2(60/w))); % power of 2 so that markers are approx. 60 px
	end % nothing found --> s=1 (as before)
end
if s == 1
	P = detectCharucoBoardPoints(img, varargin{:});
else
	P = detectCharucoBoardPoints(imresize(img,s), varargin{:});
	P = (P-0.5)/s + 0.5; % back to full res pixel coordinates
end
