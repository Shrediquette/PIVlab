/*
 * svg_text_to_paths.mjs - replace the <text> elements of the stereo-PIV workflow drawings by glyph outlines,
 * so that the SVG files look the same everywhere, without the fonts installed (e.g. on Wikimedia Commons, which
 * renders SVG with its own fonts).
 *
 * Usage (from the manual/ folder):
 *     node tools/svg_text_to_paths.mjs <font.ttf> <outdir> <file.svg> [more.svg ...]
 * Font: a TrueType font with glyf outlines, e.g. Roboto-Regular.ttf (Apache License 2.0; MATLAB ships it in
 * toolbox/vision/visionutilities/visioninit/+fonts). Bold text is drawn with an outline stroke, italic text with
 * a 12 degree slant (only the regular font is needed). Characters missing in the font (e.g. U+2713, U+2297) are
 * drawn as simple shapes. No kerning. Handles only the plain <text> elements written by
 * stereo_workflow_drawings.mjs (no <tspan>, no entities).
 * Requires Node 16+, no other dependencies.
 */
import fs from 'node:fs';
import path from 'node:path';

const [fontFile, outDir, ...files] = process.argv.slice(2);
if (!fontFile || !outDir || !files.length) {
  console.error('usage: node svg_text_to_paths.mjs <font.ttf> <outdir> <file.svg> ...');
  process.exit(1);
}

// ---------- minimal TrueType reader (glyf outlines, cmap 4/12, hmtx) ----------
const buf = fs.readFileSync(fontFile);
const u16 = o => buf.readUInt16BE(o), s16 = o => buf.readInt16BE(o), u32 = o => buf.readUInt32BE(o);
const tables = {};
for (let i = 0; i < u16(4); i++) { const r = 12 + 16 * i; tables[buf.toString('latin1', r, r + 4)] = u32(r + 8); }
for (const t of ['head', 'maxp', 'loca', 'glyf', 'cmap', 'hhea', 'hmtx']) if (tables[t] === undefined) throw new Error(`font: no ${t} table (TrueType outlines needed)`);
const upem = u16(tables.head + 18), longLoca = s16(tables.head + 50) === 1, numGlyphs = u16(tables.maxp + 4);
const numHMetrics = u16(tables.hhea + 34);
const loca = i => longLoca ? u32(tables.loca + 4 * i) : 2 * u16(tables.loca + 2 * i);
const advance = g => u16(tables.hmtx + 4 * Math.min(g, numHMetrics - 1));
const cmap = new Map();
{
  const c = tables.cmap, n = u16(c + 2);
  const subs = [];
  for (let i = 0; i < n; i++) subs.push({ p: u16(c + 4 + 8 * i), e: u16(c + 6 + 8 * i), o: c + u32(c + 8 + 8 * i) });
  const pick = subs.find(s => s.p === 3 && s.e === 10 && u16(s.o) === 12) || subs.find(s => s.p === 3 && s.e === 1 && u16(s.o) === 4) || subs.find(s => u16(s.o) === 4);
  if (u16(pick.o) === 12) {
    for (let i = 0; i < u32(pick.o + 12); i++) {
      const g = pick.o + 16 + 12 * i, start = u32(g), end = u32(g + 4), gid = u32(g + 8);
      for (let ch = start; ch <= end; ch++) cmap.set(ch, gid + ch - start);
    }
  } else {
    const o = pick.o, segX2 = u16(o + 6), ends = o + 14, starts = ends + segX2 + 2, deltas = starts + segX2, ranges = deltas + segX2;
    for (let i = 0; i < segX2 / 2; i++) {
      const end = u16(ends + 2 * i), start = u16(starts + 2 * i), delta = s16(deltas + 2 * i), ro = u16(ranges + 2 * i);
      for (let ch = start; ch <= end && ch !== 0xffff; ch++) {
        let gid;
        if (ro === 0) gid = (ch + delta) & 0xffff;
        else { const gi = u16(ranges + 2 * i + ro + 2 * (ch - start)); gid = gi ? (gi + delta) & 0xffff : 0; }
        if (gid) cmap.set(ch, gid);
      }
    }
  }
}
// glyph outline -> list of contours, each a list of {x, y, on}
function contours(g, depth = 0) {
  if (g >= numGlyphs || depth > 8) return [];
  const off = tables.glyf + loca(g), len = loca(g + 1) - loca(g);
  if (len === 0) return [];
  const nc = s16(off);
  if (nc < 0) { // composite glyph
    let p = off + 10, out = [], more = true;
    while (more) {
      const flags = u16(p), gi = u16(p + 2); p += 4;
      let dx, dy;
      if (flags & 1) { dx = s16(p); dy = s16(p + 2); p += 4; } else { dx = buf.readInt8(p); dy = buf.readInt8(p + 1); p += 2; }
      let a = 1, b = 0, c = 0, d = 1;
      const f2 = o => s16(o) / 16384;
      if (flags & 8) { a = d = f2(p); p += 2; } else if (flags & 0x40) { a = f2(p); d = f2(p + 2); p += 4; } else if (flags & 0x80) { a = f2(p); b = f2(p + 2); c = f2(p + 4); d = f2(p + 6); p += 8; }
      for (const ct of contours(gi, depth + 1)) out.push(ct.map(q => ({ x: a * q.x + c * q.y + dx, y: b * q.x + d * q.y + dy, on: q.on })));
      more = !!(flags & 0x20);
    }
    return out;
  }
  const endPts = []; for (let i = 0; i < nc; i++) endPts.push(u16(off + 10 + 2 * i));
  const nPts = nc ? endPts[nc - 1] + 1 : 0;
  let p = off + 10 + 2 * nc; p += 2 + u16(p);
  const flags = [];
  while (flags.length < nPts) { const f = buf[p++]; flags.push(f); if (f & 8) { let r = buf[p++]; while (r--) flags.push(f); } }
  const xs = [], ys = [];
  let v = 0;
  for (const f of flags) { if (f & 2) { const d = buf[p++]; v += f & 16 ? d : -d; } else if (!(f & 16)) { v += s16(p); p += 2; } xs.push(v); }
  v = 0;
  for (const f of flags) { if (f & 4) { const d = buf[p++]; v += f & 32 ? d : -d; } else if (!(f & 32)) { v += s16(p); p += 2; } ys.push(v); }
  const out = []; let s = 0;
  for (const e of endPts) { out.push(xs.slice(s, e + 1).map((x, i) => ({ x, y: ys[s + i], on: !!(flags[s + i] & 1) }))); s = e + 1; }
  return out;
}

