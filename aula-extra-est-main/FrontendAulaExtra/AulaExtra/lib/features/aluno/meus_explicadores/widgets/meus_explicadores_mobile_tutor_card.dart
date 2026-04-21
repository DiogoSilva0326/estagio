import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/features/aluno/meus_explicadores/constants/meus_explicadores_mobile_layout.dart';
import 'package:flutter/material.dart';

class MeusExplicadoresMobileTutorCard extends StatelessWidget {
  const MeusExplicadoresMobileTutorCard({
    super.key,
    required this.tutor,
    required this.primarySubject,
    required this.subjects,
    required this.lastLessonDateText,
    required this.onViewProfileTap,
    required this.onChatTap,
    required this.onScheduleTap,
    required this.onComplaintTap,
  });

  final MyTutorDto tutor;
  final String primarySubject;
  final List<String> subjects;
  final String lastLessonDateText;
  final VoidCallback onViewProfileTap;
  final VoidCallback onChatTap;
  final VoidCallback onScheduleTap;
  final VoidCallback onComplaintTap;

  @override
  Widget build(BuildContext context) {
    final rating = tutor.rating?.clamp(0.0, 5.0);
    final progress = tutor.progress.clamp(0.0, 1.0);
    final visibleSubjects = subjects.take(3).toList(growable: false);

    return Container(
      width: MeusExplicadoresMobileLayout.cardWidth,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MeusExplicadoresMobileLayout.surface,
        borderRadius: BorderRadius.circular(
          MeusExplicadoresMobileLayout.cardRadius,
        ),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
              _Avatar(photoUrl: tutor.avatarUrl, name: tutor.tutorName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.tutorName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: MeusExplicadoresMobileLayout.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            MeusExplicadoresMobileLayout.accentOrange,
                            MeusExplicadoresMobileLayout.accentPink,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        primarySubject,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'complaint') onComplaintTap();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'complaint',
                    child: Text('Submeter reclamação'),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Última aula:',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: MeusExplicadoresMobileLayout.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                lastLessonDateText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: MeusExplicadoresMobileLayout.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Avaliação:',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: MeusExplicadoresMobileLayout.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: Color(0xFFFABD2D),
              ),
              const SizedBox(width: 4),
              Text(
                rating == null ? '—' : '${rating.toStringAsFixed(1)}/5',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: MeusExplicadoresMobileLayout.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: MeusExplicadoresMobileLayout.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: MeusExplicadoresMobileLayout.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                MeusExplicadoresMobileLayout.accentOrange,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final subject in visibleSubjects)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: MeusExplicadoresMobileLayout.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MeusExplicadoresMobileLayout.accentOrange,
                        MeusExplicadoresMobileLayout.accentPink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: onViewProfileTap,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ver Perfil',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onChatTap,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    foregroundColor: MeusExplicadoresMobileLayout.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onScheduleTap,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                side: const BorderSide(color: Color(0xFFFFD7C2)),
                foregroundColor: MeusExplicadoresMobileLayout.accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text(
                'Marcar Aula',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});

  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();
    final hasAvatar = url != null && url.isNotEmpty;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF3F4F6), width: 3),
      ),
      padding: const EdgeInsets.all(3),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _FallbackAvatar(name: name),
              )
            : _FallbackAvatar(name: name),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF364153),
        ),
      ),
    );
  }
}
