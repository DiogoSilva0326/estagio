import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class NotificationsService {
  NotificationsService({NotificationsApi? api, TokenStorage? tokenStorage})
    : _api = api ?? NotificationsApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final NotificationsApi _api;
  final TokenStorage _tokenStorage;

  Future<String> _loadRequiredToken() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const NotificationsException('Sessão expirada');
    }
    return token;
  }

  Future<List<UserNotificationDto>> fetchMyNotifications() async {
    final token = await _loadRequiredToken();
    return _api.getMyNotifications(token: token);
  }

  Future<void> markAsRead(String notificationId) async {
    final token = await _loadRequiredToken();
    await _api.markAsRead(token: token, notificationId: notificationId);
  }

  Future<void> markAllAsRead() async {
    final token = await _loadRequiredToken();
    await _api.markAllAsRead(token: token);
  }

  Future<void> createNotification({
    required String idUser,
    required String type,
    required String message,
  }) async {
    final token = await _loadRequiredToken();
    await _api.createNotification(
      token: token,
      idUser: idUser,
      type: type,
      message: message,
    );
  }

  Future<NotificationRecordDto> getNotificationById(
    String notificationId,
  ) async {
    final token = await _loadRequiredToken();
    return _api.getNotificationById(
      token: token,
      notificationId: notificationId,
    );
  }

  Future<void> updateNotification(NotificationRecordDto notification) async {
    final token = await _loadRequiredToken();
    await _api.updateNotification(token: token, notification: notification);
  }
}
