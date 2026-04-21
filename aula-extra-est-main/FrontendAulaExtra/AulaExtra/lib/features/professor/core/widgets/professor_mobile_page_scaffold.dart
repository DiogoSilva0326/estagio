import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:flutter/material.dart';

class ProfessorMobilePageScaffold extends StatelessWidget {
  const ProfessorMobilePageScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
    this.footerTopSpacing = 0,
  });

  final Widget child;
  final Color? backgroundColor;
  final double footerTopSpacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            child,
                            if (footerTopSpacing > 0)
                              SizedBox(height: footerTopSpacing),
                          ],
                        ),
                        const FooterSection(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
