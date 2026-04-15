import 'package:flutter/material.dart';

class FullBleedScaledSection extends StatelessWidget {
  const FullBleedScaledSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const designWidth = 1440.0;
        final scale = constraints.maxWidth < designWidth
            ? constraints.maxWidth / designWidth
            : 1.0;

        return Align(
          alignment: Alignment.topCenter,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: SizedBox(width: designWidth, child: child),
          ),
        );
      },
    );
  }
}
