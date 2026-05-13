import 'package:aula_extra/features/professor/meus_anuncios/constants/meus_anuncios_professor_constants.dart';
import 'package:flutter/material.dart';

class MeusAnunciosPanelCard extends StatelessWidget {
  const MeusAnunciosPanelCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(28),
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: MeusAnunciosProfessorColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: MeusAnunciosProfessorColors.surfaceBorder),
      ),
      child: child,
    );
  }
}

class MeusAnunciosAvatar extends StatelessWidget {
  const MeusAnunciosAvatar({
    required this.photoUrl,
    required this.size,
    super.key,
  });

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalized = photoUrl?.trim();
    final hasPhoto = normalized != null && normalized.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFF7ED),
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(normalized),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Icon(
              Icons.person_rounded,
              size: size * 0.44,
              color: const Color(0xFFFB923C),
            ),
    );
  }
}

class MeusAnunciosInfoPill extends StatelessWidget {
  const MeusAnunciosInfoPill({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
        ),
      ),
    );
  }
}

class MeusAnunciosModePill extends StatelessWidget {
  const MeusAnunciosModePill({
    required this.label,
    this.compact = false,
    this.color, // <-- PROPRIEDADE NOVA ADICIONADA AQUI
    super.key,
  });

  final String label;
  final bool compact;
  final Color? color; // <-- VARIÁVEL NOVA AQUI

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? null : 137.87,
      height: compact ? null : 52.34,
      constraints: compact
          ? const BoxConstraints(minWidth: 118, minHeight: 42)
          : null,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
          : null,
      decoration: BoxDecoration(
        color: color, // Aplica cor sólida se existir (Psicólogo/Tutor)
        gradient: color == null // Se não existir cor, aplica o degradé Laranja (Explicador)
            ? const LinearGradient(
                begin: Alignment(0.5, 0.0),
                end: Alignment(0.5, 1.0),
                colors: [Color(0xFFFFB36B), Color(0xFFFB6D63)],
              )
            : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: compact
            ? Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              )
            : SizedBox(
                width: 122.99,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.7,
                    fontFamily: 'Helvetica Neue',
                    fontWeight: FontWeight.w500,
                    height: 1.33,
                  ),
                ),
              ),
      ),
    );
  }
}

class MeusAnunciosStatusPill extends StatelessWidget {
  const MeusAnunciosStatusPill({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final isPublished = normalized == 'published';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPublished
            ? MeusAnunciosProfessorColors.activeBackground
            : MeusAnunciosProfessorColors.warningBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPublished ? 'Ativo' : 'Inativo',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isPublished
              ? MeusAnunciosProfessorColors.activeText
              : MeusAnunciosProfessorColors.warningText,
        ),
      ),
    );
  }
}