---
title: pco cameras
order: 3
image: /assets/images/cameras/pco.jpg
summary: pco.panda 26 DS (USB 3.0), pco.pixelfly 1.4 DS (USB 2.0) and pco.edge 26 DS (CLHS frame grabber).
description: Set up pco.panda, pco.pixelfly and pco.edge cameras for PIV image acquisition in PIVlab (standalone app and MATLAB toolbox).
models: [pco.panda 26 DS USB, pco.pixelfly 1.4 DS USB, pco.edge 26 DS CLHS]
connection: USB 3.0 / USB 2.0 / CLHS
software: pco interface drivers
config: PIVlab LD-PS + pco.panda 26 DS / pco.pixelfly usb / pco.edge 26 DS CLHS
keywords: pco excelitas panda pixelfly edge clhs kaya camware pco.matlab sdk
---
## 1. Install the software

<!-- switch: edition -->

### Standalone app

1. {% include steps/pco-drivers.md %}

### MATLAB toolbox

1. Install [pco camware](https://www.excelitas.com/product/pco-camera-control-software).
2. Install [pco.matlab](https://www.excelitas.com/product/pco-software-development-kits).
3. {% include steps/pco-drivers.md %}
4. Install the [MATLAB Support for MinGW-w64 C/C++ Compiler](https://www.mathworks.com/matlabcentral/fileexchange/52848-matlab-support-for-mingw-w64-c-c-compiler).
5. Open the pco.matlab folder (typically `C:\Program Files\PCO Digital Camera Toolbox\pco.matlab`) and run `scripts\setup_files.m` in MATLAB.
6. Add the pco.matlab folder to the MATLAB path permanently: **Home** tab → **Set Path** → **Add with Subfolders…**, select the pco.matlab folder, then **Save** and **Close**.
7. After connecting the camera (next step), run `pco_camera_info.m` from the `pco.matlab\scripts` folder. It shows information about your camera.

## 2. Connect the camera

1. Plug in the camera and insert the connector fully. On the panda, tighten the screws of the USB plug; on the edge, gently wiggle the plug until it sits firmly. A loose plug is the most common reason why a pco camera is not found.

> **For full speed:** connect the panda directly to a USB 3.0 port, not through a USB hub. Laptops should run on their power supply, because some save energy by limiting USB / CLHS bandwidth on battery.

## 3. Start capturing

1. Start PIVlab and open the image acquisition panel.
2. Select the configuration for your camera, for example **PIVlab LD-PS + pco.panda 26 DS**.
3. Start your PIV recordings.

The pco.edge 26 DS CLHS records into the computer's RAM first. PIVlab suggests this setting when you start a recording.
