#include "mex.h"
#include <opencv2/calib3d.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>
#include <string>
#include <cstring>

// opencv_undistort: undistort an image using the full OpenCV distortion model,
// including the tilted-sensor coefficients tauX/tauY (CALIB_TILTED_MODEL).
// MATLAB's undistortImage does not support tauX/tauY, so this MEX function
// is used instead when the Scheimpflug / tilted model is active.
//
// Usage:
//   img_out = opencv_undistort(img_in, K, D)
//   img_out = opencv_undistort(img_in, K, D, view)
//
// img_in : uint8, uint16, double, or single — HxW (grayscale) or HxWx3 (colour),
//          MATLAB column-major storage. Output class matches input class exactly,
//          with no rescaling — a narrow uint16 range such as [65500,65535] is
//          preserved as-is.
// K      : 3x3 double, OpenCV-format intrinsic matrix
//          [fx  0  cx]
//          [0  fy  cy]
//          [0   0   1]
//          (same layout as K_init passed from pivlab_estimateCameraParameters)
// D      : 1xN double, distortion coefficients in OpenCV order
//          [k1 k2 p1 p2] or full 14-element vector for tilted model
// view   : (optional) string 'same' (default) | 'valid' | 'full'
//          'same'  - output same size as input, original K used as new K
//          'valid' - crop to region with no black borders (alpha=0)
//          'full'  - include all pixels, may have black borders (alpha=1)

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    if (nrhs < 3 || nrhs > 4)
        mexErrMsgTxt("Usage: img_out = opencv_undistort(img_in, K, D [, view])");
    if (nlhs != 1)
        mexErrMsgTxt("One output required.");

    // ----------------------------
    // img_in: uint8, uint16, double, or single
    // ----------------------------
    mxClassID in_class = mxGetClassID(prhs[0]);
    int cv_depth;
    if      (in_class == mxUINT8_CLASS)  cv_depth = CV_8U;
    else if (in_class == mxUINT16_CLASS) cv_depth = CV_16U;
    else if (in_class == mxDOUBLE_CLASS) cv_depth = CV_64F;
    else if (in_class == mxSINGLE_CLASS) cv_depth = CV_32F;
    else
        mexErrMsgTxt("img_in must be uint8, uint16, double, or single.");

    int ndims_in = (int)mxGetNumberOfDimensions(prhs[0]);
    const mwSize* imgDims = mxGetDimensions(prhs[0]);
    int H = (int)imgDims[0];
    int W = (int)imgDims[1];
    int C = (ndims_in == 3) ? (int)imgDims[2] : 1;

    if (C != 1 && C != 3)
        mexErrMsgTxt("img_in must be grayscale (HxW) or RGB (HxWx3).");

    // Bytes per scalar element — used for type-agnostic memcpy
    size_t es = mxGetElementSize(prhs[0]);

    const uint8_t* imgData = (const uint8_t*)mxGetData(prhs[0]);

    // Convert MATLAB column-major HxW(xC) to OpenCV row-major HxW(xC)
    int cv_type = CV_MAKETYPE(cv_depth, C);
    cv::Mat img_cv(H, W, cv_type);

    if (C == 1)
    {
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
                memcpy(img_cv.ptr(r) + c * es,
                       imgData + (r + c * H) * es, es);
    }
    else  // C == 3: MATLAB planar R,G,B → OpenCV interleaved
    {
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
                for (int ch = 0; ch < 3; ++ch)
                    memcpy(img_cv.ptr(r) + (c * 3 + ch) * es,
                           imgData + (r + c * H + ch * H * W) * es, es);
    }

    // ----------------------------
    // K: 3x3 OpenCV-format intrinsic matrix, passed as MATLAB 3x3 column-major
    // K_opencv = [fx 0 cx; 0 fy cy; 0 0 1]
    // In MATLAB column-major storage:
    //   index 0 = K(1,1) = fx
    //   index 1 = K(2,1) = 0
    //   index 2 = K(3,1) = 0
    //   index 3 = K(1,2) = 0
    //   index 4 = K(2,2) = fy
    //   index 5 = K(3,2) = 0
    //   index 6 = K(1,3) = cx
    //   index 7 = K(2,3) = cy
    //   index 8 = K(3,3) = 1
    // ----------------------------
    if (!mxIsDouble(prhs[1]) || mxGetM(prhs[1]) != 3 || mxGetN(prhs[1]) != 3)
        mexErrMsgTxt("K must be a 3x3 double matrix.");

    double* Kdata = mxGetPr(prhs[1]);
    cv::Mat K_cv = (cv::Mat_<double>(3,3) <<
        Kdata[0], 0.0,      Kdata[6],
        0.0,      Kdata[4], Kdata[7],
        0.0,      0.0,      1.0);

    // ----------------------------
    // D: distortion coefficients
    // ----------------------------
    if (!mxIsDouble(prhs[2]))
        mexErrMsgTxt("D must be a double vector.");

    int Dlen = (int)mxGetNumberOfElements(prhs[2]);
    double* Ddata = mxGetPr(prhs[2]);

    cv::Mat D_cv(1, Dlen, CV_64F);
    for (int i = 0; i < Dlen; ++i)
        D_cv.at<double>(0, i) = Ddata[i];

    // ----------------------------
    // view string (optional, default 'same')
    // ----------------------------
    char view_buf[32] = "same";
    if (nrhs == 4)
        mxGetString(prhs[3], view_buf, sizeof(view_buf));

    // ----------------------------
    // Compute new camera matrix based on view
    // ----------------------------
    cv::Size imgSize(W, H);
    cv::Mat newK;

    if (std::strcmp(view_buf, "valid") == 0)
        newK = cv::getOptimalNewCameraMatrix(K_cv, D_cv, imgSize, 0.0, imgSize);
    else if (std::strcmp(view_buf, "full") == 0)
        newK = cv::getOptimalNewCameraMatrix(K_cv, D_cv, imgSize, 1.0, imgSize);
    else // 'same'
        newK = K_cv.clone();

    // ----------------------------
    // Build remap and apply
    // ----------------------------
    cv::Mat map1, map2;
    cv::initUndistortRectifyMap(K_cv, D_cv, cv::Mat(), newK, imgSize,
                                CV_32FC1, map1, map2);

    cv::Mat img_out;
    cv::remap(img_cv, img_out, map1, map2, cv::INTER_CUBIC,
              cv::BORDER_CONSTANT, cv::Scalar(0));

    // ----------------------------
    // Convert OpenCV row-major back to MATLAB column-major
    // ----------------------------
    int Cout = img_out.channels();
    mwSize outDims[3] = {(mwSize)H, (mwSize)W, (mwSize)Cout};
    int ndims_out = (Cout == 1) ? 2 : 3;

    plhs[0] = mxCreateNumericArray(ndims_out, outDims, in_class, mxREAL);
    uint8_t* outData = (uint8_t*)mxGetData(plhs[0]);

    if (Cout == 1)
    {
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
                memcpy(outData + (r + c * H) * es,
                       img_out.ptr(r) + c * es, es);
    }
    else
    {
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
                for (int ch = 0; ch < 3; ++ch)
                    memcpy(outData + (r + c * H + ch * H * W) * es,
                           img_out.ptr(r) + (c * 3 + ch) * es, es);
    }
}
