import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms
class WhiteboardPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFF121212)),
      child: Center(
        child: Text(
          'Whiteboard não disponível nesta plataforma.\nUse a versão Web.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
