function M = subsasgn(A,index,InputVAL)
%SUBSASGN Subscripted assignment for Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Apr-2001.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

switch index.type
    case '()'   % InputVAL is a laurmat object or a number
        MA = A.Matrix;
        if isnumeric(InputVAL)
            if length(InputVAL)==1
                nbR = length(index.subs{1});
                nbC = length(index.subs{2});
                InputVAL = InputVAL*ones(nbR,nbC);
            end
            InputVAL = laurmat(InputVAL);
        end
        if isa(InputVAL,'laurmat')
            MA(index.subs{:}) = InputVAL.Matrix;
        else
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
        end
        M = laurmat(MA);
        
    case '{}'   % InputVAL is a laurpoly object or a number
        MA = A.Matrix;
        if isa(InputVAL,'laurpoly')
            MA{index.subs{:}} = InputVAL;
        elseif isnumeric(InputVAL) && length(InputVAL)==1
            MA{index.subs{:}} = laurpoly(InputVAL,0);
        else
            error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
        end
        M = laurmat(MA);
        
    case '.'    % InputVAL is a cell array of laurpoly objects or of numbers.
        if isequal(index.subs,'Matrix')
            M = laurmat(InputVAL);
        else
            error(message('Wavelet:FunctionArgVal:Invalid_FieldNam'))
        end
end
