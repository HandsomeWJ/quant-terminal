// An ad blocker or browser shield can stop the chart library loading, which leaves the chart area empty.
// A plain script (not a module) so it runs right after the library tag, and a file so the page's
// Content-Security-Policy needs no inline scripts.
if (!window.LightweightCharts) {
  var chartBlocked = document.createElement("div");
  chartBlocked.id = "chartBlocked";
  chartBlocked.style.cssText = "position:fixed;left:50%;top:80px;transform:translateX(-50%);z-index:9999;max-width:480px;padding:14px 18px;border-radius:8px;background:#7a1f1f;color:#fff;font:14px/1.4 sans-serif";
  chartBlocked.textContent = "The chart library didn't load, so charts can't draw. An ad blocker or browser shield is the usual cause. Turn it off for this page and reload.";
  document.body.appendChild(chartBlocked);
}
