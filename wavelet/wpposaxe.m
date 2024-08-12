function [out1,out2,out3,out4,out5,out6,out7] = wpposaxe(win,dim,pos_g,is)
%WPPOSAXE Axes positions for wavelet packets tool.
%   [OUT1,OUT2,OUT3,OUT4,OUT5,OUT6,OUT7] = WPPOSAXE(WIN,DIM,POS_G,IS)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% out1 = pos_axe_pack
% out2 = pos_axe_tree
% out3 = pos_axe_cfs
% out4 = pos_axe_sig
% out5 = pos_sli_size
% out6 = pos_sli_pos
% out7 = pos_axe_col

[bdx,bdy]     = depOfMachine;
[xpixl,ypixl] = wfigutil('prop_size',win,1,1);
bdx           = bdx*xpixl;
bdy           = bdy*ypixl;
w_axe         = (pos_g(3)-4*bdx)/2;

% Get Globals.
%-------------
% [Def_Btn_Height,sliYProp] = mextglob('get','Def_Btn_Height','Sli_YProp');
% h_sli = sliYProp*Def_Btn_Height*ypixl;
h_sli     = 14*ypixl;
h_axe_col = bdy/2;
w_axe_col = w_axe;
if dim==1
    h_axe       = pos_g(4)-6*bdy;
    w_axe_tree  = w_axe;
    h_axe_tree  = (2*h_axe)/3;
    w_axe_pack  = w_axe;
    h_axe_pack  = h_axe/3;
    w_axe_sig   = w_axe;
    h_axe_sig   = h_axe/3;
    w_axe_cfs   = w_axe;
    h_axe_cfs   = (2*h_axe)/3-bdy-h_axe_col-2*bdy;
    c1x = pos_g(1)+bdx+w_axe_pack/2;
    c1y = pos_g(2)+2*bdy+h_axe_pack/2;
    c2x = c1x;
    c2y = c1y+(h_axe_pack+h_axe_tree)/2+2*bdy;

    c5x = c1x+w_axe+2*bdx;
    c5y = pos_g(2)+2*bdy+h_axe_col/2;

    c3x = c1x+w_axe+2*bdx;
    c3y = c5y+(h_axe_col+h_axe_cfs)/2+bdy+bdy;
    c4x = c3x;
    c4y = c3y+(h_axe_cfs+h_axe_sig)/2+3*bdy;

elseif dim==2
    h_axe = (pos_g(4)-6*bdy-h_axe_col-3*bdy)/2;
    c5x   = pos_g(1)+pos_g(3)/2;
    c5y   = pos_g(2)+2*bdy+h_axe_col/2;

    c1x   = pos_g(1)+bdx+w_axe/2;
    c1y   = c5y+(h_axe+h_axe_col)/2+2*bdy;
    c2x   = c1x;
    c2y   = c1y+h_axe+3*bdy;
    c3x   = c1x+w_axe+2*bdx;
    c3y   = c1y;
    c4x   = c3x;
    c4y   = c2y;
    w_axe_tree = w_axe;
    h_axe_tree = h_axe;
    if nargin==4
        [w_axe,h_axe] = wpropimg(is,w_axe,h_axe);
    end
    w_axe_pack = w_axe;
    h_axe_pack = h_axe;
    w_axe_sig  = w_axe;
    h_axe_sig  = h_axe;
    w_axe_cfs  = w_axe;
    h_axe_cfs  = h_axe;
end

out1 = [ c1x-w_axe_pack/2, ...
         c1y-h_axe_pack/2, ...
         w_axe_pack,       ...
         h_axe_pack      ];


out2 = [ c2x-w_axe_tree/2, ...
         c2y-h_axe_tree/2, ...
         w_axe_tree,       ...
         h_axe_tree      ];


out3 = [ c3x-w_axe_cfs/2,  ...
         c3y-h_axe_cfs/2,  ...
         w_axe_cfs,        ...
         h_axe_cfs       ];

out4 = [ c4x-w_axe_sig/2,  ...
         c4y-h_axe_sig/2,  ...
         w_axe_sig,        ...
         h_axe_sig       ];

d_yh = 0.75*h_sli;
d_yl = 0.50*h_sli;
out5 = [ out2(1)+out2(3)/4,     ...
         out2(2)+out2(4)-d_yh,  ...
         out2(3)/2              ...
         h_sli   ];

out6 = [ out2(1)+out2(3)/8,...
         out2(2)-d_yl,     ...
         (3*out2(3))/4,    ...
         h_sli   ];

out7 = [ c5x-w_axe_col/2,  ...
         c5y-h_axe_col/2,  ...
         w_axe_col,        ...
         h_axe_col       ];

%-------------------------------------------------
function varargout = depOfMachine(varargin)

scrSize = getMonitorSize;
if scrSize(4)<=600
    bdx = 20; bdy = 15;
else
    bdx = 30; bdy = 20;
end
varargout = {bdx,bdy};
%-------------------------------------------------
