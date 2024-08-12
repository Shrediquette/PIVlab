function OUT = waveletfamilies(ARG)
%WAVELETFAMILIES Wavelet families and family members.
%   WAVELETFAMILIES or WAVELETFAMILIES('f') displays the 
%   names of all available wavelet families.
%
%   WAVELETFAMILIES('n') displays the names of all available
%   wavelets in each family.
%
%   WAVELETFAMILIES('a') displays all available wavelet 
%   families with their corresponding properties.
%
%   See also WAVEMNGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Aug-2007.
%   Last Revision: 08-Feb-2008.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 0
    ARG = convertStringsToChars(ARG);
end

if nargin<1 , ARG = 'fam'; end
switch lower(ARG(1))
    case 'f' , S = wavemngr('read');
    case 'n' , S = wavemngr('read','all');
    case 'a'  
        S = wavemngr('read_asc');
        S(abs(S)==13) = [];
end
disp(S); disp(' ');
if nargout>0 , OUT = S; end
