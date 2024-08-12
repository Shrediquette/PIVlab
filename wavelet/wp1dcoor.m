function [sx,sy] = wp1dcoor(x,y,axe,in4)
%WP1DCOOR Wavelet packets 1-D coordinates.
%   Write function used by DYNVTOOL.
%   [SX,SY] = WP1DCOOR(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Nov-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Tagged object.
%---------------
tag_img_cfs = 'Img_WPCfs';
tag_nodlab  = 'Pop_NodLab';

sx = sprintf('X = %7.2f',x);
sy = sprintf('Y = %7.2f',y);
if axe==in4
   img = findobj(in4,'Type','image','Tag',tag_img_cfs);
   if ~isempty(img)
       typelab = get(findobj(get(in4,'Parent'),'Tag',tag_nodlab),'Value');
       us      = get(img,'UserData');
       k = find(us(:,3)<y & us(:,4)>y);
       if length(k)==1
          if typelab==1
             sy = getWavMSG('Wavelet:wp1d2dRF:Pack_ID_dp',us(k,1),us(k,2));
          else
             sy = getWavMSG('Wavelet:wp1d2dRF:Pack_ID_ind',depo2ind(2,us(k,1:2)));
          end
       end
    end
end
