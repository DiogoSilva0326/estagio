import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'native_overlay_embed_web.dart';

/// Web implementation that creates a native <iframe> element floating above
/// the Flutter CanvasKit canvas via the native_embeds.js overlay system.
///
/// This completely bypasses HtmlElementView / platform-view compositing
/// and therefore works on Chrome, Safari **and** Firefox.
///
/// Ideal for embedding Google Maps, YouTube videos, or any external content.
class NativeIframe extends StatelessWidget {
  const NativeIframe({
    super.key,
    required this.src,
    this.aspectRatio = 16 / 9,
    this.fill = true,
    this.backgroundColor = const Color(0xFFF0F0F0),
    this.clipTop,
    this.cutoutBottomLeftWidth = 0,
    this.cutoutBottomLeftHeight = 0,
  });

  /// The iframe source URL (e.g., Google Maps embed URL).
  final String src;

  /// Aspect ratio when [fill] is false.
  final double aspectRatio;

  /// If true, fills the available space. If false, uses [aspectRatio].
  final bool fill;

  /// Background color shown while loading.
  final Color backgroundColor;

  /// Optional viewport Y where the embed should start being visible.
  /// Useful for pinned headers that must always stay above the embed.
  final double? clipTop;

  /// Optional bottom-left rectangular cutout to keep overlapping Flutter
  /// elements visible above the native embed.
  final double cutoutBottomLeftWidth;
  final double cutoutBottomLeftHeight;

  @override
  Widget build(BuildContext context) {
    // Build a stable ID from the src so the overlay is reused across rebuilds.
    final key = base64Url.encode(utf8.encode(src)).replaceAll('=', '');
    final id = 'iframe-$key';

    final child = NativeOverlayEmbed(
      id: id,
      type: NativeEmbedType.iframe,
      src: src,
      backgroundColor: backgroundColor,
      clipTop: clipTop,
      cutoutBottomLeftWidth: cutoutBottomLeftWidth,
      cutoutBottomLeftHeight: cutoutBottomLeftHeight,
    );

    if (fill) return child;

    return AspectRatio(aspectRatio: aspectRatio, child: child);
  }
}
