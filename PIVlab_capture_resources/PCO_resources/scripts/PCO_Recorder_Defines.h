#ifndef PCO_RECORDER_DEFINES_H
#define PCO_RECORDER_DEFINES_H

//Filetypes for static file save functions
#define FILESAVE_IMAGE_BW_16                    "M_16"
#define FILESAVE_IMAGE_BW_8                     "M_08"
#define FILESAVE_IMAGE_COL_16                   "C_16"
#define FILESAVE_IMAGE_COL_8                    "C_08"
//=======================================================

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
