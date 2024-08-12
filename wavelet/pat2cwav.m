function [PSI,XVal,NC] = pat2cwav(y,method,PolDegree,Regularity)
%PAT2CWAV Construction of a wavelet starting from a pattern.
%   [PSI,XVAL,NC] = PAT2CWAV(YPAT,METHOD,POLDEGREE,REGULARITY)
%  	computes an admissible wavelet for CWT (given by XVAL and PSI)
% 	adapted to the pattern defined by the vector YPAT, and of norm 
%   equal to 1.
%   The underlying x-values pattern are set to:
%             xpat = linspace(0,1,length(YPAT))
%   
% 	The constant NC is such that NC*PSI approximates YPAT on 
% 	the interval [0,1] by least squares fitting using:
% 	  - a polynomial of degree POLDEGREE when METHOD is equal to 'polynomial'
% 	  - a projection on the space of functions orthogonal to constants when
% 	    METHOD is equal to 'orthconst'.
% 	
% 	The REGULARITY parameter allows to define the boundary constraints at
% 	the points 0 and 1. Allowable values are 'continuous', 'differentiable'
% 	and 'none'.
% 	
% 	When METHOD is equal to 'polynomial':
%     - if REGULARITY is equal to 'continuous', POLDEGREE must be >= 3 
%     - if REGULARITY is equal to 'differentiable', POLDEGREE must be >= 5 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Mar-2003.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.


% NbPts = 1024;      % Length of PSI.
if nargin > 1
    method = convertStringsToChars(method);
end

if nargin > 3
    Regularity = convertStringsToChars(Regularity);
end

a = 0;             % Lower bound of interval: XVal(1).
b = 1;             % Upper bound of interval: XVal(end).
N = PolDegree + 1; % Degree of freedom. 
x = linspace(a,b,length(y));
if ischar(Regularity)
    Regularity = lower(Regularity);
    switch Regularity
        case 'none'
            Regularity = -1;
        case 'continuous'
            Regularity = 0;
        case 'differentiable'
            Regularity = 1;
        otherwise
            error(message('Wavelet:FunctionArgVal:Invalid_RegVal'))
    end
else
    okReg = ~isempty(Regularity);
    if okReg
        okReg = isnumeric(Regularity) & ...
            fix(Regularity)==Regularity & (Regularity >=-1);
    end
    if ~okReg
        error(message('Wavelet:FunctionArgVal:Invalid_RegVal'))
    end
end

method = lower(method);
switch method
    case {'polynomial','orthconst'}
        
    case {'discpoly'}
        R  = inline('x.^(p-1)','x','p','a','b');
        dR = inline('max(p-1,0)*x.^max(p-2,0)','x','p','a','b');
        method = 'symbolic';
        
    case 'lagrange'  
        R  = inline('((b-x).*(x-a)).^(p-1)','x','p','a','b');
        dR = inline('max(p-1,0)*(-2*x+a+b).*((b-x).*(x-a)).^max(p-2,0)','x','p','a','b');
        method = 'symbolic';
        
    case 'cos'  
        R  = inline('cos(2*(n-1)*pi*x/(b-a))','x','n','a','b');
        dR = inline('(-2*(n-1)*pi/(b-a))*sin(2*(n-1)*pi*x/(b-a))','x','n','a','b');
        method = 'symbolic';
        
    case 'sin'  
        R  = inline('sin(2*n*pi*x/(b-a))','x','n','a','b');
        dR = inline('(2*n*pi/(b-a))*cos(2*n*pi*x/(b-a))','x','n','a','b');
        method = 'symbolic';
end
if isequal(method,'symbolic')
    Regularity = min(Regularity,1);
end
NBConstrains = 1 + 2*(Regularity + 1);

