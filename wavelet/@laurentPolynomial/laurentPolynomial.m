classdef laurentPolynomial
    %LAURENTPOLYNOMIAL Laurent polynomial
    %   LP = laurentPolynomial creates a Laurent polynomial with coefficient
    %   equal to 1 and maximum order equal to zero.
    %
    %   LP = laurentPolynomial('Coefficients',C) creates a Laurent
    %   polynomial with real-valued coefficients specified in the vector C.
    %   If k is the length of the vector C, LP represents the following
    %   Laurent polynomial:
    %       P(z) = C(1) + C(2)*z^(-1) + ... + C(k)*z^(-k+1)
    %   where the maximum order of the Laurent polynomial is zero.
    %
    %   LP = laurentPolynomial(...,'MaxOrder',M) creates a Laurent
    %   polynomial with maximum order equal to the specified integer M.
    %   Unless specified, the coefficient of the Laurent polynomial is
    %   equal to 1.
    %
    % LAURENTPOLYNOMIAL Properties:
    %
    %   Coefficients   -   Coefficients of the Laurent polynomial
    %   MaxOrder       -   Maximum order of the Laurent polynomial
    %
    % LAURENTPOLYNOMIAL Methods:
    %
    %   degree        -    Degree of Laurent polynomial
    %   dyaddown      -    Dyadic downsampling of Laurent polynomial
    %   dyadup        -    Dyadic upsampling of Laurent polynomial
    %   eq            -    Equality of two Laurent polynomials
    %   euclid        -    Euclidean division of two Laurent polynomials
    %   polyphase     -    Polyphase components of Laurent polynomial
    %   plus          -    Add two Laurent polynomials
    %   minus         -    Difference of two Laurent polynomials
    %   mtimes        -    Product of two Laurent polynomials
    %   mpower        -    Laurent polynomial exponentiation
    %   horzcat       -    Horizontal concatenation of Laurent polynomials
    %   vertcat       -    Vertical concatenation of Laurent polynomials
    %   reflect       -    Reflect Laurent polynomial
    %   lp2filters    -    Laurent polynomials to filters
    %   lp2ls         -    Laurent polynomials to lifting steps and
    %                      normalization factors
    %   ne            -    Inequality of two Laurent polynomials
    %   rescale       -    Rescale Laurent polynomial by nonzero scalar
    %   uminus        -    Unary negative of Laurent polynomial
    %
    %   % Example 1:
    %   %   Obtain a Laurent polynomial for specified coefficients and
    %   %   maximum order.
    %   LP = laurentPolynomial('Coefficients',1:5,'MaxOrder',2);
    %
    %   See also LAURENTMATRIX, LIFTINGSCHEME

    %   Copyright 2021 The MathWorks, Inc.

    %#codegen
    properties
        % Laurent polynomial coefficients. Coefficients is a real-valued
        % scalar or vector.
        Coefficients
        % An integer specifying the maximum order of the Laurent
        % polynomial.
        MaxOrder
    end

    methods
        function obj = laurentPolynomial(varargin)
            narginchk(0,4);

            if nargin > 0
                [obj,isC,isM] = parseInputs(obj,varargin{:});
                C = isC;
                coder.varsize('C',[1 inf],[0 1]);
                obj.Coefficients = C;
                obj.MaxOrder = isM;

            else
                obj.Coefficients = 1;
                obj.MaxOrder = 0;
            end
        end
    end

    % setter/getter methods
    methods
        function obj = set.Coefficients(obj,C)
            C1 = C;
            coder.varsize('C1',[1 50],[0 1]);
            obj.Coefficients = C1;
        end

        function C = get.Coefficients(obj)
            C = obj.Coefficients;
        end

        function obj = set.MaxOrder(obj,M)
            validateattributes(M,{'numeric'},{'scalar','nonnan',...
                'finite','real','integer','nonnan'});
            obj.MaxOrder = double(M);
        end

        function M = get.MaxOrder(obj)
            M = obj.MaxOrder;
        end
    end

    % math operation methods
    methods
        function P = plus(Ai,Bi)
            %PLUS Laurent polynomial addition.
            %   P = PLUS(A,B) returns the Laurent polynomial that is the
            %   sum of the two Laurent polynomials A and B.
            %
            %   % Example: Obtain the sum of two Laurent polynomials A and
            %   % B.
            %   A = laurentPolynomial('Coefficients',1:3,'MaxOrder',0);
            %   B = laurentPolynomial('Coefficients',-1:3,'MaxOrder',-4);
            %   S = plus(A,B);
            %
            %   See also MINUS.

            coder.internal.assert((isnumeric(Ai)||isa(Ai, ...
                'laurentPolynomial')),'Wavelet:Lifting:InvalidInputMath');

            coder.internal.assert((isnumeric(Bi)||isa(Bi, ...
                'laurentPolynomial')),'Wavelet:Lifting:InvalidInputMath');

            if isnumeric(Ai)
                A = laurentPolynomial('Coefficients',Ai,'MaxOrder',0);
                dA = 0;
            else
                A = Ai;
                dAm = A.MaxOrder;
                dA = dAm(1);
            end

            if  isnumeric(Bi)
                B = laurentPolynomial('Coefficients',Bi,'MaxOrder',0);
                dB = 0;
            else
                B = Bi;
                dBm = B.MaxOrder;
                dB = dBm(1);
            end

            dP = max([dA,dB]);
            cA = A.Coefficients;
            coder.varsize('cA');
            lA = length(cA);
            cB = B.Coefficients;
            lB = length(cB);
            nbCoefs = dP - min([dA-lA+1,dB-lB+1])+1;
            cP = zeros(1,nbCoefs,'like',cA);
            coder.varsize('cP');
            idxBeg = 1+dP-dA;
            idxEnd = idxBeg +lA-1;
            cP(idxBeg:idxEnd) = cA;
            idxBeg = 1+dP-dB; 
            idxEnd = idxBeg +lB-1;
            cP(idxBeg:idxEnd) = cP(idxBeg:idxEnd)+cB;
            P2 = laurentPolynomial('Coefficients',cP,'MaxOrder',dP);
            P = reduceCM(P2);
        end

        function P = minus(A,B)
            %MINUS Laurent polynomial subtraction.
            %   P = MINUS(A,B) returns the Laurent polynomial that is the
            %   difference of the two Laurent polynomials A and B.
            %
            %   %Example:
            %   A = laurentPolynomial('Coefficients',1:3,'MaxOrder',0);
            %   B = laurentPolynomial('Coefficients',-1:3,'MaxOrder',-4);
            %
            %   % Obtain the difference of A and B.
            %   P = minus(A,B);
            %
            %   See also PLUS.

            coder.internal.assert((isnumeric(A)||isa(A, ...
                'laurentPolynomial')),'Wavelet:Lifting:InvalidInputMath');

            coder.internal.assert((isnumeric(B)||isa(B, ...
                'laurentPolynomial')),'Wavelet:Lifting:InvalidInputMath');            

            if isnumeric(B)
                Bneg = laurentPolynomial("Coefficients",-B,"MaxOrder",0);
            else
                Bneg = -B;
            end
            
            P = plus(A,Bneg);
        end

        function P = uminus(A)
            %UMINUS Unary minus for Laurent polynomial.
            %   -A negates the coefficients of the Laurent polynomial A.

            P = laurentPolynomial('Coefficients',-A.Coefficients,...
                'MaxOrder',A.MaxOrder);
        end

        function P = mtimes(A,B)
            %MTIMES Laurent polynomial multiplication.
            %   P = MTIMES(A,B) returns the Laurent polynomial that is the
            %   product of the two Laurent polynomials A and B.

            narginchk(1,inf)
            coder.internal.assert(isa(A,'laurentPolynomial'),...
                'Wavelet:Lifting:InvalidInputMath');
            coder.internal.assert(isa(B,'laurentPolynomial'),...
                'Wavelet:Lifting:InvalidInputMath');

            dA = A.MaxOrder;
            dB = B.MaxOrder;
            cA = A.Coefficients;
            cB = B.Coefficients;
            dP = dA+dB;
            cP = conv(cA,cB);
            P = laurentPolynomial('Coefficients',cP,'MaxOrder',dP);
            P = reduceCM(P);
        end

        function Q = mpower(P,pow)
            %MPOWER Laurent polynomial exponentiation.
            %   MPOWER(P,POW) raises the Laurent polynomial P to the power
            %   POW, where POW is an integer. If POW is negative, P must be
            %   a monomial.

            coder.internal.assert(~(pow ~= fix(pow)),...
                'Wavelet:FunctionArgVal:Invalid_PowVal');

            Q = laurentPolynomial;

            if pow > 0
                for k = 1:pow(1) , Q = Q*P; end
            elseif pow < 0
                coder.internal.assert((degree(P) == 0),...
                    'Wavelet:Lifting:InvalidPow');
                D = laurentPolynomial('Coefficients',...
                    1./(P.Coefficients),'MaxOrder',-P.MaxOrder);
                for k = 1:abs(pow(1)) , Q = Q*D; end
            end
        end

        function R = eq(Ai,Bi)
            %EQ Laurent polynomials equality test.
            %   EQ(A,B) returns 1 if the two Laurent polynomials A and B
            %   are equal and 0 otherwise.
            %
            %   %Example:
            %   A = laurentPolynomial('Coefficients',2,'MaxOrder',-1);
            %   B = laurentPolynomial('Coefficients',5,'MaxOrder',0);
            %   isEQ = eq(A,B);
            %
            %   See also NE.

            if isa(Ai,'laurentPolynomial')
                A = Ai;
            elseif isnumeric(Ai)
                A = laurentPolynomial('Coefficients',Ai);
            else
                coder.internal.error('Wavelet:Lifting:InvalidInputEq')
            end

            if isa(Bi,'laurentPolynomial')
                B = Bi;
            elseif isnumeric(Bi)
                B = laurentPolynomial('Coefficients',Bi);
            else
                coder.internal.error('Wavelet:Lifting:InvalidInputEq')
            end

            A = reduceCM(A);
            B = reduceCM(B);

            CA = A.Coefficients;
            coder.varsize('CA');
            CB = B.Coefficients;
            coder.varsize('CB');

            epsilon = sqrt(eps);
            if ((A.MaxOrder-B.MaxOrder) == 0) && (length(CA) == length(CB))

                R = (max(abs(A.Coefficients-B.Coefficients)) < epsilon);
            else
                R = false;
            end
        end

        function R = ne(A,B)
            %NE Laurent polynomial inequality test.
            %   NE(A,B) returns 1 if the two Laurent polynomials A and B
            %   are different and 0 otherwise.
            %
            %   See also EQ.

            R = ~eq(A,B);
        end

        function H = horzcat(varargin)
            %HORZCAT Horizontal concatenation of multiple Laurent
            %   polynomials
            %   H = horzcat(P1,P2,...,Pn) returns a cell array H of Laurent
            %   polynomials obtained by horizontal concatenation of the
            %   Laurent polynomials P1, P2, ..., Pn.
            %
            %   % Example: Obtain a horizontal concatenation of the Laurent
            %   % polynomials Z and Z2.
            %   Z = laurentPolynomial('Coefficients',1,'MaxOrder',1);
            %   Z2 = laurentPolynomial('Coefficients',1,'MaxOrder',2);
            %   H = [Z Z2];
            %
            %   See also VERTCAT.
            

            H = cat(2,varargin{:});
        end

        function V = vertcat(varargin)
            %VERTCAT Vertical concatenation of multiple Laurent polynomials
            %   V = vertcat(P1,P2,...,Pn) returns a cell array V of Laurent
            %   polynomials obtained by vertical concatenation of the
            %   Laurent polynomials P1, P2, ..., Pn.
            %
            %   % Example: Obtain a vertical concatenation of the Laurent
            %   % polynomials Z and Z2.
            %   Z = laurentPolynomial('Coefficients',1,'MaxOrder',1);
            %   Z2 = laurentPolynomial('Coefficients',1,'MaxOrder',2);
            %   V = [Z; Z2];
            %
            %   See also HORZCAT.

            V = cat(1,varargin{:});
        end

        function R = rescale(L,a)
            %RESCALE Scale the coefficients of the Laurent polynomial by a
            %  real-valued scalar.
            %  R = rescale(L,c) returns the Laurent polynomial R after
            %  scaling the coefficients of the Laurent polynomial L by
            %  factor c. The scaling factor c must be a nonzero scalar.

            validateattributes(a,{'numeric'},{'scalar','nonzero'});

            R = laurentPolynomial('Coefficients',a*(L.Coefficients),...
                'MaxOrder',(L.MaxOrder));
        end
    end

    % other methods
    methods
        function d = degree(obj)
            % DEGREE Degree of a Laurent polynomial
            %   DEGREE(P) returns the degree of the Laurent polynomial P
            %   that is one less than length(P.Coefficients).
            %
            %   %Example:
            %   P = laurentPolynomial('Coefficients',1:3,'MaxOrder',0);
            %   d = degree(P)
            C = obj.Coefficients;
            d = numel(C)-1;
        end

        function [E,O] = polyphase(P)
            %POLYPHASE Even and odd parts of a Laurent polynomial.
            %   [E,O] = POLYPHASE(P) returns the even part E and odd part O
            %   of the Laurent polynomial P. The polynomial E is such that:
            %           E(z^2) = [P(z) + P(-z)]/2
            %   The polynomial O is such that:
            %           O(z^2) = [P(z) - P(-z)] / [2*z^(-1)]
            %
            %   See also DYADDOWN, DYADUP.

            C = P.Coefficients;
            D = P.MaxOrder;
            E = laurentPolynomial('Coefficients',C(1+mod(D,2):2:end),...
                'MaxOrder',floor(D/2));
            O = laurentPolynomial('Coefficients',C(1+mod(D+1,2):2:end),...
                'MaxOrder',floor((D+1)/2));
        end

        function Q = dyaddown(P)
            %DYADDOWN Dyadic downsampling of a Laurent polynomial.
            %   Q = DYADDOWN(P) returns the Laurent polynomial Q obtained
            %   by downsampling the Laurent polynomial P.
            %   If   P(z) = ... C(-2)*z^(-2) + C(-1)*z^(-1) + C(0) + ...
            %               ... C(+1)*z^(+1) + C(+2)*z^(+2) + ...
            %   then Q(z) = ... C(-2)*z^(-1) + C(0) + C(+2)*z^(+1) + ...
            %
            %   See also DYADUP, POLYPHASE, REFLECT.

            C = P.Coefficients;
            D = P.MaxOrder;
            newC = C(1+mod(D,2):2:end);
            newD = floor(D/2);
            Q    = laurentPolynomial('Coefficients',newC,'MaxOrder',newD);
        end

        function Q = dyadup(P)
            %DYADUP Dyadic upsampling of a Laurent polynomial.
            %   Q = DYADUP(P) returns the Laurent polynomial Q obtained by
            %   upsampling the Laurent polynomial P: Q(z) = P(z^2).
            %   If   P(z) = ... C(-1)*z^(-1) + C(0) + C(+1)*z^(+1) + ...
            %   then Q(z) = ... C(-1)*z^(-2) + C(0) + C(+1)*z^(+2) + ...
            %
            %   See also DYADDOWN, POLYPHASE, REFLECT.
            C = P.Coefficients;
            D = P.MaxOrder;
            newC = dyadup(C,0);
            Q = laurentPolynomial('Coefficients',newC,'MaxOrder',2*D);
        end

        function Q = reflect(P)
            %REFLECT Reflection of a Laurent polynomial.
            %   Q = REFLECT(P) returns the Laurent polynomial Q that is
            %   the reflection of the Laurent polynomial P: Q(z) = P(1/z).
            %
            %   See also DYADDOWN, DYADUP.
            C = P.Coefficients;
            coder.varsize('C',[1 inf],[0 1]);
            D = P.MaxOrder;
            L = length(C);
            newD = -(D-L+1);
            newC = fliplr(C);
            Q = laurentPolynomial('Coefficients',newC,'MaxOrder',newD);
        end

        function DEC = euclid(Ai,Bi)
            %EUCLID Euclidean algorithm for Laurent polynomials.
            %   DEC = EUCLID(A,B) returns an array of structures DEC that
            %   include the Euclidean division of A by B as follows:
            %      A = B*Q + R, where Q is the quotient and R the remainder.
            %
            %   The i-th row of DEC contains one Euclidean division of A by
            %   B such that
            %   A = B*(DEC(i,1).LP) + DEC(i,2).LP,
            %   where:
            %        DEC(i,1).LP is the Laurent polynomial that corresponds
            %        to the quotient.
            %        DEC(i,2).LP is the Laurent polynomial that corresponds
            %        to the remainder.
            %
            %   The array of structures DEC contains at most four rows.
            %
            %   %Example:
            %     % Create two Laurent polynomials
            %     A = laurentPolynomial('Coefficients',(1:4),'MaxOrder',0);
            %     B = laurentPolynomial('Coefficients',[1 2],'MaxOrder',0);
            %
            %     % Obtain the Euclidian division of A by B
            %     DEC = euclid(A,B);
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
            %   See also LAURENTPOLYNOMIAL.

            if isa(Ai,'laurentPolynomial')
                A = Ai;
            elseif isnumeric(Ai)
                A = laurentPolynomial('Coefficients',Ai);
            else
                coder.internal.assert('Wavelet:Lifting:InvalidInputEq')
            end

            if isa(Bi,'laurentPolynomial')
                B = Bi;
            elseif isnumeric(Bi)
                B = laurentPolynomial('Coefficients',Bi);
            else
                coder.internal.assert('Wavelet:Lifting:InvalidInputEq')
            end

            A = reduceCM(A);
            B = reduceCM(B);

            maxDEG_A = A.MaxOrder;
            maxDEG_B = B.MaxOrder;
            cA = A.Coefficients;
            lA = length(cA);
            cB = B.Coefficients;
            lB = length(cB);
            minDEG_A = maxDEG_A-lA+1;
            minDEG_B = maxDEG_B-lB+1;
            maxDEG_LEFT  = maxDEG_A-maxDEG_B;
            minDEG_RIGHT = minDEG_A-minDEG_B;

            dL = lA-lB;
            qLEFT_2 = zeros(1,dL+1);
            qRIGHT_2 = zeros(1,dL+1);
            rLEFT_2 = coder.nullcopy(cA);
            rRIGHT_2 = coder.nullcopy(cA);
            zr = laurentPolynomial('Coefficients',0,'MaxOrder',0);
            Dtmp = struct('LP',zr);

            if dL > 0
                rLEFT = cA;
                qLEFT = zeros(1,dL+1);

                for j = 1:dL+1
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

                DEC2 = repmat(Dtmp,4,2);
                coder.varsize('DEC2',[8,2],[1,0]);
                DEC2(1,1).LP = (laurentPolynomial('Coefficients',qLEFT,...
                    'MaxOrder',maxDEG_LEFT(1)));
                DEC2(1,2).LP = (laurentPolynomial('Coefficients',rLEFT,...
                    'MaxOrder',maxDEG_A(1)));
                DEC2(2,1).LP = (laurentPolynomial('Coefficients',qLEFT_2,...
                    'MaxOrder',maxDEG_LEFT(1)));
                DEC2(2,2).LP = (laurentPolynomial('Coefficients',rLEFT_2,...
                    'MaxOrder',maxDEG_A(1)));
                DEC2(3,1).LP = (laurentPolynomial('Coefficients',qRIGHT_2,...
                    'MaxOrder',maxDEG_LEFT(1)));
                DEC2(3,2).LP = (laurentPolynomial('Coefficients',rRIGHT_2,...
                    'MaxOrder',maxDEG_A(1)));
                DEC2(4,1).LP = (laurentPolynomial('Coefficients',qRIGHT,...
                    'MaxOrder',maxDEG_RIGHT(1)));
                DEC2(4,2).LP = (laurentPolynomial('Coefficients',rRIGHT,...
                    'MaxOrder',maxDEG_A(1)));

            elseif dL == 0
                qLEFT  = cA(1)/cB(1);
                qRIGHT = cA(end)/cB(end);
                rLEFT  = cA-qLEFT*cB;
                rRIGHT = cA-qRIGHT*cB;
                maxDEG_RIGHT = minDEG_RIGHT;
                DEC2 = repmat(Dtmp,2,2);
                DEC2(1,1).LP = (laurentPolynomial('Coefficients',qLEFT,...
                    'MaxOrder',maxDEG_LEFT));
                DEC2(1,2).LP = (laurentPolynomial('Coefficients',rLEFT,...
                    'MaxOrder',maxDEG_A));
                DEC2(2,1).LP = (laurentPolynomial('Coefficients',qRIGHT,...
                    'MaxOrder',maxDEG_RIGHT));
                DEC2(2,2).LP = (laurentPolynomial('Coefficients',rRIGHT,...
                    'MaxOrder',maxDEG_A));
            else
                DEC2 = repmat(Dtmp,1,2);
                Q = zr;
                R = A;
                DEC2(1,1).LP = Q;
                DEC2(1,2).LP = R;
            end
            nbDEC = size(DEC2,1);

            idx = true(1,nbDEC);
            for j = 1:nbDEC
                for k = j+1:nbDEC
                    if idx(k) == 1
                        idx(k) = (DEC2(j,1).LP ~= DEC2(k,1).LP) || ...
                            (DEC2(j,2).LP ~= DEC2(k,2).LP);
                    end
                end
            end

            DEC = DEC2(idx,:);
        end

        function [LoD,HiD,LoR,HiR] = lp2filters(LoDz,HiDz,LoRz,HiRz,signFLAG)
            %LP2FILTERS Laurent polynomials to filters.
            %   [LoD,HiD,LoR,HiR] = LP2FILTERS(LoDz,HiDz,LoRz,HiRz) returns
            %   the filters associated with the Laurent polynomials
            %   (LoDz,HiDz,LoRz,HiRz) that represent the following:
            %       LoRz <-> Z(LoR)
            %       HiRz <-> Z(HiR)
            %       LoDz <-> Z(LoD)
            %       HiDz <-> Z(HiD)
            %   where Z(.) is the z-transform of the corresponding filter.
            %
            %   [LoD,HiD,LoR,HiR] = LP2FILTERS(...,signFLAG) changes the
            %   signs of the two highpass filters (HiD,HiR) when signFLAG
            %   is equal to 1. Default for signFLAG is 0.
            %
            %   % Example
            %   % Obtain the Laurent polynomials (LoDz,HiDz,LoRz,HiRz) that
            %   % correspond to the filter coefficients (LoD,HiD,LoR,HiR)
            %   % respectively. Revert the process and get the filter
            %   % coefficients from the Laurent polynomials and verify they
            %   % are the same.
            %
            %   [LoD,HiD,LoR,HiR] = wfilters('db2');
            %   [LoDz,HiDz,LoRz,HiRz] = filters2lp({LoR});
            %   [LoD2,HiD2,LoR2,HiR2] = lp2filters(LoDz,HiDz,LoRz,HiRz);
            %   max(abs(LoD-LoD2))
            %   max(abs(HiD-HiD2))
            %   max(abs(LoR-LoR2))
            %   max(abs(HiR-HiR2))
            %
            %   % For an orthogonal wavelet, observe that LoDz is the 
            %   % reflection of the z-transform of LoR.
            %   LoDzr = reflect(LoDz);
            %   isORTH = (LoDzr == LoRz);
            %   See also LAURENTPOLYNOMIAL, FILTERS2LP.

            if nargin == 4 
                signFLAG = 0;
            end
            
            validateattributes(signFLAG, {'logical','numeric'},...
                {'scalar'},'laurentPolynomial','signFLAG');

            isORTH = ((LoDz) == reflect(LoRz));
            [LoD,HiD] = getFilters('a',LoDz,HiDz,isORTH,signFLAG);
            [LoR,HiR] = getFilters('s',LoRz,HiRz,isORTH,signFLAG);
        end

        function [LS,K] = lp2LS(waveType,LoRz,HiRz,factMode)
            %LP2LS Laurent polynomial to lifting steps and normalization
            % factors.
            %   [LS,K] = LP2LS(WAVETYPE,LoRz,HiRz,FACTMODE) returns the
            %   lifting scheme steps LS and normalization factors K
            %   associated with the Laurent polynomials LoRz and HiRz.
            %
            %   WAVETYPE specifies the wavelet type that corresponds to
            %   LoRz and HiRz. Valid values for WAVETYPE are as follows:
            %   'o' - orthogonal wavelets
            %   'b' - biorthogonal wavelets
            %
            %   FACTMODE specifies if the factorization mode is 'synthesis'
            %   (synthesis factorization) or 'analysis' (analysis
            %   factorization). Default FACTMODE is 'analysis'.
            %
            %   %Example: Obtain the lifting steps and normalization 
            %   % factors that correspond to the Laurent polynomials that  
            %   % denote the z-transform of the filters for 'db1'.
            %   [~,~,LoRz,HiRz] = wave2lp('db1');
            %   [LSact1,Kact1] = lp2LS('o',LoRz,HiRz,'s');

            if nargin < 4
                factMode = 'analysis';
            end

            if any(strncmpi({'analysis','synthesis'},factMode,1))
                factMode1 = lower(factMode(1));
            else
                coder.internal.error('Wavelet:FunctionArgVal:Invalid_FactVal');
            end

            switch waveType
                case 'o'
                    [LS,K] = LP2LSOrth(LoRz,HiRz,factMode1);
                case 'b'
                    [He,Ho] = polyphase(LoRz);
                    [Ge,Go] = polyphase(HiRz);
                    PM = {He,Ge;Ho,Go};
                    [FactorTAB,m] = eucfacttab(He,Ho);
                    MatFACT = makeMatFact(FactorTAB,PM,m);

                    nbFACT = length(MatFACT);
                    % Compute lifting schemes.
                    if nbFACT > 0

                        switch factMode1
                            case {'a','s'}   % dual_LS or prim_LS
                                % Compute Lifting Steps.
                                APMF = pmf2apmf(MatFACT,factMode1);
                                [LS,K] = apmf2LS(APMF);
                            otherwise
                                coder.internal.error('Wavelet:FunctionArgVal:Invalid_FactVal');
                        end
                    else
                        LS = liftingStep();  K = 1;
                    end
                otherwise
                    coder.internal.error('Wavelet:Lifting:InvalidWavType');
            end
        end
    end

    methods (Access = private)
        function [obj,isC,isM] = parseInputs(obj,varargin)

            % parser for the name value-pairs
            parms = {'Coefficients','MaxOrder'};

            % Select parsing options.
            poptions = struct('PartialMatching','unique');
            pstruct = coder.internal.parseParameterInputs(parms,...
                poptions,varargin{:});
            C = coder.internal.getParameterValue(pstruct.Coefficients, ...
                [],varargin{:});
            M = coder.internal.getParameterValue(pstruct.MaxOrder, [],...
                varargin{:});
         
            if isempty(C)
                isC = 1;
                coder.varsize('isC',[1 inf],[0 1]);
            else
                validateattributes(C,{'numeric'},{'vector','real','nonnan'});
                C1 = double(C);
                if isrow(C1) || iscolumn(C1)
                    C2 = C1(:).';
                end
                
                isC = C2;
            end
                                       
            if isempty(M)
                isM = 0;
            else
                isM = M;
            end

        end

        function C = cat(dim,varargin)
            n = numel(varargin);
            sz = zeros(n,1);
            sz1 = zeros(n,1);
            sz2 = zeros(n,1);

            % check if all elements in varargin have same dimension
            for ii = 1:n
                sz(ii) = numel(size(varargin{ii}));
                sz1(ii) = size(varargin{ii},1);
                sz2(ii) = size(varargin{ii},2);
            end

            switch dim
                case 1  % vertical concatenation
                    C = cell(sum(sz1),sz2(1));
                    s = cumsum(sz1);

                    for ii = 1:n
                        switch ii
                            case 1
                                C{1:s(ii),:} = varargin{ii};
                            otherwise
                                C{s(ii-1)+1:s(ii),:} = varargin{ii};
                        end
                    end

                case 2  % horizontal concatenation

                    C = cell(sz1(1),sum(sz2));
                    s = cumsum(sz2);

                    for ii = 1:n
                        switch ii
                            case 1
                                C{:,1:s(ii)} = varargin{ii};
                            otherwise
                                C{:,s(ii-1)+1:s(ii)} = varargin{ii};
                        end
                    end
            end
        end

        function [LS,K] = LP2LSOrth(Hs,Gs,factMode)
            % Synthesis Polyphase Matrix factorizations
            [E_H,O_H] = polyphase(Hs);
            [Ge,Go] = polyphase(Gs);
            PM = {E_H,Ge;O_H,Go};

            % Compute factorizations.
            len_E_H = length(E_H.Coefficients);
            R_E_H = mod(len_E_H,2);
            differ_deg = degree(E_H)-degree(O_H);
            C = laurentMatrix;
            F = struct('Mat',C);
            MatFACT = repmat(F,1,1);
            coder.varsize('MatFACT');

            switch R_E_H
                case 0  % Even number of factors = length(FactorTAB) - 1
                    if differ_deg >= 0
                        [FactorTAB,m] = eucfacttab(E_H,O_H);
                        MatFACT = makeMatFact(FactorTAB,PM,m);
                    else
                        [FactorTAB,m] = eucfacttab(O_H,E_H);
                        MatFACT = makeMatFact(FactorTAB,PM,m);
                    end
                case 1  % Odd number of factors = length(FactorTAB) - 1
                    if differ_deg <= 0
                        [FactorTAB,m] = eucfacttab(O_H,E_H);
                        MatFACT = makeMatFact(FactorTAB,PM,m);
                    else
                        [FactorTAB,m] = eucfacttab(E_H,O_H);
                        MatFACT = makeMatFact(FactorTAB,PM,m);
                    end
            end

            nbFACT = length(MatFACT);

            % Compute lifting schemes.
            if nbFACT > 0
                switch factMode
                    case {'a','s'}   % dual_LS or prim_LS
                        % Compute Lifting Steps.
                        APMF = pmf2apmf(MatFACT,factMode);
                        [LS,K] = apmf2LS(APMF);
                    otherwise
                        coder.internal.error('Wavelet:FunctionArgVal:Invalid_FactVal');
                end
            else
                LS = liftingStep();  K = 1;
            end
        end

        function R = isconst(P)
            %ISCONST True for a constant Laurent polynomial.
            %   R = ISCONST(P) returns 1 if P is a constant Laurent
            %   polynomial and 0 otherwise.

            D = P.MaxOrder;
            R = (D == 0) && (length(P.Coefficients)==1);
        end
    end
