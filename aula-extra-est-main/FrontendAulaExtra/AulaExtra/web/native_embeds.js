/** 
 * native_embeds.js — manages native HTML elements (iframes, videos) that
 * float above the Flutter CanvasKit canvas.
 *
 * Flutter's CanvasKit renderer draws everything on a <canvas>. When we use
 * HtmlElementView it relies on platform-view compositing which breaks in
 * Safari & Firefox (OpaqueResponseBlocking, missing rendering, etc.).
 *
 * This script creates native DOM elements that sit in an overlay <div> on
 * top of the Flutter canvas. The Dart side calls these JS functions via
 * dart:js_interop to create/update/destroy embeds, passing the on-screen
 * position and size computed from the Flutter widget's RenderBox.
 *
 * POSITIONING: Dart reports *viewport-relative* coordinates (localToGlobal).
 * Each embed lives inside a *wrapper* <div> that uses `position:fixed` and
 * `overflow:hidden` for clipping behind the header. The actual <video> or
 * <iframe> inside the wrapper keeps its full size — it is only the wrapper
 * that shrinks — so Safari never sees the media element being resized or
 * clipped directly, which avoids Safari's compositing bugs.
 *
 * Each embed is identified by a unique string `id`.
 */
(function () {
  'use strict';

  var overlay = document.createElement('div');
  overlay.id = 'native-embeds-overlay';
  overlay.style.cssText =
    'position:fixed;top:0;left:0;width:0;height:0;' +
    'pointer-events:none;z-index:100;overflow:visible;';
  document.body.appendChild(overlay);

  var registry = {};
  var _clipTop = 0;
  var _allHidden = false;

  function applyBottomLeftCutout(entry, width, height) {
    var cutW = Math.max(0, Math.min(entry.cutoutBottomLeftWidth || 0, width));
    var cutH = Math.max(0, Math.min(entry.cutoutBottomLeftHeight || 0, height));

    if (cutW <= 0 || cutH <= 0) {
      entry.wrapper.style.clipPath = '';
      entry.wrapper.style.webkitClipPath = '';
      return;
    }

    var cutTop = Math.max(0, height - cutH);
    var polygon = 'polygon(0 0, 100% 0, 100% 100%, ' + cutW + 'px 100%, ' + cutW + 'px ' + cutTop + 'px, 0 ' + cutTop + 'px)';
    entry.wrapper.style.clipPath = polygon;
    entry.wrapper.style.webkitClipPath = polygon;
  }

  function setClipTop(y) {
    _clipTop = y || 0;
  }

  function createWrapper(id) {
    var w = document.createElement('div');
    w.id = 'native-wrap-' + id;
    w.style.cssText =
      'position:fixed;overflow:hidden;pointer-events:none;' +
      'display:block;';
    return w;
  }

  function setRect(entry, viewportX, viewportY, w, h) {
    var wrapper = entry.wrapper;
    var el = entry.el;

    if (_allHidden) { wrapper.style.display = 'none'; return; }

    var vh = window.innerHeight;
    var vw = window.innerWidth;

    if (viewportY + h <= 0 || viewportY >= vh ||
        viewportX + w <= 0 || viewportX >= vw) {
      wrapper.style.display = 'none';
      return;
    }

    var visibleTop = Math.max(viewportY, _clipTop);
    var visibleBottom = Math.min(viewportY + h, vh);
    var visibleH = visibleBottom - visibleTop;

    if (visibleH <= 0) {
      wrapper.style.display = 'none';
      return;
    }

    wrapper.style.display = 'block';

    var ws = wrapper.style;
    ws.left = viewportX + 'px';
    ws.top = visibleTop + 'px';
    ws.width = w + 'px';
    ws.height = visibleH + 'px';
    applyBottomLeftCutout(entry, w, visibleH);

    var es = el.style;
    es.position = 'absolute';
    es.left = '0';
    es.top = (viewportY - visibleTop) + 'px';
    es.width = w + 'px';
    es.height = h + 'px';
  }

  function createVideo(id, src, controls, autoplay, loop, x, y, w, h) {
    var existing = registry[id];
    if (existing && existing.type === 'video') {
      var v = existing.el;
      if (v.getAttribute('data-src') !== src) {
        v.setAttribute('data-src', src);
        var sourceEl = v.querySelector('source');
        if (sourceEl) sourceEl.src = src;
        v.load();
        if (autoplay) tryPlay(v);
      }
      setRect(existing, x, y, w, h);
      return;
    }

    if (existing) destroyEmbed(id);

    var video = document.createElement('video');
    video.id = 'native-embed-' + id;
    video.setAttribute('data-src', src);
    video.muted = true;
    video.defaultMuted = true;
    video.setAttribute('muted', '');
    video.playsInline = true;
    video.setAttribute('playsinline', '');
    video.setAttribute('webkit-playsinline', '');
    video.controls = controls;
    video.loop = loop;
    video.preload = 'auto';
    video.style.cssText =
      'pointer-events:auto;background:#000;display:block;' +
      'object-fit:contain;border:0;position:absolute;left:0;top:0;';

    var source = document.createElement('source');
    source.src = src;
    source.type = 'video/mp4';
    video.appendChild(source);

    var wrapper = createWrapper(id);
    wrapper.appendChild(video);
    overlay.appendChild(wrapper);

    var entry = { wrapper: wrapper, el: video, type: 'video' };
    registry[id] = entry;
    setRect(entry, x, y, w, h);

    if (autoplay) {
      video.autoplay = true;
      video.setAttribute('autoplay', '');
      video.load();
      video.addEventListener('loadeddata', function () { tryPlay(video); });
      video.addEventListener('canplay', function () { tryPlay(video); });
      setTimeout(function () { tryPlay(video); }, 500);
      setTimeout(function () { tryPlay(video); }, 1500);
    }
  }

  function tryPlay(v) {
    if (!v.paused) return;
    var p = v.play();
    if (p && typeof p.catch === 'function') p.catch(function () {});
  }

  function createIframe(id, src, x, y, w, h) {
    var existing = registry[id];
    if (existing && existing.type === 'iframe') {
      var f = existing.el;
      if (f.src !== src) f.src = src;
      setRect(existing, x, y, w, h);
      return;
    }

    if (existing) destroyEmbed(id);

    var iframe = document.createElement('iframe');
    iframe.id = 'native-embed-' + id;
    iframe.src = src;
    iframe.style.cssText =
      'pointer-events:auto;background:#f0f0f0;display:block;border:0;' +
      'position:absolute;left:0;top:0;';
    iframe.allowFullscreen = true;
    iframe.loading = 'lazy';
    iframe.referrerPolicy = 'no-referrer-when-downgrade';
    iframe.title = 'Embed';
    iframe.setAttribute(
      'allow',
      'accelerometer; encrypted-media; picture-in-picture; autoplay; geolocation'
    );

    var wrapper = createWrapper(id);
    wrapper.appendChild(iframe);
    overlay.appendChild(wrapper);

    var entry = { wrapper: wrapper, el: iframe, type: 'iframe' };
    registry[id] = entry;
    setRect(entry, x, y, w, h);
  }

  function updateRect(id, x, y, w, h) {
    var entry = registry[id];
    if (!entry) return;
    setRect(entry, x, y, w, h);
  }

  function hideEmbed(id) {
    var entry = registry[id];
    if (!entry) return;
    entry.wrapper.style.display = 'none';
  }

  function showEmbed(id) {
    var entry = registry[id];
    if (!entry) return;
    entry.wrapper.style.display = 'block';
  }

  function destroyEmbed(id) {
    var entry = registry[id];
    if (!entry) return;
    if (entry.wrapper.parentNode) entry.wrapper.parentNode.removeChild(entry.wrapper);
    delete registry[id];
  }

  function destroyAll() {
    for (var id in registry) {
      if (registry.hasOwnProperty(id)) destroyEmbed(id);
    }
  }

  function hideAll() {
    _allHidden = true;
    for (var id in registry) {
      if (registry.hasOwnProperty(id)) registry[id].wrapper.style.display = 'none';
    }
  }

  function showAll() {
    _allHidden = false;
  }

  function setBottomLeftCutout(id, width, height) {
    var entry = registry[id];
    if (!entry) return;
    entry.cutoutBottomLeftWidth = Math.max(0, width || 0);
    entry.cutoutBottomLeftHeight = Math.max(0, height || 0);
  }

  window._nativeEmbeds = {
    setClipTop: setClipTop,
    setBottomLeftCutout: setBottomLeftCutout,
    createVideo: createVideo,
    createIframe: createIframe,
    updateRect: updateRect,
    hideEmbed: hideEmbed,
    showEmbed: showEmbed,
    destroyEmbed: destroyEmbed,
    destroyAll: destroyAll,
    hideAll: hideAll,
    showAll: showAll,
  };
})();