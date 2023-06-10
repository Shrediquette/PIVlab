function [xtable, ytable, utable, vtable, typevector, correlation_map,correlation_matrices] = piv_FFTmulti (image1,image2,interrogationarea, step, subpixfinder, mask_inpt, roi_inpt,passes,int2,int3,int4,imdeform,repeat,mask_auto,do_linear_correlation,do_correlation_matrices,repeat_last_pass,delta_diff_min)
% For unittests
if nargin == 0
	xtable = localfunctions;
	return
end

%profile on
%this funtion performs the  PIV analysis.
limit_peak_search_area=1; %new in 2.41: Default is to limit the peak search area in pass 2-4.
if repeat == 0
	convert_image_class_type = 'single'; % 'single', 'double': do the cross-correlation with single and not double precision. Saves 50% memory.
else %repeted correlation needs double as type
	convert_image_class_type = 'double';
end

warning off %#ok<*WNOFF> %MATLAB:log:logOfZero
if numel(roi_inpt)>0
	xroi=roi_inpt(1);
	yroi=roi_inpt(2);
	widthroi=roi_inpt(3);
	heightroi=roi_inpt(4);
	image1_roi = image1(yroi:yroi+heightroi,xroi:xroi+widthroi);
	image2_roi = image2(yroi:yroi+heightroi,xroi:xroi+widthroi);
else
	xroi=0;
	yroi=0;
	image1_roi = image1;
	image2_roi = image2;
end
%% Convert image classes (if desired) to save RAM in the FFT correlation with huge images
image1_roi = convert_image_class(image1_roi, convert_image_class_type);
image2_roi = convert_image_class(image2_roi, convert_image_class_type);
% Pad to the first (largest) interrogationarea
pady = ceil(interrogationarea/2);
padx = ceil(interrogationarea/2);
image1_roi = padarray(image1_roi, [pady padx], min(min(image1_roi)));
image2_roi = padarray(image2_roi, [pady padx], min(min(image1_roi)));
image_roi_xs = (1:size(image2_roi,2))  - padx + xroi;
image_roi_ys = (1:size(image2_roi,1))' - pady + yroi;

%% Construct mask as logical array
mask = zeros(size(image1_roi), 'logical');
if numel(mask_inpt)>0
	for i=1:size(mask_inpt,1)
		masklayerx = mask_inpt{i,1};
		masklayery = mask_inpt{i,2};
		mask = mask | poly2mask(masklayerx-xroi+padx,masklayery-yroi+pady,size(image1_roi,1),size(image1_roi,2)); %kleineres eingangsbild und maske geshiftet
	end
end


