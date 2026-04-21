import 'package:aula_extra/features/disciplinas/constants/disciplinas_mobile_layout.dart';
import 'package:flutter/material.dart';

class DisciplinasMobileAreaCard extends StatelessWidget {
  const DisciplinasMobileAreaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    this.imageAsset,
    this.iconData,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color dotColor;
  final String? imageAsset;
  final IconData? iconData;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: DisciplinasMobileLayout.surface,
        borderRadius: BorderRadius.circular(DisciplinasMobileLayout.cardRadius),
        border: Border.all(
          color: selected
              ? dotColor.withValues(alpha: 0.75)
              : DisciplinasMobileLayout.border,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          _CardVisual(
            imageAsset: imageAsset,
            iconData: iconData,
            dotColor: dotColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: DisciplinasMobileLayout.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: DisciplinasMobileLayout.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DisciplinasMobileLayout.cardRadius),
      child: child,
    );
  }
}

class _CardVisual extends StatelessWidget {
  const _CardVisual({
    required this.imageAsset,
    required this.iconData,
    required this.dotColor,
  });

  final String? imageAsset;
  final IconData? iconData;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    if (imageAsset != null && imageAsset!.trim().isNotEmpty) {
      return Image.asset(
        imageAsset!,
        width: 52,
        height: 52,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(iconData ?? Icons.school_rounded, size: 28, color: dotColor),
    );
  }
}
