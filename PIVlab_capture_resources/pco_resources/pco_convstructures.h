//-----------------------------------------------------------------//
// Name        | Pco_ConvStructures.h        | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Purpose     | PCO - Convert DLL structure definitions           //
//-----------------------------------------------------------------//
// Author      | MBL, FRE, HWI, Excelitas PCO GmbH                 //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2021 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com           //
//-----------------------------------------------------------------//


// @ver1.000

// defines for Lut's ...
// local functions

//--------------------
#ifndef PCO_CONVERT_STRUCT_H
#define PCO_CONVERT_STRUCT_H

#ifndef PCO_COLOR_CORR_COEFF_H
#error "Please include pco_color_corr_coeff.h before including pco_convstructures.h."
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/*#ifndef dword
#define dword DWORD
#endif
#ifndef word
#define word WORD
#endif
#ifndef byte
#define byte BYTE
#endif*/

#define PCO_BW_CONVERT      1
#define PCO_COLOR_CONVERT   2
#define PCO_PSEUDO_CONVERT  3
#define PCO_COLOR16_CONVERT 4

#define PCO_CONV_SDK_DEF_DLG_NO_WAIT_MSG_IN_OPEN      0x00000200 // Open dialog does not release message loop during creation of dialog

#define PROCESS_REC2020 0x00000001 // Use Rec 2020 calculation for gamma

typedef struct  {
  WORD          wSize;
  WORD          wScale_minmax;         // Maximum value for min
  int           iScale_maxmax;         // Maximum value for max
  int           iScale_min;            // Lowest value for processing
  int           iScale_max;            // Highest value for processing
  int           iColor_temp;           // Color temperature  3500...20000
  int           iColor_tint;           // Color correction  -100...100 // 5 int
  int           iColor_saturation;     // Color saturation  -100...100
  int           iColor_vibrance;       // Color dynamic saturation  -100...100
  int           iContrast;             // Contrast  -100...100
  int           iGamma;                // Gamma  40...250
  int           iSRGB;                 // sRGB mode
  void          *pHistogrammData;      // internal pointer to histogram data // 10 int
  DWORD         dwDialogOpenFlags;     // Set to zero
  DWORD         dwProcessingFlags;     // Flags to control processing: 0x01 -> Use Rec 2020 Mode for Gamma calculation
  WORD          wProzValue4Min;        // % value to clip range for min max (min+x% and max-x%)
  WORD          wProzValue4Max;        // % value to clip range for min max (min+x% and max-x%)
  DWORD         dwzzDummy1[49];        // 64 int
}PCO_Display;

#define BAYER_UPPER_LEFT_IS_RED        0x000000000
#define BAYER_UPPER_LEFT_IS_GREEN_RED  0x000000001
#define BAYER_UPPER_LEFT_IS_GREEN_BLUE 0x000000002
#define BAYER_UPPER_LEFT_IS_BLUE       0x000000003

typedef struct  {
  WORD  wSize;
  WORD  wAlpha;                        // Alpha (opacity) value for RGBA or BGRA; 0 = transparent; 255 = opaque
  int   iKernel;                       // Selection of upper left pixel R-Gr-Gb-B
  int   iColorMode;                    // Mode parameter of sensor: 0: Bayer pattern // 3 int
  DWORD dwzzDummy1[61];                // 64 int
}PCO_Bayer;

#define CONVERT_FILTER_MODE_NLM            0x0001 // NLM filter mode
#define CONVERT_FILTER_MODE_DENOISE        0x0002 // PCO denoiser filter mode
#define CONVERT_FILTER_MODE_VEC_TRANSLATE  0x0004 // PCO vector translate mode

typedef struct  {
  WORD  wSize;
  WORD  wDummy;
  int   iMode;                         // Noise reduction mode
  int   iType;                         // Noise reduction type // 3 int
  int   iSharpen;                      // Amount sharpen
  DWORD dwzzDummy1[60];
}PCO_Filter;

// Flags for actual input data
#define CONVERT_SENSOR_COLORIMAGE     0x0001 // Input data is a color image (see Bayer struct)
#define CONVERT_SENSOR_UPPERALIGNED   0x0002 // Input data is upper aligned
#define CONVERT_SENSOR_NO_DENOISER    0x0004 // Input data must not be denoised
typedef struct {
  WORD wSize;
  WORD wDummy;
  int  iConversionFactor;              // Conversion factor of sensor in 1/100 e/count
  int  iDataBits;                      // Bit resolution of sensor
  int  iSensorInfoBits;                // Flags:
                                       // 0x00000001: Input is a color image (see Bayer struct!)
                                       // 0x00000002: Input is upper aligned
  int  iDarkOffset;                    // Hardware dark offset
  WORD wIMAGE_SIZE_X_Offset;           // Sensor ROI x left, 0 is first pixel (zero based)
  WORD wIMAGE_SIZE_Y_Offset;           // Sensor ROI y top, 0 is first pixel (zero based)
  SRGBCOLCORRCOEFF strColorCoeff;      // 9 double -> 18int // 24 int
  int  iCamNum;                        // Camera number (enumeration of cameras controlled by app)
  HANDLE hCamera;                      // Handle of the camera loaded, future use; set to zero.
  DWORD dwzzDummy1[38];
}PCO_SensorInfo;


