import 'package:flutter/material.dart';

class FullBleedScaledSection extends StatelessWidget {
  const FullBleedScaledSection({super.key, required this.child});

  final Widget child;

  static const double designWidth = 1440.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(width: designWidth, child: child),
            ),
          ),
        );
      },
    );
  }
}
