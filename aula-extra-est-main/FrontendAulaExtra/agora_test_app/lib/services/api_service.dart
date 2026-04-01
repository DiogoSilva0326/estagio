import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Service for communicating with the Synget.AgoraIntegrator.API backend
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  bool _urlLogged = false;

  String get baseUrl {
    final value = dotenv.env['API_BASE_URL'];
    String url;
    if (value == null || value.trim().isEmpty) {
      url = 'http://localhost:5050';
    } else {
      url = value.endsWith('/') ? value.substring(0, value.length - 1) : value;
    }
    
    if (!_urlLogged) {
      debugPrint('ApiService: Using API URL: $url');
      _urlLogged = true;
    }
    
    return url;
  }

  // ==================== TOKEN ENDPOINTS ====================

  /// Fetch RTC token for video/audio calls
  Future<TokenResponse> fetchRtcToken({
    required String channelName,
    required String uid,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/token/rtc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'uid': uid,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('RTC token request failed', response.statusCode, response.body);
    }

    return TokenResponse.fromJson(jsonDecode(response.body));
  }

  /// Fetch RTM token for messaging
  Future<TokenResponse> fetchRtmToken({required String userId}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/token/rtm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('RTM token request failed', response.statusCode, response.body);
    }

    return TokenResponse.fromJson(jsonDecode(response.body));
  }

  // ==================== SESSION ENDPOINTS ====================

  /// Create a new session
  Future<SessionResponse> createSession({
    required String channelName,
    required String hostUserId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/session/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'hostUserId': hostUserId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Create session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body));
  }

  /// Join an existing session or create one if it doesn't exist
  Future<SessionResponse> joinOrCreateSession({
    required String channelName,
    required String userId,
    String? displayName,
  }) async {
    try {
      // Try to join existing session first
      return await joinSession(
        channelName: channelName,
        userId: userId,
        displayName: displayName,
      );
    } on SessionNotFoundException {
      // Session doesn't exist, create it
      await createSession(
        channelName: channelName,
        hostUserId: userId,
      );
      // Now join with display name
      return await joinSession(
        channelName: channelName,
        userId: userId,
        displayName: displayName,
      );
    }
  }

  /// Join an existing session
  Future<SessionResponse> joinSession({
    required String channelName,
    required String userId,
    String? displayName,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/session/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'userId': userId,
        'displayName': ?displayName,
      }),
    );

    if (response.statusCode == 404) {
      throw SessionNotFoundException(channelName);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Join session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body));
  }

  /// Leave a session
  Future<SessionResponse> leaveSession({
    required String channelName,
    required String userId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/session/leave'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'userId': userId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Leave session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body));
  }

  /// Get session by channel name
  Future<SessionResponse?> getSession(String channelName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/session/$channelName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get session failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body));
  }

  /// Get all sessions
  Future<List<SessionResponse>> getAllSessions() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/session'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get all sessions failed', response.statusCode, response.body);
    }

    final List<dynamic> json = jsonDecode(response.body);
    return json.map((e) => SessionResponse.fromJson(e)).toList();
  }

  /// End a session
  Future<void> endSession(String channelName) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/session/$channelName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('End session failed', response.statusCode, response.body);
    }
  }

  // ==================== WHITEBOARD ENDPOINTS ====================

  /// Fetch whiteboard token for a channel
  Future<WhiteboardTokenResponse> fetchWhiteboardToken({
    required String channelName,
    required int uid,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/whiteboard/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'uid': uid,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Whiteboard token request failed', response.statusCode, response.body);
    }

    return WhiteboardTokenResponse.fromJson(jsonDecode(response.body));
  }

  // ==================== USER MUTE ENDPOINTS ====================

  /// Set a user's audio mute state in a session
  Future<SessionResponse> setUserAudioMute({
    required String channelName,
    required String userId,
    required bool muted,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/session/$channelName/mute/audio'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'muted': muted}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Set user audio mute failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body));
  }

  /// Set a user's video mute state in a session
  Future<SessionResponse> setUserVideoMute({
    required String channelName,
    required String userId,
    required bool muted,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/session/$channelName/mute/video'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'muted': muted}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Set user video mute failed', response.statusCode, response.body);
    }

    return SessionResponse.fromJson(jsonDecode(response.body));
  }

  /// Get a participant's state in a session
  Future<SessionUser?> getSessionUser({
    required String channelName,
    required String userId,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/session/$channelName/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get session user failed', response.statusCode, response.body);
    }

    return SessionUser.fromJson(jsonDecode(response.body));
  }

  // ==================== CONTACTS ENDPOINTS ====================

  /// Get all contacts for a user
  Future<List<Contact>> getContacts(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/contacts/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get contacts failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Add a contact
  Future<Contact> addContact({
    required String ownerId,
    required String contactUserId,
    required String displayName,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ownerId': ownerId,
        'contactUserId': contactUserId,
        'displayName': displayName,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Add contact failed', response.statusCode, response.body);
    }

    return Contact.fromJson(jsonDecode(response.body));
  }

  /// Remove a contact
  Future<void> removeContact(String ownerId, String contactUserId) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/contacts/$ownerId/$contactUserId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Remove contact failed', response.statusCode, response.body);
    }
  }

  // ==================== CONTACT REQUEST ENDPOINTS ====================

  /// Send a contact request
  Future<ContactRequest> sendContactRequest({
    required String fromUserId,
    required String toUserId,
    required String fromDisplayName,
    String? message,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/contacts/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'fromDisplayName': fromDisplayName,
        'message': ?message,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Send contact request failed', response.statusCode, response.body);
    }

    return ContactRequest.fromJson(jsonDecode(response.body));
  }

  /// Accept a contact request
  Future<void> acceptContactRequest(String requestId, String displayName) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/contacts/request/$requestId/accept?displayName=$displayName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Accept contact request failed', response.statusCode, response.body);
    }
  }

  /// Reject a contact request
  Future<void> rejectContactRequest(String requestId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/contacts/request/$requestId/reject'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Reject contact request failed', response.statusCode, response.body);
    }
  }

  /// Cancel a sent contact request
  Future<void> cancelContactRequest(String requestId, String userId) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/contacts/request/$requestId/cancel?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Cancel contact request failed', response.statusCode, response.body);
    }
  }

  /// Get pending contact requests (received)
  Future<List<ContactRequest>> getPendingContactRequests(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/contacts/request/pending/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get pending requests failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ContactRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get sent contact requests
  Future<List<ContactRequest>> getSentContactRequests(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/contacts/request/sent/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get sent requests failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ContactRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Check if user can send messages to another user
  Future<MessagePermission> canSendMessage(String fromUserId, String toUserId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/contacts/canmessage/$fromUserId/$toUserId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Check message permission failed', response.statusCode, response.body);
    }

    return MessagePermission.fromJson(jsonDecode(response.body));
  }

  // ==================== FILE UPLOAD ENDPOINTS ====================

  /// Upload a file and get the file info for chat attachment
  Future<FileUploadResult> uploadFile(File file, {String? userId, String? roomId}) async {
    var uri = Uri.parse('$baseUrl/api/files/upload');
    if (userId != null || roomId != null) {
      uri = uri.replace(queryParameters: {
        'userId': ?userId,
        'roomId': ?roomId,
      });
    }

    final request = http.MultipartRequest('POST', uri);

    final mimeType = _getMimeType(file.path);
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType.parse(mimeType),
    ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('File upload failed', response.statusCode, response.body);
    }

    return FileUploadResult.fromJson(jsonDecode(response.body));
  }

  /// Upload file from bytes (for web)
  Future<FileUploadResult> uploadFileBytes(List<int> bytes, String fileName, {String? userId, String? roomId}) async {
    var uri = Uri.parse('$baseUrl/api/files/upload');
    if (userId != null || roomId != null) {
      uri = uri.replace(queryParameters: {
        'userId': ?userId,
        'roomId': ?roomId,
      });
    }

    final request = http.MultipartRequest('POST', uri);

    final mimeType = _getMimeType(fileName);
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ));

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('File upload failed', response.statusCode, response.body);
    }

    return FileUploadResult.fromJson(jsonDecode(response.body));
  }

  /// Get file download URL
  String getFileDownloadUrl(String fileId) {
    return '$baseUrl/api/files/$fileId';
  }

  /// Get all files accessible to a user (sent or received)
  Future<UserFilesResult> getUserFiles(String username, {int limit = 100}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/files/user/$username?limit=$limit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get user files failed', response.statusCode, response.body);
    }

    return UserFilesResult.fromJson(jsonDecode(response.body));
  }

  /// Get files in a specific conversation (room)
  Future<RoomFilesResult> getRoomFiles(String roomId, {String? username, int limit = 100}) async {
    var uri = Uri.parse('$baseUrl/api/files/room/$roomId');
    final queryParams = <String, String>{'limit': limit.toString()};
    if (username != null) queryParams['username'] = username;
    uri = uri.replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get room files failed', response.statusCode, response.body);
    }

    return RoomFilesResult.fromJson(jsonDecode(response.body));
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }

  // ==================== STANDALONE CHAT ENDPOINTS ====================

  /// Get all chat rooms for a user
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/standalonechat/rooms/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get chat rooms failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ChatRoom.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Create or get a direct message room
  Future<ChatRoom> createDirectMessage(String userId1, String userId2) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/standalonechat/dm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId1': userId1,
        'userId2': userId2,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Create DM failed', response.statusCode, response.body);
    }

    return ChatRoom.fromJson(jsonDecode(response.body));
  }

  /// Create a group chat
  Future<ChatRoom> createGroup({
    required String creatorUserId,
    required String groupName,
    required List<String> memberUserIds,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/standalonechat/group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'creatorUserId': creatorUserId,
        'groupName': groupName,
        'memberUserIds': memberUserIds,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Create group failed', response.statusCode, response.body);
    }

    return ChatRoom.fromJson(jsonDecode(response.body));
  }

  /// Get message history for a room
  Future<List<ChatMessageModel>> getRoomMessages(String roomId, {int limit = 50}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/standalonechat/room/$roomId/messages?limit=$limit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get room messages failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ==================== VIDEO CALLS ENDPOINTS ====================

  /// Start or join a video call (creates user if needed)
  Future<VideoCallResponse> startVideoCall({
    required String channelName,
    required String username,
    String? displayName,
    String? callType,
    String? deviceType,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/videocalls/start-by-username'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'username': username,
        'displayName': displayName ?? username,
        'callType': callType ?? 'video',
        'deviceType': deviceType ?? _getDeviceType(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Start video call failed', response.statusCode, response.body);
    }

    return VideoCallResponse.fromJson(jsonDecode(response.body));
  }

  /// Leave a video call
  Future<LeaveCallResponse> leaveVideoCall({
    required String channelName,
    required String username,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/videocalls/leave-by-username'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'username': username,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Leave video call failed', response.statusCode, response.body);
    }

    return LeaveCallResponse.fromJson(jsonDecode(response.body));
  }

  /// Get active call for a channel
  Future<VideoCallResponse?> getActiveCall(String channelName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/videocalls/channel/$channelName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get active call failed', response.statusCode, response.body);
    }

    return VideoCallResponse.fromJson(jsonDecode(response.body));
  }

  /// Get call history for a user
  Future<List<VideoCallResponse>> getCallHistory(int userId, {int limit = 50}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/videocalls/user/$userId/history?limit=$limit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get call history failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => VideoCallResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// End a call (usually called by host)
  Future<VideoCallResponse> endVideoCall(String channelName) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/videocalls/end-by-channel/$channelName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('End video call failed', response.statusCode, response.body);
    }

    return VideoCallResponse.fromJson(jsonDecode(response.body));
  }

  /// Join an existing video call (for participants/students - does NOT create a new call)
  /// Throws NoActiveCallException if no call exists on this channel
  Future<VideoCallResponse> joinVideoCall({
    required String channelName,
    required String username,
    String? displayName,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/videocalls/join-by-username'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'channelName': channelName,
        'username': username,
        'displayName': displayName ?? username,
        'deviceType': _getDeviceType(),
      }),
    );

    if (response.statusCode == 404) {
      final body = jsonDecode(response.body);
      throw NoActiveCallException(
        channelName,
        body['message'] as String? ?? 'No active call on this channel.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Join video call failed', response.statusCode, response.body);
    }

    return VideoCallResponse.fromJson(jsonDecode(response.body));
  }

  /// Check if an active call exists on a channel
  Future<ActiveCallCheck> checkActiveCall(String channelName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/videocalls/check/$channelName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Check active call failed', response.statusCode, response.body);
    }

    return ActiveCallCheck.fromJson(jsonDecode(response.body));
  }

  // ==================== PROFESSOR ROOM ENDPOINTS ====================

  /// Get all professor rooms
  Future<List<ProfessorRoom>> getProfessorRooms() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/professorrooms'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get professor rooms failed', response.statusCode, response.body);
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => ProfessorRoom.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get professor room by ID
  Future<ProfessorRoom?> getProfessorRoomById(int id) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/professorrooms/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get professor room failed', response.statusCode, response.body);
    }

    return ProfessorRoom.fromJson(jsonDecode(response.body));
  }

  /// Get professor room by professor ID
  Future<ProfessorRoom?> getProfessorRoomByProfessorId(int professorId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/professorrooms/professor/$professorId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get professor room by professor ID failed', response.statusCode, response.body);
    }

    return ProfessorRoom.fromJson(jsonDecode(response.body));
  }

  /// Get professor room by username
  Future<ProfessorRoom?> getProfessorRoomByUsername(String username) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/professorrooms/by-username/$username'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get professor room by username failed', response.statusCode, response.body);
    }

    return ProfessorRoom.fromJson(jsonDecode(response.body));
  }

  /// Get professor room by room name (channel name)
  Future<ProfessorRoom?> getProfessorRoomByRoomName(String roomName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/professorrooms/by-name/$roomName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Get professor room by room name failed', response.statusCode, response.body);
    }

    return ProfessorRoom.fromJson(jsonDecode(response.body));
  }

  /// Check if a room name is available
  Future<RoomNameAvailability> checkRoomNameAvailable(String roomName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/professorrooms/check-name/$roomName'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Check room name availability failed', response.statusCode, response.body);
    }

    return RoomNameAvailability.fromJson(jsonDecode(response.body));
  }

  /// Update professor room name
  Future<ProfessorRoom> updateProfessorRoomName({
    required int professorId,
    required String newRoomName,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/professorrooms/professor/$professorId/room-name'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newRoomName': newRoomName}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Update professor room name failed', response.statusCode, response.body);
    }

    return ProfessorRoom.fromJson(jsonDecode(response.body));
  }

  /// Update professor room (full update)
  Future<ProfessorRoom> updateProfessorRoom({
    required int id,
    String? roomName,
    String? description,
    bool? isActive,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/professorrooms/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'roomName': ?roomName,
        'description': ?description,
        'isActive': ?isActive,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Update professor room failed', response.statusCode, response.body);
    }

    return ProfessorRoom.fromJson(jsonDecode(response.body));
  }

  String _getDeviceType() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) return 'desktop';
    return 'unknown';
  }

}

