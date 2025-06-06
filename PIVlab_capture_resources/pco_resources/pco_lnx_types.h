//-----------------------------------------------------------------//
// Name        | pco_lnx_types               | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Purpose     | PCO - Common Logging functions                    //
//-----------------------------------------------------------------//
// Author      | FRE, Excelitas PCO GmbH                           //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2003 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com           //
//-----------------------------------------------------------------//


// pco_lnx_types.h: Defines all necessary data types for linux when code is
// migrated from windows OS.
//

#if !defined PCO_LNX_TYPES
#define PCO_LNX_TYPES

#define _MAX_PATH FILENAME_MAX
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <wchar.h>
#include <ctype.h>

typedef struct tagDEC {
  USHORT wReserved;
  union {
    struct {
      BYTE scale;
      BYTE sign;
    } DUMMYSTRUCTNAME;
    USHORT signscale;
  } ;//DUMMYUNIONNAME;
  ULONG  Hi32;
  union {
    struct {
      ULONG Lo32;
      ULONG Mid32;
    } DUMMYSTRUCTNAME2;
    ULONGLONG Lo64;
  } ;//DUMMYUNIONNAME2;
} DECIMAL;

enum VARENUM
    {
        VT_EMPTY	= 0,
        VT_NULL	= 1,
        VT_I2	= 2,
        VT_I4	= 3,
        VT_R4	= 4,
        VT_R8	= 5,
        VT_CY	= 6,
        VT_DATE	= 7,
        VT_BSTR	= 8,
        VT_DISPATCH	= 9,
        VT_ERROR	= 10,
        VT_BOOL	= 11,
        VT_VARIANT	= 12,
        VT_UNKNOWN	= 13,
        VT_DECIMAL	= 14,
        VT_I1	= 16,
        VT_UI1	= 17,
        VT_UI2	= 18,
        VT_UI4	= 19,
        VT_I8	= 20,
        VT_UI8	= 21,
        VT_INT	= 22,
        VT_UINT	= 23,
        VT_VOID	= 24,
        VT_HRESULT	= 25,
        VT_PTR	= 26,
        VT_SAFEARRAY	= 27,
        VT_CARRAY	= 28,
        VT_USERDEFINED	= 29,
        VT_LPSTR	= 30,
        VT_LPWSTR	= 31,
        VT_RECORD	= 36,
        VT_INT_PTR	= 37,
        VT_UINT_PTR	= 38,
        VT_FILETIME	= 64,
        VT_BLOB	= 65,
        VT_STREAM	= 66,
        VT_STORAGE	= 67,
        VT_STREAMED_OBJECT	= 68,
        VT_STORED_OBJECT	= 69,
        VT_BLOB_OBJECT	= 70,
        VT_CF	= 71,
        VT_CLSID	= 72,
        VT_VERSIONED_STREAM	= 73,
        VT_BSTR_BLOB	= 0xfff,
        VT_VECTOR	= 0x1000,
        VT_ARRAY	= 0x2000,
        VT_BYREF	= 0x4000,
        VT_RESERVED	= 0x8000,
        VT_ILLEGAL	= 0xffff,
        VT_ILLEGALMASKED	= 0xfff,
        VT_TYPEMASK	= 0xfff
    } ;

typedef struct _SYSTEMTIME
{
  WORD wYear;
  WORD wMonth;
  WORD wDayOfWeek;
  WORD wDay;
  WORD wHour;
  WORD wMinute;
  WORD wSecond;
  WORD wMilliseconds;
}   SYSTEMTIME;

/*
#if defined CREATE_OBJECT_STRLWR
char *_strlwr_s(char *str, int imaxlen)
{
  unsigned char *p = (unsigned char *)str;
  int ilen = 0;
  while (*p) {
     *p = tolower((unsigned char)*p);
      p++;ilen++;
      if(ilen >= imaxlen)
        break;
  }

  return str;
}
#else
extern char *_strlwr_s(char *str, int imaxlen);
#endif
*/

#define BI_RGB        0L
#pragma pack(push, 1)
struct BITMAPFILEHEADER {
    uint16_t file_type;          // File type always BM which is 0x4D42
    uint32_t file_size;               // Size of the file (in bytes)
    uint16_t reserved1;               // Reserved, always 0
    uint16_t reserved2;               // Reserved, always 0
    uint32_t offset_data;             // Start position of pixel data (bytes from the beginning of the file)
};

struct BITMAPINFOHEADER {
    uint32_t size;                      // Size of this header (in bytes)
    int32_t width;                      // width of bitmap in pixels
    int32_t height;                     // width of bitmap in pixels
                                             //       (if positive, bottom-up, with origin in lower left corner)
                                             //       (if negative, top-down, with origin in upper left corner)
    uint16_t planes;                    // No. of planes for the target device, this is always 1
    uint16_t bit_count;                 // No. of bits per pixel
    uint32_t compression;               // 0 or 3 - uncompressed. THIS PROGRAM CONSIDERS ONLY UNCOMPRESSED BMP images
    uint32_t size_image;                // 0 - for uncompressed images
    int32_t x_pixels_per_meter;
    int32_t y_pixels_per_meter;
    uint32_t colors_used;               // No. color indexes in the color table. Use 0 for the max number of colors allowed by bit_count
    uint32_t colors_important;          // No. of colors used for displaying the bitmap. If 0 all colors are required
};
#pragma pack(pop)

#endif
