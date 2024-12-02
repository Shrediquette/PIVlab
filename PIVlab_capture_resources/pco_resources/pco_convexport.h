//-----------------------------------------------------------------//
// Name        | Pco_ConvExport.h            | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Purpose     | PCO - Convert DLL function API definitions        //
//-----------------------------------------------------------------//
// Author      | MBL, FRE, HWI, Excelitas PCO GmbH                 //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2021 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com           //
//-----------------------------------------------------------------//

/*
// The following ifdef block is the standard way of creating macros which make exporting
// from a DLL simpler. All files within this DLL are compiled with the PCOCNV_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see
// PCOCNV_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.
*/


#include "pco_convstructures.h"

#ifdef PCOCONVERT_EXPORTS
// __declspec(dllexport) + .def file funktioniert nicht mit 64Bit Compiler
  #if defined _WIN32
    #ifdef _WIN64
      #define PCOCONVERT_API
    #else
      #define PCOCONVERT_API __declspec(dllexport) WINAPI
    #endif
  #else
    #define PCOCONVERT_API __attribute__ ((__visibility__("default")))
  #endif
#else
  #if defined _WIN32
    #define PCOCONVERT_API __declspec(dllimport) WINAPI
  #else
    #define PCOCONVERT_API __attribute__ ((__visibility__("default")))
  #endif
#endif


