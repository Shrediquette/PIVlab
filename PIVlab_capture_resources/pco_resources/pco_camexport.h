//-----------------------------------------------------------------//
// Name        | PCO_CamExport.h             | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Purpose     | PCO - SC2 Camera exported Functions               //
//-----------------------------------------------------------------//
// Author      | FRE, Excelitas PCO GmbH, Kelheim, Germany         //
//-----------------------------------------------------------------//
// Notes       | Some functions are illustrated with an example    //
//             | source code. If the function you need doesn't     //
//             | have some source code sample, please take a look  //
//             | on other functions supplied with source code. You //
//             | will find some useful code there and you will be  //
//             | able to adapt the code to the function you need.  //
//             |                                                   //
//             | To get informations about the ranges of the       //
//             | data values please take a look at the SDK docu.   //
//-----------------------------------------------------------------//
// (c) 2021 Excelitas PCO GmbH * Donaupark 11 *                    //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: pco@excelitas.com           //
//-----------------------------------------------------------------//



#if defined _WIN32
 #ifdef SC2_CAM_EXPORTS
  #if defined _WIN64
   #define SC2_SDK_FUNC
  #else
   #define SC2_SDK_FUNC __declspec(dllexport)
  #endif
 #else
  #define SC2_SDK_FUNC __declspec(dllimport)
 #endif
#endif

#ifdef PCO_LINUX
 #define SC2_SDK_FUNC
 #define WINAPI
#endif

#ifdef __cplusplus
extern "C" {                           //  Assume C declarations for C++
#endif  //C++


// use case: scan any or explicit interface for any or unused cameras
// see defines in PCO_Devices.h

/// \brief Scan any or explicit interface for any or unused cameras
/// \anchor PCO_ScanCameras
/// \param if_type defines scanning parameters see defines in PCO_Devices.h
/// \param device_count pointer to a WORD variable, which receive count of according PCO_DEVICE structures.
/// \param device_array array which is filled with according PCO_DEVICE structures
/// - Can be NULL on input. Than only device_count is returned.
/// \param array_size Length of the device_array in bytes ( sizeof(PCO_DEVICE)*count ).
/// If more devices are found as fit into the array only array is filled only upto possible numbers
/// \return Error code or PCO_NOERROR on success
///
SC2_SDK_FUNC int WINAPI PCO_ScanCameras(WORD type,WORD *device_count, PCO_Device* device_array, UINT64 array_size);


/// \brief get PCO_Device structure with id 
/// \anchor PCO_ScanCameras
/// \param device reference to PCO_Device structure
/// \param id valid id from structure PCO_Device
/// \return Error code or PCO_NOERROR on success
///
SC2_SDK_FUNC int WINAPI PCO_GetCameraDeviceStruct(PCO_Device* device, WORD id);


/// \brief Open camera object
/// \anchor PCO_OpenNextCamera
/// Opens camera object.
/// Initialize camera
/// - camhandle must be NULL on input to open next vacant camera
/// - if camhandle is a valid handle reinitialize this camera
/// \param camhandle pointer to handle to receive the camera object handle
/// NULL or previously retrieved camera object handle
/// if open succeeds a valid camera object handle is returned
/// \return Error code or PCO_NOERROR on success
///
SC2_SDK_FUNC int WINAPI PCO_OpenNextCamera(HANDLE *camhandle);


/// \brief Open camera object with id from scan
/// \anchor PCO_OpenCameraDevice
/// Opens a camera object.
/// Initialize camera
/// - camhandle must be NULL on input to open a camera, which is not already used.
/// - if camhandle is a valid handle reinitialize this camera
/// \param camhandle pointer to handle to receive the camera object handle
/// NULL or previously retrieved camera object handle
/// if open succeeds a valid camera object handle is returned
/// \param id valid id from one of the PCO_Device structures, returned from PCO_ScanCamera
/// \return Error code or PCO_NOERROR on success
///
SC2_SDK_FUNC int WINAPI PCO_OpenCameraDevice(HANDLE *camhandle, WORD id);

/// \brief Get Device Id from opened camera
/// \anchor PCO_GetCameraDeviceId
/// Get Device Id from opened camera object.
/// \param ph Handle to a previously opened camera
/// \param id Pointer to WORD varaiable to receive the id for the camera object
/// \return Error code or PCO_NOERROR on success
///
SC2_SDK_FUNC int WINAPI PCO_GetCameraDeviceId(HANDLE ph, WORD *id);



/// \brief Adds an external image buffer to the driver queue and return immediately. Callback function is called, when image is in buffeer
/// \anchor PCO_AddBufferExtern_CB
/// The images will be transferred to a previously allocated buffer addressed by the sBufNr.
/// This buffer has to be big enough to hold all the requested images.
/// In case of additional metadata, the user has to take care for the correct buffer size.
/// The function uses an internal Callback function
/// \param ph Handle to a previously opened camera
/// \param dw1stImage variable to hold the image number of the first image to be retrieved
///                   This value has to be set to 0, if you are running in preview mode.
/// \param dwLastImage variable to hold the image number of the last image to be retrieved
///                   This value has to be set to 0, if you are running in preview mode.
/// \param dwSynch variable to hold synchronization parameter
/// \param pBuf pointer to image buffer
/// \param dwLen size of buffer pBuf in bytes
/// \param userfunc callback function 
/// \param void* userdata, which is forwarded to callback function
/// \return Error code or PCO_NOERROR on success
///
SC2_SDK_FUNC int WINAPI PCO_AddBufferExtern_CB(HANDLE ph,WORD wSegment, DWORD dwFirstImage,DWORD dwLastImage, DWORD dwSynch,
                                               void* pBuf, DWORD dwLen,pco_image_done_cb_fn userfunc,void* userdata);

/// \brief Wait for next buffer from driver queue. Buffer has been added with PCO_AddBufferEx()
/// \anchor WaitforNextBufferNum
/// The images will be transferred to a previously allocated buffer addressed by the sBufNr.
/// \param ph Handle to a previously opened camera
/// \param sBufNr pointer to SHORT variable to receive the buffer number of this buffer.
/// \param timeoute imeout in milliseconds 
/// \return Error code or PCO_NOERROR on success
SC2_SDK_FUNC int WINAPI PCO_WaitforNextBufferNum(HANDLE ph,SHORT* sBufNr,int timeout);

/// \brief Wait for next buffer from driver queue. Buffer has been added with PCO_AddBufferExtern()
/// \anchor WaitforNextBufferNum
/// The images will be transferred to a previously allocated buffer addressed by the sBufNr.
/// \param ph Handle to a previously opened camera
/// \param BufferAddress pointer to void pointer to receive the buffer address of this buffer.
/// \param timeoute imeout in milliseconds 
/// \return Error code or PCO_NOERROR on success
SC2_SDK_FUNC int WINAPI PCO_WaitforNextBufferAdr(HANDLE ph,void** BufferAddress,int timeout);

#ifdef __cplusplus
}       //  Assume C declarations for C++
#endif  //C++
