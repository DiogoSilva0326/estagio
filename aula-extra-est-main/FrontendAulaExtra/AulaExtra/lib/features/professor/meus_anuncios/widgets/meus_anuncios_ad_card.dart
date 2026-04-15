import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/features/professor/meus_anuncios/constants/meus_anuncios_professor_constants.dart';
import 'package:aula_extra/features/professor/meus_anuncios/widgets/meus_anuncios_shared_widgets.dart';
import 'package:flutter/material.dart';

class MeusAnunciosAdCard extends StatelessWidget {
  const MeusAnunciosAdCard({
    required this.ad,
    required this.displayName,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onViewProfile,
    this.processingStatus = false,
    super.key,
  });

  final ProfessorAdDto ad;
  final String displayName;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onViewProfile;
  final bool processingStatus;

  String _formatPrice(double? value) {
    if (value == null) return '—';
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _modeLabel() {
    final normalized = (ad.tutoringTypeName ?? '').trim().toLowerCase();
    if (normalized.contains('grupo') || normalized.contains('group')) {
      return 'Aula em Grupo';
    }
    if (normalized.contains('individual') || normalized.contains('1:1')) {
      return 'Aula Individual';
    }
    return ad.tutoringTypeName?.trim().isNotEmpty == true
        ? ad.tutoringTypeName!.trim()
        : 'Aula';
  }

  String _firstNameLine() {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : displayName.trim();
  }

  String _secondNameLine() {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final isInactive = ad.status.trim().toLowerCase() == 'inactive';
    final modeLabel = _modeLabel();

    return SizedBox(
      width: 471.46,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 401.93),
        child: MeusAnunciosPanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MeusAnunciosAvatar(photoUrl: ad.photoUrl, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _firstNameLine(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: MeusAnunciosProfessorColors.title,
                                ),
                              ),
                              Text(
                                _secondNameLine(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: MeusAnunciosProfessorColors.title,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        MeusAnunciosModePill(label: modeLabel),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                ad.courseName.trim().isNotEmpty ? ad.courseName : 'Anúncio',
                style: const TextStyle(
                  color: MeusAnunciosProfessorColors.mutedText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if ((ad.disciplinaNome ?? '').trim().isNotEmpty)
                    MeusAnunciosInfoPill(label: ad.disciplinaNome!.trim()),
                  if ((ad.cicloEstudos ?? '').trim().isNotEmpty)
                    MeusAnunciosInfoPill(label: ad.cicloEstudos!.trim()),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                ad.description?.trim().isNotEmpty == true
                    ? ad.description!.trim()
                    : 'Sem descrição disponível.',
                style: const TextStyle(
                  color: MeusAnunciosProfessorColors.mutedText,
                  fontSize: 14.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatPrice(ad.sessionPrice)}€',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: MeusAnunciosProfessorColors.title,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/hora',
                      style: TextStyle(
                        color: MeusAnunciosProfessorColors.mutedText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewProfile,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(
                          color: MeusAnunciosProfessorColors.accent,
                        ),
                        foregroundColor: MeusAnunciosProfessorColors.accent,
                      ),
                      child: const Text('Ver Perfil'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isInactive
                        ? OutlinedButton(
                            onPressed: processingStatus ? null : onToggleStatus,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: const BorderSide(color: Color(0xFFBBF7D0)),
                              foregroundColor:
                                  MeusAnunciosProfessorColors.success,
                            ),
                            child: processingStatus
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Reativar'),
                          )
                        : FilledButton(
                            onPressed: onEdit,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor:
                                  MeusAnunciosProfessorColors.accent,
                            ),
                            child: const Text('Editar'),
                          ),
                  ),
                  if (!isInactive) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: processingStatus ? null : onToggleStatus,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          foregroundColor: MeusAnunciosProfessorColors.danger,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: processingStatus
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
