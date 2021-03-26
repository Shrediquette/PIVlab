%Filter velocity vector based on the local image quality
function [u,v,threshold_suggestion] = PIVlab_image_filter (do_contrast,do_bright,x,y,u,v,contrast_filter_thresh,bright_filter_thresh,A,B,rawimageA,rawimageB)
if do_contrast==1
	if size(A,3)>1 %color image cannot be displayed properly when bg subtraction is enabled.
		A = rgb2gray(A);
		B = rgb2gray(B);
	end
	
	C=double(A)+double(B);
	C=C/max(C(:));
	
	gx=diff(C,1,2); %diff is faster than gradient
	gx(:,end+1) = gx(:,end);
	gy=diff(C,1,1);
	gy(end+1,:) = gx(end,:);
	
	g=(abs(gx)+abs(gy))/2; % sum up absolute gradients in x and y. It serves as measure for the "texture amplitude" in the images.
	
	H = fspecial('average',round(size(A,1)/size(x,1)));
	gb = imfilter(g,H,'replicate'); %lowpass the result
	
	x_orig = 1:size(A,2);
	y_orig = 1:size(A,1);
	[X,Y] = meshgrid(x_orig,y_orig);
	gq = interp2(X,Y,gb,x,y,'nearest'); %scale down result to match size of u and v
	
	lowhigh = stretchlim(gq,[0.1 1]); %finds limits for 10% of data and 100% of data
	threshold_suggestion=lowhigh(1); %the 10% limit is returned as suggestion.
	
	u(gq<contrast_filter_thresh)=nan; %remove vectors where image texture is low.
	v(gq<contrast_filter_thresh)=nan;
	%{
mainhandle=gcf;
figure;
imagesc(gq)
figure(mainhandle)
	%}

end

%bright area filter
if do_bright==1
	if size(rawimageA,3)>1
		rawimageA = rgb2gray(rawimageA);
		rawimageB = rgb2gray(rawimageB);
	end
	
	lowhighA = stretchlim(rawimageA,[0 0.99]); %set the treshold at the top 1% of the available brightnesses
	lowhighB = stretchlim(rawimageB,[0 0.99]);
	threshold_suggestion=(lowhighA(2)+lowhighB(2))/2;
	
	thresh_A=max(double(rawimageA(:)))*bright_filter_thresh;
	thresh_B=max(double(rawimageB(:)))*bright_filter_thresh;
	%find the theoretical maximum of the image class
	classimage=class(rawimageA);
	if strcmp(classimage,'double')==1 %double stays double
		%do nothing
	elseif strcmp(classimage,'single')==1 %e.g. 32bit tif, ranges from 0...1
		%do nothing
	elseif strcmp(classimage,'uint16')==1 %e.g. 16bit tif, ranges from 0...65535
		thresh_A=thresh_A/65535;
		thresh_B=thresh_B/65535;
	elseif strcmp(classimage,'uint8')==1 %0...255
		thresh_A=thresh_A/255;
		thresh_B=thresh_B/255;
	end
	
	A_bw=im2bw(rawimageA,thresh_A);
	B_bw=im2bw(rawimageB,thresh_B);
	C_bw=(A_bw+B_bw)*0.5;
	SE = strel('rectangle',[3 3]);
	D_bw = imerode(C_bw,SE);
	
	H = fspecial('average',round(size(A,1)/size(x,1)));
	D_bwb = imfilter(D_bw,H,'replicate'); %lowpass the result

		x_orig = 1:size(A,2);
	y_orig = 1:size(A,1);
		[X,Y] = meshgrid(x_orig,y_orig);
	D_bwbq = interp2(X,Y,D_bwb,x,y,'nearest'); %scale down result to match size of u and v
	u(D_bwbq>0)=nan; %remove vectors where brightness is high.
	v(D_bwbq>0)=nan;
end

