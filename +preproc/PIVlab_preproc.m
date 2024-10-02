function out = PIVlab_preproc (in,roirect,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens,maxintens)
%preprocessing does not change the image class anymore
%works with uint8, uint16, singe and double RGB and gray images.
%this function preprocesses the images
if size(in,3)>1
	in=rgb2gray(in); % rgb2gray keeps image class
end
if numel(roirect)>0
    x=roirect(1);
    y=roirect(2);
    width=roirect(3);
    height=roirect(4);
else
    x=1;
    y=1;
    width=size(in,2)-1;
    height=size(in,1)-1;
end
%roi (x,y,width,height)
in_roi=in(y:y+height,x:x+width);

%histogramm anpassen, bei 8bit und 16 bit
in_roi = imadjust(in_roi, [minintens;maxintens],[]); %wenn defaults= 0 und 1, dann kein Effekt

if intenscap == 1
    %Intensity Capping: a simple method to improve cross-correlation PIV results
    %Uri Shavit Æ Ryan J. Lowe Æ Jonah V. Steinbuck
    n = 2; 
    up_lim_im_1 = median(double(in_roi(:))) + n*std2(in_roi); % upper limit for image 1
    brightspots_im_1 = find(in_roi > up_lim_im_1); % bright spots in image 1
    capped_im_1 = in_roi; capped_im_1(brightspots_im_1) = up_lim_im_1; % capped image 1
    in_roi=capped_im_1;
end

if clahe == 1
    numberoftiles1=round(size(in_roi,1)/clahesize);
    numberoftiles2=round(size(in_roi,2)/clahesize);
    if numberoftiles1 < 2
    numberoftiles1=2;
    end
    if numberoftiles2 < 2
    numberoftiles2=2;
    end
    in_roi=adapthisteq(in_roi, 'NumTiles',[numberoftiles1 numberoftiles2], 'ClipLimit', 0.01, 'NBins', 256, 'Range', 'full', 'Distribution', 'uniform');
end

if highp == 1
    h = fspecial('gaussian',highpsize,highpsize);
    %in_roi=double(in_roi-(imfilter(in_roi,h,'replicate')));
		in_roi=(in_roi-(imfilter(in_roi,h,'replicate')));
    %in_roi=in_roi/max(max(in_roi));
end

if wienerwurst == 1
    in_roi=wiener2(in_roi,[wienerwurstsize wienerwurstsize]);
	%wiener denoise might be pretty useless? At least I didn't see any
	%benefits yet. So I add another low pass filter, which might actually help in
	%cases with noise
	h = fspecial('gaussian',wienerwurstsize,wienerwurstsize/2); 
	in_roi=imfilter(in_roi,h,'replicate');
end

out=in;
out(y:y+height,x:x+width)=in_roi;