end

function objN = reduceCM(obj)
C = obj.Coefficients;
M = obj.MaxOrder;
C(abs(C) <= 1e-9) = 0;
idx = find(abs(C));

if isempty(idx)
    CN = 0;
    MN = 0;
else
    i1 = idx(1);
    i2 = idx(end);
    CN = C(i1:i2);
    ord = (0:-1:-(numel(C)-1))+M;
    MN = ord(i1);
end

objN = laurentPolynomial('Coefficients',CN,'MaxOrder',MN);
end

function [Lo,Hi] = getFilters(typeFILT,H,G,isORTH,signFLAG)

Lo = H.Coefficients;
Hi = G.Coefficients;
lenLo = length(Lo);
lenHi = length(Hi);

powMAX = G.MaxOrder;
powMIN = powMAX-lenHi+1;
powHi = powMIN:powMAX;

if isORTH                   % Orthogonal case in necessary here.
    switch typeFILT
        case 'a' , AddPOW = 0;
        case 's' , AddPOW = 1;
    end
else                       % Part of biorthogonal case.
    [long,idx] = max([lenLo,lenHi]);
    add = fix(abs((lenLo-lenHi)/2));
    switch idx
        case 1 , Hi = extend_Filter(Hi,lenHi,long);
        case 2 , Lo = extend_Filter(Lo,lenLo,long);
    end
    switch typeFILT
        case 'a' , AddPOW = 1 + add;
        case 's' , AddPOW = 1;
    end