// ==================== MODELS ====================
class TokenResponse {
  TokenResponse({
    required this.token,
    this.channelName,
    this.uid,
    required this.tokenType,
  });

  final String token;
  final String? channelName;
  final String? uid;
  final String tokenType;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'] as String,
      channelName: json['channelName'] as String?,
      uid: json['uid'] as String?,
      tokenType: json['tokenType'] as String,
    );
  }

  @override
  String toString() => 'TokenResponse(type: $tokenType, channel: $channelName, uid: $uid, token: ${token.substring(0, 20)}...)';
}

class SessionResponse {
  SessionResponse({
    required this.channelName,
    this.hostUserId,
    this.token,
    this.createdAt,
    required this.users,
    this.message,
  });

  final String channelName;
  final String? hostUserId;
  final String? token;
  final DateTime? createdAt;
  final List<SessionUser> users;
  final String? message;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      channelName: json['channelName'] as String,
      hostUserId: json['hostUserId'] as String?,
      token: json['token'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => SessionUser.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      message: json['message'] as String?,
    );
  }

  @override
  String toString() => 'SessionResponse(channel: $channelName, host: $hostUserId, users: ${users.length}, message: $message)';
}

class WhiteboardTokenResponse {
  WhiteboardTokenResponse({
    required this.uuid,
    required this.token,
    required this.channelName,
  });

