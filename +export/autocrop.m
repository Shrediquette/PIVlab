function [imagedata,croprect]=autocrop (file,fmt)
% Removes the white border of an image. fmt 0 = png file, 1 = jpg file (both overwritten),
% 3 = image data (returned in imagedata). croprect = [first_row last_row first_col last_col].
if fmt ~=3
	A=imread(file);
else
	A=file;
end
B=rgb2gray(A);
rows=not_white(mean(B,2));
cols=not_white(mean(B,1));
A=A(rows(1):rows(2),cols(1):cols(2),:);
if fmt==1 %jpg
	imwrite(A,file,'quality', 100);
elseif fmt == 0 %png
	imwrite(A,file);
elseif fmt == 3 %video
	imagedata=A;
end
croprect=[rows cols];

function range=not_white(val)
%first and last entry that is not white (all, if all are white)
k=find(val~=255);
if isempty(k)
	range=[1 numel(val)];
else
	range=[k(1) k(end)];
end
