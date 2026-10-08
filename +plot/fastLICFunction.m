function [varargout] = fastLICFunction(varargin)

% AUTOCOMPILE compile the missing mex file on the fly
% plot.fastLICFunction() (no inputs) only compiles the MEX file (see plot.LIC_core).
% The MEX file cannot be called from here: while this file runs, MATLAB keeps calling this
% file instead of the new MEX file (endless recursion before 2026-10).

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
pause(1)
cd(pwdir);
success = true;

catch
% compilation failed
cd(pwdir);
disp(lasterr);
error('could not locate MEX file for %s', mexname);
end

if success
disp('... compilation OK')
if nargin > 0
	error('The MEX file %s was compiled now. Please call plot.%s again.', mexname, mexname);
end
end