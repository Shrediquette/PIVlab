function varargout = wwarndlg(WarnString,DlgName,bloc)
%WWARNDLG Display warning dialog box (and block execution).
%   HANDLE = WWARNDLG(WARNSTRING,DLGNAME) creates an warning dialog box
%   which displays WARNSTRING in a window named DLGNAME.  A pushbutton
%   labeled OK must be pressed to make the warning box disappear.
%
%   WWARNDLG(WARNSTRING,DLGNAME,arg) block execution.
% 
%   WARNSTRING may be any valid string format.  Cell arrays are
%   preferred.
% 
%   See also MSGBOX, HELPDLG, QUESTDLG, ERRORDLG.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

if nargin==2
    h = warndlg(WarnString,DlgName);
else
    h = msgbox(WarnString,DlgName,'warn','modal');
end
if nargout==1
    if nargin<3 , varargout(1) = {h}; else , varargout(1) = {[]}; end
end
