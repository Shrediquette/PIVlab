---
title: OPTOcam 2/80
order: 2
image: /assets/images/cameras/optocam-2-80.jpg
summary: USB 3.0 camera from OPTOLUTION, driven via the Basler pylon software.
description: Set up the OPTOcam 2/80 camera for PIV image acquisition in PIVlab (standalone app and MATLAB toolbox) - driver installation and connection.
connection: USB 3.0
software: Basler pylon
config: PIVlab LD-PS + OPTOcam 2/80
keywords: optocam 2/80 basler pylon dart genicam gentl usb3 stereo
---
Two OPTOcam 2/80 can be combined for [stereo-PIV](/wiki/7-stereo-piv/) (from PIVlab 4.0): tick **Stereo** in the image acquisition panel.

## 1. Install the software

<!-- switch: edition -->

### Standalone app

1. {% include steps/pylon.md %}

### MATLAB toolbox

1. {% include steps/iat.md %}
2. {% include steps/pylon.md %}
3. {% include steps/genicam.md %}

## 2. Connect the camera

1. Plug the camera into a USB 3.0 port of the computer.

{% include steps/usb-hint.md %}

## 3. Start capturing

1. Start PIVlab and open the image acquisition panel.
2. Select the configuration **PIVlab LD-PS + OPTOcam 2/80**.
3. Start your PIV recordings.
