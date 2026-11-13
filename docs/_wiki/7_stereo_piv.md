---
title: "Stereo-PIV software: all three velocity components"
group: Going further
summary: Add a second camera and measure the out-of-plane velocity too, with the same PIVlab workflow. Try it first with the built-in simulator.
description: Stereo-PIV (2D3C) software that also records - PIVlab measures all three velocity components u, v, w with two cameras, records both cameras synchronized with the laser, creates the calibration board, calibrates (incl. Scheimpflug) and analyses in one program. Includes a 3D flow and stereo-PIV simulator to try it before buying hardware. Available from PIVlab 4.0.
keywords: stereo piv stereoscopic 2d3c three components out-of-plane velocity w scheimpflug two cameras dual camera stereo acquisition recording live marker detection calibration board generator charuco simulator synthetic 3d flow sphere wake upgrade all-in-one
---
> **Available from PIVlab 4.0.**

<div class="beta-box" data-beta-box hidden></div>

Standard (2D) PIV measures the two velocity components in the plane of the light sheet. With a **second camera** that looks at the light sheet from a different angle, PIVlab also measures the third component, the velocity **through** the light sheet (w). This is called stereo-PIV or 2D3C (two dimensions, three components).

<video class="anim" preload="none" muted loop playsinline poster="/assets/images/stereo/stereo-result-w.webp" aria-label="Stereo-PIV result: in-plane velocity vectors and the out-of-plane component w in colour"><source src="/assets/images/stereo/stereo-result-w.mp4" type="video/mp4"><img src="/assets/images/stereo/stereo-result-w.gif" alt="Stereo-PIV result: in-plane velocity vectors and the out-of-plane component w in colour"></video>

## From recording to 3D result in one program

PIVlab does not only analyse stereo-PIV images, it also records them. Recording, calibration and analysis happen in the same program, with the same panels as 2D PIV:

1. Print the ChArUco calibration board that PIVlab creates for you, in the size you need.
2. Place the board at the measurement position and focus the tilted lenses with the sharpness display.
3. Record images of the board at many positions and tilts for the lens calibration of each camera.
4. Align the light sheet on the board, switch the laser off and record the board under normal lighting. The live image shows both cameras side by side, with the detected board markers, so you see at once whether both cameras see the board well. One click saves the board images of both cameras.
5. Record the PIV images of both cameras, synchronized with the laser. PIVlab opens them directly in stereo mode.
6. Run the lens and stereo calibration and the disparity correction. The next recording with the same setup keeps the calibration.
7. Analyse, validate and export as usual: the results now include w.

How each step works is shown in eight drawings: [How stereo-PIV works: illustrated step by step]({{ '/wiki/8-stereo-piv-explained/' | relative_url }}).

<a href="{{ '/wiki/8-stereo-piv-explained/' | relative_url }}"><img src="{{ '/manual/assets/img/stereo-piv/workflow/stereo-piv-workflow-card.png' | relative_url }}" width="1200" height="630" loading="lazy" alt="Stereo-PIV step by step: eight drawings from setting up the cameras to the 3D vector map with u, v and w"></a>

![Live image of both cameras in PIVlab with the detected markers of the calibration board](/manual/assets/img/capture/stereo-live.png)

Images recorded with other systems can be imported as well. Everything is explained step by step in the manual: [Stereo-PIV: set-up and recording](/manual/pages/stereo-setup.html), [Stereo acquisition](/manual/pages/capture.html#stereo) and [Stereo-PIV analysis](/manual/pages/stereo-piv.html).

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
