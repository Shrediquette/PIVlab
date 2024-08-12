function [EuclideTAB,first] = euclidedivtab(A,B)
%EUCLIDEDIVTAB Table obtained by the Euclidean division algorithm.
%   For two Laurent Polynomials A and B, [TAB,FIRST] = euclidedivtab(A,B)
%   returns a cell array TAB and an integer FIRST such that:
%
%=========================================================================
% Basic Euclidean Algorithm for Laurent Polynomials
%--------------------------------------------------
% A , B two Laurent polynomials with d(A) => d(B). (d = degree)
% Initialization: A(0) = A , B(0) = B 
% while B(i) ~= 0
%   A(i) = B(i)*Q(i) + R(i)        <-- Euclidean Division
%   A(i+1) = B(i) , B(i+1) = R(i)
% end
%--------------------------------------------------
% There are several euclidian divisions of A by B (see EUCLIDEDIV).
% Starting from TAB(1,:) = {A,B,laurpoly(0,0),1,0}, we compute
% DEC = euclidediv(A,B). Then the first lines of TAB starting from 
% the line 2 contain all possibles euclidian divisions of A by B,
% A = B*Q+R:
%   TAB(j,:) = {B , R , Q , flagDIV , 1} , j = 2, ... , (nbEuclideDIV+1)
%   flagDIV  = 0 if the Remainder R = 0. Otherwise flagDIV  = 1.
%
% The CellArray TAB is computed by computing euclidian divisions
% for each line on which flagDIV = 1 ...
% The general form of a line of the CellArray TAB is:
%   TAB(j,:) = {B , R , Q , flagDIV , idxLine}
%
% The number "idxLine" gives the number of the line used to compute 
% the euclidian division A = B*Q+R. 
% So for each line with index k => first:
%      TAB(k,1)*TAB(k,3)-TAB(k,2) = TAB(TAB(k,5),1)
%=========================================================================

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 25-Apr-2001.

%   Copyright 1995-2020 The MathWorks, Inc.

EuclideTAB = cell(4050,5);
EuclideTAB(1,:) = {A,B,laurpoly(0,0),1,0};
idxLine = 1;
continu = 1;
cnt = 1;
while continu
    toDIV = EuclideTAB{idxLine,4};
    if toDIV
        EuclideTAB{idxLine,4} = NaN;
        A = EuclideTAB{idxLine,1};
        B = EuclideTAB{idxLine,2};
        DEC = euclidediv(A,B);
        nbDEC = size(DEC,1);
        indx = (1:nbDEC)+cnt;
        cnt = cnt+nbDEC;
        for k = 1:nbDEC
            flagDIV = (DEC{k,2} ~= 0);
            EuclideTAB(indx(k),:) = {B,DEC{k,2},DEC{k,1},flagDIV,idxLine};
        end
    end
    idxLine = idxLine+1;
    if cnt >= 4000
        break;
    end
    if idxLine > size(EuclideTAB,1) , break; end
end

m = min(4000,cnt);
EuclideTAB(m+1:end,:) = [];
first = 1;
while isnan(EuclideTAB{first,4}) , first = first+1; end
