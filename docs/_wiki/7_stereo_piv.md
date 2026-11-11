---
title: "Stereo-PIV: all three velocity components"
group: Going further
summary: Add a second camera and measure the out-of-plane velocity too, with the same PIVlab workflow. Try it first with the built-in simulator.
description: Stereo-PIV (2D3C) in PIVlab - measure all three velocity components u, v, w in the light sheet with two cameras. Scheimpflug calibration, ChArUco boards, stereo image acquisition and a 3D flow and stereo-PIV simulator to try it before buying hardware. Available from PIVlab 4.0.
keywords: stereo piv stereoscopic 2d3c three components out-of-plane velocity w scheimpflug two cameras calibration charuco simulator synthetic 3d flow sphere wake upgrade
---
> **Available from PIVlab 4.0.** Would you like to try it earlier? Ask in the [PIVlab forum](https://groups.google.com/forum/?hl=en-GB#!forum/pivlab) and you get a link to the current version.

Standard (2D) PIV measures the two velocity components in the plane of the light sheet. With a **second camera** that looks at the light sheet from a different angle, PIVlab also measures the third component, the velocity **through** the light sheet (w). This is called stereo-PIV or 2D3C (two dimensions, three components).

<video class="anim" preload="none" muted loop playsinline poster="/assets/images/stereo/stereo-result-w.webp" aria-label="Stereo-PIV result: in-plane velocity vectors and the out-of-plane component w in colour"><source src="/assets/images/stereo/stereo-result-w.mp4" type="video/mp4"><img src="/assets/images/stereo/stereo-result-w.gif" alt="Stereo-PIV result: in-plane velocity vectors and the out-of-plane component w in colour"></video>

## The same workflow you already know

Stereo-PIV in PIVlab uses the same program, the same panels and the same steps as 2D PIV. The additional steps are guided:

1. Load the images of both cameras into one session.
2. Calibrate each camera with images of a ChArUco calibration board. PIVlab creates printable boards for you.
3. Run the stereo calibration and the disparity correction.
4. Analyse, validate and export as usual: the results now include w.

Everything is explained step by step in the manual: [Stereo-PIV (2D3C)](/manual/pages/stereo-piv.html).

## Try it before you buy anything

PIVlab contains a **3D flow and stereo-PIV simulator**. You position two virtual cameras (with lens distortion) as you like, capture simulated calibration boards and generate a 3D flow, e.g. the 3D wake of a sphere. Then you import the images and go through the complete stereo-PIV workflow, as if you already had the equipment. This is also useful for learning and teaching stereo-PIV.

![The stereo-PIV simulator in PIVlab: two cameras looking at a calibration board in the light sheet, with the simulated camera images](/assets/images/stereo/stereo-simulator.jpg)

More in the manual: [Synthetic particle image generation](/manual/pages/synthetic-images.html).

## Hardware for stereo-PIV

- **Two cameras** look at the light sheet from different angles. The lenses are tilted with a **Scheimpflug** mount, so that the whole light sheet is in focus. PIVlab's sharpness display helps you to adjust the tilt.
- **OPTOLUTION cameras** get Scheimpflug housings, so the lenses can be tilted directly.
- **pco cameras:** Scheimpflug mounts from pco are available through OPTOLUTION.
- **Calibration target:** included free of charge with a stereo set from OPTOLUTION.

Start with 2D PIV today and upgrade to stereo-PIV later by adding a second camera. Ask [OPTOLUTION](https://optolution.com/en/products/particle-image-velocimetry-piv/) for a stereo set.
