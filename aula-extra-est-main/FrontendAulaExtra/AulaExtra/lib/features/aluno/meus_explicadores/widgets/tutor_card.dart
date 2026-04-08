import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  const TutorCard({
    super.key,
    required this.name,
    required this.subject,
    this.subjects,
    this.avatarUrl,
    this.lastLessonDateText = '—',
    this.rating,
    this.progress = 0,
    this.onViewProfileTap,
    this.onChatTap,
    this.onScheduleTap,
  });

  final String name;
  final String subject;
  final List<String>? subjects;
  final String? avatarUrl;
  final String lastLessonDateText;
  final double? rating; // 0..5 (null when not rated)
  final double progress; // 0..1
  final VoidCallback? onViewProfileTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onScheduleTap;

  static const _orangeStart = Color(0xFFFF6B00);
  static const _orangeEnd = Color(0xFFFF9966);
  static const _green = Color(0xFF00C950);
  static const _blue = Color(0xFF2B7FFF);

  @override
  Widget build(BuildContext context) {
    final subjectList = (subjects == null || subjects!.isEmpty)
        ? <String>[subject]
        : subjects!.where((s) => s.trim().isNotEmpty).toList(growable: false);
    final primarySubject = subjectList.first;
    final remainingSubjects = subjectList.length > 1
      ? subjectList.sublist(1)
      : const <String>[];

    final clampedProgress = progress.clamp(0.0, 1.0);
    final clampedRating = rating?.clamp(0.0, 5.0);

    return SizedBox(
      width: 305.182,
      height: 557.062,
      child: Container(
        padding: const EdgeInsets.fromLTRB(33.09, 33.09, 33.09, 33.09),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.379),
          borderRadius: BorderRadius.circular(22.062),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.379), blurRadius: 4.137),
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.379), blurRadius: 2.758),
          ],
        ),
        child: Column(
          children: [
            // Avatar + name
            SizedBox(
              height: 172.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Avatar(avatarUrl: avatarUrl, name: name, size: 126.0),
                  const SizedBox(height: 6.0),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.82,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF101828),
                      height: 38.608 / 24.82,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6.0),

            // Subject chips
            SizedBox(
              height: 33.093,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: _SubjectChip(subject: primarySubject)),
                    if (remainingSubjects.isNotEmpty) ...[
                      const SizedBox(width: 11.031),
                      _SubjectsDropdownButton(subjects: remainingSubjects),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22.062),

            // Stats (last lesson + rating)
            Column(
              children: [
                _LabelValueRow(
                  label: 'Última aula:',
                  value: lastLessonDateText,
                  valueColor: const Color(0xFF101828),
                ),
                const SizedBox(height: 11.031),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Avaliação:',
                      style: TextStyle(
                        fontSize: 19.304,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                        height: 27.577 / 19.304,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 22.062, color: Color(0xFFFABD2D)),
                        const SizedBox(width: 5.515),
                        Text(
                          clampedRating == null ? '—' : '${clampedRating.toStringAsFixed(1)}/5',
                          style: const TextStyle(
                            fontSize: 19.304,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF101828),
                            height: 27.577 / 19.304,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22.062),

            // Progress
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progresso',
                      style: TextStyle(
                        fontSize: 16.546,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                        height: 22.062 / 16.546,
                      ),
                    ),
                    Text(
                      '${(clampedProgress * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 16.546,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                        height: 22.062 / 16.546,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5.515),
                _ProgressBar(value: clampedProgress),
              ],
            ),
            const Spacer(),

            const SizedBox(height: 22.062),

            // Buttons
            _ActionButtons(
              onViewProfileTap: onViewProfileTap,
              onChatTap: onChatTap,
              onScheduleTap: onScheduleTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.subject});
  final String subject;

  @override
  Widget build(BuildContext context) {
    final bg = _subjectColor(subject);
    return Container(
      height: 33.093,
      padding: const EdgeInsets.fromLTRB(16.546, 5.515, 16.546, 5.515),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(23133510)),
      child: Center(
        child: Text(
          subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16.546,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 22.062 / 16.546,
          ),
        ),
      ),
    );
  }

  Color _subjectColor(String subject) {
    switch (subject.trim().toLowerCase()) {
      case 'matemática':
      case 'matematica':
        return const Color(0xFF2B7FFF);
      case 'física':
      case 'fisica':
        return const Color(0xFF00C950);
      case 'química':
      case 'quimica':
        return const Color(0xFFA74AD4);
      case 'inglês':
      case 'ingles':
        return const Color(0xFFFF6900);
      default:
        return const Color(0xFF2B7FFF);
    }
  }
}

