import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/api_config.dart';
import '../../../design/theme/app_colors.dart';
import '../../profissionais/models/backoffice_professional_review_details.dart';
import '../../profissionais/services/backoffice_professional_review_service.dart';
import '../models/explicador_item.dart';

class ReviewCandidaturaDialog extends StatefulWidget {
  const ReviewCandidaturaDialog({
    required this.item,
    super.key,
    this.entityLabel = 'explicador',
    this.entityTitle = 'Explicador',
  });

  final ExplicadorItem item;
  final String entityLabel;
  final String entityTitle;

  @override
  State<ReviewCandidaturaDialog> createState() =>
      _ReviewCandidaturaDialogState();
}

class _ReviewCandidaturaDialogState extends State<ReviewCandidaturaDialog> {
  late final BackofficeProfessionalReviewService _service;
  late Future<BackofficeProfessionalReviewDetails> _future;
  bool _submitting = false;
  String? _reviewingCertificateId;

  @override
  void initState() {
    super.initState();
    _service = BackofficeProfessionalReviewService();
    _future = _service.fetchProfessorDetails(widget.item.idProfessor);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.fetchProfessorDetails(widget.item.idProfessor);
    });
  }

  Future<void> _submitAction({required bool approve}) async {
    setState(() {
      _submitting = true;
    });

    try {
      final supportType = switch (widget.item.category) {
        'tutores' => 'tutor',
        'psicologos' => 'psicologo',
        _ => 'professor',
      };

      if (approve) {
        await _service.approveProfessor(
          widget.item.idProfessor,
          supportType: supportType,
        );
      } else {
        await _service.rejectProfessor(
          widget.item.idProfessor,
          supportType: supportType,
        );
      }

      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? '${widget.entityTitle} aprovado com sucesso.'
                : '${widget.entityTitle} rejeitado com sucesso.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível concluir a ação: $error')),
      );

      setState(() {
        _submitting = false;
      });
    }
  }

  Future<void> _reviewCertificate(
    String certificateId, {
    bool? approved,
    bool? verified,
  }) async {
    setState(() {
      _reviewingCertificateId = certificateId;
    });

    try {
      await _service.reviewCertificate(
        certificateId,
        approved: approved,
        verified: verified,
      );

      await _reload();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento atualizado com sucesso.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível rever o documento: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reviewingCertificateId = null;
        });
      }
    }
  }

  Future<void> _previewDocument(
    String title,
    String? fileUrl,
  ) async {
    final resolved = ApiConfig.resolveUrl(fileUrl);
    if (resolved == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O documento não tem URL disponível.')),
      );
      return;
    }

    if (_isImageFile(resolved)) {
      await showDialog<void>(
        context: context,
        builder: (_) => _ImagePreviewDialog(title: title, imageUrl: resolved),
      );
      return;
    }

    await _launchExternal(resolved);
  }

  Future<void> _downloadDocument(String? fileUrl) async {
    final resolved = ApiConfig.resolveUrl(fileUrl);
    if (resolved == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O documento não tem URL disponível.')),
      );
      return;
    }

    await _launchExternal(resolved);
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o documento.')),
      );
    }
  }

  bool _isImageFile(String url) {
    final normalized = url.toLowerCase();
    return normalized.endsWith('.png') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
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
            child: FutureBuilder<BackofficeProfessionalReviewDetails>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return _ErrorState(
                    onRetry: _reload,
                    entityTitle: widget.entityTitle.toLowerCase(),
                  );
                }

                final details = snapshot.data!;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogHeader(
                      details: details,
                      item: widget.item,
                      entityLabel: widget.entityLabel,
                      entityTitle: widget.entityTitle,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProfileCard(details: details, item: widget.item),
                              const SizedBox(height: 24),
                              _InfoGrid(details: details, item: widget.item),
                              const SizedBox(height: 24),
                              const _SectionLabel(title: 'DOCUMENTOS SUBMETIDOS'),
                              const SizedBox(height: 12),
                              _CertificatesSection(
                                details: details,
                                item: widget.item,
                                reviewingCertificateId: _reviewingCertificateId,
                                onPreviewDocument: _previewDocument,
                                onDownloadDocument: _downloadDocument,
                                onReviewCertificate: _reviewCertificate,
                              ),
                              const SizedBox(height: 24),
                              const _SectionLabel(title: 'BIOGRAFIA E APRESENTAÇÃO'),
                              const SizedBox(height: 12),
                              _BiographySection(details: details),
                              const SizedBox(height: 24),
                              const _SectionLabel(title: 'AVALIAÇÕES RECENTES'),
                              const SizedBox(height: 12),
                              _ReviewsSection(details: details),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _DialogFooter(
                      entityTitle: widget.entityTitle,
                      details: details,
                      item: widget.item,
                      submitting: _submitting,
                      onApprove: () => _submitAction(approve: true),
                      onReject: () => _submitAction(approve: false),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.details,
    required this.item,
    required this.entityLabel,
    required this.entityTitle,
  });

  final BackofficeProfessionalReviewDetails details;
  final ExplicadorItem item;
  final String entityLabel;
  final String entityTitle;

  @override
  Widget build(BuildContext context) {
    final badgeColor = item.isRejected
        ? AppColors.danger
        : item.isApproved
            ? const Color(0xFF4CAF50)
            : AppColors.warning;
    final badgeBackground = item.isRejected
        ? const Color(0x26F04438)
        : item.isApproved
            ? const Color(0x264CAF50)
            : const Color(0x26FB7B02);

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Revisão de Candidatura · $entityTitle',
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.45,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.moderationLabel,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Consulte os dados reais do $entityLabel antes de aprovar ou rejeitar a candidatura.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.details, required this.item});

  final BackofficeProfessionalReviewDetails details;
  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    final resolvedPhotoUrl = ApiConfig.resolveUrl(details.photoUrl ?? item.photoUrl);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DialogProfileAvatar(
            initials: item.initials,
            photoUrl: resolvedPhotoUrl,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.displayName,
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
                  text: details.email,
                ),
                const SizedBox(height: 8),
                _ProfileLine(
                  icon: Icons.phone_outlined,
                  text: details.mobileNumber ?? details.phoneNumber ?? '-',
                ),
                const SizedBox(height: 8),
                _ProfileLine(
                  icon: Icons.location_on_outlined,
                  text: details.currentSchool ?? 'Sem localização indicada',
                ),
                const SizedBox(height: 8),
                _ProfileLine(
                  icon: Icons.category_outlined,
                  text: details.areaNames.isEmpty
                      ? item.areaLabel
                      : details.areaNames.join(', '),
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
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.details, required this.item});

  final BackofficeProfessionalReviewDetails details;
  final ExplicadorItem item;

  @override
  Widget build(BuildContext context) {
    final items = <_InfoTileData>[
      _InfoTileData('Estado', details.statusLabel),
      _InfoTileData('Validação', item.moderationLabel),
      _InfoTileData(
        'Experiência',
        details.yearsExperience > 0
            ? '${details.yearsExperience} anos'
            : 'Não indicada',
      ),
      _InfoTileData(
        'Membro desde',
        _formatDate(details.memberSince) ?? 'Sem data',
      ),
      _InfoTileData(
        'Especialidades',
        details.disciplinas.isNotEmpty
          ? details.disciplinas.join(', ')
          : details.areaNames.isEmpty
            ? 'Sem especialidades'
            : details.areaNames.join(', '),
      ),
      _InfoTileData(
        'Línguas',
        details.languages.isEmpty ? 'Sem línguas' : details.languages.join(', '),
      ),
      _InfoTileData('Educação', details.educationLevel ?? 'Não indicada'),
      _InfoTileData('Website', details.website ?? 'Sem website'),
      _InfoTileData('Sessões', '${details.lessonsCount}'),
      _InfoTileData(
        'Avaliação',
        details.reviewCount > 0
            ? '${details.averageRating.toStringAsFixed(1)} (${details.reviewCount})'
            : 'Sem avaliações',
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map((item) => SizedBox(width: 340, child: _InfoTile(item: item)))
          .toList(growable: false),
    );
  }

  String? _formatDate(DateTime? value) {
    if (value == null) {
      return null;
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _InfoTileData {
  const _InfoTileData(this.label, this.value);

  final String label;
  final String value;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.item});

  final _InfoTileData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.16,
      ),
    );
  }
}

