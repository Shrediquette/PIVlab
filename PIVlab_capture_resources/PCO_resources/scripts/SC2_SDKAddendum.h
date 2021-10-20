//-----------------------------------------------------------------//
// Name        | SC2_SDKAddendum.h           | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Visual 'C++'                                      //
//-----------------------------------------------------------------//
// Purpose     | PCO - SC2 Camera DLL Functions                    //
//-----------------------------------------------------------------//
// Author      | MBL, PCO AG                                       //
//-----------------------------------------------------------------//
// Revision    |  rev. 1.08 rel. 1.08                              //
//-----------------------------------------------------------------//

//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2002 PCO AG * Donaupark 11 *                                //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
// Revision History:                                               //
//-----------------------------------------------------------------//
// Rev.:     | Date:      | Changed:                               //
// --------- | ---------- | ---------------------------------------//
//  1.02     | 04.05.2004 | new file added to SDK, FRE, MBL        //
//           |            |                                        //
//-----------------------------------------------------------------//
//  1.04     | 16.06.2005 | some defines MBL                       //
//           |            |                                        //
//-----------------------------------------------------------------//
//  1.05     | 27.02.2006 |  Added PCO_GetCameraName, FRE          //
//-----------------------------------------------------------------//
//  1.06     | 29.09.2008 |  Added PCO_GIGE_TRANSFER_PARAM, FRE    //
//-----------------------------------------------------------------//
//  1.07     | 23.11.2011 |  Added IMAGE_TRANSFER_MODE_PARAM, VTI  //
//-----------------------------------------------------------------//
//  1.08     | 26.07.2017 |  Added DISCOVERY_ACK, VTI              //
//-----------------------------------------------------------------//

#if !defined SC2_SDKADDENDUM_H
#define SC2_SDKADDENDUM_H

typedef struct _PCO1394_ISO_PARAMS
{
  DWORD  bandwidth_bytes;         // number of byte to allocate on the bus for isochronous transfers
                                  // 0...4096; recommended: 2048 (default 4096)
  DWORD  speed_of_isotransfer;    // speed to use when allocating bandwidth
                                  // 1,2,4; recommended: 4 (default 4)
  DWORD  number_of_isochannel;    // number of channel to use on the bus
                                  // 0...7 + additional bits (default AUTO_CHANNEL)
  DWORD  number_of_iso_buffers;   // number of buffers to use when allocating transfer resources
                                  // depends on image size, auto adjusted from the driver
                                  // 16...256; recommended: 32 (default 32)
  DWORD  byte_per_isoframe;       // 0...4096; information only
}PCO1394_ISO_PARAM;

#define PCO_1394_AUTO_CHANNEL   0x200
#define PCO_1394_HOLD_CHANNEL   0x100

#define PCO_1394_DEFAULT_BANDWIDTH 4096
#define PCO_1394_DEFAULT_SPEED 4
#define PCO_1394_DEFAULT_CHANNEL 0x00
#define PCO_1394_DEFAULT_ISOBUFFER 32

typedef struct _PCO_1394_TRANSFER_PARAM
{
   PCO1394_ISO_PARAM iso_param;
   DWORD bytes_avaiable;       //bytes avaiable on the bus 
   DWORD dummy[15];            //for future use, set to zero
}PCO_1394_TRANSFER_PARAM;


typedef struct _PCO_SC2_CL_TRANSFER_PARAMS
{
  DWORD  baudrate;         // serial baudrate: 9600, 19200, 38400, 56400, 115200
  DWORD  ClockFrequency;   // Pixelclock in Hz: 40000000,66000000,80000000
  DWORD  CCline;           // Usage of CameraLink CC1-CC4 lines, use value returned by Get 
  DWORD  DataFormat;       // see defines below, use value returned by Get
  DWORD  Transmit;         // single or continuous transmitting images, 0-single, 1-continuous
}PCO_SC2_CL_TRANSFER_PARAM;

#define PCO_CL_DEFAULT_BAUDRATE 9600
#define PCO_CL_PIXELCLOCK_40MHZ 40000000
#define PCO_CL_PIXELCLOCK_66MHZ 66000000
#define PCO_CL_PIXELCLOCK_80MHZ 80000000
#define PCO_CL_PIXELCLOCK_32MHZ 32000000
#define PCO_CL_PIXELCLOCK_64MHZ 64000000

#define PCO_CL_CCLINE_LINE1_TRIGGER           0x01
#define PCO_CL_CCLINE_LINE2_ACQUIRE           0x02
#define PCO_CL_CCLINE_LINE3_HANDSHAKE         0x04
#define PCO_CL_CCLINE_LINE4_TRANSMIT_ENABLE   0x08

