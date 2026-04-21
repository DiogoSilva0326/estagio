import 'package:aula_extra/features/disciplinas/constants/disciplinas_mobile_layout.dart';
import 'package:flutter/material.dart';

class DisciplinasMobileSubjectCard extends StatelessWidget {
  const DisciplinasMobileSubjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.areaLabel,
    required this.cycleLabel,
    required this.dotColor,
    this.imageAsset,
    this.iconData,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String areaLabel;
  final String cycleLabel;
  final Color dotColor;
  final String? imageAsset;
  final IconData? iconData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: DisciplinasMobileLayout.surface,
        borderRadius: BorderRadius.circular(DisciplinasMobileLayout.cardRadius),
        border: Border.all(color: DisciplinasMobileLayout.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardVisual(
                imageAsset: imageAsset,
                iconData: iconData,
                dotColor: dotColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 21,
                            height: 1.08,
                            fontWeight: FontWeight.w700,
                            color: DisciplinasMobileLayout.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: dotColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            areaLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: dotColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: DisciplinasMobileLayout.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cycleLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: DisciplinasMobileLayout.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DisciplinasMobileLayout.border),
            ),
            child: const Text(
              'Ver explicadores disponíveis para esta disciplina.',
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: DisciplinasMobileLayout.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ver explicadores',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DisciplinasMobileLayout.cardRadius),
      child: card,
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
        width: 56,
        height: 56,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        iconData ?? Icons.menu_book_rounded,
        size: 28,
        color: dotColor,
      ),
    );
  }
}