  final String uuid;
  final String token;
  final String channelName;

  factory WhiteboardTokenResponse.fromJson(Map<String, dynamic> json) {
    return WhiteboardTokenResponse(
      uuid: json['uuid'] as String,
      token: json['token'] as String,
      channelName: json['channelName'] as String,
    );
  }

  @override
  String toString() => 'WhiteboardTokenResponse(channel: $channelName, uuid: $uuid)';
}

/// Represents a user object returned by session endpoints
class SessionUser {
  SessionUser({
    required this.userId,
    this.displayName,
    required this.isAudioMuted,
    required this.isVideoMuted,
    this.joinedAt,
  });

  final String userId;
  final String? displayName;
  final bool isAudioMuted;
  final bool isVideoMuted;
  final DateTime? joinedAt;

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    return SessionUser(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String?,
      isAudioMuted: json['isAudioMuted'] as bool? ?? false,
      isVideoMuted: json['isVideoMuted'] as bool? ?? false,
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt'] as String) : null,
    );
  }
}

// ==================== EXCEPTIONS ====================

class ApiException implements Exception {
  ApiException(this.message, this.statusCode, this.body);

  final String message;
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException: $message (status: $statusCode)\n$body';
}

class SessionNotFoundException implements Exception {
  SessionNotFoundException(this.channelName);

