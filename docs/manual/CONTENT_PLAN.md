# PIVlab Manual — maintenance guide & content tracker

**Read this file first when working on the manual**, in this session or a fresh one. It is the
durable source of truth — more reliable than session memory, which may be summarized or
unavailable in a new session.

The manual is **content-complete**: all 29 topics are written and live. The job now is
**keeping it in step with the code**, so this file is organised around that.

---

## 1. Status watermark

| | |
|---|---|
| Content state | **Complete** — 29/29 topics live, no `status: "soon"` entries remain in `nav.js` |
| **Verified against source as of** | **commit `3505f82` (2026-11-05, branch `stereo`)** |
| Last full review | 2026-11-05 |

> **This watermark is the whole mechanism. When you update the manual to match new code,
> bump the commit hash and date above.** Everything in section 2 depends on it being honest.
>
> ⚠️ It was *not* bumped during the Oct-2026 API/stereo work even though the manual was being
> updated in the same commits — the 2026-11-05 review had to reconstruct two months of changes
> from `git log`. Bump it in the **same commit** as the manual change, not later.

## 2. Routine check — has PIVlab moved ahead of the manual?

Run this at the **start of every manual session**. It lists source commits made since the manual
was last verified:

```bash
git log --oneline 3505f82..HEAD -- +gui +piv +plot +pivlab +stereo +preproc +validate +calibrate +export +import +extract +mask +misc +postproc +roi +simulate +uncertainty +acquisition +opencv +wOFV PIVlab_GUI.m
```

**Keep that package list complete.** `+pivlab` and `+stereo` were added in Oct 2026 and the
original command did not list them — a new package is invisible to this check until it is added
here. `git diff --name-only <watermark>..HEAD | grep -oE '^\+[a-z]+/' | sort -u` shows the full set.

- **No output** → the manual is current. Say so and stop; do not invent work.
- **Output** → triage each commit with the map in section 3, update the affected pages, then
  bump the watermark.

To see what actually changed in the UI (the usual culprit — panel labels, new controls):

```bash
git diff 3505f82..HEAD -- +gui/generateUI.m +gui/generateMenu.m
```

Useful narrower probes:

```bash
# Did the derived-parameter list or its units change?  -> derive-spatial.html
git diff 3505f82..HEAD -- +plot/derivs_Callback.m +plot/derivative_calc.m

# Do the documented shortcuts still match the code?  -> shortcuts.html
grep -oE "Accelerator','[A-Z]'" +gui/generateMenu.m | sort -u          # the real list
grep -oE '<kbd>[A-Z]</kbd>' docs/manual/pages/shortcuts.html | sort -u # what we claim
```

### Changes that definitely require a manual edit

- A **new or renamed control** in `generateUI.m` → the page owning that panel (section 3).
- A **new `Accelerator`** in `generateMenu.m` → `pages/shortcuts.html`.
- A **new derived parameter** or changed unit string in `+plot/derivs_Callback.m` →
  `pages/derive-spatial.html`, **including a verified equation** (see section 6).
- A **new PIV algorithm** or changed per-algorithm control visibility in
  `+piv/algorithm_selection_Callback.m` → `pages/piv-settings.html`.
- A **previously dead feature becoming live** — several are currently documented as absent
  *because* they are commented out (see section 5). If one is re-enabled, the page must change.
- A **maths change** in `+plot/{qcrit,shear,strain}.m` → re-verify the equation, and add a
  version-changed callout like the existing v3.10 shear-rate one.

## 3. Source → page map (for triage)

