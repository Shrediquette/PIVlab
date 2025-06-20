//-----------------------------------------------------------------------------//
// Name        | SC2_common.h                | Type: ( ) source                //
//-------------------------------------------|       (*) header                //
// Project     | PCO                         |       ( ) others                //
//-----------------------------------------------------------------------------//
// Purpose     | Defines, constants for use with SDK commands for              //
//             | pco.camera (SC2)                                              //
//-----------------------------------------------------------------------------//
// Author      | MBl/FRe/LWa and others, Excelitas PCO GmbH                    //
//-----------------------------------------------------------------------------//
// Notes       |                                                               //
//-----------------------------------------------------------------------------//
// (c) 2010-2021 Excelitas PCO GmbH * Donaupark 11 * D-93309 Kelheim / Germany //
// *  Phone: +49 (0)9441 / 2005-0  *                                           //
// *  Fax:   +49 (0)9441 / 2005-20 * Email: pco@excelitas.com                  //
//-----------------------------------------------------------------------------//


#if !defined SC2_COMMON
#define SC2_COMMON


//#pragma message("Structures packed to 1 byte boundary!")
#pragma pack(push) 
#pragma pack(1)

#if !defined PCO_METADATA_STRUCT
#define PCO_METADATA_STRUCT_DEFINED

#define PCO_METADATA_SIZE_V1 58
#define PCO_METADATA_SIZE_V2 68
#define PCO_METADATA_SIZE_V3 69

#define PCO_METADATA_VERSION         0x0003     // current version!

#define PCO_METADATA_VERSION_V1      0x0001 
#define PCO_METADATA_VERSION_V2      0x0002 
#define PCO_METADATA_VERSION_V3      0x0003

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

  SHORT  sSENSOR_TEMPERATURE;        // current sensor temperature in grade celsius, 0x8000 if not known

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
  BYTE   bSYNC_STATUS;               // status of PLL for external synchronisation (100 Hz or 1 kHz):  Bit 0: 0 = off, 1 = locked
                                     // status of sequences stop trigger (T0 trigger):                 Bit 1: 0 = no trigger, 1 = trigger
  WORD   wDARK_OFFSET;               // nominal dark offset in counts, 0xFFFF if unknown, current dark offset may differ
  // 52
  BYTE   bTRIGGER_MODE;              // exposure trigger mode, see PCO SDK
  BYTE   bDOUBLE_IMAGE_MODE;         // 0x00 = standard, 0x01 = double image (PIV) mode
  BYTE   bCAMERA_SYNC_MODE;          // see PCO SDK
  BYTE   bIMAGE_TYPE;                // 0x01 ist b/w, 0x02 is color bayer pattern, 0x10 is RGB mode
  WORD   wCOLOR_PATTERN;             // bayer pattern color mask, same as for SDK command "Get Camera Description", 0 if n/a
  // 58 - structure V2 starting here
  WORD   wCAMERA_SUBTYPE;            // sub-type of pco camera taking the images, see SDK, 0 if unknown
  DWORD  dwEVENT_NUMBER;             // application dependent event number
  // 64 bytes ..
  WORD   wIMAGE_SIZE_X_Offset;       // actual x offset in case of ROI (X0) in x direction (horizontal)
  WORD   wIMAGE_SIZE_Y_Offset;       // actual y offset in case of ROI (Y0) in y direction (vertical)
  // 68 - structure V3 starting here
  BYTE   bREADOUT_MODE;              // [7]: readout direction: 0 = normal, 1 = reverse; [6:0]: readout mode
  // 69 bytes ..
}
PCO_METADATA_STRUCT;


// Add the older version V2 for use with legacy firmware (bugfixes etc.):

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

  SHORT  sSENSOR_TEMPERATURE;        // current sensor temperature in grade celsius, 0x8000 if not known

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
  BYTE   bSYNC_STATUS;               // status of PLL for external synchronisation (100 Hz or 1 kHz):  Bit 0: 0 = off, 1 = locked
                                     // status of sequences stop trigger (T0 trigger):                 Bit 1: 0 = no trigger, 1 = trigger
  WORD   wDARK_OFFSET;               // nominal dark offset in counts, 0xFFFF if unknown, current dark offset may differ
  // 52
  BYTE   bTRIGGER_MODE;              // exposure trigger mode, see PCO SDK
  BYTE   bDOUBLE_IMAGE_MODE;         // 0x00 = standard, 0x01 = double image (PIV) mode
  BYTE   bCAMERA_SYNC_MODE;          // see PCO SDK
  BYTE   bIMAGE_TYPE;                // 0x01 ist b/w, 0x02 is color bayer pattern, 0x10 is RGB mode
  WORD   wCOLOR_PATTERN;             // bayer pattern color mask, same as for SDK command "Get Camera Description", 0 if n/a
  // 58 - structure V2 starting here
  WORD   wCAMERA_SUBTYPE;            // sub-type of pco camera taking the images, see SDK, 0 if unknown
  DWORD  dwEVENT_NUMBER;             // application dependent event number
  // 64 bytes ..
  WORD   wIMAGE_SIZE_X_Offset;       // actual x offset in case of ROI (X0) in x direction (horizontal)
  WORD   wIMAGE_SIZE_Y_Offset;       // actual y offset in case of ROI (Y0) in y direction (vertical)
  // 68 bytes
}
PCO_METADATA_STRUCT_V2;


// Add the older version V1 for use with legacy firmware (bugfixes etc.):

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

  SHORT  sSENSOR_TEMPERATURE;        // current sensor temperature in grade celsius, 0x8000 if not known

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
  BYTE   bSYNC_STATUS;               // status of PLL for external synchronisation (100 Hz or 1 kHz):  Bit 0: 0 = off, 1 = locked
                                     // status of sequences stop trigger (T0 trigger):                 Bit 1: 0 = no trigger, 1 = trigger
  WORD   wDARK_OFFSET;               // nominal dark offset in counts, 0xFFFF if unknown, current dark offset may differ
  // 52
  BYTE   bTRIGGER_MODE;              // exposure trigger mode, see PCO SDK
  BYTE   bDOUBLE_IMAGE_MODE;         // 0x00 = standard, 0x01 = double image (PIV) mode
  BYTE   bCAMERA_SYNC_MODE;          // see PCO SDK
  BYTE   bIMAGE_TYPE;                // 0x01 ist b/w, 0x02 is color bayer pattern, 0x10 is RGB mode
  WORD   wCOLOR_PATTERN;             // bayer pattern color mask, same as for SDK command "Get Camera Description", 0 if n/a
  // 58
}
PCO_METADATA_STRUCT_V1;

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


//#pragma message("Structures packed back to normal!")
#pragma pack(pop)  

#endif
