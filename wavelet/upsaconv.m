function y = upsaconv(type,x,f,s,dwtATTR,shiFLAG)
%UPSACONV Upsample and convolution.
%
%   Y = UPSACONV('1D',X,F_R) returns the one step dyadic
%   interpolation (upsample and convolution) of vector X
%   using filter F_R.
%
%   Y = UPSACONV('1D',X,F_R,L) returns the length-L central 
%   portion of the result obtained using Y = UPSACONV('1D',X,F_R).
%
%   Y = UPSACONV('2D',X,{F1_R,F2_R}) returns the one step dyadic 
%   interpolation (upsample and convolution) of matrix X
%   using filter F1_R for rows and filter F2_R for columns.
%
%   Y = UPSACONV('2D',X,{F1_R,F2_R},S) returns the size-S
%   central portion of the result obtained 
%   using Y = UPSACONV('2D',X,{F1_R,F2_R})
% 
%   Y = UPSACONV('1D',X,F_R,DWTATTR) returns the one step
%   interpolation of vector X using filter F_R where the upsample 
%   and convolution attributes are described by DWTATTR.
%
%   Y = UPSACONV('1D',X,F_R,L,DWTATTR) combines the two 
%   other usages.
%
%   Y = UPSACONV('2D',X,{F1_R,F2_R},DWTATTR) returns the one step
%   interpolation of matrix X using filters F1_R and F2_R where  
%   the upsample and convolution attributes are described by DWTATTR.
% 
%   Y = UPSACONV('2D',X,{F1_R,F2_R},S,DWTATTR) combines the 
%   other usages.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Nov-97.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

% Special case.
if isempty(x) , y = 0; return; end

y = x;
if nargin<4 , sizFLAG = 1; else , sizFLAG = isempty(s); end
if nargin<5 , dwtATTR = dwtmode('get'); end
if nargin<6 , shiFLAG = 1; end
dumFLAG = ~isstruct(dwtATTR);
if ~dumFLAG , perFLAG = isequal(dwtATTR.extMode,'per'); else , perFLAG = 0; end
shiFLAG = shiFLAG && ~dumFLAG;

switch type
    case {1,'1','1d','1D'}
        ly = length(y);
        lf = length(f);
        if sizFLAG
            if ~perFLAG , s = 2*ly-lf+2; else , s = 2*ly; end
        end
        if shiFLAG , shift = dwtATTR.shift1D; else , shift = 0; end
        shift = mod(shift,2);
        if ~perFLAG
            if sizFLAG , s = 2*ly-lf+2; end
            y = wconv1(dyadup(y,0),f);
            y = wkeep1(y,s,'c',shift);
        else
            if sizFLAG , s = 2*ly; end
            y = dyadup(y,0,1);
            y = wextend('1D','per',y,lf/2);
            y = wconv1(y,f);
            y = wkeep1(y,2*ly,lf);
            if shift==1 , y = y([2:end,1]); end
            y = y(1:s);
        end

    case {2,'2','2d','2D'}
        sy = size(y);
        lf = length(f{1});
        if sizFLAG
            if ~perFLAG , s = 2*sy-lf+2; else , s = 2*sy; end
        end
        if shiFLAG , shift = dwtATTR.shift2D; else , shift = [0 0]; end
        shift = mod(shift,2);
        if ~perFLAG
            y = wconv2('col',dyadup(y,'row',0),f{1});
            y = wconv2('row',dyadup(y,'col',0),f{2});
            y = wkeep2(y,s,'c',shift);
        else
            y = dyadup(y,'mat',0,1);
            y = wextend('2D','per',y,[lf/2,lf/2]);
            y = wconv2('col',y,f{1});
            y = wconv2('row',y,f{2});
            y = wkeep2(y,2*sy,[lf lf]);
            if shift(1)==1 , y = y([2:end,1],:); end
            if shift(2)==1 , y = y(:,[2:end,1]); end
            y = wkeep2(y,s,[1,1]);
        end
end
