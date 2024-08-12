function wsaveprocess(caller,fig,varargin)
%WSAVEPROCESS Generate Matlab code.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Nov-2010.
%   Last Revision: 16-Mar-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

% Check inputs
if nargin<2 , fig = gcbf; end

% Get the generated code
mcode_str = wgeneratematlabcode(caller,fig,varargin{:});

% Display the generated code
wdisplaymatlabcode(mcode_str,'editor')
