function [xtable, ytable, output] = piv_corr2 (image1,image2,interrogationarea, step, mask, roi)
if numel(roi)>0
    xroi=roi(1);
    yroi=roi(2);
    widthroi=roi(3);
    heightroi=roi(4);
    image1_roi=double(image1(yroi:yroi+heightroi,xroi:xroi+widthroi));
    image2_roi=double(image2(yroi:yroi+heightroi,xroi:xroi+widthroi));
else
    xroi=0;
    yroi=0;
    image1_roi=double(image1);
    image2_roi=double(image2);
end

if numel(mask)>0
    cellmask=mask;
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

xtable=zeros(numelementsy,numelementsx);
ytable=xtable;

nrx=0;
nrxreal=0;
nry=0;
%% MAINLOOP
for j = miniy:step:maxiy %vertical loop
    nry=nry+1;
    for i = minix:step:maxix % horizontal loop
        nrx=nrx+1;%used to determine the pos of the vector in resulting matrix
        if nrxreal < numelementsx
            nrxreal=nrxreal+1;
        else
            nrxreal=1;
        end
        startpoint=[i j];
        image1_crop=image1_roi(j:j+interrogationarea-1, i:i+interrogationarea-1);
        image2_crop=image2_roi(j:j+interrogationarea-1, i:i+interrogationarea-1);
        if mask(round(j+interrogationarea/2),round(i+interrogationarea/2))==0
            result_corr= corr2(image2_crop,image1_crop);
        else %if mask was not 0 then
            output(nry,nrxreal)=result_corr;
        end
        
        output(nry,nrxreal)=result_corr;
                xtable(nry,nrxreal)=startpoint(1)+interrogationarea/2;
        ytable(nry,:)=startpoint(1,2)+interrogationarea/2;
    end
    
end

xtable=xtable-ceil(interrogationarea/2);
ytable=ytable-ceil(interrogationarea/2);

xtable=xtable+xroi;
ytable=ytable+yroi;


