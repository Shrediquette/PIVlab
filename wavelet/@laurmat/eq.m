function R = eq(A,B)
%EQ Laurent matrices equality test.
%   EQ(A,B) returns 1 if the two Laurent matrices A and B
%   are equal and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if      isnumeric(A) && length(A)==1 , A = laurmat(A);
elseif  isnumeric(B) && length(B)==1 , B = laurmat(B);
end

R = isequal(A.Matrix,B.Matrix);
if ~R && isequal(size(A.Matrix),size(B.Matrix))
	R = true;
	for i = 1:size(A.Matrix,1)
		for j = 1:size(A.Matrix,2)
			R = R & (A.Matrix{i,j}==B.Matrix{i,j});
			if ~R , break; end
		end
		if ~R , break; end
	end
end
