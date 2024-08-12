function show_et(EuclidTAB,flagPause) %#ok<INUSD>
%SHOW_ET Show table obtained by the Euclidean division algorithm.
%  SHOW_ET(EuclidTAB,flagPause) shows the table obtained by  
%  the Euclidean division algorithm (see EUCLIDEDIVTAB).
%
%   Example:
%     A = laurpoly([1:4],0);
%     B = laurpoly([1 2],0);
%     EuclidTAB = euclidedivtab(A,B);
%     show_et(EuclidTAB,'flagPause')

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2001.
%   Last Revision: 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

disp('---------------------------')
for j = 1:size(EuclidTAB,1)
    disp(['idx = ', int2str(j)])
    TMP = lpstr(EuclidTAB{j,1});
    if size(TMP,1)>1
        disp(EuclidTAB{j,1},'A')
    else
        disp(['A = ' , TMP])
    end
    TMP = lpstr(EuclidTAB{j,2});
    if size(TMP,1)>1
        disp(EuclidTAB{j,2},'R')
    else
        disp(['R = ' ,TMP])
    end
    TMP = lpstr(EuclidTAB{j,3});
    if size(TMP,1)>1
        disp(EuclidTAB{j,3},'Q')
    else
        disp(['Q = ' ,TMP])
    end
    disp(['ToDIV = ' , int2str(EuclidTAB{j,4})])
    disp(['idxPar = ' , int2str(EuclidTAB{j,5})])
    disp('---------------------------')
    if nargin>1 , pause; end
end
