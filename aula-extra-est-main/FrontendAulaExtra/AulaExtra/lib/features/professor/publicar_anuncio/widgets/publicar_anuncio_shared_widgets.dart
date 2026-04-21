import 'package:aula_extra/features/professor/publicar_anuncio/constants/publicar_anuncio_professor_constants.dart';
import 'package:flutter/material.dart';

class PublicarAnuncioSurfaceCard extends StatelessWidget {
  const PublicarAnuncioSurfaceCard({
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
      padding: padding,
      decoration: BoxDecoration(
        color: PublicarAnuncioProfessorColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: PublicarAnuncioProfessorColors.surfaceBorder),
      ),
      child: child,
    );
  }
}

class PublicarAnuncioStateCard extends StatelessWidget {
  const PublicarAnuncioStateCard({
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
    return PublicarAnuncioSurfaceCard(
      padding: padding,
      radius: radius,
      child: child,
    );
  }
}

class PublicarAnuncioFieldLabel extends StatelessWidget {
  const PublicarAnuncioFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: PublicarAnuncioProfessorColors.title,
      ),
    );
  }
}

class PublicarAnuncioPreviewChip extends StatelessWidget {
  const PublicarAnuncioPreviewChip({
    required this.label,
    this.color = const Color(0xFFF3F4F6),
    this.textColor = const Color(0xFF374151),
    super.key,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class PublicarAnuncioProfileAvatar extends StatelessWidget {
  const PublicarAnuncioProfileAvatar({
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
              size: size * 0.48,
              color: const Color(0xFFFB923C),
            ),
    );
  }
}
