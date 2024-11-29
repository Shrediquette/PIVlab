---
layout: default
title: Home
permalink: /wiki/
---
# What is it?

PIVlab is a free graphical user interface (GUI) based particle image velocimetry (PIV) software and is currently the most frequently cited PIV software on the market. It can be used to control [OPTOLUTION's lasers, cameras and synchronizers](https://optolution.com/en/products/particle-image-velocimetry-piv/), and of course it calculates the velocity distribution within imported (or captured) particle image pairs. It can also be used to derive, display and export multiple parameters of the flow pattern. The simple, GUI makes PIV data acquisition and data post-processing fast and efficient.

**You can use PIVlab:**
* As a free stand-alone program for windows computers (all features, no requirements)
* As free toolbox inside Matlab for every operating system (all features, Matlab required)
* As free web browser-based app by using Matlab online (no hardware interaction, free Mathworks account required)


_**Still not sure what exactly PIVlab is, how it looks like, if it is easy enough to use, and if it really is a good choice for doing PIV?**_ Then have a look at a quick [video demo of how PIVlab looks like](https://www.youtube.com/watch?v=P9HDj4oGS98) (very old video, but it shows the principle). Some example results [are presented here](https://www.youtube.com/watch?v=LXtrEX5X6SI). Many researchers have published papers (>5000)  in high impact journals with the help of PIVlab in the past. Papers citing PIVlab can be found via [this Google Scholar link](https://scholar.google.de/scholar?hl=de&as_sdt=0%2C5&q=%28%22pivlab%22+%7C+%22piv+lab%22%29+AND+%28%22piv%22+%7C+%22particle+image+velocimetry%22%29+-%22%40pivlab.net%22&btnG=).

# Installation instructions
## Stand-alone application
tbd
## Matlab toolbox
### Requirements
PIVlab needs Matlab and the image processing toolbox to run. It is compatible with releases from Matlab R2019b and later. PIVlab checks for all requirements during startup and will warn you if something misses.
### Setup
My preferred method is to download the zip file from GitHub by going [here](https://github.com/Shrediquette/PIVlab/releases), click 'Source code (zip)' of the latest release and extract the contents to a new folder in your Matlab work directory. Then run PIVlab\_GUI.m.  
Alternatively, download the latest 'PIVlab.mltbx' from [here](https://github.com/Shrediquette/PIVlab/releases), and run it on your computer. It will automatically add the PIVlab toolbox and app in your Matlab installation.
## Matlab online
See the video quickstart here: [Youtube video](https://www.youtube.com/watch?v=EQHfAmRxXw4)
# Tutorials

A text-based quickstart manual for PIVlab with step-by-step instructions [is available here](https://github.com/Shrediquette/PIVlab/wiki/Quickstart:-Analyze-PIV-data). If you prefer watching videos, you can watch the tutorial videos [here](https://github.com/Shrediquette/PIVlab/wiki/Video-tutorials).

# Support

You can get support in the [Google Groups forum](https://groups.google.com/forum/?hl=en-GB#!forum/pivlab). Usually I am very responsive. If you have problems analyzing your data, please always provide the original data in the forum. And if I have a fix or a solution for your problem, please give me feedback if it worked!

# Documentation

There are papers published on PIVlab by me, they give some background information:

*   [2014 paper in Journal of Open Research Software](https://openresearchsoftware.metajnl.com/articles/10.5334/jors.bl)
*   [2014 PhD thesis, chapter on PIV](https://pure.rug.nl/ws/portalfiles/portal/14094707/Chapter_2.pdf)
*   [2021 paper in Journal of Open Research Software](https://openresearchsoftware.metajnl.com/articles/10.5334/jors.334)
*   tbd: Add 2024 flowlab paper

# Contribute

You can support PIVlab development by contributing code, writing documentation and giving a comment and rating on [Matlabs FileExchange Website](https://de.mathworks.com/matlabcentral/fileexchange/27659). The best way for supporting PIVlab is to buy hardware (cameras, lasers, synchronizers) for PIVlab from OPTOLUTION, the company I am working for. If OPTOLUTION generates some money with PIVlab hardware, then I can spend more of my working time for improving PIVlab. Have a look at the available hardware here, or contact us for customized hardware:  
[OPTOLUTION PIV hardware for PIVlab](https://optolution.com/en/products/particle-image-velocimetry-piv/)