  final String channelName;

  @override
  String toString() => 'Session "$channelName" not found';
}

/// Exception thrown when trying to join a call that doesn't exist
class NoActiveCallException implements Exception {
  NoActiveCallException(this.channelName, this.message);

  final String channelName;
  final String message;

  @override
  String toString() => message;
}

/// Result of checking if an active call exists
class ActiveCallCheck {
  ActiveCallCheck({
    required this.hasActiveCall,
    required this.channelName,
    this.call,
  });

  final bool hasActiveCall;
  final String channelName;
  final VideoCallResponse? call;

  factory ActiveCallCheck.fromJson(Map<String, dynamic> json) {
    return ActiveCallCheck(
      hasActiveCall: json['hasActiveCall'] as bool,
      channelName: json['channelName'] as String,
      call: json['call'] != null 
          ? VideoCallResponse.fromJson(json['call'] as Map<String, dynamic>) 
          : null,
    );
  }
}

/// Represents a user contact
class Contact {
  Contact({
    required this.contactUserId,
    required this.displayName,
    this.nickname,
    this.addedAt,
    this.isBlocked = false,
    this.isPending = false,
  });

  final String contactUserId;
  final String displayName;
  final String? nickname;
  final DateTime? addedAt;
  final bool isBlocked;
  final bool isPending;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactUserId: json['contactUserId'] as String,
      displayName: json['displayName'] as String,
      nickname: json['nickname'] as String?,
      addedAt: json['addedAt'] != null ? DateTime.parse(json['addedAt'] as String) : null,
      isBlocked: json['isBlocked'] as bool? ?? false,
      isPending: json['isPending'] as bool? ?? false,
    );
  }
}

