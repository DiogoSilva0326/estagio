import 'package:aula_extra/core/data/communication/chat_files_api.dart';
import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ChatFilesService {
  ChatFilesService({
    ChatFilesApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? ChatFilesApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ChatFilesApi _api;
  final TokenStorage _tokenStorage;

  Future<ChatUploadedFileDto> uploadFile({
    required List<int> bytes,
    required String fileName,
    String? contentType,
    String? userId,
    String? roomId,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ChatFilesException('Sessão expirada');
    }

    final uploaded = await _api.uploadFile(
      token: token,
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
      userId: userId,
      roomId: roomId,
    );

    return ChatUploadedFileDto(
      fileId: uploaded.fileId,
      fileName: uploaded.fileName,
      fileUrl: normalizeUrl(uploaded.fileUrl) ?? uploaded.fileUrl,
      contentType: uploaded.contentType,
      fileSizeBytes: uploaded.fileSizeBytes,
      thumbnailUrl: normalizeUrl(uploaded.thumbnailUrl),
    );
  }

  Future<List<ChatFileInfoDto>> getUserFiles({
    required String username,
    int limit = 100,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ChatFilesException('Sessão expirada');
    }

    final files = await _api.getUserFiles(
      token: token,
      username: username,
      limit: limit,
    );

    return files.map(_normalizeFileInfo).toList(growable: false);
  }

  Future<List<ChatFileInfoDto>> getRoomFiles({
    required String roomId,
    String? username,
    int limit = 100,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ChatFilesException('Sessão expirada');
    }

    final files = await _api.getRoomFiles(
      token: token,
      roomId: roomId,
      username: username,
      limit: limit,
    );

    return files.map(_normalizeFileInfo).toList(growable: false);
  }

  Future<void> deleteFile({required String fileId}) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ChatFilesException('Sessão expirada');
    }

    await _api.deleteFile(
      token: token,
      fileId: fileId,
    );
  }

  ChatFileInfoDto _normalizeFileInfo(ChatFileInfoDto file) {
    return ChatFileInfoDto(
      fileId: file.fileId,
      fileName: file.fileName,
      contentType: file.contentType,
      fileSizeBytes: file.fileSizeBytes,
      uploadedBy: file.uploadedBy,
      uploadedByDisplayName: file.uploadedByDisplayName,
      downloadUrl: normalizeUrl(file.downloadUrl) ?? file.downloadUrl,
      createdAt: file.createdAt,
      isOwnFile: file.isOwnFile,
      roomId: file.roomId,
      thumbnailUrl: normalizeUrl(file.thumbnailUrl),
    );
  }

  static String? normalizeUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    return ApiConfig.uri(raw).toString();
  }
}
