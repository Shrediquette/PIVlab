function [xtable ytable utable vtable typevector] = piv_DCC (image1,image2,interrogationarea, step, subpixfinder, mask, roi)
%this funtion performs the DCC PIV analysis. Recent window-deformation
%methods perform better and will maybe be implemented in the future.

%warning off %MATLAB:log:logOfZero
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
    for i=1:size(cellmask,1);
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
if (rem(interrogationarea,2) == 0) %for the subpixel displacement measurement
    SubPixOffset=1;
else
    SubPixOffset=0.5;
end
xtable=zeros(numelementsy,numelementsx);
ytable=xtable;
utable=xtable;
vtable=xtable;
%u2table=xtable;
%v2table=xtable;
%s2n=xtable;
typevector=ones(numelementsy,numelementsx);

%corr_results=cell(numelementsy,numelementsx);

nrx=0;
nrxreal=0;
nry=0;
increments=0;

%% MAINLOOP
try
handles=guihandles(getappdata(0,'hgui'));
catch
end
%parfor loop: divide image into nr_of_cores parts,
%run analyses in parallel, merge the parts...?
%nry ersetzen
%statt j so komisch, eine tabelle machen mit den koordinaten. J muss integer sein


for j = miniy:step:maxiy %vertical loop
    nry=nry+1;
    if increments<6 %reduced display refreshing rate
        increments=increments+1;
    else
        increments=1;
        try
        set(handles.progress, 'string' , ['Frame progress: ' int2str(j/maxiy*100) '%']);drawnow;
        catch
            %fprintf('.');
        end
    end
    for i = minix:step:maxix % horizontal loop
        nrx=nrx+1;%used to determine the pos of the vector in resulting matrix
        if nrxreal < numelementsx
            nrxreal=nrxreal+1;
        else
            nrxreal=1;
        end
        startpoint=[i j];
        image1_crop=image1_roi(j:j+interrogationarea-1, i:i+interrogationarea-1);
        image2_crop=image2_roi(ceil(j-interrogationarea/2):ceil(j+1.5*interrogationarea-1), ceil(i-interrogationarea/2):ceil(i+1.5*interrogationarea-1));
       
        if mask(round(j+interrogationarea/2),round(i+interrogationarea/2))==0
            %improves the clarity of the correlation peak.
            image1_crop=image1_crop-mean(mean(image1_crop));
            image2_crop=image2_crop-mean(mean(image2_crop));
            result_conv= conv2(image2_crop,rot90(conj(image1_crop),2),'valid');
            %image2_crop is bigger than image1_crop. Zeropading is therefore not
            %necessary. 'Valid' makes sure that no zero padded content is
            %returned.
            %result_conv=result_conv/max(max(result_conv))*255; %normalize, peak=always 255
            result_conv = ((result_conv-min(min(result_conv)))/(max(max(result_conv))-min(min(result_conv))))*255;
            %corr_results{nry,nrxreal}=result_conv;
            %Find the 255 peak
            [y,x] = find(result_conv==255);
            if size(x,1)>1 %if there are more than 1 peaks just take the first
                x=x(1:1);
            end
            if size(y,1)>1 %if there are more than 1 peaks just take the first
                y=y(1:1);
            end
            if isnan(y)==0 & isnan(x)==0
                try
                    if subpixfinder==1
                        [vector] = SUBPIXGAUSS (result_conv,interrogationarea,x,y,SubPixOffset);
                    elseif subpixfinder==2
                        [vector] = SUBPIX2DGAUSS (result_conv,interrogationarea,x,y,SubPixOffset);
                    end
                catch
                    vector=[NaN NaN]; %if something goes wrong with cross correlation.....
                end
            else
                vector=[NaN NaN]; %if something goes wrong with cross correlation.....
            end
        else %if mask was not 0 then
            vector=[NaN NaN];
            typevector(nry,nrxreal)=0;
        end

        %Create the vector matrix x, y, u, v
        xtable(nry,nrxreal)=startpoint(1)+interrogationarea/2;
        ytable(nry,:)=startpoint(1,2)+interrogationarea/2;
        utable(nry,nrxreal)=vector(1);
        vtable(nry,nrxreal)=vector(2);
     end

