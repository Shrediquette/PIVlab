#include "mex.h"
#include <opencv2/calib3d.hpp>
#include <opencv2/core.hpp>
#include <vector>

// opencv_calibrate_tilted: like opencv_calibrate_basic but enables
// CALIB_TILTED_MODEL (Scheimpflug adapter support). Returns a 14-element
// distortion vector [k1 k2 p1 p2 0 0 0 0 0 0 0 0 tauX tauY].

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    if (nrhs != 3 && nrhs != 5)
        mexErrMsgTxt("Usage:\n"
                     "[K, dist, rvecs, tvecs] = opencv_calibrate_tilted(imagePoints, worldPoints, imageSize)\n"
                     "or\n"
                     "[K, dist, rvecs, tvecs] = opencv_calibrate_tilted(imagePoints, worldPoints, imageSize, K_init, D_init)");

    if (nlhs != 4)
        mexErrMsgTxt("Four outputs required.");

    // ----------------------------
    // imagePoints (Mx2xNumImages)
    // ----------------------------
    if (!mxIsDouble(prhs[0]) || mxGetNumberOfDimensions(prhs[0]) != 3)
        mexErrMsgTxt("imagePoints must be Mx2xNumImages double");

    const mwSize* dims = mxGetDimensions(prhs[0]);
    mwSize M = dims[0];
    mwSize numImages = dims[2];
    double* imgData = mxGetPr(prhs[0]);

    // ----------------------------
    // worldPoints (Mx2)
    // ----------------------------
    if (!mxIsDouble(prhs[1]) || mxGetN(prhs[1]) != 2)
        mexErrMsgTxt("worldPoints must be Mx2 double");

    double* worldData = mxGetPr(prhs[1]);

    // ----------------------------
    // imageSize
    // ----------------------------
    double* sizeData = mxGetPr(prhs[2]);
    int height = (int)sizeData[0];
    int width  = (int)sizeData[1];
    cv::Size imageSize(width, height);

    // ----------------------------
    // Build objectPoints + imagePoints (NaN robust)
    // ----------------------------
    std::vector<std::vector<cv::Point3f>> objectPoints;
    std::vector<std::vector<cv::Point2f>> imagePoints;

    for (mwSize v = 0; v < numImages; ++v)
    {
        std::vector<cv::Point2f> imgPts;
        std::vector<cv::Point3f> objPts;

        for (mwSize i = 0; i < M; ++i)
        {
            double x = imgData[i + M*(0 + 2*v)];
            double y = imgData[i + M*(1 + 2*v)];

            if (!mxIsNaN(x) && !mxIsNaN(y))
            {
                imgPts.emplace_back((float)x, (float)y);

                double wx = worldData[i];
                double wy = worldData[i + M];
                objPts.emplace_back((float)wx, (float)wy, 0.0f);
            }
        }

        if (imgPts.size() >= 4)
        {
            imagePoints.push_back(imgPts);
            objectPoints.push_back(objPts);
        }
    }

    if (imagePoints.size() < 3)
        mexErrMsgTxt("Not enough valid images for calibration.");

    // ----------------------------
    // Intrinsics + distortion
    // 14-element vector: [k1 k2 p1 p2 k3 k4 k5 k6 s1 s2 s3 s4 tauX tauY]
    // We fix k3-k6 and s1-s4 to zero; only tauX/tauY are added on top of
    // the standard k1,k2,p1,p2.
    // ----------------------------
    cv::Mat K = cv::Mat::eye(3, 3, CV_64F);
    cv::Mat distCoeffs = cv::Mat::zeros(1, 14, CV_64F);

    int flags = 0;
    flags |= cv::CALIB_FIX_K3;
    flags |= cv::CALIB_FIX_K4;
    flags |= cv::CALIB_FIX_K5;
    flags |= cv::CALIB_FIX_K6;
    flags |= cv::CALIB_FIX_S1_S2_S3_S4;
    flags |= cv::CALIB_TILTED_MODEL;

    // ----------------------------
    // Optional initial guess (K and D from a prior standard calibration)
    // D_init may be 4-element [k1 k2 p1 p2] — we copy what we have.
    // ----------------------------
    if (nrhs == 5)
    {
        if (!mxIsDouble(prhs[3]) || mxGetM(prhs[3]) != 3 || mxGetN(prhs[3]) != 3)
            mexErrMsgTxt("K_init must be 3x3");

        if (!mxIsDouble(prhs[4]))
            mexErrMsgTxt("D_init must be double");

        double* Kin = mxGetPr(prhs[3]);
        double* Din = mxGetPr(prhs[4]);
        mwSize Dlen = mxGetNumberOfElements(prhs[4]);

        // K_init is passed in OpenCV format from the MATLAB wrapper
        K.at<double>(0,0) = Kin[0];  // fx
        K.at<double>(1,1) = Kin[4];  // fy
        K.at<double>(0,2) = Kin[6];  // cx
        K.at<double>(1,2) = Kin[7];  // cy

        // Copy up to 14 elements of D_init
        for (mwSize i = 0; i < Dlen && i < 14; ++i)
            distCoeffs.at<double>(0, (int)i) = Din[i];

        flags |= cv::CALIB_USE_INTRINSIC_GUESS;
    }

    std::vector<cv::Mat> rvecs, tvecs;

    try
    {
        cv::calibrateCamera(objectPoints,
                            imagePoints,
                            imageSize,
                            K,
                            distCoeffs,
                            rvecs,
                            tvecs,
                            flags);
    }
    catch (const cv::Exception& e)
    {
        mexErrMsgTxt(e.what());
    }

    // ----------------------------
    // Output K (same layout as opencv_calibrate_basic)
    // ----------------------------
    plhs[0] = mxCreateDoubleMatrix(3, 3, mxREAL);
    double* outK = mxGetPr(plhs[0]);

    for (int r = 0; r < 3; ++r)
        for (int c = 0; c < 3; ++c)
            outK[r + c*3] = K.at<double>(r, c);

    // ----------------------------
    // Output distortion: full 14-element vector
    // [k1 k2 p1 p2 k3 k4 k5 k6 s1 s2 s3 s4 tauX tauY]
    // ----------------------------
    plhs[1] = mxCreateDoubleMatrix(1, 14, mxREAL);
    double* outD = mxGetPr(plhs[1]);

    for (int i = 0; i < 14; ++i)
        outD[i] = distCoeffs.at<double>(0, i);

    // ----------------------------
    // Output extrinsics
    // ----------------------------
    mwSize usedViews = rvecs.size();

    plhs[2] = mxCreateDoubleMatrix(usedViews, 3, mxREAL);
    plhs[3] = mxCreateDoubleMatrix(usedViews, 3, mxREAL);

    double* outR = mxGetPr(plhs[2]);
    double* outT = mxGetPr(plhs[3]);

    for (mwSize v = 0; v < usedViews; ++v)
    {
        for (int i = 0; i < 3; ++i)
        {
            outR[v + i*usedViews] = rvecs[v].at<double>(i, 0);
            outT[v + i*usedViews] = tvecs[v].at<double>(i, 0);
        }
    }
}
