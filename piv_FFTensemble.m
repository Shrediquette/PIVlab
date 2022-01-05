function [xtable, ytable, utable, vtable, typevector,correlation_map] = piv_FFTensemble (autolimit,filepath,video_frame_selection,bg_img_A,bg_img_B,clahe,highp,intenscap,clahesize,highpsize,wienerwurst,wienerwurstsize,roi_inpt,maskiererx,maskierery,interrogationarea,step,subpixfinder,passes,int2,int3,int4,mask_auto,imdeform,repeat,do_pad)
%this funtion performs the  PIV analysis. It is a modification of the
%pivFFTmulti, and will do ensemble correlation. That is a suitable
%algorithm for low seeding density as it happens in microPIV.
warning off %#ok<*WNOFF> %MATLAB:log:logOfZero
%% pre-processing is done in this function
result_conv_ensemble = zeros(interrogationarea,interrogationarea); % prepare empty result_conv
if isempty(video_frame_selection) %list with image files was passed
	amount_input_imgs=size(filepath,1);
else
	amount_input_imgs=numel(video_frame_selection);
end
total_analyses_amount=amount_input_imgs / 2 * passes;
from_total = 0;
tic
skippy=0;
for ensemble_i1=1:2:amount_input_imgs
	if isempty(video_frame_selection) %list with image files was passed
		%detect if it is b16 or standard pixel image
		[~,~,ext] = fileparts(filepath{1});
		if strcmp(ext,'.b16')
			image1=f_readB16(filepath{ensemble_i1});
			image2=f_readB16(filepath{ensemble_i1+1});
		else
			image1=imread(filepath{ensemble_i1});
			image2=imread(filepath{ensemble_i1+1});
		end
	else % video file was passed
		image1 = read(filepath,video_frame_selection(ensemble_i1));
		image2 = read(filepath,video_frame_selection(ensemble_i1+1));
	end
	if size(image1,3)>1
		image1=uint8(mean(image1,3));
		image2=uint8(mean(image2,3));
		%disp('Warning: To optimize speed, your images should be grayscale, 8 bit!')
	end
	%Subtract background (if existent)
	if ~isempty(bg_img_A)
		image1=image1-bg_img_A;
	end
	if ~isempty(bg_img_B)
		image2=image2-bg_img_B;
	end
	%if autolimit == 1 %if autolimit is desired: do autolimit for each image seperately
		if size(image1,3)>1
			stretcher = stretchlim(rgb2gray(image1));
		else
			stretcher = stretchlim(image1);
		end
		minintens1 = stretcher(1);
		maxintens1 = stretcher(2);
		if size(image2,3)>1
			stretcher = stretchlim(rgb2gray(image2));
		else
			stretcher = stretchlim(image2);
		end
		minintens2 = stretcher(1);
		maxintens2 = stretcher(2);
	%end
	image1 = PIVlab_preproc (image1,roi_inpt,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens1,maxintens1);
	image2 = PIVlab_preproc (image2,roi_inpt,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens2,maxintens2);
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
	%prepare a matrix for calculating the average mask of all images
	if ensemble_i1==1
		average_mask=zeros(size(image1_roi));
	end
	%get mask from mask list
	ximask={};
	yimask={};
	if size(maskiererx,2)>=ensemble_i1
		for j=1:size(maskiererx,1)
			if isempty(maskiererx{j,ensemble_i1})==0
				ximask{j,1}=maskiererx{j,ensemble_i1}; %#ok<*AGROW>
				yimask{j,1}=maskierery{j,ensemble_i1};
			else
				break
			end
		end
		if size(ximask,1)>0
			mask_inpt=[ximask yimask];
		else
			mask_inpt=[];
		end
	else
		mask_inpt=[];
	end
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
	try
		average_mask=average_mask + mask; %will fail if images are not same dimensions.
	catch
		cancel = 1;
		hgui=getappdata(0,'hgui');
		setappdata(hgui, 'cancel', cancel);
		text(gca(getappdata(0,'hgui')),10,10,'Error: Image dimensions inconsistent!','color',[1 0 0],'fontsize',20)
		drawnow;
		break
	end
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
		hgui=getappdata(0,'hgui');
		cancel=getappdata(hgui, 'cancel');
		if cancel == 1
			break
			%disp('user cancelled');
		end
		
	catch %#ok<CTCH>
		GUI_avail=0;
		disp('no GUI')
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
	
	if mask_auto == 1
		%das zentrum der Matrize (3x3) mit dem mittelwert ersetzen = Keine Autokorrelation
		%MARKER
		h = fspecial('gaussian', 3, 1.5);
		h=h/h(2,2);
		h=1-h;
		%h=repmat(h,1,1,size(result_conv,3));
		h=repmat(h,[1,1,size(result_conv,3)]);
		h=h.*result_conv((interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,(interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,:);
		result_conv((interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,(interrogationarea/2)+SubPixOffset-1:(interrogationarea/2)+SubPixOffset+1,:)=h;
	end
	%apply mask
	ii = find(mask(ss1(round(interrogationarea/2+1), round(interrogationarea/2+1), :)));
	result_conv(:,:, ii) = 0;
	%average the correlation matrices
	try
		result_conv_ensemble=result_conv_ensemble+result_conv;
	catch % older matlab releases
		result_conv_ensemble = zeros(size(result_conv));
		result_conv_ensemble=result_conv_ensemble+result_conv;
	end
	
	if GUI_avail==1
		progri=ensemble_i1/(amount_input_imgs)*100;
		from_total=from_total+1;
		set(handles.progress, 'string' , ['Pass ' int2str(1) ' progress: ' int2str(progri) '%' ])
		set(handles.overall, 'string' , ['Total progress: ' int2str(from_total / total_analyses_amount * 100) '%'])
		zeit=toc;
		done=from_total;
		tocome=total_analyses_amount-done;
		zeit=zeit/done*tocome;
		hrs=zeit/60^2;
		mins=(hrs-floor(hrs))*60;
		secs=(mins-floor(mins))*60;
		hrs=floor(hrs);
		mins=floor(mins);
		secs=floor(secs);
		set(handles.totaltime,'string', ['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
		
		%xxx update display every 10 frames...?
		%aber wie, dann müsste man peakfinder machen
		if skippy ==0
			[xtable,ytable,utable, vtable] = peakfinding (result_conv_ensemble, mask, interrogationarea,minix,step,maxix,miniy,maxiy,SubPixOffset,ss1,subpixfinder);
			if verLessThan('matlab','8.4')
				delete (findobj(getappdata(0,'hgui'),'type', 'hggroup'))
			else
				delete (findobj(getappdata(0,'hgui'),'type', 'quiver'))
			end
			hold on;
			vecscale=str2double(get(handles.vectorscale,'string'));
			%Problem: wenn colorbar an, zï¿½hlt das auch als aexes...
			colorbar('off')
			
			%u_table original gibts nicjt, braichts auch nicht...
			quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==0)+xroi-interrogationarea/2,ytable(isnan(utable)==0)+yroi-interrogationarea/2,utable(isnan(utable)==0)*vecscale,vtable(isnan(utable)==0)*vecscale,'Color', [1-(from_total / total_analyses_amount) (from_total / total_analyses_amount) 0.15],'autoscale','off')
			%quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==1)+xroi-interrogationarea/2,ytable(isnan(utable)==1)+yroi-interrogationarea/2,utable(isnan(utable)==1)*vecscale,vtable(isnan(utable)==1)*vecscale,'Color',[0.7 0.15 0.15], 'autoscale','off')
			hold off
			drawnow;
		end
		if skippy <10
			skippy=skippy+1;
		else
			skippy=0;
		end
		try
			drawnow limitrate
		catch
			drawnow
		end
	else
		fprintf('.');
	end
	if passes==1 % only 1 pass selected, so correlation coefficient will be calculated in this (first & final) pass.
		if ensemble_i1==1 %first image pair
			correlation_map=zeros(size(typevector));
			corr_map_cnt=0;
		end
		for cor_i=1:size(image1_cut,3)
			correlation_map(cor_i)=correlation_map(cor_i) + corr2(image1_cut(:,:,cor_i),image2_cut(:,:,cor_i));
		end
		corr_map_cnt=corr_map_cnt+1;
	end
end
%correlation_map=[];
if cancel == 0
	%% Correlation matrix of pass 1 is done.
	[xtable,ytable,utable, vtable] = peakfinding (result_conv_ensemble, mask, interrogationarea,minix,step,maxix,miniy,maxiy,SubPixOffset,ss1,subpixfinder);
	
	for multipass=1:passes-1
		% unfortunately, preprocessing has to be done again for every pass, otherwise i would have to save the modified data somehow.
		if multipass==1
			interrogationarea=round(int2/2)*2;
		end
		if multipass==2
			interrogationarea=round(int3/2)*2;
		end
		if multipass==3
			interrogationarea=round(int4/2)*2;
		end
		result_conv_ensemble = zeros(interrogationarea,interrogationarea); % prepare empty result_conv
		skippy=0;
		for ensemble_i1=1:2:amount_input_imgs
			if skippy <10
				skippy=skippy+1;
			else
				skippy=0;
			end
			if isempty(video_frame_selection) %list with image files was passed
				if strcmp(ext,'.b16')
					image1=f_readB16(filepath{ensemble_i1});
					image2=f_readB16(filepath{ensemble_i1+1});
				else
					image1=imread(filepath{ensemble_i1});
					image2=imread(filepath{ensemble_i1+1});
				end
			else % video file was passed
				image1 = read(filepath,video_frame_selection(ensemble_i1));
				image2 = read(filepath,video_frame_selection(ensemble_i1+1));
			end
			if size(image1,3)>1
				image1=uint8(mean(image1,3));
				image2=uint8(mean(image2,3));
			end
			%subtract bg if present
			if ~isempty(bg_img_A)
				image1=image1-bg_img_A;
			end
			if ~isempty(bg_img_B)
				image2=image2-bg_img_B;
			end
			%if autolimit == 1 %if autolimit is desired: do autolimit for each image seperately
				if size(image1,3)>1
					stretcher = stretchlim(rgb2gray(image1));
				else
					stretcher = stretchlim(image1);
				end
				minintens1 = stretcher(1);
				maxintens1 = stretcher(2);
				if size(image2,3)>1
					stretcher = stretchlim(rgb2gray(image2));
				else
					stretcher = stretchlim(image2);
				end
				minintens2 = stretcher(1);
				maxintens2 = stretcher(2);
			%end
			image1 = PIVlab_preproc (image1,roi_inpt,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens1,maxintens1);
			image2 = PIVlab_preproc (image2,roi_inpt,clahe, clahesize,highp,highpsize,intenscap,wienerwurst,wienerwurstsize,minintens2,maxintens2);
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
			if GUI_avail==1
				progri=ensemble_i1/(amount_input_imgs)*100;
				from_total=from_total+1;
				set(handles.progress, 'string' , ['Pass ' int2str(multipass+1) ' progress: ' int2str(progri) '%' ])
				set(handles.overall, 'string' , ['Total progress: ' int2str(from_total / total_analyses_amount * 100) '%'])
				
				zeit=toc;
				done=from_total;
				tocome=total_analyses_amount-done;
				zeit=zeit/done*tocome;
				hrs=zeit/60^2;
				mins=(hrs-floor(hrs))*60;
				secs=(mins-floor(mins))*60;
				hrs=floor(hrs);
				mins=floor(mins);
				secs=floor(secs);
				set(handles.totaltime,'string', ['Time left: ' sprintf('%2.2d', hrs) 'h ' sprintf('%2.2d', mins) 'm ' sprintf('%2.2d', secs) 's']);
				try
					drawnow limitrate
					
				catch
					drawnow
				end
			else
				fprintf('.');
			end
			%multipass validation, smoothing
			utable_orig=utable;
			vtable_orig=vtable;
			[utable,vtable] = PIVlab_postproc (utable,vtable,[],[], [], 1,4, 1,1.5);
			if GUI_avail==1
				cancel=getappdata(hgui, 'cancel');
				if cancel == 1
					break
					%disp('user cancelled');
				end
				if skippy ==0
					if verLessThan('matlab','8.4')
						delete (findobj(getappdata(0,'hgui'),'type', 'hggroup'))
					else
						delete (findobj(getappdata(0,'hgui'),'type', 'quiver'))
					end
					hold on;
					vecscale=str2double(get(handles.vectorscale,'string'));
					%Problem: wenn colorbar an, zï¿½hlt das auch als aexes...
					colorbar('off')
					quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==0)+xroi-interrogationarea/2,ytable(isnan(utable)==0)+yroi-interrogationarea/2,utable(isnan(utable)==0)*vecscale,vtable(isnan(utable)==0)*vecscale,'Color', [1-(from_total / total_analyses_amount) (from_total / total_analyses_amount) 0.15],'autoscale','off')
					
					%                    quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==0)+xroi-interrogationarea/2,ytable(isnan(utable)==0)+yroi-interrogationarea/2,utable_orig(isnan(utable)==0)*vecscale,vtable_orig(isnan(utable)==0)*vecscale,'Color', [0.15 0.7 0.15],'autoscale','off')
					%quiver ((findobj(getappdata(0,'hgui'),'type', 'axes')),xtable(isnan(utable)==1)+xroi-interrogationarea/2,ytable(isnan(utable)==1)+yroi-interrogationarea/2,utable_orig(isnan(utable)==1)*vecscale,vtable_orig(isnan(utable)==1)*vecscale,'Color',[0.7 0.15 0.15], 'autoscale','off')
					drawnow
					hold off
				end
			end
			%replace nans
			utable=inpaint_nans(utable,4);
			vtable=inpaint_nans(vtable,4);
			%smooth predictor
			try
				if multipass<passes-1
					utable = smoothn(utable,0.6); %stronger smoothing for first passes
					vtable = smoothn(vtable,0.6);
				else
					utable = smoothn(utable); %weaker smoothing for last pass
					vtable = smoothn(vtable);
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
			image1_roi = gen_image1_roi;
			image2_roi = gen_image2_roi;
			%get mask from mask list
			ximask={};
			yimask={};
			if size(maskiererx,2)>=ensemble_i1
				for j=1:size(maskiererx,1)
					if isempty(maskiererx{j,ensemble_i1})==0
						ximask{j,1}=maskiererx{j,ensemble_i1}; %#ok<*AGROW>
						yimask{j,1}=maskierery{j,ensemble_i1};
					else
						break
					end
				end
				if size(ximask,1)>0
					mask_inpt=[ximask yimask];
				else
					mask_inpt=[];
				end
			else
				mask_inpt=[];
			end
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
			
			xtable_old=xtable;
			ytable_old=ytable;
			typevector=ones(numelementsy,numelementsx);
			xtable = repmat((minix:step:maxix), numelementsy, 1) + interrogationarea/2;
			ytable = repmat((miniy:step:maxiy)', 1, numelementsx) + interrogationarea/2;
			
			%xtable alt und neu geben koordinaten wo die vektoren herkommen.
			%d.h. u und v auf die gewï¿½nschte grï¿½ï¿½e bringen+interpolieren
			
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
						for oldmatlab=1:size(image1_cut,3);
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
						for oldmatlab=1:size(image1_cut,3)
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
			
			
			if mask_auto == 1
				%limit peak search arena....
				emptymatrix=zeros(size(result_conv,1),size(result_conv,2),size(result_conv,3));
				%emptymatrix=emptymatrix+0.1;
				if interrogationarea > 8 % masking central peak will not work for extrmely small interrogation areas. And it also doesn't make sense.
					sizeones=4;
					%h = fspecial('gaussian', sizeones*2+1,1);
					h=fspecial('disk',4);
					h=h/max(max(h));
					%h=repmat(h,1,1,size(result_conv,3));
					h=repmat(h,[1,1,size(result_conv,3)]);
					emptymatrix((interrogationarea/2)+SubPixOffset-sizeones:(interrogationarea/2)+SubPixOffset+sizeones,(interrogationarea/2)+SubPixOffset-sizeones:(interrogationarea/2)+SubPixOffset+sizeones,:)=h;
					result_conv = result_conv .* emptymatrix;
				else
					disp('All interrogation areas must be larger than 8 pixels for disabling auto correlation successfully.')
				end
			end
			
			%apply mask ---
			ii = find(mask(ss1(round(interrogationarea/2+1), round(interrogationarea/2+1), :)));
			result_conv(:,:, ii) = 0;
			%add alle result_conv
			try
				result_conv_ensemble=result_conv_ensemble+result_conv;
			catch % older matlab releases
				result_conv_ensemble = zeros(size(result_conv));
				result_conv_ensemble=result_conv_ensemble+result_conv;
			end
			
			if multipass==passes-1 %correlation strength only in last pass
				
				if ensemble_i1==1 %first image pair
					correlation_map=zeros(size(typevector));
					corr_map_cnt=0;
				end
				%Correlation strength
				for cor_i=1:size(image1_cut,3)
					correlation_map(cor_i)=correlation_map(cor_i)+corr2(image1_cut(:,:,cor_i),image2_cut(:,:,cor_i));
				end
				corr_map_cnt=corr_map_cnt+1;
			end
		end
		[xtable,ytable,utable2, vtable2] = peakfinding (result_conv_ensemble, [], interrogationarea,minix,step,maxix,miniy,maxiy,SubPixOffset,ss1,subpixfinder);
		utable = utable+utable2;
		vtable = vtable+vtable2;
	end
	if cancel == 0
		%mask only if all frames are masked
		%apply mask
		nrx=0;
		nrxreal=0;
		nry=0;
		average_mask=padarray(average_mask,[ceil(interrogationarea/2) ceil(interrogationarea/2)],0);
		for jmask = miniy:step:maxiy %vertical loop
			nry=nry+1;
			for imask = minix:step:maxix % horizontal loop
				nrx=nrx+1;%used to determine the pos of the vector in resulting matrix
				if nrxreal < numelementsx
					nrxreal=nrxreal+1;
				else
					nrxreal=1;
				end
				%fehlerzeile:
				if average_mask(round(jmask+interrogationarea/2),round(imask+interrogationarea/2)) >= amount_input_imgs/2
					typevector(nry,nrxreal)=0;
				end
			end
		end
		xtable=xtable-ceil(interrogationarea/2);
		ytable=ytable-ceil(interrogationarea/2);
		
		xtable=xtable+xroi;
		ytable=ytable+yroi;
	end
	%% Write correlation matrices to the workspace
	%{
try
    counter=evalin('base','counter');
    counter=counter+1;
    assignin('base','counter',counter);
    all_matrices=evalin('base','all_matrices');
    all_matrices{end+1}=result_conv_ensemble;
    assignin('base','all_matrices',all_matrices);
    disp('appended matrix')
catch
    assignin('base','counter',1);
    all_matrices{1}=result_conv_ensemble;
    assignin('base','all_matrices',all_matrices);
    disp('created new matrix')
end
	%}
	correlation_map = permute(reshape(correlation_map, [size(xtable')]), [2 1 3])/corr_map_cnt;
	%clear Correlation map in masked area
	correlation_map(typevector==0) = 0;
end



function [xtable,ytable,utable, vtable] = peakfinding (result_conv_ensemble, mask, interrogationarea,minix,step,maxix,miniy,maxiy,SubPixOffset,ss1,subpixfinder)
minres = permute(repmat(squeeze(min(min(result_conv_ensemble))), [1, size(result_conv_ensemble, 1), size(result_conv_ensemble, 2)]), [2 3 1]);
deltares = permute(repmat(squeeze(max(max(result_conv_ensemble))-min(min(result_conv_ensemble))),[ 1, size(result_conv_ensemble, 1), size(result_conv_ensemble, 2)]), [2 3 1]);
result_conv_ensemble = ((result_conv_ensemble-minres)./deltares)*255;

%apply mask ---
if isempty (mask)==0
	ii = find(mask(ss1(round(interrogationarea/2+1), round(interrogationarea/2+1), :)));
	result_conv_ensemble(:,:, ii) = 0;
end

[y, x, z] = ind2sub(size(result_conv_ensemble), find(result_conv_ensemble==255));

% we need only one peak from each couple pictures
[z1, zi] = sort(z);
dz1 = [z1(1); diff(z1)];
i0 = find(dz1~=0);
x1 = x(zi(i0));
y1 = y(zi(i0));
z1 = z(zi(i0));

xtable = repmat((minix:step:maxix)+interrogationarea/2, length(miniy:step:maxiy), 1);
ytable = repmat(((miniy:step:maxiy)+interrogationarea/2)', 1, length(minix:step:maxix));

if subpixfinder==1
	[vector] = SUBPIXGAUSS (result_conv_ensemble,interrogationarea, x1, y1, z1, SubPixOffset);
elseif subpixfinder==2
	[vector] = SUBPIX2DGAUSS (result_conv_ensemble,interrogationarea, x1, y1, z1, SubPixOffset);
end
vector = permute(reshape(vector, [size(xtable') 2]), [2 1 3]);

utable = vector(:,:,1);
vtable = vector(:,:,2);



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