class _CertificatesSection extends StatelessWidget {
  const _CertificatesSection({
    required this.details,
    required this.item,
    required this.reviewingCertificateId,
    required this.onPreviewDocument,
    required this.onDownloadDocument,
    required this.onReviewCertificate,
  });

  final BackofficeProfessionalReviewDetails details;
  final ExplicadorItem item;
  final String? reviewingCertificateId;
  final Future<void> Function(String title, String? fileUrl) onPreviewDocument;
  final Future<void> Function(String? fileUrl) onDownloadDocument;
  final Future<void> Function(String certificateId, {bool? approved, bool? verified})
  onReviewCertificate;

  @override
  Widget build(BuildContext context) {
    if (details.certificates.isEmpty &&
        details.ibanDocumentUrl == null &&
        details.psychologistProofDocumentUrl == null) {
      return const _EmptyBlock(message: 'Não existem documentos submetidos.');
    }

    final items = <Widget>[
      for (final certificate in details.certificates)
        _CertificateTile(
          certificate: certificate,
          isSubmitting: reviewingCertificateId == certificate.idCertificate,
          onPreviewDocument: onPreviewDocument,
          onDownloadDocument: onDownloadDocument,
          onReviewCertificate: onReviewCertificate,
        ),
      if (details.ibanDocumentUrl != null)
        _CertificateTile(
          certificate: BackofficeProfessionalCertificate(
            idCertificate: 'iban-document',
            name: 'Documento IBAN',
            description: 'Documento bancário submetido pelo profissional.',
            fileUrl: details.ibanDocumentUrl,
            approved: details.isVerifiedIban,
            verified: details.isVerifiedIban,
            canReview: false,
          ),
          isSubmitting: false,
          onPreviewDocument: onPreviewDocument,
          onDownloadDocument: onDownloadDocument,
          onReviewCertificate: onReviewCertificate,
        ),
      if (details.psychologistProofDocumentUrl != null)
        _CertificateTile(
          certificate: BackofficeProfessionalCertificate(
            idCertificate: 'psychologist-proof-document',
            name: 'Comprovativo de Psicólogo',
            description: 'Documento obrigatório para aprovação de psicólogo.',
            fileUrl: details.psychologistProofDocumentUrl,
            approved: item.isApproved,
            verified: item.isApproved,
            canReview: false,
          ),
          isSubmitting: false,
          onPreviewDocument: onPreviewDocument,
          onDownloadDocument: onDownloadDocument,
          onReviewCertificate: onReviewCertificate,
        ),
    ];

    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          items[index],
          if (index != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CertificateTile extends StatelessWidget {
  const _CertificateTile({
    required this.certificate,
    required this.isSubmitting,
    required this.onPreviewDocument,
    required this.onDownloadDocument,
    required this.onReviewCertificate,
  });

  final BackofficeProfessionalCertificate certificate;
  final bool isSubmitting;
  final Future<void> Function(String title, String? fileUrl) onPreviewDocument;
  final Future<void> Function(String? fileUrl) onDownloadDocument;
  final Future<void> Function(String certificateId, {bool? approved, bool? verified})
  onReviewCertificate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.name,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (certificate.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    certificate.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (certificate.fileUrl != null) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => onPreviewDocument(certificate.name, certificate.fileUrl),
                    child: Text(
                      ApiConfig.resolveUrl(certificate.fileUrl) ?? certificate.fileUrl!,
                      style: const TextStyle(
                      color: Color(0xFF41A7D7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DocumentStatusPill(
                      label: certificate.approved ? 'Aprovado' : 'Não aprovado',
                      positive: certificate.approved,
                    ),
                    _DocumentStatusPill(
                      label: certificate.verified ? 'Verificado' : 'Não verificado',
                      positive: certificate.verified,
                    ),
                  ],
                ),
                if (certificate.fileUrl != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniActionButton(
                        label: 'Pré-visualizar',
                        icon: Icons.remove_red_eye_outlined,
                        onPressed: () => onPreviewDocument(certificate.name, certificate.fileUrl),
                      ),
                      _MiniActionButton(
                        label: 'Download',
                        icon: Icons.download_rounded,
                        onPressed: () => onDownloadDocument(certificate.fileUrl),
                      ),
                    ],
                  ),
                ],
                if (certificate.canReview) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MiniActionButton(
                        label: certificate.approved ? 'Marcar não aprovado' : 'Aprovar ficheiro',
                        icon: certificate.approved
                            ? Icons.cancel_outlined
                            : Icons.task_alt_outlined,
                        onPressed: isSubmitting
                            ? null
                            : () => onReviewCertificate(
                                  certificate.idCertificate,
                                  approved: !certificate.approved,
                                ),
                      ),
                      _MiniActionButton(
                        label: certificate.verified ? 'Marcar não verificado' : 'Verificar ficheiro',
                        icon: certificate.verified
                            ? Icons.verified_outlined
                            : Icons.fact_check_outlined,
                        onPressed: isSubmitting
                            ? null
                            : () => onReviewCertificate(
                                  certificate.idCertificate,
                                  verified: !certificate.verified,
                                ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isSubmitting)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

class _DialogProfileAvatar extends StatelessWidget {
  const _DialogProfileAvatar({required this.initials, required this.photoUrl});

  final String initials;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
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
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (photoUrl == null) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        photoUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class _DocumentStatusPill extends StatelessWidget {
  const _DocumentStatusPill({required this.label, required this.positive});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: positive ? const Color(0x264CAF50) : const Color(0x26FB7B02),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: positive ? const Color(0xFF4CAF50) : AppColors.warning,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.borderSoft),
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  const _ImagePreviewDialog({required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: InteractiveViewer(
                  child: Center(
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BiographySection extends StatelessWidget {
  const _BiographySection({required this.details});

  final BackofficeProfessionalReviewDetails details;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Text(
            details.biography ?? 'Sem biografia submetida.',
            style: const TextStyle(
              color: Color(0xFF4A5565),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vídeo de apresentação',
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                details.presentationVideoUrl ?? 'Sem vídeo submetido.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.details});

  final BackofficeProfessionalReviewDetails details;

  @override
  Widget build(BuildContext context) {
    if (details.reviews.isEmpty) {
      return const _EmptyBlock(message: 'Ainda não existem avaliações recentes.');
    }

    return Column(
      children: [
        for (var index = 0; index < details.reviews.length; index++) ...[
          _ReviewTile(review: details.reviews[index]),
          if (index != details.reviews.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final BackofficeProfessionalReviewEntry review;

  @override
  Widget build(BuildContext context) {
    final createdAt = review.createdAt;
    final createdAtLabel = createdAt == null
        ? null
        : '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '⭐ ${review.rating}',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
          if (createdAtLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              createdAtLabel,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.entityTitle,
    required this.details,
    required this.item,
    required this.submitting,
    required this.onApprove,
    required this.onReject,
  });

  final String entityTitle;
  final BackofficeProfessionalReviewDetails details;
  final ExplicadorItem item;
  final bool submitting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final canModerate = !item.isApproved;

    return Container(
      height: 99,
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: submitting ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Fechar'),
            ),
          ),
          if (canModerate) ...[
            const SizedBox(width: 16),
            Expanded(
              child: TextButton(
                onPressed: submitting ? null : onReject,
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0x33FFBDC0),
                  foregroundColor: const Color(0xFFED1C24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('Rejeitar $entityTitle'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: submitting ? null : onApprove,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color(0xFFF15C64),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text('Aprovar $entityTitle'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.entityTitle});

  final Future<void> Function() onRetry;
  final String entityTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(
            'Não foi possível carregar os dados completos de $entityTitle.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
