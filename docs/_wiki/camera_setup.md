---
layout: default
title: Camera Setup
permalink: /PIVlab/wiki/camera-setup
---
# Setting up the OPTOcam camera
*   The OPTOcam requires the [image acquisition toolbox from Mathworks](https://de.mathworks.com/products/image-acquisition.html). This is included in many Matlab licenses from universities.
*   Furthermore, you need to install the "pylon camera software suite", which is available here ([link to the basler software website](https://www2.baslerweb.com/de/downloads/downloads-software/#type=pylonsoftware;language=all;version=all;series=baslerdart;model=all)).
*   Then, you need to install the [Image Acquisition Toolbox Support Package for GenICam Interface](https://de.mathworks.com/matlabcentral/fileexchange/45180-image-acquisition-toolbox-support-package-for-genicam-interface?s_tid=srchtitle).

When this is finished, start PIVlab with the camera plugged into a USB3.0 port **(do NOT use a USB hub! The camera needs the full bandwith of the USB port)**, select the suitable configurations (e.g. "PIVlab LD-PS + OPTOcam 2/80), and start your PIV analyses!

# Setting up pco cameras (panda and pixelfly)
## Instructions for PIVlab version >= 3.07 (for older versions, see below)
1. Install pco camware: https://www.excelitas.com/product/pco-camera-control-software
2. Install pco.matlab: https://www.excelitas.com/product/pco-software-development-kits
3. Install the PCO USB 3.0 Interface Driver for the panda camera, or the 2.0 Driver for the pixelfly: https://www.excelitas.com/product/pco-interface-drivers
4. Download and install Matlab Compiler: https://de.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-compiler
5. Open the folder of the pco.matlab installation from step 2 (typically in "C:\Program Files\PCO Digital Camera Toolbox\pco.matlab"), and run pco.matlab\scripts\setup_files.m in Matlab
6. In Matlab, add the pco.matlab folder to the search path permanently: Click on the "Home" tab, then "Set Path", then "Add with subfolders". Select the pco.matlab folder, then click "Save", then "Close".
7. Plug in your pco camera **(do NOT use a USB hub! The camera needs the full bandwith of the USB port)**. Please take care to fully insert (fully tighten the two screws!) the USB cable in the camera.
8. Run pco_camera_info.m in the pco.matlab\scripts folder to see information about your pco camera. This should run without errors.
   Done. You can now use your pco camera in the PIVlab_GUI.

## Instructions for PIVlab until version 3.06
1. Install pco camware: https://www.excelitas.com/product/pco-camera-control-software
2. Install pco.matlab: https://www.excelitas.com/product/pco-software-development-kits
3. Install the PCO USB 3.0 Interface Driver for the panda camera, or the 2.0 Driver for the pixelfly: https://www.excelitas.com/product/pco-interface-drivers
4. Download and install Matlab Compiler: https://de.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-compiler
5. Navigate to your PIVlab installation. The folder depends on how you installed PIVlab:
* If you installed the mltbx file, then, on the MATLAB® Home tab, in the Environment section, click Add-Ons > Manage Add-ons. Then click on the three vertical dots and choose "Open Folder". If PIVlab appears twice in this list, you will have to do the following steps for all of these entries.
* If you just downloaded and unzipped the zip archive, then navigate to the destination folder you chose.
6. Open the folder of the pco.matlab installation from step 2, and run pco.matlab\scripts\setup_files.m in Matlab
7. Now copy all the contents of folder "scripts" **_except_** pco_camera_open_close.m and pco_camera_subfunction.m to "PIVlab\PIVlab_capture_resources\PCO_resources\scripts in the PIVlab folder you located in step 4.
8. Plug in your pco camera **(do NOT use a USB hub! The camera needs the full bandwith of the USB port)**. Please take care to fully insert (tighten the two screws!) the USB cable in the camera.
9. Run pco_camera_info.m in the scripts folder to see information about your pco camera. This should run without errors.
   Done. You can now use your pco camera in the PIVlab_GUI.

# Setting up OPTRONIS cameras
1. The following OPTRONIS cameras are supported:
* [Cyclone-25-150-M](https://optronis.com/produkte/cyclone-25-150/)
* [Cyclone-1HS-3500-M](https://optronis.com/produkte/cyclone-1hs-3500/)
* [Cyclone-2-2000-M](https://optronis.com/produkte/cyclone-2-2000/)

2. They need to be connected via a PCIe frame grabber to a PC [(Euresys Coaxlink Quad CXP-12)](https://www.euresys.com/de/Products/Frame-Grabbers/Coaxlink-series/Coaxlink-Quad-CXP-12). The PC must have a PCIe 3.0 (Gen 3) x8 slot.

3. The cameras require the [image acquisition toolbox from Mathworks](https://de.mathworks.com/products/image-acquisition.html). This is included in many Matlab licenses from universities.

4. Furthermore, you need to install the EGRABBER FOR COAXLINK from Euresys. Get the latest release from their website (at the time of writing, the latest release is egrabber-win10-x86_64-24.04.0.2.exe):

[https://www.euresys.com/de/Support/Download-area?Series=e1bb72b9-60d9-4d17-aa17-daef9c856322&lang=de-DE](https://www.euresys.com/de/Support/Download-area?Series=e1bb72b9-60d9-4d17-aa17-daef9c856322&lang=de-DE)

5. Then, you need to install the [Image Acquisition Toolbox Support Package for GenICam Interface](https://de.mathworks.com/matlabcentral/fileexchange/45180-image-acquisition-toolbox-support-package-for-genicam-interface?s_tid=srchtitle).

6. The framegrabber firmware needs to be "1-camera". _**If you bought your camera and framegrabber from OPTOLUTION, then this is already verified.**_

7. The camera also needs to be **set to external triggering permanently**. How this is done is shown below.

8. Connect the camera to the frame grabber using the four coaxial cables. You need to connect them in the right order: 1-A, 2-B, 3-C, 4-D. Don't forget to connect the trigger cable (Aux. port on the OPTRONIS, “Sync in”) to the laser or synchronizer.

9. Power your camera with the supplied power supply (or directly via Coaxpress).

10. All four lights on the back of the OPTRONIS need to be solid green.

11. When this is finished, start PIVlab and select the suitable configuration ("PIVlab LD-PS + OPTRONIS) in the image acquisition menu. The exact camera model will be detected automatically.

12. Connect to the laser / synchronizer in PIVlab.

13. Keep in mind that these high-speed cameras transfer enormous amounts of data. In PIVlab, image data is captured into RAM before it is saved to disk (otherwise most hard disks, even SSD's, can't keep up with the data rate). With a Cyclone-2-2000-M camera, you can capture approximately the following amount of 8-bit double images:
* 16 GB RAM: 1300 double images
* 32 GB RAM: 3400 double images
* 64 GB RAM: 7500 double images

14. PIVlab throws a warning before capturing when you selected too many images, and the corresponding edit field in the GUI becomes orange.

15. Also keep in mind that you need a fast SSD to write data from RAM in a reasonable time. And the SSD should also be large enough!

## Configuration in eGrabber Studio
![](https://github.com/Shrediquette/PIVlab/blob/main/images/Optronis_setup_1.JPG)
![](https://github.com/Shrediquette/PIVlab/blob/main/images/Optronis_setup_2.JPG)
![](https://github.com/Shrediquette/PIVlab/blob/main/images/Optronis_setup_3.JPG)
![](https://github.com/Shrediquette/PIVlab/blob/main/images/Optronis_setup_4.JPG)
![](https://github.com/Shrediquette/PIVlab/blob/main/images/Optronis_setup_5.JPG)
When this is done, power cycle the camera and click the refresh button:
![](https://github.com/Shrediquette/PIVlab/blob/main/images/Optronis_setup_6.JPG)
Verify that the changed settings have been accepted and didn’t change after the power cycle.

# Setting up the Krontech Chronos cameras
Here is some information about using the Chronos cameras in PIVlab. I have tested the Chronos 1.4, but not the 2.1. The Chronos 2.1 should work too.
## Chronos limitations
Unfortunately, there are some limitations of the Chronos, and it is also pretty hard to get support from the manufacturers.
The camera is very nice and extremely affordable, but this also introduces some hick-ups in the Chronos Firmware.

* Firmware 0.5.1 seems most stable and doesn't skip frames in the middle of a recording
* Disable "Debounce" in the "IO1 BNC" panel on the Chronos "Trigger I/O" Menu
* Click "Setup" in PIVlab Image acquisition panel and enter the IP address of the chronos like this: 192.168.254.100
* The resolutions entered here must be accepted by the camera. Not every resolution is accepted by the Chronos. e.g.  1280x720 and 1280x1024 is ok.
* Data transfer from Chronos RAM to SD card or SMB shared drive is slow.
* Tiff raw is the recommended file format although it is slow to save.
* H264 is much faster, but gives worse results.
* Stripes in image? Cover lens. Go to "Util" -> "Factory" -> "Black calibrate all resolutions" on the Chronos touchscreen
* Still stripes? Set camera to desired resolution, then goto main screen -> "Black cal" on the Chronos touchscreen (always cover the lens).
* Still stripes? Then go to "Record settings" on the Chronos, click the two "max" buttons and then "OK".
* Sometimes it also helps to change resolution to remove the stripes.
* A frame rate of 1000 fps is not possible on the Chronos when using an external trigger. In order to use 1000 fps, you need to slightly reduce the resolution to something like 1280x720. I have no clue why this is the case.
* In many cases, the Chronos will not properly shut down when you press the power button. A long press will force the camera to shut down. This seems to happen whenever the camera is configured to be triggered externally. You could circumvent this by initiating the live preview from PIVlab before you power the camera off.
* When powering the camera on, it is sometimes not clear if the camera is booting or if it hangs. Powering up the camera takes some time, so you may need to wait between 30s and a minute.
## General tips
* I am using a VONETS VAP11s mini router connected to the Chronos. Then I can connect to the WiFi network of the Vonets and access the Chronos wirelessly.
* Use PIVlab to toggle between live image preview or PIV capture mode.
* In many cases, I am not enabling the "save" checkbox in the "Capture PIV images" panel in PIVlab. As soon as you click "Start" in the "Capture PIV images" panel, the chronos will capture images synced to the laser and will save them to the RAM ringbuffer, also when this checkbox is not enabled. You can stop the recording by pressing "Abort" in PIVlab.
* You might then use the Chronos Webinterface to save data to SD or SSD or SMB of the camera. This webinterface seems pretty handy to review, select and save the desired frames.
* You can of ourse also use the touchscreen of the camera to review, select and save the desired frames.
* Always make sure that you verify that image A and B are not confused. Sometimes, the Chronos skips the very first frame, resulting in an incorrect frame-straddling sequence!