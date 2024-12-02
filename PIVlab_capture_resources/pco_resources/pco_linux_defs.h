#ifdef _WIN32
#include <windows.h>

#elif defined(PCO_LINUX)
#include <stdint.h>
#include <stdarg.h>

typedef int                 BOOL;
#ifndef FALSE
#define FALSE               0
#endif

#ifndef TRUE
#define TRUE                1
#endif

typedef uint8_t       BYTE;
typedef uint8_t       UCHAR;
typedef UCHAR         *PUCHAR;

typedef uint16_t      WORD;
typedef uint32_t      DWORD;
typedef uint64_t      UINT64;
typedef uint64_t      DWORD64;


typedef char          TCHAR;
typedef char          CHAR;
//typedef wchar_t       WCHAR;

typedef char*         LPTSTR;
typedef char*         LPSTR;

typedef const char*   LPCTSTR;
typedef const char*   LPCSTR;


typedef int16_t       SHORT;
typedef uint16_t      USHORT;
typedef USHORT        *PUSHORT;

typedef int32_t       LONG;
typedef uint32_t      ULONG;
typedef ULONG         *PULONG;

typedef int64_t       INT64;
typedef int64_t       LONGLONG;
typedef uint64_t      ULONGLONG;

typedef int32_t       __int32;
typedef uint32_t      __uint32;

typedef int64_t       __int64;
typedef uint64_t      __uint64;

typedef uint64_t      LARGE_INTEGER;


typedef float         FLOAT;
typedef FLOAT         *PFLOAT;
typedef BOOL          *LPBOOL;
typedef BYTE          *LPBYTE;
typedef int           *LPINT;
typedef WORD          *LPWORD;
typedef long          *LPLONG;
typedef DWORD         *LPDWORD;
typedef void          *LPVOID;
typedef const void    *LPCVOID;

typedef int                 INT;
typedef unsigned int        UINT;
typedef unsigned int        *PUINT;
typedef unsigned long long  DWORD_PTR;

#define MAKEWORD(a, b)      ((WORD)(((BYTE)(((DWORD_PTR)(a)) & 0xff)) | ((WORD)((BYTE)(((DWORD_PTR)(b)) & 0xff))) << 8))
#define MAKELONG(a, b)      ((LONG)(((WORD)(((DWORD_PTR)(a)) & 0xffff)) | ((DWORD)((WORD)(((DWORD_PTR)(b)) & 0xffff))) << 16))
#define LOWORD(l)           ((WORD)(((DWORD_PTR)(l)) & 0xffff))
#define HIWORD(l)           ((WORD)((((DWORD_PTR)(l)) >> 16) & 0xffff))
#define LOBYTE(w)           ((BYTE)(((DWORD_PTR)(w)) & 0xff))
#define HIBYTE(w)           ((BYTE)((((DWORD_PTR)(w)) >> 8) & 0xff))

typedef void*         HANDLE;
typedef HANDLE        *PHANDLE;

typedef void*         HINSTANCE;
typedef void*         HMODULE;
typedef void*         LPVOID;
typedef void*         PVOID;

typedef HANDLE        *LPHANDLE;
typedef HANDLE        HGLOBAL;
typedef HANDLE        HLOCAL;
typedef HANDLE        GLOBALHANDLE;
typedef HANDLE        LOCALHANDLE;

typedef int           PCO_HANDLE;


#define far

#if !defined (MAX_PATH)
#define MAX_PATH 1024
#endif


#else
#error Unknown/unsupported platform
#endif

