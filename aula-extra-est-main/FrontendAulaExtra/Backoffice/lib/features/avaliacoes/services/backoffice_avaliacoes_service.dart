import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/avaliacao_item.dart';

class BackofficeAvaliacoesSummary {
  const BackofficeAvaliacoesSummary({
    required this.averageRating,
    required this.totalEvaluations,
    required this.pendingModeration,
    required this.lessonEvaluations,
    required this.professorEvaluations,
  });

  const BackofficeAvaliacoesSummary.empty()
    : averageRating = 0,
      totalEvaluations = 0,
      pendingModeration = 0,
      lessonEvaluations = 0,
      professorEvaluations = 0;

  final double averageRating;
  final int totalEvaluations;
  final int pendingModeration;
  final int lessonEvaluations;
  final int professorEvaluations;

  BackofficeAvaliacoesSummary copyWith({
    double? averageRating,
    int? totalEvaluations,
    int? pendingModeration,
    int? lessonEvaluations,
    int? professorEvaluations,
  }) {
    return BackofficeAvaliacoesSummary(
      averageRating: averageRating ?? this.averageRating,
      totalEvaluations: totalEvaluations ?? this.totalEvaluations,
      pendingModeration: pendingModeration ?? this.pendingModeration,
      lessonEvaluations: lessonEvaluations ?? this.lessonEvaluations,
      professorEvaluations: professorEvaluations ?? this.professorEvaluations,
    );
  }
}

class BackofficeAvaliacoesViewData {
  const BackofficeAvaliacoesViewData({
    required this.summary,
    required this.lessonSummary,
    required this.professorSummary,
    required this.lessonEvaluations,
    required this.professorEvaluations,
    this.warningMessage,
  });

  const BackofficeAvaliacoesViewData.empty()
    : summary = const BackofficeAvaliacoesSummary.empty(),
      lessonSummary = const BackofficeAvaliacoesSummary.empty(),
      professorSummary = const BackofficeAvaliacoesSummary.empty(),
      lessonEvaluations = const <AvaliacaoItem>[],
      professorEvaluations = const <AvaliacaoItem>[],
      warningMessage = null;

  final BackofficeAvaliacoesSummary summary;
  final BackofficeAvaliacoesSummary lessonSummary;
  final BackofficeAvaliacoesSummary professorSummary;
  final List<AvaliacaoItem> lessonEvaluations;
  final List<AvaliacaoItem> professorEvaluations;
  final String? warningMessage;

  bool get isEmpty =>
      lessonEvaluations.isEmpty && professorEvaluations.isEmpty;

  BackofficeAvaliacoesViewData updateItem(
    String itemId,
    AvaliacaoStatus nextStatus,
  ) {
    List<AvaliacaoItem> updateList(List<AvaliacaoItem> items) {
      return items
          .map((item) => item.id == itemId ? item.copyWith(status: nextStatus) : item)
          .toList(growable: false);
    }

    final updatedLessonEvaluations = updateList(lessonEvaluations);
    final updatedProfessorEvaluations = updateList(professorEvaluations);
    final allItems = <AvaliacaoItem>[
      ...updatedLessonEvaluations,
      ...updatedProfessorEvaluations,
    ];
    final updatedLessonSummary = _computeSummaryForItems(
      updatedLessonEvaluations,
      lessonEvaluationsCount: updatedLessonEvaluations.length,
      professorEvaluationsCount: updatedProfessorEvaluations.length,
    );
    final updatedProfessorSummary = _computeSummaryForItems(
      updatedProfessorEvaluations,
      lessonEvaluationsCount: updatedLessonEvaluations.length,
      professorEvaluationsCount: updatedProfessorEvaluations.length,
    );
    final updatedGlobalSummary = _computeSummaryForItems(
      allItems,
      lessonEvaluationsCount: updatedLessonEvaluations.length,
      professorEvaluationsCount: updatedProfessorEvaluations.length,
    );

    return BackofficeAvaliacoesViewData(
      summary: updatedGlobalSummary,
      lessonSummary: updatedLessonSummary,
      professorSummary: updatedProfessorSummary,
      lessonEvaluations: updatedLessonEvaluations,
      professorEvaluations: updatedProfessorEvaluations,
      warningMessage: warningMessage,
    );
  }

