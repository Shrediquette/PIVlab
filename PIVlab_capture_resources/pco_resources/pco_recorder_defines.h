#ifndef PCO_RECORDER_DEFINES_H
#define PCO_RECORDER_DEFINES_H

//Filetypes for static file save functions
#define FILESAVE_IMAGE_BW_8                     "M_08"  //Mono8  (8 Bit)
#define FILESAVE_IMAGE_BW_16                    "M_16"  //Mono16 (16 Bit)
#define FILESAVE_IMAGE_BGR_8                    "C_08"  //RGB    (24 Bit)
#define FILESAVE_IMAGE_BGRA_8                   "C_08_A" //BGRA   (32 Bit)
#define FILESAVE_IMAGE_BGR_16                   "C_16"  //BGR16  (48 Bit)
//=======================================================

//Masks for recorde mode and mode flags
#define PCO_RECORDER_MODE_MASK                  0x00FF
#define PCO_RECORDER_MODE_FLAG_MASK             0xFF00

//Flag for using DotPhoton Compression
//Only valid for Memory and Camram, will be ignored for file mode
#define PCO_RECORDER_MODE_USE_DPCORE            0x1000

//Flag for enabling the multi image request
//Only for usb3 cameras and only for mode memory
#define PCO_RECORDER_USE_USB3_MULTIREQUEST      0x2000

// Only valid for File Mode and double image set
#define PCO_RECORDER_DOUBLEIMG_SPLIT            0x8000
// Splits double image in two sequentials streams for multi file modes
#define PCO_RECORDER_DOUBLEIMG_SPLIT_SEQUENCE   0xC000 // 0x8000 | 0x4000

//Recorder Mode
#define PCO_RECORDER_MODE_FILE                  0x0001
#define PCO_RECORDER_MODE_MEMORY                0x0002
#define PCO_RECORDER_MODE_CAMRAM                0x0003

//Memory Type
#define PCO_RECORDER_MEMORY_SEQUENCE            0x0001
#define PCO_RECORDER_MEMORY_RINGBUF             0x0002
#define PCO_RECORDER_MEMORY_FIFO                0x0003

//File Type
#define PCO_RECORDER_FILE_TIF                   0x0001
#define PCO_RECORDER_FILE_MULTITIF              0x0002
#define PCO_RECORDER_FILE_PCORAW                0x0003
#define PCO_RECORDER_FILE_B16                   0x0004
#define PCO_RECORDER_FILE_DICOM                 0x0005
#define PCO_RECORDER_FILE_MULTIDICOM            0x0006

//CamRam Type
#define PCO_RECORDER_CAMRAM_SEQUENTIAL          0x0001
#define PCO_RECORDER_CAMRAM_SINGLE_IMAGE        0x0002

//Image Readout
#define PCO_RECORDER_LATEST_IMAGE               0xFFFFFFFF

//Auto Exposure Regions
#define REGION_TYPE_BALANCED                    0x0000
#define REGION_TYPE_CENTER_BASED                0x0001
#define REGION_TYPE_CORNER_BASED                0x0002
#define REGION_TYPE_FULL                        0x0003
#define REGION_TYPE_CUSTOM                      0x0004

typedef struct
{
  double dGainK;                   // System Gain K in DN/e (= 1/conversion factor)
  double dDarkNoise_e;             // Temporal dark noise in electrons (= RMS readout noise)
  double dDSNU_e;                  // DSNU in electrons
  double dPRNU_pct;                // PRNU in percent

  double dLightSourceNoise_pct;    // RMS intensity noise of the light source (set to 0 if not known or negligible)
}
PCO_Recorder_CompressionParams;

#endif // PCO_RECORDER_DEFINES_H
