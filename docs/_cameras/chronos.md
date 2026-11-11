---
title: Krontech Chronos
order: 6
image: /assets/images/cameras/chronos.jpg
summary: Compact, affordable high-speed cameras (Chronos 1.4, Chronos 2.1) controlled over the network.
description: Use Krontech Chronos 1.4 and 2.1 high-speed cameras with PIVlab - network setup, trigger settings, recommended firmware, resolutions and tips for saving recordings.
models: [Chronos 1.4, Chronos 2.1]
connection: Ethernet / WiFi
software: none (camera firmware)
config: PIVlab LD-PS + Chronos
keywords: krontech chronos 1.4 2.1 high-speed camera ip address network firmware black calibration tiff h264
---
PIVlab has been tested with the Chronos 1.4. The Chronos 2.1 is expected to work the same way.

## 1. Prepare the camera

1. Use firmware **0.5.1**. It records reliably without skipped frames.
2. On the Chronos touchscreen, open the **Trigger I/O** menu and disable **Debounce** in the **IO1 BNC** panel.

## 2. Connect to PIVlab

1. Connect the camera to the computer's network. A small WiFi router at the camera (for example a VONETS VAP11s) lets you control it wirelessly.
2. In PIVlab's image acquisition panel, click **Setup** and enter the IP address of the Chronos, for example `192.168.254.100`.
3. Enter a resolution the camera accepts, for example 1280 × 720 or 1280 × 1024.
4. Use PIVlab to switch between live image and PIV capture.

## 3. Record

1. Click **Start** in the **Capture PIV images** panel. The Chronos records images synchronized to the laser into its RAM ring buffer, also when **Save** is not ticked.
2. Click **Abort** to stop the recording.
3. Review, select and save the frames you need, either in the Chronos web interface or on the touchscreen. The camera can save to SD card, SSD or an SMB network drive.
4. Check that images A and B are in the right order before analysing.

**File formats:** TIFF raw gives the best PIV results. H.264 saves much faster with lower image quality.

**1000 fps with external trigger:** use a slightly reduced resolution such as 1280 × 720.

## Tips

### Clean images (black calibration)

If you see stripes in the images, cover the lens and try these steps one after the other:

1. **Util** → **Factory** → **Black calibrate all resolutions**.
2. Set the camera to the resolution you need, then **Black cal** on the main screen.
3. In **Record settings**, click both **max** buttons, then **OK**.
4. Switch to a different resolution and back.

### Switching on and off

- Starting the camera takes 30 seconds to a minute.
- When the camera is set to external triggering, hold the power button a little longer to switch it off, or start the live image from PIVlab first.