| Source | Manual page |
|---|---|
| `generateUI.m:599-673` | `preprocessing.html` |
| `generateUI.m:675-847`, `+piv/algorithm_selection_Callback.m` | `piv-settings.html` |
| `generateUI.m:848-878`, `+piv/do_analys_Callback.m`, `+misc/clear_everything_Callback.m` | `analyze.html` |
| `generateUI.m:880-1002`, `+validate/vel_limit_Callback.m` | `validation-velocity.html` |
| `generateUI.m:1004-1068`, `+calibrate/calccali.m` | `spatial-calibration.html` |
| `generateUI.m:1070-1163`, `+plot/{derivs_Callback,derivative_calc,qcrit,shear,strain,LIC}.m` | `derive-spatial.html` |
| `generateUI.m:1182-1328` | `plot-appearance.html` |
| `generateUI.m:1330-1373`, `1770-1819`, `1922-1945`, `+export/` | `export.html` |
| `generateUI.m:1374-1423` | `extract-polyline.html` |
| `generateUI.m:1425-1494` | `markers.html` |
| `generateUI.m:1496-1553` | `statistics.html` |
| `generateUI.m:1555-1768` | `synthetic-images.html` |
| `generateUI.m:1820-1868` | `extract-area.html` |
| `generateUI.m:1872-1920` | `streamlines.html` |
| `generateUI.m:2008-2038` | `derive-temporal.html` |
| `generateUI.m:2042-2123` | `validation-image.html` |
| `generateUI.m:2125-2223+`, `+acquisition/` | `capture.html` |
| **`+pivlab/`** (the whole API package) | **`command-line.html`** |
| **`+stereo/`**, `generateUI.m:49` (CAM 1/2 toggle), `+import/stereo_import_Callback.m` | **`stereo-piv.html`**, plus the stereo `.note`s on derive-spatial / derive-temporal / export / extract-* / validation-velocity / statistics |
| `+simulate/` (3D generator, `simulate.part_img_3d_Callback`) | `synthetic-images.html` |
| `generateUI.m:2334-2496`, `cam_*_Callback.m` | `camera-calibration.html` |
| `generateUI.m:2496-2511` | `correlation-matrices.html` |
| `+preproc/PIVlab_preproc.m` | `roi.html` |
| `+mask/`, masking panel | `masking.html` |
| `+gui/image_import_dialog.m`, `+import/` | `sessions.html` |
| `+gui/generateMenu.m` (Accelerators) | `shortcuts.html` |
| `+gui/toggle_second_monitor_Callback.m` | `second-monitor.html` |
| `+piv/piv_FFTmulti.m` (correlation, uncertainty) | `derive-spatial.html#eq-analysis`, `validation-image.html` |
| `generateUI.m:71-76`, `+misc/toggle_parallel_Callback.m`, `+gui/veclick.m` | `interface.html` |
| *(no code source — user domain knowledge)* | `best-practices.html` |

Line numbers drift. Treat them as a starting hint, not gospel — grep for the panel tag
(`multip08`, `uipanel37`, …) if they no longer match.

## 4. How to add or update a page

1. **Verify against source first.** Never guess a button label, tooltip or menu path — read it in
   `+gui/generateUI.m` / `+gui/generateMenu.m`. This is the single most important rule here.
2. Write/edit `pages/<slug>.html`: `<article id="doc">` content only, three `<script>` tags at the
   bottom. Use [`pages/masking.html`](pages/masking.html) as the reference for structure and tone.
3. **New page only:** add it to `assets/js/nav.js` (`status: "soon"` → `"live"` plus a one-line
   `blurb`). The homepage "Start here" cards are auto-built from that file by `app.js`'s
   `buildStartHereCards()`, so `index.html` never needs editing.
   - If you ever add a page that is *not* yet written, restore the "Chapters marked soon aren't
     written yet" sentence to `index.html` — it was removed while the plan is 100% live. The
     `.soon`/`.badge` CSS and JS are still in place and working.
4. Add search records **by hand** to `assets/js/search-index.js` (see the warning in section 5).
5. Add a dated entry to the changelog (section 7) and **bump the watermark** (section 1).

## 5. House rules & hard-won gotchas

**Writing style**

- **⛔ Only write what a user needs in order to use a feature or understand a result.** This is
  the rule most often broken, so apply it as a test before every sentence: *would a reader act
  differently, or understand a result better, because of this sentence?* If not, it does not go
  in the manual. The user is **shortening** the manual, not growing it. Specifically, leave out:
  - **Rationale and background.** Why a design is the way it is, what the OS or MATLAB does, what
    something used to be. Real example that had to be removed on 2026-11-05 from
    `shortcuts.html`: *"That keeps them clear of Ctrl+A, Ctrl+C, Ctrl+V and Ctrl+Z, which the
    operating system and MATLAB's own text fields use for select-all, copy, paste and undo. They
    work wherever you are in the window, including while you are typing in a settings field."*
  - **Self-explanatory behaviour and small conveniences** — e.g. which folder a file dialog
    starts in, that a button does what its label says, that a shortcut is also shown in the menu.
  - **Negative statements** — "X has no shortcut", "Y is a button, not a shortcut", "everything
    not listed is reached through the menu only". State what exists; say nothing about what
    doesn't. (All three were removed from `shortcuts.html` on 2026-11-05.)
  - **Implementation detail** — that belongs in the dev log or in this file, not in the manual.

  When something feels worth recording but fails the test, put it in the changelog here (or the
  dev log) and mention it in the chat summary instead of writing it into a page.
