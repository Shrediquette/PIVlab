function [c,l] = wavedec(x,n,IN3,IN4)
%WAVEDEC Multi-level 1-D wavelet decomposition.
%   WAVEDEC performs a multilevel 1-D wavelet analysis
%   using either a specific wavelet 'wname' or a specific set 
%   of wavelet decomposition filters (see WFILTERS).
%
%   [C,L] = WAVEDEC(X,N,'wname') returns the wavelet decomposition of the 
%   signal X at level N, using 'wname'. WAVEDEC does not enforce a maximum
%   level restriction. Use WMAXLEV to ensure the wavelet coefficients are 
%   free from boundary effects. If boundary effects are not a concern in 
%   your application, a good rule is to set N less than or equal to 
%   fix(log2(length(X))).
%   
%   The output vector, C, contains the wavelet decomposition. L contains
%   the number of coefficients by level.
%   C and L are organized as:
%   C      = [app. coef.(N)|det. coef.(N)|... |det. coef.(1)]
%   L(1)   = length of app. coef.(N)
%   L(i)   = length of det. coef.(N-i+2) for i = 2,...,N+1
%   L(N+2) = length(X).
%
%   [C,L] = WAVEDEC(X,N,Lo_D,Hi_D) Lo_D is the decomposition low-pass 
%   filter and Hi_D is the decomposition high-pass filter.
%
%
%   See also DWT, WAVEINFO, WAVEREC, WFILTERS, WMAXLEV.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2020 The MathWorks, Inc.

filterSingle = false;
% Convert wname from string to char
if isStringScalar(IN3)
    IN3 = convertStringsToChars(IN3);
end

narginchk(3,4);
validateattributes(x,{'numeric'},{'vector','finite'},'wavedec','X');
validateattributes(n,{'numeric'},{'scalar','integer','positive'},'wavedec','N');

if nargin==3
    [Lo_D,Hi_D] = wfilters(IN3,'d');
else
    Lo_D = IN3;  
    Hi_D = IN4;
    filterSingle = isUnderlyingType(Lo_D,'single') && ...
        isUnderlyingType(Hi_D,'single');
end

% Initialization.
s = size(x);
x = x(:).'; % row vector
c = [];
l = zeros(1,n+2,'like',real(x([])));
% code generation is on a separate path so this is ok.
isSingle = isUnderlyingType(x,'single');
if isSingle && ~filterSingle
    Lo_D = cast(Lo_D,'single');
    Hi_D = cast(Hi_D,'single');
end

if isempty(x) 
    return;
end

l(end) = length(x);
for k = 1:n
    [x,d] = dwt(x,Lo_D,Hi_D); % decomposition
    c     = [d c];            %#ok<AGROW> % store detail
    l(n+2-k) = length(d);     % store length
end

% Last approximation.
c = [x c];
l(1) = length(x);

if s(1)>1
    c = c.'; 
    l = l';
end


