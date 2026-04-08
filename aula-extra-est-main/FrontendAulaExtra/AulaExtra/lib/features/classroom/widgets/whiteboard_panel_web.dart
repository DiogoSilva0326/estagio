// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui;

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
  late final String _iframeSrc;

  @override
  void initState() {
    super.initState();
    _viewId =
        'whiteboard-${widget.uuid}-${DateTime.now().millisecondsSinceEpoch}';
    // Whiteboard files live in web/whiteboard/ (copied verbatim to build/web/whiteboard/).
    // We must resolve from the document base so --base-href is respected.
    final baseDocumentUri = Uri.parse(
      html.document.baseUri ?? Uri.base.toString(),
    );
    _iframeSrc = baseDocumentUri
        .resolve(
          'whiteboard/index.html?v=${DateTime.now().millisecondsSinceEpoch}',
        )
        .toString();

    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..src = _iframeSrc;

      iframe.onLoad.listen((_) {
        iframe.contentWindow?.postMessage(<String, Object>{
          'type': 'init',
          'payload': <String, Object>{
            'appIdentifier': widget.appIdentifier,
            'region': widget.region,
            'uuid': widget.uuid,
            'roomToken': widget.roomToken,
            'uid': widget.uid,
          },
        }, '*');
      });

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}
