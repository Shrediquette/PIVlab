---
layout: default
title: Camera Setup
---
# Setting up the wireless serial dongle
Communication with the snychronizer works through a wireless serial link. The white USB stick with the small spiral antenna is one end of this wireless serial link. It needs this driver to work properly (a standard USB / UART transceiver chip)
[CP210X USB-UART driver (silabs)](https://www.silabs.com/documents/public/software/CP210x_Universal_Windows_Driver.zip)
After installation, check windows device manager to find the correct COM port.
It will look like this picture from the website "randomnerdtutorials.com":
![](https://i0.wp.com/randomnerdtutorials.com/wp-content/uploads/2024/02/Testing-the-CP210x-USB-to-UART-Bridge-Drivers-Installation-on-Windows-PC-Device-Manager.png)

More information on the whole system is also available in the [User Guide For The OPTOLUTION PIV System](https://optolution.com/media/manual_piv_system_optolution_v1.0.pdf)
