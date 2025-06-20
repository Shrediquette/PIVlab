//-----------------------------------------------------------------//
// Name        | SC2_CamMatlab.h             | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Matlab                                            //
//-----------------------------------------------------------------//
// Purpose     | PCO - Matlab                                      //
//-----------------------------------------------------------------//
// Author      | MBL, Excelitas PCO GmbH                           //
//-----------------------------------------------------------------//
// Revision    |  rev. 1.10 rel. 1.10                              //
//-----------------------------------------------------------------//
// Notes       | Does include all necessary header files           //
//             |                                                   //
//             |                                                   //
//-----------------------------------------------------------------//
// (c) 2021 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com                 //
//-----------------------------------------------------------------//

#pragma pack(push)            
#pragma pack(1)            

#define MATLAB

#ifndef _WIN32
#define PCO_LINUX
#endif

#include "pco_matlab.h"

#if !defined PCO_ML_BUFLIST_DEF
#define PCO_ML_BUFLIST_DEF
//PCO_Buflist used in PCO_WaitforBuffer
//It is defined here, because we must use different declaration for Matlab
//Maximum count of entries (buffers) is 16 as defined in PCO_BUFCNT.
//This structure defines only 8 entries, which should be sufficient for all applications
typedef struct
{
 SHORT sBufNr_1;
 WORD  ZZwAlignDummy_1;
 DWORD dwStatusDll_1;
 DWORD dwStatusDrv_1;                    // 12
 SHORT sBufNr_2;
 WORD  ZZwAlignDummy_2;
 DWORD dwStatusDll_2;
 DWORD dwStatusDrv_2;                    // 12
 SHORT sBufNr_3;
 WORD  ZZwAlignDummy_3;
 DWORD dwStatusDll_3;
 DWORD dwStatusDrv_3;                    // 12
 SHORT sBufNr_4;
 WORD  ZZwAlignDummy_4;
 DWORD dwStatusDll_4;
 DWORD dwStatusDrv_4;                    // 12
 SHORT sBufNr_5;
 WORD  ZZwAlignDummy_5;
 DWORD dwStatusDll_5;
 DWORD dwStatusDrv_5;                    // 12
 SHORT sBufNr_6;
 WORD  ZZwAlignDummy_6;
 DWORD dwStatusDll_6;
 DWORD dwStatusDrv_6;                    // 12
 SHORT sBufNr_7;
 WORD  ZZwAlignDummy_7;
 DWORD dwStatusDll_7;
 DWORD dwStatusDrv_7;                    // 12
 SHORT sBufNr_8;
 WORD  ZZwAlignDummy_8;
 DWORD dwStatusDll_8;
 DWORD dwStatusDrv_8;                    // 12
}PCO_Buflist;  
#endif

#define PCO_SENSOR_CREATE_OBJECT

#include "sc2_sdkaddendum.h"
#include "sc2_ml_sdkstructures.h"
#include "sc2_defs.h"

#undef PCO_SENSOR_CREATE_OBJECT

#include "sc2_common.h"
#include "pco_device.h"
#include "sc2_camexport.h"
#include "pco_camexport.h"
#include "pco_recorder_export.h"

#pragma pack(pop)            

