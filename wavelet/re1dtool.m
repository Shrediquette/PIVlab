function varargout = re1dtool(option,varargin)
%RE1DTOOL Regression estimation 1-D tool.
%   VARARGOUT = RE1DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Nov-98.
%   Copyright 1995-2020 The MathWorks, Inc.

% DDUX data logging
dataId = matlab.ddux.internal.DataIdentification("WA", ...
    "WA_WAVELETANALYZER","WA_WAVELETANALYZER_APPS");
DDUXdata = struct();
DDUXdata.appName = "re1dtool";
matlab.ddux.internal.logData(dataId,DDUXdata);
% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
switch option
    case 'create'
        win_tool = wdretool('createREG');
        if nargout>0 , varargout{1} =  win_tool; end

    case 'close' , wdretool('close');

    otherwise
        errargt(mfilename,getWavMSG('Wavelet:moreMSGRF:Unknown_Opt'),'msg');
        error(message('Wavelet:FunctionArgVal:Invalid_Input'));
end
