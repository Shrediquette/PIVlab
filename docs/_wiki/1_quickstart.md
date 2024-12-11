---
layout: default
title: Quickstart
---
# General remarks
A "frame" is defined as a pair of images including any derived parameters. Single analyses consist of one single frame (one image pair + results); a time-resolved analysis consists of multiple frames (several image pairs + results). A "session" is defined as a collection of single or multiple frames including any derived parameters and all the settings of the GUI. Sessions can be saved and reloaded in PIVlab.  
The **coordinate system** is defined as follows: The standard coordinate system of image data has its origin at the top left. PIVlab uses this coodinate system too. Velocities in the horizontal direction (x) are called 'u' and velocities in the vertical direction (y) are called 'v'. Positive u is top-to-bottom, and positive v is left-to-right. **This coordinate system can be adjusted / modified after calibration** (see below).  
When creating masks, manually rejecting vectors, selecting areas/ poly-lines etc., the left mouse button performs the desired task, whereas the right mouse button ends this task. The GUI is menu-based; selecting a menu item will change the panel that is displayed on the left hand side. When doing PIV analyses, the work flow should start at the left side of the menu, and continue to the right side.  
PIVlab uses "tool tips" everywhere. When you would like to see more information on a setting or a parameter, simply hover your mouse over the feature. A tool tip will appear and give you more detailed information.

