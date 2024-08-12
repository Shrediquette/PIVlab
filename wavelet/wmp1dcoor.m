function [sx,sy] = wmp1dcoor(x,y,axe,in4)
%WMP1DCOOR Manage display of coordinates values.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Jun-2011.
%   Last Revision: 02-Jun-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Tagged object.
%---------------
tag_img_cfs = 'Img_WPCfs';
sx = sprintf('X = %7.2f',x);
sy = sprintf('Y = %7.2f',y);
if axe==in4
   img = wfindobj(in4,'Type','image','Tag',tag_img_cfs);
   if ~isempty(img)
       siz = size(get(img,'Cdata'));
       ud = get(img,'Userdata');
       plotMODE = ud(1);
       lenSIG = ud(2);
       xlim = get(in4,'Xlim');
       a = (lenSIG-1)/(xlim(2)-xlim(1));
       b = (1-a/2);       
       sx = sprintf('X = %7.2f',a*x+b);
       switch plotMODE
           case 1
               div = 2^4; nf = ceil(y/div); r = rem(y,div);
               if r==0 , nf = nf-1; r = div; end
               sy = sprintf('Cpt: %.0f - WPck: %.0f',nf,r);
               
           case 2
               div = 2^4; nbF = siz(1)/div;
               np = ceil(y/nbF); r = rem(y,nbF);
               if r==0 , np = np-1; r = div; end
               sy = sprintf('WPck: %.0f - Cpt: %.0f',np,r);
       end
    end
end