/// Represents a standalone chat room (DM or group)
class ChatRoom {
  ChatRoom({
    required this.roomId,
    required this.channelName,
    required this.roomType,
    this.groupName,
    this.groupDescription,
    required this.creatorUserId,
    required this.memberUserIds,
    this.memberNames,
    required this.createdAt,
    required this.isActive,
    this.lastMessageAt,
  });

  final String roomId;
  final String channelName;
  final String roomType;
  final String? groupName;
  final String? groupDescription;
  final String creatorUserId;
  final List<String> memberUserIds;
  /// Map of user IDs to display names
  final Map<String, String>? memberNames;
  final DateTime createdAt;
  final bool isActive;
  final DateTime? lastMessageAt;

  bool get isDirectMessage => roomType == 'DirectMessage' || roomType == 'direct';
  bool get isGroup => roomType == 'Group' || roomType == 'group';

  /// Get the display name for a user ID
  String getDisplayName(String userId) {
    return memberNames?[userId] ?? userId;
  }

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] as String,
      channelName: json['channelName'] as String,
      roomType: json['roomType'] as String,
      groupName: json['groupName'] as String?,
      groupDescription: json['groupDescription'] as String?,
      creatorUserId: json['creatorUserId'] as String,
      memberUserIds: (json['memberUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      memberNames: (json['memberNames'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      lastMessageAt: json['lastMessageAt'] != null 
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
    );
  }
}

