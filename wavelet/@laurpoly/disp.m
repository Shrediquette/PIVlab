function varargout = disp(P,varName)
%DISP Display a Laurent polynomial object as text.
%   DISP(P) displays the Laurent polynomial P printing 
%   the polynomial name (here: P). 
%   DISP(P,VarName) uses "VarName" as polynomial name.
%
%   Example:
%      P = laurpoly(1:3,0);
%      disp(P)
%      disp(P,'Poly')

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision 08-Jul-2003.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin > 1 && isStringScalar(varName)
    varName = convertStringsToChars(varName);
end

if nargin<2 , varName = inputname(1); end

flagHeadSep = false;
headerSTR = [...
	' Laurent polynomial object '
    '==========================='
	];
dispSTR = lpstr(P,60);
nbLines = size(dispSTR,1);
if nbLines==1
    dispSTR = [varName '(z) = ' deblank(dispSTR)];
else
    varNameSTR = [varName '(z) = ...'];
    blanks  = repmat(' ',nbLines,4);
    dispSTR = [blanks dispSTR];
    dispSTR = strvcat(varNameSTR,dispSTR);
end
sepSTR  = repmat('-',1,size(dispSTR,2)+1);
 
% Displaying.
%------------
if nargout==0
    disp(' '); 
    if flagHeadSep , disp(headerSTR); end
    disp(dispSTR);
    if flagHeadSep , disp(sepSTR); disp(' '); end
else
    varargout{1} = dispSTR;
end