NbPts = length(y);
XVal  = linspace(a,b,NbPts);
switch method
    case 'polynomial'  
        %  Mean square system construction.
        %----------------------------------
        % G : Gram Matrix
        % M : Matrix of constrains
        % B : Second Member
        %-------------------------
        G = zeros(N,N);
        M = zeros(1,N);
        B = zeros(N,1);
        for ii = 1:N
            for jj = 1:N
                k = ii + jj - 1;
                G(ii,jj) = (b^k-a^k)/k;
            end
            % Zero mean constraint.
            M(1,ii) = (b^ii-a^ii)/ii;
            % Second member.
            yTIMES_RI = y.*x.^(ii-1);
            BiVAL = 0.5*(yTIMES_RI(1:end-1) + yTIMES_RI(2:end));
            B(ii,1) = sum(diff(x).*BiVAL);
        end
        B(N+1,1)= 0;
        
        % Add eventual boundary constrains.
        %----------------------------------
        if (Regularity > -1) && (N > NBConstrains)
            for i = 1:N
                M([2,3],i) = [a^(i-1) ; b^(i-1)];
            end
            for k = 1:Regularity
                for i = 1:k
                    M([2*k+2,2*k+3],i) = [0;0];
                end
                for i = k+1:N
                    M([2*k+2,2*k+3],i) = prod(i-k:i-1)*[a;b].^(i-1-k);
                end
            end
            B(N+2:N+NBConstrains,1) = 0;
        end
        
        % Solving linear system.
        %-----------------------
        A = [G M';M zeros(NBConstrains,NBConstrains)];
        U = A\B;
        PSI = 0;
        for ii = 1:N
            PSI = PSI+U(ii).*XVal.^(ii-1);
        end

    case 'orthconst'  
        %  Mean square system construction.
        %----------------------------------
        % G : Gram Matrix
        % M : Matrix of constrains
        % B : Second Member
        %-------------------------
        G = zeros(N,N);
        B = zeros(N,1);
        NBConstrains = NBConstrains-1;
        for ii = 1:N
            for jj = 1:N
                k = ii + jj - 1;
                G(ii,jj) = (b^k-a^k)/k;
            end
            % Second member.
            yTIMES_RI = y.*x.^(ii-1);
            BiVAL = 0.5*(yTIMES_RI(1:end-1) + yTIMES_RI(2:end));
            B(ii,1) = sum(diff(x).*BiVAL);
        end
        M = [];
        MConstraint = [];
        
        % Add eventual boundary constrains.
        %----------------------------------
        if (Regularity > -1) && (N > NBConstrains)
            M = zeros(1,N);
            for i = 1:N
                M([1,2],i) = [a^(i-1) ; b^(i-1)];
            end
            for k = 1:Regularity
                for i = 1:k
                    M([2*k+1,2*k+2],i) = [0;0];
                end
                for i = k+1:N
                    M([2*k+1,2*k+2],i) = prod(i-k:i-1)*[a;b].^(i-1-k);
                end
            end
            dy = y;
            dx = diff(x);
            for p = 0:Regularity
                leftVAL  = dy(1)/(dx(1)^p);
                rightVAL = dy(end)/(dx(end)^p);
                B(N+2*p+1,1) = leftVAL;
                B(N+2*p+2,1) = rightVAL;
                dy = diff(dy);
            end
            MConstraint = zeros(NBConstrains,NBConstrains);
        end
        
        % Solving linear system.
        %-----------------------
        A = [G M';M MConstraint];
        U = A\B;
        PSI = y;
        for ii = 1:N
            PSI = PSI-U(ii).*XVal.^(ii-1);
        end

    case 'symbolic'  
        %  Mean square system construction.
        %----------------------------------
        % G : Gram Matrix
        % M : Matrix of constrains
        % B : Second Member
        %-------------------------
        G = zeros(N,N);
        M = zeros(1,N);
        B = zeros(N,1);        
        for i = 1:N
            RI = R(XVal,i,a,b);
            for j=1:N
                G(i,j) = sum(RI.*R(XVal,j,a,b));
            end
            % Constraint.
            M(1,i) = sum(RI);
            % Second member.
            B(i,1) = sum(y.*R(x,i,a,b));
        end
        rk = rank(M,sqrt(eps)/100);
        if rk<1
            M = [];
            NBConstrains = NBConstrains-1;
        end
        next = size(M,1)+1;
        
        % Add eventual boundary constrains.
        %----------------------------------
        if (Regularity > -1) && (N > NBConstrains)
            for i = 1:N
                M([next,next+1],i) = [R(a,i,a,b) ; R(b,i,a,b)];
            end
            nbRow = size(M,1);
            rk = rank(M,sqrt(eps)/100);
            if rk<nbRow
                M(rk+1:nbRow,:) = [];
                NBConstrains = NBConstrains-(nbRow-rk);
            end
            next = size(M,1)+1;
            if Regularity > 0
                for i = 1:N
                    M([next,next+1],i) = [dR(a,i,a,b) ; dR(b,i,a,b)];
                end
                nbRow = size(M,1);
                rk = rank(M,sqrt(eps)/100);
                if rk<nbRow
                    M(rk+1:nbRow,:) = [];
                    NBConstrains = NBConstrains-(nbRow-rk);
                end
            end
        end
        if NBConstrains>0 , B(N+1:N+NBConstrains,1) = 0; end
        
        % Solving linear system.
        %-----------------------
        A = [G M';M zeros(NBConstrains,NBConstrains)];
        U = A\B;
        PSI = 0;
        for i = 1:N
            PSI = PSI+U(i).*R(XVal,i,a,b);
        end
end

% Interpolation on a NbPts-grid
XValOLD = XVal;
XVal = linspace(0,1,NbPts);
PSI  = interp1(XValOLD,PSI,XVal);

% L2 Normalization.
XStep = XVal(2)-XVal(1);
NC = sqrt(sum(PSI.^2)*XStep);
PSI = PSI/NC;
