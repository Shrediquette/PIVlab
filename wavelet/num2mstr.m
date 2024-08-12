function s = num2mstr(n)
%NUM2MSTR Convert number to string in maximum precision.
%   S = NUM2MSTR(N) converts real numbers of input 
%   matrix N to string output vector S, in 
%   maximum precision.
%
%   See also NUM2STR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

if ischar(n) , s = n; return; end
[r,c] = size(n);
if isnumeric(n)
    if max(r,c)==1
        s = sprintf('%25.18g',n);
        
    elseif r>1
        s = [];
        for k=1:r
            s = [s sprintf('%25.18g',n(k,:)) ';'];
        end
        s = ['[' s ']'];
        
    elseif c>1
        s = sprintf('%25.18g',n);
        s = ['[' s ']'];
        
    else
        s = '';
    end
else
    if max(r,c)==1
        s = handle2str(n);
        
    elseif r>1
        s = [];
        for k=1:r
            s = [s handle2str(n(k,:)) ';'];
        end
        s = ['[' s ']'];
        
    elseif c>1
        s = handle2str(n);
        s = ['[' s ']'];
        
    else
        s = '';
    end
end