  BackofficeAvaliacoesSummary _computeSummaryForItems(
    List<AvaliacaoItem> items, {
    required int lessonEvaluationsCount,
    required int professorEvaluationsCount,
  }) {
    final approvedRatings = items
        .where((item) => item.status == AvaliacaoStatus.aprovada)
        .map((item) => item.estrelas)
        .where((value) => value > 0)
        .toList(growable: false);

    return BackofficeAvaliacoesSummary(
      averageRating: approvedRatings.isEmpty
          ? 0
          : approvedRatings.reduce((left, right) => left + right) /
                approvedRatings.length,
      totalEvaluations: items.length,
      pendingModeration:
          items.where((item) => item.status == AvaliacaoStatus.pendente).length,
      lessonEvaluations: lessonEvaluationsCount,
      professorEvaluations: professorEvaluationsCount,
    );
  }
}

class BackofficeAvaliacoesService {
  BackofficeAvaliacoesService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeAvaliacoesViewData> fetch() async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      return const BackofficeAvaliacoesViewData(
        summary: BackofficeAvaliacoesSummary.empty(),
        lessonSummary: BackofficeAvaliacoesSummary.empty(),
        professorSummary: BackofficeAvaliacoesSummary.empty(),
        lessonEvaluations: <AvaliacaoItem>[],
        professorEvaluations: <AvaliacaoItem>[],
        warningMessage:
            'Sem sessão de administrador ativa. Inicie sessão para carregar as avaliacoes.',
      );
    }

    try {
      final payload = await _apiClient.getJson(
        ApiConfig.uri('/api/admin/evaluations'),
        token: token,
      );

      final lessonItems = ((payload['lessonEvaluations'] as List?) ??
              const <dynamic>[])
          .whereType<Map>()
          .map((raw) => _mapItem(raw.cast<String, dynamic>(), AvaliacaoKind.aula))
          .toList(growable: false);

      final professorItems = ((payload['professorEvaluations'] as List?) ??
              const <dynamic>[])
          .whereType<Map>()
          .map(
            (raw) => _mapItem(raw.cast<String, dynamic>(), AvaliacaoKind.professor),
          )
          .toList(growable: false);

      final summaryPayload = (payload['summary'] as Map?)?.cast<String, dynamic>();
      final computedSummary = _computeSummary(lessonItems, professorItems);

      return BackofficeAvaliacoesViewData(
        summary: BackofficeAvaliacoesSummary(
          averageRating:
              _doubleValue(summaryPayload?['averageRating']) ?? computedSummary.averageRating,
          totalEvaluations:
              _intValue(summaryPayload?['totalEvaluations']) ?? computedSummary.totalEvaluations,
          pendingModeration:
              _intValue(summaryPayload?['pendingModeration']) ?? computedSummary.pendingModeration,
          lessonEvaluations:
              _intValue(summaryPayload?['lessonEvaluations']) ?? lessonItems.length,
          professorEvaluations:
              _intValue(summaryPayload?['professorEvaluations']) ?? professorItems.length,
        ),
        lessonSummary: _computeSummaryForItems(
          lessonItems,
          lessonEvaluationsCount: lessonItems.length,
          professorEvaluationsCount: professorItems.length,
        ),
        professorSummary: _computeSummaryForItems(
          professorItems,
          lessonEvaluationsCount: lessonItems.length,
          professorEvaluationsCount: professorItems.length,
        ),
        lessonEvaluations: lessonItems,
        professorEvaluations: professorItems,
      );
    } catch (_) {
      return const BackofficeAvaliacoesViewData(
        summary: BackofficeAvaliacoesSummary.empty(),
        lessonSummary: BackofficeAvaliacoesSummary.empty(),
        professorSummary: BackofficeAvaliacoesSummary.empty(),
        lessonEvaluations: <AvaliacaoItem>[],
        professorEvaluations: <AvaliacaoItem>[],
        warningMessage:
            'Nao foi possivel sincronizar as avaliacoes com a API. Tente novamente.',
      );
    }
  }

  Future<void> moderate({
    required AvaliacaoItem item,
    required bool approved,
  }) async {
    final token = await _requireToken();
    final kind = item.kind == AvaliacaoKind.aula ? 'lesson' : 'professor';

    await _apiClient.putJson(
      ApiConfig.uri('/api/admin/evaluations/$kind/${item.id}/moderation'),
      token: token,
      body: <String, dynamic>{
        'approved': approved,
      },
    );
  }

  BackofficeAvaliacoesSummary _computeSummary(
    List<AvaliacaoItem> lessonItems,
    List<AvaliacaoItem> professorItems,
  ) {
    return _computeSummaryForItems(
      <AvaliacaoItem>[...lessonItems, ...professorItems],
      lessonEvaluationsCount: lessonItems.length,
      professorEvaluationsCount: professorItems.length,
    );
  }

  BackofficeAvaliacoesSummary _computeSummaryForItems(
    List<AvaliacaoItem> items, {
    required int lessonEvaluationsCount,
    required int professorEvaluationsCount,
  }) {
    final approvedRatings = items
        .where((item) => item.status == AvaliacaoStatus.aprovada)
        .map((item) => item.estrelas)
        .where((value) => value > 0)
        .toList(growable: false);

    return BackofficeAvaliacoesSummary(
      averageRating: approvedRatings.isEmpty
          ? 0
          : approvedRatings.reduce((left, right) => left + right) /
                approvedRatings.length,
      totalEvaluations: items.length,
      pendingModeration:
          items.where((item) => item.status == AvaliacaoStatus.pendente).length,
      lessonEvaluations: lessonEvaluationsCount,
      professorEvaluations: professorEvaluationsCount,
    );
  }

  AvaliacaoItem _mapItem(
    Map<String, dynamic> json,
    AvaliacaoKind kind,
  ) {
    final id = _string(json['evaluationId']);
    final rating = _intValue(json['rating']) ?? 0;
    final targetName = _string(json['targetName'], fallback: 'Sem profissional');
    final subjectName = _string(
      json['subjectName'],
      fallback: kind == AvaliacaoKind.aula ? 'Sem disciplina' : 'Professor',
    );

    return AvaliacaoItem(
      id: id,
      kind: kind,
      code: _buildCode(kind, id),
      aluno: _string(json['studentName'], fallback: 'Aluno'),
      explicador: targetName,
      disciplina: subjectName,
      estrelas: rating.clamp(0, 5),
      comment: _string(json['comment'], fallback: 'Sem comentario.'),
      dateLabel: _formatDate(_parseDate(json['createdAt'])),
      status: _mapStatus(json['isValid']),
    );
  }

  AvaliacaoStatus _mapStatus(dynamic value) {
    final parsed = _boolValue(value);
    if (parsed == null) {
      return AvaliacaoStatus.pendente;
    }

    return parsed ? AvaliacaoStatus.aprovada : AvaliacaoStatus.rejeitada;
  }

  String _buildCode(AvaliacaoKind kind, String id) {
    final prefix = kind == AvaliacaoKind.aula ? 'AULA' : 'PROF';
    final compact = id.replaceAll('-', '').toUpperCase();
    final suffix = compact.length <= 6 ? compact : compact.substring(compact.length - 6);
    return '#$prefix-$suffix';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString())?.toLocal();
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '--';
    }

    const months = <String>[
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]}';
  }

  Future<String> _requireToken() async {
    await _sessionController.initialize();
    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      throw Exception('Sessao de administrador indisponivel.');
    }

    return token;
  }

  String _string(dynamic value, {String fallback = ''}) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }

    return normalized;
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  double? _doubleValue(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  bool? _boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value == null) {
      return null;
    }

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }

    return null;
  }
}