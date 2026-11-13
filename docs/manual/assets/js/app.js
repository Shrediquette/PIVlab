/*
 * app.js — builds the shared page chrome around each page's content.
 *
 * Every content page contains only:
 *     <article id="doc"> ...the actual manual text... </article>
 * plus <script> tags loading nav.js, search-index.js and this file.
 *
 * This script wraps that article in the header / sidebar / table-of-contents /
 * footer layout, so navigation and styling live in ONE place and pages stay
 * pure content.  All links are relative, so the site behaves identically when
 * opened from disk (file://) or served from any sub-path.
 */
(function () {
  "use strict";

  // --- Where is the manual root, relative to the current page? -------------
  // Pages under /pages/ need to go up one level; the root index.html does not.
  var inPages = /\/pages\//.test(location.pathname.replace(/\\/g, "/"));
  var ROOT = inPages ? "../" : "./";
  var currentFile = location.pathname.replace(/\\/g, "/").split("/").pop() || "index.html";
  var currentRel = (inPages ? "pages/" : "") + currentFile; // e.g. "pages/masking.html"

  function h(tag, attrs, html) {
    var el = document.createElement(tag);
    if (attrs) { for (var k in attrs) { if (attrs[k] != null) el.setAttribute(k, attrs[k]); } }
    if (html != null) el.innerHTML = html;
    return el;
  }
  function resolve(href) { return ROOT + href; }

  // --- Flatten nav into an ordered list of live pages (for the pager) ------
  function livePages() {
    var out = [];
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      (sec.items || []).forEach(function (it) {
        if (it.status === "live") out.push({ label: it.label, href: it.href, section: sec.title });
      });
    });
    return out;
  }

  // ------------------------------------------------------- Homepage "Start here"
  // Auto-built from nav.js so the homepage never goes stale as pages ship.
  // Grouped like the sidebar: one titled group per nav section, one card per
  // live page (except the homepage itself), using each item's `blurb`, in the
  // order they appear in nav.js.
  function buildStartHereCards() {
    var container = document.getElementById("start-here-cards");
    if (!container) return;
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      var items = (sec.items || []).filter(function (it) {
        return it.status === "live" && it.href !== currentRel;
      });
      if (!items.length) return;
      container.appendChild(h("h3", { class: "cards-group-title" }, sec.title));
      var grid = h("div", { class: "cards" });
      items.forEach(function (it) {
        grid.appendChild(h("a", { class: "card", href: resolve(it.href) },
          "<h4>" + it.label + "</h4><p>" + (it.blurb || sec.title) + "</p>"));
      });
      container.appendChild(grid);
    });
  }

  // ------------------------------------------------------------------ Sidebar
  function buildSidebar() {
    var nav = h("nav", { class: "nav" });
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      var group = h("div", { class: "nav-group" });
      group.appendChild(h("p", { class: "nav-group-title" }, sec.title));
      var ul = h("ul");
      (sec.items || []).forEach(function (it) {
        var li = h("li");
        if (it.status === "soon") {
          li.appendChild(h("span", { class: "nav-link soon", title: "Coming soon" },
            it.label + '<span class="badge">soon</span>'));
        } else {
          var isActive = it.href === currentRel;
          var a = h("a", { class: "nav-link" + (isActive ? " active" : ""), href: resolve(it.href) }, it.label);
          li.appendChild(a);
        }
        ul.appendChild(li);
      });
      group.appendChild(ul);
      nav.appendChild(group);
    });
    return nav;
  }

  // --------------------------------------------------------- Table of contents
  function slugify(s) {
    return s.toLowerCase().replace(/[^\w]+/g, "-").replace(/^-+|-+$/g, "");
  }
  function buildToc(article) {
    var heads = article.querySelectorAll("h2, h3");
    if (!heads.length) return null;
    var wrap = h("div", { class: "toc" });
    wrap.appendChild(h("p", { class: "toc-title" }, "On this page"));
    var ul = h("ul");
    heads.forEach(function (hd) {
      if (!hd.id) hd.id = slugify(hd.textContent);
      var li = h("li", { class: hd.tagName.toLowerCase() });
      li.appendChild(h("a", { href: "#" + hd.id, "data-target": hd.id }, hd.textContent));
      ul.appendChild(li);
    });
    wrap.appendChild(ul);
    return wrap;
  }
  function initScrollSpy(toc) {
    if (!toc) return;
    var links = toc.querySelectorAll("a");
    var byId = {};
    links.forEach(function (a) { byId[a.getAttribute("data-target")] = a; });
    var ids = Object.keys(byId);
    if (!ids.length) return;
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          links.forEach(function (a) { a.classList.remove("active"); });
          var a = byId[e.target.id];
          if (a) a.classList.add("active");
        }
      });
    }, { rootMargin: "0px 0px -75% 0px", threshold: 0 });
    ids.forEach(function (id) { var el = document.getElementById(id); if (el) obs.observe(el); });
  }

  // ------------------------------------------------------------------- Pager
  function buildPager() {
    var pages = livePages();
    var idx = -1;
    for (var i = 0; i < pages.length; i++) { if (pages[i].href === currentRel) { idx = i; break; } }
    if (idx === -1) return null;
    var pager = h("nav", { class: "pager" });
    if (idx > 0) {
      var p = pages[idx - 1];
      pager.appendChild(h("a", { class: "pager-link prev", href: resolve(p.href) },
        '<span class="pager-dir">Previous</span><span class="pager-label">' + p.label + "</span>"));
    } else { pager.appendChild(h("span")); }
    if (idx < pages.length - 1) {
      var n = pages[idx + 1];
      pager.appendChild(h("a", { class: "pager-link next", href: resolve(n.href) },
        '<span class="pager-dir">Next</span><span class="pager-label">' + n.label + "</span>"));
    } else { pager.appendChild(h("span")); }
    return pager;
  }

  // --------------------------------------------------------------- Breadcrumb
  function buildBreadcrumb() {
    var section = null, label = null;
    (window.MANUAL_NAV.sections || []).forEach(function (sec) {
      (sec.items || []).forEach(function (it) {
        if (it.href === currentRel) { section = sec.title; label = it.label; }
      });
    });
    var bc = h("nav", { class: "breadcrumb" });
    bc.appendChild(h("a", { href: resolve("index.html") }, window.MANUAL_NAV.title));
    if (section) { bc.appendChild(h("span", { class: "sep" }, "›")); bc.appendChild(h("span", null, section)); }
    if (label && label !== "Introduction") { bc.appendChild(h("span", { class: "sep" }, "›")); bc.appendChild(h("span", { class: "current" }, label)); }
    return bc;
  }

  // ------------------------------------------------------------------- Search
  // Website pages (wiki, camera setup, ...) are searched too: their records come from
  // ../assets/js/site-search.js (built by Jekyll on pivlab.de, loaded on first use;
  // absent when the manual is opened from disk).
  var SITE_ROOT = ROOT + "../";
  var siteSearchLoaded = false;
  function loadScript(src, done) {
    var s = h("script", { src: src });
    s.onload = done; s.onerror = done;
    document.head.appendChild(s);
  }
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function initSearch(input, panel) {
    // records for the shared ranking (search-core.js): manual first, website pages added on first use
    var data = (window.MANUAL_SEARCH || []).map(function (r) {
      return { title: r.title, where: r.section || "", text: r.text || "",
        url: resolve(r.href) + (r.hash && r.hash !== "top" ? "#" + r.hash : "") };
    });
    function addSiteRecords() {
      (window.SITE_SEARCH || []).forEach(function (r) {
        data.push({ title: r.title, url: r.url, where: r.section || "Website", text: r.text || "" });
      });
      if (input.value) render(input.value);
    }
    loadScript(ROOT + "assets/js/search-core.js", function () { if (input.value) render(input.value); });
    function loadSiteRecords() {
      if (siteSearchLoaded) return;
      siteSearchLoaded = true;
      loadScript(SITE_ROOT + "assets/js/site-search.js", addSiteRecords);
    }
    input.addEventListener("focus", loadSiteRecords);
    input.addEventListener("input", loadSiteRecords);
    function render(q) {
      panel.innerHTML = "";
      q = q.trim();
      if (!q) { panel.classList.remove("open"); return; }
      var hits = window.PivlabSearch ? window.PivlabSearch.rank(data, q, 8) : [];
      if (!hits.length) {
        panel.appendChild(h("div", { class: "search-empty" }, "No results for “" + esc(q) + "”"));
      } else {
        hits.forEach(function (rec) {
          panel.appendChild(h("a", { class: "search-hit", href: rec.url },
            '<span class="search-hit-title">' + esc(rec.title) + "</span>" +
            '<span class="search-hit-section">' + esc(rec.where) + "</span>"));
        });
      }
      panel.classList.add("open");
    }
    input.addEventListener("input", function () { render(input.value); });
    input.addEventListener("focus", function () { if (input.value) render(input.value); });
    document.addEventListener("click", function (e) {
      if (!panel.contains(e.target) && e.target !== input) panel.classList.remove("open");
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "/" && document.activeElement !== input) { e.preventDefault(); input.focus(); }
      if (e.key === "Escape") { panel.classList.remove("open"); input.blur(); }
    });
  }

  // -------------------------------------------------------------------- Theme
  function initTheme(btn) {
    var stored = null;
    try { stored = localStorage.getItem("pivlab-manual-theme"); } catch (e) {}
    var prefersDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
    var theme = stored || (prefersDark ? "dark" : "light");
    apply(theme);
    btn.addEventListener("click", function () {
      theme = (document.documentElement.getAttribute("data-theme") === "dark") ? "light" : "dark";
      apply(theme);
      try { localStorage.setItem("pivlab-manual-theme", theme); } catch (e) {}
    });
    function apply(t) {
      document.documentElement.setAttribute("data-theme", t);
      btn.setAttribute("aria-label", t === "dark" ? "Switch to light mode" : "Switch to dark mode");
      btn.innerHTML = t === "dark" ? "☀" : "☾";
    }
  }

  // --------------------------------------------------------------------- Build
  document.addEventListener("DOMContentLoaded", function () {
    var article = document.getElementById("doc");
    if (!article) return;

    // Header / top bar — a dark hero band (holds the PIVlab logo, like pivlab.de's
    // header) above a sticky lime action bar (like pivlab.de's #banner). These are
    // kept as separate top-level siblings of <body> (not nested in one wrapper) —
    // a sticky element only stays stuck while its own parent is on screen, so
    // nesting it inside a ~140px-tall wrapper would make it scroll away with it.
    // The top menu and the download buttons are the same as on the website
    // (window.SITE_NAV from ../assets/js/site-nav.js, filled in once it has loaded).
    var hero = h("div", { class: "hero" });
    hero.appendChild(h("a", { class: "hero-home", href: SITE_ROOT, "aria-label": "PIVlab website" }));
    var heroSide = h("div", { class: "hero-side" });
    heroSide.appendChild(h("a", { class: "hero-title", href: resolve("index.html") }, "User Manual"));
    var downloads = h("div", { class: "downloads" });
    heroSide.appendChild(downloads);
    hero.appendChild(heroSide);
    var header = h("header", { class: "action-bar" });
    var burger = h("button", { class: "burger", "aria-label": "Show manual chapters" }, "&#9776; Chapters");
    var menuBtn = h("button", { class: "menu-btn", "aria-label": "Show website menu", "aria-expanded": "false" }, "Menu");
    var siteMenu = h("ul", { class: "site-menu" },
      '<li><a href="' + SITE_ROOT + '">PIVlab website</a></li>');
    var searchWrap = h("div", { class: "search" });
    var searchInput = h("input", { type: "search", placeholder: "Search manual + website  ( / )", "aria-label": "Search the manual and the website" });
    var searchPanel = h("div", { class: "search-panel" });
    searchWrap.appendChild(searchInput); searchWrap.appendChild(searchPanel);
    var themeBtn = h("button", { class: "theme-toggle", "aria-label": "Toggle theme" }, "☾");
    var siteMark = h("a", { class: "site-mark", href: "https://optolution.com", target: "_blank", rel: "noopener", title: "OPTOLUTION" }, "");
    header.appendChild(burger); header.appendChild(menuBtn); header.appendChild(siteMenu); header.appendChild(searchWrap);
    header.appendChild(themeBtn); header.appendChild(siteMark);
    menuBtn.addEventListener("click", function () {
      var open = siteMenu.classList.toggle("open");
      menuBtn.setAttribute("aria-expanded", open ? "true" : "false");
    });
    document.addEventListener("click", function (e) {
      if (siteMenu.classList.contains("open") && !siteMenu.contains(e.target) && e.target !== menuBtn) {
        siteMenu.classList.remove("open"); menuBtn.setAttribute("aria-expanded", "false");
      }
    });
    loadScript(SITE_ROOT + "assets/js/site-nav.js", function () {
      var nav = window.SITE_NAV;
      if (!nav) return; // manual opened from disk: keep the single "PIVlab website" link
      siteMenu.innerHTML = "";
      (nav.navigation || []).forEach(function (it) {
        var isManual = it.url.replace(/\/$/, "") === "/manual";
        siteMenu.appendChild(h("li", null, '<a href="' + it.url + '"' + (isManual ? ' class="active" aria-current="page"' : "") + ">" + it.title + "</a>"));
      });
      downloads.appendChild(h("span", { class: "downloads-label" }, "Download"));
      (nav.downloads || []).forEach(function (d) {
        // same download icon as in the website header (_layouts/default.html)
        if (d.header) downloads.appendChild(h("a", { class: "dl-btn", href: d.url, title: d.text },
          '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M7 1h2v7.6l2.3-2.3 1.4 1.4L8 12.4 3.3 7.7l1.4-1.4L7 8.6zM2 13h12v2H2z"/></svg>' + d.button));
      });
      downloads.appendChild(h("a", { class: "dl-btn gh", href: nav.github }, "View on GitHub"));
      loadScript(SITE_ROOT + "assets/js/beta.js", function () {}); // adds a "Beta x.y" button while a beta exists
    });

    // Layout skeleton
    var layout = h("div", { class: "layout" });
    var sidebar = h("aside", { class: "sidebar" });
    sidebar.appendChild(buildSidebar());
    var main = h("main", { class: "main" });
    var toc = buildToc(article);

    main.appendChild(buildBreadcrumb());
    main.appendChild(article);            // move the page's content in
    var pager = buildPager();
    if (pager) main.appendChild(pager);
    main.appendChild(h("footer", { class: "site-footer" },
      'PIVlab manual · <a href="https://www.pivlab.de" target="_blank" rel="noopener">PIVlab.de</a> · ' +
      'PIVlab is developed by William Thielicke at <a href="https://optolution.com" target="_blank" rel="noopener">OPTOLUTION Messtechnik GmbH</a> · ' +
      '<a href="https://www.pivlab.de/imprint/">Legal notice</a> · <a href="https://www.pivlab.de/privacy/">Privacy policy</a>'));

    layout.appendChild(sidebar);
    layout.appendChild(main);
    if (toc) { var tocAside = h("aside", { class: "toc-rail" }); tocAside.appendChild(toc); layout.appendChild(tocAside); }

    document.body.insertBefore(layout, document.body.firstChild);
    document.body.insertBefore(header, document.body.firstChild);
    document.body.insertBefore(hero, document.body.firstChild);

    // Behaviour
    burger.addEventListener("click", function () { sidebar.classList.toggle("open"); });
    document.addEventListener("click", function (e) {
      if (window.innerWidth <= 900 && sidebar.classList.contains("open") &&
          !sidebar.contains(e.target) && e.target !== burger) sidebar.classList.remove("open");
    });
    // reference tables with two columns are shown as label/explanation blocks on phones (style.css)
    article.querySelectorAll("table.ref").forEach(function (t) {
      var maxCols = 0;
      t.querySelectorAll("tr").forEach(function (r) { maxCols = Math.max(maxCols, r.children.length); });
      if (maxCols <= 2) t.classList.add("two-col");
    });
    initScrollSpy(toc);
    initSearch(searchInput, searchPanel);
    initTheme(themeBtn);
    buildStartHereCards();
  });
})();
