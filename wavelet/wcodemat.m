function y = wcodemat(x,nb,opt,absol)
%WCODEMAT Extended pseudocolor matrix scaling.
%   Y = WCODEMAT(X,NBCODES,OPT,ABSOL) returns a coded version
%   of input matrix X if ABSOL=0, or ABS(X) if ABSOL is 
%   nonzero, using the first NBCODES integers.
%   Coding can be done row-wise (OPT='row' or 'r'), columnwise 
%   (OPT='col' or 'c'), or globally (OPT='mat' or 'm'). 
%   Coding uses a regular grid between the minimum and 
%   the maximum values of each row (column or matrix,
%   respectively).
%
%   Y = WCODEMAT(X,NBCODES,OPT) is equivalent to
%   Y = WCODEMAT(X,NBCODES,OPT,1).
%   Y = WCODEMAT(X,NBCODES) is equivalent to
%   Y = WCODEMAT(X,NBCODES,'mat',1).
%   Y = WCODEMAT(X) is equivalent to
%   Y = WCODEMAT(X,16,'mat',1).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
switch nargin
    case 1 , absol = 1; opt = 'm'; nb = 16;
    case 2 , absol = 1; opt = 'm';
    case 3 , absol = 1;
end
% Handle string input
if isStringScalar(opt)
    opt = convertStringsToChars(opt);
end
opt = lower(opt(1));

trans = false;
if isequal(opt(1),'r')
    trans = true;
    opt   = 'c';
    x     = x';
end
if absol , x = abs(x); end
switch opt
    case 'm'
        y = ones(size(x));
        x = x - min(x(:));
        maxx  = max(x(:));
        if maxx<eps , return; end
        x = nb*(x/maxx);
        y(:) = 1 + fix(x);

    case 'c'
        t1 = size(x,1);
        minx  = min(x); 
        x = (x - minx(ones(1,t1),:));
        maxx  = max(x);
        echel = maxx(ones(1,t1),:);
        indexs = echel<eps;
        x = nb*(x./echel);
        y = 1 + fix(x);
        y(indexs) = 1;

    otherwise
        error(message('Wavelet:FunctionArgVal:Unknown_Opt'));
end
y(y>nb) = nb;
if trans, y = y'; end

