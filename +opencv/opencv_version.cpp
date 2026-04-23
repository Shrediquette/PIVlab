#include "mex.h"
#include <opencv2/core.hpp>

// opencv_version: returns the OpenCV version string as a MATLAB char array.
// Used to verify that the statically-linked OpenCV MEX files are present and
// actually executable on the current machine / MATLAB version.
//
// Usage:
//   v = opencv.opencv_version   % returns e.g. '4.12.0'

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    std::string v = cv::getVersionString();
    plhs[0] = mxCreateString(v.c_str());
}
