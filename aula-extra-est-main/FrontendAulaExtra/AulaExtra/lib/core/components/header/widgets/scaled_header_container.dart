import 'package:flutter/material.dart';

class ScaledHeaderContainer extends StatelessWidget {
  const ScaledHeaderContainer({
    super.key,
    required this.height,
    required this.designWidth,
    required this.child,
    this.backgroundColor = Colors.white,
    this.boxShadow,
  });

  final double height;
  final double designWidth;
  final Widget child;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: boxShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: designWidth,
                      height: height,
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
