function P = laurpoly(coefs,varargin)
%LAURPOLY Constructor for the class LAURPOLY (Laurent Polynomial).
%   P = LAURPOLY(C,d) returns a Laurent polynomial object.
%   C is a vector whose elements are the coefficients
%   of the polynomial P and d is the highest degree of 
%   the monomials of P.
%
%   If m is the length of the vector C, P represents 
%   the following Laurent polynomial:
%     P(z) = C(1)*z^d + C(2)*z^(d-1) + ... + C(m)*z^(d-m+1)
%
%   P = LAURPOLY(C,'dmin',d) allows to specify the lowest degree   
%   instead of the highest degree of monomials of P. The
%   corresponding output P represents the following Laurent
%   polynomial:
%     P(z) = C(1)*z^(d+m-1) + ... + C(m-1)*z^(d+1) + C(m)*z^d
%
%   P = LAURPOLY(C,'dmax',d) is equivalent to P = LAURPOLY(C,d).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2020 The MathWorks, Inc.

%===============================================
% Class LAURPOLY (Parent objects: )
% Fields:
%   maxDEG - maximal degree of monomials
%   coefs  - Row Vector of coefficients 
%===============================================

% Check arguments.
%-----------------
if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

nbIn = nargin;
if nbIn > 3
  error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end

switch nargin
	case 0 , maxDEG = 0; coefs = 1;
	case 1 , maxDEG = 0;
    case 2 , maxDEG = varargin{1};
    case 3 
        degATTR = lower(varargin{1});
        switch degATTR
            case {'dmax','maxdeg'} , maxDEG = varargin{2};
            case 'dmin' , maxDEG = varargin{2}+length(coefs)-1;
            otherwise
                error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
        end
end

% Built object.
%--------------
[coefs,maxDEG] = reduce(coefs(:)',maxDEG);
P = struct('maxDEG',maxDEG,'coefs',coefs);
P = class(P,'laurpoly');
