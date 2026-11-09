function P = cam_detectCharucoBoardPoints_scaled(img, varargin)
%Drop-in replacement for detectCharucoBoardPoints. Very large markers (high resolution
%images) are not detected reliably, best results are achieved with markers of approx.
%30...80 px. --> Downscale the image so that markers are approx. 60 px, detect, and map
%the points back to full resolution coordinates.
%Corners of wrongly decoded markers are removed (preproc.cam_filter_charuco_corners).
s = preproc.cam_charuco_scale(img);
if s == 1
	P = detectCharucoBoardPoints(img, varargin{:});
else
	P = detectCharucoBoardPoints(imresize(img,s), varargin{:});
	P = (P-0.5)/s + 0.5; % back to full res pixel coordinates
end
P = preproc.cam_filter_charuco_corners(P, varargin{1});
