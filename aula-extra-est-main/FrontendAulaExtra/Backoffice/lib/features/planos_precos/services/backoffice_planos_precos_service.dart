import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../../configuracoes/services/backoffice_system_settings_service.dart';
import '../models/plano_item.dart';

class BackofficePlanCourseOption {
  const BackofficePlanCourseOption({required this.id, required this.name});

  final String id;
  final String name;
}

class BackofficePlanDraft {
  const BackofficePlanDraft({
    required this.courseId,
    required this.name,
    required this.description,
    required this.price,
    required this.numberOfLessons,
    required this.isActive,
  });

  final String courseId;
  final String name;
  final String description;
  final double price;
  final int numberOfLessons;
  final bool isActive;
}

class BackofficePlanosPrecosData {
  const BackofficePlanosPrecosData({
    required this.items,
    required this.courses,
    required this.baseCommission,
  });

  final List<PlanoItem> items;
  final List<BackofficePlanCourseOption> courses;
  final String baseCommission;
}

class BackofficePlanosPrecosService {
  BackofficePlanosPrecosService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
    BackofficeSystemSettingsService? settingsService,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance,
       _settingsService =
           settingsService ?? BackofficeSystemSettingsService();

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;
  final BackofficeSystemSettingsService _settingsService;

  Future<BackofficePlanosPrecosData> fetchData() async {
    final token = await _validatedToken();
    final coursesPayload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Courses/courses'),
      token: token,
    );
    final lessonPacksPayload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Courses/lesson-packs'),
      token: token,
    );
    final settings = await _settingsService.fetchAll();

    final courses = coursesPayload
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .map(
          (item) => BackofficePlanCourseOption(
            id: item['idCourse']?.toString() ?? '',
            name: (item['name']?.toString() ?? '').trim(),
          ),
        )
        .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList(growable: false);

    final items = lessonPacksPayload
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .map(_mapLessonPack)
        .whereType<PlanoItem>()
        .toList(growable: false);

    final commission = settings
        .where(
          (item) => item.key.toLowerCase() ==
              'payments.platform.base_commission_percent',
        )
        .map((item) => item.value?.trim() ?? '')
        .where((item) => item.isNotEmpty)
        .cast<String?>()
        .firstOrNull;

    return BackofficePlanosPrecosData(
      items: items,
      courses: courses,
      baseCommission: commission ?? '20',
    );
  }

  Future<void> createPlan(BackofficePlanDraft draft) async {
    final token = await _validatedToken();
    await _apiClient.postJson(
      ApiConfig.uri('/api/Courses/lesson-packs'),
      token: token,
      body: <String, dynamic>{
        'idCourse': draft.courseId,
        'name': draft.name,
        'description': draft.description,
        'numberOfLessons': draft.numberOfLessons,
        'totalPrice': draft.price,
        'isActive': draft.isActive,
      },
    );
  }

  Future<void> updatePlan(String id, BackofficePlanDraft draft) async {
    final token = await _validatedToken();
    await _apiClient.putJson(
      ApiConfig.uri('/api/Courses/lesson-packs/$id'),
      token: token,
      body: <String, dynamic>{
        'idLessonPack': id,
        'idCourse': draft.courseId,
        'name': draft.name,
        'description': draft.description,
        'numberOfLessons': draft.numberOfLessons,
        'totalPrice': draft.price,
        'isActive': draft.isActive,
      },
    );
  }

  Future<void> saveBaseCommission(String value) async {
    await _settingsService.upsertMany([
      BackofficeSystemSettingDraft(
        key: 'payments.platform.base_commission_percent',
        value: value,
        dataType: 'number',
        description: 'Comissão base aplicada pela plataforma aos pagamentos.',
      ),
    ]);
  }

  PlanoItem? _mapLessonPack(Map<String, dynamic> json) {
    final id = json['idLessonPack']?.toString() ?? '';
    final courseId = json['idCourse']?.toString() ?? '';
    if (id.isEmpty || courseId.isEmpty) {
      return null;
    }

    final name = (json['name']?.toString() ?? '').trim();
    final description = (json['description']?.toString() ?? '').trim();
    final lessons = _asInt(json['numberOfLessons']);
    final totalPrice = _asDouble(json['totalPrice']);
    final isActive = _asBool(json['isActive']);

    final style = _resolveStyle(lessons, isActive);

    return PlanoItem(
      id: id,
      courseId: courseId,
      name: name.isEmpty ? 'Plano sem nome' : name,
      subtitle: '',
      description: description.isEmpty ? 'Sem descrição.' : description,
      priceLabel: '${totalPrice.toStringAsFixed(2)}€',
      numberOfLessons: lessons,
      isActive: isActive,
      badgeLabel: style.badgeLabel,
      badgeBackgroundColor: style.badgeBackgroundColor,
      badgeTextColor: style.badgeTextColor,
      icon: style.icon,
      iconBackgroundColor: style.iconBackgroundColor,
      iconColor: style.iconColor,
    );
  }

  _PlanVisualStyle _resolveStyle(int lessons, bool isActive) {
    if (!isActive) {
      return const _PlanVisualStyle(
        badgeLabel: 'INATIVO',
        badgeBackgroundColor: Color(0xFFF3F4F6),
        badgeTextColor: Color(0xFF667085),
        icon: Icons.pause_circle_outline_rounded,
        iconBackgroundColor: Color(0xFFF3F4F6),
        iconColor: Color(0xFF667085),
      );
    }

    if (lessons >= 8) {
      return const _PlanVisualStyle(
        badgeLabel: 'POPULAR',
        badgeBackgroundColor: Color(0xFFFFF2E8),
        badgeTextColor: Color(0xFFFB7B02),
        icon: Icons.workspace_premium_outlined,
        iconBackgroundColor: Color(0xFFFFF2E8),
        iconColor: Color(0xFFFB7B02),
      );
    }

    return const _PlanVisualStyle(
      badgeLabel: 'ATIVO',
      badgeBackgroundColor: Color(0xFFEAFBF3),
      badgeTextColor: Color(0xFF027A48),
      icon: Icons.school_outlined,
      iconBackgroundColor: Color(0xFFEAF2FB),
      iconColor: Color(0xFF41A7D7),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true';
  }

  Future<String> _validatedToken() async {
    await _sessionController.initialize();
    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      throw Exception('Sem sessão de administrador ativa.');
    }

    return token;
  }
}

class _PlanVisualStyle {
  const _PlanVisualStyle({
    required this.badgeLabel,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String badgeLabel;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
}