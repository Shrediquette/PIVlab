function [extMode,shift] = defaultDWTExtModeAndShift(nd)
%MATLAB Code Generation Private Function

%   Return the default extension mode and shift for nd == 1 (DWT) or nd ==
%   2 (DWT2). Uses getappdata('DWT_Attribute') with dwtmode('get') as a
%   fallback method.

%   Copyright 1995-2020 The MathWorks, Inc.
%#codegen

coder.internal.prefer_const(nd);
S1 = coder.const(@feval,'getappdata',0,'DWT_Attribute');
if isstruct(S1) && ~isempty(S1)
    [extMode,shift] = extractData(nd,S1);
else
    S2 = coder.const(@feval,'dwtmode','get');
    [extMode,shift] = extractData(nd,S2);
end

%--------------------------------------------------------------------------

function [extMode,shift] = extractData(nd,S)
coder.internal.prefer_const(nd,S);
extMode = coder.const(S.extMode); % Default: Extension.
if nd == 2
    shift = coder.const(S.shift2D); % Default: Shift.
else % if nd == 1
    shift = coder.const(S.shift1D); % Default: Shift.
end

%--------------------------------------------------------------------------