end
AddPOW = AddPOW + signFLAG;
powMUL = powHi(end) + AddPOW;
Hi = ((-1)^powMUL)*Hi;
end

function G = extend_Filter(F,len,long)
d = (long-len)/2;
G = [zeros(1,floor(d)) F zeros(1,ceil(d))];
end

%% functions for LP2LS
function [FactorTAB,m] = eucfacttab(A,B,flagConstREM)
%EUCFACTAB Euclidean factor table for Euclidean division algorithm.

if nargin < 3 , flagConstREM = 1; end

[EuclideTAB,FlgIdx,first] = euclidedivtab(A,B);
FactorTAB2 = cell(1,20);
zr = laurentPolynomial('Coefficients',0);
ii = 1;

for jj = 1:20
    FactorTAB2{ii,jj} = zr;
end

idxFactorise = 0;
m = 1;

for k = first:size(EuclideTAB,1)
    add = {reduceCM(EuclideTAB{k,1})};
    idx = k;

    while idx > 1
        add{end+1} = reduceCM(EuclideTAB{idx,3});
        idx = FlgIdx(idx,2);
    end

    if flagConstREM
        if (nnz(add{1,end}.Coefficients) == 1) && ...
                (nnz(add{1}.Coefficients) ~= 1)
            r = numel(add);
            add2 = add;
            for ii = 1:r
                jj = r+1-ii;
                add{ii} = add2{jj};
            end
        end
        addDEC = (degree(add{1}) == 0);
    else
        addDEC = 1;
    end

    if addDEC
        idxFactorise = idxFactorise+1;
        flpadd = add;
        r = numel(add);
        for ii = 1:r
            jj = r+1-ii;
            flpadd{ii} = add{jj};
        end

        n = numel(flpadd);
        if idxFactorise
            m = n;
        else
            m = max(m,n);
        end

        for ii = 1:20
            if (ii < n)
                FactorTAB2{idxFactorise,ii} = flpadd{ii};
            elseif (ii == n)
                FactorTAB2{idxFactorise,20} = flpadd{ii};
            end
        end
    end

    if idxFactorise == 1
        break;
    end

