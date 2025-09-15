function generate_it_Callback(~, ~, ~)
handles=gui.gethand;
flow_sim=get(handles.flow_sim,'value');
switch flow_sim
	case 1 %rankine
		v0 = str2double(get(handles.rank_displ,'string')); %max velocity
		vortexplayground=[str2double(get(handles.img_sizex,'string')),str2double(get(handles.img_sizey,'string'))]; %width, height)
		center1=[str2double(get(handles.rankx1,'string')),str2double(get(handles.ranky1,'string'))]; %x,y
		center2=[str2double(get(handles.rankx2,'string')),str2double(get(handles.ranky2,'string'))]; %x,y
		[x,y]=meshgrid(-center1(1):vortexplayground(1)-center1(1)-1,-center1(2):vortexplayground(2)-center1(2)-1);
		[o,r] = cart2pol(x,y);
		uo=zeros(size(x));
		R0 = str2double(get(handles.rank_core,'string')); %radius %35
		uoin = (r <= R0);
		uout = (r > R0);
		uo = uoin+uout;
		uo(uoin) =  v0*r(uoin)/R0;
		uo(uout) =  v0*R0./r(uout);
		uo(isnan(uo))=0;
		u = -uo.*sin(o);
		v = uo.*cos(o);
		if get(handles.singledoublerankine,'value')==2
			[x,y]=meshgrid(-center2(1):vortexplayground(1)-center2(1)-1,-center2(2):vortexplayground(2)-center2(2)-1);
			[o,r] = cart2pol(x,y);
			uo=zeros(size(x));
			R0 = str2double(get(handles.rank_core,'string')); %radius %35
			uoin = (r <= R0);
			uout = (r > R0);
			uo = uoin+uout;
			uo(uoin) =  v0*r(uoin)/R0;
			uo(uout) =  v0*R0./r(uout);
			uo(isnan(uo))=0;
			u2 = -uo.*sin(o);
			v2 = uo.*cos(o);
			u=u-u2;
			v=v-v2;
		end
	case 2 %oseen
		v0 = str2double(get(handles.oseen_displ,'string'))*3; %max velocity
		vortexplayground=[str2double(get(handles.img_sizex,'string')),str2double(get(handles.img_sizey,'string'))]; %width, height)
		center1=[str2double(get(handles.oseenx1,'string')),str2double(get(handles.oseeny1,'string'))]; %x,y
		center2=[str2double(get(handles.oseenx2,'string')),str2double(get(handles.oseeny2,'string'))]; %x,y
		[x,y]=meshgrid(-center1(1):vortexplayground(1)-center1(1)-1,-center1(2):vortexplayground(2)-center1(2)-1);
		[o,r] = cart2pol(x,y);
		uo=zeros(size(x));
		zaeh=1;
		t=str2double(get(handles.oseen_time,'string'));
		r=r/100;

		%uo wird im zwentrum NaN!!
		uo=(v0./(2*pi*r)).*(1-exp(-r.^2/(4*zaeh*t)));
		uo(isnan(uo))=0;
		u = -uo.*sin(o);
		v = uo.*cos(o);
		if get(handles.singledoubleoseen,'value')==2
			[x,y]=meshgrid(-center2(1):vortexplayground(1)-center2(1)-1,-center2(2):vortexplayground(2)-center2(2)-1);
			[o,r] = cart2pol(x,y);
			r=r/100;
			uo=(v0./(2*pi*r)).*(1-exp(-r.^2/(4*zaeh*t)));
			uo(isnan(uo))=0;
			u2 = -uo.*sin(o);
			v2 = uo.*cos(o);
			u=u-u2;
			v=v-v2;
		end
	case 3 %linear
		u=zeros(str2double(get(handles.img_sizey,'string')),str2double(get(handles.img_sizex,'string')));
		v(1:str2double(get(handles.img_sizey,'string')),1:str2double(get(handles.img_sizex,'string')))=str2double(get(handles.shiftdisplacement,'string'));
	case 4 % rotation
		[v,u] = meshgrid(-(str2double(get(handles.img_sizex,'string')))/2:1:(str2double(get(handles.img_sizex,'string')))/2-1,-(str2double(get(handles.img_sizey,'string')))/2:1:(str2double(get(handles.img_sizey,'string')))/2-1);

		u=u/max(max(u));
		v=-v/max(max(v));
		u=u*str2double(get(handles.rotationdislacement,'string'));
		v=v*str2double(get(handles.rotationdislacement,'string'));
		[x,y]=meshgrid(1:1:str2double(get(handles.img_sizex,'string'))+1);
	case 5 %membrane
		[x,y]=meshgrid(linspace(-3,3,str2double(get(handles.img_sizex,'string'))),linspace(-3,3,str2double(get(handles.img_sizey,'string'))));
		u = peaks(x,y)/3;
		v = peaks(y,x)/3;
        %matlab logo in u displacement:
        %u=-1*membrane(1,str2double(get(handles.img_sizex,'string'))/2)*5;
        %v=membrane(1,str2double(get(handles.img_sizex,'string'))/2)*0;
end
%% Create Particle Image
set(handles.status_creation,'string','Calculating particles...');drawnow;
i=[];
j=[];
sizey=str2double(get(handles.img_sizey,'string'));
sizex=str2double(get(handles.img_sizex,'string'));
noise=str2double(get(handles.part_noise,'string'));
A=zeros(sizey,sizex);
B=A;
partAm=str2double(get(handles.part_am,'string'));
Z=str2double(get(handles.sheetthick,'string')); %0.25 sheet thickness
dt=str2double(get(handles.part_size,'string')); %particle diameter
ddt=str2double(get(handles.part_var,'string')); %particle diameter variation

z0_pre=randn(partAm,1); %normal distributed sheet intensity

z1_pre=randn(partAm,1); %normal distributed sheet intensity

z0=z0_pre*(str2double(get(handles.part_z,'string'))/200+0.5)+z1_pre*(1-((str2double(get(handles.part_z,'string'))/200+0.5)));
z1=z1_pre*(str2double(get(handles.part_z,'string'))/200+0.5)+z0_pre*(1-((str2double(get(handles.part_z,'string'))/200+0.5)));

%z0=abs(randn(partAm,1)); %normal distributed sheet intensity
I0=255*exp(-(Z^2./(0.125*z0.^2))); %particle intensity
I0(I0>255)=255;
I0(I0<0)=0;

I1=255*exp(-(Z^2./(0.125*z1.^2))); %particle intensity
I1(I1>255)=255;
I1(I1<0)=0;

d=randn(partAm,1)/2; %particle diameter distribution
d=dt+d*ddt;
d(d<0)=0;
x0=rand(partAm,1)*sizex;
y0=rand(partAm,1)*sizey;
rd = -8.0 ./ d.^2;
offsety=v;
offsetx=u;

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

set(handles.status_creation,'string','Placing particles...');drawnow;
for n=1:partAm
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

A(A>255)=255;
B(B>255)=255;

gen_image_1=imnoise(uint8(A),'gaussian',0,noise);
gen_image_2=imnoise(uint8(B),'gaussian',0,noise);

set(handles.status_creation,'string','...done')
figure;imshow(gen_image_1,'initialmagnification', 100);
figure;imshow(gen_image_2,'initialmagnification', 100);
gui.put('gen_image_1',gen_image_1);
gui.put('gen_image_2',gen_image_2);
gui.put('real_displ_u',offsetx);
gui.put('real_displ_v',offsety);

