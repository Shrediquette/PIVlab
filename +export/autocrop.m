function [imagedata,croprect]=autocrop (file,fmt)
%problem, entweder Verfahren nicht geeignet oder irgendein Matlab bug...
if fmt ~=3
	A=imread(file);
else
	A=file;
end
B=rgb2gray(A);

%rows (y) detect white borders
val=mean(B,2);
startcropy = find(val~=255,1,'first');
if isempty (startcropy)
	startcropy=1;
end

endcropy = find(val~=255,1,'last');
if isempty (endcropy)
	endcropy=size(B,1);
end

%disp([num2str(startcropy) '  '  num2str(endcropy)])

%cols (y) detect white borders
val=mean(B,1);
startcropx = find(val~=255,1,'first');
if isempty (startcropx)
	startcropx=1;
end

endcropx = find(val~=255,1,'last');
if isempty (endcropx)
	endcropx=size(B,2);
end
%disp([num2str(startcropx) '  '  num2str(endcropx)])


%crop image data
A=A(startcropy:endcropy,startcropx:endcropx,:);

%overwrite file
if fmt==1 %jpg
	imwrite(A,file,'quality', 100);
elseif fmt == 0 %png
	imwrite(A,file);
elseif fmt == 3 %video
	imagedata=A;
end
croprect=[startcropy endcropy startcropx endcropx];

