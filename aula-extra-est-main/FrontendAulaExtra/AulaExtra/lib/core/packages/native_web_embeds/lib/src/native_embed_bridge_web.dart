// ignore_for_file: avoid_web_libraries_in_flutter
/// Dart ↔ JS bridge for the native_embeds.js overlay system.
///
/// This provides typed calls to window._nativeEmbeds.* so Dart widgets
/// can create/destroy/reposition native HTML elements that sit above
/// the Flutter CanvasKit canvas.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

// ─── JS interop bindings ────────────────────────────────────────────

@JS('window._nativeEmbeds.setClipTop')
external void _jsSetClipTop(JSNumber y);

@JS('window._nativeEmbeds.createVideo')
external void _jsCreateVideo(
  JSString id,
  JSString src,
  JSBoolean controls,
  JSBoolean autoplay,
  JSBoolean loop,
  JSNumber x,
  JSNumber y,
  JSNumber w,
  JSNumber h,
);

@JS('window._nativeEmbeds.createIframe')
external void _jsCreateIframe(
  JSString id,
  JSString src,
  JSNumber x,
  JSNumber y,
  JSNumber w,
  JSNumber h,
);

@JS('window._nativeEmbeds.updateRect')
external void _jsUpdateRect(
  JSString id,
  JSNumber x,
  JSNumber y,
  JSNumber w,
  JSNumber h,
);

@JS('window._nativeEmbeds.hideEmbed')
external void _jsHideEmbed(JSString id);

@JS('window._nativeEmbeds.showEmbed')
external void _jsShowEmbed(JSString id);

@JS('window._nativeEmbeds.destroyEmbed')
external void _jsDestroyEmbed(JSString id);

@JS('window._nativeEmbeds.destroyAll')
external void _jsDestroyAll();

@JS('window._nativeEmbeds.hideAll')
external void _jsHideAll();

@JS('window._nativeEmbeds.showAll')
external void _jsShowAll();

// ─── Typed Dart API ─────────────────────────────────────────────────

/// Whether the native embeds JS is loaded. Returns false on non-web or if
/// the script hasn't been included.
bool get isAvailable {
  final ne = globalContext.getProperty('_nativeEmbeds'.toJS);
  return ne.isA<JSObject>();
}

/// Tell the JS overlay where the header ends (viewport Y).
/// Embeds will be clipped above this line so they disappear behind the header.
void setClipTop(double y) => _jsSetClipTop(y.toJS);

void createVideo({
  required String id,
  required String src,
  required bool controls,
  required bool autoplay,
  required bool loop,
  required double x,
  required double y,
  required double w,
  required double h,
}) {
  _jsCreateVideo(
    id.toJS,
    src.toJS,
    controls.toJS,
    autoplay.toJS,
    loop.toJS,
    x.toJS,
    y.toJS,
    w.toJS,
    h.toJS,
  );
}

void createIframe({
  required String id,
  required String src,
  required double x,
  required double y,
  required double w,
  required double h,
}) {
  _jsCreateIframe(id.toJS, src.toJS, x.toJS, y.toJS, w.toJS, h.toJS);
}

void updateRect({
  required String id,
  required double x,
  required double y,
  required double w,
  required double h,
}) {
  _jsUpdateRect(id.toJS, x.toJS, y.toJS, w.toJS, h.toJS);
}

void hideEmbed(String id) => _jsHideEmbed(id.toJS);

void showEmbed(String id) => _jsShowEmbed(id.toJS);

void destroyEmbed(String id) => _jsDestroyEmbed(id.toJS);

void destroyAll() => _jsDestroyAll();

void hideAll() => _jsHideAll();

void showAll() => _jsShowAll();
