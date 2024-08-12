classdef laurentMatrix
    %LAURENTMATRIX Laurent matrix
    %   LM = laurentMatrix creates a Laurent matrix that is a 2-by-2
    %   identity matrix.
    %
    %   LM = laurentMatrix('Elements',M) creates a Laurent matrix with
    %   elements specified by a cell array, M, that has at most two rows
    %   and two columns. Each element of M must be a real-valued numeric or
    %   a laurentPolynomial object.
    %
    % LAURENTMATRIX Properties:
    %
    %   Elements      -    Elements of a Laurent matrix
    %
    % LAURENTMATRIX Methods:
    %
    %   ctranspose    -    Transpose of a Laurent matrix
    %   det           -    Determinant of a Laurent matrix
    %   dispMat       -    Display a Laurent matrix
    %   dyaddown      -    Dyadic downsampling of a Laurent matrix
    %   dyadup        -    Dyadic upsampling of a Laurent matrix     
    %   inverse       -    Inverse of a Laurent matrix
    %   eq            -    Equality of two Laurent matrices
    %   plus          -    Add two Laurent matrices
    %   uminus        -    Unary negative of a Laurent matrix
    %   minus         -    Subtract two Laurent matrices
    %   mtimes        -    Multiply two Laurent matrices
    %   reflect       -    Reflect entries of a Laurent matrix
    %
    %   % Example 1:
    %   %   Obtain a Laurent matrix with elements specified in a 2-by-2
    %   %   cell array M.
    %   LP = laurentPolynomial('Coefficients',2,'MaxOrder',1);
    %   M = {1 0; LP 1};
    %   LM = laurentMatrix('Elements',M);
    %   invLM = inverse(LM);
    %
    %   % Example 2:
    %   %   Confirm that the sum, difference, and product of two Laurent 
    %   %   matrices are also Laurent matrices.
    %   LM1 = laurentMatrix();
    %   Z = laurentPolynomial('Coefficients',1);
    %   LM2 = laurentMatrix('Elements',{1 Z; 0 1});
    %   LMS = LM1+LM2;
    %   LMD = LM1-LM2;
    %   LMP = LM1*LM2;
    %   isa(LMS,'laurentMatrix')
    %   isa(LMD,'laurentMatrix')
    %   isa(LMP,'laurentMatrix')
    %
    %   See also LAURENTPOLYNOMIAL, LIFTINGSCHEME
    
    %   Copyright 2021 The MathWorks, Inc.

    %#codegen
    properties
        % A cell array of laurentPolynomial objects that correspond to the
        % entries of a Laurent matrix.
        Elements
    end
    
    methods
        function obj = laurentMatrix(varargin)
            narginchk(0,2);
             if nargin > 0
                [obj,isE] = parseInputs(obj,varargin{:});  
                obj.Elements = isE;
            else
                LP1 = laurentPolynomial;
                LP0 = laurentPolynomial('Coefficients',0);
                obj.Elements = {LP1 LP0;LP0 LP1};
            end
        end
    end
    
    % setter/getter methods
    methods
        function obj = set.Elements(obj,E)                        
            obj.Elements = E;
        end
        
        function C = get.Elements(obj)
            C = obj.Elements;
        end
        
    end
    
    % math operations
    methods
        function S = plus(A,B)
            %PLUS Laurent matrix addition.
            %   S = PLUS(A,B) returns the Laurent matrix that is the sum of
            %   the two Laurent matrices A and B.
            
            if isnumeric(A) && length(A)==1
                A = laurentMatrix('Elements',{A});
            elseif  isnumeric(B) && length(B)==1
                B = laurentMatrix('Elements',{B});
            end
            
            MA = A.Elements;
            MB = B.Elements;
            [rA,cA] = size(MA);
            [rB,cB] = size(MB);
            
            if (rA~=rB) || (cA~=cB)
                coder.internal.error('Wavelet:Lifting:InvalidMatDim', '+');
            end
            MS = cell(rA,cA);
            for i=1:rA
                for j=1:cA
                    MS{i,j} = MA{i,j}+MB{i,j};
                end
            end
            S = laurentMatrix('Elements',MS);
        end

        function M = uminus(A)
            %UMINUS Unary minus for Laurent matrix.
            %   -A negates each element of the Laurent matrix A.
            
            MA = A.Elements;
            [rA,cA] = size(MA);
            MB = cell(rA,cA);
           
            for i=1:rA
                for j=1:cA
                    MB{i,j} = -MA{i,j};
                end
            end
            M = laurentMatrix('Elements',MB);
        end
        
        function D = minus(A,B)
            %MINUS Laurent matrix subtraction.
            %   D = MINUS(A,B) returns the Laurent matrix that is the
            %   difference of the two Laurent matrices A and B.
            
            if isnumeric(A) && length(A)==1
                A = laurentMatrix('Elements',{A});
            elseif  isnumeric(B) && length(B)==1
                B = laurentMatrix('Elements',{B});
            end
            
            Bneg = uminus(B);
            D = plus(A,Bneg);       
        end

        function objN = ctranspose(obj)
            %CTRANSPOSE Laurent matrix transpose.
            %    B = ctranspose(A) returns the Laurent matrix that is the
            %    transpose of the Laurent matrix A.
            
            E = obj.Elements;
            [r,c] = size(E);
            EN = cell(c,r);
            
            for ii = 1:c
                for jj = 1:r
                    EN{ii,jj} = E{jj,ii};
                end
            end
            
            objN = laurentMatrix('Elements',EN);
        end
      
        function P = mtimes(A,B)
            %MTIMES Laurent matrix multiplication.
            %   P = MTIMES(A,B) returns the Laurent matrix that is the
            %   product of the two Laurent matrices A and B.           
            
            coder.internal.assert(~(isnumeric(A)||isa(A,...
                'laurentPolynomial')),'Wavelet:Lifting:InvalidInputMath');
            coder.internal.assert(~(isnumeric(B)||isa(B,...
                'laurentPolynomial')),'Wavelet:Lifting:InvalidInputMath');
            
            if isnumeric(A)
                MA = {A 0;0 A};
                coder.varsize('MA',[2 2],[1 1]);
            elseif isa(A,'laurentMatrix')
                MA = A.Elements;
            else
                MA = {1};
            end
            
            if isnumeric(B)
                MB = {B 0;0 B};
                coder.varsize('MB',[2 2],[1 1]);
            elseif isa(B,'laurentMatrix')
                MB = B.Elements;
            else
                MB = {1};
            end
            
            [rA,cA] = size(MA);
            [rB,cB] = size(MB);
            
            zr = laurentPolynomial('Coefficients',0,'MaxOrder',0);

            MP = cell(rA,cB);
            coder.varsize('MP',[2 2],[1 1]);
            for i = 1:rA
                for j = 1:cB
                    MP{i,j} = zr;
                end
            end
            
            coder.internal.assert(~(cA~=rB),...
                'Wavelet:Lifting:InvalidMatDim', '*');
      
            for i = 1:rA
                for j = 1:cB
                    S = zr;
                    for k = 1:cA
                        S = S + MA{i,k}*MB{k,j};
                    end
                    MP{i,j} = S;
                end
            end
            P = laurentMatrix('Elements',MP);
        end
        
        function D = det(M)
            %DET Laurent matrix determinant.
            %   D = det(M) returns the determinant of the Laurent matrix M
            %   as a laurentPolynomial object.
            E = M.Elements;
            [r,c] = size(E);
            coder.internal.assert((r == c),...
                'Wavelet:Lifting:InvalidMatSizeDet');
            
            D = laurentPolynomial('Coefficients',1);
            switch r
                case 1
                    D = E{1};
                case 2
                    D = (E{1,1}*E{2,2})-(E{1,2}*E{2,1});
            end
        end
        
        function I = inverse(M)
            %INVERSE Inverse of Laurent matrix.
            %   Minv = inverse(M) returns the inverse of the Laurent matrix
            %   M if M has a non-zero monomial determinant.
            A = M.Elements;
            E = coder.nullcopy(A);
            DM = det(M);
            coder.internal.assert((degree(DM) == 0),...
                'Wavelet:Lifting:InvalidMatDet'); 
            D = DM.Coefficients;
            mD = DM.MaxOrder;
            invD = laurentPolynomial('Coefficients',1/D,'MaxOrder',-mD);
            E{1,1} = A{2,2}*invD;
            E{2,2} = (A{1,1}*invD);
            E{1,2} = (-A{1,2}*invD);
            E{2,1} = (-A{2,1}*invD);
            I = laurentMatrix('Elements',E);
        end
        
        function R = reflect(M)
            %REFLECT Reflection of Laurent matrix.
            %   R = reflect(M) returns a Laurent matrix R such that
            %   R(i,j) = reflect(M(i,j))
            %   where R(i,j) and M(i,j) are the (i,j) entries of the
            %   Laurent matrices R and M respectively.
            
            E = M.Elements;
            [r,c] = size(E);
            Er = coder.nullcopy(E);
            
            for ii = 1:r
                for jj = 1:c
                    Er{ii,jj} = reflect(E{ii,jj});
                end
            end
            
            R = laurentMatrix('Elements',Er);
        end
        
        function R = dyadup(M)
            %DYADUP Dyadic upsampling of a Laurent matrix.
            %   R = dyadup(M) returns a Laurent matrix R such that
            %   R(i,j) = dyadup(M(i,j))
            %   where R(i,j) and M(i,j) are the (i,j) entries of the
            %   Laurent matrices R and M respectively.
            
            E = M.Elements;
            [r,c] = size(E);
            Er = coder.nullcopy(E);
            
            for ii = 1:r
                for jj = 1:c
                    Er{ii,jj} = dyadup(E{ii,jj});
                end
            end
            
            R = laurentMatrix('Elements',Er);
        end
        
        function R = dyaddown(M)
            %DYADDOWN Dyadic downsampling of a Laurent matrix.
            %   R = dyaddown(M) returns a Laurent matrix R such that
            %   R(i,j) = dyaddown(M(i,j))
            %   where R(i,j) and M(i,j) are the (i,j) entries of the
            %   Laurent matrices R and M respectively.
            
            E = M.Elements;
            [r,c] = size(E);
            Er = coder.nullcopy(E);
            
            for ii = 1:r
                for jj = 1:c
                    Er{ii,jj} = dyaddown(E{ii,jj});
                end
            end
            
            R = laurentMatrix('Elements',Er);
        end

        function R = eq(A,B)
            %EQ Test if two Laurent matrices are equal.
            %   EQ(A,B) returns 1 if the two Laurent matrices A and B are
            %   equal and 0 otherwise.
            
            if isnumeric(A) && length(A)==1
                A = laurentMatrix('Elements',{A});
            elseif  isnumeric(B) && length(B)==1
                B = laurentMatrix('Elements',{B});
            end
            
            MA = A.Elements;
            MB = B.Elements;
            [rA,cA] = size(MA);
            [rB,cB] = size(MB);
            
            if (rA~=rB) || (cA~=cB)
                coder.internal.error('Wavelet:Lifting:InvalidMatDim', '==');
            end
            
            R = true;
            for i = 1:size(A.Elements,1)
                for j = 1:size(A.Elements,2)
                    R = R & (MA{i,j} == MB{i,j});
                end
            end
        end
        
         function dispMat(obj)
            % DISPMAT Laurent matrix display.
            %   DISPMAT(M) displays the Laurent matrix M.
            Mat = obj.Elements;
            [r,c] = size(Mat);
            
            switch c
                case 1                    
                    switch r
                        case 1
                            M11 = dispPoly(Mat{1,1});
                            sP = strjoin(M11,'\0');
                            formatSpec = "\t|%s |\n";
                            fprintf(formatSpec,sP);
                            
                        case 2
                            M11 = dispPoly(Mat{1,1});
                            M21 = dispPoly(Mat{2,1});
                            
                            srow1 = strjoin(M11,'\0');
                            srow2 = strjoin(M21,'\0');
                            n1 = length(srow1);
                            n2 = length(srow2);
                            if (n1 == n2)
                                fprintf("%s %s %s\n","|",srow1,"|");
                                sp = cell(1,n1-1);
                                sp{1} = '|';
                                sp{n1-2} = ' |';
                                sp{n1-1} = '\n';
                                for ii = 2:n1-3
                                    sp{ii} = ' ';
                                end
                                fprintf(strjoin(sp,'\0'));
                                fprintf("%s %s %s\n","|",srow2,"|");
                            elseif (n1 > n2)
                                nsp = n1-n2;                               
                                fprintf("%s %s %s\n","|",srow1,"|");

                                % printing the gap between the rows
                                sp = cell(1,nsp-3);
                                sp{1} = '|';
                                sp{nsp-4} = '|';
                                sp{nsp-3} = '\n';
                                for ii = 2:nsp-5
                                    sp{ii} = ' ';
                                end
                                fprintf(strjoin(sp,'\0'));

                                % print the second line
                                sp = cell(1,nsp);
                                sp{nsp} = ' |';
                                for ii = 1:nsp-1
                                    sp{ii} = '';
                                end
                                fprintf("| %s %s\n",srow2,...
                                    strjoin(sp,'\0'));
                            else
                                nsp = n2-n1;
                                sp = cell(1,nsp);
                                sp{nsp} = ' |';

                                for ii = 1:nsp-1
                                    sp{ii} = '';
                                end
                                
                                fprintf("%s %s %s\n",'|',srow1,...
                                    strjoin(sp,'\0'));

                                % printing the gap between the rows
                                sp = cell(1,nsp-3);
                                sp{1} = '|';
                                sp{nsp-4} = '|';
                                sp{nsp-3} = '\n';
                                for ii = 2:nsp-5
                                    sp{ii} = ' ';
                                end
                                fprintf(strjoin(sp,'\0'));

                                % print the second line
                                fprintf("%s %s %s\n","|",srow2,"|");
                            end
                    end
                   
                case 2
                    switch r
                        case 1
                            M11 = dispPoly(Mat{1,1});
                            M12 = dispPoly(Mat{1,2});
                            col1 = strjoin(M11,'\0');
                            col2 = strjoin(M12,'\0');
                            formatSpec = "%s %s\t%s %s\n";
                            fprintf(formatSpec,"|",col1,col2,"|");

                        case 2
                            M11 = dispPoly(Mat{1,1});
                            M12 = dispPoly(Mat{1,2});
                            M21 = dispPoly(Mat{2,1});
                            M22 = dispPoly(Mat{2,2});
                            
                            row1 = M11;
                            row1{end+1} = ' ';
                            for ii = 1:length(M12)
                                row1{end+1} = M12{ii};
                            end
                            
                            srow1 = strjoin(row1,'\0');
                            
                            row2 = M21;
                            row2{end+1} = ' ';
                            for ii = 1:length(M22)
                                row2{end+1} = M22{ii};
                            end
                            
                            srow2 = strjoin(row2,'\0');
                            n1 = length(srow1);
                            n2 = length(srow2);
                            if (n1 == n2)
                                fprintf("%s %s %s\n","|",srow1,"|");
                                % print gap between lines
                                sp = cell(1,n1+2);
                                sp{1} = '| ';
                                sp{n1+1} = ' |';
                                sp{n1+2} = '\n';
                                for ii = 2:n1
                                    sp{ii} = '';
                                end
                                fprintf(strjoin(sp,'\0'));
                               
                                fprintf("%s %s %s\n","|",srow2,"|");
                            elseif (n1 > n2)
                                nsp = n1-n2;
                                sp = cell(1,nsp);
                                for ii = 1:nsp
                                    sp{ii} = '';
                                end
                                
                                spc = strjoin(sp,'\0');
                                
                                newrow2 = M21;
                                newrow2{end+1} = ' ';
                                newrow2{end+1} = spc;
                                for ii = 1:length(M22)
                                    newrow2{end+1} = M22{ii};
                                end
                                
                                fprintf("%s %s %s\n","|",srow1,"|");
                                % print gap between lines
                                sp = cell(1,n1+2);
                                sp{1} = '| ';
                                sp{n1+1} = ' |';
                                sp{n1+2} = '\n';
                                for ii = 2:n1
                                    sp{ii} = '';
                                end
                                fprintf(strjoin(sp,'\0'));
                                fprintf("%s %s %s\n","|",strjoin(newrow2,'\0'),...
                                    "|");
                            else
                                nsp = n2-n1;
                                sp = cell(1,nsp);
                                for ii = 1:nsp
                                    sp{ii} = '';
                                end
                                
                                spc = strjoin(sp,'\0');
                                
                                newrow1 = M11;
                                newrow1{end+1} = ' ';
                                newrow1{end+1} = spc;
                                for ii = 1:length(M12)
                                    newrow1{end+1} = M12{ii};
                                end
                                
                                fprintf("%s %s %s\n","|",strjoin(newrow1,'\0'),...
                                    "|");
                                % print gap between lines
                                sp = cell(1,n1+4);
                                sp{1} = '|';
                                sp{n1+3} = ' |';
                                sp{n1+4} = '\n';
                                for ii = 2:n1+2
                                    sp{ii} = ' ';
                                end
                                fprintf(strjoin(sp,'\0'));
                                fprintf("%s %s %s\n","|",srow2,"|");
                            end
                    end
            end            
        end
    end
      
    methods (Access = private)
        function [obj,E2] = parseInputs(obj,varargin)
            
            % parser for the name value-pairs
            parms = {'Elements'};
            
            % Select parsing options.
            poptions = struct('PartialMatching','unique');
            pstruct = coder.internal.parseParameterInputs(parms,...
                poptions,varargin{:});
            E = coder.internal.getParameterValue(pstruct.Elements,[], ...
                varargin{:});
            validateattributes(E,{'cell'},{'nonempty'});
            [r,c] = size(E);
            
            coder.internal.assert(((r <= 2) && (c <= 2)),...
                'Wavelet:Lifting:UnsupportedRowColSize');
            
            E2 = cell(r,c);
            for ii = 1:r
                for jj = 1:c                 
                    coder.internal.assert((isa(E{ii,jj},...
                        'laurentPolynomial')|| isnumeric(E{ii,jj})),...
                        'Wavelet:Lifting:InvalidLMInput');
                    if isnumeric(E{ii,jj})
                        E2{ii,jj} = laurentPolynomial('Coefficients',...
                            double(E{ii,jj}));
                    else
                        E2{ii,jj} = E{ii,jj};
                    end
                end
            end
            
        end
    end
