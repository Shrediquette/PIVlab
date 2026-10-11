function root = helper_root()
%HELPER_ROOT PIVlab folder (the folder above unittests). Helper of the unit tests.
root = fileparts(fileparts(mfilename('fullpath')));
end