#define PCO_CL_DATAFORMAT_MASK   0x0F
#define PCO_CL_DATAFORMAT_1x16   0x01
#define PCO_CL_DATAFORMAT_2x12   0x02
#define PCO_CL_DATAFORMAT_3x8    0x03
#define PCO_CL_DATAFORMAT_4x16   0x04
#define PCO_CL_DATAFORMAT_5x16   0x05
#define PCO_CL_DATAFORMAT_5x12   0x07     //extract data to 12bit
#define PCO_CL_DATAFORMAT_10x8   0x08
#define PCO_CL_DATAFORMAT_5x12L  0x09     //extract data to 16Bit
#define PCO_CL_DATAFORMAT_5x12R  0x0A     //without extract


#define SCCMOS_FORMAT_MASK                                        0xFF00
#define SCCMOS_FORMAT_TOP_BOTTOM                                  0x0000  //Mode E 
#define SCCMOS_FORMAT_TOP_CENTER_BOTTOM_CENTER                    0x0100  //Mode A
#define SCCMOS_FORMAT_CENTER_TOP_CENTER_BOTTOM                    0x0200  //Mode B
#define SCCMOS_FORMAT_CENTER_TOP_BOTTOM_CENTER                    0x0300  //Mode C
#define SCCMOS_FORMAT_TOP_CENTER_CENTER_BOTTOM                    0x0400  //Mode D 

#define PCO_CL_TRANSMIT_ENABLE  0x01
#define PCO_CL_TRANSMIT_LONGGAP 0x02


typedef struct _PCO_USB_TRANSFER_PARAM {
  unsigned int  MaxNumUsb;           // defines packet size 
  unsigned int  ClockFrequency;      // Pixelclock in Hz: 40000000,66000000,80000000
  unsigned int  Transmit;            // single or continuous transmitting images, 0-single, 1-continuous
  unsigned int  UsbConfig;           // 0=bulk_image, 1=iso_image
  unsigned int  ImgTransMode;        // Bit0: 14Bit Image
                                     // Bit1: 12Bit Image (obsolete)
                                     // Bit2: VTI coding enabled
                                     // Bit3: 1024Byte padding enabled
}PCO_USB_TRANSFER_PARAM;

typedef struct _PCO_USB3_TRANSFER_PARAM {
  unsigned int  uiFlags;             // Bit0: 0: USB 3.0 connection is used to connect camera to the PC (recommended)
                                     //       1: USB 2.0 connection is used to connect camera to the PC
                                     // Bit1..31: reserved
  unsigned int  MaxNumUsb;           // defines packet size 
}PCO_USB3_TRANSFER_PARAM;

#define PCO_GIGE_PAKET_RESEND     0x00000001
//#define PCO_GIGE_BURST_MODE      0x00000002   !!! obsolete (22.06.2017) !!!
//#define PCO_GIGE_MAXSPEED_MODE   0x00000004   !!! obsolete (22.06.2017) !!!
//#define PCO_GIGE_DEBUG_MODE      0x00000008   !!! obsolete (22.06.2017) !!!
//#define PCO_GIGE_BW_SAME2ALL     0x00000000   !!! obsolete (22.06.2017) !!!
//#define PCO_GIGE_BW_ALL2MAX      0x00000010   !!! obsolete (22.06.2017) !!!
#define PCO_GIGE_CAM_SYNC         0x00000010
//#define PCO_GIGE_BW_2ACTIVE      0x00000020   !!! obsolete (22.06.2017) !!!
#define PCO_GIGE_DATAFORMAT_1x8   0x01080001
#define PCO_GIGE_DATAFORMAT_1x16  0x01100007
#define PCO_GIGE_DATAFORMAT_3x8   0x02180015
#define PCO_GIGE_DATAFORMAT_4x8   0x02200016

typedef struct _PCO_GIGE_TRANSFER_PARAM
{
  DWORD  dwPacketDelay;       // delay between image stream packets (number of clockticks of a 100MHz clock;
                              // default: 2000 -> 20us, range: 0 ... 8000 -> 0 ... 80us)
  DWORD  dwResendPercent;     // Number of lost packets of image in percent. If more packets got lost,
                              // complete image will be resent or image transfer is failed (default 30).
  DWORD  dwFlags;             // Bit 0:   Set to enable packet resend
                              // Bit 1:   !!! obsolete (22.06.2017) !!!: Set to enable Burst_mode
                              // Bit 2:   !!! obsolete (22.06.2017) !!!: Set to enable Max Speed Modus
                              // Bit 3:   !!! obsolete (22.06.2017) !!!: Set to enable Camera Debug Mode
                              // Bit 4:   camera Sync Mutex
                              // Bit 5:   Enable Jumbo Frames
                              // Bit 6:   Enable Intermediate Driver
                              // Bit 8-31: Reserved
                              // (LSB; default 0x00000001).      
  DWORD  dwDataFormat;        // DataFormat: default:  0x01100007
                              // supported types:  Mono, 8Bit:  0x01080001
                              //                   Mono, 16Bit: 0x01100007
                              //                   RGB,  24Bit: 0x02180015  (R=G=B=8Bit)
                              //                   RGB,  32Bit: 0x02200016  (R=G=B=a=8Bit)
  DWORD  dwCameraIPAddress;   // Current Ip Address of the Camera
                              //  (can not be changed with Set_Transfer_Param() routine )
  DWORD  dwUDPImgPcktSize;    // Size of an UDP Image packet
                              //  (can not be changed with Set_Transfer_Param() routine )
  UINT64 ui64MACAddress;      // Settings are attached to this interface
}PCO_GIGE_TRANSFER_PARAM; 


