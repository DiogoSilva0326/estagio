// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'package:flutter/material.dart';

class WhiteboardPanel extends StatefulWidget {
  const WhiteboardPanel({
    super.key,
    required this.appIdentifier,
    required this.region,
    required this.uuid,
    required this.roomToken,
    required this.uid,
  });

  final String appIdentifier;
  final String region;
  final String uuid;
  final String roomToken;
  final int uid;

  @override
  State<WhiteboardPanel> createState() => _WhiteboardPanelState();
}

class _WhiteboardPanelState extends State<WhiteboardPanel> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'whiteboard-${widget.uuid}-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..src = 'assets/whiteboard/index.html?v=${DateTime.now().millisecondsSinceEpoch}';

      iframe.onLoad.listen((_) {
        final data = {
          'appIdentifier': widget.appIdentifier,
          'region': widget.region,
          'uuid': widget.uuid,
          'roomToken': widget.roomToken,
          'uid': widget.uid,
        };
        iframe.contentWindow?.postMessage({'type': 'init', 'payload': data}, '*');
      });

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
