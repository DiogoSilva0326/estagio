import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'native_overlay_embed_web.dart';

/// Web implementation that creates a native <video> element floating above
/// the Flutter CanvasKit canvas via the native_embeds.js overlay system.
///
/// This completely bypasses HtmlElementView / platform-view compositing
/// and therefore works on Chrome, Safari **and** Firefox.
class NativeVideo extends StatelessWidget {
  const NativeVideo({
    super.key,
    required this.src,
    this.controls = true,
    this.autoplay = false,
    this.loop = false,
    this.backgroundColor = const Color(0xFF000000),
  });

  /// The video source URL (e.g., '/videos/my-video.mp4').
  final String src;

  /// Whether to show video controls.
  final bool controls;

  /// Whether to autoplay the video (muted).
  final bool autoplay;

  /// Whether to loop the video.
  final bool loop;

  /// Background color shown while loading.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Build a stable ID from the video parameters so the overlay is reused
    // when src/controls/etc. don't change across rebuilds.
    final hash = base64Url
        .encode(utf8.encode('$src|$controls|$autoplay|$loop'))
        .replaceAll('=', '');
    final id = 'video-$hash';

    return NativeOverlayEmbed(
      id: id,
      type: NativeEmbedType.video,
      src: src,
      controls: controls,
      autoplay: autoplay,
      loop: loop,
      backgroundColor: backgroundColor,
    );
  }
}
