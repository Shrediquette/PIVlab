function S = getWavMSG(msgId,varargin)
%GETWAVMSG Cache function for message catalog.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 27-Aug-2011.
%   Last Revision: 28-Aug-2011.
%   Copyright 1995-2020 The MathWorks, Inc.

S = getString(message(msgId,varargin{:}));
