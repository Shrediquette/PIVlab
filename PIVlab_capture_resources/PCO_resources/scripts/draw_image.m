function imah=draw_image(data,lim)
% Draw image data to figure. Scale image for resolutions above 800x600 
%
% * Input parameters :
%    data [uint16(,)]        image data (height,width)
%    lim  [low up]           upper and lower limits to display (optional)
%                            default: [0 m], where m is maximal value calculated from first image   
%
% * Output parameters :
%    imah                    handle to image  

 if(nargin<1)
  error('at least data array needed');
 end 

 if(nargin<2)
  ulim=max(max(data(10:end-10,10:end-10)));
  lim=[0 ulim];  
 end 
  
 fig_ima=figure;
 [height,width]=size(data);
 scrsz = get(0,'ScreenSize');
%use other scale factor  
 scal=4.0; 
 if((width>2400)&&(height>1800))
  scal=3.0;   
 elseif((width>1600)&&(height>1200))
  scal=2.0;   
 elseif((width>800)&&(height>600))
  scal=1.5;   
 elseif((width<=800)&&(height<=600)) 
  scal=1.0;   
 end
 set(fig_ima,'MenuBar','none');
 set(fig_ima,'Position',[1 1 width/scal+60 height/scal+40]);
 figsz=get(fig_ima,'OuterPosition');
%position of window 200 pixel from left  
 cx=200; 
%to center on screen use cx=(scrsz(3)-figsz(3))/2
 cy=scrsz(4)-figsz(4)-100; %position of window 100 pixel from top
  %to center on screen use cy=(scrsz(4)-figsz(4))/2
 set(fig_ima,'Position',[cx cy width/scal+60 height/scal+40]);
 colormap('gray');
 set(fig_ima,'NumberTitle','off')
 set(fig_ima,'Name',['Image 1:',num2str(scal)]);
 axes1 = axes('Visible','off','Parent',fig_ima,'YDir','reverse',...
    'TickDir','out',...
    'Units','pixel',...
    'Position',[30 20 width/scal height/scal],...
    'PlotBoxAspectRatio',[width/scal height/scal 1],...
    'Layer','top',...
    'DataAspectRatio',[1 1 1],...
    'CLim',lim);
 box(axes1,'on');
 hold(axes1,'all');
 imah=image(data,'Parent',axes1,'CDataMapping','scaled');
 set(imah,'CDataMapping','scaled');
 set(fig_ima,'Resize','off'); %resizing of figure not allowed
 commandwindow;
end