- Task-focused, not an exhaustive parameter reference — explain what a user does and why.
- Prefer one real worked example (the Kármán-vortex rod mask) over abstract description.
- Use the shared components: `.split` (text beside screenshot), `ol.steps`, `table.ref`,
  `.note`/`.tip`/`.warn` callouts, `.eq`/`.eq-where` (equations), `.annot`+`.legend` (annotated
  screenshots).
- Flag anything disabled/WIP/experimental honestly rather than describing aspirational behaviour.
- **No math library.** The manual is dependency-free and must keep working opened from `file://`.
  Equations are plain HTML + Unicode with `<em>` variables.

**❌ Do not run `tools/build_search_index.mjs`.** It regenerates `text` keywords mechanically from
the slugified heading, discarding the far richer hand-curated keywords in the committed
`search-index.js`. It was tried on 2026-08-13 and reverted — it rewrote 816 lines and measurably
degraded search. **Add records by hand** in the existing style.

**❌ Do not auto-generate result/output screenshots.** Panel screenshots (`.png`) are captured from
the GUI; **result visuals come from the user** (`.jpg`) — auto-generated ones came out messy.

**Screenshots from MATLAB** — see the `reference_pivlab_gui_screenshots` memory. Two rules that
have each cost a whole session:
- Launch with `PIVlab_GUI(1)` (core-count argument), **never** bare `PIVlab_GUI` — otherwise it
  blocks on a "how many cores?" dialog and every subsequent MCP call hangs.
- Set `gui.put('batchModeActive',1)` right after loading images, before switching panels — several
  callbacks (e.g. switching the PIV algorithm to wOFV) otherwise open a confirmation dialog that
  hangs the MCP call and kills the figure.

**Features that are dead in code and deliberately undocumented** — if any of these is re-enabled,
the corresponding page needs updating:
- `uipanel43` "Calculate mean/sum" in `generateUI.m:1164-1181` — commented out. The live version
  of this feature is `derive-temporal.html` (multip22).
- `img_not_mask` checkbox — `Visible off`.
- `+plot/dcev.m` (Δ/complex-eigenvalue criterion) — orphaned; `derivative_calc.m:153` uses
  `plot.qcrit` instead. Only Q criterion exists; there is no λ₂, Δ or Γ.
- `calib_dolivedetect` — commented out in `generateUI.m:2475-2485` but still referenced by
  `cam_marker_setup_Callback.m:8` and session load/save. Latent bug, flagged separately.
- `+plot/draw_pixel_background_overlay.m:187-197` holds a **stale duplicate** of the derived-
  parameter label lists that stops at item 12 (no Uncertainty). If the parameter list changes,
  this copy needs changing too — it is used to re-label the colorbar.

