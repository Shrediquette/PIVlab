function draw_images_roi(data,wait,lim,disproi)
% Draw data of image array to figure. Set ROI or scale image for resolutions above 800x600 
%
% * Input parameters :
%    data [uint16(,,)]       image data array (height,width,count)
%    wait                    time to wait between images (optional) default: 0.01)
%    lim  [low up]           upper and lower limits to display (optional)
%                            default: [0 m], where m is maximal value calculated from first image   
%    disproi [left top width height]
%                            size and position of top-left corner to display (optional) 
%                            i.E. top-left 800x600Pixel:                [ 1 1 800 600 ]
%                                 offset left=400 top=200 800x600Pixel: [ 401 201 800 600 ]
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
 left=1;
 top=1; 
 
 [~,b]=size(disproi);
 if((nargin==4)&&(b>=4))
  if((disproi(1)>=1)&&(disproi(1)<w-1))
   left=disproi(1);
  end 

  if((disproi(2)>=1)&&(disproi(2)<h-1))
   top=disproi(2);
  end
  
  
  if(disproi(3)<=w-left)
   w=disproi(3)+left-1;
  else
   w=w-left+1;   
  end 
  
  if(disproi(4)<=h-top)
   h=disproi(4)+top-1;
  else
   h=h-top+1;   
  end 
 end
 
 disp(['ROI set to [',num2str(left),' ',num2str(w),' ',num2str(top),' ',num2str(h),']']);
 
 imah=draw_image(data(top:h,left:w,1),lim);
 for ima_nr=1:count
  set(imah,'CData',data(top:h,left:w,ima_nr),'CDataMapping','scaled'); 
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
