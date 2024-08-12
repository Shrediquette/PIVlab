function LSstr = displs(varargin)
%DISPLS Display lifting scheme.
%   S = DISPLS(LS,FRM) returns a string describing 
%   the lifting scheme LS. The format string "FRM" 
%   (see SPRINTF) is used to build S. 
%  
%   DISPLS(LS) is equivalent to DISPLS(LS,'%12.8f')
%
%   For more information about lifting schemes type: lsinfo.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2001.
%   Copyright 1995-2020 The MathWorks, Inc.

narginchk(1,2);
[varargin{:}] = wavelet.internal.wconvertStringsToChars(varargin{:});

format = '%12.8f';
LS = varargin{1};
if nargin == 2
    format = varargin{2};
end

N = size(LS,1);
C1str = '';
for k = 1:N-1
    C1str = [C1str;'''',LS{k,1},''''];
end
C1str = strvcat(C1str,['[', sprintf(format,LS{N,1}),']  ']);

C2str = '';
for k = 1:N
    C2str = strvcat(C2str,['[', sprintf(format,LS{k,2}),']  ']);
end

C3str = '';
for k = 1:N
    C3str = strvcat(C3str,['[', int2str(LS{k,3}),']  ']);
end

LSstr = [C1str,C2str,C3str];
varName = inputname(1);
LSstr = strvcat([varName , ' = {...'], LSstr,'};');
if nargout<1 , disp(LSstr); end
