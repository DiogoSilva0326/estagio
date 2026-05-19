class LessonClassroomEntryDto {
  const LessonClassroomEntryDto({
    required this.reservationId,
    required this.lessonId,
    required this.channelName,
    required this.chatChannelName,
    required this.chatDisplayName,
    required this.lessonTitle,
    required this.professorUsername,
    required this.professorDisplayName,
    required this.studentUsername,
    required this.studentDisplayName,
    required this.isHost,
    required this.agoraUid,
    required this.agoraAppId,
    required this.rtcToken,
    required this.whiteboard,
    this.startTime,
    this.endTime,
    this.screenShare,
  });

  final String reservationId;
  final String lessonId;
  final String channelName;
  final String chatChannelName;
  final String chatDisplayName;
  final String lessonTitle;
  final String professorUsername;
  final String professorDisplayName;
  final String studentUsername;
  final String studentDisplayName;
  final bool isHost;
  final int agoraUid;
  final String agoraAppId;
  final String rtcToken;
  final DateTime? startTime;
  final DateTime? endTime;
  final LessonClassroomScreenShareDto? screenShare;
  final LessonClassroomWhiteboardDto whiteboard;

  String get localDisplayName =>
      isHost ? professorDisplayName : studentDisplayName;

  String get remoteDisplayName =>
      isHost ? studentDisplayName : professorDisplayName;

  static String _readString(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final value = json[pascal] ?? json[camel];
    if (value == null) {
      throw const LessonClassroomException(
        'Resposta inválida da aula ao vivo.',
      );
    }
    return value.toString();
  }

  static int _readInt(Map<String, dynamic> json, String pascal, String camel) {
    final value = json[pascal] ?? json[camel];
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw const LessonClassroomException(
        'Resposta inválida da aula ao vivo.',
      );
    }
    return parsed;
  }

  static bool _readBool(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final value = json[pascal] ?? json[camel];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    throw const LessonClassroomException('Resposta inválida da aula ao vivo.');
  }

  static DateTime? _readNullableDateTime(
    Map<String, dynamic> json,
    String pascal,
    String camel,
  ) {
    final value = json[pascal] ?? json[camel];
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory LessonClassroomEntryDto.fromJson(Map<String, dynamic> json) {
    return LessonClassroomEntryDto(
      reservationId: _readString(json, 'ReservationId', 'reservationId'),
      lessonId: _readString(json, 'LessonId', 'lessonId'),
      channelName: _readString(json, 'ChannelName', 'channelName'),
      chatChannelName: (json['ChatChannelName'] ?? json['chatChannelName'] ?? '')
          .toString(),
      chatDisplayName: (json['ChatDisplayName'] ?? json['chatDisplayName'] ?? '')
          .toString(),
      lessonTitle: _readString(json, 'LessonTitle', 'lessonTitle'),
      professorUsername: _readString(
        json,
        'ProfessorUsername',
        'professorUsername',
      ),
      professorDisplayName: _readString(
        json,
        'ProfessorDisplayName',
        'professorDisplayName',
      ),
      studentUsername: _readString(json, 'StudentUsername', 'studentUsername'),
      studentDisplayName: _readString(
        json,
        'StudentDisplayName',
        'studentDisplayName',
      ),
      isHost: _readBool(json, 'IsHost', 'isHost'),
      agoraUid: _readInt(json, 'AgoraUid', 'agoraUid'),
      agoraAppId: _readString(json, 'AgoraAppId', 'agoraAppId'),
      rtcToken: _readString(json, 'RtcToken', 'rtcToken'),
      startTime: _readNullableDateTime(json, 'StartTime', 'startTime'),
      endTime: _readNullableDateTime(json, 'EndTime', 'endTime'),
      screenShare:
          (json['ScreenShare'] ?? json['screenShare']) is Map<String, dynamic>
          ? LessonClassroomScreenShareDto.fromJson(
              (json['ScreenShare'] ?? json['screenShare'])
                  as Map<String, dynamic>,
            )
          : null,
      whiteboard: LessonClassroomWhiteboardDto.fromJson(
        (json['Whiteboard'] ?? json['whiteboard']) as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
    );
  }
}

class LessonClassroomScreenShareDto {
  const LessonClassroomScreenShareDto({required this.uid, required this.token});

  final int uid;
  final String token;

  factory LessonClassroomScreenShareDto.fromJson(Map<String, dynamic> json) {
    final rawUid = json['Uid'] ?? json['uid'];
    final uid = rawUid is int ? rawUid : int.tryParse(rawUid?.toString() ?? '');
    final token = (json['Token'] ?? json['token'])?.toString();
    if (uid == null || token == null || token.isEmpty) {
      throw const LessonClassroomException(
        'Dados de partilha de ecrã inválidos.',
      );
    }

    return LessonClassroomScreenShareDto(uid: uid, token: token);
  }
}

class LessonClassroomWhiteboardDto {
  const LessonClassroomWhiteboardDto({
    required this.appIdentifier,
    required this.region,
    required this.uuid,
    required this.roomToken,
  });

  final String appIdentifier;
  final String region;
  final String uuid;
  final String roomToken;

  bool get isReady =>
      appIdentifier.trim().isNotEmpty &&
      uuid.trim().isNotEmpty &&
      roomToken.trim().isNotEmpty;

  factory LessonClassroomWhiteboardDto.fromJson(Map<String, dynamic> json) {
    return LessonClassroomWhiteboardDto(
      appIdentifier: (json['AppIdentifier'] ?? json['appIdentifier'] ?? '')
          .toString(),
      region: (json['Region'] ?? json['region'] ?? 'us-sv').toString(),
      uuid: (json['Uuid'] ?? json['uuid'] ?? '').toString(),
      roomToken: (json['RoomToken'] ?? json['roomToken'] ?? '').toString(),
    );
  }
}

class LessonClassroomException implements Exception {
  const LessonClassroomException(this.message);

  final String message;

  @override
  String toString() => message;
}