class _SubjectsDropdownButton extends StatelessWidget {
  const _SubjectsDropdownButton({required this.subjects});

  final List<String> subjects;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Ver restantes disciplinas',
      itemBuilder: (context) => [
        for (final subject in subjects)
          PopupMenuItem<String>(
            value: subject,
            child: Text(subject),
          ),
      ],
      child: Container(
        height: 33.093,
        padding: const EdgeInsets.fromLTRB(13, 5.515, 13, 5.515),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: const Color(0xFFD0D5DD), width: 1.2),
          borderRadius: BorderRadius.circular(23133510),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${subjects.length}',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF344054),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.avatarUrl, required this.name, this.size = 132.371});

  final String? avatarUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final outer = size;
    final borderWidth = 5.0;
    final inner = outer - borderWidth * 2 - 2; // small padding compensation
    final normalizedAvatarUrl = avatarUrl?.trim();
    final hasAvatar = normalizedAvatarUrl != null && normalizedAvatarUrl.isNotEmpty;

    return Container(
      width: outer,
      height: outer,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF3F4F6), width: borderWidth),
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                normalizedAvatarUrl,
                width: inner,
                height: inner,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: inner,
                  height: inner,
                  color: const Color(0xFFE5E7EB),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(fontSize: 42, color: Color(0xFF364153), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            : Container(
                width: inner,
                height: inner,
                color: const Color(0xFFE5E7EB),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(fontSize: 42, color: Color(0xFF364153), fontWeight: FontWeight.w600),
                  ),
                ),
              ),
      ),
    );
  }
}

class _LabelValueRow extends StatelessWidget {
  const _LabelValueRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19.304,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              height: 27.577 / 19.304,
            ),
          ),
        ),
        const SizedBox(width: 11.031),
        Text(
          value,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 19.304,
            fontWeight: FontWeight.w400,
            color: valueColor,
            height: 27.577 / 19.304,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  static const _radius = 23133510.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: SizedBox(
        height: 11.031,
        width: double.infinity,
        child: Stack(
          children: [
            Container(color: const Color(0xFFE5E7EB)),
            FractionallySizedBox(
              widthFactor: value,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [TutorCard._orangeStart, TutorCard._orangeEnd],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onViewProfileTap,
    required this.onChatTap,
    required this.onScheduleTap,
  });

  final VoidCallback? onViewProfileTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onScheduleTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 236.239,
      height: 74.459,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 71.389,
            height: 74.459,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [TutorCard._orangeStart, TutorCard._orangeEnd],
                ),
                borderRadius: BorderRadius.circular(19.304),
              ),
              child: TextButton(
                onPressed: onViewProfileTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19.304)),
                ),
                child: const Text(
                  'Ver\nPerfil',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 16.546,
                    fontWeight: FontWeight.w400,
                    height: 22.062 / 16.546,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 73,
            height: 73,
            child: OutlinedButton(
              onPressed: onChatTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(2.028),
                side: const BorderSide(color: TutorCard._blue, width: 2.028),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.278)),
              ),
              child: const Icon(Icons.chat_bubble_outline, size: 32.444, color: TutorCard._blue),
            ),
          ),
          SizedBox(
            width: 71.399,
            height: 74.459,
            child: ElevatedButton(
              onPressed: onScheduleTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: TutorCard._green,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19.304)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.calendar_today, size: 22.062, color: Colors.white),
                  SizedBox(height: 5.515),
                  Text(
                    'Marcar',
                    style: TextStyle(
                      fontSize: 16.546,
                      fontWeight: FontWeight.w400,
                      height: 22.062 / 16.546,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