// Flags for output data, directly controlled by the convert mode parameter
#define CONVERT_MODE_OUT_MASK          0xFFFF0000
#define CONVERT_MODE_OUT_FLIPIMAGE     0x0001 // Flip image (top->bottom; bottom->top)
#define CONVERT_MODE_OUT_MIRRORIMAGE   0x0002 // Mirror image (left->right; right->left)
//#define CONVERT_MODE_OUT_TURNIMAGEL   0x0004 // Turn image 90 degree non counterclockwise
//#define CONVERT_MODE_OUT_TURNIMAGER   0x0008 // Turn image 90 degree counterclockwise
#define CONVERT_MODE_OUT_RGB32         0x0100 // Produce 32bit (not 24bit); Flag name is not really a good one, as it implies RGB
                                              // but it will produce a BGR(A) instead. See next flag, sorry for this.
#define CONVERT_MODE_OUT_RGB           0x0200 // In case this flag is set, the conversion produces an RGB output, instead of BGR
#define CONVERT_MODE_EXT_FILTER_FLAGS  0x1000 // Enables the control of the internal flags


// Process internal flags, controlled by the dialog
#define CONVERT_MODE_OUT_DOPOSTPROC    0x00010000 // Post processing is enabled (e.g. 16->8, filter, etc.)
#define CONVERT_MODE_OUT_DOLOWPASS     0x00020000 // Resulting image will be low pass filtered
#define CONVERT_MODE_OUT_DOBLUR        0x00040000 // Resulting color image will be blurred
#define CONVERT_MODE_OUT_DOMEDIAN      0x00080000 // Resulting color image will be median filtered
#define CONVERT_MODE_OUT_DOSHARPEN     0x00100000 // Resulting color image will be sharpened
#define CONVERT_MODE_OUT_DOADSHARPEN   0x00200000 // Resulting color image will be 'adaptive' sharpened
#define CONVERT_MODE_OUT_DOPCODEBAYER  0x00400000 // Demosaicking used is pco algorithm instead of CUVI (tunacode)

#define CONVERT_MODE_OUT_HAS_TIMESTAMP 0x00800000 // Calculate histogram without timestamp
#define CONVERT_MODE_OUT_DOHIST        0x00000010 // Calculate histogram (automatically set when auto minmax is set)
#define CONVERT_MODE_OUT_AUTOMINMAX    0x00000020 // Does an auto min/max during conversion and sets the values
#define CONVERT_MODE_OUT_AUTOMINMAX_SM 0x00000040 // same, but with smaller area (min+10% and max-10%)
#define CONVERT_MODE_OUT_AUTOMINMAX_PRZ 0x00000080 // same, but with prz area (min+x% and max-x%); see iProzValue4MinMax

#define CONVERT_CAPS_DENOISER          0x00000001 // Denoiser is possible
#define CONVERT_CAPS_DENOISER_REINIT   0x00000002 // Denoiser flag must be reinit, due to switching to CPU convert

#define CONVERT_CAPS_OPENCL            0x00000004 // OpenCL convert is possible
#define CONVERT_CAPS_CUDA              0x00000008 // CUDA convert is possible
#define CONVERT_CAPS_VEC_TRANSLATE     0x00000010 // Vector translation is possible

typedef struct
{
  WORD  wSize;
  WORD  wDummy[3];
  PCO_Display         str_Display;     // Process settings for output image // 66 int
  PCO_Bayer           str_Bayer;       // Bayer processing settings // 130 int
  PCO_Filter          str_Filter;      // Filter processing settings // 198 int
  PCO_SensorInfo      str_SensorInfo;  // Sensor parameter // 258 int
  int                 iData_Bits_Out;  // Bit resolution of output:
                                       // BW only: 8: 8bit bw
                                       // Color / BW:
                                       //   Color sensor: 24: 8bit BGR, 32: 8bit BGRA
                                       //   BW sensor: Call to Convert16TO24
                                       //              24: 8bit RGB bw (R=B=G)
                                       //              32: 8bit RGBA bw (R=B=G)
                                       //   BW sensor: Call to Convert16TOPSEUDO
                                       //              24: 8bit BGR (Pseudo color)
                                       //              32: 8bit BGRA (Pseudo color)
                                       // Color only: 48bit: 16bit BGR, not available with bw sensor
  DWORD               dwModeBitsDataOut;// Flags setting different modes:
                                       // 0x00000001: Flip image
                                       // 0x00000002: Mirror image
                                       // 0x00000100: Produce 32bit color output image
                                       // 0x00000200: Produce RGB color output image
                                       // 0x00010000: Do post processing
                                       // 0x00020000: Do low pass filtering
                                       // 0x00040000: Do color blur
                                       // 0x00400000: Demosaicking used is fast algorithm

  int                 iGPU_Processing_mode;// Mode for processing: 0->CPU, 1->GPU, 2->OpenCL // 261 int
  int                 iConvertType;    // 1: BW, 2: color, 3: Pseudo-color, 4: 16bit-color
  char                szConvertInfo[60];  // GPU Name only
  DWORD               dwConvertCAPS;   // 0x00000001: Denoiser is possible
  char                szConvertInfoGPU[60];  // GPU info only
  DWORD               dwzzDummy1[27];  // 320 int
}PCO_Convert;

#endif /* PCO_CONVERT_STRUCT_H */
