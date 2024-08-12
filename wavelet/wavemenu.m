function varargout = wavemenu(varargin)
% WAVEMENU Start the Wavelet Toolbox graphical user interface tools.
%   The WAVEMENU command will be removed in a future release. Use
%   waveletAnalyzer instead.
%
%    WAVEMENU launches a menu for accessing the various 
%    graphical tools provided in the Wavelet Toolbox.
%
%    In addition, WAVEMENU(COLOR) let you choose the color
%    preferences. Available values for COLOR are:
%        'k', 'w' , 'y' , 'r' , 'g', 'b' , 'std' (or 's')
%        and 'default' (or 'd').
%
%    WAVEMENU is equivalent to WAVEMENU('default')

% Last Modified by GUIDE v2.5 20-Nov-2010 15:06:19
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-Aug-2013.
%   Copyright 1995-2020 The MathWorks, Inc.
%   $Revision: 1.22.4.21 $ $Date: 2013/08/23 23:45:16 $

warning(message('Wavelet:wavemenu:FunctionToBeRemoved'));
[varargout{1:nargout}] = waveletAnalyzer(varargin{:});
