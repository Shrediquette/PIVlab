function t = wpdec2(x,depth,wname,type_ent,parameter)
%WPDEC2 Wavelet packet decomposition 2-D.
%   T = WPDEC2(X,N,'wname',E,P) returns a wptree object T
%   corresponding to a wavelet packet decomposition
%   of the matrix X, at level N, with a
%   particular wavelet ('wname', see WFILTERS).
%   E is a character vector containing the type of entropy (see WENTROPY):
%   E = 'shannon', 'threshold', 'norm', 'log energy', 'sure, 'user'
%   P is an optional parameter:
%        'shannon' or 'log energy' : P is not used
%        'threshold' or 'sure'     : P is the threshold (0 <= P)
%        'norm' : P is a power (1 <= P)
%        'user' : P is a character vector containing the name
%                 of an user-defined function.
%
%   T = WPDEC2(X,N,'wname') is equivalent to
%   T = WPDEC2(X,N,'wname','shannon').
%
%   NOTE: When X represents an indexed image, then X is an 
%   m-by-n matrix. When X represents a truecolor image, it becomes 
%   an m-by-n-by-3 array which consists of three m-by-n matrices
%  (representing the red, green, and blue color planes) concatenated 
%   along the third dimension.
%   For more information on image formats, see the reference pages 
%   of IMAGE and IMFINFO functions.
%
%   See also WAVEINFO, WENTROPY, WPDEC, WPREC, WPREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
if nargin > 2
    wname = convertStringsToChars(wname);
end

if nargin > 3
    type_ent = convertStringsToChars(type_ent);
end

nbIn = nargin;
if nbIn < 3   
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
elseif nbIn==3 , parameter = 0.0; type_ent = 'shannon';
elseif nbIn==4 , parameter = 0.0;
end
if strcmpi(type_ent,'user') && ~ischar(parameter)
    error(message('Wavelet:FunctionArgVal:Invalid_EntNam'));
end

% Tree Computation (order = 4).
t = wptree(4,depth,x,wname,type_ent,parameter);

