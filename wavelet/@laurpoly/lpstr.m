function dispSTR = lpstr(P,maxLEN)
%LPSTR String to display a Laurent polynomial object.
%   S = LPSTR(P) returns a string S used to display 
%   the Laurent polynomial P.
%   S = LPSTR(P,MAXLEN) uses at most MAXLEN chars for 
%   each line of the string S. The default is MAXLEN = 60.
%
%   Example:
%      P = laurpoly(1:8,0);
%      S1 = lpstr(P) , S2 = lpstr(P,90) , S3 = lpstr(P,30)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2001.
%   Last Revision 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.
   
if nargin<2 , maxLEN = 60; end

dispSTR = [];
lineSTR = '';

d = P.maxDEG;
c = P.coefs;
nbCoefs = length(c);
for k=1:nbCoefs
    v = c(k);
    if v~=0
        if abs(v)~=1 
            tmp =  num2str(abs(v),4);
        else
            if d~=0 , tmp = ''; else , tmp = '1'; end 
        end
        if v<0 , tmp = ['- ' , tmp];  elseif (nbCoefs>1) , tmp = ['+ ' , tmp]; end
        
        if d~=0 
            if abs(v)~=1 , tmp = [tmp '*']; end
            if     d<0 , tmp = [tmp 'z^(-'];
            elseif d>0 , tmp = [tmp 'z^(+'];
            end
            tmp = [tmp , int2str(abs(d)) ') ' ];
        else
            tmp = [tmp ' '];
        end
        lineSTR = [lineSTR , tmp];
        
    elseif nbCoefs==1
        lineSTR = [lineSTR , '0'];

    end
    lenlineSTR = length(lineSTR);
    if (lenlineSTR>maxLEN) && (k<nbCoefs)
        lineSTR = [lineSTR ,' ...'];
        dispSTR = strvcat(dispSTR,lineSTR);
        lineSTR = '';
    end
    d = d-1;
end
dispSTR = strvcat(dispSTR,lineSTR);