// ---------- text -> path data ----------
const r = n => Math.round(n * 100) / 100;
// placeholder shapes for characters the font does not have (in em units, y up, baseline 0)
const fallback = {
  0x2713: { adv: 0.62, d: 'M0.08,0.33 L0.22,0.17 L0.54,0.62', stroke: 0.07 },                       // check mark
  0x2297: { adv: 0.82, circle: [0.41, 0.27, 0.3], d: 'M0.2,0.06 L0.62,0.48 M0.62,0.06 L0.2,0.48', stroke: 0.05 }, // circled times
  0x2192: { adv: 0.9, d: 'M0.08,0.3 L0.78,0.3 M0.58,0.12 L0.8,0.3 L0.58,0.48', stroke: 0.065 },       // right arrow
};
function textToPath(str, x, y, size, anchor, slant) {
  const s = size / upem, chars = [...str];
  const widths = chars.map(ch => { const cp = ch.codePointAt(0); return cmap.has(cp) ? advance(cmap.get(cp)) * s : fallback[cp] ? fallback[cp].adv * size : advance(0) * s; });
  const total = widths.reduce((a, b) => a + b, 0);
  let pen = x - (anchor === 'middle' ? total / 2 : anchor === 'end' ? total : 0);
  const k = slant ? Math.tan(12 * Math.PI / 180) : 0;
  const P = (gx, gy) => [r(pen + gx + k * gy), r(y - gy)]; // gx, gy in px, y up
  let fill = '', strokes = '';
  chars.forEach((ch, i) => {
    const cp = ch.codePointAt(0);
    if (cmap.has(cp)) {
      for (const ct of contours(cmap.get(cp))) {
        if (!ct.length) continue;
        // start at an on-curve point (or the midpoint of two off-curve points)
        let pts = ct.map(q => ({ x: q.x * s, y: q.y * s, on: q.on }));
        let i0 = pts.findIndex(q => q.on);
        if (i0 < 0) { pts.unshift({ x: (pts[0].x + pts.at(-1).x) / 2, y: (pts[0].y + pts.at(-1).y) / 2, on: true }); i0 = 0; }
        pts = pts.slice(i0).concat(pts.slice(0, i0));
        fill += 'M' + P(pts[0].x, pts[0].y).join(',');
        let ctrl = null;
        for (let j = 1; j <= pts.length; j++) {
          const q = pts[j % pts.length];
          if (q.on) { fill += ctrl ? 'Q' + P(ctrl.x, ctrl.y).join(',') + ' ' + P(q.x, q.y).join(',') : 'L' + P(q.x, q.y).join(','); ctrl = null; }
          else if (ctrl) { const m = { x: (ctrl.x + q.x) / 2, y: (ctrl.y + q.y) / 2 }; fill += 'Q' + P(ctrl.x, ctrl.y).join(',') + ' ' + P(m.x, m.y).join(','); ctrl = q; }
          else ctrl = q;
        }
        fill += 'Z';
      }
    } else if (fallback[cp]) {
      const f = fallback[cp];
      strokes += f.d.replace(/([ML])([\d.]+),([\d.]+)/g, (m, c, a, b) => c + P(+a * size, +b * size).join(','));
      if (f.circle) { const [cx, cy, rr] = f.circle, R = rr * size, c0 = P(cx * size - R, cy * size); strokes += `M${c0} a${r(R)},${r(R)} 0 1,0 ${r(2 * R)},0 a${r(R)},${r(R)} 0 1,0 ${r(-2 * R)},0`; }
    }
    pen += widths[i];
  });
  return { fill, strokes, strokeWidth: (fallback[[...str].map(c => c.codePointAt(0)).find(c => fallback[c])] || {}).stroke * size || 0 };
}
const attr = (tag, name) => (tag.match(new RegExp(`\\s${name}="([^"]*)"`)) || [])[1];
function outline(svg) {
  let n = 0;
  const out = svg.replace(/<text([^>]*)>([^<]*)<\/text>/g, (m, a, content) => {
    if (!content.trim()) return '';
    n++;
    const size = +attr(a, 'font-size') || 16, fillC = attr(a, 'fill') || '#000', bold = /^(600|700|bold)$/.test(attr(a, 'font-weight') || '');
    const { fill, strokes, strokeWidth } = textToPath(content, +attr(a, 'x') || 0, +attr(a, 'y') || 0, size, attr(a, 'text-anchor') || 'start', attr(a, 'font-style') === 'italic');
    let s = fill ? `<path d="${fill}" fill="${fillC}"${bold ? ` stroke="${fillC}" stroke-width="${r(size * 0.04)}" stroke-linejoin="round"` : ''}/>` : '';
    if (strokes) s += `<path d="${strokes}" fill="none" stroke="${fillC}" stroke-width="${r(strokeWidth)}" stroke-linecap="round" stroke-linejoin="round"/>`;
    return `<g aria-label="${content.replace(/"/g, '&quot;')}">${s}</g>`;
  });
  return { out: out.replace(/ font-family="[^"]*"/g, ''), n };
}

fs.mkdirSync(outDir, { recursive: true });
for (const f of files) {
  const { out, n } = outline(fs.readFileSync(f, 'utf8'));
  const target = path.join(outDir, path.basename(f));
  fs.writeFileSync(target, out);
  console.log(`${path.basename(f)}: ${n} texts -> paths, ${(out.length / 1024).toFixed(0)} kB, <text> left: ${(out.match(/<text/g) || []).length}`);
}