# Tutorial - Analyzing a series of images
This tutorial will show you how to process a series of image pairs. Some of the possibilities of PIVlab will be demonstrated. I recommend to read this tutorial while performing the steps in PIVlab. This will teach you to use the most important features of PIVlab. After this, feel free to [watch the video tutorials.](https://shrediquette.github.io/PIVlab/wiki/2-video-tutorials/)

## Import images
First, load some images by selecting _File_ -> _New session_. Click _Load images_ in the panel that appears on the left side of the screen.

![](https://github.com/user-attachments/assets/ceaa6167-ec2e-4ca3-b9e5-029690a7faf8)

Select the images _PIVlab\_Karman\_01.bmp_ till _PIVlab\_Karman\_04.bmp_ that you can find in the PIVlab/Examples folder. Set the sequencing style to _'time resolved'_ and click _Add_, then _Import_.

![](https://github.com/user-attachments/assets/fdeefd0e-025d-4e5b-ad80-2f57f95e23f9)

The images are loaded in PIVlab. The image list on the panel on the left side displays the images that you selected. The letters _'A'_ & _'B'_ denote the first and the second image of one image pair (= one "frame"). In the lower left corner, you will find a slider to navigate through all frames, and a button (_Toggle A/B_) to toggle between the individual images within one frame.

![](https://github.com/user-attachments/assets/ac241e40-5809-4739-bba0-39f5ff4fa611)

## Zooming, setting a region of interest and a mask
In the menu, continue to _Image settings -> Define region of interest (ROI)_. When you do not set a ROI, then the whole image will be analyzed (which is fine most of the time). If you would like to select a region of interest, you would click _Select ROI_, and then left click and drag to draw a rectangle. You could also enter coordinates by hand.

![](https://github.com/user-attachments/assets/90825a50-c32f-4050-9025-83c9f27fb807)

Additionally, you should apply a mask to exclude areas in the image from the analysis. Navigate to _Image settings -> Define masks to exclude regions from analysis_ in the menu. The mask should be applied to exclude the dark object (a cylindrical rod) from the analyses. First, you should zoom into this black circle a bit, so it is easier to draw a mask. Click the magnifier icon to enable zooming mode, then drag a zooming rectangle around the rod:

![](https://github.com/user-attachments/assets/b155e4e9-edec-4a30-8036-77097537a754)

The image will be magnified. You need to click this button again to disable zooming mode. If you want to reset any zoom or pan, click this button again, then right click in the image and select "Reset Zoom/Pan" from the pop-up menu. But, as we want to draw a mask now, keep the image zoomed.  
Image masking has quite a number of options that you should explore yourself. There is a basic mode and an expert mode. The expert mode allows to draw masks automatically, the basic mode is for drawing shapes manually. You can import masks that you generated somewhere else, save masks and load masks from other PIVlab sessions.

We want to use the basic mode and draw a circle over the dark rod: Click _circle_, and then click + drag with the mouse to generate a circle. You can scale and move the circle to get a perfect matching mask.

![](https://github.com/user-attachments/assets/b39584b5-0623-4672-a56d-424564444a17)

Because the cylindrical rod doesn’t move from one frame to the other, you can apply the mask to all frames of the current session by clicking _Copy mask to all frames_. You can always draw more than one mask if necessary.

## Image pre-processing
PIVlab offers a number of image pre-processing techniques, that can significantly enhance the quality of your analyses. Click on _Image settings_ -> _Image pre-processing_. Contrast-limited adaptive histogram equalization (_CLAHE_) is enabled by default. This filter locally enhances the contrast in the images. The other pre-processing filters can be handy as well, but will not be used in this example. You can also move your mouse over the check boxes to see some tool tips with more information on the filters. Always remember to apply your selection by clicking "Apply and preview current frame". The filters will be automatically applied to all frames in your current PIVlab session.

![](https://github.com/user-attachments/assets/ff44abcf-f228-4abe-8129-ab424d50fc05)

## PIV settings
Proceed to _Analysis_ -> _PIV settings_ to setup the cross-correlation for your image data. PIVlab features four different correlation algorithms: _Multipass FFT window deformation, ensemble multipass FFT window deformation, single pass direct cross correlation and optical flow (wavelet based, wOFV)._

The _Multipass FFT window deformation_ algorithm is enabled by default, and in most situations, it delivers the best / most robust results. By selecting this algorithm, your data will be analysed in several passes: The first pass uses relatively large interrogation areas to calculate the displacement of your image data reliably. The larger the interrogation areas, the better the signal-to-noise ratio, and the more robust is the cross correlation. But large interrogation areas will only give a very low vector resolution ("vectors per frame"). That is why you should decrease the size of the interrogation windows in the following passes. The displacement information of the first pass is used to offset the interrogation areas in the second pass and so on. This procedure yields a high vector resolution, a high signal-to-noise ratio, and a high dynamic velocity range. The interrogation areas of later passes are not only displaced, but they are also deformed. Read [my paper for more information on this](https://openresearchsoftware.metajnl.com/articles/10.5334/jors.bl).  
The general recommendation is to use about three passes (the more passes you use, the better will be the result, but it will also take a while to compute). Start with big interrogation areas (e.g. 128 pixels) and decrease gradually in the following passes (e.g. 64 pixels in pass 2, 32 pixels in pass 3). You don't need to use 'power of two' numbers for the size of the areas (this is because MATLAB uses [FFTW](http://www.fftw.org/) for the correlation, and that can handle arbitrary sizes):

![](https://github.com/user-attachments/assets/e868a565-de43-41a4-bca0-7fc6f3d3f9f6)

Now, everything is ready for the PIV analysis.

_**One further general remark on the choice of the interrogation area size:**_ _Very often, I notice that extremely small interrogation areas are used in the last pass. While this will increase the resolution of the vector map, it will also significantly increase noise and the amount of erroneous correlations. In many cases, high vector map resolutions are not really important. Think about this and make the interrogation areas as large as possible: You will get more accurate and more reliable results._

## Analysis
Navigate to _Analysis_ -> _Analyze!_ in the menu and click _Analyze all frames_.

![](https://github.com/user-attachments/assets/70893efa-62ca-4f4a-acfe-5574a5d9f981)

## Calibration / unit conversion (optional)

You can calibrate (tell PIVlab how many pixels are one meter, and the time step between the images of one frame) whenever you want, but it is wise to do it before validating the data (see next step). Until now, the units in PIVlab are "pixels per frame": Click on a vector to have its "velocity" and coordinates displayed in the lower left corner of the program (_Current point: u: xxx \[px/fr\]_ etc.):

![](https://github.com/user-attachments/assets/a44bbc01-f154-4843-8ef0-7cc624e84018)

These units can be converted to real-world units (e.g. meters or meters per second) by navigating to _Calibration_ -> _Calibrate using current or external image_. Usually, you would now load your calibration image (which would e.g. show a ruler centered in the laser sheet). You would click on _Select reference length \[px\]_ and the click and drag to draw a line along a known distance. But in this example, we don't have a calibration image - someone forgot to record it. However, the calibration can also be done by using the currently displayed image: Click _Select reference length \[px\]_ and click and drag to draw a line along the diameter of the cylinder:

![](https://github.com/user-attachments/assets/c6a8cfe7-3939-4646-98ea-3951b6c92bf5)

Now, you can enter the real diameter of the cylinder in the field _Real distance \[mm\]_ (the diameter was 30 mm) and the time step in _time step \[ms\]_ (the frame rate was 400 Hz = 2.5 ms). The precision of this kind of calibration is pretty low, so external calibration images should really be used. Finally, you need to click _Apply calibration_ to activate the calibration:

![](https://github.com/user-attachments/assets/121589d9-dba5-4a00-be2c-8ce8dea3f507)

You could additionally set offsets and flip the coordinate system if you like, e.g. making the coordinate system start at the centre of the cylindrical rod. But this is fully optional and often not required.

**(Additional note: If you are** _**not interested in velocities, but only in displacements**_**, then proceed as explained above, but enter "0" as time step. Then all data output will be displacement and not velocity)**

If you again click on some vectors in the image, the velocity will be displayed in real units (m/s). The free flow velocity in this experiment was around -0.2 m/s (the negative sign means that the flow is from right-to-left with the standard coordinate system orientation):

![](https://github.com/user-attachments/assets/a5da166b-f26f-40e2-87a1-bcf2a0499371)

## Data validation/filtering (optional)
Some erroneous vectors might show up due to poorly illuminated regions in the image or strong out-of-plane flow:

![](https://github.com/user-attachments/assets/672da336-643a-43b4-8925-b9e030c737c3)

For our example data set, there are hardly any outliers, but usually there are quite a number of them. They can be removed and interpolated by selecting _Validation_ -> _Velocity based validation_. There are several ways to filter your data. Start by setting velocity limits. Vectors outside of these limits will be rejected. Click _Select velocity limits:_

![](https://github.com/user-attachments/assets/29995959-fc80-4918-8071-a3f82bcde58e)

Draw a rectangle (click + hold left mouse button and drag the mouse) over the vectors that you would like to keep:

![](https://github.com/user-attachments/assets/f8776008-3803-4be2-8b59-f921a8a88bf0)

The best practice is to enable only this velocity limit filter first. Apply this filter to some frames and check if it really only removes erroneous vectors. It should not remove any valid data. If it does, clear the velocity limits and find some better limits. When this is finished, you can enable additional filters to remove erroneous vectors that may have remained: You should enable the standard deviation filter (set to n = 8) and the local median filter with a threshold between 1 and 3. Click on _Apply to all frames_ to perform the velocity based validation/filtering.

There are additional powerful filters in _Post processing_ -> _Image based validation._ They do not filter data using the velocity vectors, but they use the raw input images to control filtering. That is why these filters need more computation time and take some time to calculate. You could e.g. suppress vectors in bright regions (e.g. caused by reflections), or in regions that have a low contrast (e.g. shadows or areas without seeding particles). Furthermore, you could suppress vectors that are in image regions that have a low correlation. Experiment with the settings if you like:

![](https://github.com/user-attachments/assets/5c203c7b-6ff9-43f5-9f57-99159a8def60)

If the checkbox _Interpolate missing data_ is enabled, vectors will be filtered out and then replaced by interpolated vectors. These vectors are shown in orange. **Take care that you are not accidentally interpolating all the data you're interested in!**

Finally, click _Apply to all frames_ again and scan through all the frames (by using the slider on the lower left) to check if all data looks good. As mentioned above, interpolated vectors will be displayed in orange. You can also disable interpolation. **You should always aim for having only a very small amount of orange vectors, as these are not measured displacements / velocities, but just interpolated data!** If there are remaining erroneous vectors, try changing the velocity limits, or the other validation filters. You can also reject individual vectors by clicking _Manually reject vector_ in the _Velocity based validation_ panel.

Also check the _Valid detection probability (VDP)_ shown in the green / yellow / red box at the bottom: It should be above 90 % (but this strongly depends on your experimental conditions).

## Displaying derivatives
To display the vorticity in the flow, select _Plot_ -> _Spatial: Derive parameters/ modify data_. Select _Vorticity_ in the upper pop-up menu. You can smooth the data by enabling the check box next to _Smooth data_ and dragging the slider a bit to the right. Then click _Apply to all frames:_

![](https://github.com/user-attachments/assets/ffcd7439-3377-4c99-998d-cfb81824dbc9)

The limits of the colormap can be adjusted (by default, they are calculated automatically for each frame). This is especially useful when exporting videos where it is important that the colormap doesn't change during the video:

![](https://github.com/user-attachments/assets/3911f9c7-cc95-4f16-94ef-8cfbaf27773e)

You can also calculate the average velocity of several frames:

Navigate to _Plot_ -> _Temporal: Derive parameters_ and click _Calculate mean._ Now, an additional frame will be automatically added to your session. It contains the mean velocity field of all frames. All masks of the frames you used to calculate this average will be combined. Vectors will be orange in the average frame, if more than half of the original vectors at that spot were interpolated before.

## Modifying plot appearance
The scaling of vectors can be modified by selecting _Plot ->_ _Modify plot appearance_. The scaling of the vectors can be set to automatic mode, or vector display may be suppressed. You can enable a color bar /color legend when you want to have a reference for the colors displayed e.g. by vorticity. 

Additionally, you can change the colors of the vectors. The checkbox _enhance PIV image display_ will increase the brightness of the displayed image. Use this to improve legibility of dark images.

![](https://github.com/user-attachments/assets/2707d658-1fd2-4686-8135-6325c82de96f)

Almost all steps mentioned above are also shown in three video tutorials. Furthermore these tutorials show how to work and analyze your results and how to export results in various formats. [Watch these videos here.](https://github.com/Shrediquette/PIVlab/wiki/Video-tutorials)
