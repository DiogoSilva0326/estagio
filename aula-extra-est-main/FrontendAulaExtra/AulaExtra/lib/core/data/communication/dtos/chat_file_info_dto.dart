class ChatUploadedFileDto {
  const ChatUploadedFileDto({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
    required this.fileSizeBytes,
    this.thumbnailUrl,
  });

  final String fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;
  final int fileSizeBytes;
  final String? thumbnailUrl;

  factory ChatUploadedFileDto.fromJson(Map<String, dynamic> json) {
    return ChatUploadedFileDto(
      fileId: json['fileId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      fileSizeBytes: _parseInt(json['fileSizeBytes']),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
    );
  }
}

class ChatFileInfoDto {
  const ChatFileInfoDto({
    required this.fileId,
    required this.fileName,
    required this.contentType,
    required this.fileSizeBytes,
    required this.uploadedBy,
    required this.uploadedByDisplayName,
    required this.downloadUrl,
    required this.createdAt,
    required this.isOwnFile,
    this.roomId,
    this.thumbnailUrl,
  });

  final String fileId;
  final String fileName;
  final String contentType;
  final int fileSizeBytes;
  final String uploadedBy;
  final String uploadedByDisplayName;
  final String downloadUrl;
  final DateTime createdAt;
  final bool isOwnFile;
  final String? roomId;
  final String? thumbnailUrl;

  factory ChatFileInfoDto.fromJson(Map<String, dynamic> json) {
    return ChatFileInfoDto(
      fileId: json['fileId']?.toString() ?? '',
      fileName: json['fileName']?.toString() ?? '',
      contentType: json['contentType']?.toString() ?? '',
      fileSizeBytes: _parseInt(json['fileSizeBytes']),
      uploadedBy: json['uploadedBy']?.toString() ?? '',
      uploadedByDisplayName: json['uploadedByDisplayName']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      isOwnFile: _parseBool(json['isOwnFile']),
      roomId: json['roomId']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
    );
  }
}

int _parseInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _parseBool(Object? value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

DateTime _parseDateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return DateTime.now();
  return DateTime.tryParse(raw) ?? DateTime.now();
}
