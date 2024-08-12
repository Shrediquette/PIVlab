function [C,D] = wfusfun(A,B,funNUM)
%WFUSFUN Template for a user defined method of fusion.
%    For two arrays A and B which are of the same size,
%    C = WFUSFUN(A,B) returns an array C which is of the same
%    size as A and B. The array C is the "fusion" of A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Jan-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin<3 , funNUM = 5; end
switch funNUM
    case 1
        t = 0.1;
        sA = size(A); 
        mA = floor(sA/2);
        D = logical(ones(size(A)));
        jmax = 0;
        for i = mA(1):sA(1)
            jmax = min([jmax + 1,mA(2)-1]);
            for j = 1:jmax
                D(i,mA(2)-j:mA(2)+j) = 0;
            end
        end
        C = A; C(D) = A(D); 
        C(~D) = t*A(~D) + (1-t)*B(~D);

    case 2 
        try , t = method.param; catch , t = 0.1; end
        D = ones(size(A));
        sA = size(A);
        x  = linspace(0,1,sA(1));
        P = zeros(size(A));
        jmax = 0;
        for i = 1:sA(1)
            P(i,:) = x(i);
        end
        if t~=1 , P = P.^t; end
        C = A.*(1-P) + B.*P;
        
    case 3
        try , t = method.param; catch , t = 0.1; end
        D = ones(size(A));
        sA = size(A);
        sA2 = sA(2)/2;
        y  = linspace(0,1,sA2);
        P = zeros(size(A));
        jmax = 0;
        for i = 1:sA2
            P(:,sA2+i)   = y(i);
            P(:,sA2-i+1) = y(i);
        end
        if t>0 , P = 1-P; end
        C = A.*(1-P) + B.*P; 
        
    case 4  
        D = logical(tril(ones(size(A)))); t = 0.3;
        C = A; 
        C(D)  = t*A(D)+(1-t)*B(D);
        C(~D) = t*B(~D)+(1-t)*A(~D);
        
    case 5  
        D = logical(triu(ones(size(A))));  t = 0.3;
        C = A; 
        C(D)  = t*A(D)+(1-t)*B(D);
        C(~D) = t*B(~D)+(1-t)*A(~D);
        
end