end

function dispSTR = dispPoly(P)
narginchk(1,1)

d = P.MaxOrder;
c = P.Coefficients;
nbCoefs = length(c);
n = (0:-1:-(nbCoefs-1))+d;
dispSTR = cell(1,0);
coder.varsize('dispSTR');

for k = 1:nbCoefs
    v = c(k);
    if (k == 1)
        if (n(k) == 0)
            if (v == 0)
                dispSTR = {sprintf('%1.2e',abs(v))};
            else
                dispSTR = {sprintf('%1.2e',v)};
            end
            
        else
            if (v == 1)
                S = {'z^(',sprintf('%d',int8(n(k))),')'};
            else
                S = {sprintf('%1.2e',v),'*z^(',sprintf('%d',int8(n(k))),')'};
            end
            dispSTR = S;
        end
    else
        if (n(k) == 0)
            switch sign(v)
                case 0
                    continue;
                case 1
                    S = {'+',sprintf('%1.2e',v)};
                case -1
                    S = {sprintf('%1.2e',v)};
            end

        else
            switch sign(v)
                case 0
                    S = cell(1,0);
                case 1
                    if (v == 1)
                        S = {'+','z^(',sprintf('%d',int8(n(k))),')'};
                    else
                        S = {'+',sprintf('%1.2e',v),'*z^(',sprintf('%d',int8(n(k))),')'};
                    end
                    
                case -1
                    if (v == -1)
                        S = {'-z^(',sprintf('%d',int8(n(k))),')'};
                    else
                        S = {sprintf('%1.2e',v),'*z^(',...
                            sprintf('%d',int8(n(k))),')'};
                    end
            end
        end
        
        for ii = 1:numel(S)
            dispSTR{end+1} = S{ii};
        end
    end
end
end