end

FactorTAB = cell(1,m);
for ii = 1:m
    if (ii < m)
        FactorTAB{ii} = FactorTAB2{ii};
    else
        FactorTAB{ii} = FactorTAB2{20};
    end
end

end

function [EuclideTAB,FlgIdx,first] = euclidedivtab(A,B)
%EUCLIDEDIVTAB Table obtained by the Euclidean division algorithm.
% [EuclideTAB,FlgIdx,first] = euclidedivtab(A,B) returns a struct
% EuclideTAB that includes possible factorizations of the two Laurent
% polynomials A and B obtained from Euclidean division algorithm. There are
% several euclidian divisions of A by B
%
%=========================================================================
% Basic Euclidean Algorithm for Laurent Polynomials
%--------------------------------------------------
% A, B two Laurent polynomials with degree(A) => degree(B).
% Initialization: A(0) = A , B(0) = B
% while B(i) ~= 0
%   A(i) = B(i)*Q(i) + R(i)        <-- Euclidean Division
%   A(i+1) = B(i) , B(i+1) = R(i)
% end
%--------------------------------------------------
% See also EUCLID.

FlgIdx2 = zeros(4050,2);
ETAB1 = {A};
ETAB2 = {B};
zr = laurentPolynomial('Coefficients',0);
ETAB3 = {zr};
FlgIdx2(1,1:2) = [1 0];
idxLine = 1;
continu = 1;
cnt = 1;

