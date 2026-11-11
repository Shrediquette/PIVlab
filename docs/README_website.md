# PIVlab website (www.pivlab.de) – how to edit

GitHub Pages builds the site with Jekyll from this `docs/` folder. This file is not published.

| What | Where |
|---|---|
| Top menu | `_config.yml` (`navigation`) – also used by the manual |
| All download links (header buttons, big buttons on home and downloads page) | `_config.yml` (`downloads`) – also used by the manual |
| Page frame (header, menu, footer) | `_layouts/default.html` |
| Colours and layout | `assets/css/site.css` |
| Wiki pages | `_wiki/*.md` (order = file name; `group` decides the tile group on the Wiki page) |
| Camera pages | `_cameras/*.md` (one file per camera, `order` decides the order) |
| Install steps used on several camera pages | `_includes/steps/*.md` |
| Search ranking (website and manual) | `manual/assets/js/search-core.js` |
| Legal notice / privacy policy | `imprint.md`, `privacy.md` |

## Add a camera

Copy a file in `_cameras/`, e.g. `optocam-2-80.md`, and change the front matter (`title`, `order`, `summary`, `connection`, `software`, `config`) and the steps. The page appears automatically on the camera overview, in the search and in the sitemap. For a photo on the overview card, put a JPG with white background into `assets/images/cameras/` and add `image: /assets/images/cameras/<name>.jpg` to the front matter (without it, a camera icon is shown). Numbered lists are shown as steps.

Steps that occur on several pages are in `_includes/steps/` and are used like this: `1. {% include steps/genicam.md %}`. Change the text there once and all pages follow.

## Switches (Standalone app / MATLAB toolbox, frame grabber, ...)

Put a marker line before the options; the headings after it become the tabs:

```
<!-- switch: edition -->

### Standalone app
...
### MATLAB toolbox
...
```

- The word after `switch:` names the switch. The visitor's choice is remembered per name on all pages (`edition`, `grabber`).
- The **first** option is shown to first-time visitors.
- A switch can sit inside an option of another one: use `####` headings (see the OPTRONIS pages).
- A section whose `##` heading ends with `(Euresys only)` is shown only while an option starting with "Euresys" is chosen.

Hint box: start a paragraph with `> `.

Link from PIVlab to a camera page: `camera_setup_url` in `+acquisition/camera_info.m`.

## Videos and animations

YouTube video:

```html
<div class="video" data-yt="VIDEO_ID" data-title="Title"><a href="https://www.youtube.com/watch?v=VIDEO_ID">Watch on YouTube: Title</a></div>
```
Nothing is loaded from YouTube before the visitor clicks (see privacy policy). The preview image is a copy on pivlab.de: save the video's thumbnail (`https://i.ytimg.com/vi/VIDEO_ID/maxresdefault.jpg`) as `assets/images/videos/VIDEO_ID.jpg`. Without it, a dark placeholder is shown.

Short looping animation (e.g. made from a GIF): use an MP4 in `<video class="anim" preload="none" muted loop playsinline poster="still.webp">` – it is only loaded and played while it is on screen (see `assets/images/stereo/`).

## Search engines

Every page should have a `description` in its front matter (shown by Google, read by AI assistants); top-level pages (home, downloads, ...) are found in the site search through `description` and `keywords` only. `sitemap.xml`, `robots.txt`, `llms.txt` and the search index (`assets/js/site-search.js`) are generated automatically.
