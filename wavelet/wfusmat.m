function [C,D] = wfusmat(A,B,method)
%WFUSMAT Fusion of two matrices or arrays.
%   C = WFUSMAT(A,B,METHOD) returns the fusioned matrix C obtained
%   from the matrices A and B using the fusion method defined by METHOD.
%
%   A, B and C must be of same size.
%   If A and B represent indexed images, then they are m-by-n matrices.
%   If A and B represent truecolor images, then they are m-by-n-by-3
%   arrays.
%
%   Available fusion methods are:
%
%   - simple ones, METHOD is
%         - 'max'  : D = abs(A) >= abs(B) ; C = A(D) + B(~D)
%         - 'min'  : D = abs(A) <= abs(B) ; C = A(D) + B(~D)
%         - 'mean' : C = (A+B)/2 ; D = ones(size(A))
%         - 'rand' : C = A(D) + B(~D); D is a boolean random matrix
%         - 'img1' : C = A
%         - 'img2' : C = B
%
%   - parameter-dependent ones, METHOD is of the following form 
%     METHOD = struct('name',nameMETH,'param',paramMETH) where nameMETH
%     can be:
%         - 'linear'    : C = A*paramMETH + B*(1-paramMETH) 
%                             where 0 <= paramMETH <= 1   
%         - 'UD_fusion' : Up-Down fusion, with paramMETH >= 0  
%                         x = linspace(0,1,size(A,1));
%                         P = x.^paramMETH;
%                         Then each row of C is computed with:
%                         C(i,:) = A(i,:)*(1-P(i)) + B(i,:)*P(i);
%                         So C(1,:)= A(1,:) and C(end,:)= A(end,:) 
%         - 'DU_fusion' : Down-Up fusion
%         - 'LR_fusion' : Left-Right fusion (columnwise fusion)
%         - 'RL_fusion' : Right-Left fusion (columnwise fusion)
%         - 'userDEF'   : paramMETH is a string 'userFUNCTION' containing
%                         a function name such that:
%                         C = userFUNCTION(A,B).
%
%   In addition, [C,D] = WFUSMAT(A,B,METHOD) returns the boolean
%   matrix D when defined or an empty matrix otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-Jan-2003.
%   Last Revision: 02-Apr-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(3,3);
if isStringScalar(method)
    method = convertStringsToChars(method);
end

if ischar(method)
    method = struct('name',method);
end
methName = method.name;
D = [];
switch lower(methName)
    case 'mean'
        C = 0.5*(A+B);
        D = ones(size(A));
        
    case 'max' 
        D = abs(A)>=abs(B);
        C = A.*D + B.*(~D);
        
    case 'min' 
        D = abs(A)<=abs(B); 
        C = A.*D + B.*(~D);
        
    case 'linear' 
        t = method.param;
        C = t*A + (1-t)*B;
        D = ones(size(A));
        
    case 'rand'  
        R = rand(size(A)); 
        C = zeros(size(A));
        D = (R<0.5);
        C(D)  = A(D);
        C(~D) = B(~D);
 
    case 'ud_fusion'  
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 1;
        end
        S = size(A);
        x  = linspace(0,1,S(1));
        P = zeros(S);
        for i = 1:S(1) , P(i,:) = x(i); end
        if t~=1 , P = P.^t; end
        C = A.*(1-P) + B.*P;
        D = [];

    case 'du_fusion'  
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 1;
        end
        S = size(A);
        x  = linspace(0,1,S(1));
        P = zeros(S);
        for i = 1:S(1) , P(i,:) = x(i); end
        if t~=1 , P = P.^t; end
        C = A.*P + B.*(1-P);
        D = [];

    case 'lr_fusion'  
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 1;
        end    
        S = size(A);
        x  = linspace(0,1,S(2));
        P = zeros(S);
        for i = 1:S(1) , P(:,i,:) = x(i); end
        if t~=1 , P = P.^t; end
        C = A.*(1-P) + B.*P;
        D = [];

    case 'rl_fusion'  
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 1;
        end
        S = size(A);
        x  = linspace(0,1,S(2));
        P = zeros(S);
        for i = 1:S(1) , P(:,i,:) = x(i); end
        if t~=1 , P = P.^t; end
        C = A.*P + B.*(1-P);
        D = [];
    %--------------------------------------------------------------%       
    case {'img1','mat1'} , C = A;
    case {'img2','mat2'} , C = B;
    %--------------------------------------------------------------%
    case {'userdef'}
        C = feval(method.param,A,B);
        D = [];
    %--------------------------------------------------------------%
    case 'manual'
        D = t;  %#ok<NODEF>
        C(D) = A(D); C(~D) = B(~D);
    %--------------------------------------------------------------%
    case 'tril' 
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 1;
        end            
        D = logical(tril(ones(size(A)))); 
        C(D)  = t*A(D)+(1-t)*B(D);
        C(~D) = t*B(~D)+(1-t)*A(~D);
    case 'triu' 
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 1;
        end
        D = logical(triu(ones(size(A)))) ; 
        C(D)  = t*A(D)+(1-t)*B(D);
        C(~D) = t*B(~D)+(1-t)*A(~D);
    %--------------------------------------------------------------%     
    case 'funny_1'
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 0.1;
        end
        sA = size(A); 
        mA = floor(sA/2);
        D = true(size(A));
        jmax = 0;
        for i = mA(1):sA(1)
            jmax = min([jmax + 1,mA(2)-1]);
            for j = 1:jmax
                D(i,mA(2)-j:mA(2)+j) = 0;
            end
        end
        C = A; C(D) = A(D); 
        C(~D) = t*A(~D) + (1-t)*B(~D);
        
    case 'funny_2' 
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 0.1;
        end
        D = ones(size(A));
        sA = size(A);
        x  = linspace(0,1,sA(1));
        P = zeros(size(A));
        for i = 1:sA(1)
            P(i,:) = x(i);
        end
        if t~=1 , P = P.^t; end
        C = A.*(1-P) + B.*P;
        
    case 'funny_3' 
        try
            t = method.param;
        catch ME  %#ok<NASGU>
            t = 0.1;
        end
        D = ones(size(A));
        sA = size(A);
        sA2 = sA(2)/2;
        y  = linspace(0,1,sA2);
        P = zeros(size(A));
        for i = 1:sA2
            P(:,sA2+i)   = y(i);
            P(:,sA2-i+1) = y(i);
        end
        if t>0 , P = 1-P; end
        C = A.*(1-P) + B.*P;  
    %--------------------------------------------------------------%
end