while continu
    toDIV = FlgIdx2(idxLine,1);
    if toDIV
        FlgIdx2(idxLine,1) = NaN;
        A = ETAB1{idxLine};
        B = ETAB2{idxLine};
        DEC = euclid(A,B);
        nbDEC = size(DEC,1);
        indx = (1:nbDEC)+cnt;
        cnt = cnt+nbDEC;
        for k = 1:nbDEC
            cLP = max(abs(DEC(k,2).LP.Coefficients));
            flagDIV = (degree(DEC(k,2).LP) && (cLP >= 1e-12));
            ETAB1{end+1} = B;
            ETAB2{end+1} = DEC(k,2).LP;
            ETAB3{end+1} = DEC(k,1).LP;
            FlgIdx2(indx(k),1) = flagDIV;
            FlgIdx2(indx(k),2) = idxLine;
        end
    end
    idxLine = idxLine+1;
    if cnt >= 4000
        break;
    end

    if idxLine > size(FlgIdx2,1) , break; end
end

m = min(4000,cnt);
EuclideTAB = cell(m,3);
for ii = 1:m
    EuclideTAB{ii,1} = ETAB1{ii};
    EuclideTAB{ii,2} = ETAB2{ii};
    EuclideTAB{ii,3} = ETAB3{ii};
