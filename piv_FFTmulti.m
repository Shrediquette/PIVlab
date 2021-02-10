function [xtable, ytable, utable, vtable, typevector, correlation_map] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask_inpt, roi_inpt,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_pad)
%profile on
%this funtion performs the  PIV analysis.
limit_peak_search_area=1; %new in 2.41: Default is to limit the peak search area in pass 2-4.
warning off %#ok<*WNOFF> %MATLAB:log:logOfZero
if numel(roi_inpt)>0
	xroi=roi_inpt(1);
	yroi=roi_inpt(2);
	widthroi=roi_inpt(3);
	heightroi=roi_inpt(4);
	image1_roi=double(image1(yroi:yroi+heightroi,xroi:xroi+widthroi));
	image2_roi=double(image2(yroi:yroi+heightroi,xroi:xroi+widthroi));
else
	xroi=0;
	yroi=0;
	image1_roi=double(image1);
	image2_roi=double(image2);
end
gen_image1_roi = image1_roi;
gen_image2_roi = image2_roi;

if numel(mask_inpt)>0
	cellmask=mask_inpt;
	mask=zeros(size(image1_roi));
	for i=1:size(cellmask,1)
		masklayerx=cellmask{i,1};
		masklayery=cellmask{i,2};
		mask = mask + poly2mask(masklayerx-xroi,masklayery-yroi,size(image1_roi,1),size(image1_roi,2)); %kleineres eingangsbild und maske geshiftet
	end
else
	mask=zeros(size(image1_roi));
end
mask(mask>1)=1;
gen_mask = mask;

miniy=1+(ceil(interrogationarea/2));
minix=1+(ceil(interrogationarea/2));
maxiy=step*(floor(size(image1_roi,1)/step))-(interrogationarea-1)+(ceil(interrogationarea/2)); %statt size deltax von ROI nehmen
maxix=step*(floor(size(image1_roi,2)/step))-(interrogationarea-1)+(ceil(interrogationarea/2));

numelementsy=floor((maxiy-miniy)/step+1);
numelementsx=floor((maxix-minix)/step+1);

LAy=miniy;
LAx=minix;
LUy=size(image1_roi,1)-maxiy;
LUx=size(image1_roi,2)-maxix;
shift4centery=round((LUy-LAy)/2);
shift4centerx=round((LUx-LAx)/2);
if shift4centery<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
	shift4centery=0;
end
if shift4centerx<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
	shift4centerx=0;
end
miniy=miniy+shift4centery;
minix=minix+shift4centerx;
maxix=maxix+shift4centerx;
maxiy=maxiy+shift4centery;

