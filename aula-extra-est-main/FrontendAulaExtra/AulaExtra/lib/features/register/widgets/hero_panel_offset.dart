import 'package:aula_extra/features/register/widgets/hero_panel.dart';
import 'package:flutter/material.dart';

class RegisterHeroPanelOffset extends StatelessWidget {
  const RegisterHeroPanelOffset({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 639.518,
      height: 999.781,
      child: const Stack(
        clipBehavior: Clip.none,
        children: [Positioned(top: 278, left: 0, child: RegisterHeroPanel())],
      ),
    );
  }
}
