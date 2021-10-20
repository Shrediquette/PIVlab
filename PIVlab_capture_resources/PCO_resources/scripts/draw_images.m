function draw_images(data,wait,lim,dispsize)
% Draw data of image array to figure. Reduce size or scale image for resolutions above 800x600 
%
% * Input parameters :
%    data [uint16(,,)]       image data array (height,width,count)
%    wait                    time to wait between images (optional) default: 0.01)
%    lim  [low up]           upper and lower limits to display (optional)
%                            default: [0 m], where m is maximal value calculated from first image   
%    dispsize [width height] size of top-left corner to display (optional) 
%                            default: full image scaled for bigger sizes 
%
% * Output parameters :

 if(nargin<1)
  error('Wrong number of input arguments. Need data array');
 end 

 if(nargin<2)
  wait=0.010;
 end 

 if(nargin<3)
  ulim=max(max(data(10:end-10,10:end-10,1)));
  lim=[0 ulim];  
 end 
  
 disp(['waittime set to ',num2str(wait)]);
 disp(['limits set to [0 ',num2str(lim(2)),']']);
 
 [h,w,count]=size(data);

 if(nargin==4)
  if(dispsize(1)<w)
   w=dispsize(1);
  end 
  if(dispsize(2)<h)
   h=dispsize(2);
  end 
 end 
 
 imah=draw_image(data(1:h,1:w,1),lim);
 for ima_nr=1:count
  set(imah,'CData',data(1:h,1:w,ima_nr),'CDataMapping','scaled'); 
  if(wait==0)
   disp('Press any key to proceed')
   pause
  else 
   pause(wait);
  end 
 end 
 disp('Press "Enter" to close window and proceed');
 pause();
 close();
 pause(1);
 commandwindow;
end