typedef struct _IMAGE_TRANSFER_MODE_PARAM
{
  WORD  wSize;                // size of this struct
  WORD  wMode;                // transfer mode, e.g. full, scaled, cutout etc.
  WORD  wImageWidth;          // original image width
  WORD  wImageHeight;         // original image height
  WORD  wTxWidth;             // width of transferred image (scaled or cutout)
  WORD  wTxHeight;            // width of transferred image (scaled or cutout)
  WORD  wParam[8];            // params, meaning depends on selected mode else set to zero
  WORD  ZZwDummy[10];         // for future use, set to zero
} IMAGE_TRANSFER_MODE_PARAM;

//Gige Vision Acknowledge Message Header
typedef struct _GVCP_ACK_HEADER
{
  WORD  Status;
  WORD  Acknowledge;
  WORD  Length;
  WORD  AckID;
}GVCP_ACK_HEADER;

//Gige Vision Discovery Acknowledge Message
typedef struct _DISCOVERY_ACK
{
  GVCP_ACK_HEADER AckHeader;  //Gige Vision Header
  WORD   SpecVersionMajor;    //Gige Vision Version Major
  WORD   SpecVersionMinor;    //Gige Vision Version Minor
  DWORD  DeviceMode;          //Gige Vision Device Mode
  WORD   NicId;               //PCO Network Interface Card Identifier
  WORD   DeviceMACHigh;       //Gige Vision Camera MAC Address High
  DWORD  DeviceMACLow;        //Gige Vision Camera MAC Address Low
  DWORD  IPConfigOptions;     //Gige Vision Ip Config Options
  DWORD  IPConfigCurrent;     //Gige Vision Ip Config Current
  DWORD  ValidConnection;     //PCO Connection Status: 0x0 invalid, 0x1 valid
  DWORD  AccessAllowed;       //PCO Camera Access Status: 0x0 no access, 0x1 access allowed
  DWORD  NICIp;               //PCO Network Interface Card Ip Address
  DWORD  CurrentIP;           //Gige Vision Camera Ip Address
  DWORD  CameraType;          //PCO Camera Type (available with Gige Camera IF V1.04 or higher)
  DWORD  CameraSubType;       //PCO Camera Type (available with Gige Camera IF V1.04 or higher)
  DWORD  NICSubnetMask;       //PCO Network Interface Card Subnet Mask
  DWORD  CurrentSubnetMask;   //Gige Vision Camera Subnet Mask
  DWORD  RFU1;                //changed to reserved from HWVersion @26.07.2017 VTI
  DWORD  RFU2;                //changed to reserved from FWVersion @26.07.2017 VTI
  DWORD  CameraSerialNumber;  //PCO Camera S/N (available with Gige Camera IF V1.04 or higher)
  DWORD  DefaultGateway;      //Gige Vision Camera Gateway
  BYTE   ManufacturerName[32];//Gige Vision Manufacturer Name in ASCII
  BYTE   ModelName[32];       //Gige Vision Camera Model Name in ASCII
  BYTE   DeviceVersion[32];   //Gige Vision Camera Version
  BYTE   ManufacSpecInfo[48]; //Gige Vision Manufacturer Specific Information
  BYTE   SerialNumber[16];    //Gige Vision Camera Interface S/N
  BYTE   UserDefinedName[16]; //Gige Vision User Defined Name
}DISCOVERY_ACK;

typedef struct _PCO_CLHS_TRANSFER_PARAMS
{
   DWORD   DataFormat;       // see defines below, use value returned by Get
   DWORD   Transmit;         // single or continuous transmitting images, 0-single, 1-continuous
                             // additional action flags for Global_shutter edge Hotpixel and dark image
}PCO_CLHS_TRANSFER_PARAM;

#define PCO_CLHS_DATAFORMAT_1x16 0x0000
#define PCO_CLHS_DATAFORMAT_1x8  0x0001
#define PCO_CLHS_DATAFORMAT_10P  0x0100
#define PCO_CLHS_DATAFORMAT_12P  0x0101
#define PCO_CLHS_DATAFORMAT_14P  0x0102




//loglevels for interface dll
#define ERROR_M     0x0001
#define INIT_M      0x0002
#define BUFFER_M    0x0004
#define PROCESS_M   0x0008

#define COC_M       0x0010
#define INFO_M      0x0020
#define COMMAND_M   0x0040

#define PCI_M       0x0080

#define TIME_M      0x1000 
#define TIME_MD     0x2000 
#define THREAD_ID   0x4000 
#define CPU_ID      0x8000           // not on XP

#endif
