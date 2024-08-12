function X = mwptrec(dec)
%MWPTDEC Multisignal wavelet packet 1-D reconstruction is a function for
%   parsing value-only inputs, flags, and name-value pairs for the vmd
%   function. This function is for internal use only. It may be removed in
%   the future.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Feb-2011
%   Last Revision: 28-Aug-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

%#codegen

% Check arguments.
narginchk(1,1)
nargoutchk(1,1);

% Initialization.
dirDec = dec.dirDec;
LoR = dec.dwtFilters.LoR;
HiR = dec.dwtFilters.HiR;
dwtEXTM = dec.dwtEXTM;
perFLAG = strcmp(dwtEXTM,'per');

nbC = length(dec.cfs);
coder.varsize('z');
z = dec.cfs;

s = double(dec.sx);
lev = 1;
coder.varsize('z{:}')
while nbC>1
    for j = 1:nbC/2
        if ~signalwavelet.internal.isodd(j)&&(nbC~=2)
            a = z{j+1};
            d = z{j};
        else
            a = z{j};
            d = z{j+1};
        end
        a = upsconv(a,LoR,s(end-lev),perFLAG) + upsconv(d,HiR,s(end-lev),perFLAG);
        z{j+1} = a;
        z(j) = [];
    end
    lev = lev+1;
    nbC = length(z);
end

if isequal(dirDec,'c') 
    X = z{1}.';
else
    X = z{1};
end

end

%-------------------------------------------------------------------------%
function y = upsconv(x,f,lenKept,perFLAG)
%UPSCONV Upsample and convolution.
[sx1,sx2] = size(x);
if ~perFLAG
    y = zeros(sx1,sx2*2-1);
    y(1:sx1,1:2:end) = x;
    y = conv2(y,f,'full');
    sy = size(y,2);
    if lenKept>sy
        lenKept = sy;
    end
    d = (sy-lenKept)/2;
    first = 1+floor(d);
    last = sy-ceil(d);
    y = y(1:sx1,first:last);
else
    lf = length(f);
    y = zeros(sx1,sx2*2);
    y(1:sx1,1:2:end) = x;
    y = wextend('addcol','per',y,ceil(lf/2));
    y = conv2(y,f,'full');         
    y = y(1:sx1,lf:lf+sx2*2-1);
    y = y(1:sx1,1:lenKept);
end

end