image1_roi=padarray(image1_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
image2_roi=padarray(image2_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
mask=padarray(mask,[ceil(interrogationarea/2) ceil(interrogationarea/2)],0);

if (rem(interrogationarea,2) == 0) %for the subpixel displacement measurement
	SubPixOffset=1;
else
	SubPixOffset=0.5;
end
xtable=zeros(numelementsy,numelementsx);
ytable=xtable; %#ok<*NASGU>
utable=xtable;
vtable=xtable;
typevector=ones(numelementsy,numelementsx);

%% MAINLOOP
try %check if used from GUI
	handles=guihandles(getappdata(0,'hgui'));
	GUI_avail=1;
catch %#ok<CTCH>
	GUI_avail=0;
end

% divide images by small pictures
% new index for image1_roi and image2_roi


s0 = (repmat((miniy:step:maxiy)'-1, 1,numelementsx) + repmat(((minix:step:maxix)-1)*size(image1_roi, 1), numelementsy,1))';
s0 = permute(s0(:), [2 3 1]);
s1 = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
ss1 = repmat(s1, [1, 1, size(s0,3)])+repmat(s0, [interrogationarea, interrogationarea, 1]);

image1_cut = image1_roi(ss1);
image2_cut = image2_roi(ss1);

if do_pad==1 && passes == 1 %only on first pass
	%subtract mean to avoid high frequencies at border of correlation:
	image1_cut=image1_cut-mean(image1_cut,[1 2]);
	image2_cut=image2_cut-mean(image2_cut,[1 2]);
	% padding (faster than padarray) to get the linear correlation:
	image1_cut=[image1_cut zeros(interrogationarea,interrogationarea-1,size(image1_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cut,3))];
	image2_cut=[image2_cut zeros(interrogationarea,interrogationarea-1,size(image2_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cut,3))];
end
%do fft2:
result_conv = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
if do_pad==1 && passes == 1
	%cropping of correlation matrix:
	result_conv =result_conv((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
end

%% repeated  Correlation in the first pass (might make sense to repeat more often to make it even more robust...)

if repeat == 1 && passes == 1
	ms=round(step/4); %multishift parameter so groß wie viertel int window
	%Shift left bot
	s0B = (repmat((miniy+ms:step:maxiy+ms)'-1, 1,numelementsx) + repmat(((minix-ms:step:maxix-ms)-1)*size(image1_roi, 1), numelementsy,1))';
	s0B = permute(s0B(:), [2 3 1]);
	s1B = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
	ss1B = repmat(s1B, [1, 1, size(s0B,3)])+repmat(s0B, [interrogationarea, interrogationarea, 1]);
	image1_cutB = image1_roi(ss1B);
	image2_cutB = image2_roi(ss1B);
	if do_pad==1 && passes == 1
		%subtract mean to avoid high frequencies at border of correlation:
		image1_cutB=image1_cutB-mean(image1_cutB,[1 2]);
		image2_cutB=image2_cutB-mean(image2_cutB,[1 2]);
		% padding (faster than padarray) to get the linear correlation:
		image1_cutB=[image1_cutB zeros(interrogationarea,interrogationarea-1,size(image1_cutB,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cutB,3))];
		image2_cutB=[image2_cutB zeros(interrogationarea,interrogationarea-1,size(image2_cutB,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cutB,3))];
	end
	result_convB = fftshift(fftshift(real(ifft2(conj(fft2(image1_cutB)).*fft2(image2_cutB))), 1), 2);
	if do_pad==1 && passes == 1
		%cropping of correlation matrix:
		result_convB =result_convB((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
	end
	
	%Shift right bot
	s0C = (repmat((miniy+ms:step:maxiy+ms)'-1, 1,numelementsx) + repmat(((minix+ms:step:maxix+ms)-1)*size(image1_roi, 1), numelementsy,1))';
	s0C = permute(s0C(:), [2 3 1]);
	s1C = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
	ss1C = repmat(s1C, [1, 1, size(s0C,3)])+repmat(s0C, [interrogationarea, interrogationarea, 1]);
	image1_cutC = image1_roi(ss1C);
	image2_cutC = image2_roi(ss1C);
	if do_pad==1 && passes == 1
		%subtract mean to avoid high frequencies at border of correlation:
		image1_cutC=image1_cutC-mean(image1_cutC,[1 2]);
		image2_cutC=image2_cutC-mean(image2_cutC,[1 2]);
		% padding (faster than padarray) to get the linear correlation:
		image1_cutC=[image1_cutC zeros(interrogationarea,interrogationarea-1,size(image1_cutC,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cutC,3))];
		image2_cutC=[image2_cutC zeros(interrogationarea,interrogationarea-1,size(image2_cutC,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cutC,3))];
	end
	result_convC = fftshift(fftshift(real(ifft2(conj(fft2(image1_cutC)).*fft2(image2_cutC))), 1), 2);
	if do_pad==1 && passes == 1
		%cropping of correlation matrix:
		result_convC =result_convC((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
	end
	
	%Shift left top
	s0D = (repmat((miniy-ms:step:maxiy-ms)'-1, 1,numelementsx) + repmat(((minix-ms:step:maxix-ms)-1)*size(image1_roi, 1), numelementsy,1))';
	s0D = permute(s0D(:), [2 3 1]);
	s1D = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
	ss1D = repmat(s1D, [1, 1, size(s0D,3)])+repmat(s0D, [interrogationarea, interrogationarea, 1]);
	image1_cutD = image1_roi(ss1D);
	image2_cutD = image2_roi(ss1D);
	
	if do_pad==1 && passes == 1
		%subtract mean to avoid high frequencies at border of correlation:
		image1_cutD=image1_cutD-mean(image1_cutD,[1 2]);
		image2_cutD=image2_cutD-mean(image2_cutD,[1 2]);
		% padding (faster than padarray) to get the linear correlation:
		image1_cutD=[image1_cutD zeros(interrogationarea,interrogationarea-1,size(image1_cutD,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cutD,3))];
		image2_cutD=[image2_cutD zeros(interrogationarea,interrogationarea-1,size(image2_cutD,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cutD,3))];
	end
	result_convD = fftshift(fftshift(real(ifft2(conj(fft2(image1_cutD)).*fft2(image2_cutD))), 1), 2);
	if do_pad==1 && passes == 1
		%cropping of correlation matrix:
		result_convD =result_convD((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
	end
	
	%Shift right top
	s0E = (repmat((miniy-ms:step:maxiy-ms)'-1, 1,numelementsx) + repmat(((minix+ms:step:maxix+ms)-1)*size(image1_roi, 1), numelementsy,1))';
	s0E = permute(s0E(:), [2 3 1]);
	s1E = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
	ss1E = repmat(s1E, [1, 1, size(s0E,3)])+repmat(s0E, [interrogationarea, interrogationarea, 1]);
	image1_cutE = image1_roi(ss1E);
	image2_cutE = image2_roi(ss1E);
	if do_pad==1 && passes == 1
		%subtract mean to avoid high frequencies at border of correlation:
		image1_cutE=image1_cutE-mean(image1_cutE,[1 2]);
		image2_cutE=image2_cutE-mean(image2_cutE,[1 2]);
		% padding (faster than padarray) to get the linear correlation:
		image1_cutE=[image1_cutE zeros(interrogationarea,interrogationarea-1,size(image1_cutE,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cutE,3))];
		image2_cutE=[image2_cutE zeros(interrogationarea,interrogationarea-1,size(image2_cutE,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cutE,3))];
	end
	result_convE = fftshift(fftshift(real(ifft2(conj(fft2(image1_cutE)).*fft2(image2_cutE))), 1), 2);
	if do_pad==1 && passes == 1
		%cropping of correlation matrix:
		result_convE =result_convE((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
	end
	result_conv=result_conv.*result_convB.*result_convC.*result_convD.*result_convE;
end

%%{
if mask_auto == 1
	%das zentrum der Matrize (3x3) mit dem mittelwert ersetzen = Keine Autokorrelation
	%MARKER
	h = fspecial('gaussian', 3, 1.5);
	h=h/h(2,2);
	h=1-h;
	try
		h=repmat(h,1,1,size(result_conv,3));
	catch %old matlab releases fail
		for repli=1:size(result_conv,3)
			h_repl(:,:,repli)=h;
		end
		h=h_repl;
	end
	h=h.*result_conv((interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,(interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,:);
	result_conv((interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,(interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,:)=h;
end
%%}
%peakheight
%peak_height=max(max(result_conv)) ./ mean(mean(result_conv)) ;
%peak_height = permute(reshape(peak_height, [size(xtable')]), [2 1 3]);

minres = permute(repmat(squeeze(min(min(result_conv))), [1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
deltares = permute(repmat(squeeze(max(max(result_conv))-min(min(result_conv))),[ 1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
result_conv = ((result_conv-minres)./deltares)*255;
%apply mask
ii = find(mask(ss1(round(interrogationarea/2+1), round(interrogationarea/2+1), :)));
jj = find(mask((miniy:step:maxiy)+round(interrogationarea/2), (minix:step:maxix)+round(interrogationarea/2)));
typevector(jj) = 0;
result_conv(:,:, ii) = 0;

[y, x, z] = ind2sub(size(result_conv), find(result_conv==255));

% we need only one peak from each couple pictures
[z1, zi] = sort(z);
if ~isempty(z1)
	dz1 = [z1(1); diff(z1)];
	i0 = find(dz1~=0);
else
	dz1=[];
	i0=[];
end
x1 = x(zi(i0));
y1 = y(zi(i0));
z1 = z(zi(i0));

xtable = repmat((minix:step:maxix)+interrogationarea/2, length(miniy:step:maxiy), 1);
ytable = repmat(((miniy:step:maxiy)+interrogationarea/2)', 1, length(minix:step:maxix));

if subpixfinder==1
	[vector] = SUBPIXGAUSS (result_conv,interrogationarea, x1, y1, z1, SubPixOffset);
elseif subpixfinder==2
	[vector] = SUBPIX2DGAUSS (result_conv,interrogationarea, x1, y1, z1, SubPixOffset);
end
vector = permute(reshape(vector, [size(xtable') 2]), [2 1 3]);

utable = vector(:,:,1);
vtable = vector(:,:,2);


%assignin('base','corr_results',corr_results);


%multipass
%feststellen wie viele passes
%wenn intarea=0 dann keinen pass.
for multipass=1:passes-1
	
	if GUI_avail==1
		set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes+((multipass-1)*(100/passes))) '%' sprintf('\n') 'Validating velocity field']);drawnow;
	else
		fprintf('.');
	end
	%multipass validation, smoothing
	utable_orig=utable;
	vtable_orig=vtable;
	[utable,vtable] = PIVlab_postproc (utable,vtable,[], [], 1,4, 1,1.5);
	
	%find typevector...
	%maskedpoints=numel(find((typevector)==0));
	%amountnans=numel(find(isnan(utable)==1))-maskedpoints;
	%discarded=amountnans/(size(utable,1)*size(utable,2))*100;
	%disp(['Discarded: ' num2str(amountnans) ' vectors = ' num2str(discarded) ' %'])
	
	if GUI_avail==1
		if verLessThan('matlab','8.4')
			delete (findobj(getappdata(0,'hgui'),'type', 'hggroup'))
		else
			delete (findobj(getappdata(0,'hgui'),'type', 'quiver'))
		end
		hold on;
		vecscale=str2double(get(handles.vectorscale,'string'));
		%Problem: wenn colorbar an, zï¿½hlt das auch als aexes...
		colorbar('off')
		quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==0)+xroi-interrogationarea/2,ytable(isnan(utable)==0)+yroi-interrogationarea/2,utable_orig(isnan(utable)==0)*vecscale,vtable_orig(isnan(utable)==0)*vecscale,'Color', [0.15 0.7 0.15],'autoscale','off')
		quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==1)+xroi-interrogationarea/2,ytable(isnan(utable)==1)+yroi-interrogationarea/2,utable_orig(isnan(utable)==1)*vecscale,vtable_orig(isnan(utable)==1)*vecscale,'Color',[0.7 0.15 0.15], 'autoscale','off')
		drawnow
		hold off
	end
	
	%replace nans
	utable=inpaint_nans(utable,4);
	vtable=inpaint_nans(vtable,4);
	%smooth predictor
	
	try
		if multipass<passes-1
			utable = smoothn(utable,0.9); %stronger smoothing for first passes
			vtable = smoothn(vtable,0.9);
			lastpass=0;
		else
			utable = smoothn(utable); %weaker smoothing for last pass
			vtable = smoothn(vtable);
			lastpass=1;
		end
	catch
		
		%old matlab versions: gaussian kernel
		h=fspecial('gaussian',5,1);
		utable=imfilter(utable,h,'replicate');
		vtable=imfilter(vtable,h,'replicate');
	end
	
	if multipass==1
		interrogationarea=round(int2/2)*2;
	end
	if multipass==2
		interrogationarea=round(int3/2)*2;
	end
	if multipass==3
		interrogationarea=round(int4/2)*2;
	end
	step=interrogationarea/2;
	
	%bildkoordinaten neu errechnen:
	%roi=[];
	
	image1_roi = gen_image1_roi;
	image2_roi = gen_image2_roi;
	mask = gen_mask;
	
	
	miniy=1+(ceil(interrogationarea/2));
	minix=1+(ceil(interrogationarea/2));
	maxiy=step*(floor(size(image1_roi,1)/step))-(interrogationarea-1)+(ceil(interrogationarea/2)); %statt size deltax von ROI nehmen
	maxix=step*(floor(size(image1_roi,2)/step))-(interrogationarea-1)+(ceil(interrogationarea/2));
	
	numelementsy=floor((maxiy-miniy)/step+1);
	numelementsx=floor((maxix-minix)/step+1);
	
	LAy=miniy;
	LAx=minix;
	LUy=size(image1_roi,1)-maxiy;
	LUx=size(image1_roi,2)-maxix;
	shift4centery=round((LUy-LAy)/2);
	shift4centerx=round((LUx-LAx)/2);
	if shift4centery<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
		shift4centery=0;
	end
	if shift4centerx<0 %shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we weould have less data....
		shift4centerx=0;
	end
	miniy=miniy+shift4centery;
	minix=minix+shift4centerx;
	maxix=maxix+shift4centerx;
	maxiy=maxiy+shift4centery;
	
	image1_roi=padarray(image1_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
	image2_roi=padarray(image2_roi,[ceil(interrogationarea/2) ceil(interrogationarea/2)], min(min(image1_roi)));
	mask=padarray(mask,[ceil(interrogationarea/2) ceil(interrogationarea/2)],0);
	
	%{
	%Improve masking?
	max_img_value=(max(image1_roi(:))+max(image2_roi(:)))/2;
	noise_mask1=rand(size(image1_roi))*max_img_value*0;
	noise_mask2=rand(size(image1_roi))*max_img_value*0;
	image1_roi(mask==1)=0;
	image2_roi(mask==1)=0;
	noise_mask1(mask==0)=0;
	noise_mask2(mask==0)=0;
	image1_roi=image1_roi+noise_mask1;
	image2_roi=image2_roi+noise_mask2;
	%keyboard
	disp('XXX')
	%}
	
	if (rem(interrogationarea,2) == 0) %for the subpixel displacement measurement
		SubPixOffset=1;
	else
		SubPixOffset=0.5;
	end
	xtable_old=xtable;
	ytable_old=ytable;
	typevector=ones(numelementsy,numelementsx);
	xtable = repmat((minix:step:maxix), numelementsy, 1) + interrogationarea/2;
	ytable = repmat((miniy:step:maxiy)', 1, numelementsx) + interrogationarea/2;
	
	%xtable alt und neu geben koordinaten wo die vektoren herkommen.
	%d.h. u und v auf die gewï¿½nschte grï¿½ï¿½e bringen+interpolieren
	if GUI_avail==1
		set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100/passes+((multipass-1)*(100/passes))) '%' sprintf('\n') 'Interpolating velocity field']);drawnow;
		%set(handles.progress, 'string' , 'Interpolating velocity field');drawnow;
	else
		fprintf('.');
	end
	
	utable=interp2(xtable_old,ytable_old,utable,xtable,ytable,'*spline');
	vtable=interp2(xtable_old,ytable_old,vtable,xtable,ytable,'*spline');
	
	utable_1= padarray(utable, [1,1], 'replicate');
	vtable_1= padarray(vtable, [1,1], 'replicate');
	
	%add 1 line around image for border regions... linear extrap
	
	firstlinex=xtable(1,:);
	firstlinex_intp=interp1(1:1:size(firstlinex,2),firstlinex,0:1:size(firstlinex,2)+1,'linear','extrap');
	xtable_1=repmat(firstlinex_intp,size(xtable,1)+2,1);
	
	firstliney=ytable(:,1);
	firstliney_intp=interp1(1:1:size(firstliney,1),firstliney,0:1:size(firstliney,1)+1,'linear','extrap')';
	ytable_1=repmat(firstliney_intp,1,size(ytable,2)+2);
	
	X=xtable_1; %original locations of vectors in whole image
	Y=ytable_1;
	U=utable_1; %interesting portion of u
	V=vtable_1; % "" of v
	
	X1=X(1,1):1:X(1,end)-1;
	Y1=(Y(1,1):1:Y(end,1)-1)';
	X1=repmat(X1,size(Y1, 1),1);
	Y1=repmat(Y1,1,size(X1, 2));
	
	U1 = interp2(X,Y,U,X1,Y1,'*linear');
	V1 = interp2(X,Y,V,X1,Y1,'*linear');
	
	image2_crop_i1 = interp2(1:size(image2_roi,2),(1:size(image2_roi,1))',double(image2_roi),X1+U1,Y1+V1,imdeform); %linear is 3x faster and looks ok...
	
	xb = find(X1(1,:) == xtable_1(1,1));
	yb = find(Y1(:,1) == ytable_1(1,1));
	
	% divide images by small pictures
	% new index for image1_roi
	s0 = (repmat((miniy:step:maxiy)'-1, 1,numelementsx) + repmat(((minix:step:maxix)-1)*size(image1_roi, 1), numelementsy,1))';
	s0 = permute(s0(:), [2 3 1]);
	s1 = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
	ss1 = repmat(s1, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
	% new index for image2_crop_i1
	s0 = (repmat(yb-step+step*(1:numelementsy)'-1, 1,numelementsx) + repmat((xb-step+step*(1:numelementsx)-1)*size(image2_crop_i1, 1), numelementsy,1))';
	s0 = permute(s0(:), [2 3 1]) - s0(1);
	s2 = repmat((1:2*step)',1,2*step) + repmat(((1:2*step)-1)*size(image2_crop_i1, 1),2*step,1);
	ss2 = repmat(s2, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
	
	
	image1_cut = image1_roi(ss1);
	image2_cut = image2_crop_i1(ss2);
	if do_pad==1 && multipass==passes-1
		%subtract mean to avoid high frequencies at border of correlation:
		try
			image1_cut=image1_cut-mean(image1_cut,[1 2]);
			image2_cut=image2_cut-mean(image2_cut,[1 2]);
		catch %old Matlab release
			
			for oldmatlab=1:size(image1_cut,3);
				image1_cut(:,:,oldmatlab)=image1_cut(:,:,oldmatlab)-mean(mean(image1_cut(:,:,oldmatlab)));
				image2_cut(:,:,oldmatlab)=image2_cut(:,:,oldmatlab)-mean(mean(image2_cut(:,:,oldmatlab)));
			end
		end
		
		% padding (faster than padarray) to get the linear correlation:
		
		image1_cut=[image1_cut zeros(interrogationarea,interrogationarea-1,size(image1_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cut,3))];
		image2_cut=[image2_cut zeros(interrogationarea,interrogationarea-1,size(image2_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cut,3))];
	end
	%do fft2:
	result_conv = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
	if do_pad==1 && multipass==passes-1
		%cropping of correlation matrix:
		result_conv =result_conv((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
	end
	
	%% repeated correlation
	if repeat == 1 && multipass==passes-1
		ms=round(step/4); %multishift parameter so groß wie viertel int window
		
		%Shift left bot
		image2_crop_i1 = interp2(1:size(image2_roi,2),(1:size(image2_roi,1))',double(image2_roi),X1+U1-ms,Y1+V1+ms,imdeform); %linear is 3x faster and looks ok...
		xb = find(X1(1,:) == xtable_1(1,1));
		yb = find(Y1(:,1) == ytable_1(1,1));
		s0 = (repmat((miniy+ms:step:maxiy+ms)'-1, 1,numelementsx) + repmat(((minix-ms:step:maxix-ms)-1)*size(image1_roi, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]);
		s1 = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
		ss1 = repmat(s1, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		s0 = (repmat(yb-step+step*(1:numelementsy)'-1, 1,numelementsx) + repmat((xb-step+step*(1:numelementsx)-1)*size(image2_crop_i1, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]) - s0(1);
		s2 = repmat((1:2*step)',1,2*step) + repmat(((1:2*step)-1)*size(image2_crop_i1, 1),2*step,1);
		ss2 = repmat(s2, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		image1_cut = image1_roi(ss1);
		image2_cut = image2_crop_i1(ss2);
		if do_pad==1 && multipass==passes-1
			%subtract mean to avoid high frequencies at border of correlation:
			try
				image1_cut=image1_cut-mean(image1_cut,[1 2]);
				image2_cut=image2_cut-mean(image2_cut,[1 2]);
			catch
				for oldmatlab=1:size(image1_cut,3);
					image1_cut(:,:,oldmatlab)=image1_cut(:,:,oldmatlab)-mean(mean(image1_cut(:,:,oldmatlab)));
					image2_cut(:,:,oldmatlab)=image2_cut(:,:,oldmatlab)-mean(mean(image2_cut(:,:,oldmatlab)));
				end
			end
			% padding (faster than padarray) to get the linear correlation:
			image1_cut=[image1_cut zeros(interrogationarea,interrogationarea-1,size(image1_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cut,3))];
			image2_cut=[image2_cut zeros(interrogationarea,interrogationarea-1,size(image2_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cut,3))];
		end
		result_convB = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
		if do_pad==1 && multipass==passes-1
			%cropping of correlation matrix:
			result_convB =result_convB((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
		end
		%figure;imagesc(image1_cut(:,:,100));colormap('gray');figure;imagesc(image2_cut(:,:,100));colormap('gray')
		
		
		%Shift right bot
		image2_crop_i1 = interp2(1:size(image2_roi,2),(1:size(image2_roi,1))',double(image2_roi),X1+U1+ms,Y1+V1+ms,imdeform); %linear is 3x faster and looks ok...
		xb = find(X1(1,:) == xtable_1(1,1));
		yb = find(Y1(:,1) == ytable_1(1,1));
		s0 = (repmat((miniy+ms:step:maxiy+ms)'-1, 1,numelementsx) + repmat(((minix+ms:step:maxix+ms)-1)*size(image1_roi, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]);
		s1 = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
		ss1 = repmat(s1, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		s0 = (repmat(yb-step+step*(1:numelementsy)'-1, 1,numelementsx) + repmat((xb-step+step*(1:numelementsx)-1)*size(image2_crop_i1, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]) - s0(1);
		s2 = repmat((1:2*step)',1,2*step) + repmat(((1:2*step)-1)*size(image2_crop_i1, 1),2*step,1);
		ss2 = repmat(s2, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		image1_cut = image1_roi(ss1);
		image2_cut = image2_crop_i1(ss2);
		if do_pad==1 && multipass==passes-1
			%subtract mean to avoid high frequencies at border of correlation:
			try
				image1_cut=image1_cut-mean(image1_cut,[1 2]);
				image2_cut=image2_cut-mean(image2_cut,[1 2]);
			catch
				for oldmatlab=1:size(image1_cut,3)
					image1_cut(:,:,oldmatlab)=image1_cut(:,:,oldmatlab)-mean(mean(image1_cut(:,:,oldmatlab)));
					image2_cut(:,:,oldmatlab)=image2_cut(:,:,oldmatlab)-mean(mean(image2_cut(:,:,oldmatlab)));
				end
			end
			% padding (faster than padarray) to get the linear correlation:
			image1_cut=[image1_cut zeros(interrogationarea,interrogationarea-1,size(image1_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cut,3))];
			image2_cut=[image2_cut zeros(interrogationarea,interrogationarea-1,size(image2_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cut,3))];
		end
		result_convC = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
		if do_pad==1 && multipass==passes-1
			%cropping of correlation matrix:
			result_convC =result_convC((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
		end
		%Shift left top
		image2_crop_i1 = interp2(1:size(image2_roi,2),(1:size(image2_roi,1))',double(image2_roi),X1+U1-ms,Y1+V1-ms,imdeform); %linear is 3x faster and looks ok...
		xb = find(X1(1,:) == xtable_1(1,1));
		yb = find(Y1(:,1) == ytable_1(1,1));
		s0 = (repmat((miniy-ms:step:maxiy-ms)'-1, 1,numelementsx) + repmat(((minix-ms:step:maxix-ms)-1)*size(image1_roi, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]);
		s1 = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
		ss1 = repmat(s1, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		s0 = (repmat(yb-step+step*(1:numelementsy)'-1, 1,numelementsx) + repmat((xb-step+step*(1:numelementsx)-1)*size(image2_crop_i1, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]) - s0(1);
		s2 = repmat((1:2*step)',1,2*step) + repmat(((1:2*step)-1)*size(image2_crop_i1, 1),2*step,1);
		ss2 = repmat(s2, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		image1_cut = image1_roi(ss1);
		image2_cut = image2_crop_i1(ss2);
		if do_pad==1 && multipass==passes-1
			%subtract mean to avoid high frequencies at border of correlation:
			try
				image1_cut=image1_cut-mean(image1_cut,[1 2]);
				image2_cut=image2_cut-mean(image2_cut,[1 2]);
			catch
				for oldmatlab=1:size(image1_cut,3);
					image1_cut(:,:,oldmatlab)=image1_cut(:,:,oldmatlab)-mean(mean(image1_cut(:,:,oldmatlab)));
					image2_cut(:,:,oldmatlab)=image2_cut(:,:,oldmatlab)-mean(mean(image2_cut(:,:,oldmatlab)));
				end
			end
			% padding (faster than padarray) to get the linear correlation:
			image1_cut=[image1_cut zeros(interrogationarea,interrogationarea-1,size(image1_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cut,3))];
			image2_cut=[image2_cut zeros(interrogationarea,interrogationarea-1,size(image2_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cut,3))];
		end
		result_convD = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
		if do_pad==1 && multipass==passes-1
			%cropping of correlation matrix:
			result_convD =result_convD((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
		end
		%Shift right top
		image2_crop_i1 = interp2(1:size(image2_roi,2),(1:size(image2_roi,1))',double(image2_roi),X1+U1+ms,Y1+V1-ms,imdeform); %linear is 3x faster and looks ok...
		xb = find(X1(1,:) == xtable_1(1,1));
		yb = find(Y1(:,1) == ytable_1(1,1));
		s0 = (repmat((miniy-ms:step:maxiy-ms)'-1, 1,numelementsx) + repmat(((minix+ms:step:maxix+ms)-1)*size(image1_roi, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]);
		s1 = repmat((1:interrogationarea)',1,interrogationarea) + repmat(((1:interrogationarea)-1)*size(image1_roi, 1),interrogationarea,1);
		ss1 = repmat(s1, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		s0 = (repmat(yb-step+step*(1:numelementsy)'-1, 1,numelementsx) + repmat((xb-step+step*(1:numelementsx)-1)*size(image2_crop_i1, 1), numelementsy,1))';
		s0 = permute(s0(:), [2 3 1]) - s0(1);
		s2 = repmat((1:2*step)',1,2*step) + repmat(((1:2*step)-1)*size(image2_crop_i1, 1),2*step,1);
		ss2 = repmat(s2, [1, 1, size(s0,3)]) + repmat(s0, [interrogationarea, interrogationarea, 1]);
		image1_cut = image1_roi(ss1);
		image2_cut = image2_crop_i1(ss2);
		if do_pad==1 && multipass==passes-1
			%subtract mean to avoid high frequencies at border of correlation:
			try
				image1_cut=image1_cut-mean(image1_cut,[1 2]);
				image2_cut=image2_cut-mean(image2_cut,[1 2]);
			catch
				for oldmatlab=1:size(image1_cut,3)
					image1_cut(:,:,oldmatlab)=image1_cut(:,:,oldmatlab)-mean(mean(image1_cut(:,:,oldmatlab)));
					image2_cut(:,:,oldmatlab)=image2_cut(:,:,oldmatlab)-mean(mean(image2_cut(:,:,oldmatlab)));
				end
			end
			% padding (faster than padarray) to get the linear correlation:
			image1_cut=[image1_cut zeros(interrogationarea,interrogationarea-1,size(image1_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image1_cut,3))];
			image2_cut=[image2_cut zeros(interrogationarea,interrogationarea-1,size(image2_cut,3)); zeros(interrogationarea-1,2*interrogationarea-1,size(image2_cut,3))];
		end
		result_convE = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut))), 1), 2);
		if do_pad==1 && multipass==passes-1
			%cropping of correlation matrix:
			result_convE =result_convE((interrogationarea/2):(3*interrogationarea/2)-1,(interrogationarea/2):(3*interrogationarea/2)-1,:);
		end
		result_conv=result_conv.*result_convB.*result_convC.*result_convD.*result_convE;
	end
	
	%limiting the peak search are in later passes makes sense: Earlier
	%passes use larger interrogation windows. They are therefore
	%statistically more significant, and it is more likely, that the
	%estimated displacement is correct. If we limit the maximum acceptable
	%deviation from this initial guess in later passes, then the result is
	%generally more likely to be correct.
	if limit_peak_search_area == 1
		if floor(size(result_conv,1)/3) >= 3 %if the interrogation area becomes too small, then further limiting of the search area doesnt make sense, because the peak may become as big as the search area
			emptymatrix=zeros(size(result_conv,1),size(result_conv,2),size(result_conv,3));
			if mask_auto == 1 %more restricted when "disable autocorrelation" is enabled
				sizeones=4;
			else %less restrictive for standard correlation settings
				sizeones=floor(size(result_conv,1)/3);
			end
			h=fspecial('disk',sizeones);
			h=h/max(max(h));
			try
				h=repmat(h,1,1,size(result_conv,3));
			catch %old matlab releases fail
				h_repl=[];
				for repli=1:size(result_conv,3)
					h_repl(:,:,repli)=h;
				end
				h=h_repl;
			end
			emptymatrix((interrogationarea/2)+SubPixOffset-sizeones:(interrogationarea/2)+SubPixOffset+sizeones,(interrogationarea/2)+SubPixOffset-sizeones:(interrogationarea/2)+SubPixOffset+sizeones,:)=h;
			bg_sig=(1-emptymatrix).*mean(result_conv,1:2); %zeros in middle, average correlation value in the remaining space
			result_conv = result_conv .* emptymatrix + bg_sig;
		end
	end
	
	%do fft2
	minres = permute(repmat(squeeze(min(min(result_conv))), [1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
	deltares = permute(repmat(squeeze(max(max(result_conv))-min(min(result_conv))), [1, size(result_conv, 1), size(result_conv, 2)]), [2 3 1]);
	%peakheight
	%peak_height=max(max(result_conv))./mean(mean(result_conv));
	%peak_height = permute(reshape(peak_height, [size(xtable')]), [2 1 3]);
	%{
    %1st to 2nd peak ratio:
    for ll = 1:size(result_conv,3)
        A=result_conv(:,:,ll);
        max_A= max(A(:));
        [row,col]=find(A==max_A);
        try
            A(row-3:row+3,col-3:col+3)=0;
            max_A2nd= max(A(:));
            ratio(1,1,ll)=max_A/max_A2nd;
        catch
            disp('lllll')
            ratio(1,1,ll)=nan;
        end
    end
    peak_height = permute(reshape(ratio, [size(xtable')]), [2 1 3]);
    figure;imagesc(peak_height);axis image
	%}
	result_conv = ((result_conv-minres)./deltares)*255;
	
	%apply mask
	ii = find(mask(ss1(round(interrogationarea/2+1), round(interrogationarea/2+1), :)));
	jj = find(mask((miniy:step:maxiy)+round(interrogationarea/2), (minix:step:maxix)+round(interrogationarea/2)));
	typevector(jj) = 0;
	result_conv(:,:, ii) = 0;
	
	[y, x, z] = ind2sub(size(result_conv), find(result_conv==255));
	[z1, zi] = sort(z);
	% we need only one peak from each couple pictures
	if ~isempty(z1)
		dz1 = [z1(1); diff(z1)];
		i0 = find(dz1~=0);
	else
		dz1=[];
		i0=[];
	end
	x1 = x(zi(i0));
	y1 = y(zi(i0));
	z1 = z(zi(i0));
	
	%new xtable and ytable
	xtable = repmat((minix:step:maxix)+interrogationarea/2, length(miniy:step:maxiy), 1);
	ytable = repmat(((miniy:step:maxiy)+interrogationarea/2)', 1, length(minix:step:maxix));
	
	if subpixfinder==1
		[vector] = SUBPIXGAUSS (result_conv,interrogationarea, x1, y1, z1,SubPixOffset);
	elseif subpixfinder==2
		[vector] = SUBPIX2DGAUSS (result_conv,interrogationarea, x1, y1, z1,SubPixOffset);
	end
	vector = permute(reshape(vector, [size(xtable') 2]), [2 1 3]);
	
	utable = utable+vector(:,:,1);
	vtable = vtable+vector(:,:,2);
end
%Correlation strength
correlation_map=zeros(size(typevector));
for cor_i=1:size(image1_cut,3)
	correlation_map(cor_i)=corr2(image1_cut(:,:,cor_i),image2_cut(:,:,cor_i));
end
correlation_map = permute(reshape(correlation_map, [size(xtable')]), [2 1 3]);
correlation_map(jj) = 0;
%correlation_map=peak_height; %replace correlation coefficient with peak height
xtable=xtable-ceil(interrogationarea/2);
ytable=ytable-ceil(interrogationarea/2);

xtable=xtable+xroi;
ytable=ytable+yroi;

% Write correlation matrices to the workspace
%{
try
    counter=evalin('base','counter');
    counter=counter+1;
    assignin('base','counter',counter);
    all_matrices=evalin('base','all_matrices');
    all_matrices{end+1}=result_conv;
    assignin('base','all_matrices',all_matrices);
    disp('appended matrix')
catch
    assignin('base','counter',1);
    all_matrices{1}=result_conv;
    assignin('base','all_matrices',all_matrices);
    disp('created new matrix')
end
%}
%%{
function [vector] = SUBPIXGAUSS(result_conv, interrogationarea, x, y, z, SubPixOffset)
%was hat peak nr.1 für einen Durchmesser?
%figure;imagesc((1-im2bw(uint8(result_conv(:,:,155)),0.9)).*result_conv(:,:,101))
xi = find(~((x <= (size(result_conv,2)-1)) & (y <= (size(result_conv,1)-1)) & (x >= 2) & (y >= 2)));
x(xi) = [];
y(xi) = [];
z(xi) = [];
xmax = size(result_conv, 2);
vector = NaN(size(result_conv,3), 2);
if(numel(x)~=0)
	ip = sub2ind(size(result_conv), y, x, z);
	%the following 8 lines are copyright (c) 1998, Uri Shavit, Roi Gurka, Alex Liberzon, Technion ï¿½ Israel Institute of Technology
	%http://urapiv.wordpress.com
	f0 = log(result_conv(ip));
	f1 = log(result_conv(ip-1));
	f2 = log(result_conv(ip+1));
	peaky = y + (f1-f2)./(2*f1-4*f0+2*f2);
	f0 = log(result_conv(ip));
	f1 = log(result_conv(ip-xmax));
	f2 = log(result_conv(ip+xmax));
	peakx = x + (f1-f2)./(2*f1-4*f0+2*f2);
	
	SubpixelX=peakx-(interrogationarea/2)-SubPixOffset;
	SubpixelY=peaky-(interrogationarea/2)-SubPixOffset;
	vector(z, :) = [SubpixelX, SubpixelY];
	
end
%}
function [vector] = SUBPIX2DGAUSS(result_conv, interrogationarea, x, y, z, SubPixOffset)
xi = find(~((x <= (size(result_conv,2)-1)) & (y <= (size(result_conv,1)-1)) & (x >= 2) & (y >= 2)));
x(xi) = [];
y(xi) = [];
z(xi) = [];
xmax = size(result_conv, 2);
vector = NaN(size(result_conv,3), 2);
if(numel(x)~=0)
	c10 = zeros(3,3, length(z));
	c01 = c10;
	c11 = c10;
	c20 = c10;
	c02 = c10;
	ip = sub2ind(size(result_conv), y, x, z);
	
	for i = -1:1
		for j = -1:1
			%following 15 lines based on
			%H. Nobach ï¿½ M. Honkanen (2005)
			%Two-dimensional Gaussian regression for sub-pixel displacement
			%estimation in particle image velocimetry or particle position
			%estimation in particle tracking velocimetry
			%Experiments in Fluids (2005) 38: 511ï¿½515
			c10(j+2,i+2, :) = i*log(result_conv(ip+xmax*i+j));
			c01(j+2,i+2, :) = j*log(result_conv(ip+xmax*i+j));
			c11(j+2,i+2, :) = i*j*log(result_conv(ip+xmax*i+j));
			c20(j+2,i+2, :) = (3*i^2-2)*log(result_conv(ip+xmax*i+j));
			c02(j+2,i+2, :) = (3*j^2-2)*log(result_conv(ip+xmax*i+j));
			%c00(j+2,i+2)=(5-3*i^2-3*j^2)*log(result_conv_norm(maxY+j, maxX+i));
		end
	end
	c10 = (1/6)*sum(sum(c10));
	c01 = (1/6)*sum(sum(c01));
	c11 = (1/4)*sum(sum(c11));
	c20 = (1/6)*sum(sum(c20));
	c02 = (1/6)*sum(sum(c02));
	%c00=(1/9)*sum(sum(c00));
	
	deltax = squeeze((c11.*c01-2*c10.*c02)./(4*c20.*c02-c11.^2));
	deltay = squeeze((c11.*c10-2*c01.*c20)./(4*c20.*c02-c11.^2));
	peakx = x+deltax;
	peaky = y+deltay;
	
	SubpixelX = peakx-(interrogationarea/2)-SubPixOffset;
	SubpixelY = peaky-(interrogationarea/2)-SubPixOffset;
	
	vector(z, :) = [SubpixelX, SubpixelY];
end

%{
%Problem ist nicht das subpixel-finden. Sondern das integer-finden.....
function [vector] = SUBPIXCENTROID(result_conv, interrogationarea, x, y, z, SubPixOffset)
%was hat peak nr.1 für einen Durchmesser?
%figure;imagesc((1-im2bw(uint8(result_conv(:,:,155)),0.9)).*result_conv(:,:,101))
xi = find(~((x <= (size(result_conv,2)-1)) & (y <= (size(result_conv,1)-1)) & (x >= 2) & (y >= 2)));
x(xi) = [];
y(xi) = [];
z(xi) = [];
xmax = size(result_conv, 2);
vector = NaN(size(result_conv,3), 2);
if(numel(x)~=0)
    ip = sub2ind(size(result_conv), y, x, z);
    
    %%william
    %peak location
   
    for i=1:size(x,1)
try
        mask=im2bw(uint8(result_conv(:,:,i)),0.98);
        marker=false(size(mask));
        marker(y(i),x(i))=true;
        binary_mask = imreconstruct(marker,mask);
        grayscale_peak_only=result_conv(:,:,i).*binary_mask;
        s = regionprops(binary_mask,grayscale_peak_only,{'Centroid','WeightedCentroid'});
        if size(s,1)~=0
        SubpixelX= s.WeightedCentroid(1);
        SubpixelY= s.WeightedCentroid(2);
        SubpixelX= s.Centroid(1);
        SubpixelY= s.Centroid(2);
        else
            SubpixelX= nan;
            SubpixelY= nan
        end
        vector(i, :) = [SubpixelX-(interrogationarea/2)-SubPixOffset, SubpixelY-(interrogationarea/2)-SubPixOffset];
catch
    keyboard
end

    end
end
%}