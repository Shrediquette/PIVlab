function hh = wtitle(string,varargin)
%WTITLE  Graph title.
%   WTITLE('text') adds text at the top of the current axis.
%
%   WTITLE('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the title.
%
%   H = WTITLE(...) returns the handle to the text object
%   used as the title.
%
%   See also WXLABEL, WYLABEL, XLABEL, YLABEL, ZLABEL, TITLE, TEXT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 25-Jan-2012.
%   Copyright 1995-2020 The MathWorks, Inc.

nbin = nargin;
if nbin>1
    for k=1:2:nbin-1
        p = deblank(lower(varargin{k}));
        if isequal(p,'parent')
            ax = varargin{k+1};
            varargin(k:k+1) = [];
            break
        end
    end
end

if isempty(ax) , ax = gca; end
h = get(ax,'title');

narg = (nargin-1)/2;
if nargin > 1 && (narg-fix(narg)~=0)
  error(message('Wavelet:FunctionInput:Invalid_ArgNum'));
end

%Over-ride text objects default font attributes with
%the Axes' default font attributes.
set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
       'FontName',   get(ax, 'FontName'), ...
       'FontSize',   get(ax, 'FontSize'), ...
       'FontWeight', get(ax, 'FontWeight'), ...
       'Rotation',   0, ...
       'String',     string, varargin{:});

if nargout > 0
  hh = h;
end
