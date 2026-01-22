//-----------------------------------------------------------------//
// Name        | pco_device.h                | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | pco.camera                  |       ( ) others    //
//-----------------------------------------------------------------//
// Purpose     | pco.camera - device structure handling            //
//-----------------------------------------------------------------//
// Author      | MBL, Excelitas PCO GmbH, Kelheim, Germany         //
//-----------------------------------------------------------------//
// Notes       | Common definitions                                //
//             | Exported functions                                //
//             |                                                   //
//-----------------------------------------------------------------//
// (c) 2022 - 2022 PCO Excelitas GmbH                              //
// Donaupark 11 D-93309  Kelheim / Germany                         //
// Phone: +49 (0)9441 / 2005-0   Fax: +49 (0)9441 / 2005-20        //
// Email: pco@excelitas.com                                        //
//-----------------------------------------------------------------//


#ifndef PCO_DEVICES_H
#define PCO_DEVICES_H

// GNU specific __attribute__((unused)) define
#ifdef __GNUC__
#define ATTRIBUTE_UNUSED __attribute__((unused))
#else
#define ATTRIBUTE_UNUSED
#endif

#define STRUCT_VERSION_PCODEVICE       0x0100

#define PCO_INTERFACE_ALL    0         // all supported interfaces
#define PCO_INTERFACE_FW     1         // Firewire interface
#define PCO_INTERFACE_CL_MTX 2         // Cameralink Matrox Solios / Helios
#define PCO_INTERFACE_CL_ME3 3         // Cameralink Silicon Software Me3
#define PCO_INTERFACE_CL_NAT 4         // Cameralink National Instruments
#define PCO_INTERFACE_GIGE   5         // Gigabit Ethernet
#define PCO_INTERFACE_USB    6         // USB 2.0
#define PCO_INTERFACE_CL_ME4 7         // Cameralink Silicon Software Me4
#define PCO_INTERFACE_USB3   8         // USB 3.0 and USB 3.1 Gen1
#define PCO_INTERFACE_WLAN   9         // WLan (Only control path, not data path)
#define PCO_INTERFACE_CLHS  11         // Cameralink HS


//flags for type parameter of PCO_ScanCameras functions
//distinct interface types from above can be added to FLAG values
//e.g. searching for connected and unused USB Cameras will be
//type=PCO_SCAN_FLAG_UNUSED|PCO_SCAN_FLAG_CONNECTED|PCO_INTERFACE_USB;

#define PCO_SCAN_FLAG_ALL                  0x0000  //any camera
#define PCO_SCAN_FLAG_UNUSED               0x8000  //any unused camera
#define PCO_SCAN_FLAG_CONNECTED            0x4000  //any connected camera

#define PCO_SCAN_MASK_FLAGS                0xF000  //mask out flags
#define PCO_SCAN_MASK_INTERFACE            0x00FF  //mask out interface type


#define PCO_SCAN_FOR_UNUSED_AT_USB         0x8006  //any unused and connected camera on USB interface
#define PCO_SCAN_FOR_UNUSED_AT_USB3        0x8008  //any unused and connected camera on USB3 interface
#define PCO_SCAN_FOR_UNUSED_AT_ME4         0x8007  //any unused and connected camera on ME4  interface


#define PCODEVICE_STATUS_BITS_CONNECTED 0x00000001  // physical connection detected by interface
#define PCODEVICE_STATUS_BITS_LISTED    0x00000002  // device known, connection may be lost
#define PCODEVICE_STATUS_BITS_ATTACHED  0x00000004  // attached and owned by process
#define PCODEVICE_STATUS_BITS_OPENED    0x00000008  // open call to com / grab

#define PCODEVICE_STATUS_BITS_GRAB      0x00000010


/*PCO_OpenCameraSelect defines
//only connected and unused cameras are opened
#define PCO_SELECT_ALL_CAMERA      0xFFFF  //any unused camera on any interface type supported
#define PCO_SELECT_AT_INTERFACE    0xF000  //any unused camera on distinct interface supported
                                           //interface type must be added

#define PCO_SELECT_BY_ID           0x8001  //camera selected with id
#define PCO_SELECT_BY_SERIAL       0x8002  //camera selected with serial number
#define PCO_SELECT_BY_IPV4         0x8003  //camera selected with IPV4 address
#define PCO_SELECT_BY_IPV6         0x8004  //camera selected with IPV6 address
#define PCO_SELECT_BY_CTI          0x8005  //camera selected with genicam TL Dll

//param_type
//
#define PCO_PARAM_TYPE_UINT8        0x0001
#define PCO_PARAM_TYPE_UINT16       0x0002
#define PCO_PARAM_TYPE_UINT32       0x0004
#define PCO_PARAM_TYPE_UINT64       0x0008
#define PCO_PARAM_TYPE_ASCIISTRING  0x1000

#define PCO_PARAM_SIZE_UINT8        0x0001
#define PCO_PARAM_SIZE_UINT16       0x0002
#define PCO_PARAM_SIZE_UINT32       0x0004
#define PCO_PARAM_SIZE_UINT64       0x0008


*/

#pragma pack(push, 1)

typedef struct
{
  WORD struct_version;
  INT64 processid;
  DWORD status;                 // current camera status bit ored from above definition
  DWORD id;                     // ascending number or exchangeable
  DWORD SerialNumber;           // from camera (either get_camera_type or configuration)
  UINT64 ExtendedInfo;           // depends on Interface, e.g. IP Address
  WORD CameraType;             // from camera ( get_camera_type )
  WORD CameraSubType;          // from camera ( get_camera_type )
  WORD PCO_InterfaceType;      // from above definitions previously in SC2_SDKStructures used from sc2_cam.so
  char     CameraName[64];         // 0 terminated ascii string
  char     PCO_InterfaceName[64];  // 0 terminated ascii string
}PCO_Device;

#pragma pack(pop)

#endif
