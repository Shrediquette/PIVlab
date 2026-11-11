---
title: Camera setup
group: Hardware
summary: Install drivers and connect your camera to PIVlab, step by step for each supported camera.
description: How to set up OPTOcam, pco, OPTRONIS Cyclone / CyclonePlus and Krontech Chronos cameras for image acquisition in PIVlab (standalone app and MATLAB toolbox).
keywords: camera driver installation genicam gentl image acquisition toolbox
---
PIVlab captures PIV image pairs directly from these cameras, synchronized with the laser. Looking for a camera? See the [PIV cameras available from OPTOLUTION](https://optolution.com/en/products/particle-image-velocimetry-piv/cameras-overview/). Choose your camera for the installation steps:

<div class="cards">
{%- assign cams = site.cameras | sort: "order" %}
{%- for c in cams %}
  <a class="card camera-card" href="{{ c.url | relative_url }}">
    <span class="card-photo">{% if c.image %}<img src="{{ c.image | relative_url }}" alt="{{ c.title }}" loading="lazy">{% else %}<svg viewBox="0 0 64 48" aria-hidden="true"><rect x="6" y="12" width="40" height="28" rx="4"/><path d="M46 20l12-6v20l-12-6z"/><circle cx="26" cy="26" r="8" class="lens"/></svg>{% endif %}</span>
    <h3>{{ c.title }}</h3>
    <p>{{ c.summary }}</p>
    <span class="tags"><span class="tag">{{ c.connection }}</span><span class="tag">{{ c.software }}</span></span>
  </a>
{%- endfor %}
</div>

## Before you start

- Each camera page has steps for the **Standalone app** and for the **MATLAB toolbox**. Pick your version with the switch at the top of the steps; your choice is remembered.
- When the camera is connected, click **Detect connected cameras** in PIVlab's image acquisition panel to check that it is found.
- The synchronizer and laser are set up separately: see [Synchronizer setup]({{ '/wiki/4-synchronizer-laser/' | relative_url }}).
