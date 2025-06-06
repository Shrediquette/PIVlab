//-----------------------------------------------------------------//
// Name        | pco_matlab.h                | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Visual 'C++'                                      //
//-----------------------------------------------------------------//
// Purpose     | PCO - matlab                                      //
//-----------------------------------------------------------------//
// Author      | MBL, Excelitas PCO GmbH                           //
//-----------------------------------------------------------------//
// Revision    |  rev. 1.10 rel. 1.10                              //
//-----------------------------------------------------------------//
// Notes       | This file does help to wrap common used           //
//             | declaration in pco header files to matlab conform //
//             | syntax                                            //
//-----------------------------------------------------------------//
// (c) 2021 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com                 //
//-----------------------------------------------------------------//


#ifndef PCO_MATLAB_H
#define PCO_MATLAB_H

#ifdef _WIN32
    #define WINAPI __stdcall
#else
    #define WINAPI
#endif 

#include <stdint.h>
#include <stdarg.h>

#define BYTE uint8_t
#define WORD uint16_t
#define DWORD uint32_t
#define FLOAT float
#define CHAR char

#define INT64 int64_t
#define UINT64 uint64_t
#define UINT32 uint32_t
#define SHORT int16_t
#define LONG int32_t

#define HANDLE void* 

#define far 

#endif
