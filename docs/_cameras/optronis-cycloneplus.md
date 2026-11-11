---
title: OPTRONIS CyclonePlus
order: 5
image: /assets/images/cameras/optronis-cycloneplus.png
summary: 25-megapixel high-speed CoaXPress camera (CyclonePlus-25-M), up to 145 fps at 5120 × 5120 pixels.
description: Set up the OPTRONIS CyclonePlus-25-M high-speed camera with a Euresys Coaxlink (or BitFlow) frame grabber for time-resolved PIV in PIVlab - drivers, cabling and RAM per recording.
models: [CyclonePlus-25-M]
connection: CoaXPress (PCIe frame grabber)
software: Euresys eGrabber (or BitFlow SDK)
config: PIVlab LD-PS + OPTRONIS Cyclone
keywords: optronis cycloneplus cyclone plus 25 megapixel high-speed time-resolved coaxpress cxp-12 euresys coaxlink egrabber bitflow ram 10 bit
---
The CyclonePlus-25-M records 5120 × 5120 pixels at up to 145 frames per second, in 8 or 10 bit. PIVlab detects the camera automatically and sets its trigger mode itself, so no settings in eGrabber Studio are needed.

## 1. Install the software

<!-- switch: edition -->

### Standalone app

<!-- switch: grabber -->

#### BitFlow frame grabber

1. {% include steps/pcie-bitflow.md %}
2. {% include steps/bitflow-sdk.md %}
3. {% include steps/bitflow-adaptor.md %}
4. For the full frame rate, record in 8 bit.

#### Euresys frame grabber

1. {% include steps/pcie-euresys.md %}
2. {% include steps/egrabber.md %}

### MATLAB toolbox

<!-- switch: grabber -->

#### BitFlow frame grabber

1. {% include steps/iat.md %}
2. {% include steps/pcie-bitflow.md %}
3. {% include steps/bitflow-sdk.md %}
4. {% include steps/bitflow-adaptor.md %}
5. {% include steps/genicam.md %}
6. For the full frame rate, record in 8 bit.

#### Euresys frame grabber

1. {% include steps/iat.md %} For 10-bit recordings, use MATLAB R2025a or newer.
2. {% include steps/pcie-euresys.md %}
3. {% include steps/egrabber.md %}
4. {% include steps/genicam.md %}

## 2. Connect the camera

1. Connect the camera to the frame grabber with the CoaXPress cables.
2. Connect the trigger input of the camera to the synchronizer.
3. Power the camera.

## 3. Start capturing

1. Start PIVlab and open the image acquisition panel.
2. Select the configuration **PIVlab LD-PS + OPTRONIS Cyclone**. The CyclonePlus is detected automatically.
3. Connect to the synchronizer in PIVlab and start your PIV recordings.

## How many images fit into RAM

High-speed recordings go into the computer's RAM first, so that no frame is lost, and are saved to disk afterwards. Approximate number of double images at full resolution (5120 × 5120 pixels):

| RAM | 8 bit | 10 bit |
|---|---|---|
| 16 GB | 100 | 50 |
| 32 GB | 260 | 130 |
| 64 GB | 590 | 295 |
| 128 GB | 1250 | 620 |

10-bit images are stored with 16 bit, so they need twice the RAM. A smaller region of interest gives proportionally more images. PIVlab shows the maximum for your computer: if you ask for more images, the field turns orange and PIVlab warns you before recording. A fast, large SSD makes saving the recording quicker.
