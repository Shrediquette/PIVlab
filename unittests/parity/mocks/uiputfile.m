function [f,p,idx] = uiputfile(varargin)
% Test mock: returns the file set with setappdata(0,'parity_mock_file',{path,file}).
m = getappdata(0,'parity_mock_file');
if isempty(m), f = 0; p = 0; idx = 0; return; end
p = m{1}; f = m{2}; idx = 1;
if ~endsWith(p,filesep), p = [p filesep]; end
end
