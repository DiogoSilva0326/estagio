import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';
import 'package:flutter/material.dart';

class FullBleedScaledSection extends StatelessWidget {
  const FullBleedScaledSection({super.key, required this.child});

  final Widget child;

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
              child: SizedBox(width: kTutorProfileDesignWidth, child: child),
            ),
          ),
        );
      },
    );
  }
}
