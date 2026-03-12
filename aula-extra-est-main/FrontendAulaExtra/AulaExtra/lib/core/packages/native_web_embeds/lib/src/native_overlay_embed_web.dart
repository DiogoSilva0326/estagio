// ignore_for_file: avoid_web_libraries_in_flutter
/// A Flutter widget that reserves screen space and creates a native HTML
/// element (video or iframe) positioned exactly over that space using
/// the native_embeds.js overlay system.
///
/// This completely bypasses HtmlElementView / platform view compositing
/// and therefore works on Chrome, Safari **and** Firefox.
///
/// POSITIONING: The Dart side reports *viewport-relative* coordinates via
/// `localToGlobal`. The JS side uses `position: fixed` to place the element
/// at those exact viewport coordinates. Dart re-reports coordinates on
/// every Flutter scroll event so the native element tracks its Flutter
/// placeholder precisely. When the placeholder scrolls off-screen,
/// `localToGlobal` returns negative Y (or Y > viewport height) and the
/// JS side hides/clips the element automatically.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'native_embed_bridge_web.dart' as bridge;

/// Type of native embed to create.
enum NativeEmbedType { video, iframe }

/// Widget that creates a native HTML element floating above the Flutter canvas.
///
/// It renders a coloured placeholder box, then after layout it tells JS to
/// create the native element at the correct viewport position (position:fixed).
/// On every scroll event it re-reports the position so the element tracks
/// its placeholder.
class NativeOverlayEmbed extends StatefulWidget {
  const NativeOverlayEmbed({
    super.key,
    required this.id,
    required this.type,
    required this.src,
    this.controls = true,
    this.autoplay = false,
    this.loop = false,
    this.backgroundColor = Colors.black,
  });

  final String id;
  final NativeEmbedType type;
  final String src;
  final bool controls;
  final bool autoplay;
  final bool loop;
  final Color backgroundColor;

  @override
  State<NativeOverlayEmbed> createState() => _NativeOverlayEmbedState();
}

class _NativeOverlayEmbedState extends State<NativeOverlayEmbed>
    with WidgetsBindingObserver {
  final GlobalKey _boxKey = GlobalKey();
  bool _created = false;
  bool _disposed = false;
  bool _drawerWasOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start the continuous frame sync loop.  Each iteration schedules
    // a post-frame callback (which fires AFTER build+layout+paint) that
    // reads fresh localToGlobal coords and pushes them to JS.  The
    // callback re-schedules itself so it runs every frame.
    _scheduleFrameSync();
  }

  @override
  void didUpdateWidget(NativeOverlayEmbed old) {
    super.didUpdateWidget(old);
    if (old.src != widget.src ||
        old.type != widget.type ||
        old.id != widget.id) {
      bridge.destroyEmbed(old.id);
      _created = false;
    }
  }

  @override
  void didChangeMetrics() {
    // Will be picked up by the next frame sync automatically.
  }

  @override
  void deactivate() {
    bridge.hideEmbed(widget.id);
    super.deactivate();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    bridge.destroyEmbed(widget.id);
    super.dispose();
  }

  /// Schedules a post-frame callback that reads the widget position and
  /// then re-schedules itself, creating a per-frame sync loop.
  void _scheduleFrameSync() {
    if (_disposed) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      _checkDrawerState();
      _syncClipTop();
      _createOrUpdate();
      // Re-schedule for next frame to keep the loop going
      _scheduleFrameSync();
    });
  }

  /// Hide all native embeds when a drawer (hamburger menu) is open,
  /// so the video doesn't float above the drawer overlay.
  void _checkDrawerState() {
    final scaffold = Scaffold.maybeOf(context);
    final isOpen = scaffold?.isEndDrawerOpen ?? false;
    if (isOpen && !_drawerWasOpen) {
      bridge.hideAll();
      _drawerWasOpen = true;
    } else if (!isOpen && _drawerWasOpen) {
      bridge.showAll();
      _drawerWasOpen = false;
    }
  }

  /// Tell JS where the scroll area starts so embeds are clipped behind
  /// the header.
  void _syncClipTop() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;
    final scrollRO = scrollable.context.findRenderObject();
    if (scrollRO == null || scrollRO is! RenderBox || !scrollRO.attached) {
      return;
    }
    final topLeft = scrollRO.localToGlobal(Offset.zero);
    bridge.setClipTop(topLeft.dy);
  }

  Rect? _getRect() {
    final ro = _boxKey.currentContext?.findRenderObject();
    if (ro == null || !ro.attached) return null;
    final rb = ro as RenderBox;
    final topLeft = rb.localToGlobal(Offset.zero);
    return Rect.fromLTWH(topLeft.dx, topLeft.dy, rb.size.width, rb.size.height);
  }

  void _createOrUpdate() {
    if (_disposed) return;
    final rect = _getRect();
    if (rect == null || rect.width <= 0 || rect.height <= 0) return;

    if (!_created) {
      switch (widget.type) {
        case NativeEmbedType.video:
          bridge.createVideo(
            id: widget.id,
            src: widget.src,
            controls: widget.controls,
            autoplay: widget.autoplay,
            loop: widget.loop,
            x: rect.left,
            y: rect.top,
            w: rect.width,
            h: rect.height,
          );
        case NativeEmbedType.iframe:
          bridge.createIframe(
            id: widget.id,
            src: widget.src,
            x: rect.left,
            y: rect.top,
            w: rect.width,
            h: rect.height,
          );
      }
      _created = true;
    } else {
      _forceUpdate(rect);
    }
  }

  /// Always pushes position to JS (no tolerance skip) — ensures the
  /// native element tracks the Flutter placeholder on every single frame.
  void _forceUpdate(Rect rect) {
    bridge.updateRect(
      id: widget.id,
      x: rect.left,
      y: rect.top,
      w: rect.width,
      h: rect.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Tracker(
      boxKey: _boxKey,
      color: widget.backgroundColor,
    );
  }
}

/// A simple render-object widget that paints a coloured box.
class _Tracker extends SingleChildRenderObjectWidget {
  const _Tracker({
    required this.boxKey,
    required this.color,
  }) : super(key: boxKey);

  final GlobalKey boxKey;
  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTracker(color: color);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTracker renderObject) {
    renderObject.color = color;
  }
}

class _RenderTracker extends RenderBox {
  _RenderTracker({required Color color}) : _color = color;

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(
      offset & size,
      Paint()..color = _color,
    );
  }

  @override
  bool get sizedByParent => false;
}
