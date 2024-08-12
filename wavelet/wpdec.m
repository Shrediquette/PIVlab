function t = wpdec(x,depth,wname,type_ent,parameter)
%WPDEC Wavelet packet decomposition 1-D.
%   T = WPDEC(X,N,'wname',E,P) returns a wptree object T
%   corresponding to a wavelet packet decomposition
%   of the vector X, at level N, with a
%   particular wavelet ('wname', see WFILTERS).
%   E is a character vector containing the type of entropy (see WENTROPY):
%   E = 'shannon', 'threshold', 'norm', 'log energy', 'sure', 'user'
%   P is an optional parameter:
%        'shannon' or 'log energy' : P is not used
%        'threshold' or 'sure'     : P is the threshold (0 <= P)
%        'norm' : P is a power (1 <= P)
%        'user' : P is a character vector containing the name
%                 of an user-defined function.
%
%   T = WPDEC(X,N,'wname') is equivalent to
%   T = WPDEC(X,N,'wname','shannon').
%
%   See also WAVEINFO, WENTROPY, WPDEC2, WPREC, WPREC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.

nbIn = nargin;
if nbIn < 3   
    error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));
elseif nbIn==3
    parameter = 0.0;
    type_ent = 'shannon';
elseif nbIn==4
    parameter = 0.0;
end

[wname,type_ent,parameter] = convertStringsToChars(wname,type_ent,parameter);

if strcmpi(type_ent,'user') && ~ischar(parameter)
    error(message('Wavelet:FunctionArgVal:Invalid_EntNam'));
end

% Tree Computation (order = 2).
t = wptree(2,depth,x,wname,type_ent,parameter);
