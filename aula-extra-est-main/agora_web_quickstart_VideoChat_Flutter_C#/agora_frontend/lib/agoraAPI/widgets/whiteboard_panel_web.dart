// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

// import 'package:flutter/material.dart';

// class WhiteboardPanel extends StatelessWidget {
//   const WhiteboardPanel({
//     super.key,
//     required this.appIdentifier,
//     required this.region,
//     required this.uuid,
//     required this.roomToken,
//     required this.uid,
//   });

//   final String appIdentifier;
//   final String region;
//   final String uuid;
//   final String roomToken;
//   final int uid;

//   @override
//   Widget build(BuildContext context) {
//     return const DecoratedBox(
//       decoration: BoxDecoration(color: Color(0xFF121212)),
//       child: Center(
//         child: Text(
//           'Whiteboard no Web: WIP\n(use macOS/Android/iOS para o WebView)\n',
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.white54),
//         ),
//       ),
//     );
//   }
// }

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
  State<WhiteboardPanel> createState() => _WhiteboardPanelWebState();
}

class _WhiteboardPanelWebState extends State<WhiteboardPanel> {
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    // Criamos um ID único para o IFrame
    _viewId = 'whiteboard-${widget.uuid}';

    // Registamos a factory para o elemento HTML
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..src = 'assets/whiteboard/index.html?v=5'; // cache-bust to ensure latest asset

      // Esperar o carregamento para enviar as credenciais
      iframe.onLoad.listen((_) {
        final data = {
          'appIdentifier': widget.appIdentifier,
          'region': widget.region,
          'uuid': widget.uuid,
          'roomToken': widget.roomToken,
          'uid': widget.uid,
        };
        // Envia os dados para o JS dentro do iframe
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