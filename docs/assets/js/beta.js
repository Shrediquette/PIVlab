/*
 * beta.js — download buttons for a beta version of PIVlab.
 *
 * If the newest release on GitHub is marked as "pre-release", this script adds
 *   - a "Beta x.y" button to every download bar (website header and manual header),
 *   - a beta box to every element with the attribute data-beta-box (home and downloads page).
 * When a normal release is the newest one, nothing is shown.
 * The answer is kept for one hour in the browser (sessionStorage), so GitHub is asked
 * at most once per hour and visitor. If GitHub cannot be reached, nothing is shown.
 * Used by _layouts/default.html and by manual/assets/js/app.js.
 */
(function () {
  "use strict";
  var API = "https://api.github.com/repos/Shrediquette/PIVlab/releases?per_page=10";
  var KEY = "pivlab-beta";
  var TTL = 60 * 60 * 1000; // one hour

  function readCache() {
    try {
      var c = JSON.parse(sessionStorage.getItem(KEY));
      if (c && Date.now() - c.time < TTL) return c;
    } catch (e) {}
    return null;
  }
  function writeCache(beta) {
    try { sessionStorage.setItem(KEY, JSON.stringify({ time: Date.now(), beta: beta })); } catch (e) {}
  }

  // newest non-draft release; a beta only if that one is a pre-release
  function findBeta(releases) {
    if (!Array.isArray(releases)) return null;
    var list = releases.filter(function (r) { return !r.draft; });
    list.sort(function (a, b) { return new Date(b.published_at) - new Date(a.published_at); });
    var newest = list[0];
    if (!newest || !newest.prerelease) return null;
    function asset(name) {
      var assets = newest.assets || [];
      for (var i = 0; i < assets.length; i++) { if (assets[i].name === name) return assets[i].browser_download_url; }
      return newest.html_url; // file missing: link to the release page
    }
    return {
      tag: newest.tag_name,
      date: (newest.published_at || "").slice(0, 10),
      exe: asset("PIVlab_installer.exe"),
      mltbx: asset("PIVlab.mltbx"),
      notes: newest.html_url
    };
  }

  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function shortName(tag) { // "4.0-beta" -> "4.0"
    var v = String(tag).replace(/[-_ ]?beta.*$/i, "");
    return v || tag;
  }

  function show(beta) {
    if (!beta) return;
    var label = "Beta " + shortName(beta.tag);
    var bars = document.querySelectorAll(".downloads");
    for (var i = 0; i < bars.length; i++) {
      var bar = bars[i];
      if (bar.querySelector(".dl-btn.beta")) continue;
      var a = document.createElement("a");
      a.className = "dl-btn beta";
      a.href = "/downloads#beta";
      a.title = "Beta version " + beta.tag + ": the newest features before the stable release";
      // same download icon as the other header buttons (_layouts/default.html)
      a.innerHTML = '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M7 1h2v7.6l2.3-2.3 1.4 1.4L8 12.4 3.3 7.7l1.4-1.4L7 8.6zM2 13h12v2H2z"/></svg>' + esc(label);
      var gh = bar.querySelector(".dl-btn.gh");
      if (gh) bar.insertBefore(a, gh); else bar.appendChild(a);
    }
    var boxes = document.querySelectorAll("[data-beta-box]");
    for (var k = 0; k < boxes.length; k++) {
      boxes[k].innerHTML =
        '<p class="beta-title"><strong>Beta version ' + esc(beta.tag) + "</strong>" +
        (beta.date ? " · published " + esc(beta.date) : "") + "</p>" +
        "<p>Try the newest features before the stable release.</p>" +
        '<div class="beta-links">' +
        '<a class="beta-btn" href="' + esc(beta.exe) + '">Standalone app (beta)</a>' +
        '<a class="beta-btn" href="' + esc(beta.mltbx) + '">MATLAB toolbox (beta)</a>' +
        '<a href="' + esc(beta.notes) + '">Release notes</a>' +
        "</div>";
      boxes[k].hidden = false;
    }
  }

  function run() {
    var c = readCache();
    if (c) { show(c.beta); return; }
    if (!window.fetch) return;
    fetch(API)
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (releases) {
        if (!releases) return; // e.g. rate limit: try again on the next page
        var beta = findBeta(releases);
        writeCache(beta);
        show(beta);
      })
      .catch(function () {}); // GitHub unreachable: show nothing
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", run);
  else run();
})();
