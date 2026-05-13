import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class PaginasInstitucionaisHeaderSection extends StatelessWidget {
  const PaginasInstitucionaisHeaderSection({required this.onCreate, super.key});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderText(),
              const SizedBox(height: 24),
              _CreateButton(onPressed: onCreate),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            _CreateButton(onPressed: onCreate),
          ],
        );
      },
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Páginas Institucionais',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 34.944,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4129,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4.659),
        Text(
          'Gestão de conteúdo estático do site.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16.307,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1752,
          ),
        ),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.592,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 18.637),
        label: const Text('Nova Página'),
        style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC9039),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: const Color(0x40FC9039),
              padding: const EdgeInsets.symmetric(horizontal: 23.296),
              textStyle: const TextStyle(
                fontSize: 16.307,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1752,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.307),
              ),
            ).copyWith(
              overlayColor: WidgetStatePropertyAll(
                Colors.white.withValues(alpha: 0.08),
              ),
            ),
      ),
    );
  }
}