end

FlgIdx = FlgIdx2(1:m,:);
first = 1;
while isnan(FlgIdx(first,1)) , first = first+1; end
end

function MF2 = makeMatFact(FactorTAB,M,lenFACT)
%MAKEMATFACT Make matrix factorization.
%   MatFACT = MAKEMATFACT(FactorTAB,M,lenFACT) Computes all the
%   factorizations for matrix M, using the array of lenFACT factors in
%   FactorTAB.

% Initialization
remVAL  = mod(lenFACT-1,2);
zr = laurentPolynomial('Coefficients',0);
one = laurentPolynomial('Coefficients',1);
I = laurentMatrix;
F = struct('Mat',I);
MF = repmat(F,1,lenFACT-1);
MF2 = MF;

if isempty(FactorTAB) , return; end
idx = 1;

% Compute factorizations.
%------------------------
FACT = cell(1,lenFACT);
for ii = 1:lenFACT
    if (ii < lenFACT)
        FACT{ii} = FactorTAB{idx,ii};
    else
        FACT{ii} = FactorTAB{idx,end};
    end
end

if (degree(FACT{1,end}) ~= 0) && isconst(FACT{1,1})
    FACT2 = FACT;
    for ii = 1:lenFACT
        jj = lenFACT+1-ii;
        FACT{ii} = FACT2{jj};
    end
