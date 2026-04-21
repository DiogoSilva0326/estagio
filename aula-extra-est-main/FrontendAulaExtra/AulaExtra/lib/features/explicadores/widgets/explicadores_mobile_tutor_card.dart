import 'package:aula_extra/features/explicadores/constants/explicadores_mobile_layout.dart';
import 'package:flutter/material.dart';

class ExplicadoresMobileTutorCard extends StatelessWidget {
  const ExplicadoresMobileTutorCard({
    super.key,
    required this.name,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
    required this.onViewProfileTap,
    required this.onBookLessonTap,
    this.photoUrl,
    this.showSuperBadge = true,
    this.accentChipLabel,
  });

  final String name;
  final String country;
  final double rating;
  final int reviewCount;
  final String description;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;
  final VoidCallback onViewProfileTap;
  final VoidCallback onBookLessonTap;
  final String? photoUrl;
  final bool showSuperBadge;
  final String? accentChipLabel;

  @override
  Widget build(BuildContext context) {
    final visibleTags = tags
        .where((tag) => tag.trim().isNotEmpty)
        .take(3)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(
          ExplicadoresMobileLayout.tutorCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.06),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TutorAvatar(photoUrl: photoUrl, name: name),
              const SizedBox(width: 16),
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
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.22,
                            fontWeight: FontWeight.w700,
                            color: ExplicadoresMobileLayout.textPrimary,
                          ),
                        ),
                        if (showSuperBadge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ExplicadoresMobileLayout.accentOrange,
                                  ExplicadoresMobileLayout.accentPink,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Super Explicador',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFF4A5565),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              country,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Color(0xFF4A5565),
                              ),
                            ),
                          ],
                        ),
                        if (accentChipLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              accentChipLabel!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1447E6),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: ExplicadoresMobileLayout.accentOrange,
                            ),
                          ),
                        ),
                        Text(
                          rating.toStringAsFixed(
                            rating.truncateToDouble() == rating ? 0 : 1,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: ExplicadoresMobileLayout.textPrimary,
                          ),
                        ),
                        Text(
                          '($reviewCount avaliações)',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: ExplicadoresMobileLayout.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: ExplicadoresMobileLayout.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: Color(0xFF4A5565),
              ),
              const SizedBox(width: 8),
              Text(
                lessonsText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: Color(0xFF4A5565),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visibleTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: ExplicadoresMobileLayout.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$pricePerHour€',
                      style: const TextStyle(
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: ExplicadoresMobileLayout.accentOrange,
                      ),
                    ),
                    const TextSpan(
                      text: '/hora',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        color: ExplicadoresMobileLayout.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: onViewProfileTap,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: ExplicadoresMobileLayout.accentOrange,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Ver Perfil',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: ExplicadoresMobileLayout.accentOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ExplicadoresMobileLayout.accentOrange,
                                ExplicadoresMobileLayout.accentPink,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: onBookLessonTap,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Marcar Aula',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TutorAvatar extends StatelessWidget {
  const _TutorAvatar({required this.photoUrl, required this.name});

  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'E' : name.trim().characters.first;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: ExplicadoresMobileLayout.accentOrange,
              width: 2,
            ),
            color: const Color(0xFFF3F4F6),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.trim().isNotEmpty
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        initial.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: ExplicadoresMobileLayout.textPrimary,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initial.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ExplicadoresMobileLayout.textPrimary,
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ExplicadoresMobileLayout.accentOrange,
                  ExplicadoresMobileLayout.accentPink,
                ],
              ),
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
