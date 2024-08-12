function s = getonoff(x)
%GETONOFF Returns a matrix of strings with 'off' or 'on '.
%   S = GETONOFF(X)
%   X is a vector : 
%       X(i) = 0 ==> S(i) = 'off' else S(i) = 'on '     

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.10.4.2 $


r = length(x);
s = cell(1,r);
for k = 1:r
    if x(k)==0 , s{k} = 'off'; else s{k} = 'on'; end
end
if r==1 , s = s{1}; end