end

CF = FACT{end}.Coefficients;
mF = FACT{end}.MaxOrder;
iCF = 1./CF;
imF = -mF;
iFACT = laurentPolynomial('Coefficients',iCF,'MaxOrder',imF);
C = laurentMatrix('Elements',{FACT{end},zr;zr,iFACT});
for k = 1:lenFACT-1
    MF(k).Mat = I;
end

for k = 1:lenFACT-1
    if mod(k,2) == remVAL
        MF(k).Mat.Elements{2,1} = FACT{k};
    else
        MF(k).Mat.Elements{1,2} = FACT{k};
    end
end

H0 = I;
MP = H0.Elements;
coder.varsize('MP');
MA = H0.Elements;
coder.varsize('MA');

for k = 1:lenFACT
    switch k

        case lenFACT
            MA = MP;
            MP = prodCell(MA,C.Elements);

        case 1
            MB = MF(k).Mat.Elements;
            coder.varsize('MB');
            MP = prodCell(MA,MB);

        otherwise
            MA = MP;
            MB = MF(k).Mat.Elements;
            coder.varsize('MB');
            MP = prodCell(MA,MB);
    end
end

P0 = laurentMatrix('Elements',MP);
invP0 = inverse(P0);

H1 = laurentMatrix('Elements',{M{1,2};M{2,2}});
T = prod(invP0,H1);
Tz = T.Elements;
mtz = reduceCM(Tz{1}*(FACT{end}*FACT{end}));
R = laurentMatrix('Elements',{one,mtz;zr,one});

if ~isempty(R.Elements)
    MF2 = repmat(F,1,lenFACT+1);
    coder.varsize('MF2');
    for ii = 1:lenFACT+1
        if (ii < lenFACT)
            MF2(ii).Mat = MF(ii).Mat;
        elseif (ii == lenFACT)
            MF2(ii).Mat = R;
        else
            MF2(ii).Mat = C;
        end
    end
