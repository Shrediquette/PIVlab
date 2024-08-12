function c = wthcoef2(o,c,s,niv,thr,sorh)
%WTHCOEF2 Wavelet coefficient thresholding 2-D.
%   For 'type' = 'h' ('v' or 'd'), 
%   NC = WTHCOEF2('type',C,S,N,T,SORH) returns the horizontal
%   (vert. or diag., respectively) coefficients obtained from
%   the wavelet decomposition structure [C,S] (see WAVEDEC2),
%   by soft (if SORH = 's') or hard (if SORH = 'h') thresholding 
%   defined in vectors N and T. N contains the detail levels 
%   to be compressed and T the corresponding thresholds.
%   N and T must be of the same length.
%   The vector N must be such that 1 <= N(i) <= size(S,1)-2.
%
%   For 'type' = 'h' ('v' or 'd' respectively),
%   NC = WTHCOEF2('type',C,S,N) returns the horizontal (vert. 
%   or diag., respectively) coefficients obtained from [C,S] by
%   setting all the coefficients of detail levels defined in N
%   to zero.
%
%   NC = WTHCOEF2('a',C,S) returns the coefficients obtained by
%   setting approximation coefficients to zero.
%
%   NC = WTHCOEF2('t',C,S,N,T,SORH) returns the detail
%   coefficients obtained from the wavelet decomposition
%   structure [C,S] by soft (if SORH = 's') or hard
%   (if SORH = 'h') thresholding (see WTHRESH) defined in
%   vectors N and T.
%   N contains the detail levels to be thresholded and T the
%   corresponding thresholds which are applied in the three
%   detail orientations.
%   N and T must be of the same length.
%
%   [NC,S] is the modified wavelet decomposition structure.
%
%   See also WAVEDEC2, WTHRESH.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if isStringScalar(o)
    o = convertStringsToChars(o);
end

if nargin > 5 && isStringScalar(sorh)
    sorh = convertStringsToChars(sorh);
end

nbIn = nargin;
if nbIn < 3 
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
elseif nbIn==5
    error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
end
o = lower(o(1));
switch o
    case 'a'
        if nbIn>3
            error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
        end
        ll = prod(s(1,:));
        c(1:ll) = 0;      
        return;
        
    case {'h','v','d','t'}
    
    otherwise 
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
nmax = size(s,1)-2;
if find((niv < 1) | (niv > nmax) | (niv ~= fix(niv)))
    error(message('Wavelet:FunctionArgVal:Invalid_LevVal'))
end
if nbIn==6
    if (length(niv) ~= length(thr)) || ~isempty(find(thr<0,1))
        error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
    end
end

% Compression.
for k = 1:length(niv)
    n     = niv(k);
    kn    = size(s,1)-n;
    first = s(1,1)*s(1,2)+3*sum(s(2:kn-1,1).*s(2:kn-1,2))+1;
    add   = s(kn,1)*s(kn,2);
    if     o=='v', first = first+add;
    elseif o=='d', first = first+2*add;
    end             
    if o=='t', last = first + 3*add-1;
    else last = first+add-1; end
    if nbIn==6
        thres = thr(k);
        cfs   = c(first:last);
        cfs   = wthresh(cfs,sorh,thres);
        c(first:last) = cfs;
    else
        c(first:last) = 0;
    end
end
