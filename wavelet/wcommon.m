function [xind,yind] = wcommon(x,y)
%WCOMMON Find common elements.
%   For two vectors X and Y with integer components,
%   [XI,YI] = WCOMMON(X,Y) returns two vectors
%   with 0 and 1 components such that:
%   XI(k) = 1 if X(k) belongs to Y otherwise XI(k) = 0 and 
%   YI(j) = 1 if Y(j) belongs to X otherwise YI(j) = 0.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

xind = ismember(x,y);
yind = ismember(y,x);
