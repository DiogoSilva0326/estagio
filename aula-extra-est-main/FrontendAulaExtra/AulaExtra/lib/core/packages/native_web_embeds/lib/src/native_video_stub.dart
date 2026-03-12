import 'package:flutter/widgets.dart';

/// Non-web fallback for NativeVideo. Shows a simple placeholder.
class NativeVideo extends StatelessWidget {
  const NativeVideo({
    super.key,
    required this.src,
    this.controls = true,
    this.autoplay = false,
    this.loop = false,
    this.backgroundColor = const Color(0xFF000000),
  });

  final String src;
  final bool controls;
  final bool autoplay;
  final bool loop;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: const Center(
        child: Text(
          'Vídeo disponível apenas na versão web.',
          style: TextStyle(color: Color(0xFFFFFFFF)),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
