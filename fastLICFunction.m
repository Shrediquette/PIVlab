function [varargout] = fastLICFunction(varargin)

% AUTOCOMPILE compile the missing mex file on the fly

% remember the original working directory
pwdir = pwd;

% determine the name and full path of this function
funname = mfilename('fullpath');
mexsrc = [funname '.c'];
[mexdir, mexname] = fileparts(funname);

try
% try to compile the mex file on the fly
disp(['trying to compile MEX file from ' mexsrc ' ...']);
cd(mexdir);
mex(mexsrc);
cd(pwdir);
success = true;

catch
% compilation failed
disp(lasterr);
error('could not locate MEX file for %s', mexname);
disp(['Please try to compile the file ' mexsrc ' manually.']);
disp('You might need to run "mex -setup" in Matlab before compilation');
cd(pwdir);
success = false;
end

if success
% execute the mex file that was just created
disp('... compilation OK')
funname = mfilename;
funhandle = str2func(funname);
[varargout{1:nargout}] = funhandle(varargin{:});
end