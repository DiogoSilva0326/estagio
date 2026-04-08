import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:http/http.dart' as http;

class NotificationRecordDto {
  const NotificationRecordDto({
    required this.idNotification,
    required this.idUser,
    required this.type,
    required this.message,
    required this.wasRead,
    this.createdAt,
    this.updatedAt,
  });

  final String idNotification;
  final String idUser;
  final String? type;
  final String? message;
  final bool wasRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationRecordDto copyWith({
    String? idNotification,
    String? idUser,
    String? type,
    String? message,
    bool? wasRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationRecordDto(
      idNotification: idNotification ?? this.idNotification,
      idUser: idUser ?? this.idUser,
      type: type ?? this.type,
      message: message ?? this.message,
      wasRead: wasRead ?? this.wasRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NotificationRecordDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      final raw = value?.toString().trim();
      if (raw == null || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    }

    return NotificationRecordDto(
      idNotification:
          (json['idNotification'] ?? json['IdNotification'])?.toString() ?? '',
      idUser: (json['idUser'] ?? json['IdUser'])?.toString() ?? '',
      type: (json['type'] ?? json['Type'])?.toString(),
      message: (json['message'] ?? json['Message'])?.toString(),
      wasRead: (json['wasRead'] ?? json['WasRead']) == true,
      createdAt: parseDate(json['createdAt'] ?? json['CreatedAt']),
      updatedAt: parseDate(json['updatedAt'] ?? json['UpdatedAt']),
    );
  }
}

class NotificationsApi {
  Future<List<UserNotificationDto>> getMyNotifications({
    required String token,
  }) async {
    final response = await http.get(
      ApiConfig.uri('/api/Users/me/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw const NotificationsException('Sessão expirada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationsException(
        'Falha ao carregar notificações (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! List) {
      throw const NotificationsException('Resposta inválida do servidor');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(UserNotificationDto.fromJson)
        .toList();
  }

  Future<void> markAsRead({
    required String token,
    required String notificationId,
  }) async {
    final response = await http.put(
      ApiConfig.uri('/api/Users/me/notifications/$notificationId/read'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'isRead': true}),
    );

    if (response.statusCode == 401) {
      throw const NotificationsException('Sessão expirada');
    }
    if (response.statusCode != 204) {
      throw NotificationsException(
        'Falha ao marcar notificação como lida (${response.statusCode})',
      );
    }
  }

  Future<void> markAllAsRead({required String token}) async {
    final response = await http.put(
      ApiConfig.uri('/api/Users/me/notifications/read-all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw const NotificationsException('Sessão expirada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationsException(
        'Falha ao marcar notificações como lidas (${response.statusCode})',
      );
    }
  }

  Future<void> createNotification({
    required String token,
    required String idUser,
    required String type,
    required String message,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final response = await http.post(
      ApiConfig.uri('/api/Communication/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'idUser': idUser,
        'type': type,
        'message': message,
        'wasRead': false,
        'createdAt': now,
        'updatedAt': now,
      }),
    );

    if (response.statusCode == 401) {
      throw const NotificationsException('Sessão expirada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationsException(
        'Falha ao criar notificação (${response.statusCode})',
      );
    }
  }

  Future<NotificationRecordDto> getNotificationById({
    required String token,
    required String notificationId,
  }) async {
    final response = await http.get(
      ApiConfig.uri('/api/Communication/notifications/$notificationId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw const NotificationsException('Sessão expirada');
    }
    if (response.statusCode == 404) {
      throw const NotificationsException('Notificação não encontrada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationsException(
        'Falha ao obter notificação (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const NotificationsException('Resposta inválida do servidor');
    }

    return NotificationRecordDto.fromJson(body);
  }

  Future<void> updateNotification({
    required String token,
    required NotificationRecordDto notification,
  }) async {
    final response = await http.put(
      ApiConfig.uri(
        '/api/Communication/notifications/${notification.idNotification}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'idNotification': notification.idNotification,
        'idUser': notification.idUser,
        'type': notification.type,
        'message': notification.message,
        'wasRead': notification.wasRead,
        'createdAt': notification.createdAt?.toUtc().toIso8601String(),
        'updatedAt': notification.updatedAt?.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 401) {
      throw const NotificationsException('Sessão expirada');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationsException(
        'Falha ao atualizar notificação (${response.statusCode})',
      );
    }
  }
}

class NotificationsException implements Exception {
  const NotificationsException(this.message);

  final String message;

  @override
  String toString() => message;
}
