import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/explicador_item.dart';

class ReviewCandidaturaDialog extends StatelessWidget {
  const ReviewCandidaturaDialog({required this.item, super.key});

  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 40,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(item: item),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 29, 32, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CandidateProfileCard(item: item),
                          const SizedBox(height: 32),
                          _SectionLabel(
                            title: 'VERIFICAÇÕES AUTOMÁTICAS (ONFIDO)',
                          ),
                          const SizedBox(height: 16),
                          for (
                            var index = 0;
                            index < item.verifications.length;
                            index++
                          ) ...[
                            _VerificationCard(item: item.verifications[index]),
                            if (index != item.verifications.length - 1)
                              const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 32),
                          const _SectionLabel(title: 'FORMAÇÃO ACADÉMICA'),
                          const SizedBox(height: 16),
                          _AcademicCard(item: item),
                          const SizedBox(height: 32),
                          const _SectionLabel(title: 'APRESENTAÇÃO E PITCH'),
                          const SizedBox(height: 16),
                          _PitchMessageCard(
                            message: item.candidateMessage ?? '',
                          ),
                          const SizedBox(height: 16),
                          _PitchVideoCard(duration: item.videoDuration ?? '-'),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                _DialogFooter(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.item});

  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 97,
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 25),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Revisão de Candidatura',
                      style: TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.45,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            item.reviewStatusBackgroundColor ??
                            const Color(0x26FB7B02),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.reviewStatusLabel ?? item.statusLabel,
                        style: TextStyle(
                          color: item.reviewStatusColor ?? item.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verifique a identidade e as competências do explicador.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateProfileCard extends StatelessWidget {
  const _CandidateProfileCard({required this.item});

  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF41A7D7), Color(0xFF88C9EA)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              item.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.07,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.44,
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileLine(
                  icon: Icons.mail_outline_rounded,
                  text: item.email,
                ),
                const SizedBox(height: 8),
                _ProfileLine(
                  icon: Icons.phone_outlined,
                  text: item.phone ?? '-',
                ),
                const SizedBox(height: 8),
                _ProfileLine(
                  icon: Icons.location_on_outlined,
                  text: item.location ?? '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4A5565),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFD1D5DC),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.16,
          ),
        ),
      ],
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.item});

  final ExplicadorVerificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: const Color(0x0D4CAF50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x334CAF50)),
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: const Color(0xFF4CAF50)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                color: Color(0xFF1E2939),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.15,
              ),
            ),
          ),
          Icon(
            item.isApproved
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            size: 20,
            color: item.isApproved ? const Color(0xFF4CAF50) : AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _AcademicCard extends StatelessWidget {
  const _AcademicCard({required this.item});

  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.degreeTitle ?? '-',
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.degreeInstitution ?? '-',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 17),
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                size: 16,
                color: Color(0xFFFC9039),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.documentLabel ?? '-',
                  style: const TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0x1A41A7D7),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.documentActionLabel ?? 'Ver Documento',
                  style: const TextStyle(
                    color: Color(0xFF41A7D7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PitchMessageCard extends StatelessWidget {
  const _PitchMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 2, height: 88, color: const Color(0xFFFC9039)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF4A5565),
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                height: 1.6,
                letterSpacing: -0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchVideoCard extends StatelessWidget {
  const _PitchVideoCard({required this.duration});

  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          const Center(
            child: Opacity(
              opacity: 0.8,
              child: Icon(
                Icons.play_circle_outline_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC9039),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Vídeo Pitch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({required this.item});

  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 99,
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
        boxShadow: [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 20,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 160,
            child: SizedBox(
              height: 50,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0x33FFBDC0),
                  foregroundColor: const Color(0xFFED1C24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Rejeitar Perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.31,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 316,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D4CAF50),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text(
                  'Aprovar Explicador',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.31,
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
