# PIVlab - particle image velocimetry (PIV) tool with GUI
*PIVlab is a graphical user interface (GUI) based particle image velocimetry (PIV) software. It can be used to control OPTOLUTION's lasers, cameras and synchronizers, and of course it calculates the velocity distribution within imported (or captured) particle image pairs. It can also be used to derive, display and export multiple parameters of the flow pattern. The simple, GUI makes PIV data acquisition and data post-processing fast and efficient.*

![PIVlab_screenshot](https://github.com/Shrediquette/PIVlab/blob/main/images/PIVlab_screenshot.jpg)

**   **
**PIVlab comes with it's own unique hardware: Pulsed lasers, LEDs, synchronizers and cameras are available here: [Optolution.com](https://www.optolution.com/en/products/particle-image-velocimetry-piv/)**
**   **
Video tutorial 1/3: Quickstart guide
https://youtube.com/watch?v=g2hcTRAzBvY

Video tutorial 2/3: Pre-processing, analysis and data validation
https://youtube.com/watch?v=15RTs_USHFk

Video tutorial 3/3: Data exploration and data export
https://youtube.com/watch?v=47NCB_RFiE8

PIVlab controlling cameras, lasers, etc.
https://youtu.be/8B5M31NWlJc


**Installation:** https://github.com/Shrediquette/PIVlab/wiki#installation-instructions

**Please ask your questions in the PIVlab forum:** http://pivlab.blogspot.de/p/forum.html

**Software documentation is available in the wiki:** https://github.com/Shrediquette/PIVlab/wiki
**   **
**Code contributors:**
* Main: William Thielicke (http://william.thielicke.org)
* Name spaces / packages: Mikhil from MATHWORKS (https://github.com/Mikhil11)
* Vectorization in piv_fftmulti: Sergey Filatov (http://www.issp.ac.ru/lqc/people.html)
* GUI parallelization: Chun-Sheng Wang, ParaPIV (https://de.mathworks.com/matlabcentral/fileexchange/63358-parapiv)
* Command line parallelization: Quynh M. Nguyen (https://github.com/quynhneo)
* Speed, memory and general optimizations: Maarten (https://github.com/mkbosmans) via VORtech.nl via MathWorks
**   **
We would like to acknowledge Uri Shavit, Roi Gurka &amp; Alex Liberzon for sharing their code for 3-point Gaussian sub-pixel estimation. Thanks to Nima Bigdely Shamlo for allowing me to include the LIC function. Thanks to Raffel et al. for writing the book "Particle Image Velocimetry, A Practical Guide", which was a very good help. Thanks to the [thousands of publications that use PIVlab for research](https://scholar.google.de/scholar?cites=819244312015141543)!

Visit Matlabs File exchange site for PIVlab: [![View PIVlab - particle image velocimetry (PIV) tool on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://de.mathworks.com/matlabcentral/fileexchange/27659-pivlab-particle-image-velocimetry-piv-tool)

PIVlab [can be run online using MATLAB online](https://youtu.be/EQHfAmRxXw4?si=X77HabqAIbuHRIGT). MATLAB online is free (after registration) with a limited usage time per user (20 hrs/month):
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=Shrediquette/PIVlab&file=PIVlab_GUI.m)
