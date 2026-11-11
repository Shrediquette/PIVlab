/*
 * search-core.js — ranking used by both search boxes: the manual (app.js) and
 * the website (assets/js/site.js). Change the ranking here, in one place.
 *
 * PivlabSearch.rank(records, query, max)
 *   records: [{ title, where, text, ... }]  (other fields are passed through)
 *   Every word of the query has to match. If no record matches all words,
 *   records that match at least one word are returned instead.
 *   Weights: title 6, where (section) 2, text 1.
 */
window.PivlabSearch = (function () {
  "use strict";
  function score(rec, terms, needAll) {
    var title = (rec.title || "").toLowerCase();
    var where = (rec.where || "").toLowerCase();
    var text = (rec.text || "").toLowerCase();
    var s = 0, hits = 0;
    for (var i = 0; i < terms.length; i++) {
      var t = terms[i], h = 0;
      if (title.indexOf(t) !== -1) h += 6;
      if (where.indexOf(t) !== -1) h += 2;
      if (text.indexOf(t) !== -1) h += 1;
      if (h) hits++;
      s += h;
    }
    if (needAll && hits < terms.length) return 0;
    return s;
  }
  function pick(records, terms, needAll) {
    var out = [];
    for (var i = 0; i < records.length; i++) {
      var s = score(records[i], terms, needAll);
      if (s > 0) out.push({ rec: records[i], s: s, i: i });
    }
    return out;
  }
  function rank(records, query, max) {
    var terms = String(query || "").toLowerCase().split(/\s+/).filter(Boolean);
    if (!terms.length) return [];
    var res = pick(records, terms, true);
    if (!res.length) res = pick(records, terms, false);
    res.sort(function (a, b) { return b.s - a.s || a.i - b.i; });
    return res.slice(0, max || 10).map(function (x) { return x.rec; });
  }
  return { rank: rank };
})();
