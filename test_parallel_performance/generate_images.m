function generate_images (outputpath,amount,size)
selpath = outputpath;
noise = 0.0005; %noise 0 bis 0.05
z_move=10; %z_move
partAm=size^2*0.01;
Z=0.333; %sheet thickness
dt=3; %particle diameter
ddt=1; %particle diameter variation

for iiii = 0:amount-1
disp(['Progress: ' int2str(iiii/amount*100) ' %']);
	%% Generate random artificial particle images
	u = rand(1)*ones(size,size);
	v = rand(1)*ones(size,size);
	offsety=v; %zero displacement in y direction
	offsetx=u; %uniform x displacement increases from 0 to 99/10 pixels
	[x,y]=meshgrid(1:1:size);
	i=[];
	j=[];
	sizey=size;
	sizex=size;
	A=zeros(sizey,sizex);
	B=A;
	z0_pre=randn(partAm,1); %normal distributed sheet intensity
	randn('state', sum(100*clock)); %#ok<*RAND>
	z1_pre=randn(partAm,1); %normal distributed sheet intensity
	z0=z0_pre*(z_move/200+0.5)+z1_pre*(1-((z_move/200+0.5)));
	z1=z1_pre*(z_move/200+0.5)+z0_pre*(1-((z_move/200+0.5)));
	
	I0=255*exp(-(Z^2./(0.125*z0.^2))); %particle intensity
	I0(I0>255)=255;
	I0(I0<0)=0;
	
	I1=255*exp(-(Z^2./(0.125*z1.^2))); %particle intensity
	I1(I1>255)=255;
	I1(I1<0)=0;
	
	randn('state', sum(100*clock));
	d=randn(partAm,1)/2; %particle diameter distribution
	d=dt+d*ddt;
	d(d<0)=0;
	rand('state', sum(100*clock));
	x0=rand(partAm,1)*sizex;
	y0=rand(partAm,1)*sizey;
	rd = -8.0 ./ d.^2;
	
	xlimit1=floor(x0-d/2); %x min particle extent image1
	xlimit2=ceil(x0+d/2); %x max particle extent image1
	ylimit1=floor(y0-d/2); %y min particle extent image1
	ylimit2=ceil(y0+d/2); %y max particle extent image1
	xlimit2(xlimit2>sizex)=sizex;
	xlimit1(xlimit1<1)=1;
	ylimit2(ylimit2>sizey)=sizey;
	ylimit1(ylimit1<1)=1;
	
	%calculate particle extents for image2 (shifted image)
	x0integer=round(x0);
	x0integer(x0integer>sizex)=sizex;
	x0integer(x0integer<1)=1;
	y0integer=round(y0);
	y0integer(y0integer>sizey)=sizey;
	y0integer(y0integer<1)=1;
	
	xlimit3=zeros(partAm,1);
	xlimit4=xlimit3;
	ylimit3=xlimit3;
	ylimit4=xlimit3;
	for n=1:partAm
		xlimit3(n,1)=floor(x0(n)-d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x min particle extent image2
		xlimit4(n,1)=ceil(x0(n)+d(n)/2-offsetx((y0integer(n)),(x0integer(n)))); %x max particle extent image2
		ylimit3(n,1)=floor(y0(n)-d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y min particle extent image2
		ylimit4(n,1)=ceil(y0(n)+d(n)/2-offsety((y0integer(n)),(x0integer(n)))); %y max particle extent image2
	end
	xlimit3(xlimit3<1)=1;
	xlimit4(xlimit4>sizex)=sizex;
	ylimit3(ylimit3<1)=1;
	ylimit4(ylimit4>sizey)=sizey;
	
	ctr=0;
	for n=1:partAm
		ctr=ctr+1;
		if ctr==10000
			ctr=0;
			%fprintf('.')
		end
		r = rd(n);
		for j=xlimit1(n):xlimit2(n)
			rj = (j-x0(n))^2;
			for i=ylimit1(n):ylimit2(n)
				A(i,j)=A(i,j)+I0(n)*exp((rj+(i-y0(n))^2)*r);
			end
		end
		for j=xlimit3(n):xlimit4(n)
			for i=ylimit3(n):ylimit4(n)
				B(i,j)=B(i,j)+I1(n)*exp((-(j-x0(n)+offsetx(i,j))^2-(i-y0(n)+offsety(i,j))^2)*-rd(n)); %place particle with gaussian intensity profile
			end
		end
	end
	
	
	%% Create random Background "glow"
	bg=im2bw(rand(size,size),0.99999);
	SE = strel('line',round(rand*90)+90,round(rand*180));
	bg2=imdilate(bg,SE);
	bg3 = imgaussfilt(double(bg2),40);
	bg3=bg3/max(max(bg3));
	bg3=bg3*0.1;
	bg=im2bw(rand(size,size),0.999997);
	SE = strel('disk',round(rand*100)+200,4);
	bg2=imdilate(bg,SE);
	bg4 = 0.12*imgaussfilt(double(bg2),100);
	bg3(isnan(bg3))=0;
	bg4(isnan(bg4))=0;
	
	A=A+bg3*rand*255+bg4*rand*255;
	B=B+bg3*rand*255+bg4*rand*255;
	
	A(A>255)=255;
	B(B>255)=255;
	A=imnoise(uint8(A),'gaussian',0,noise);
	B=imnoise(uint8(B),'gaussian',0,noise);
	
	A=uint8(A);
	B=uint8(B);
	
	%True velocities, save if desired
	x_real=x;
	y_real=y;
	u_real=u;
	v_real=v;
	
	imwrite(A,[selpath '\synth_image_' sprintf('%5.5d',iiii) '_A.jpg'],'Quality',97);
	imwrite(B,[selpath '\synth_image_' sprintf('%5.5d',iiii) '_B.jpg'],'Quality',97);
	
end

