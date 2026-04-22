% Build script for PIVlab OpenCV MEX files — static linking via vcpkg.
% Run from an interactive MATLAB session (not via MCP server).
%
% Prerequisites:
%   1. vcpkg at C:\vcpkg
%        git clone https://github.com/microsoft/vcpkg C:\vcpkg
%        C:\vcpkg\bootstrap-vcpkg.bat -disableMetrics
%   2. OpenCV4 static-md installed:
%        C:\vcpkg\vcpkg install "opencv4[core,calib3d,imgproc]:x64-windows-static-md"

clc
mex -setup C++

VCPKG_ROOT = 'C:\vcpkg\installed\x64-windows-static-md';
OPENCV_INC = fullfile(VCPKG_ROOT, 'include', 'opencv4');
LIB_DIR    = fullfile(VCPKG_ROOT, 'lib');

if ~isfolder(OPENCV_INC)
    error('OpenCV headers not found at %s\nRun: C:\\vcpkg\\vcpkg install "opencv4[core,calib3d,imgproc]:x64-windows-static-md"', OPENCV_INC);
end

% Collect ALL .lib files — opencv modules + all third-party deps.
% Static archives do not carry transitive dependencies, so every lib must be
% listed explicitly on the link command.
lib_files = dir(fullfile(LIB_DIR, '*.lib'));
if isempty(lib_files)
    error('No .lib files found in %s', LIB_DIR);
end
lib_args = arrayfun(@(f) fullfile(LIB_DIR, f.name), lib_files, 'UniformOutput', false);

src_dir = fileparts(mfilename('fullpath'));

% Windows system libs required by OpenCV internals
sys_libs = {'kernel32.lib','user32.lib','gdi32.lib','winspool.lib', ...
            'shell32.lib','ole32.lib','oleaut32.lib','uuid.lib', ...
            'comdlg32.lib','advapi32.lib','ws2_32.lib'};

all_args = [{'-v', '-outdir', src_dir, ['-I' OPENCV_INC]}, lib_args(:)', sys_libs(:)'];

disp('Building opencv_calibrate_basic ...')
mex(all_args{:}, fullfile(src_dir, 'opencv_calibrate_basic.cpp'))

disp('Building opencv_calibrate_tilted ...')
mex(all_args{:}, fullfile(src_dir, 'opencv_calibrate_tilted.cpp'))

disp('Building opencv_undistort ...')
mex(all_args{:}, fullfile(src_dir, 'opencv_undistort.cpp'))

disp('Building opencv_version ...')
mex(all_args{:}, fullfile(src_dir, 'opencv_version.cpp'))

disp('All MEX files built successfully.')
