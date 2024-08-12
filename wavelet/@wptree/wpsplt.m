function [wpt,varargout] = wpsplt(wpt,node)
%WPSPLT Split (decompose) wavelet packet.
%   WPSPLT updates a wavelet packet tree after
%   the decomposition of a node.
%
%   T = WPSPLT(T,N) returns the modified tree T
%   corresponding to the decomposition of the node N.
%
%   For a 1-D decomposition: [T,CA,CD] = WPSPLT(T,N)
%   with CA = approximation and CD = detail of node N.
%
%   For a 2-D decomposition: [T,CA,CH,CV,CD] = WPSPLT(T,N)
%   with CA = approximation and CH, CV, CD = (Horiz., Vert. and
%   Diag.) details of node N.
%
%   See also WAVEDEC, WAVEDEC2, WPDEC, WPDEC2, WPJOIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2020 The MathWorks, Inc.

[wpt,child,varargout] = nodesplt(wpt,node);
if isempty(child)
    error(message('Wavelet:FunctionArgVal:Invalid_NodVal'));
end
