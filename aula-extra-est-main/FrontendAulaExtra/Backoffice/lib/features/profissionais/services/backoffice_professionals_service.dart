import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../../../design/theme/app_colors.dart';
import '../../explicadores/models/explicador_item.dart';

enum BackofficeProfessionalCategory {
  explicadores('explicadores'),
  tutores('tutores'),
  psicologos('psicologos');

  const BackofficeProfessionalCategory(this.apiValue);

  final String apiValue;
}

class BackofficeProfessionalsViewData {
  const BackofficeProfessionalsViewData({
    required this.items,
    this.warningMessage,
  });

  final List<ExplicadorItem> items;
  final String? warningMessage;
}

class BackofficeProfessionalsService {
  BackofficeProfessionalsService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeProfessionalsViewData> fetch(
    BackofficeProfessionalCategory category,
  ) async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      return const BackofficeProfessionalsViewData(
        items: <ExplicadorItem>[],
        warningMessage:
            'Sem sessão de administrador ativa. Inicie sessão para carregar estes utilizadores.',
      );
    }

    try {
      final payload = await _apiClient.getJson(
        ApiConfig.uri('/api/Professors/admin-directory').replace(
          queryParameters: <String, String>{'category': category.apiValue},
        ),
        token: token,
      );

      final rawItems = (payload['items'] as List?) ?? const <dynamic>[];
      return BackofficeProfessionalsViewData(
        items: rawItems
            .whereType<Map>()
            .map((item) => _mapItem(item.cast<String, dynamic>(), category))
            .toList(growable: false),
      );
    } catch (_) {
      return const BackofficeProfessionalsViewData(
        items: <ExplicadorItem>[],
        warningMessage:
            'Não foi possível sincronizar esta lista com a API. Tente novamente.',
      );
    }
  }

  ExplicadorItem _mapItem(
    Map<String, dynamic> json,
    BackofficeProfessionalCategory category,
  ) {
    final name = _stringValue(json['name'], fallback: 'Profissional');
    final isActive = _boolValue(json['isActive']);
    final isVerified = _boolValue(json['isVerified']);
    final isRejected = _boolValue(json['isRejected']);
    final statusLabel = _stringValue(
      json['statusLabel'],
      fallback: isActive ? 'ATIVO' : 'INATIVO',
    ).toUpperCase();
    final priceValue = _decimalValue(json['pricePerHour']);
    final reviewCount = _intValue(json['reviewCount']);
    final ratingValue = _decimalValue(json['averageRating']);
    final yearsExperience = _intValue(json['yearsExperience']);
    final currentSchool = _nullableString(json['currentSchool']);
    final biography = _nullableString(json['biography']);

    return ExplicadorItem(
      idProfessor: _stringValue(json['idProfessor'], fallback: ''),
      category: _stringValue(json['category'], fallback: category.apiValue),
      photoUrl: _nullableString(json['photoUrl']),
      initials: _buildInitials(name),
      name: name,
      email: _stringValue(json['email'], fallback: '-'),
      areaLabel: _stringValue(json['areaName'], fallback: 'Sem área'),
      mainSubject: _stringValue(
        json['primarySubject'],
        fallback: 'Sem especialidade',
      ),
      priceLabel: _formatPrice(priceValue),
      ratingLabel: _formatRating(ratingValue, reviewCount),
      statusLabel: statusLabel,
      isActive: isActive,
      isVerified: isVerified,
        isRejected: isRejected,
        statusColor: isRejected
          ? AppColors.danger
          : isActive
          ? const Color(0xFF4CAF50)
          : AppColors.warning,
        statusBackgroundColor: isRejected
          ? const Color(0x26F04438)
          : isActive
          ? const Color(0x264CAF50)
          : const Color(0x26FB7B02),
      phone: _nullableString(json['phone']),
      location: currentSchool,
      candidateMessage:
          biography ?? 'Sem apresentação adicional disponível neste momento.',
      degreeTitle: yearsExperience > 0
          ? '$yearsExperience anos de experiência'
          : 'Experiência não indicada',
      degreeInstitution: currentSchool ?? 'Localização não indicada',
      documentLabel: _documentLabelFor(category),
      documentActionLabel: 'Ver Documento',
      videoDuration: '-',
        reviewStatusLabel: _computeReviewStatusLabel(category, isRejected, isVerified, isActive),
        reviewStatusColor: _computeReviewStatusColor(category, isRejected, isVerified, isActive),
        reviewStatusBackgroundColor: _computeReviewStatusBackgroundColor(category, isRejected, isVerified, isActive),
      verifications: _verificationsFor(category, approved: isVerified),
    );
  }

  bool _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  String _stringValue(Object? value, {required String fallback}) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  String? _nullableString(Object? value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _decimalValue(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _formatPrice(double? price) {
    if (price == null || price <= 0) return '—';
    final hasDecimals = price % 1 != 0;
    return '€${price.toStringAsFixed(hasDecimals ? 2 : 0)}/h';
  }

  String _formatRating(double? rating, int reviewCount) {
    if (rating == null || reviewCount <= 0) return 'Sem avaliações';
    return '${rating.toStringAsFixed(1)} ($reviewCount aval.)';
  }

  String _buildInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return parts.isEmpty ? 'AE' : parts;
  }

  String _documentLabelFor(BackofficeProfessionalCategory category) {
    switch (category) {
      case BackofficeProfessionalCategory.explicadores:
        return 'Documentação académica em validação';
      case BackofficeProfessionalCategory.tutores:
        return 'Certificado pedagógico em validação';
      case BackofficeProfessionalCategory.psicologos:
        return 'Cédula profissional em validação';
    }
  }

  List<ExplicadorVerificationItem> _verificationsFor(
    BackofficeProfessionalCategory category, {
    required bool approved,
  }) {
    switch (category) {
      case BackofficeProfessionalCategory.explicadores:
        return <ExplicadorVerificationItem>[
          ExplicadorVerificationItem(
            label: 'Cartão de Cidadão / Passaporte',
            icon: Icons.person_outline_rounded,
            isApproved: approved,
          ),
          ExplicadorVerificationItem(
            label: 'Registo Criminal',
            icon: Icons.description_outlined,
            isApproved: approved,
          ),
        ];
      case BackofficeProfessionalCategory.tutores:
        return <ExplicadorVerificationItem>[
          ExplicadorVerificationItem(
            label: 'Cartão de Cidadão / Passaporte',
            icon: Icons.person_outline_rounded,
            isApproved: approved,
          ),
          ExplicadorVerificationItem(
            label: 'Certificado de Habilitações',
            icon: Icons.school_outlined,
            isApproved: approved,
          ),
        ];
      case BackofficeProfessionalCategory.psicologos:
        return <ExplicadorVerificationItem>[
          ExplicadorVerificationItem(
            label: 'Cartão de Cidadão / Passaporte',
            icon: Icons.person_outline_rounded,
            isApproved: approved,
          ),
          ExplicadorVerificationItem(
            label: 'Cédula Profissional',
            icon: Icons.verified_user_outlined,
            isApproved: approved,
          ),
        ];
    }
  }

  String _computeReviewStatusLabel(
    BackofficeProfessionalCategory category,
    bool isRejected,
    bool isVerified,
    bool isActive,
  ) {
    if (isRejected) return 'REJEITADO';
    if (isVerified && isActive) return 'APROVADO';
    
    // Mostrar "PENDENTE PSICÓLOGO" explicitamente para categoria de psicólogos
    if (category == BackofficeProfessionalCategory.psicologos) {
      return 'PENDENTE PSICÓLOGO';
    }
    
    return 'PENDENTE';
  }

  Color _computeReviewStatusColor(
    BackofficeProfessionalCategory category,
    bool isRejected,
    bool isVerified,
    bool isActive,
  ) {
    if (isRejected) return AppColors.danger;
    if (isVerified && isActive) return const Color(0xFF4CAF50);
    
    // Cor para "PENDENTE PSICÓLOGO" - laranja/warning
    if (category == BackofficeProfessionalCategory.psicologos) {
      return AppColors.warning;
    }
    
    return AppColors.warning;
  }

  Color _computeReviewStatusBackgroundColor(
    BackofficeProfessionalCategory category,
    bool isRejected,
    bool isVerified,
    bool isActive,
  ) {
    if (isRejected) return const Color(0x26F04438);
    if (isVerified && isActive) return const Color(0x264CAF50);
    
    // Background para "PENDENTE PSICÓLOGO" - laranja claro
    if (category == BackofficeProfessionalCategory.psicologos) {
      return const Color(0x26FB7B02);
    }
    
    return const Color(0x26FB7B02);
  }
}

