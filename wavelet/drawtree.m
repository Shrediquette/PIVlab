function fig = drawtree(t,varargin)
%DRAWTREE Draw wavelet packet decomposition tree.
%   DRAWTREE(T) draws the wavelet packet tree T.
%   F = DRAWTREE(T) returns the figure's handle.
%
%   For an existing figure F produced by a previous call
%   to the DRAWTREE function, DRAWTREE(T,F) draws the wavelet 
%   packet tree T in the figure whose handle is F.
%
%   Example:
%     x   = sin(8*pi*(0:0.005:1));
%     t   = wpdec(x,3,'db2');
%     fig = drawtree(t);
%     %---------------------------------------
%     % Use command line function to modify t
%     %---------------------------------------
%     t   = wpjoin(t,2);
%     drawtree(t,fig);
%
%   See also READTREE.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 04-Jan-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check arguments.
%-----------------
nbIn = nargin;
switch nbIn
    case 0
        error(message('Wavelet:FunctionInput:NotEnough_ArgNum'));

    case {1,2}
        maxarg = 2;

    otherwise
        error(message('Wavelet:FunctionInput:TooMany_ArgNum'));
end

% Draw tree.
%-----------
order = treeord(t);
switch order
    case 2 , prefix = 'wp1d';
    case 4 , prefix = 'wp2d';
end
func1 = [prefix 'tool'];
func2 = [prefix 'mngr'];

newfig = 1;
if nargin==maxarg
    fig = varargin{end};
    varargin(end) = [];
    % If the handle is valid and is a tree UI, then use it. Otherwise open
    % a new figure.
    if ishandle(fig)
        tagfig = lower(get(fig,'Tag'));
        if isequal(func1,tagfig)
            newfig = 0;
        end
    end
end
if newfig
    fig = feval(func1);
end
feval(func2,'load_dec',fig,t,varargin{:});
