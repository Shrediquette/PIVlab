%Filter velocity vector based on the local image quality
function [u_out,v_out,threshold_suggestion] = PIVlab_image_filter (x,y,u,v,img_filter_thresh,A,B,rawimageA,rawimageB)
%normalize images
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

u_out=u;
v_out=v;

u_out(gq<img_filter_thresh)=nan; %remove vectors where image texture is low.
v_out(gq<img_filter_thresh)=nan;
%{
mainhandle=gcf;
figure;
imagesc(gq)
figure(mainhandle)
%}

%bright area filter
%muss funktionieren ohne bg subtract
%filters vectors that are on an interrogationarea with bright objects.
%threshold muss relativ zu mittlerer bildintensität sein?
lowhighA = stretchlim(rawimageA,[0 0.99]); %set the treshold at the top 1% of the available brightnesses
lowhighB = stretchlim(rawimageB,[0 0.99]);

A_bw=im2bw(rawimageA,lowhighA(2));
B_bw=im2bw(rawimageB,lowhighB(2));
C_bw=(A_bw+B_bw)*0.5;
SE = strel('rectangle',[3 3]);
D_bw = imerode(C_bw,SE);

H = fspecial('average',round(size(A,1)/size(x,1)));
D_bwb = imfilter(D_bw,H,'replicate'); %lowpass the result

%x_orig = 1:size(A,2);
%y_orig = 1:size(A,1);
%[X,Y] = meshgrid(x_orig,y_orig);
D_bwbq = interp2(X,Y,D_bwb,x,y,'nearest'); %scale down result to match size of u and v
u_out(D_bwbq>0.05)=nan; %remove vectors where brightness is high.
v_out(D_bwbq>0.05)=nan;
%^^ der trreshold basiert trotzdem auf relativen helligkeiten...

%{
mainhandle=gcf;
figure;
imagesc(D_bwb)
figure(mainhandle)
%}