else
    MF2 = repmat(F,1,lenFACT);
    for ii = 1:lenFACT
        if (ii < lenFACT)
            MF2(ii).Mat = MF(ii).Mat;
        else
            MF2(ii).Mat = C;
        end
    end
end

end

function [APMF_1,APMF_2] = pmf2apmf(PMF,factMode)
%PMF2APMF Polyphase matrix factorization to analysis polyphase matrix
%         factorization.
%
%   APMF = PMF2APMF(PMF,FACTMODE) returns the analysis polyphase matrix
%   factorization APMF starting from the polyphase matrix factorization
%   PMF. FACTMODE indicates the type of PMF, the valid values for FACTMODE
%   are:
%     'analysis'  - Factors in PMF corresponds to the analysis polyphase
%                   matrix
%     'synthesis' - Factors in PMF corresponds to the synthesis polyphase
%                   matrix

if isempty(PMF)
    C = laurentMatrix;
    F = struct('Mat',C);
    APMF_1 = F;
    APMF_2 = F;
    coder.varsize('APMF_1');
    coder.varsize('APMF_2');
    return;
end
factMode = lower(factMode(1));

[APMF_1,APMF_2] = ONE_pmf2apmf(PMF,factMode);

end

function [APMF_1,APMF_2] = ONE_pmf2apmf(PMF,factMode)
C = laurentMatrix;
F = struct('Mat',C);
APMF_1 = F;
APMF_2 = F;
coder.varsize('APMF_1');
coder.varsize('APMF_2');
len = length(PMF);

if ~(PMF(len).Mat.Elements{1,1} == 0)
    PMF2 = PMF;
    ii = 1:len;
    jj = len+1-ii;
    PMF(ii) = PMF2(jj);
end

switch lower(factMode)
    case 'a'    % P-Tilda matrix factorization.
        APMF_1 = dualFact(PMF,len);
    case 's'    % P matrix factorization.
        APMF_1 = primalFact(PMF,len);
    case 't'    % P-Tilda and P matrices factorization.
        APMF_1 = dualFact(PMF,len);
        APMF_2 = primalFact(PMF,len);
end
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dec = dualFact(dec,len)    % P-Tilda matrix factorization.
for k = 1:len
    dec(k).Mat = reflect((dec(k).Mat)');
end
end
%---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---%
function dec = primalFact(dec,len)  % P matrix factorization.
zr = laurentPolynomial('Coefficients',0);
for k = 1:len
    if (dec(k).Mat.Elements{1,2}~= zr)
        dec(k).Mat.Elements{1,2} = -dec(k).Mat.Elements{1,2};
    elseif dec(k).Mat.Elements{2,1}~= zr
        dec(k).Mat.Elements{2,1} = -dec(k).Mat.Elements{2,1};
    else
        tmp = dec(k).Mat.Elements{1,1};
        dec(k).Mat.Elements{1,1} = dec(k).Mat.Elements{2,2};
        dec(k).Mat.Elements{2,2} = tmp;
    end
end
end

function  [LS,K] = apmf2LS(APMF)
%APMF2LS Analyzis polyphase matrix factorization to lifting scheme.
%   [LS,K] = APMF2LS(APMF) returns the lifting scheme steps LS and
%   normalization factor K that correspond to the analysis polyphase matrix
%   factorization APMF. APMF is a cell array of Laurent Matrices.

if isempty(APMF) , LS = liftingStep();  K = 1; return; end

nbLIFT = length(APMF);
b = APMF(1).Mat.Elements;
cb = b{1,1}.Coefficients;
K = [cb,1/cb];
zr = laurentPolynomial('Coefficients',0);
Stmp = struct('Type','','Coefficients',zeros(1,0,'like',cb),'MaxOrder',0);
coder.varsize('Stmp.Type');
coder.varsize('Stmp.Coefficients');
LS = repmat(Stmp,nbLIFT-1,1);

for jj = nbLIFT:-1:2
    k = 1+nbLIFT-jj;
    M = APMF(jj).Mat.Elements;
    P = M{1,2};
    if (P == zr)
        P = M{2,1};
        LS(k).Type = 'predict';
    else
        LS(k).Type = 'update';
    end

    LS(k).Coefficients = P.Coefficients;
    LS(k).MaxOrder = P.MaxOrder;
end
end

function MP = prodCell(MA,MB)
%MTIMES Laurent matrices multiplication.
%   P = prodCell(A,B) returns a cell array P that corresponds to the
%   entries of a Laurent Matrix that is the product of two Laurent matrices
%   whose elements are contained in the cell arrays A and B.

[rA,cA] = size(MA);
[rB,cB] = size(MB);

S = laurentPolynomial('Coefficients',0);

MP = cell(rA,cB);
coder.varsize('MP',[2 2],[1 1]);

coder.internal.assert(~(cA~=rB),'Wavelet:Lifting:InvalidMatDim', '*');

for i = 1:rA
    for j = 1:cB
        switch cA
            case 1
                MP{i,j} = MA{i,1}*MB{1,j};
            case 2
                MP{i,j} = (MA{i,1}*MB{1,j}) + (MA{i,2}*MB{2,j});
            otherwise
                MP{i,j} = S;
        end
    end
end
end

function Pv = prod(varargin)
%PROD Product of Laurent matrices.
%   P = PROD(M1,M2,...) returns a Laurent matrix which is the
%   product of the Laurent matrices Mi.

narginchk(1,inf);
nbIn = nargin;
Ptmp = struct('mat',varargin{1});
P = repmat(Ptmp,1,nbIn);

for k = 1:nbIn
    if (k == 1)
        P(k).mat = varargin{1};
    else
        P(k).mat = (P(k-1).mat * varargin{k});
    end
end

Pv = laurentMatrix('Elements',P(nbIn).mat.Elements);
end