**Keyboard shortcuts live in `+gui/key_press.m`, not in menu accelerators.** Since 2026-11-05 all
shortcuts are **Ctrl+Shift+key**. Matlab's `uimenu` `Accelerator` can only do Ctrl+key, so there
are no `Accelerator` properties left — `gui.key_press` (the figure's `WindowKeyPressFcn`) maps each
key to a **Tag** and `gui.run_shortcut` clicks that menu entry or control. Consequences to respect:

- **The single source of truth is the `switch` in `+gui/key_press.m`.** To check the manual against
  the code, compare that switch with the tables in `docs/manual/pages/shortcuts.html`.
- **A shortcut must never do more than the mouse.** `gui.run_shortcut` refuses when the element is
  missing, disabled (PIVlab busy, see `gui.toolsavailable`) or hidden (Basic mode, 2D mode). Keep
  that guard if the file is rewritten — a raw callback call would bypass the busy lock.
- **The shortcut text is part of the menu label** (`'ANALYZE!   (Ctrl+Shift+A)'`) because dropping
  `Accelerator` also dropped Matlab's automatic hint. Label, Tag, `key_press` and the manual page
  must be changed together.
- `PIVlab_GUI.m` uses **`WindowKeyPressFcn`**, not `KeyPressFcn`, so shortcuts also work while an
  edit field has the focus; `gui.reset_gui_Callback` **re-assigns** it instead of clearing it.
- **Undocumented display helpers** share the same switch: `C` crosshair, `X` sharpness,
  `-`/`0` autocontrast limits, `L` colour scale log/linear (`L` was `K` until `K` became
  "define masks"). Leave these out of the manual unless the user asks.

**⚠️ A tooltip is not a keyboard shortcut.** On 2026-11-05 a bogus `Ctrl+K` row ("switch between
camera 1 and camera 2") was found in `shortcuts.html`, added during the stereo work in `424936a`:
no such accelerator existed, and the `CAM 1`/`CAM 2` **pushbutton** tooltip had been copied into the
shortcuts table. Never transcribe a tooltip into the shortcut list.

**The printable shortcuts PDF is gone.** `help/PIVlab_shortcuts.pdf` and `+misc/shortcuts_Callback.m`
were deleted on 2026-11-05 — the PDF went stale (it still claimed Ctrl+E covered masking) because it
was a second place to maintain. `Learn! → List keyboard shortcuts` still exists, but now opens
`https://www.pivlab.de/manual/pages/shortcuts.html` in the browser (`+gui/shortcuts_Callback.m`).
So `shortcuts.html` plus the menu labels are the only shortcut documentation. **Do not reintroduce a
separate printable list** — a second copy is what went stale last time.

## 6. Equations — verification standard

`derive-spatial.html#equations` documents the exact maths behind every derived parameter. If you
touch it, **repeat this standard**: read the formula from `+plot/*.m`, read any MATLAB built-in
from its own source (e.g.
`C:\Program Files\MATLAB\R20xx\toolbox\matlab\graphics\graphics\specgraph\curl.m`) rather than
trusting recall, *then* check it against the standard fluid-mechanics definition.

Findings worth never re-deriving:

- **`curl` returns `curlz = ∂v/∂x − ∂u/∂y`, which IS the vorticity** (`curl.m:27-33`). The
  *second* output `cav` is the half-value angular velocity; a claim that `curlz = 2ω` is wrong.
  PIVlab's `-curl(...)` (`derivative_calc.m:121`) cancels the downward image y-axis, so the
  documented `ω = ∂v/∂x − ∂u/∂y`, positive = counter-clockwise on screen, is correct.
  **Do not "fix" this sign.**
- `qcrit.m` is algebraically identical to the standard `Q = ½(‖Ω‖² − ‖S‖²)` — verified by
  expanding component-by-component.
- Vector direction: default axes are x→right, y→bottom (`generateUI.m:1051,1057`), so 0°=right,
  +90°=down, ±180°=left, −90°=up — angles increase *clockwise on screen*, inverting if the user
  selects "y increases towards the top".
- Correlation coefficient is computed **only on the final pass, from already-deformed windows**
  (`piv_FFTmulti.m:345-348`) — how well the windows match *after* deformation, not raw similarity.
- Uncertainty = particle-image disparity, Sciacchitano/Wieneke/Scarano 2013 (citation in the source
  comment at `piv_FFTmulti.m:644-651`); its dual meaning (real uncertainty vs. sub-window velocity
  non-uniformity, from `:637-643`) is documented as a callout.
- LIC implementation credit is in-code at `LIC.m:30-37` (Nima Bigdely Shamlo, Matlab VFV Toolbox
  1.0, SDSU); the technique originates with Cabral & Leedom, SIGGRAPH '93.
- "Simple strain rate" is `∂u/∂x − ∂v/∂y`, **not** a standard strain rate. Shear rate changed
  meaning in v3.10 (was `∂v/∂x + ∂u/∂y`) — the page carries a `.warn` about this.

## 7. Changelog

Newest first. **Add an entry whenever you change the manual**, and bump the watermark.

### 2026-11-05 — keyboard shortcuts reworked to Ctrl+Shift
All shortcuts moved from Ctrl+key menu accelerators to **Ctrl+Shift+key**, because Ctrl+A/C/V/Z are
taken by the OS and by Matlab's text fields, so the old accelerators were unreliable while an edit
field had the focus. See the shortcut rules in section 5 for the mechanism and the constraints.

Code: all `Accelerator` properties removed from `+gui/generateMenu.m` and replaced by `Tag`s plus
the shortcut in the label; `+gui/key_press.m` rewritten as the single shortcut table; new
`+gui/run_shortcut.m`; `PIVlab_GUI.m` switched to `WindowKeyPressFcn`; `gui.reset_gui_Callback`
re-assigns it. `help/PIVlab_shortcuts.pdf` and `+misc/shortcuts_Callback.m` deleted;
`Learn! → List keyboard shortcuts` kept, but now opens the manual page in the browser
(new `+gui/shortcuts_Callback.m`).

**Covered by `unittests/test_gui_shortcuts.m`** (11 tests, ~70 s, group `gui`). It checks each of
the 18 panel keys against the menu entry whose *label* announces that key — taking the expected
panel from the label, not from a list in the test, so a key wired to the wrong entry fails too —
plus the camera keys in real stereo mode, the busy and modifier guards, that `generateMenu.m` has
no `Accelerator` again, and that **`shortcuts.html` lists exactly the keys `key_press.m` handles**.
That last one is the guard against the manual drifting away from the code.

Two things the test must keep doing, both learned the hard way:
- **Never send `Ctrl+Shift+O` or `Ctrl+Shift+H` as a key in a test.** `O` opens the file dialog,
  which `PIVlabTestMode` does *not* answer — the run then hangs until someone clicks Cancel by
  hand (it did, on 2026-11-05). `H` opens a web browser. Both are checked through their target.
- **Assert the parsed lists are non-empty.** Comparing two regexp-parsed key lists passes happily
  when both parsers return nothing.

`Ctrl+Shift+O` is reachable in **2D mode on purpose** — that is how a stereo session is started,
so it is not gated on stereo mode. Only the two camera keys are.

Shortcuts **added** for features that had none: `K` define masks, `W` Stereo-PIV panel,
`O` import stereo images, `1`/`2` show camera 1 / camera 2, `F` image-based validation (it was the
only validation panel without one). All other letters kept their meaning, just with Shift. The
hidden colour-scale toggle moved `K` → `L` to free `K` for masking.

Manual: `shortcuts.html` rewritten as six grouped tables, with the three negative sentences the
user objected to removed ("Masking has no shortcut", "… is a button, not a shortcut", "Everything
not listed above … is reached through the menu only") — the page now just states what exists.
A paragraph explaining *why* the shortcuts use Ctrl+Shift was then also removed at the user's
request: rationale has no value for the reader. The page is down to two sentences of prose plus
the tables. See the hardened writing rule at the top of section 5 — it has now been broken twice.
Inline `(Ctrl+…)` references updated on 15 pages; `masking.html`, `validation-image.html` and
`stereo-piv.html` gained their new shortcuts. **Left untouched on purpose:** `sessions.html:78`
still says `Ctrl+A`, because that is the operating system's select-all in the file dialog, not a
PIVlab shortcut.

### 2026-11-05 — review of the whole `stereo` branch + shortcuts fix (`3505f82`)
Reconstructed two months of manual changes that had been made alongside the code without changelog
entries or a watermark bump (see the entries below, which were written during this review). Also:

- **Found a factual error**: the `Ctrl+K` row in `shortcuts.html` named an accelerator that did not
  exist (see the tooltip warning in section 5). Superseded the same day by the Ctrl+Shift rework
  above, which gives the camera switch a real shortcut.
- Verified the remaining 16 rows of `shortcuts.html` against `Accelerator','X'` in
  `generateMenu.m` — all correct. `Ctrl+G` changed target (`part_img_sett_Callback` →
  `part_img_3d_Callback`) but the page's wording "Synthetic particle image generation" still fits.
- Added `+pivlab` and `+stereo` to the section 2 drift command; they had been invisible to it.
- Updated the watermark to `3505f82` and the topic count to 29.

### 2026-10-01 → 2026-10-28 — PIVlab 4: command-line API and Stereo-PIV
The two largest manual additions since the initial build; written incrementally in the same commits
as the code, which is why no separate changelog entries existed until the 2026-11-05 review.

- **New page `command-line.html`** (nav section "Data", after Exporting results) documenting the
  `+pivlab` API package: ten-line workflow, the function list, the result struct, options,
  settings, camera calibration, stereo, and why pre-processing does not create new image files.
  Commits `56e9446`, `a5662f5`, `c04f246`, `26ebf86`, `1c9e149`.
- **`stereo-piv.html` rewritten from a 30-line "not implemented" stub into the full 300-line
  guide** (`#idea`, `#arrangement`, `#cameras`, then the numbered workflow `#import`, `#lens`,
  `#calibration`, `#disparity`, `#analysis`, `#w`). Nav label and blurb changed from
  "Stereo PIV settings / Not implemented yet" to "Stereo-PIV (2D3C)". New screenshots
  `stereo-piv/panel.png` and `stereo-piv/camera-switch.png`. ~14 commits, `424936a` → `05aa433`.
- **Stereo `.note` cross-references added to the 2D pages** so each one states what changes in
  stereo mode: `derive-spatial.html` (extra `w component`, 3D magnitude), `derive-temporal.html`
  (operations include w; TKE frame holds `0.5·var(w)`; make mean frames *after* validation),
  `export.html` (w in ASCII/Tecplot/VTK/MAT/workspace), `extract-area.html`,
  `extract-polyline.html` (tangent/normal stay in the light-sheet plane), `validation-velocity.html`
  (limits tested on the 3D result), `statistics.html`. All link to `stereo-piv.html#w`.
- **`capture.html#stereo`** — two cameras, the "Stereo" checkbox, Swap cameras, cam1/cam2 naming,
  missed-trigger warning. `capture/panel.png` renewed; `capture/stereo-live.png` was made with
  **simulated** cameras (`unittests/mocks_imaq`) showing the user's real OPTOcam board images —
  **replace it with a real-rig screenshot when one is available**.
- **`camera-calibration.html`** — no camera sub-menus any more; the panels act on the active
  camera. Plus the checker-size section (own entry below).
- **`synthetic-images.html` largely rewritten** for the combined 2D/3D particle image generator
  (`1c9e149`): one panel with simple / one camera / stereo modes, sphere wake and free jet via
  `simulate.flow_simulation_3d`. The old 2D-only generator is gone, so the previous "5 flow types
  / Membrane has no sub-panel" note no longer applies.
- **`sessions.html`** updated for the new `+gui/image_import_dialog.m` (replaces `uipickfiles`).
- New result images `plot-appearance/vector-magnitude.jpg` and `vector-magnitude-uniform.jpg`.

### 2026-10-24 — checker size section (branch `stereo`, not committed)
New `<h3 id="checker-size">` "Choosing the checker size" with a `.warn` on the limits of the ChArUco
detection in `camera-calibration.html` (`#markerboard`), plus one hand-written search record.
Wrongly decoded markers are deliberately not mentioned (user's decision: fixed in the code instead,
`+preproc/cam_filter_charuco_corners.m`). Board limit raised from 1000 to 2000 checkers
(`+preproc/cam_generateboard_Callback.m`). Numbers
from a Monte Carlo study with synthetic OPTOcam 2/80 board images (`D:\PIV Data\charuco_checker_size_study`,
README there). The 2000-checker limit is the check in `+preproc/cam_generateboard_Callback.m`.
Watermark **not** bumped: only this section was written, the rest of the manual was not re-verified.

### 2026-10-24 — stereo acquisition
`capture.html#stereo` (two cameras, "Stereo" checkbox, Swap cameras, cam1/cam2, missed-trigger warning);
`stereo-piv.html` import step links to it. `assets/img/capture/panel.png` renewed (new "Stereo" checkbox).
`assets/img/capture/stereo-live.png` was made with simulated cameras (`unittests/mocks_imaq`) showing the
user's real OPTOcam board images (`D:\PIV Data\stereotest_optocam2\aligned_board`) with live ChArUco
detection — replace it with a screenshot from the real rig when available.

### 2026-08-13 — equations for every derived parameter (`24fe6ce`)
New `#equations` section on `derive-spatial.html` (three `<h3>`s: velocity-based / gradient-based /
carried over from the analysis), new `.eq` + `.eq-where` CSS component, four hand-written search
records. Full verification standard and findings recorded in section 6. Also added a `.tip` to the
smoothing section (smoothing runs *before* derivatives, so it damps the noise that differentiation
amplifies).

### 2026-07-20 — undocumented content pass (`0c422de`, `b0d8ab4`)
⚠️ **Changelog gap.** These two commits edited `plot-appearance.html`, `derive-temporal.html`,
`extract-polyline.html`, `shortcuts.html` and `search-index.js` without a CONTENT_PLAN entry. Scope
not reconstructed. This gap is exactly what the section 1 watermark exists to prevent.

### 2026-07-09 — site chrome redesign + calibration warning (`89fa4f5`, `f412092`)
Two-tier header matching pivlab.de: dark hero band with the real PIVlab logo artwork
(`assets/img/header-hero.png`, cropped from the website's `background.png`) over a sticky lime
action bar, with the round OPTOLUTION mark linking to optolution.com. Hero and action bar are
**separate `<body>` siblings** — nesting them in one wrapper capped the sticky bar's range to the
wrapper height, so it scrolled away. Added a `.warn` to `spatial-calibration.html` (a dedicated
calibration image must match the PIV images' pixel dimensions and sit exactly in the laser sheet).
Removed the stale "Chapters marked soon aren't written yet" sentence from `index.html` after
confirming zero `"soon"` entries remain (see section 4 step 3 if that ever changes).

### 2026-07-08 — "Tips & tricks" advice pass
User supplied a distillation of years of their own PIVlab Google Group support advice. **Unlike
every other page, this content is not verified against `generateUI.m`** — it is author/community
domain knowledge, treated as authoritative and not embellished. New `best-practices.html`
(five-stage mindset, seeding/image quality, diagnose-before-you-tune checklist, troubleshooting-by-
symptom table) plus a `#tips` section on `piv-settings.html`; smaller additions to
`preprocessing.html`, `roi.html`, `validation-velocity.html`, `spatial-calibration.html`,
`correlation-matrices.html`. Later the same day, a `#tuning` section on `validation-velocity.html`
(tune one filter at a time with others disabled, check across several frames, then combine).

**Two standing user corrections for any future advice-style content:**
1. **Do not quote or attribute the user.** No blockquote/citation component — it is awkward since
   the user *is* William Thielicke. Fold guidance into plain paraphrased prose.
2. For Δt/displacement selection the actionable technique is **empirical, not calculated**: enter a
   rough guess, run a quick test analysis, click a vector, read the displacement from the Tools
   panel's "Current point" readout (`interface.html#tools`).

**Correction:** removed the `#whatmask` section from `masking.html` — it claimed "PIVlab has no
true dynamic masking", which is **wrong**: Automatic-mask Expert generators re-detect per frame,
and masks can be moved/re-drawn frame to frame. **Do not reintroduce this claim.**

### 2026-07-08 — user-provided result images
16 clean, properly-masked result/output screenshots supplied by the user, placed as full-width
`<figure>`s (panel `.png` captures stay). Established the standing rule: **result visuals come from
the user.** `assets/img/markers/panel.png` is now orphaned/unused.

### 2026-07-07 — screenshot pass
All 24 P1/P2/P3 pages got at least one real screenshot (33 images) in one MATLAB session using
`PIVlab_GUI(1)` + `batchModeActive=1`. A real single-frame DCC analysis was run first (~7s) so
validation/statistics/derive/export panels show genuine populated data instead of "N/A". Capturing
`capture.html`'s panel live revealed more real controls than the static code read had shown.

### 2026-07-07/08 — initial build (`7b7854e`)
All 28 topics written and verified against source. Per-page verification notes are preserved in
section 8.

---

## 8. Coverage map — what each page covers and what was verified

All topics complete. Kept for the per-page verification detail, which feeds the triage map above.

### Getting started
- **Introduction** — `index.html` (landing page, not a menu item).
- **Interface & workflow** — `interface.html`. Window layout, left-to-right menu workflow, Tools
  panel (frame slider, Toggle, zoom/pan, parallel toggle per `+misc/toggle_parallel_Callback.m`,
  Current-point readout click-driven per `+gui/veclick.m`), quick-access strip
  (`generateUI.m:71-76`), Basic vs Advanced mode. Carries an **annotated overview**: user's
  `gui-overview.jpg` (1248×918) with an inline-SVG overlay of 6 numbered lime boxes + a `.legend`.
  Technique: the `.annot` wrapper sizes to the image so `viewBox="0 0 1248 918"` maps 1:1 —
  reusable for future annotated shots.
- **Sessions: new/load/save** — `sessions.html`. 3 image-sequencing styles
  (`+gui/image_import_dialog.m`), image list & Remove images (clears results, per
  `+import/remove_images_from_list.m`), and the Session-vs-Settings distinction.

### Image settings
- **Camera calibration & rectification** — `camera-calibration.html`. multip26/27/28. No camera sub
  menus: the panels work on the active camera (CAM 1 / CAM 2 toggle in stereo mode).
- **Image pre-processing** — `preprocessing.html`. CLAHE, highpass, intensity capping, Wiener2,
  auto contrast stretch, background subtraction. The preview button only re-renders a preview;
  filters actually apply to all frames at analysis time.
- **Region of interest** — `roi.html`. ROI genuinely *crops* the pixel array before processing
  (`+preproc/PIVlab_preproc.m:33-45`), unlike masking's post-hoc NaN — the page has a comparison
  table. One global rectangle per session (`roirect`), not per-frame.
- **Masking** — `masking.html`. Includes overlapping-mask even-odd behaviour.

### Analysis
- **PIV settings** — `piv-settings.html`. Per-algorithm control visibility differs by algorithm and
  is documented in a table. Plus the `#tips` advice section.
- **Stereo-PIV (2D3C)** — `stereo-piv.html`. **No longer a stub** (it was one until Oct 2026):
  full 300-line guide — camera arrangement, one session/two cameras with the `CAM 1`/`CAM 2`
  toggle, then the numbered workflow import → per-camera lens calibration → stereo calibration →
  disparity correction → analysis → working with W. Source is the `+stereo` package.
- **Running the analysis** — `analyze.html`. "Analyze all frames" relabels to "Start ensemble
  analysis" for the Ensemble algorithm; "Clear all results" clears only `resultslist`/`derived`,
  not masks/ROI/settings.

### Validation
- **Velocity-based** — `validation-velocity.html`. Scatter plot is u-vs-v *velocity* space, not
  image space. Colour legend cross-links to `plot-appearance.html` (at `:146`). Has `#tuning`.
- **Image-based** — `validation-image.html`. Mirrors the velocity panel but with 3 image-quality
  filters (low contrast, bright objects, correlation coefficient).

### Spatial calibration
- **Calibrating pixels to mm** — `spatial-calibration.html`. Time-step = 0 triggers
  `displacement_only` mode. Carries the "calibration image must match your setup" warning.

### Plot & post-processing
- **Deriving spatial parameters** — `derive-spatial.html`. 13-item parameter list + units, and the
  full `#equations` section (section 6).
- **Deriving temporal parameters** — `derive-temporal.html`. The **live** version of the mean/sum
  feature that is commented out in multip08; gained stdev/TKE.
- **Modifying plot appearance** — `plot-appearance.html`. The hub that both validation pages and
  masking reference for colours/transparency.
- **Streamlines** — `streamlines.html`. Leads with the non-obvious "streamlines are global (all
  frames)" behaviour.
- **Markers / distance / angle** — `markers.html`. Marker persistence survives "New session",
  cleared only on PIVlab restart.
- **Correlation matrices** — `correlation-matrices.html`. Plus a peak-shape interpretation table.
- **Second monitor display** — `second-monitor.html`. Deliberately short, labelled "experimental"
  per the menu's own wording; single-monitor fallback confirmed in code.

### Extractions, statistics, simulation, data, acquisition, reference
- **Parameters from poly-line** — `extract-polyline.html`. Draw interaction taken from a
  commented-out-but-accurate instructional label (disabled for space, not because behaviour changed).
- **Parameters from area** — `extract-area.html`. Computes a single *average* over the area, not a
  profile — the key difference from poly-line.
- **Statistics** — `statistics.html`.
- **Synthetic particle images** — `synthetic-images.html`. Rewritten Oct 2026 for the **combined
  2D/3D generator** (`simulate.part_img_3d_Callback`, `simulate.flow_simulation_3d`): one panel
  with simple / one camera / stereo modes, sphere wake and free jet. The old 2D-only generator
  and its "5 flow types / Membrane" structure are gone.
- **Exporting results** — `export.html`. All 6 panels. Workspace export fails *silently* with no
  results, unlike `pixel_data.m` which shows an error dialog — documented as a warning.
- **Command line (API)** — `command-line.html`. The `+pivlab` package: ten-line workflow, function
  list, result struct, options, settings, camera calibration, stereo, and why pre-processing does
  not write new image files. Added Oct 2026 with the PIVlab 4 API.
- **Capturing images** — `capture.html`. Still the **thinnest page in the manual** (126 lines, 3
  sections: `#workflow`, `#stereo`, `#webcam`). Large and hardware-specific (~38 files in
  `+acquisition`); deliberately kept at workflow-shape level and linked out to
  `docs/_wiki/4_synchronizer_laser.md` and `5_camera_setup.md` rather than guessing hardware
  behaviour. The *software* side (panel-by-panel) could be expanded without a rig — see the note
  at the end of section 8.
- **Keyboard shortcuts** — `shortcuts.html`. The 22 Ctrl+Shift shortcuts, grouped by workflow.
  Source of truth is the `switch` in `+gui/key_press.m` (see the shortcut rules in section 5).
- **Best practices & troubleshooting** — `best-practices.html`. User domain knowledge, not code.

### Explicitly out of scope
Learn! → Tutorial videos, Forum, Website, How to cite, About — footer/Introduction links, not
dedicated pages.

### Known gaps / candidates for future work

- **`capture.html` is thin relative to the feature.** The acquisition GUI (multip24 + the
  `+acquisition` package) has far more software surface than the page covers: camera selection and
  settings, live image, autofocus/sharpness aids, the synchronizer and laser controls, capture
  modes, file naming and storage. All of that is readable in the source and can be documented
  **without hardware**; only the "does this physically behave as described" claims need the rig.
  If this is picked up, follow the normal rule — verify every label against `generateUI.m` and the
  `+acquisition` callbacks, keep hardware-specific wiring in the wiki pages, and mark anything
  unverifiable without the rig rather than guessing.
- **`capture/stereo-live.png` is a simulated-camera screenshot** — swap in a real-rig capture when
  one exists (see the 2026-10-24 entry).
- The user has recorded **YouTube tutorials for image acquisition**. Claude cannot watch video; if
  that material should feed the manual, it needs a transcript or the user's own notes as input —
  and it would then be user-supplied domain knowledge, i.e. the same category as
  `best-practices.html`, not code-verified content.
