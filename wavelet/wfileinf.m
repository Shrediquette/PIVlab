function [fileStruct,err] = wfileinf(varargin)
%WFILEINF Read variables info in a file.
%   [FILESTRUCT,ERR] = WFILEINF(FULLFILENAME)  OR
%   [FILESTRUCT,ERR] = WFILEINF(PATHNAME,FILENAME)  OR
%   [FILESTRUCT,ERR] = WFILEINF(DIR1,DIR2,...,FILE)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Oct-97.
%   Last Revision: 29-May-1998.
%   Copyright 1995-2020 The MathWorks, Inc.

switch nargin
  case 1 ,    fullName = varargin{1};
  otherwise , fullName = fullfile(varargin{:});
end
fileStruct = whos('-file',fullName);
err = isempty(fileStruct);
