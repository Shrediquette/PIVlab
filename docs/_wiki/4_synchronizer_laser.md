---
title: Synchronizer setup
group: Hardware
summary: Set up the wireless serial link between PIVlab and the synchronizer.
description: Set up the wireless serial dongle (CP210x USB-UART driver) for the OPTOLUTION synchronizer and laser in PIVlab.
---
## Setting up the wireless serial dongle

PIVlab talks to the synchronizer through a wireless serial link. The white USB stick with the small spiral antenna is one end of this link.

1. Install the [CP210x USB-UART driver (Silicon Labs)](https://www.silabs.com/documents/public/software/CP210x_Universal_Windows_Driver.zip).
2. Plug in the USB stick.
3. Open the Windows **Device Manager**. Under **Ports (COM & LPT)** you find an entry like **Silicon Labs CP210x USB to UART Bridge (COM5)**. The number is the COM port to select in PIVlab.

More information on the whole system is in the [User Guide for the OPTOLUTION PIV System](https://optolution.com/media/manual_piv_system_optolution_v1.0.pdf).
