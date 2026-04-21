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
// img_in : uint8, H x W (grayscale) or H x W x 3 (colour), MATLAB column-major
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
    // img_in: must be uint8
    // ----------------------------
    if (!mxIsUint8(prhs[0]))
        mexErrMsgTxt("img_in must be uint8.");

    int ndims_in = (int)mxGetNumberOfDimensions(prhs[0]);
    const mwSize* imgDims = mxGetDimensions(prhs[0]);
    int H = (int)imgDims[0];
    int W = (int)imgDims[1];
    int C = (ndims_in == 3) ? (int)imgDims[2] : 1;

    if (C != 1 && C != 3)
        mexErrMsgTxt("img_in must be grayscale (HxW) or RGB (HxWx3).");

    uint8_t* imgData = (uint8_t*)mxGetData(prhs[0]);

    // Convert MATLAB column-major HxW(xC) to OpenCV row-major HxW(xC)
    cv::Mat img_cv;
    if (C == 1)
    {
        img_cv.create(H, W, CV_8UC1);
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
                img_cv.at<uint8_t>(r, c) = imgData[r + c*H];
    }
    else
    {
        img_cv.create(H, W, CV_8UC3);
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
            {
                // MATLAB stores planes separately (R plane, G plane, B plane)
                img_cv.at<cv::Vec3b>(r, c)[0] = imgData[r + c*H + 0*H*W]; // R
                img_cv.at<cv::Vec3b>(r, c)[1] = imgData[r + c*H + 1*H*W]; // G
                img_cv.at<cv::Vec3b>(r, c)[2] = imgData[r + c*H + 2*H*W]; // B
            }
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

    plhs[0] = mxCreateNumericArray(ndims_out, outDims, mxUINT8_CLASS, mxREAL);
    uint8_t* outData = (uint8_t*)mxGetData(plhs[0]);

    if (Cout == 1)
    {
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
                outData[r + c*H] = img_out.at<uint8_t>(r, c);
    }
    else
    {
        for (int r = 0; r < H; ++r)
            for (int c = 0; c < W; ++c)
            {
                outData[r + c*H + 0*H*W] = img_out.at<cv::Vec3b>(r, c)[0]; // R
                outData[r + c*H + 1*H*W] = img_out.at<cv::Vec3b>(r, c)[1]; // G
                outData[r + c*H + 2*H*W] = img_out.at<cv::Vec3b>(r, c)[2]; // B
            }
    }
}
