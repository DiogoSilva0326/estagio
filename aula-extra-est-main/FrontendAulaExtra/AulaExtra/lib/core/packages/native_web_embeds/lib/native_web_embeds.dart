/// Native Web Embeds - Flutter Web video & iframe overlay system.
///
/// This package provides widgets that render native HTML elements (videos,
/// iframes) above the Flutter CanvasKit canvas. It works on Chrome, Safari,
/// and Firefox by bypassing HtmlElementView platform-view compositing.
///
/// ## Usage
///
/// ```dart
/// import 'package:native_web_embeds/native_web_embeds.dart';
///
/// // Video
/// NativeVideo(
///   src: '/videos/my-video.mp4',
///   autoplay: true,
///   loop: true,
///   controls: true,
/// )
///
/// // Google Maps / Iframe
/// NativeIframe(
///   src: 'https://www.google.com/maps/embed?...',
/// )
/// ```
///
/// ## Setup
///
/// 1. Add the `native_embeds.js` script to your `web/index.html`
/// 2. Import this package and use the widgets
///
/// See README.md for full integration instructions.
library;

// Core exports
export 'src/native_video.dart';
export 'src/native_iframe.dart';
export 'src/native_embed_bridge.dart';