%% MAINLOOP
max_repetitions=6; %maximum amount of repetitions of the last pass
repetition=0;
%repeat_last_pass=0; %set in GUI: enable repetition of last pass
%delta_diff_min=0.025;  %set in GUI: the quality increase from one pass to the other should at least be this good. This is sort of the slope of the "quality"
delta_diff=1; %initialize with bad value
for multipass = 1:passes
	%this while loop will run at least once. when repeat_last_pass is 0, then the while loop will break after the first execution.
	while  delta_diff > delta_diff_min && repetition < max_repetitions
		if multipass == passes
			repetition=repetition+1; %repetitions are counted only after the last refinement pass finished.
		end
		do_pad = do_linear_correlation==1 && multipass==passes;

		if multipass > 1
			%multipass validation, smoothing
			utable_orig=utable;
			vtable_orig=vtable;
			[utable,vtable] = PIVlab_postproc (utable,vtable,[],[], [], 1,4, 1,1.5);
			
			maskedpoints=numel(find((typevector)==0));
			amountnans=numel(find(isnan(utable)))-maskedpoints;
			discarded=amountnans/(size(utable,1)*size(utable,2))*100;
			if multipass==2 %only display warning after first pass, because later passes are just the interpolation of the interpolation which isn't very informative
				display_warning_msg=[];
				serious_issue=0;
				if discarded > 33 && discarded < 75
					display_warning_msg='Problematic';
				end
				if discarded >= 75 && discarded < 95
					display_warning_msg='Very bad';
					serious_issue=1;
				end
				if discarded >= 95
					display_warning_msg='Catastrophic';
					serious_issue=1;
				end
				if ~isempty (display_warning_msg)
					disp(['WARNING: ' display_warning_msg ' image data, interpass-validation discarded ' num2str(round(discarded)) '% of the vectors in pass nr. ' num2str(multipass) '!'])
					disp(['Try increasing the Pass 1 interrogation area size to ' num2str(interrogationarea*2) ' pixels.'])
					if serious_issue
						beep on
						beep
						commandwindow
					end
				end
			end

			%replace nans
			try
				utable=inpaint_nans(utable,4);
				vtable=inpaint_nans(vtable,4);
				%smooth predictor
				if multipass < passes
					utable = smoothn(utable,0.9); %stronger smoothing for first passes
					vtable = smoothn(vtable,0.9);
				else
					utable = smoothn(utable); %weaker smoothing for last pass(nb: BEFORE the image deformation. So the output is not smoothed!)
					vtable = smoothn(vtable);
				end
			catch
				disp('Error: Could not validate vector data, too few valid vectors.')
			end
		end

		if multipass==2
			interrogationarea = round(int2/2)*2;
			step = interrogationarea/2;
		end
		if multipass==3
			interrogationarea = round(int3/2)*2;
			step = interrogationarea/2;
		end
		if multipass==4
			interrogationarea = round(int4/2)*2;
			step = interrogationarea/2;
		end
		interrogationarea = uint32(interrogationarea);
		step = uint32(step);
		
		%bildkoordinaten neu errechnen:
		%roi=[];

		pady = ceil(interrogationarea/2);
		padx = ceil(interrogationarea/2);
		if multipass==1
			padx_orig = padx;
			pady_orig = pady;
		end

		miniy = 1 + pady_orig;
		minix = 1 + padx_orig;
		maxiy = step*idivide(size(image1_roi,1)-2*pady_orig,step) - (interrogationarea-1) + pady_orig; %statt size deltax von ROI nehmen
		maxix = step*idivide(size(image1_roi,2)-2*padx_orig,step) - (interrogationarea-1) + padx_orig;

		numelementsy = idivide(maxiy-miniy, step) + 1;
		numelementsx = idivide(maxix-minix, step) + 1;

		shift4centery = round((size(image1_roi,1)-maxiy-miniy-2*padx)/2);
		shift4centerx = round((size(image1_roi,2)-maxix-minix-2*padx)/2);
		%shift4center will be negative if in the unshifted case the left border is bigger than the right border. the vectormatrix is hence not centered on the image. the matrix cannot be shifted more towards the left border because then image2_crop would have a negative index. The only way to center the matrix would be to remove a column of vectors on the right side. but then we would have less data....
		miniy = miniy + max(shift4centery, 0);
		minix = minix + max(shift4centerx, 0);
		maxix = maxix + max(shift4centerx, 0);
		maxiy = maxiy + max(shift4centery, 0);

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
			interrogationarea_center = double(interrogationarea/2 + 1);
		else
			interrogationarea_center = double((interrogationarea+1)/2);
		end

		typevector = ones(numelementsy, numelementsx, 'single');
		if multipass == 1
			xtable = zeros(numelementsy,numelementsx, 'single');
			ytable = zeros(numelementsy,numelementsx, 'single');
			utable = zeros(numelementsy,numelementsx, 'single');
			vtable = zeros(numelementsy,numelementsx, 'single');
		end
		xtable_old = xtable(1,:);
		ytable_old = ytable(:,1);
		xtable = single(repmat((minix:step:maxix)  + xroi - padx_orig + interrogationarea/2, numelementsy, 1));
		ytable = single(repmat((miniy:step:maxiy)' + yroi - pady_orig + interrogationarea/2, 1, numelementsx));
		if multipass > 1
			%xtable alt und neu geben koordinaten wo die vektoren herkommen.
			%d.h. u und v auf die gewÃ¯Â¿Â½nschte grÃ¯Â¿Â½Ã¯Â¿Â½e bringen+interpolieren
			try
				utable=interp2(xtable_old,ytable_old,utable,xtable,ytable,'*spline');
				vtable=interp2(xtable_old,ytable_old,vtable,xtable,ytable,'*spline');
			catch
				%msgbox('Error: Most likely, your ROI is too small and/or the interrogation area too large.','modal')
				disp('Error: Most likely, your ROI is too small and/or the interrogation area too large.')
				commandwindow
				utable=zeros(size(xtable));
				vtable=zeros(size(xtable));
			end

			%add 1 line around image for border regions... linear extrap
			X = interp1(1:size(xtable,2), xtable(1,:), 0:size(xtable,2)+1, 'linear', 'extrap');
			Y = interp1(1:size(ytable,1), ytable(:,1), 0:size(ytable,1)+1, 'linear', 'extrap')';
			U = padarray(utable, [1,1], 'replicate'); %interesting portion of u
			V = padarray(vtable, [1,1], 'replicate'); % "" of v
			
			X1 = (X(1):1:X(end)-1);
			Y1 = (Y(1):1:Y(end)-1)';
			X2 = interp2(X,Y,U,X1,Y1,'*linear') + repmat(X1,size(Y1, 1),1);
			Y2 = interp2(X,Y,V,X1,Y1,'*linear') + repmat(Y1,1,size(X1, 2));

			%symmetric interpolation of image A and B
			%X2 = interp2(X,Y,U*0.5,X1,Y1,'*linear') + repmat(X1,size(Y1, 1),1);
			%Y2 = interp2(X,Y,V*0.5,X1,Y1,'*linear') + repmat(Y1,1,size(X1, 2));
			%X2_2 = interp2(X,Y,U*-0.5,X1,Y1,'*linear') + repmat(X1,size(Y1, 1),1);
			%Y2_2 = interp2(X,Y,V*-0.5,X1,Y1,'*linear') + repmat(Y1,1,size(X1, 2));
		end
		% interpolate image2_roi
		if multipass == 1
			image2_crop_i1 = image2_roi(miniy:maxiy+interrogationarea-1, minix:maxix+interrogationarea-1);
			%symmetric interpolation of image A and B
			%image1_crop_i1 = image1_roi(miniy:maxiy+interrogationarea-1, minix:maxix+interrogationarea-1);
		else
			%symmetric interpolation of image A and B
			%image1_crop_i1 = interp2(image_roi_xs,image_roi_ys,image1_roi,X2_2,Y2_2,imdeform); %linear is 3x faster and looks ok...
			image2_crop_i1 = interp2(image_roi_xs,image_roi_ys,image2_roi,X2,Y2,imdeform); %linear is 3x faster and looks ok...
		end
		N = numelementsx * numelementsy;
		result_conv = zeros([interrogationarea, interrogationarea, N], convert_image_class_type);
		correlation_map = zeros([numelementsy, numelementsx], convert_image_class_type);

		BATCHSIZE = 200;
		image1_cut = zeros([interrogationarea interrogationarea BATCHSIZE], convert_image_class_type);
		image2_cut = zeros([interrogationarea interrogationarea BATCHSIZE], convert_image_class_type);
		for batch_offset = 0:BATCHSIZE:N-1
			batch_len = min(BATCHSIZE, N-batch_offset);
			if batch_len < BATCHSIZE
				image1_cut = image1_cut(:,:,1:batch_len);
				image2_cut = image2_cut(:,:,1:batch_len);
			end
			% Divide images into overlapping subimages of fixed size
			for i = 1:batch_len
				[y, x] = ind2sub([numelementsy numelementsx], batch_offset+i);
				xs = (1:interrogationarea) + (x-1) * step;
				ys = (1:interrogationarea) + (y-1) * step;
				image1_cut(:,:,i) = image1_roi(miniy-1+ys, minix-1+xs);
				%symmetric interpolation of image A and B
				%image1_cut(:,:,i) = image1_crop_i1(ys, xs);
				image2_cut(:,:,i) = image2_crop_i1(ys, xs);
			end
			% Calculate correlation strength on the last pass
			if multipass == passes
				correlation_map(batch_offset+(1:batch_len)) = calculate_correlation_map(image1_cut, image2_cut);
			end
			% Do 2D FFT
			result_conv(:,:,batch_offset+(1:batch_len)) = do_correlations(image1_cut, image2_cut, do_pad, interrogationarea);
		end

		%% repeated correlation
		if repeat == 1 && multipass==passes
			ms = round(double(step)/4); %multishift parameter so groÃ wie viertel int window
			%% Shift left bot
			if multipass == 1
				image2_crop_i1 = image2_roi(miniy+ms:maxiy+interrogationarea-1+ms, minix-ms:maxix+interrogationarea-1-ms);
			else
				image2_crop_i1 = interp2(image_roi_xs,image_roi_ys,image2_roi,X2-ms,Y2+ms,imdeform); %linear is 3x faster and looks ok...
			end
			for ix = 1:numelementsx
				for iy = 1:numelementsy
					l = iy + numelementsy * (ix-1);
					xs = (1:interrogationarea) + (ix-1) * step;
					ys = (1:interrogationarea) + (iy-1) * step;
					image1_cut(:,:,l) = image1_roi(miniy-1+ys+ms, minix-1+xs-ms);
					image2_cut(:,:,l) = image2_crop_i1(ys, xs);
				end
			end
			result_convB = do_correlations(image1_cut, image2_cut, do_pad, interrogationarea);
			%figure;imagesc(image1_cut(:,:,100));colormap('gray');figure;imagesc(image2_cut(:,:,100));colormap('gray')
			%% Shift right bot
			if multipass == 1
				image2_crop_i1 = image2_roi(miniy+ms:maxiy+interrogationarea-1+ms, minix+ms:maxix+interrogationarea-1+ms);
			else
				image2_crop_i1 = interp2(image_roi_xs,image_roi_ys,image2_roi,X2+ms,Y2+ms,imdeform); %linear is 3x faster and looks ok...
			end
			for ix = 1:numelementsx
				for iy = 1:numelementsy
					l = iy + numelementsy * (ix-1);
					xs = (1:interrogationarea) + (ix-1) * step;
					ys = (1:interrogationarea) + (iy-1) * step;
					image1_cut(:,:,l) = image1_roi(miniy-1+ys+ms, minix-1+xs+ms);
					image2_cut(:,:,l) = image2_crop_i1(ys, xs);
				end
			end
			result_convC = do_correlations(image1_cut, image2_cut, do_pad, interrogationarea);
			%% Shift left top
			if multipass == 1
				image2_crop_i1 = image2_roi(miniy-ms:maxiy+interrogationarea-1-ms, minix-ms:maxix+interrogationarea-1-ms);
			else
				image2_crop_i1 = interp2(image_roi_xs,image_roi_ys,image2_roi,X2-ms,Y2-ms,imdeform); %linear is 3x faster and looks ok...
			end
			for ix = 1:numelementsx
				for iy = 1:numelementsy
					l = iy + numelementsy * (ix-1);
					xs = (1:interrogationarea) + (ix-1) * step;
					ys = (1:interrogationarea) + (iy-1) * step;
					image1_cut(:,:,l) = image1_roi(miniy-1+ys-ms, minix-1+xs-ms);
					image2_cut(:,:,l) = image2_crop_i1(ys, xs);
				end
			end
			result_convD = do_correlations(image1_cut, image2_cut, do_pad, interrogationarea);
			%% Shift right top
			if multipass == 1
				image2_crop_i1 = image2_roi(miniy-ms:maxiy+interrogationarea-1-ms, minix+ms:maxix+interrogationarea-1+ms);
			else
				image2_crop_i1 = interp2(image_roi_xs,image_roi_ys,image2_roi,X2+ms,Y2-ms,imdeform); %linear is 3x faster and looks ok...
			end
			for ix = 1:numelementsx
				for iy = 1:numelementsy
					l = iy + numelementsy * (ix-1);
					xs = (1:interrogationarea) + (ix-1) * step;
					ys = (1:interrogationarea) + (iy-1) * step;
					image1_cut(:,:,l) = image1_roi(miniy-1+ys-ms, minix-1+xs+ms);
					image2_cut(:,:,l) = image2_crop_i1(ys, xs);
				end
			end
			result_convE = do_correlations(image1_cut, image2_cut, do_pad, interrogationarea);
			%% Combine results
			result_conv = result_conv.*result_convB.*result_convC.*result_convD.*result_convE;
		end

		if multipass == 1
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
				h = h .* result_conv(interrogationarea_center+(-1:1),interrogationarea_center+(-1:1),:);
				result_conv(interrogationarea_center+(-1:1),interrogationarea_center+(-1:1),:) = h;
			end
		else
			%limiting the peak search are in later passes makes sense: Earlier
			%passes use larger interrogation windows. They are therefore
			%statistically more significant, and it is more likely, that the
			%estimated displacement is correct. If we limit the maximum acceptable
			%deviation from this initial guess in later passes, then the result is
			%generally more likely to be correct.
			if limit_peak_search_area == 1
				if floor(size(result_conv,1)/3) >= 3 %if the interrogation area becomes too small, then further limiting of the search area doesnt make sense, because the peak may become as big as the search area
					if mask_auto == 1 %more restricted when "disable autocorrelation" is enabled
						sizeones = 4;
					else %less restrictive for standard correlation settings
						sizeones = floor(size(result_conv,1)/3);
					end

					emptymatrix = zeros(size(result_conv,1),size(result_conv,2), convert_image_class_type);
					emptymatrix(interrogationarea_center + (-sizeones:sizeones), ...
					            interrogationarea_center + (-sizeones:sizeones)) = fspecial('disk', sizeones);
					emptymatrix = emptymatrix / max(max(emptymatrix));

					try
						% result_conv in middle, average correlation value in the remaining space
						mean_result_conv = mean(result_conv, 1:2);
						result_conv = result_conv .* emptymatrix + mean_result_conv .* (1-emptymatrix);
					catch %old matlab releases fail
						for oldmatlab=1:size(result_conv,3)
							mean_result_conv = mean(mean(result_conv(:,:,oldmatlab)));
							result_conv(:,:,oldmatlab) = result_conv(:,:,oldmatlab) .* emptymatrix + mean_result_conv .* (1-emptymatrix);
						end
					end
				end
			end
		end

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
		result_conv = rescale_array(result_conv);

		%apply mask
		masked_xs = (minix:step:maxix) + round(interrogationarea/2);
		masked_ys = (miniy:step:maxiy) + round(interrogationarea/2);
		typevector(mask(masked_ys, masked_xs)) = 0;
		result_conv(:, :, mask(masked_ys, masked_xs)) = 0;
		if multipass == passes
			correlation_map(mask(masked_ys, masked_xs)) = 0;
		end

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

		if subpixfinder==1
			[vector] = SUBPIXGAUSS(result_conv, interrogationarea_center, x1, y1, z1);
		elseif subpixfinder==2
			[vector] = SUBPIX2DGAUSS(result_conv, interrogationarea_center, x1, y1, z1);
		end
		vector = single(reshape(vector, [size(xtable) 2]));

		utable = utable + vector(:,:,1);
		vtable = vtable + vector(:,:,2);

		%compare result to previous pass, do extra passes when delta is not around zero.
		if repetition > 1 %only then we'll have an utable with the same dimension
			deltau=abs(utable_orig-utable);
			deltav=abs(vtable_orig-vtable);
		else
			deltau=0;
			deltav=0;
			old_mean_delta=1;
		end
		mean_delta=nanmean(deltau(:)+deltav(:));
		delta_diff=abs(old_mean_delta-mean_delta);%/abs(mean_delta) %0 --> no improvement, 1 --> 100% improvement
		old_mean_delta=mean_delta;

		if multipass < passes %don't do a repetition when not in the last refining pass.
			break
		end
		if repeat_last_pass==0 %let the while loop only run once when repeat_last_pass is disabled.
			break
		end
	end
	
end


%{
%mal alle daten die ich brauche speichern. Als Beispielsatz. Dann damit experimentieren wie in echt...
%% Hier uncertainty...?
%Die Werte sind viel zu hoch, im Prinzip folgen sie aber den Erwartungen.
Das Problem wird meine Partikelpäarchenfinder sein. Evtl. doch aus dem Beispiel klauen...
%lowpass filter
image1_cut = imfilter(image1_cut,fspecial('gaussian',[3 3]));
image2_cut = imfilter(image2_cut,fspecial('gaussian',[3 3]));

multiplied_images = image1_cut(:,:,:) .* image1_cut(:,:,:);
max_val=max(multiplied_images,[],[1 2]); %maximum for each slice
multiplied_images_binary=imbinarize(multiplied_images./max_val,0.75);
multiplied_images_binary = bwareaopen(multiplied_images_binary, 2); %remove everything with less than n pixels
for islice=1:size(multiplied_images_binary,3)
	multiplied_images_binary(:,:,islice) = bwmorph(multiplied_images_binary(:,:,islice), 'shrink', inf);
end
%remove pixels at borders (otherwise subpixfinder will fail)
multiplied_images_binary(:,1,:)=0;multiplied_images_binary(:,end,:)=0;
multiplied_images_binary(1,:,:)=0;multiplied_images_binary(end,:,:)=0;
amount_of_particles_pairs_per_IA = squeeze(sum(multiplied_images_binary,[1 2]));

%meine koordinaten zeigen nicht zwingend partikel päarchen. wenn es keine partikel päarchen sind, dann wird disparity groß sein

%find all coordinates of particle pairs
[y_img, x_img, z_img] = ind2sub(size(multiplied_images_binary), find(multiplied_images_binary==1));

[peakx_A, peaky_A] = multispot_SUBPIXGAUSS(image1_cut, x_img, y_img, z_img);
[peakx_B, peaky_B] = multispot_SUBPIXGAUSS(image2_cut, x_img, y_img, z_img);

%PRoblem: ich finde peaks an stellen wo particel evtl weit auseinander sind

%{
Each point (i, j) where ? is non-null indicates a particle
image pair; the peak of the corresponding particle images is
detected in I1 and I2 in a ___neighborhood of search radius r___
(typically 1 or 2 pixels), centered in (i, j).
%}

xdisparity=peakx_A-peakx_B;
ydisparity=peaky_A-peaky_B;

%mismatch is limited to 1.5 pixel:
%{
Each point (i, j) where ? is non-null indicates a particle
image pair; the peak of the corresponding particle images is
detected in I1 and I2 in a ___neighborhood of search radius r___
(typically 1 or 2 pixels), centered in (i, j).
%}
xdisparity (xdisparity>1.5 | xdisparity<-1.5)=nan;
ydisparity (ydisparity>1.5 | ydisparity<-1.5)=nan;

total_disparity=(xdisparity.^2+ydisparity.^2).^0.5;



per_slice_stdev=zeros(size(multiplied_images,3),1);
per_slice_mean=zeros(size(multiplied_images,3),1);
for slice_no=1:size(multiplied_images,3)
	%for every slice...
	idx=find(z_img==slice_no);
	per_slice_stdev(slice_no,1)=std(total_disparity(idx),'omitnan');
	per_slice_mean(slice_no,1)=mean(total_disparity(idx),'omitnan');
end

disp_error = sqrt(per_slice_mean.^2  + sqrt(per_slice_stdev ./ sqrt(amount_of_particles_pairs_per_IA)));

%aus vektor mit infos wieder eine matrize machen:
disp_error = permute(reshape(disp_error, [size(xtable')]), [2 1 3]);


figure;imagesc(disp_error);pause(0.1)
figure(getappdata(0,'hgui'))
%sqrt(mean^2+ sqrt(stdev/sqrt(amount_particles))

%there are still some major mismatches in the position... why?
%if the mismatch is larger than 3 pixels: It can't be an uncertainty of particle position...
%because: we identify particles that are visible at the same position in image A and B (ideally, after image deformation all particles should be in identical positions.
%If the disparity is larger than the particle radius, then this can't be real, because then these particles did not have an overlap and something must have gone wrong.


%multiplied_images_binary(y(id),x(id),z(id))

%gg=100;figure;imagesc(multiplied_images(:,:,gg));figure;imagesc(image1_cut(:,:,gg));figure;imagesc(image2_cut(:,:,gg));figure;imagesc(multiplied_images_binary(:,:,gg))
%}


% Output correlation matrices
if do_correlation_matrices==1
	correlation_matrices=result_conv;
else
	correlation_matrices = [];
end
end


%%{
function [vector] = SUBPIXGAUSS(result_conv, interrogationarea_center, x, y, z)
xi = find(~((x <= (size(result_conv,2)-1)) & (y <= (size(result_conv,1)-1)) & (x >= 2) & (y >= 2)));
x(xi) = [];
y(xi) = [];
z(xi) = [];
xmax = size(result_conv, 2);
vector = NaN(size(result_conv,3), 2);
if(numel(x)~=0)
	ip = sub2ind(size(result_conv), y, x, z);
	%the following 8 lines are copyright (c) 1998, Uri Shavit, Roi Gurka, Alex Liberzon, Technion Ã¯Â¿Â½ Israel Institute of Technology
	%http://urapiv.wordpress.com
	f0 = log(result_conv(ip));
	f1 = log(result_conv(ip-1));
	f2 = log(result_conv(ip+1));
	peaky = y + (f1-f2)./(2*f1-4*f0+2*f2);
	f0 = log(result_conv(ip));
	f1 = log(result_conv(ip-xmax));
	f2 = log(result_conv(ip+xmax));
	peakx = x + (f1-f2)./(2*f1-4*f0+2*f2);
	
	SubpixelX = peakx - interrogationarea_center;
	SubpixelY = peaky - interrogationarea_center;
	vector(z, :) = [SubpixelX, SubpixelY];
	
end
end

function [peakx, peaky] = multispot_SUBPIXGAUSS(image_data, x, y, z)
%{
xi = find(~((x <= (size(image_data,2)-1)) & (y <= (size(image_data,1)-1)) & (x >= 2) & (y >= 2)));
x(xi) = [];
y(xi) = [];
z(xi) = [];
%}
xmax = size(image_data, 2);
if(numel(x)~=0)
	ip = sub2ind(size(image_data), y, x, z);
	%the following 8 lines are copyright (c) 1998, Uri Shavit, Roi Gurka, Alex Liberzon, Technion Ã¯Â¿Â½ Israel Institute of Technology
	%http://urapiv.wordpress.com
	f0 = log(image_data(ip));
	f1 = log(image_data(ip-1));
	f2 = log(image_data(ip+1));
	peaky = y + (f1-f2)./(2*f1-4*f0+2*f2);
	f0 = log(image_data(ip));
	f1 = log(image_data(ip-xmax));
	f2 = log(image_data(ip+xmax));
	peakx = x + (f1-f2)./(2*f1-4*f0+2*f2);
end
end
%}

function [vector] = SUBPIX2DGAUSS(result_conv, interrogationarea_center, x, y, z)
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
			%H. Nobach Ã¯Â¿Â½ M. Honkanen (2005)
			%Two-dimensional Gaussian regression for sub-pixel displacement
			%estimation in particle image velocimetry or particle position
			%estimation in particle tracking velocimetry
			%Experiments in Fluids (2005) 38: 511Ã¯Â¿Â½515
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
	
	SubpixelX = peakx - interrogationarea_center;
	SubpixelY = peaky - interrogationarea_center;
	
	vector(z, :) = [SubpixelX, SubpixelY];
end
end


function out = convert_image_class(in,type)
	if strcmp(type,'double')
		out=im2double(in);
	elseif strcmp(type,'single')
		out=im2single(in);
	elseif strcmp(type,'uint8')
		out=im2uint8(in);
	elseif strcmp(type,'uint16')
		out=im2uint16(in);
	end
end

%{
%Problem ist nicht das subpixel-finden. Sondern das integer-finden.....
function [vector] = SUBPIXCENTROID(result_conv, interrogationarea_center, x, y, z)
%was hat peak nr.1 fÃ¼r einen Durchmesser?
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
        vector(i, :) = [SubpixelX-interrogationarea_center, SubpixelY-interrogationarea_center];
catch
    keyboard
end

    end
end
%}


%% Scale an array linearly between 0 and 255 along the third axis.
function A = rescale_array(A)
	minA = min(min(A));
	maxA = max(max(A));
	deltaA = maxA - minA;
	% A = ((A-minA) ./ deltaA) * 255
	A = bsxfun(@rdivide, bsxfun(@minus, A, minA), deltaA) * 255;
end


%% Pad each image in a stack of images with the mean image value
function padded_image = meanzeropad(image, padsize)
	% Subtract mean to avoid high frequencies at border of correlation
	try
		image = image - mean(image, [1 2]);
	catch %old Matlab release
		image_mean = zeros(size(image));
		for oldmatlab = 1:size(image,3)
			image_mean(:,:,oldmatlab) = mean(mean(image(:,:,oldmatlab)));
		end
		image = image - image_mean;
	end
	% Padding (faster than padarray) to get the linear correlation
	padded_image = [image zeros(size(image,1),padsize-1,size(image,3)); zeros(padsize-1,size(image,1)+padsize-1,size(image,3))];
end

%% Correlate two stacks of images using FFT-based convolution
function result_conv = do_correlations(image1_cut, image2_cut, do_pad, padsize)
	orig_size = size(image1_cut);
	if do_pad
		% pad and subtract mean to avoid high frequencies at border of correlation
		image1_cut = meanzeropad(image1_cut, padsize);
		image2_cut = meanzeropad(image2_cut, padsize);
	end
	% 2D FFT to calculate correlation matrix
	result_conv = real(ifft2(conj(fft2(image1_cut)).*fft2(image2_cut)));
	result_conv = fftshift(fftshift(result_conv, 1), 2);
	if do_pad
		% cropping of correlation matrix
		result_conv = result_conv(padsize/2:orig_size(1)-1+padsize/2,padsize/2:orig_size(2)-1+padsize/2,:);
	end
end
	%GPU computing performance test
	%image1_cut_gpu=gpuArray(image1_cut);
	%image2_cut_gpu=gpuArray(image2_cut);
	%tic
	%result_conv_gpu = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut_gpu)).*fft2(image2_cut_gpu))), 1), 2);
	%toc
	%result_conv2=gather(result_conv_gpu);
	%result_conv=result_conv2;
	%for i=1:size(image1_cut,3)
	%	result_conv(:,:,i) = fftshift(fftshift(real(ifft2(conj(fft2(image1_cut(:,:,i))).*fft2(image2_cut(:,:,i)))), 1), 2);
	%end

%% Check whether a shifted version of an array is correctly detected
function test_do_correlations(testCase)
shift_amount = [6 1];
rng(0);
A = rand(20);
B = circshift(A, shift_amount);
result = fftshift(fftshift(do_correlations(A, B, false, 0), 1), 2);
[~, l] = max(result(:));
[i, j] = ind2sub(size(A), l);
% After fftshift, the location [1 1] in the result denotes the unshifted correlation
testCase.verifyEqual([i j], shift_amount + [1 1]);
end


%% Calculate correlation coeficients for a stack of image pairs
function corr_map = calculate_correlation_map(img1, img2)
	validateattributes(img1, {'numeric'}, {'real','3d'}, mfilename, 'img1', 1);
	validateattributes(img2, {'numeric'}, {'real','3d'}, mfilename, 'img2', 2);
	N = size(img1, 3);
	n = size(img1, 1) * size(img1, 2);
	a = reshape(img1, [n N]);
	b = reshape(img2, [n N]);
	mean_a = sum(a) / n;
	mean_b = sum(b) / n;
	corr_map = zeros(N, 1);
	for i=1:N
		% All this is a long, but fast way of calculating
		%   corr_map(i) = corr2(img1(:,:,i), img2(:,:,i))
		a_ = a(:,i) - mean_a(i);
		b_ = b(:,i) - mean_b(i);
		corr_map(i) = sum(a_.*b_) / sqrt(sum(a_.*a_) * sum(b_.*b_));
	end
end

%% Checks for calculate_correlation_map()
function test_calculate_correlation_map(testCase)
rng(0);
A = rand(100);
% Test correlation of matrix with itself is 1.0
testCase.verifyEqual(calculate_correlation_map(A, A), 1);
B = eye(100);
% Test correlation coefficient is independent of matrix scaling and offset
testCase.verifyEqual(calculate_correlation_map(A, B), calculate_correlation_map(3*A-2, B), 'AbsTol', 1e-16);
% Test calculate_correlation_map() is equal to the corr2() function it replaces
testCase.verifyEqual(corr2(A, B), calculate_correlation_map(A, B), 'AbsTol', 1e-16);
end


%% Check simple velocity field
% This test was added to check the improved uvtable interpolation
function test_piv_FFTmulti_uv_interpolation(testCase)
rng(0);
N = 480;
Np = 200;
% Generate two N*N images with a Np*Np patch in the middle
patch = rand(Np);
A = rand(N); B = A;
Pstart = (N-Np)/2+1; Pend = (N+Np)/2;
A(Pstart:Pend, Pstart:Pend) = patch;
B((Pstart:Pend)-25, (Pstart:Pend)+20) = patch; % The patch is shifted by (-25, 20) for the second image
% Smooth images
A = medfilt2(A, [9 9], 'symmetric');
B = medfilt2(B, [9 9], 'symmetric');
% Calculate velocity vectors
[xtable, ytable, utable, vtable] = piv_FFTmulti(A, B, 80, 40, 1, [], [], 3, 40, 20, 0, '*linear', 0, 0, 0, 0, 0, 0);
testCase.assertFalse(any(isnan(utable(:))));
testCase.assertFalse(any(isnan(vtable(:))));
% Verify that velocity vectors are close to actual solution
center_mask = (Pstart <= xtable) .* (xtable <= Pend) .* (Pstart <= ytable) .* (ytable <= Pend);
utable_ref = zeros(size(utable)) + 20*center_mask;
vtable_ref = zeros(size(vtable)) + -25*center_mask;
utable_rms_error = rms(utable-utable_ref, 'all', 'omitnan');
vtable_rms_error = rms(vtable-vtable_ref, 'all', 'omitnan');
testCase.verifyLessThan(utable_rms_error, 5);
testCase.verifyLessThan(vtable_rms_error, 5);
end
