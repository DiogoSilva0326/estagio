import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Represents an incoming direct message notification.
class DirectMessageNotification {
  final String channelName;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  DirectMessageNotification({
    required this.channelName,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });
}

/// Represents a professor room status change notification.
class ProfessorRoomStatusNotification {
  final String roomName;
  final String professorUsername;
  final bool isOnline;
  final int participantCount;
  final DateTime timestamp;

  ProfessorRoomStatusNotification({
    required this.roomName,
    required this.professorUsername,
    required this.isOnline,
    required this.participantCount,
    required this.timestamp,
  });
}

/// Global service for receiving real-time notifications via SignalR.
/// This service should be initialized once when the user logs in.
class NotificationService extends ChangeNotifier {
  static NotificationService? _instance;
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  NotificationService._();

  HubConnection? _hubConnection;
  String _userId = '';
  bool _isConnected = false;
  bool _disposed = false;
  bool _subscribedToProfessorRooms = false;
  
  // Unread message counts per channel
  final Map<String, int> _unreadCounts = {};
  
  // Professor room online status (roomName -> isOnline)
  final Map<String, bool> _professorRoomStatus = {};
  
  // Stream of new DM notifications
  final StreamController<DirectMessageNotification> _dmNotificationsController = 
      StreamController<DirectMessageNotification>.broadcast();
  
  // Stream of professor room status changes
  final StreamController<ProfessorRoomStatusNotification> _professorRoomStatusController = 
      StreamController<ProfessorRoomStatusNotification>.broadcast();
  
  Stream<DirectMessageNotification> get dmNotifications => _dmNotificationsController.stream;
  Stream<ProfessorRoomStatusNotification> get professorRoomStatusUpdates => _professorRoomStatusController.stream;
  
  bool get isConnected => _isConnected;
  String get userId => _userId;
  Map<String, int> get unreadCounts => Map.unmodifiable(_unreadCounts);
  Map<String, bool> get professorRoomStatus => Map.unmodifiable(_professorRoomStatus);
  
  int get totalUnreadCount => _unreadCounts.values.fold(0, (a, b) => a + b);
  
  /// Check if a professor room is online
  bool isProfessorRoomOnline(String roomName) => _professorRoomStatus[roomName] ?? false;

  String get _hubUrl {
    // Use WEBSOCKET_URL if defined, otherwise fall back to API_BASE_URL
    final websocketUrl = dotenv.env['WEBSOCKET_URL'];
    final baseUrl = (websocketUrl != null && websocketUrl.isNotEmpty) 
        ? websocketUrl 
        : (dotenv.env['API_BASE_URL'] ?? 'http://localhost:5050');
    final cleanBase = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    debugPrint('NotificationService: Using WebSocket URL: $cleanBase/chathub');
    return '$cleanBase/chathub';
  }

  /// Initialize and connect the notification service for a user.
  Future<bool> connect(String userId) async {
    if (_isConnected && _userId == userId) return true;
    
    await disconnect();
    
    _userId = userId;
    
    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(_hubUrl)
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _hubConnection!.on('DirectMessageReceived', _onDirectMessageReceived);
      _hubConnection!.on('ContactRequestReceived', _onContactRequestReceived);
      _hubConnection!.on('ContactRequestWasAccepted', _onContactRequestWasAccepted);
      _hubConnection!.on('ContactRequestWasCancelled', _onContactRequestWasCancelled);
      _hubConnection!.on('ProfessorRoomStatusChanged', _onProfessorRoomStatusUpdated);

      _hubConnection!.onclose(({Exception? error}) {
        _isConnected = false;
        notifyListeners();
      });

      _hubConnection!.onreconnecting(({Exception? error}) {
        _isConnected = false;
        notifyListeners();
      });

      _hubConnection!.onreconnected(({String? connectionId}) {
        _isConnected = true;
        // Rejoin user notification group
        _hubConnection!.invoke('JoinUserNotifications', args: [_userId]);
        notifyListeners();
      });

      await _hubConnection!.start();
      
      // Join the user's notification group
      await _hubConnection!.invoke('JoinUserNotifications', args: [userId]);
      
      // Subscribe to professor room status updates
      await subscribeToProfessorRoomUpdates();

      _isConnected = true;
      debugPrint('NotificationService: Connected for user $userId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('NotificationService connect error: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Disconnect the notification service.
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
      } catch (_) {}
      _hubConnection = null;
    }

    _isConnected = false;
    _userId = '';
    _unreadCounts.clear();
    _professorRoomStatus.clear();
    _subscribedToProfessorRooms = false;
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Mark messages in a channel as read.
  void markAsRead(String channelName) {
    if (_unreadCounts.containsKey(channelName)) {
      _unreadCounts.remove(channelName);
      notifyListeners();
    }
  }

