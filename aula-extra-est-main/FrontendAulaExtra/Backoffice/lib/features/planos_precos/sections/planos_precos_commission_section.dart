import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';

class PlanosPrecosCommissionSection extends StatelessWidget {
  const PlanosPrecosCommissionSection({
    required this.controller,
    required this.onSave,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.fromLTRB(38.438, 38.438, 38.438, 38.438),
      borderRadius: 27.955,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 760;
          final leading = Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 55.91,
                height: 55.91,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FB),
                  borderRadius: BorderRadius.circular(18.637),
                ),
                child: const Icon(
                  Icons.percent_rounded,
                  size: 27.955,
                  color: Color(0xFF41A7D7),
                ),
              ),
              const SizedBox(width: 18.637),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comissão da Plataforma (Base)',
                      style: TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 24.525,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.45,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'A taxa padrão cobrada por cada sessão realizada na plataforma.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final trailing = _CommissionEditor(
            controller: controller,
            onSave: onSave,
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [leading, const SizedBox(height: 24), trailing],
            );
          }

          return Row(
            children: [
              Expanded(child: leading),
              const SizedBox(width: 24),
              trailing,
            ],
          );
        },
      ),
    );
  }
}

class _CommissionEditor extends StatelessWidget {
  const _CommissionEditor({required this.controller, required this.onSave});

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 242.304,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.307),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.307),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 20.966,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.51,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 22),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 51.251,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                ),
                borderRadius: BorderRadius.circular(16.307),
              ),
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.307),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                ),
                child: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.307,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1752,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
