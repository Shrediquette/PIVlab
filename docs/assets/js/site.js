/*
 * site.js — behaviour of the PIVlab website (pages built with _layouts/default.html):
 *   menu button on small screens, colour theme toggle, search (website + manual),
 *   "On this page" list, Standalone/Toolbox switches and click-to-load videos.
 * Everything still works (with less comfort) when JavaScript is off.
 */
(function () {
  "use strict";

  function $(sel, root) { return (root || document).querySelector(sel); }
  function $all(sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); }
  function el(tag, attrs, html) {
    var e = document.createElement(tag);
    if (attrs) { for (var k in attrs) { if (attrs[k] != null) e.setAttribute(k, attrs[k]); } }
    if (html != null) e.innerHTML = html;
    return e;
  }
  function store(key, val) {
    try { if (val === undefined) return localStorage.getItem(key); localStorage.setItem(key, val); } catch (e) { return null; }
  }
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function slug(s) { return s.toLowerCase().replace(/[^\w]+/g, "-").replace(/^-+|-+$/g, ""); }

  // ----------------------------------------------------------------- Menu
  function initMenu() {
    var btn = $(".burger"), menu = $("#site-menu");
    if (!btn || !menu) return;
    btn.addEventListener("click", function () {
      var open = menu.classList.toggle("open");
      btn.setAttribute("aria-expanded", open ? "true" : "false");
    });
    document.addEventListener("click", function (e) {
      if (menu.classList.contains("open") && !menu.contains(e.target) && !btn.contains(e.target)) {
        menu.classList.remove("open"); btn.setAttribute("aria-expanded", "false");
      }
    });
  }

  // ---------------------------------------------------------------- Theme
  function initTheme() {
    var btn = $(".theme-toggle");
    if (!btn) return;
    function show() {
      var dark = document.documentElement.getAttribute("data-theme") === "dark";
      btn.innerHTML = dark ? "&#9788;" : "&#9790;";
      btn.setAttribute("aria-label", dark ? "Switch to light mode" : "Switch to dark mode");
    }
    show();
    btn.addEventListener("click", function () {
      var t = document.documentElement.getAttribute("data-theme") === "dark" ? "light" : "dark";
      document.documentElement.setAttribute("data-theme", t);
      store("pivlab-manual-theme", t); // same key as the manual
      show();
    });
  }

  // --------------------------------------------------------------- Search
  // Records: website = window.SITE_SEARCH (assets/js/site-search.js, built by Jekyll),
  //          manual  = window.MANUAL_SEARCH (manual/assets/js/search-index.js).
  // Both files are loaded on first use only.
  var loading = null;
  function loadScript(src) {
    return new Promise(function (resolve) {
      var s = el("script", { src: src });
      s.onload = resolve; s.onerror = resolve;
      document.head.appendChild(s);
    });
  }
  function loadIndex() {
    if (!loading) loading = Promise.all([loadScript("/assets/js/site-search.js"), loadScript("/manual/assets/js/search-index.js"),
      loadScript("/manual/assets/js/search-core.js")]);
    return loading;
  }
  function records() {
    var out = [];
    (window.SITE_SEARCH || []).forEach(function (r) { out.push({ title: r.title, url: r.url, where: r.section || "Website", text: r.text || "" }); });
    (window.MANUAL_SEARCH || []).forEach(function (r) {
      out.push({ title: r.title, url: "/manual/" + r.href + (r.hash && r.hash !== "top" ? "#" + r.hash : ""),
        where: "Manual" + (r.section ? " · " + r.section : ""), text: r.text || "" });
    });
    return out;
  }
  function search(q) {
    return window.PivlabSearch ? window.PivlabSearch.rank(records(), q, 10) : []; // ranking: manual/assets/js/search-core.js
  }
  function initSearch() {
    var input = $("#site-search"), panel = $("#search-panel");
    if (!input || !panel) return;
    var sel = -1;
    function render() {
      var q = input.value.trim();
      panel.innerHTML = ""; sel = -1;
      if (!q) { panel.classList.remove("open"); return; }
      loadIndex().then(function () {
        if (input.value.trim() !== q) return;
        panel.innerHTML = "";
        var hits = search(q);
        if (!hits.length) panel.appendChild(el("div", { class: "search-empty" }, "No results for “" + esc(q) + "”"));
        hits.forEach(function (r) {
          panel.appendChild(el("a", { class: "search-hit", href: r.url },
            '<span class="search-hit-title">' + esc(r.title) + '</span><span class="search-hit-section">' + esc(r.where) + "</span>"));
        });
        panel.classList.add("open");
      });
    }
    function move(d) {
      var hits = $all(".search-hit", panel);
      if (!hits.length) return;
      if (sel >= 0) hits[sel].classList.remove("sel");
      sel = (sel + d + hits.length) % hits.length;
      hits[sel].classList.add("sel");
      hits[sel].scrollIntoView({ block: "nearest" });
    }
    input.addEventListener("input", render);
    input.addEventListener("focus", function () { loadIndex(); if (input.value) render(); });
    input.addEventListener("keydown", function (e) {
      if (e.key === "ArrowDown") { e.preventDefault(); move(1); }
      else if (e.key === "ArrowUp") { e.preventDefault(); move(-1); }
      else if (e.key === "Enter") {
        var hits = $all(".search-hit", panel);
        var target = hits[sel >= 0 ? sel : 0];
        if (target) { e.preventDefault(); location.href = target.getAttribute("href"); }
      }
    });
    document.addEventListener("click", function (e) {
      if (!panel.contains(e.target) && e.target !== input) panel.classList.remove("open");
    });
    document.addEventListener("keydown", function (e) {
      var typing = /^(INPUT|TEXTAREA|SELECT)$/.test((document.activeElement || {}).tagName || "");
      if (e.key === "/" && !typing) { e.preventDefault(); input.focus(); }
      if (e.key === "Escape") { panel.classList.remove("open"); input.blur(); }
    });
  }

  // ------------------------------------------------------------- Switches
  // In the page text (Markdown), a comment marks a switch:
  //     <!-- switch: edition -->
  //     ### Standalone app        <- first option = shown to first-time visitors
  //     ...
  //     ### MATLAB toolbox
  // The headings directly after the marker (all of the same level, ### or ####)
  // become the options. "edition" is the name of the switch: the choice is
  // remembered per name for all pages. A switch can sit inside an option of
  // another switch (#### inside ###).
  // "## ... (Euresys only)": this section is shown only while an option whose
  // label starts with "Euresys" is chosen in a switch on the same page.
  var onlySections = [];  // {name, label, wrap, head}
  var currentChoice = {}; // switch name -> chosen label
  function refreshOnlySections() {
    onlySections.forEach(function (s) {
      var chosen = currentChoice[s.name];
      var show = !chosen || chosen === s.label;
      s.wrap.hidden = !show;
      if (s.head.id) {
        var link = $('#toc-rail a[data-target="' + s.head.id + '"]');
        if (link) link.parentNode.hidden = !show;
      }
    });
  }
  function level(node) { var m = /^H([1-6])$/.exec(node.tagName || ""); return m ? +m[1] : 99; }
  function nextElement(node) {
    var n = node.nextSibling;
    while (n && n.nodeType !== 1) n = n.nextSibling;
    return n;
  }
  function initSwitches() {
    var doc = $("#doc");
    if (!doc) return;
    var markers = [], walker = document.createTreeWalker(doc, NodeFilter.SHOW_COMMENT, null);
    while (walker.nextNode()) {
      var m = /^\s*switch:\s*([\w-]+)\s*$/.exec(walker.currentNode.nodeValue);
      if (m) markers.push({ node: walker.currentNode, name: m[1] });
    }
    var groups = []; // {name, items:[{label, id, panel, btn}]}
    markers.forEach(function (mk) {
      var first = nextElement(mk.node);
      var lev = level(first);
      if (lev < 3 || lev > 6) return;
      var items = [], cur = first;
      while (cur && level(cur) === lev) {
        var panel = el("div", { class: "switch-panel", role: "tabpanel" });
        cur.parentNode.insertBefore(panel, cur);
        var next = cur;
        // move all nodes (also the <!-- switch --> comments of inner switches) up to the
        // next heading of the same or a higher level into this option
        do { var n = next.nextSibling; panel.appendChild(next); next = n; }
        while (next && !(next.nodeType === 1 && level(next) <= lev));
        items.push({ label: cur.textContent.trim(), id: cur.id, panel: panel });
        cur = next;
      }
      if (items.length > 1) groups.push({ name: mk.name, items: items });
    });
    $all("h2", doc).forEach(function (h) {
      var m = /\(([^)]+) only\)\s*$/.exec(h.textContent);
      if (!m) return;
      var word = m[1].toLowerCase(), found = null;
      groups.forEach(function (g) {
        g.items.forEach(function (it) { if (!found && it.label.toLowerCase().indexOf(word) === 0) found = { name: g.name, label: it.label }; });
      });
      if (!found) return;
      var wrap = el("div", { class: "only-section" });
      h.parentNode.insertBefore(wrap, h);
      var next = h;
      do { var n = next.nextSibling; wrap.appendChild(next); next = n; }
      while (next && !(next.nodeType === 1 && level(next) <= 2));
      onlySections.push({ name: found.name, label: found.label, wrap: wrap, head: h });
    });
    function apply(name, label) {
      var chosen = null;
      groups.forEach(function (g) {
        if (g.name !== name) return;
        var want = g.items[0].label; // default: first option
        g.items.forEach(function (it) { if (it.label === label) want = label; });
        g.items.forEach(function (it) {
          var on = it.label === want;
          if (on) chosen = it.label;
          it.panel.hidden = !on;
          it.btn.setAttribute("aria-selected", on ? "true" : "false");
        });
      });
      if (chosen) currentChoice[name] = chosen;
      refreshOnlySections();
    }
    var names = [];
    groups.forEach(function (g) {
      if (names.indexOf(g.name) === -1) names.push(g.name);
      var bar = el("div", { class: "switch", role: "tablist", "aria-label": g.items.map(function (i) { return i.label; }).join(" / ") });
      g.items.forEach(function (it) {
        it.btn = el("button", { type: "button", role: "tab" }, esc(it.label));
        it.btn.addEventListener("click", function () { store("pivlab-" + g.name, it.label); apply(g.name, it.label); });
        bar.appendChild(it.btn);
      });
      g.items[0].panel.parentNode.insertBefore(bar, g.items[0].panel);
    });
    names.forEach(function (name) { apply(name, store("pivlab-" + name)); });
    // a link to #matlab-toolbox (the id of an option heading) opens that option
    var hash = decodeURIComponent(location.hash.slice(1));
    groups.forEach(function (g) {
      g.items.forEach(function (it) { if (it.id && it.id === hash) apply(g.name, it.label); });
    });
  }

  // ------------------------------------------------------- On this page list
  function initToc() {
    var doc = $("#doc"), rail = $("#toc-rail"), page = $("#page");
    if (!doc || !rail || !page) return;
    var heads = $all("h2", doc).filter(function (h) { return !h.closest(".switch-panel") && !h.classList.contains("group-title"); });
    if (heads.length < 3) return;
    var ul = el("ul");
    heads.forEach(function (h) {
      if (!h.id) h.id = slug(h.textContent);
      var li = el("li");
      li.appendChild(el("a", { href: "#" + h.id, "data-target": h.id }, esc(h.textContent)));
      ul.appendChild(li);
    });
    rail.appendChild(el("p", { class: "toc-title" }, "On this page"));
    rail.appendChild(ul);
    rail.hidden = false;
    page.classList.remove("no-toc");
    if (!("IntersectionObserver" in window)) return;
    var links = $all("a", ul);
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        links.forEach(function (a) { a.classList.toggle("active", a.getAttribute("data-target") === e.target.id); });
      });
    }, { rootMargin: "0px 0px -75% 0px" });
    heads.forEach(function (h) { obs.observe(h); });
  }

  // ------------------------------------------------- Click-to-load YouTube video
  // Markup: <div class="video" data-yt="VIDEO_ID" data-title="Title"><a href="https://www.youtube.com/watch?v=VIDEO_ID">Title</a></div>
  // Nothing is loaded from YouTube until the visitor clicks.
  function initVideos() {
    $all(".video[data-yt]").forEach(function (box) {
      var id = box.getAttribute("data-yt"), title = box.getAttribute("data-title") || "Video";
      var btn = el("button", { type: "button", class: "video-btn", "aria-label": "Play video: " + title },
        '<span class="video-play"></span><span class="video-title">' + esc(title) + "</span>" +
        '<span class="video-note">Plays from YouTube after you click. See the <a href="/privacy/#youtube">privacy policy</a>.</span>');
      // thumbnail copy on pivlab.de (assets/images/videos/<id>.jpg), so nothing is loaded from YouTube before the click
      btn.style.setProperty("--thumb", 'url("/assets/images/videos/' + encodeURIComponent(id) + '.jpg")');
      btn.addEventListener("click", function (e) {
        if (e.target.tagName === "A") return;
        box.innerHTML = "";
        box.appendChild(el("iframe", {
          src: "https://www.youtube-nocookie.com/embed/" + encodeURIComponent(id) + "?autoplay=1&rel=0",
          title: title, allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
          allowfullscreen: "", referrerpolicy: "strict-origin-when-cross-origin"
        }));
      });
      box.innerHTML = "";
      box.appendChild(btn);
    });
  }

  // ----------------------------------------------------- Looping animations
  // <video class="anim" preload="none" muted loop playsinline poster="..."> is only
  // downloaded and played while it is on screen (saves data on pages where it is far down).
  function initAnimations() {
    var vids = $all("video.anim");
    if (!vids.length) return;
    if (!("IntersectionObserver" in window)) { vids.forEach(function (v) { v.play(); }); return; }
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { var p = e.target.play(); if (p && p.catch) p.catch(function () {}); }
        else e.target.pause();
      });
    }, { rootMargin: "200px 0px" });
    vids.forEach(function (v) { obs.observe(v); });
  }

  document.addEventListener("DOMContentLoaded", function () {
    initMenu(); initTheme(); initSearch(); initSwitches(); initToc(); refreshOnlySections(); initVideos(); initAnimations();
  });
})();