/// Represents a chat message from the API
class ChatMessageModel {
  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    this.attachment,
  });

  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String type;
  final FileAttachment? attachment;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      attachment: json['attachment'] != null 
          ? FileAttachment.fromJson(json['attachment'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Represents a contact request
class ContactRequest {
  ContactRequest({
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.fromDisplayName,
    required this.status,
    required this.sentAt,
    this.message,
    this.respondedAt,
  });

  final String requestId;
  final String fromUserId;
  final String toUserId;
  final String fromDisplayName;
  final String status;
  final DateTime sentAt;
  final String? message;
  final DateTime? respondedAt;

  bool get isPending => status.toLowerCase() == 'pending';

  factory ContactRequest.fromJson(Map<String, dynamic> json) {
    return ContactRequest(
      requestId: json['requestId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      fromDisplayName: json['fromDisplayName'] as String,
      status: json['status'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      message: json['message'] as String?,
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }
}

/// Represents message permission check result
class MessagePermission {
  MessagePermission({
    required this.canMessage,
    this.reason,
  });

  final bool canMessage;
  final String? reason;

  factory MessagePermission.fromJson(Map<String, dynamic> json) {
    return MessagePermission(
      canMessage: json['canMessage'] as bool,
      reason: json['reason'] as String?,
    );
  }
}

/// Represents a file upload result
class FileUploadResult {
  FileUploadResult({
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

  factory FileUploadResult.fromJson(Map<String, dynamic> json) {
    return FileUploadResult(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      contentType: json['contentType'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

/// Represents a file attachment in a message
class FileAttachment {
  FileAttachment({
    required this.fileId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.downloadUrl,
    this.thumbnailUrl,
  });

  final String fileId;
  final String fileName;
  final String contentType;
  final int fileSize;
  final String downloadUrl;
  final String? thumbnailUrl;

  bool get isImage => contentType.startsWith('image/');
  bool get isVideo => contentType.startsWith('video/');
  bool get isAudio => contentType.startsWith('audio/');

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      fileSize: json['fileSize'] as int,
      downloadUrl: json['downloadUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}

// ==================== PROFESSOR ROOM MODELS ====================

/// Represents a professor's video call room
class ProfessorRoom {
  ProfessorRoom({
    required this.id,
    required this.professorId,
    required this.professorName,
    required this.roomName,
    this.description,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int professorId;
  final String professorName;
  final String roomName;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Creates a copy of this ProfessorRoom with modified fields
  ProfessorRoom copyWith({
    int? id,
    int? professorId,
    String? professorName,
    String? roomName,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfessorRoom(
      id: id ?? this.id,
      professorId: professorId ?? this.professorId,
      professorName: professorName ?? this.professorName,
      roomName: roomName ?? this.roomName,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProfessorRoom.fromJson(Map<String, dynamic> json) {
    return ProfessorRoom(
      id: json['id'] as int,
      professorId: json['professorId'] as int,
      professorName: json['professorName'] as String,
      roomName: json['roomName'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  String toString() => 'ProfessorRoom(id: $id, professorName: $professorName, roomName: $roomName)';
}

/// Response when checking if a room name is available
class RoomNameAvailability {
  RoomNameAvailability({
    required this.roomName,
    required this.isAvailable,
  });

  final String roomName;
  final bool isAvailable;

  factory RoomNameAvailability.fromJson(Map<String, dynamic> json) {
    return RoomNameAvailability(
      roomName: json['roomName'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}

// ==================== VIDEO CALL MODELS ====================

/// Represents a video call response
class VideoCallResponse {
  VideoCallResponse({
    required this.id,
    required this.channelName,
    this.callName,
    required this.callType,
    this.groupRoomId,
    this.initiatedByUserId,
    this.initiatedByName,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.maxParticipants,
    this.isRecorded,
    this.currentParticipants,
  });

  final int id;
  final String channelName;
  final String? callName;
  final String callType;
  final int? groupRoomId;
  final int? initiatedByUserId;
  final String? initiatedByName;
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final int? maxParticipants;
  final bool? isRecorded;
  final List<CallParticipant>? currentParticipants;

  bool get isActive => status.toLowerCase() == 'active';
  bool get isEnded => status.toLowerCase() == 'ended';

  factory VideoCallResponse.fromJson(Map<String, dynamic> json) {
    return VideoCallResponse(
      id: json['id'] as int,
      channelName: json['channelName'] as String,
      callName: json['callName'] as String?,
      callType: json['callType'] as String,
      groupRoomId: json['groupRoomId'] as int?,
      initiatedByUserId: json['initiatedByUserId'] as int?,
      initiatedByName: json['initiatedByName'] as String?,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      durationSeconds: json['durationSeconds'] as int?,
      maxParticipants: json['maxParticipants'] as int?,
      isRecorded: json['isRecorded'] as bool?,
      currentParticipants: (json['currentParticipants'] as List<dynamic>?)
          ?.map((e) => CallParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a participant in a video call
class CallParticipant {
  CallParticipant({
    required this.id,
    required this.userId,
    this.userName,
    required this.role,
    required this.joinedAt,
    this.deviceType,
  });

  final int id;
  final int userId;
  final String? userName;
  final String role;
  final DateTime joinedAt;
  final String? deviceType;

  bool get isHost => role.toLowerCase() == 'host';

  factory CallParticipant.fromJson(Map<String, dynamic> json) {
    return CallParticipant(
      id: json['id'] as int,
      userId: json['userId'] as int,
      userName: json['userName'] as String?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      deviceType: json['deviceType'] as String?,
    );
  }
}

/// Represents a leave call response with participant duration info
class LeaveCallResponse {
  LeaveCallResponse({
    required this.participant,
    required this.call,
  });

  final ParticipantLeaveInfo participant;
  final VideoCallResponse call;

  factory LeaveCallResponse.fromJson(Map<String, dynamic> json) {
    return LeaveCallResponse(
      participant: ParticipantLeaveInfo.fromJson(json['participant'] as Map<String, dynamic>),
      call: VideoCallResponse.fromJson(json['call'] as Map<String, dynamic>),
    );
  }
}

/// Participant info when leaving a call
class ParticipantLeaveInfo {
  ParticipantLeaveInfo({
    required this.id,
    required this.userId,
    this.username,
    required this.joinedAt,
    required this.leftAt,
    this.durationSeconds,
  });

  final int id;
  final int userId;
  final String? username;
  final DateTime joinedAt;
  final DateTime leftAt;
  final int? durationSeconds;

  factory ParticipantLeaveInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantLeaveInfo(
      id: json['id'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      leftAt: DateTime.parse(json['leftAt'] as String),
      durationSeconds: json['durationSeconds'] as int?,
    );
  }
}

/// Result of getting files for a user
class UserFilesResult {
  UserFilesResult({
    required this.username,
    required this.totalFiles,
    required this.files,
  });

  final String username;
  final int totalFiles;
  final List<UserFileInfo> files;

  factory UserFilesResult.fromJson(Map<String, dynamic> json) {
    return UserFilesResult(
      username: json['username'] as String,
      totalFiles: json['totalFiles'] as int,
      files: (json['files'] as List<dynamic>)
          .map((e) => UserFileInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Result of getting files for a room
class RoomFilesResult {
  RoomFilesResult({
    required this.roomId,
    required this.totalFiles,
    required this.files,
  });

  final String roomId;
  final int totalFiles;
  final List<UserFileInfo> files;

  factory RoomFilesResult.fromJson(Map<String, dynamic> json) {
    return RoomFilesResult(
      roomId: json['roomId'] as String,
      totalFiles: json['totalFiles'] as int,
      files: (json['files'] as List<dynamic>)
          .map((e) => UserFileInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Info about a file accessible to a user
class UserFileInfo {
  UserFileInfo({
    required this.fileId,
    required this.fileName,
    required this.contentType,
    required this.fileSizeBytes,
    this.roomId,
    required this.uploadedBy,
    required this.uploadedByDisplayName,
    required this.downloadUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.isOwnFile,
  });

  final String fileId;
  final String fileName;
  final String contentType;
  final int fileSizeBytes;
  final String? roomId;
  final String uploadedBy;
  final String uploadedByDisplayName;
  final String downloadUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final bool isOwnFile;

  bool get isImage => contentType.startsWith('image/');
  bool get isVideo => contentType.startsWith('video/');
  bool get isAudio => contentType.startsWith('audio/');

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory UserFileInfo.fromJson(Map<String, dynamic> json) {
    return UserFileInfo(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      contentType: json['contentType'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      roomId: json['roomId'] as String?,
      uploadedBy: json['uploadedBy'] as String,
      uploadedByDisplayName: json['uploadedByDisplayName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isOwnFile: json['isOwnFile'] as bool,
    );
  }
}
