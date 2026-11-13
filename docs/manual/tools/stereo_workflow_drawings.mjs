/*
 * stereo_workflow_drawings.mjs - the illustrated stereo-PIV workflow (8 drawings, flat low-colour SVG),
 * an overview of all eight (2 x 4) and a 1200 x 630 card for link previews.
 * Used by the manual (pages/stereo-piv.html) and the website (wiki: How stereo-PIV works).
 *
 * Usage (from the manual/ folder):
 *     node tools/stereo_workflow_drawings.mjs            SVG files only
 *     node tools/stereo_workflow_drawings.mjs --png      also PNG files (needs Edge or Chrome, headless)
 * Output: assets/img/stereo-piv/workflow/. Requires Node 16+, no other dependencies.
 * Drawings: PIVlab, www.pivlab.de, licence CC BY 4.0.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT = process.argv.slice(2).find(a => !a.startsWith('--')) ||
  path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'assets', 'img', 'stereo-piv', 'workflow');
const C = {
  line: '#3b4148', mute: '#7b828a', cam1: '#338cff', cam2: '#ff8c1a', laser: '#22a84a',
  grey: '#e6e9ed', grey2: '#c9ced5', bg: '#fafbfc', white: '#ffffff',
};
const W = 560;
const r = n => Math.round(n * 10) / 10;
const pts = a => a.map(p => `${r(p[0])},${r(p[1])}`).join(' ');

// ---------- basic elements ----------
const line = (a, b, o = {}) => `<line x1="${r(a[0])}" y1="${r(a[1])}" x2="${r(b[0])}" y2="${r(b[1])}" stroke="${o.c || C.line}" stroke-width="${o.w || 1.5}"${o.dash ? ` stroke-dasharray="${o.dash}"` : ''}${o.arrow ? ` marker-end="url(#a-${o.arrow})"` : ''}${o.op ? ` opacity="${o.op}"` : ''} stroke-linecap="round"/>`;
const poly = (p, o = {}) => `<polygon points="${pts(p)}" fill="${o.f || 'none'}"${o.fo !== undefined ? ` fill-opacity="${o.fo}"` : ''} stroke="${o.c || 'none'}" stroke-width="${o.w || 1.2}"${o.dash ? ` stroke-dasharray="${o.dash}"` : ''}${o.op ? ` opacity="${o.op}"` : ''} stroke-linejoin="round"/>`;
const text = (x, y, s, o = {}) => `<text x="${r(x)}" y="${r(y)}" font-size="${o.s || 12}"${o.b ? ' font-weight="600"' : ''} fill="${o.c || C.mute}" text-anchor="${o.a || 'start'}"${o.it ? ' font-style="italic"' : ''}>${s}</text>`;
const dot = (p, rad, f, o = {}) => `<circle cx="${r(p[0])}" cy="${r(p[1])}" r="${rad}" fill="${f}"${o.c ? ` stroke="${o.c}" stroke-width="${o.w || 1.2}"` : ''}/>`;
const uiButton = (x, y, w, label) => `<rect x="${x}" y="${y}" width="${w}" height="22" rx="4" fill="${C.white}" stroke="${C.line}" stroke-width="1.2"/>` + text(x + w / 2, y + 15.5, label, { a: 'middle', c: C.line, s: 11.5 });

function markers() {
  const m = (id, c) => `<marker id="a-${id}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0,1 L9,5 L0,9 z" fill="${c}"/></marker>`;
  return `<defs>${m('line', C.line)}${m('mute', C.mute)}${m('cam1', C.cam1)}${m('cam2', C.cam2)}${m('laser', C.laser)}</defs>`;
}

const TILE_H = 340; // all tiles: 560 x 340
function svg(num, title, body, caption = [], H = TILE_H) {
  const cap = caption.map((s, i) => text(20, H - 14 - (caption.length - 1 - i) * 16, s, { s: 12 })).join('');
  const plain = t => t.replace(/<[^>]*>/g, '');
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" font-family="Segoe UI, Helvetica, Arial, sans-serif">
<title>Stereo-PIV step ${num}: ${plain(title)}</title>
<desc>${caption.map(plain).join(' ')} Drawing: PIVlab, www.pivlab.de, CC BY 4.0.</desc>
${markers()}
<rect x="0.5" y="0.5" width="${W - 1}" height="${H - 1}" rx="10" fill="${C.bg}" stroke="${C.grey2}"/>
${body}
<g class="step-badge"><circle cx="26" cy="26" r="12" fill="${C.line}"/>${text(26, 30.5, num, { a: 'middle', c: '#fff', s: 13, b: true })}</g>
${text(46, 31.5, title, { s: 16, b: true, c: C.line })}
${text(W - 14, 30, 'pivlab.de · CC BY 4.0', { a: 'end', s: 9.5, c: '#a3a9b0' })}
${cap}
</svg>`;
}

// ---------- geometry ----------
const lerp = (a, b, t) => [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t];
function bilin(q, u, v) { // q = [TL, TR, BR, BL]
  const top = lerp(q[0], q[1], u), bot = lerp(q[3], q[2], u);
  return lerp(top, bot, v);
}
function hull(P) {
  const p = [...P].sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const cross = (o, a, b) => (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0]);
  const lo = [], up = [];
  for (const q of p) { while (lo.length >= 2 && cross(lo[lo.length - 2], lo[lo.length - 1], q) <= 0) lo.pop(); lo.push(q); }
  for (const q of [...p].reverse()) { while (up.length >= 2 && cross(up[up.length - 2], up[up.length - 1], q) <= 0) up.pop(); up.push(q); }
  return lo.slice(0, -1).concat(up.slice(0, -1));
}
function clip(subject, clipPoly) { // Sutherland-Hodgman, convex clip polygon
  const inside = (p, a, b) => (b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]) >= 0;
  const inter = (p1, p2, a, b) => {
    const A1 = p2[1] - p1[1], B1 = p1[0] - p2[0], C1 = A1 * p1[0] + B1 * p1[1];
    const A2 = b[1] - a[1], B2 = a[0] - b[0], C2 = A2 * a[0] + B2 * a[1];
    const d = A1 * B2 - A2 * B1;
    return [(B2 * C1 - B1 * C2) / d, (A1 * C2 - A2 * C1) / d];
  };
  let cp = clipPoly;
  const area = cp.reduce((s, p, i) => s + p[0] * cp[(i + 1) % cp.length][1] - cp[(i + 1) % cp.length][0] * p[1], 0);
  if (area < 0) cp = [...cp].reverse();
  let out = subject;
  for (let i = 0; i < cp.length; i++) {
    const a = cp[i], b = cp[(i + 1) % cp.length], inp = out; out = [];
    for (let j = 0; j < inp.length; j++) {
      const p = inp[j], q = inp[(j + 1) % inp.length];
      if (inside(q, a, b)) { if (!inside(p, a, b)) out.push(inter(p, q, a, b)); out.push(q); }
      else if (inside(p, a, b)) out.push(inter(p, q, a, b));
    }
  }
  return out;
}
// oblique projection: X right, Y depth (into the scene), Z up
const projector = (ox, oy, kx = 0.30, ky = 0.16) => (X, Y, Z) => [ox + X + kx * Y, oy - Z - ky * Y];
// deterministic pseudo-random numbers
const rnd = i => Math.abs((Math.sin(i * 12.9898 + 4.1) * 43758.5453) % 1);

// ---------- parts ----------
function board(q, nx = 7, ny = 5, o = {}) {
  let s = '';
  for (let i = 0; i < nx; i++) for (let j = 0; j < ny; j++) {
    const c = [bilin(q, i / nx, j / ny), bilin(q, (i + 1) / nx, j / ny), bilin(q, (i + 1) / nx, (j + 1) / ny), bilin(q, i / nx, (j + 1) / ny)];
    if ((i + j) % 2 === 0) s += poly(c, { f: C.line });
    else if (!o.plain) s += poly([bilin(q, (i + 0.32) / nx, (j + 0.32) / ny), bilin(q, (i + 0.68) / nx, (j + 0.32) / ny), bilin(q, (i + 0.68) / nx, (j + 0.68) / ny), bilin(q, (i + 0.32) / nx, (j + 0.68) / ny)], { f: C.grey2 });
  }
  const tint = o.tint ? poly(q, { f: o.tint, fo: 0.28 }) : '';
  return `<g${o.op ? ` opacity="${o.op}"` : ''}>${poly(q, { f: C.white })}${s}${tint}${poly(q, { c: C.line, w: 1.3 })}</g>`;
}
function board3D(P, cx, cy, cz, hw, hh, yaw = 0, pitch = 0) {
  const a = yaw * Math.PI / 180, b = pitch * Math.PI / 180;
  return [[-hw, 0, hh], [hw, 0, hh], [hw, 0, -hh], [-hw, 0, -hh]].map(([x, y, z]) => {
    const y1 = y * Math.cos(b) - z * Math.sin(b), z1 = y * Math.sin(b) + z * Math.cos(b);
    const x2 = x * Math.cos(a) - y1 * Math.sin(a), y2 = x * Math.sin(a) + y1 * Math.cos(a);
    return P(cx + x2, cy + y2, cz + z1);
  });
}
// camera symbol (flat): body + lens, pointing "up" before rotation; p = front of the body
function camTop(x, y, angle, col, o = {}) {
  const s = o.s || 1;
  const g = `<g transform="translate(${r(x)},${r(y)}) rotate(${r(angle)}) scale(${s})">` +
    `<rect x="-15" y="0" width="30" height="22" rx="3" fill="${col}" fill-opacity="0.22" stroke="${col}" stroke-width="${1.4 / s}"/>` +
    `<rect x="-8" y="-12" width="16" height="12" rx="1.5" fill="${C.white}" stroke="${col}" stroke-width="${1.4 / s}"/></g>`;
  const a = angle * Math.PI / 180;
  return { svg: g, tip: [x + 12 * s * Math.sin(a), y - 12 * s * Math.cos(a)] };
}
const aimAngle = (from, to) => Math.atan2(to[0] - from[0], -(to[1] - from[1])) * 180 / Math.PI;
const camAt = (p, target, col, s = 1.1) => { const t = camTop(p[0], p[1], aimAngle(p, target), col, { s }); return { svg: t.svg, lens: t.tip }; };
function cone(lens, quad, col, fo = 0.13) { return poly(hull([lens, ...quad]), { f: col, fo }); }
// laser in top view: box and beam direction (angle: 0 = to the right)
function laserTop(x, y, angle = 0) {
  return `<g transform="translate(${r(x)},${r(y)}) rotate(${r(angle)})"><rect x="-34" y="-7" width="30" height="14" rx="2" fill="${C.laser}" fill-opacity="0.25" stroke="${C.laser}" stroke-width="1.4"/>` +
    `<path d="M-4,-4 L4,-7 L4,7 L-4,4 z" fill="${C.laser}" fill-opacity="0.5" stroke="${C.laser}" stroke-width="1"/></g>`;
}
function thumb(x, y, w, h, col, label, inner = '') {
  return `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="3" fill="${C.white}" stroke="${col}" stroke-width="2"/>` + inner +
    (label ? text(x + 2, y - 5, label, { c: col, s: 11, b: true }) : '');
}
function sheetFan(P, apex, y0, x1, z0, z1, fo = 0.16) {
  return poly([P(apex[0], y0, apex[1]), P(x1, y0, z0), P(x1, y0, z1)], { f: C.laser, fo, c: C.laser, w: 1 });
}
function laser3D(P, x0, y0, z0) {
  const v = P, L = 50, d = 10, hh = 9;
  const back = [v(x0, y0 - d, z0 + hh), v(x0 + L, y0 - d, z0 + hh), v(x0 + L, y0 - d, z0 - hh), v(x0, y0 - d, z0 - hh)];
  const top = [v(x0, y0 - d, z0 + hh), v(x0, y0 + d, z0 + hh), v(x0 + L, y0 + d, z0 + hh), v(x0 + L, y0 - d, z0 + hh)];
  const right = [v(x0 + L, y0 - d, z0 + hh), v(x0 + L, y0 + d, z0 + hh), v(x0 + L, y0 + d, z0 - hh), v(x0 + L, y0 - d, z0 - hh)];
  return poly(top, { f: C.laser, fo: 0.12, c: C.laser }) + poly(right, { f: C.laser, fo: 0.3, c: C.laser }) + poly(back, { f: C.laser, fo: 0.2, c: C.laser });
}
function tank(P, x0, x1, y0, y1, z0, z1) {
  const e = [[[x0, y0, z0], [x1, y0, z0]], [[x0, y0, z1], [x1, y0, z1]], [[x0, y1, z1], [x1, y1, z1]], [[x0, y1, z0], [x1, y1, z0]],
    [[x0, y0, z0], [x0, y0, z1]], [[x1, y0, z0], [x1, y0, z1]], [[x0, y1, z0], [x0, y1, z1]], [[x1, y1, z0], [x1, y1, z1]],
    [[x0, y0, z0], [x0, y1, z0]], [[x1, y0, z0], [x1, y1, z0]], [[x0, y0, z1], [x0, y1, z1]], [[x1, y0, z1], [x1, y1, z1]]];
  const back = [P(x0, y1, z1), P(x1, y1, z1), P(x1, y1, z0), P(x0, y1, z0)];
  return poly(back, { f: C.grey, fo: 0.5 }) + e.map(([a, b]) => line(P(...a), P(...b), { c: C.grey2, w: 1.2 })).join('');
}
// particle image (deterministic dots), shifted by (dx, dy)
const spots = (x, y, w, h, dx = 0, dy = 0, n = 28, seed = 1) => Array.from({ length: n }, (_, i) =>
  dot([x + 5 + rnd(i * 2 + seed) * (w - 10) + dx, y + 5 + rnd(i * 2 + 1 + seed) * (h - 10) + dy], 1.5, C.line)).join('');
// small 2D vector field
function field2D(x, y, w, h, col, sign) {
  let s = '';
  const nx = 5, ny = 3;
  for (let i = 0; i < nx; i++) for (let j = 0; j < ny; j++) {
    const cx = x + (i + 0.5) * w / nx, cy = y + (j + 0.5) * h / ny;
    const ww = Math.exp(-((i - 2) ** 2 + (j - 1) ** 2) / 2.5);
    const dx = 15 + sign * 6 * ww, dy = 2 - 1.5 * (j - 1);
    s += line([cx - dx / 2, cy - dy / 2], [cx + dx / 2, cy + dy / 2], { c: col, w: 1.5, arrow: col === C.cam1 ? 'cam1' : 'cam2' });
  }
  return s;
}

// ---------- true perspective and 3D parts ----------
const sub3 = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const add3 = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
const mul3 = (a, s) => [a[0] * s, a[1] * s, a[2] * s];
const dot3 = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const cross3 = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const norm3 = a => mul3(a, 1 / Math.hypot(...a));
// central projection from eye E looking at T (Z up); P(X, Y, Z) -> screen; P.E, P.depth(q)
function perspective(E, T, cx, cy, F) {
  const f = norm3(sub3(T, E)), rt = norm3(cross3(f, [0, 0, 1])), up = cross3(rt, f);
  const P = (X, Y, Z) => { const p = sub3([X, Y, Z], E); const z = dot3(p, f); return [cx + F * dot3(p, rt) / z, cy - F * dot3(p, up) / z]; };
  P.E = E; P.depth = q => dot3(sub3(q, E), f);
  return P;
}
// perspective scaled and centred so that the points pts fit into rect [x, y, w, h]
function fitPerspective(E, T, pts, rect) {
  const base = perspective(E, T, 0, 0, 1);
  const q = pts.map(p => base(...p));
  const xs = q.map(p => p[0]), ys = q.map(p => p[1]);
  const minx = Math.min(...xs), maxx = Math.max(...xs), miny = Math.min(...ys), maxy = Math.max(...ys);
  const sc = Math.min(rect[2] / (maxx - minx), rect[3] / (maxy - miny));
  return perspective(E, T, rect[0] + (rect[2] - (maxx - minx) * sc) / 2 - minx * sc, rect[1] + (rect[3] - (maxy - miny) * sc) / 2 - miny * sc, sc);
}
// colour blended with white (a = share of the colour): opaque faces with the light tint of the 2D symbols
function mix(hex, a) {
  const c = [1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16));
  return '#' + c.map(v => Math.round(255 - (255 - v) * a).toString(16).padStart(2, '0')).join('');
}
// box: centre c, unit axes ax[3], half sizes h[3]; visible faces only, far ones first
function box3D(P, c, ax, h, col, tint = 0.22) {
  const faces = [];
  for (let i = 0; i < 3; i++) for (const s of [-1, 1]) {
    const n = mul3(ax[i], s), fc = add3(c, mul3(ax[i], s * h[i]));
    if (dot3(n, sub3(P.E, fc)) <= 0) continue;
    const j = (i + 1) % 3, k = (i + 2) % 3;
    const v = [[1, 1], [1, -1], [-1, -1], [-1, 1]].map(([a, b]) => add3(fc, add3(mul3(ax[j], a * h[j]), mul3(ax[k], b * h[k]))));
    const shade = n[2] > 0.5 ? tint * 0.7 : (Math.abs(n[2]) < 0.5 && dot3(n, [1, 0, 0]) > 0.3 ? tint * 1.5 : tint);
    faces.push({ d: P.depth(fc), s: poly(v.map(p => P(...p)), { f: mix(col, shade), c: col, w: 1.3 }) });
  }
  return faces.sort((a, b) => b.d - a.d).map(f => f.s).join('');
}
// cylinder from a0 to a1 (radius rad), axes u, v perpendicular to it
function cylinder3D(P, a0, a1, rad, u, v, col) {
  const ring = a => Array.from({ length: 36 }, (_, k) => { const t = k * Math.PI / 18; return P(...add3(a, add3(mul3(u, rad * Math.cos(t)), mul3(v, rad * Math.sin(t))))); });
  const r0 = ring(a0), r1 = ring(a1), d = norm3(sub3(a1, a0));
  let s = poly(hull([...r0, ...r1]), { f: C.white, c: col, w: 1.3 });
  if (dot3(d, sub3(P.E, a1)) > 0) s += poly(r1, { f: mix(col, 0.35), c: col, w: 1.3 });
  if (dot3(mul3(d, -1), sub3(P.E, a0)) > 0) s += poly(r0, { f: C.white, c: col, w: 1.3 });
  return s;
}
// camera as in the 2D symbol (body 30 x 22, lens 16 x 12), aimed at target; returns {svg, lens}
function camera3D(P, pos, target, col, s = 1.6) {
  const d = norm3(sub3(target, pos)), rt = norm3(cross3(d, [0, 0, 1])), up = cross3(rt, d);
  const body = box3D(P, pos, [rt, d, up], [15 * s, 11 * s, 9.5 * s], col);
  const a0 = add3(pos, mul3(d, 11 * s)), a1 = add3(a0, mul3(d, 12 * s));
  const lens = cylinder3D(P, a0, a1, 8 * s, rt, up, col);
  const lensFirst = P.depth(add3(a0, mul3(d, 6 * s))) > P.depth(pos);
  return { svg: lensFirst ? lens + body : body + lens, lens: P(...a1) };
}
function laserBox(P, x0, y0, z0, L = 50) {
  return box3D(P, [x0 + L / 2, y0, z0], [[1, 0, 0], [0, 1, 0], [0, 0, 1]], [L / 2, 10, 9], C.laser, 0.25);
}

// ---------- shared perspective scene ----------
const EYE = [70, -430, 300], LOOK = [0, 180, 80];
const CAM1 = [-125, 0, 60], CAM2 = [125, 0, 60], BOARD_C = [0, 220, 105];
function scene(rect = [16, 48, 344, 236], extra = []) {
  const key = [[-150, 120, 0], [150, 120, 0], [-150, 300, 170], [150, 300, 170], [-150, 120, 170], CAM1, CAM2, [-145, -20, 40], [145, -20, 40], ...extra];
  const P = fitPerspective(EYE, LOOK, key, rect);
  const boardQ = [P(-75, 220, 155), P(75, 220, 155), P(75, 220, 55), P(-75, 220, 55)];
  const c1 = camera3D(P, CAM1, BOARD_C, C.cam1), c2 = camera3D(P, CAM2, BOARD_C, C.cam2);
  return { P, boardQ, c1, c2 };
}

const files = {};
const add = (name, s) => { files[name] = s; };

// ===== 1: cameras and laser =====
{
  let b = '';
  b += line([280, 50], [280, 270], { c: C.grey2, w: 1 });
  // a) same side
  {
    const y0 = 104, Cc = [158, y0];
    b += text(26, 64, 'a) same side (top view)', { c: C.line, b: true, s: 12 });
    b += laserTop(48, y0) + line([48, y0], [262, y0], { c: C.laser, w: 2 }) + line([150, y0 - 14], [196, y0 - 14], { c: C.laser, w: 1.2, arrow: 'laser' });
    const k1 = [94, 214], k2 = [222, 214];
    const t1 = camAt(k1, Cc, C.cam1), t2 = camAt(k2, Cc, C.cam2);
    b += line(t1.lens, Cc, { c: C.cam1, dash: '5 4' }) + line(t2.lens, Cc, { c: C.cam2, dash: '5 4' }) + t1.svg + t2.svg;
    b += text(k1[0], 254, 'backward scatter', { a: 'middle', s: 10.5 }) + text(k1[0], 266, '(darker)', { a: 'middle', s: 10.5 });
    b += text(k2[0], 254, 'forward scatter', { a: 'middle', s: 10.5 }) + text(k2[0], 266, '(brighter)', { a: 'middle', s: 10.5 });
    b += text(Cc[0], 160, '30–90°', { a: 'middle', c: C.line, b: true, s: 11.5 });
  }
  // b) opposite sides, both downstream
  {
    const y0 = 160, Cc = [392, y0];
    b += text(296, 64, 'b) opposite sides, downstream (top view)', { c: C.line, b: true, s: 12 });
    b += laserTop(320, y0) + line([320, y0], [540, y0], { c: C.laser, w: 2 }) + line([344, y0 + 14], [390, y0 + 14], { c: C.laser, w: 1.2, arrow: 'laser' });
    const d = 92, a = Math.PI / 4;
    const k1 = [Cc[0] + d * Math.cos(a), Cc[1] + d * Math.sin(a)], k2 = [Cc[0] + d * Math.cos(a), Cc[1] - d * Math.sin(a)];
    const t1 = camAt(k1, Cc, C.cam1), t2 = camAt(k2, Cc, C.cam2);
    b += line(t1.lens, Cc, { c: C.cam1, dash: '5 4' }) + line(t2.lens, Cc, { c: C.cam2, dash: '5 4' }) + t1.svg + t2.svg;
    b += text(k1[0] + 24, k1[1] + 22, 'forward', { s: 10.5 }) + text(k2[0] + 24, k2[1] - 12, 'forward', { s: 10.5 });
    b += text(Cc[0] - 6, y0 - 8, 'sheet', { a: 'end', s: 10.5, c: C.laser });
  }
  add('stereo-step1-cameras.svg', svg(1, 'Set up cameras and laser', b, [
    'Any direction between the cameras works (30–90°). Cameras downstream of the laser see the bright',
    'forward scatter. A Scheimpflug adapter on each camera keeps the oblique view sharp everywhere.']));
}

// ===== 2: focus on the board =====
{
  const { boardQ, c1, c2 } = scene([16, 52, 340, 226]);
  let b = cone(c1.lens, boardQ, C.cam1) + cone(c2.lens, boardQ, C.cam2) + board(boardQ) + c1.svg + c2.svg;
  b += thumb(380, 60, 150, 80, C.cam1, 'camera 1', board([[396, 68], [514, 77], [514, 123], [396, 132]]));
  b += thumb(380, 182, 150, 80, C.cam2, 'camera 2', board([[396, 199], [514, 190], [514, 254], [396, 245]]));
  b += text(455, 158, 'sharp everywhere ✓', { a: 'middle', c: C.line, s: 11 });
  add('stereo-step2-focus.svg', svg(2, 'Focus both cameras on the board', b, [
    'Place the calibration board (generate it in PIVlab) where you will measure.',
    'Adjust focus and Scheimpflug angle until the whole board is sharp in both cameras.',
    'Tip: the Sharpness overlay of the PIVlab live image rates the left, centre and right third.']));
}

// ===== 3: lens calibration =====
{
  const camPos = [0, 0, 40];
  const poses = [[-100, 180, 128, 28, 12], [100, 190, 130, -24, -14], [-95, 200, 66, -18, 22], [100, 185, 64, 30, -12]];
  const key = [camPos, [-150, 160, 170], [150, 160, 170], [-150, 230, 30], [150, 230, 30], [-30, -30, 20], [30, -30, 20]];
  const P = fitPerspective([40, -360, 260], [0, 170, 90], key, [40, 50, 310, 222]);
  let b = '';
  for (const p of poses) b += board(board3D(P, p[0], p[1], p[2], 42, 30, p[3], p[4]), 6, 4, { op: 0.32, plain: true });
  const main = board3D(P, 0, 170, 100, 46, 33, -12, 10);
  const cam = camera3D(P, camPos, [0, 170, 100], C.cam1);
  b += cone(cam.lens, main, C.cam1, 0.1) + board(main, 6, 4) + cam.svg;
  b += text(20, 236, 'move and tilt', { c: C.line, s: 11 }) + text(20, 249, 'the board', { c: C.line, s: 11 });
  b += text(380, 62, 'images of camera 1', { c: C.cam1, s: 11, b: true });
  const quads = [
    [[8, 8], [56, 12], [54, 38], [10, 34]], [[14, 6], [62, 10], [60, 40], [12, 36]], [[6, 12], [40, 6], [46, 36], [8, 40]],
    [[20, 10], [62, 14], [58, 40], [24, 36]], [[10, 6], [50, 10], [48, 30], [8, 26]], [[24, 14], [64, 8], [62, 38], [26, 42]]];
  quads.forEach((q, i) => {
    const x = 380 + (i % 2) * 82, y = 70 + Math.floor(i / 2) * 56;
    b += thumb(x, y, 72, 48, C.cam1, '', board(q.map(([a, c]) => [x + a, y + c]), 5, 4, { plain: true }));
  });
  // camera 2: the same symbol, small
  const corners = []; for (const x of [-26, 26]) for (const y of [-18, 40]) for (const z of [-16, 16]) corners.push([x, y, z]);
  const Pi = fitPerspective([40, -360, 260], [0, 170, 90], corners, [396, 236, 50, 36]);
  b += camera3D(Pi, [0, 0, 0], [0, 170, 40], C.cam2).svg;
  b += text(458, 252, 'repeat for', { c: C.cam2, s: 11, b: true }) + text(458, 266, 'camera 2', { c: C.cam2, s: 11, b: true });
  add('stereo-step3-lens-calibration.svg', svg(3, 'Lens calibration, for each camera', b, [
    'Move the board through the whole image at many positions and tilts, then repeat for camera 2.',
    'No space at the measurement position? Calibrate before, then do not change',
    'focus, Scheimpflug angle or other lens settings.']));
}

// ===== 4: board at the measurement position, fields of view =====
{
  const { P, boardQ, c1, c2 } = scene([16, 50, 360, 232]);
  const fp1 = [[-108, 162], [96, 172], [96, 34], [-108, 44]].map(([x, z]) => P(x, 220, z));
  const fp2 = [[-96, 172], [108, 162], [108, 44], [-96, 34]].map(([x, z]) => P(x, 220, z));
  const ov = clip(fp1, fp2);
  let b = tank(P, -150, 150, 120, 300, 0, 170);
  b += cone(c1.lens, fp1, C.cam1, 0.07) + cone(c2.lens, fp2, C.cam2, 0.07);
  b += poly(ov, { f: C.grey2, fo: 0.9 }) + board(boardQ);
  b += poly(fp1, { c: C.cam1, w: 1.6, dash: '6 4' }) + poly(fp2, { c: C.cam2, w: 1.6, dash: '6 4' });
  b += c1.svg + c2.svg;
  const lx = 418;
  b += line([lx, 86], [lx + 18, 86], { c: C.cam1, w: 1.6, dash: '6 4' }) + text(lx + 24, 90, 'view of camera 1', { c: C.cam1, s: 11 });
  b += line([lx, 106], [lx + 18, 106], { c: C.cam2, w: 1.6, dash: '6 4' }) + text(lx + 24, 110, 'view of camera 2', { c: C.cam2, s: 11 });
  b += `<rect x="${lx}" y="120" width="18" height="11" fill="${C.grey2}"/>` + text(lx + 24, 130, 'overlap =', { c: C.line, s: 11 }) + text(lx + 24, 143, 'measurement area', { c: C.line, s: 11 });
  add('stereo-step4-board-position.svg', svg(4, 'Board at the measurement position', b, [
    'The board stands exactly where you want to measure. Align the cameras so that their views overlap',
    'as much as possible; the overlap is the measurement area. The board should fill most of it.']));
}

// ===== 5: light sheet on the board, record it =====
{
  const H5 = 340;
  const { P, boardQ, c1, c2 } = scene([16, 50, 360, 218], [[-230, 220, 100], [-230, 220, 120]]);
  let b = tank(P, -150, 150, 120, 300, 0, 170);
  b += board(boardQ, 7, 5, { tint: C.laser });
  b += laserBox(P, -230, 220, 110) + sheetFan(P, [-180, 110], 220, 150, 18, 172, 0.18);
  b += c1.svg + c2.svg;
  const lp = P(-230, 220, 128);
  b += text(lp[0] - 4, lp[1] + 46, 'laser + sheet optics', { c: C.laser, s: 11, b: true });
  const flash = (p, col) => [[-14, -10], [0, -16], [14, -10]].map(([dx, dy]) => line([p[0] + dx * 0.55, p[1] + dy * 0.55 - 8], [p[0] + dx, p[1] + dy - 10], { c: col, w: 1.3 })).join('');
  // right column: the resulting data
  b += text(462, 58, 'board images in the light sheet', { a: 'middle', c: C.line, s: 11, b: true });
  b += thumb(392, 80, 140, 74, C.cam1, 'camera 1', board([[406, 88], [518, 96], [518, 140], [406, 148]], 7, 5));
  b += thumb(392, 184, 140, 74, C.cam2, 'camera 2', board([[406, 198], [518, 191], [518, 250], [406, 243]], 7, 5));
  b += text(462, 272, 'laser off, normal lighting', { a: 'middle', s: 10.5 });
  // top view: sheet centre on the board face (camera side)
  const ty = 50;
  b += text(20, ty + 14, '', {});
  add('stereo-step5-board-in-sheet.svg', svg(5, 'Align the light sheet, record the board', b, [
    'Aim the light sheet at the board: its centre should lie on the board face (the camera side).',
    'Then switch the laser off (it grazes the board) and record the board with both cameras under',
    'normal lighting. Remove the board. From now on, the cameras must not move.']));
}

// ===== 6: stereo calibration =====
{
  let b = '';
  b += thumb(30, 64, 120, 68, C.cam1, 'camera 1', board([[42, 71], [138, 78], [138, 118], [42, 125]], 7, 5));
  b += thumb(30, 196, 120, 68, C.cam2, 'camera 2', board([[42, 210], [138, 203], [138, 257], [42, 250]], 7, 5));
  b += line([156, 100], [226, 140], { c: C.cam1, w: 1.6, arrow: 'cam1' }) + line([156, 228], [226, 190], { c: C.cam2, w: 1.6, arrow: 'cam2' });
  const gx = 236, gy = 66, gw = 300, gh = 200;
  b += `<rect x="${gx}" y="${gy}" width="${gw}" height="${gh}" fill="${C.white}" stroke="${C.line}" stroke-width="1.2"/>`;
  for (let i = 1; i < 10; i++) b += line([gx + i * gw / 10, gy], [gx + i * gw / 10, gy + gh], { c: C.grey, w: 1 });
  for (let j = 1; j < 7; j++) b += line([gx, gy + j * gh / 7], [gx + gw, gy + j * gh / 7], { c: C.grey, w: 1 });
  const v1 = [[gx + 8, gy + 22], [gx + 270, gy + 8], [gx + 270, gy + gh - 8], [gx + 8, gy + gh - 22]];
  const v2 = [[gx + 30, gy + 8], [gx + gw - 8, gy + 22], [gx + gw - 8, gy + gh - 22], [gx + 30, gy + gh - 8]];
  const ov = clip(v1, v2);
  b += poly(v1, { f: C.cam1, fo: 0.10, c: C.cam1, w: 1.6 }) + poly(v2, { f: C.cam2, fo: 0.10, c: C.cam2, w: 1.6 });
  b += poly(ov, { f: C.grey2, fo: 0.55 });
  b += board([[gx + 90, gy + 45], [gx + 210, gy + 45], [gx + 210, gy + 145], [gx + 90, gy + 145]], 7, 6, { op: 0.6 });
  b += poly(ov, { c: C.line, w: 1.6, dash: '6 3' });
  b += text(gx + gw / 2, gy - 8, 'common grid in the light sheet (both cameras)', { a: 'middle', c: C.line, s: 11, b: true });
  b += `<rect x="${gx + 85}" y="${gy + 158}" width="130" height="18" rx="3" fill="${C.white}" fill-opacity="0.85"/>`;
  b += text(gx + 150, gy + 171, 'overlap = region of interest', { a: 'middle', c: C.line, s: 11 });
  add('stereo-step6-stereo-calibration.svg', svg(6, 'Stereo calibration', b, [
    'PIVlab finds the board corners in both images, computes where the cameras are and maps both',
    'onto one common grid: a point of the sheet is at the same pixel in both cameras.']));
}

// ===== 7: disparity =====
{
  let b = '';
  const yb = 120; // board plane (calibration)
  const sheetY = x => 92 + (x - 40) * 0.075; // real light sheet: a little in front of the board and tilted
  const Pp = [176, sheetY(176)];
  const k1 = [86, 250], k2 = [266, 250];
  const t1 = camAt(k1, [176, 108], C.cam1), t2 = camAt(k2, [176, 108], C.cam2);
  b += line([40, sheetY(40)], [312, sheetY(312)], { c: C.laser, w: 10, op: 0.25 }) + line([40, sheetY(40)], [312, sheetY(312)], { c: C.laser, w: 1.4 });
  b += line([40, yb], [312, yb], { c: C.line, w: 1.6, dash: '7 4' });
  b += text(44, sheetY(44) - 10, 'light sheet (tilted, offset)', { c: C.laser, s: 11, b: true });
  b += text(312, yb + 16, 'board position', { s: 10.5, a: 'end' });
  const cross = k => { const t = (yb - k[1]) / (Pp[1] - k[1]); return [k[0] + t * (Pp[0] - k[0]), yb]; };
  const q1 = cross(t1.lens), q2 = cross(t2.lens);
  b += line(t1.lens, Pp, { c: C.cam1, w: 1.3 }) + line(t2.lens, Pp, { c: C.cam2, w: 1.3 });
  b += dot(q1, 4, C.white, { c: C.cam1, w: 1.8 }) + dot(q2, 4, C.white, { c: C.cam2, w: 1.8 }) + dot(Pp, 4.5, C.line);
  b += line([q1[0], yb + 28], [q2[0], yb + 28], { c: C.line, w: 1.2, arrow: 'line' }) + line([q2[0], yb + 28], [q1[0], yb + 28], { c: C.line, w: 1.2, arrow: 'line' });
  b += text((q1[0] + q2[0]) / 2, yb + 44, 'disparity', { a: 'middle', c: C.line, s: 11, b: true });
  b += text(Pp[0] + 8, Pp[1] - 8, 'particle', { s: 11, c: C.line });
  b += t1.svg + t2.svg + text(176, 272, 'top view', { a: 'middle', it: true, s: 11 });
  // right: correlation of the A images and the fitted map
  b += line([344, 52], [344, 270], { c: C.grey2, w: 1 });
  b += thumb(360, 66, 76, 52, C.cam1, 'camera 1, A', spots(360, 66, 76, 52, 0, 0, 26));
  b += thumb(460, 66, 76, 52, C.cam2, 'camera 2, A', spots(460, 66, 76, 52, 4, 1, 26));
  b += text(448, 97, '⊗', { a: 'middle', c: C.line, s: 16 });
  b += line([448, 126], [448, 172], { c: C.line, w: 1.4, arrow: 'line' }) + text(456, 154, 'correlate, fit', { s: 10.5, it: true });
  b += `<rect x="360" y="180" width="176" height="74" rx="3" fill="${C.white}" stroke="${C.line}" stroke-width="1.2"/>`;
  for (let i = 0; i < 6; i++) for (let j = 0; j < 3; j++) {
    const x = 376 + i * 29, y = 196 + j * 22, dx = 4 + 2.4 * i, dy = 0.5;
    b += line([x - dx / 2, y - dy / 2], [x + dx / 2, y + dy / 2], { c: C.line, w: 1.3, arrow: 'line' });
  }
  b += text(448, 270, 'fitted map → both cameras corrected', { a: 'middle', s: 11, c: C.line });
  add('stereo-step7-disparity.svg', svg(7, 'Record the flow, correct the disparity', b, [
    'The sheet is never exactly at the board position, so the cameras place a particle at different points.',
    'Correlating camera 1 A with camera 2 A measures this map; it corrects both cameras.']));
}

// ===== 8: ANALYZE: 2D PIV of each camera, then automatically u, v, w =====
{
  const H8 = 340;
  let b = '';
  const row = (y, col, label, shift, sign) => {
    let s = thumb(24, y, 54, 40, col, label + ' A', spots(24, y, 54, 40, 0, 0, 16, 1));
    s += thumb(86, y, 54, 40, col, 'B', spots(86, y, 54, 40, shift[0], shift[1], 16, 1));
    s += line([146, y + 20], [164, y + 20], { c: col, w: 1.6, arrow: col === C.cam1 ? 'cam1' : 'cam2' });
    s += thumb(170, y - 4, 112, 48, col, '2D vectors', field2D(170, y - 4, 112, 48, col, sign));
    return s;
  };
  b += text(24, 64, '2D PIV of each camera', { c: C.line, b: true, s: 12 });
  b += row(90, C.cam1, 'camera 1', [5, 0], 1);
  b += row(196, C.cam2, 'camera 2', [3, 1], -1);
  // automatic combination
  b += line([288, 110], [318, 150], { c: C.cam1, w: 1.6, arrow: 'cam1' }) + line([288, 216], [318, 176], { c: C.cam2, w: 1.6, arrow: 'cam2' });
  b += text(306, 168, 'automatic', { a: 'middle', it: true, s: 10.5, c: C.line });
  b += text(536, 64, 'resulting 3D vector map', { a: 'end', c: C.line, b: true, s: 12 });
  // the measurement plane in an oblique view: X right, Y toward the viewer, Z away from the viewer (camera 1)
  const P3 = (x, y, z) => [338 + x + 0.36 * y, 250 - 0.55 * y - z];
  const PW = 160, PD = 130;
  b += poly([P3(0, 0, 0), P3(PW, 0, 0), P3(PW, PD, 0), P3(0, PD, 0)], { f: C.grey, fo: 0.7, c: C.grey2, w: 1.2 });
  for (let i = 1; i < 5; i++) b += line(P3(i * PW / 5, 0, 0), P3(i * PW / 5, PD, 0), { c: C.grey2, w: 0.8 });
  for (let j = 1; j < 4; j++) b += line(P3(0, j * PD / 4, 0), P3(PW, j * PD / 4, 0), { c: C.grey2, w: 0.8 });
  for (let j = 3; j >= 0; j--) for (let i = 0; i < 5; i++) {
    const x = (i + 0.35) * PW / 5, y = (j + 0.5) * PD / 4;
    const w = 26 * Math.exp(-(((i - 2) / 1.2) ** 2 + ((j - 1.5) / 1.1) ** 2)) - 6;
    const u = 19, v = -3 + 4 * (j - 1.5);
    const S = P3(x, y, 0), E = P3(x + u, y - v, -w), F = P3(x + u, y - v, 0);
    b += line(F, E, { c: C.mute, w: 1.2, dash: '3 2' }) + line(S, E, { c: C.line, w: 1.6, arrow: 'line' }) + dot(S, 1.5, C.line);
  }
  // axes: X right, Y toward the viewer, Z down = away from camera 1
  const O = [470, 92], ey = [-0.55, 0.84];
  b += line(O, [O[0] + 34, O[1]], { c: C.mute, w: 1.3, arrow: 'mute' }) + text(O[0] + 38, O[1] + 4, 'X', { c: C.mute, b: true, s: 11 });
  b += line(O, [O[0] + ey[0] * 30, O[1] + ey[1] * 30], { c: C.mute, w: 1.3, arrow: 'mute' }) + text(O[0] + ey[0] * 36 - 8, O[1] + ey[1] * 36 + 4, 'Y', { c: C.mute, b: true, s: 11 });
  b += line(O, [O[0], O[1] + 30], { c: C.mute, w: 1.3, arrow: 'mute' }) + text(O[0] + 5, O[1] + 40, 'Z', { c: C.mute, b: true, s: 11 });
  b += text(O[0] + 16, O[1] + 40, 'away from', { s: 10 }) + text(O[0] + 16, O[1] + 52, 'camera 1', { s: 10, c: C.cam1 });
  add('stereo-step8-analysis.svg', svg(8, 'ANALYZE: from both cameras to u, v and w', b, [
    'ANALYZE runs a 2D PIV analysis of each camera (same settings, corrected images). The two fields',
    'differ because each camera sees the out-of-plane motion from its own side; PIVlab combines them',
    'automatically into one 3D vector per point: u, v in the board plane, w along Z.']));
}

// ---------- output ----------
const NAMES = {
  1: 'stereo-piv-step-1-cameras-and-laser', 2: 'stereo-piv-step-2-focus', 3: 'stereo-piv-step-3-lens-calibration',
  4: 'stereo-piv-step-4-board-position', 5: 'stereo-piv-step-5-board-in-light-sheet', 6: 'stereo-piv-step-6-stereo-calibration',
  7: 'stereo-piv-step-7-disparity-correction', 8: 'stereo-piv-step-8-analysis-u-v-w',
};
const tiles = Object.values(files); // in step order, with the step number (overview and card)
// single drawings (manual sections, explainer steps): without the number badge, title at the left edge
const single = t => t.replace(/<g class="step-badge">[\s\S]*?<\/g>/, '')
  .replace(/<text x="46" y="31.5"/, '<text x="20" y="31.5"').replace(/<title>Stereo-PIV step \d+: /, '<title>Stereo-PIV: ');
const inner = (s, n) => s.replace(/^[\s\S]*?<svg[^>]*>/, '').replace(/<\/svg>\s*$/, '')
  .replace(/id="a-/g, `id="t${n}-a-`).replace(/url\(#a-/g, `url(#t${n}-a-`);
function composite(w, h, cols, scale, x0, y0, gap, head) {
  const tw = W * scale, th = TILE_H * scale;
  let s = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="${w}" height="${h}" font-family="Segoe UI, Helvetica, Arial, sans-serif">\n`;
  s += `<title>Stereo-PIV step by step: from camera set-up to u, v and w</title>\n<desc>${tiles.map((t, i) => (t.match(/<title>([^<]*)<\/title>/) || [])[1]).join('. ')}.</desc>\n`;
  s += `<rect width="${w}" height="${h}" fill="#eef0f3"/>\n${head}\n`;
  tiles.forEach((t, i) => {
    const x = x0 + (i % cols) * (tw + gap), y = y0 + Math.floor(i / cols) * (th + gap);
    s += `<svg x="${r(x)}" y="${r(y)}" width="${r(tw)}" height="${r(th)}" viewBox="0 0 ${W} ${TILE_H}">${inner(t, i + 1)}</svg>\n`;
  });
  return s + '</svg>\n';
}
const OV_W = 2 * W + 3 * 24, OV_H = 96 + 4 * TILE_H + 3 * 24 + 64;
const overview = composite(OV_W, OV_H, 2, 1, 24, 96, 24,
  text(24, 50, 'Stereo-PIV step by step', { s: 30, b: true, c: C.line }) +
  text(24, 78, 'From camera set-up to the three velocity components u, v and w', { s: 16 }) +
  text(OV_W - 24, 50, 'PIVlab', { s: 22, b: true, c: C.line, a: 'end' }) + text(OV_W - 24, 76, 'www.pivlab.de', { s: 15, a: 'end', c: C.cam1 }) +
  text(24, OV_H - 26, 'Drawings: PIVlab, www.pivlab.de · licence CC BY 4.0 (free to reuse with attribution) · PIVlab is free, open-source PIV and stereo-PIV software', { s: 13 }));
const CW = 1200, CH = 630, cs = ((CW - 50) / 4) / W; // 4 x 2 tiles, 10 px margins and gaps, centred between title and footer
const card = composite(CW, CH, 4, cs, 10, 120 + (475 - (2 * TILE_H * cs + 10)) / 2, 10,
  text(16, 62, 'Stereo-PIV step by step', { s: 40, b: true, c: C.line }) +
  text(16, 104, 'Illustrated: from camera set-up to u, v and w', { s: 22 }) +
  text(CW - 16, 62, 'PIVlab', { s: 32, b: true, c: C.line, a: 'end' }) + text(CW - 16, 98, 'www.pivlab.de', { s: 20, a: 'end', c: C.cam1 }) +
  text(16, CH - 20, 'Free, open-source PIV and stereo-PIV software · drawings CC BY 4.0', { s: 15 }));

fs.mkdirSync(OUT, { recursive: true });
const written = [];
const write = (name, s) => { fs.writeFileSync(path.join(OUT, name), s); written.push(name); };
tiles.forEach((s, i) => write(NAMES[i + 1] + '.svg', single(s)));
write('stereo-piv-workflow-overview.svg', overview);
write('stereo-piv-workflow-card.svg', card);

// optional PNG versions (headless Edge or Chrome): node stereo_workflow_drawings.mjs [outdir] --png
if (process.argv.includes('--png')) {
  const { execFileSync } = await import('node:child_process');
  const browser = [process.env.BROWSER, 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe', 'C:/Program Files/Microsoft/Edge/Application/msedge.exe',
    'C:/Program Files/Google/Chrome/Application/chrome.exe', '/usr/bin/chromium', '/usr/bin/google-chrome'].find(p => p && fs.existsSync(p));
  if (!browser) throw new Error('no Edge/Chrome found for --png (set BROWSER)');
  const png = (svgName, w, h, scale) => {
    const file = path.resolve(OUT, svgName);
    execFileSync(browser, ['--headless=new', '--disable-gpu', '--hide-scrollbars', `--force-device-scale-factor=${scale}`, `--window-size=${w},${h}`,
      `--screenshot=${file.replace(/\.svg$/, '.png')}`, 'file:///' + file.replace(/\\/g, '/')], { stdio: 'ignore' });
    written.push(svgName.replace(/\.svg$/, '.png'));
  };
  tiles.forEach((_, i) => png(NAMES[i + 1] + '.svg', W, TILE_H, 2));
  png('stereo-piv-workflow-overview.svg', OV_W, OV_H, 1.5);
  png('stereo-piv-workflow-card.svg', CW, CH, 1);
}
console.log(written.join('\n'));
