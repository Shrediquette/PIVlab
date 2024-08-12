function s = wstrcoor(x,prec,lenMAX)
%WSTRCOOR Format string of coordinates values.
%   S = WSTRCOOR(X,PREC,LENMAX)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-May-2003.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

frm = ['%-+0.' sprintf('%1g',prec) 'f']; 
s = sprintf(frm,x);
if length(s)>lenMAX, s = s(1:lenMAX); end
