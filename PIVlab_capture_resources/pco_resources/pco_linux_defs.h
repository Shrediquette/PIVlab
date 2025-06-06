#ifdef WIN32
#include <windows.h>

#pragma intrinsic(_byteswap_ushort)
#pragma intrinsic(_byteswap_ulong)
#pragma intrinsic(_byteswap_uint64)
#define bswap_16(s) _byteswap_ushort(s)
#define bswap_32(s) _byteswap_ulong(s)
#define bswap_64(s) _byteswap_uint64(s)

#elif(PCO_LINUX)
#include <stdint.h>
#include <stdarg.h>
#include <thread>
#include <chrono>

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
#define Sleep_ms(ms)        std::this_thread::sleep_for(std::chrono::milliseconds(ms))


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

// Apple specific defines: PCO_LINUX + __APPLE__

#ifdef __APPLE__
#define HOST_NAME_MAX FILENAME_MAX
typedef unsigned long           ulong;

    #define bswap_16(s) ((((s) << 8) & 0xff00U) | (((s) >> 8) & 0x00ffU))
    #define bswap_32(l) ((((l) << 24) & 0xff000000) | (((l) << 8) & 0x00ff0000) | (((l) >> 8) & 0x0000ff00) | (((l) >> 24) & 0x000000ff))
    #define bswap_64(ll) (                          \
           (((ll) << 56) & 0xff00000000000000LL) |    \
           (((ll) << 40) & 0x00ff000000000000LL) |    \
           (((ll) << 24) & 0x0000ff0000000000LL) |    \
           (((ll) <<  8) & 0x000000ff00000000LL) |    \
           (((ll) >>  8) & 0x00000000ff000000LL) |    \
           (((ll) >> 24) & 0x0000000000ff0000LL) |    \
           (((ll) >> 40) & 0x000000000000ff00LL) |    \
           (((ll) >> 56) & 0x00000000000000ffLL))

#else // not __APPLE__ but PCO_LINUX
#define bswap_16(s) __bswap_16(s)
#define bswap_32(s) __bswap_32(s)
#define bswap_64(s) __bswap_64(s)
#endif

#else
#error Unknown/unsupported platform
#endif