  /// Clear all unread counts.
  void clearAllUnread() {
    _unreadCounts.clear();
    notifyListeners();
  }

  // ==================== Event Handlers ====================

  void _onDirectMessageReceived(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    
    final data = args[0] as Map<String, dynamic>?;
    if (data == null) return;

    final channelName = data['channelName'] as String? ?? '';
    final messageData = data['message'] as Map<String, dynamic>?;
    
    if (messageData == null) return;

    final senderId = messageData['senderId'] as String? ?? '';
    final senderName = messageData['senderName'] as String? ?? '';
    final content = messageData['content'] as String? ?? '';
    final timestampStr = messageData['timestamp'] as String?;
    final timestamp = timestampStr != null 
        ? DateTime.tryParse(timestampStr) ?? DateTime.now()
        : DateTime.now();

    // Increment unread count for this channel
    _unreadCounts[channelName] = (_unreadCounts[channelName] ?? 0) + 1;
    
    // Emit notification
    _dmNotificationsController.add(DirectMessageNotification(
      channelName: channelName,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp,
    ));

    debugPrint('NotificationService: New DM from $senderName in $channelName');
    notifyListeners();
  }

  void _onContactRequestReceived(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    debugPrint('NotificationService: Contact request received');
    notifyListeners();
  }

  void _onContactRequestWasAccepted(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    debugPrint('NotificationService: Contact request was accepted');
    notifyListeners();
  }

  void _onContactRequestWasCancelled(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    debugPrint('NotificationService: Contact request was cancelled');
    notifyListeners();
  }

  void _onProfessorRoomStatusUpdated(List<Object?>? args) {
    debugPrint('NotificationService: Received ProfessorRoomStatusChanged event');
    debugPrint('NotificationService: Raw args: $args');
    
    if (args == null || args.isEmpty) {
      debugPrint('NotificationService: args is null or empty');
      return;
    }
    
    // SignalR may send the data in different formats
    Map<String, dynamic>? data;
    try {
      if (args[0] is Map<String, dynamic>) {
        data = args[0] as Map<String, dynamic>;
      } else if (args[0] is Map) {
        data = Map<String, dynamic>.from(args[0] as Map);
      } else {
        debugPrint('NotificationService: Unexpected data type: ${args[0].runtimeType}');
        return;
      }
    } catch (e) {
      debugPrint('NotificationService: Error parsing data: $e');
      return;
    }

    final roomName = data['roomName'] as String? ?? '';
    final professorUsername = data['professorUsername'] as String? ?? '';
    final isOnline = data['isOnline'] as bool? ?? false;
    final participantCount = data['participantCount'] as int? ?? 0;
    final timestampStr = data['timestamp'] as String?;
    final timestamp = timestampStr != null 
        ? DateTime.tryParse(timestampStr) ?? DateTime.now()
        : DateTime.now();

    // Update local status cache
    _professorRoomStatus[roomName] = isOnline;
    
    // Emit notification
    _professorRoomStatusController.add(ProfessorRoomStatusNotification(
      roomName: roomName,
      professorUsername: professorUsername,
      isOnline: isOnline,
      participantCount: participantCount,
      timestamp: timestamp,
    ));

    debugPrint('NotificationService: Professor room $roomName is now ${isOnline ? "ONLINE" : "OFFLINE"}');
    notifyListeners();
  }

  /// Subscribe to professor room status updates.
  Future<void> subscribeToProfessorRoomUpdates() async {
    debugPrint('NotificationService: Attempting to subscribe to professor room updates...');
    debugPrint('NotificationService: Hub state: ${_hubConnection?.state}');
    
    if (_hubConnection?.state != HubConnectionState.Connected) {
      debugPrint('NotificationService: Cannot subscribe - hub not connected (state: ${_hubConnection?.state})');
      return;
    }
    
    if (_subscribedToProfessorRooms) {
      debugPrint('NotificationService: Already subscribed to professor room updates');
      return;
    }
    
    try {
      debugPrint('NotificationService: Invoking SubscribeToProfessorRoomUpdates...');
      await _hubConnection!.invoke('SubscribeToProfessorRoomUpdates', args: []);
      _subscribedToProfessorRooms = true;
      debugPrint('NotificationService: ✅ Successfully subscribed to professor room updates');
    } catch (e) {
      debugPrint('NotificationService: ❌ Error subscribing to professor rooms: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    _dmNotificationsController.close();
    _professorRoomStatusController.close();
    super.dispose();
  }
}