end

xtable=xtable-ceil(interrogationarea/2);
ytable=ytable-ceil(interrogationarea/2);

xtable=xtable+xroi;
ytable=ytable+yroi;

utable(utable>interrogationarea/1.5)=NaN;
vtable(utable>interrogationarea/1.5)=NaN;
vtable(vtable>interrogationarea/1.5)=NaN;
utable(vtable>interrogationarea/1.5)=NaN;

%assignin('base','corr_results',corr_results);
%assignin('base','x',xtable);
%assignin('base','y',ytable);
%assignin('base','u',utable);
%assignin('base','v',vtable);


function [vector] = SUBPIXGAUSS (result_conv,interrogationarea,x,y,SubPixOffset)
if (x <= (size(result_conv,1)-1)) && (y <= (size(result_conv,1)-1)) && (x >= 1) && (y >= 1)
    %the following 8 lines are copyright (c) 1998, Uri Shavit, Roi Gurka, Alex Liberzon, Technion – Israel Institute of Technology
    %http://urapiv.wordpress.com
    f0 = log(result_conv(y,x));
    f1 = log(result_conv(y-1,x));
    f2 = log(result_conv(y+1,x));
    peaky = y+ (f1-f2)/(2*f1-4*f0+2*f2);
    f0 = log(result_conv(y,x));
    f1 = log(result_conv(y,x-1));
    f2 = log(result_conv(y,x+1));
    peakx = x+ (f1-f2)/(2*f1-4*f0+2*f2);
    %
    SubpixelX=peakx-(interrogationarea/2)-SubPixOffset;
    SubpixelY=peaky-(interrogationarea/2)-SubPixOffset;
    vector=[SubpixelX, SubpixelY];
else
    vector=[NaN NaN];
end

function [vector] = SUBPIX2DGAUSS (result_conv,interrogationarea,x,y,SubPixOffset)
if (x <= (size(result_conv,1)-1)) && (y <= (size(result_conv,1)-1)) && (x >= 1) && (y >= 1)
    c10=zeros(3,3);
    c01=c10;
    c11=c10;
    c20=c10;
    c02=c10;
    for i=-1:1
        for j=-1:1
            %following 15 lines based on
            %H. Nobach Æ M. Honkanen (2005)
            %Two-dimensional Gaussian regression for sub-pixel displacement
            %estimation in particle image velocimetry or particle position
            %estimation in particle tracking velocimetry
            %Experiments in Fluids (2005) 38: 511–515
            if i ~= 0
                c10(j+2,i+2)=i*log(result_conv(y+j, x+i));
                c11(j+2,i+2)=i*j*log(result_conv(y+j, x+i));
            end
            if j~=0
                c01(j+2,i+2)=j*log(result_conv(y+j, x+i));
            end
            c20(j+2,i+2)=(3*i^2-2)*log(result_conv(y+j, x+i));
            c02(j+2,i+2)=(3*j^2-2)*log(result_conv(y+j, x+i));
            %c00(j+2,i+2)=(5-3*i^2-3*j^2)*log(result_conv_norm(maxY+j, maxX+i));
        end
    end
    c10=(1/6)*sum(sum(c10));
    c01=(1/6)*sum(sum(c01));
    c11=(1/4)*sum(sum(c11));
    c20=(1/6)*sum(sum(c20));
    c02=(1/6)*sum(sum(c02));
    %c00=(1/9)*sum(sum(c00));
    temp=4*c20*c02-c11^2;
    deltax=(c11*c01-2*c10*c02)/temp;
    deltay=(c11*c10-2*c01*c20)/temp;
    peakx=x+deltax;
    peaky=y+deltay;

    SubpixelX=peakx-(interrogationarea/2)-SubPixOffset;
    SubpixelY=peaky-(interrogationarea/2)-SubPixOffset;
    vector=[SubpixelX, SubpixelY];
else
    vector=[NaN NaN];
end