---
title: OPTOcam 20/9
order: 1
image: /assets/images/cameras/optocam-20-9.jpg
summary: USB 3.0 camera from OPTOLUTION, driven via Balluff Impact Acquire.
description: Set up the OPTOcam 20/9 camera for PIV image acquisition in PIVlab (standalone app and MATLAB toolbox) - driver installation and connection.
connection: USB 3.0
software: Balluff Impact Acquire
config: PIVlab LD-PS + OPTOcam 20/9
keywords: optocam 20/9 balluff matrix vision impact acquire genicam gentl usb3
---
## 1. Install the software

<!-- switch: edition -->

### Standalone app

1. {% include steps/balluff.md %}
2. {% include steps/balluff-options.md %}

### MATLAB toolbox

1. {% include steps/iat.md %}
2. {% include steps/balluff.md %}
3. {% include steps/balluff-options.md %}
4. {% include steps/genicam.md %}

## 2. Connect the camera

1. Plug the camera into a USB 3.0 port of the computer.

{% include steps/usb-hint.md %}

## 3. Start capturing

1. Start PIVlab and open the image acquisition panel.
2. Select the configuration **PIVlab LD-PS + OPTOcam 20/9**.
3. Start your PIV recordings.
