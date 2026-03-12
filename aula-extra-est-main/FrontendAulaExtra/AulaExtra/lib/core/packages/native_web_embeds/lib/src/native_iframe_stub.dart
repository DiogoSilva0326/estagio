import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Non-web fallback for NativeIframe. Shows a placeholder with button to open externally.
class NativeIframe extends StatelessWidget {
  const NativeIframe({
    super.key,
    required this.src,
    this.aspectRatio = 16 / 9,
    this.fill = true,
    this.backgroundColor = const Color(0xFFF0F0F0),
  });

  final String src;
  final double aspectRatio;
  final bool fill;
  final Color backgroundColor;

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(src);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final placeHolder = Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: cs.onSurfaceVariant, size: 28),
          const SizedBox(height: 10),
          Text(
            'Conteúdo embebido disponível na versão web.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _openExternal,
            child: const Text('Abrir externamente'),
          ),
        ],
      ),
    );

    if (fill) return Center(child: placeHolder);
    return AspectRatio(aspectRatio: aspectRatio, child: Center(child: placeHolder));
  }
}
