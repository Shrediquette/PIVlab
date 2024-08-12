function DEC = euclidediv(A,B)
%EUCLIDEDIV Euclidean Algorithm for Laurent polynomials.
%   DEC = EUCLIDEDIV(A,B) returns a cell array of Laurent polynomials
%   such that each row of DEC contains an euclidian division of A 
%   by B: A = B*Q + R. Q is the quotient and R the remainder.
%   For each j from 1 to size(DEC,1):   A = B*DEC{j,1} + DEC{j,2}
%
%   The cell array DEC contains at most four rows.
%
%   Example:
%     % Create two Laurent polynomials
%     A = laurpoly((1:4),0);
%     B = laurpoly([1 2],0);
%
%     % Euclidian division of A by B
%     DEC = euclidediv(A,B);
%     for k=1:4
%         disp(DEC{1,1},'Q'); disp(DEC{1,2},'R')
%     end
%
%     %----------------------------------------------------------------
%     % A(z) = 1 + 2*z^(-1) + 3*z^(-2) + 4*z^(-3) and  
%     % B(z) = 1 + 2*z^(-1)
%     % There are four decomposition A = B*Q + R: 
%     %   Q(z) = 1 + 3*z^(-2)                  and  R(z) = - 2*z^(-3)
%     %   Q(z) = 1 + 2*z^(-2)                  and  R(z) = z^(-2)
%     %   Q(z) = 1 + 0.5*z^(-1) + 2*z^(-2)     and  R(z) = - 0.5*z^(-1)
%     %   Q(z) = 0.75 + 0.5*z^(-1) + 2*z^(-2)  and  R(z) = 0.25
%     %----------------------------------------------------------------- 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Mar-2001.
%   Last Revision 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

if      isnumeric(A) && length(A)==1 , A = laurpoly(A,0);
elseif  isnumeric(B) && length(B)==1 , B = laurpoly(B,0);
end

maxDEG_A = A.maxDEG;
maxDEG_B = B.maxDEG;
cA = A.coefs; lA = length(cA);
cB = B.coefs; lB = length(cB);
minDEG_A = maxDEG_A-lA+1;
minDEG_B = maxDEG_B-lB+1;
maxDEG_LEFT  = maxDEG_A-maxDEG_B;
minDEG_RIGHT = minDEG_A-minDEG_B;

dL = lA-lB;
if dL > 0
    rLEFT = cA;
    qLEFT = zeros(1,dL+1);

    for j=1:dL+1
        idxEND = j+lB-1;
        q = rLEFT(j)/cB(1);
        if j == (dL+1)
           qBIS = rLEFT(idxEND)/cB(end);
           rLEFT_2 = rLEFT;
           rLEFT_2(j:idxEND) = rLEFT_2(j:idxEND)-qBIS*cB;
           qLEFT_2 = [qLEFT(1:dL),qBIS];
        end 
        qLEFT(j) = q;
        rLEFT(j:idxEND) = rLEFT(j:idxEND)-q*cB;
    end
    
    rRIGHT = cA;
    qRIGHT = zeros(1,dL+1);
    indx = dL+2-(1:dL+1);
    for j = 1:dL+1
        idxEND = lA-j+1;
        idxBEG = idxEND-lB+1;
        q = rRIGHT(idxEND)/cB(end);
        if j == (dL+1)
           qBIS = rRIGHT(idxBEG)/cB(1);
           rRIGHT_2 = rRIGHT;
           rRIGHT_2(idxBEG:idxEND) = rRIGHT_2(idxBEG:idxEND)-qBIS*cB;
           qRIGHT_2 = qRIGHT;
           qRIGHT_2(1) = qBIS;
        end
        qRIGHT(indx(j)) = q;
        rRIGHT(idxBEG:idxEND) = rRIGHT(idxBEG:idxEND)-q*cB;
    end
    maxDEG_RIGHT = minDEG_RIGHT+length(qRIGHT)-1;

    DEC = {...
        laurpoly(qLEFT,maxDEG_LEFT)     , laurpoly(rLEFT,maxDEG_A);   ...
        laurpoly(qLEFT_2,maxDEG_LEFT)   , laurpoly(rLEFT_2,maxDEG_A); ...
        laurpoly(qRIGHT_2,maxDEG_LEFT)  , laurpoly(rRIGHT_2,maxDEG_A); ...
        laurpoly(qRIGHT,maxDEG_RIGHT)   , laurpoly(rRIGHT,maxDEG_A) ...
        };

elseif dL == 0
    qLEFT  = cA(1)/cB(1);
    qRIGHT = cA(end)/cB(end);
    rLEFT  = cA-qLEFT*cB;
    rRIGHT = cA-qRIGHT*cB;
    maxDEG_RIGHT = minDEG_RIGHT;    
    DEC = {...
        laurpoly(qLEFT,maxDEG_LEFT)   , laurpoly(rLEFT,maxDEG_A);   ...
        laurpoly(qRIGHT,maxDEG_RIGHT) , laurpoly(rRIGHT,maxDEG_A) ...
        };
else
    Q = laurpoly(0,0); %#ok<*NASGU>
    R = A;
    DEC = {laurpoly(0,0),A};
end
nbDEC = size(DEC,1);

idx = true(1,nbDEC);
for j=1:nbDEC
    for k=j+1:nbDEC
        if idx(k) == 1
            idx(k) = (DEC{j,1} ~= DEC{k,1}) || (DEC{j,2} ~= DEC{k,2});
        end
    end
end
DEC = DEC(idx,:);
