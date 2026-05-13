import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/backoffice_professional_review_details.dart';

class BackofficeProfessionalReviewService {
  BackofficeProfessionalReviewService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeProfessionalReviewDetails> fetchProfessorDetails(
    String professorId,
  ) async {
    final token = await _requireToken();
    final payload = await _apiClient.getJson(
      ApiConfig.uri('/api/Professors/professors/$professorId/admin-review'),
      token: token,
    );

    return BackofficeProfessionalReviewDetails(
      idProfessor: _string(payload['idProfessor']),
      displayName: _string(payload['displayName'], fallback: 'Professor'),
      email: _string(payload['email'], fallback: '-'),
      mobileNumber: _nullable(payload['mobileNumber']),
      phoneNumber: _nullable(payload['phoneNumber']),
      educationLevel: _nullable(payload['educationLevel']),
      website: _nullable(payload['website']),
      photoUrl: _nullable(payload['photo'] ?? payload['profileImageUrl']),
      biography: _nullable(payload['biography']),
      presentationVideoUrl: _nullable(payload['presentationVideoUrl']),
      currentSchool: _nullable(payload['currentSchool']),
      yearsExperience: _intValue(payload['yearsExperience']),
      memberSince: _dateValue(payload['memberSince']),
      isApproved: _boolValue(payload['isApproved']),
      isActive: _boolValue(payload['isActive']),
      isVerified: _boolValue(payload['isVerified']),
      isVerifiedIban: _boolValue(payload['isVerifiedIban']),
      isRejected: _boolValue(payload['isRejected']),
      statusLabel: _string(payload['statusLabel'], fallback: 'PENDENTE'),
      lessonsCount: _intValue((payload['stats'] as Map?)?['lessonsCount']),
      averageRating: _doubleValue((payload['stats'] as Map?)?['avgRating']),
      reviewCount: _intValue((payload['stats'] as Map?)?['reviewCount']),
      areaNames: ((payload['areaNames'] as List?) ?? const <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      disciplinas: ((payload['disciplinas'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => _string(item['nome']))
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      languages: ((payload['languages'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => _string(item['nome']))
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      certificates: ((payload['certificates'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => BackofficeProfessionalCertificate(
              idCertificate: _string(item['idCertificate']),
              name: _string(item['name'], fallback: 'Documento sem nome'),
              description: _nullable(item['description']),
              fileUrl: _nullable(item['fileUrl']),
              approved: _boolValue(item['approved']),
              verified: _boolValue(item['verified']),
            ),
          )
          .toList(growable: false),
      reviews: ((payload['reviews'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => BackofficeProfessionalReviewEntry(
              reviewerName: _string(item['reviewerName'], fallback: 'Aluno'),
              rating: _intValue(item['rating']),
              comment: _nullable(item['comment']),
              createdAt: _dateValue(item['createdAt']),
            ),
          )
          .toList(growable: false),
      ibanDocumentUrl: _nullable(payload['ibanDocumentUrl']),
    );
  }

  Future<void> approveProfessor(String professorId) async {
    final token = await _requireToken();
    await _apiClient.putJson(
      ApiConfig.uri('/api/Professors/professors/$professorId/approve'),
      token: token,
    );
  }

  Future<void> rejectProfessor(String professorId) async {
    final token = await _requireToken();
    await _apiClient.putJson(
      ApiConfig.uri('/api/Professors/professors/$professorId/reject'),
      token: token,
    );
  }

  Future<void> banProfessor(String professorId) async {
    final token = await _requireToken();
    await _apiClient.putJson(
      ApiConfig.uri('/api/Professors/professors/$professorId/reject'),
      token: token,
    );
  }

  Future<void> reviewCertificate(
    String certificateId, {
    bool? approved,
    bool? verified,
  }) async {
    final token = await _requireToken();
    await _apiClient.putJson(
      ApiConfig.uri('/api/Professors/certificates/$certificateId/review'),
      token: token,
      body: <String, dynamic>{
        if (approved != null) 'approved': approved,
        if (verified != null) 'verified': verified,
      },
    );
  }

  Future<String> _requireToken() async {
    await _sessionController.initialize();
    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      throw Exception('Sem sessão de administrador ativa.');
    }
    return token;
  }

  String _string(Object? value, {String fallback = ''}) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  String? _nullable(Object? value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  bool _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _doubleValue(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _dateValue(Object? value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
