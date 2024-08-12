function Q = newvar(P,var)
%NEWVAR Change variable in a Laurent polynomial.
%   Q = NEWVAR(P,VAR) returns the Laurent polynomial Q which
%   obtained by doing a change of variable.
%   The valid choices for VAR are:
%       'z^2': P(z) ---> P(z^2)       (see DYADUP)
%       '-z' : P(z) ---> P(-z)        (see MODULATE)
%       '1/z': P(z) ---> P(1/z)       (see REFLECT)
%       'sqz': P(z) ---> P(sqrt(z))   (see DYADDOWN)
%   
%   See also DYADDOWN, DYADUP, EO2LP, MODULATE, REFLECT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-May-2001.
%   Last Revision: 14-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

C = P.coefs;
D = P.maxDEG;
L = length(C);
switch var
case 'z^2'
    newC = dyadup(C,0);
    Q = laurpoly(newC,2*D);
    
case '-z'
    pow = [D:-1:D-L+1];  
    S = (-1).^pow;
    newC = S.*C;
    Q = laurpoly(newC,D);
    
case '1/z'
    newD = -(D-L+1);    
    newC = fliplr(C);
    Q = laurpoly(newC,newD);

case 'sqz'
    newC = C(1+mod(D,2):2:end);
    newD = floor(D/2);
    Q    = laurpoly(newC,newD);
end
