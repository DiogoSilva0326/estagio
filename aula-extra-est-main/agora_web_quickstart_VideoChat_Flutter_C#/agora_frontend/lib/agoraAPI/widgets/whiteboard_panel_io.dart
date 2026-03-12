import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  final Completer<void> _pageLoaded = Completer<void>();
  String? _lastMessage;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'WhiteboardChannel',
        onMessageReceived: (message) {
          setState(() {
            _lastMessage = message.message;
          });
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!_pageLoaded.isCompleted) {
              _pageLoaded.complete();
            }
            _initWhiteboard();
          },
          onWebResourceError: (error) {
            setState(() {
              _lastMessage = 'WebView error: ${error.errorCode} ${error.description}';
            });
          },
        ),
      );

    _loadHtml();
  }

  @override
  void didUpdateWidget(covariant WhiteboardPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uuid != widget.uuid || oldWidget.roomToken != widget.roomToken || oldWidget.uid != widget.uid) {
      _initWhiteboard();
    }
  }

  Future<void> _loadHtml() async {
    // Load as a Flutter asset so relative files (e.g. fastboard.bundle.js) can be resolved.
    await _controller.loadFlutterAsset('assets/whiteboard/index.html');
  }

  Future<void> _initWhiteboard() async {
    await _pageLoaded.future;

    final payload = jsonEncode({
      'appIdentifier': widget.appIdentifier,
      'region': widget.region,
      'uuid': widget.uuid,
      'roomToken': widget.roomToken,
      'uid': widget.uid,
    });

    await _controller.runJavaScript('window.initWhiteboard($payload)');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_lastMessage != null)
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _lastMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
