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

## Beta version

Nothing to edit: publish a release on GitHub and tick **"Set as a pre-release"**. While it is the newest release, `assets/js/beta.js` shows a green "Beta x.y" button in the download bar (website and manual) and a beta box on the home page, the downloads page and the stereo-PIV guide (any element with `data-beta-box`), linking to `PIVlab_installer.exe` and `PIVlab.mltbx` of that release. When a normal release is published later, the beta buttons disappear. Visitors see a new beta within an hour (the check is cached per browser session).

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

## Publishing website changes from `stereo` to `main` (for Claude Code sessions)

pivlab.de is built from **`main:/docs`**. Website work happens on **`stereo`**, which also holds unreleased program code. Only the `docs/` folder may go to `main` – **never merge `stereo` into `main`** and never copy anything outside `docs/`. The user usually has unrelated uncommitted files in the folder: never commit, stash, reset, restore or delete them. Explain git state to the user in plain words.

Only do this when the user asks. Commands for PowerShell, run in the repository folder (the one with branch `stereo` checked out); `<C>` = the stereo commit made in step 3.

**Always address the second folder with `git -C ..\PIVlab_website <command>`, never with `cd <folder>` followed by git commands.** If the `cd` fails, the commands run in the stereo folder, and `push origin HEAD:main` then pushes the whole stereo branch to main. Before every push to main, check `git -C ..\PIVlab_website branch --show-current` (must be the temporary branch). After the push, `git diff --name-only <old main> origin/main -- . ':!docs'` must be empty.

1. **Look first.** `git fetch origin`, `git status --short`, `git rev-list --left-right --count HEAD...origin/stereo`, `git diff --cached --name-only` (must be empty).
2. **If GitHub's stereo is ahead** (the user pushes from other places): check that none of those commits touch a locally modified file (`git diff --name-only HEAD origin/stereo` vs. `git status`), then `git merge --ff-only origin/stereo`. If that is not a fast-forward or files overlap: stop and ask.
3. **Commit only `docs/` on stereo:** `git add -- docs`, check that nothing outside `docs/` is staged, `git commit` (message ends with the Co-Authored-By line), `git push origin stereo`. Never force-push.
4. **Separate folder with main:** `git worktree add -b <tmp-branch> ..\PIVlab_website origin/main` (the folder must not exist or be empty).
5. **Copy docs exactly:** `git -C ..\PIVlab_website checkout <C> -- docs`. Files that stereo deleted from `docs/` are listed by `git diff --name-only --diff-filter=D origin/main <C> -- docs` – remove exactly those with `git rm`. Then check: `git -C ..\PIVlab_website diff --cached --name-only` has nothing outside `docs/`, and `git -C ..\PIVlab_website diff --cached --quiet <C> -- docs` returns 0 (identical).
6. **Commit and publish:** commit in the worktree, then `git -C ..\PIVlab_website push origin HEAD:main` (a plain fast-forward; no pull request needed). If it is rejected because main moved: remove the worktree and start again at step 4.
7. **Check the live site:** GitHub rebuilds in 1–2 minutes – poll a changed file (background loop with a timeout), then crawl pivlab.de for 404s and check the changed pages in the browser (no console errors, structured data valid). GitHub's Jekyll 3.x is not the local preview: e.g. static files have `path`, not `relative_path`.
8. **Make stereo level with main again** (otherwise GitHub says "stereo is N commits behind main"): `git merge-tree --write-tree HEAD origin/main` must give a tree with **0 file changes** compared to HEAD; then `git merge --no-edit origin/main` (message ends with the Co-Authored-By line) and `git push origin stereo`. If the test merge would change files: stop and ask.
9. **Clean up:** `git worktree remove ..\PIVlab_website`, `git branch -d <tmp-branch>`. Report what went live, the commit IDs, and that the user's uncommitted files are untouched.

## Search engines

Every page should have a `description` in its front matter (shown by Google, read by AI assistants); top-level pages (home, downloads, ...) are found in the site search through `description` and `keywords` only. `sitemap.xml`, `robots.txt`, `llms.txt` and the search index (`assets/js/site-search.js`) are generated automatically.