#ifdef __cplusplus
extern "C" {
#endif  /* __cplusplus */




int PCOCONVERT_API PCO_ConvertCreate(HANDLE* ph, PCO_SensorInfo *strSensor, int iConvertType);
//creates a structure PCO_Convert
//allocates memory for the structure
// iConvertType: 1->bw, 2->rgb8, 3->Pseudo, 4->rgb16

int PCOCONVERT_API PCO_ConvertDelete(HANDLE ph);
//delete the LUT
//free all allocated memory

int PCOCONVERT_API PCO_ConvertGet(HANDLE ph, PCO_Convert* pstrConvert);
int PCOCONVERT_API PCO_ConvertSet(HANDLE ph, PCO_Convert* pstrConvert);

int PCOCONVERT_API PCO_ConvertGetDisplay(HANDLE ph, PCO_Display* pstrDisplay);
// Gets the PCO_Display structure
int PCOCONVERT_API PCO_ConvertSetDisplay(HANDLE ph, PCO_Display* pstrDisplay);
// Sets the PCO_Display structure

int PCOCONVERT_API PCO_ConvertSetBayer(HANDLE ph, PCO_Bayer* pstrBayer);
int PCOCONVERT_API PCO_ConvertSetFilter(HANDLE ph, PCO_Filter* pstrFilter);
int PCOCONVERT_API PCO_ConvertSetSensorInfo(HANDLE ph, PCO_SensorInfo* pstrSensorInfo);

int PCOCONVERT_API PCO_SetPseudoLut(HANDLE ph, unsigned char *pseudo_lut, int inumcolors);
//load the three pseudolut color tables of plut

//plut:   PSEUDOLUT to write data in
//inumcolors: 3: RGB; 4: 32bit RGBA

int PCOCONVERT_API PCO_LoadPseudoLut(HANDLE ph, int format, char *filename);
//load the three pseudolut color tables of plut
//from the file filename
//which includes data in the following formats

//plut:   PSEUDOLUT to write data in
//filename: name of file with data
//format: 0 = binary 256*RGB
//        1 = binary 256*R,256*G,256*R
//        2 = ASCII  256*RGB
//        3 = ASCII  256*R,256*G,256*R


int PCOCONVERT_API PCO_Convert16TO8(HANDLE ph, int mode, int icolmode, int width,int height, word *b16, byte *b8);
//convert picture data in b16 to 8bit data in b8 (grayscale)
int PCOCONVERT_API PCO_Convert16TO24(HANDLE ph, int mode, int icolmode, int width,int height, word *b16, byte *b24);
//convert picture data in b16 to 24bit data in b24 (grayscale)
int PCOCONVERT_API PCO_Convert16TOCOL(HANDLE ph, int mode, int icolmode, int width, int height, word *b16, byte *b8);
//convert picture data in b16 to RGB data in b8 (color)
int PCOCONVERT_API PCO_Convert16TOPSEUDO(HANDLE ph, int mode, int icolmode, int width, int height, word *b16, byte *b8);
//convert picture data in b16 to pseudo color data in b8 (color)
int PCOCONVERT_API PCO_Convert16TOCOL16(HANDLE ph, int mode, int icolmode, int width, int height, word *b16in, word *b16out);
//convert picture data in b16 to RGB data in b16 (color)
//through table in structure of PCO_Convert
//mode:   0       = normal
//        bit0: 1 = flip
//        bit1: 1 = mirror
//width:  width of picture
//height: height of picture
//b12:    pointer to raw picture data array
//b8:     pointer to byte data array (bw: 1 byte per pixel, rgb: 3 byte pp)
//b24:    pointer to byte data array (RGB, 3 byte per pixel, grayscale)

int PCOCONVERT_API PCO_GetWhiteBalance(HANDLE ph, int *color_temp, int *tint, int mode, int width, int height, word *gb12, int x_min, int y_min, int x_max, int y_max);
// gets white balanced values for color_temp and tint
//color_temp: int pointer to get the calculated color temperature
//tint: int pointer to get the calculated tint value
//mode:   0       = normal
//        bit0: 1 = flip
//        bit1: 1 = mirror
//width:  width of picture
//height: height of picture
//gb12:    pointer to raw picture data array
//x_m..: rectangle to set the image region to be used for calculation

int PCOCONVERT_API PCO_GetMaxLimit(float *r_max, float *g_max, float *b_max, float temp, float tint, int output_bits);
// GetMaxLimit gets the RGB values for a given temp and tint. The max value within the convert
// control dialog must not exceed the biggest value of the RGB values, e.g. in case R is the biggest
// value, the max value can increase till the R value hits the bit resolution (4095). Same condition
// must be met for decreasing the max value, e.g. in case B is the lowest value, the max value
// can decrease till the B value hits the min value.
// Usual:   ....min....B..max.G...R...4095(12bit), with max = R+G+B/3
// Increase:....min.......B..max.G...R4095 -> max condition, R hits 4095
// Decrease:....minB..max.G...R.......4095 -> min condition, B hits min
//the values can be used to calculate the maximum values for scale_min and scale_max in the convert control
// fmax = max(r_max,g_max,b_max)
// fmin = min(r_max,g_max,b_max)
// flimit = (float)((1 <<  m_strConvertNew.str_SensorInfo.iDataBits) - 1)
// imaxmax = (int)(flimit / fmax);
// iminmax = (int)(fmin * flimit / fmax);
//r_max,g_max,b_max: float pointer to get the multiplicators
//color_temp: color temperature to be used for calculation
//tint: tint value to be used for calculation
//output_bits: bit range of raw data


int PCOCONVERT_API PCO_GetColorValues(float *pfColorTemp, float *pfColorTint, int iRedMax, int iGreenMax, int iBlueMax);

int PCOCONVERT_API PCO_WhiteBalanceToDisplayStruct(HANDLE ph, PCO_Display* strDisplay, int mode, int width, int height,
                                                   word *gb12, int x_min, int y_min, int x_max, int y_max);
// Calculates the white balance and sets the values to the strDisplay struct while maintaining the limits
// Gets the struct strDisplay from the convert Handle internally.
//mode:   0       = normal
//        bit0: 1 = flip
//        bit1: 1 = mirror
//width:  width of picture
//height: height of picture
//gb12:    pointer to raw picture data array
//x_m..: rectangle to set the image region to be used for calculation

int PCOCONVERT_API PCO_GetVersionInfoPCO_CONV(char* pszName, int iNameLength, char* pszPath, int iPathLength, int* piMajor, int* piMinor, int* piPatch, int* piBuild);
// Returns version information about the dll. 
// char* pszName: String to get the name of the module (can be NULL)
// int iNameLength: Length of the string in bytes (can be 0)
// char* pszPath: String to get the path of the module (can be NULL)
// int iPathLength: Length of the string in bytes (can be 0)
// int* piMajor: Pointer to int to get the major version number (can be NULL)
// int* piMinor: Pointer to int to get the minor version number (can be NULL)
// int* piPatch: Pointer to int to get the patch number (can be NULL)
// int* build: Pointer to int to get the build version number (can be NULL)
#ifdef __cplusplus
}
#endif
