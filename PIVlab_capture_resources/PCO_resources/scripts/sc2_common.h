//-----------------------------------------------------------------//
// Name        | SC2_common.h                | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | - Embedded platforms like M16C, AVR32, PIC32 etc. //
//             | - PC with several Windows versions, Linux etc.    //
//-----------------------------------------------------------------//
// Environment | - Platform dependent                              //
//-----------------------------------------------------------------//
// Purpose     | Defines, constants for use with SDK commands for  //
//             | pco.camera (SC2)                                  //
//-----------------------------------------------------------------//
// Author      | MBl/FRe/LWa and others, PCO AG                    //
//-----------------------------------------------------------------//
// Revision    | versioned using SVN                               //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2010-2014 PCO AG * Donaupark 11 * D-93309 Kelheim / Germany //
// *  Phone: +49 (0)9441 / 2005-0  *                               //
// *  Fax:   +49 (0)9441 / 2005-20 *  Email: info@pco.de           //
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
// Revision History:                                               //
//-----------------------------------------------------------------//
// Rev.:     | Date:      | Changed:                               //
// --------- | ---------- | ---------------------------------------//
//  0.01     | 15.07.2010 |  new file, FRE                         //
//-----------------------------------------------------------------//
//-----------------------------------------------------------------//

#if !defined SC2_COMMON
#define SC2_COMMON


#ifdef WIN32
//#pragma message("Structures packed to 1 byte boundary!")
#pragma pack(push) 
#pragma pack(1)            
#endif

#ifdef __MICROBLAZE__
#define struct struct __attribute__ ((packed))
#endif


#if !defined PCO_METADATA_STRUCT
#define PCO_METADATA_STRUCT_DEFINED
typedef struct
{
  WORD   wSize;                      // size of this structure
  WORD   wVersion;                   // version of the structure
  // 4
  BYTE   bIMAGE_COUNTER_BCD[4];      // 0x00000001 to 0x99999999, where first byte is least sign. byte
  // 8
  BYTE   bIMAGE_TIME_US_BCD[3];      // 0x000000 to 0x999999, where first byte is least significant byte
  BYTE   bIMAGE_TIME_SEC_BCD;        // 0x00 to 0x59
  BYTE   bIMAGE_TIME_MIN_BCD;        // 0x00 to 0x59
  BYTE   bIMAGE_TIME_HOUR_BCD;       // 0x00 to 0x23
  BYTE   bIMAGE_TIME_DAY_BCD;        // 0x01 to 0x31
  BYTE   bIMAGE_TIME_MON_BCD;        // 0x01 to 0x12
  BYTE   bIMAGE_TIME_YEAR_BCD;       // 0x00 to 0x99 only last two digits, 2000 has to be added
  BYTE   bIMAGE_TIME_STATUS;         // 0x00 = internal osc, 0x01 = synced by IRIG, 0x02 = synced by master
  // 18
  WORD   wEXPOSURE_TIME_BASE;        // timebase ns/us/ms for following exposure time
  DWORD  dwEXPOSURE_TIME;            // exposure time in ns/us/ms  according to timebase
  DWORD  dwFRAMERATE_MILLIHZ;        // framerate in mHz, 0 if unknown or not

  SHORT  sSENSOR_TEMPERATURE;        // current sensor temperature in centigrade, 0x8000 if not known

                                     // Note: Description changed 27.06.2017: Now centigrades, which
                                     //       is current implementation in pco.dimax. This is 
                                     //       different from the PCO_GetTemperature command which
                                     //       provides the sensor temperature in 10th of degrees!
  // 30
  WORD   wIMAGE_SIZE_X;              // actual size of image in x direction (horizontal)
  WORD   wIMAGE_SIZE_Y;              // actual size of image in y direction (vertical)
  BYTE   bBINNING_X;                 // binning in x direction, 0x00 if unknown or n/a
  BYTE   bBINNING_Y;                 // binning in y direction, 0x00 if unknown or n/a
  // 36
  DWORD  dwSENSOR_READOUT_FREQUENCY; // sensor readout frequency in Hz, 0 if unknown
  WORD   wSENSOR_CONV_FACTOR;        // sensor conversions factor in e-/ct, 0 if unknown
  // 42
  DWORD  dwCAMERA_SERIAL_NO;         // camera serial no, 0 if unknown
  WORD   wCAMERA_TYPE;               // type of pco camera taking the images, see SDK, 0 if unknown
  BYTE   bBIT_RESOLUTION;            // number of valid bits of the pixel values, e.g. 12 for the pco.dimax
  BYTE   bSYNC_STATUS;               // status of PLL for external synchronisation (100 Hz or 1 kHz): 0 = off, 1 = locked
  WORD   wDARK_OFFSET;               // nominal dark offset in counts, 0xFFFF if unknown, current dark offset may differ
  // 52
  BYTE   bTRIGGER_MODE;              // exposure trigger mode, see PCO SDK
  BYTE   bDOUBLE_IMAGE_MODE;         // 0x00 = standard, 0x01 = double image (PIV) mode
  BYTE   bCAMERA_SYNC_MODE;          // see PCO SDK
  BYTE   bIMAGE_TYPE;                // 0x01 ist b/w, 0x02 is color bayer pattern, 0x10 is RGB mode
  WORD   wCOLOR_PATTERN;             // bayer pattern color mask, same as for SDK command "Get Camera Description", 0 if n/a
  // 58 bytes ..
}
PCO_METADATA_STRUCT;
#endif

#if !defined PCO_TIMESTAMP_STRUCT
#define PCO_TIMESTAMP_STRUCT_DEFINED
typedef struct
{
  WORD   wSize;                      // size of this structure
  DWORD  dwImgCounter;               // number of current image since start of record
  // 6
  WORD wYear;                        // current year
  WORD wMonth;                       // current month of year
  WORD wDay;                         // current day of month
  WORD wHour;                        // current hour of day
  WORD wMinute;                      // current minute of hour
  WORD wSecond;                      // current second of minute
  // 18
  DWORD dwMicroSeconds;              // current microseconds of second
  // 22 bytes ..
}
PCO_TIMESTAMP_STRUCT;
#endif

#ifdef WIN32
//#pragma message("Structures packed back to normal!")
#pragma pack(pop)  
#endif

#ifdef __MICROBLAZE__
#undef struct
#endif


#endif
