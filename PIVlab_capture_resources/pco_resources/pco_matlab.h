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

#define BYTE unsigned char
#define WORD unsigned short
#define DWORD unsigned long
#define FLOAT float
#define CHAR char

#define SHORT short
#define LONG long

#define INT64 __int64
#define UINT64 unsigned __int64
#define UINT32 unsigned long

#define HANDLE void* 

#define far 

#endif

