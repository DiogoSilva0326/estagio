import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/video_call_helper.dart';
import 'conversations_page.dart';
import 'files_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final AuthService? authService;
  
  const HomePage({super.key, this.authService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  // Controllers
  final _channelController = TextEditingController(text: 'test-channel');
  final _uidController = TextEditingController(text: '12345');
  late TextEditingController _userIdController;
  late TextEditingController _userNameController;
  final _roomNameController = TextEditingController();
  
  // State
  String _logs = '';
  bool _isLoading = false;
  List<SessionResponse> _sessions = [];
  
  // Professor Rooms State
  ProfessorRoom? _myProfessorRoom;
  List<ProfessorRoom> _allProfessorRooms = [];
  bool _isLoadingProfessorRooms = false;
  
  // Active calls state (room name -> is active)
  Map<String, bool> _activeCallsStatus = {};
  
  // Subscription for professor room status updates
  StreamSubscription<ProfessorRoomStatusNotification>? _professorRoomStatusSubscription;

  AuthUser? get _currentUser => widget.authService?.currentUser;
  bool get _isAuthenticated => widget.authService?.isAuthenticated ?? false;
  bool get _canStartVideoCall => _currentUser?.canStartVideoCall ?? false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Initialize controllers with authenticated user data if available
    _userIdController = TextEditingController(
      text: _currentUser?.username ?? 'user1',
    );
    _userNameController = TextEditingController(
      text: _currentUser?.effectiveDisplayName ?? 'Guest',
    );
    
    _log('App initialized. API URL: ${_apiService.baseUrl}');
    if (_isAuthenticated) {
      _log('Logged in as: ${_currentUser?.username} (${_currentUser?.role})');
      _loadProfessorRooms();
      _connectNotificationService();
    }
  }

  /// Connect to notification service for real-time DM/file notifications
  Future<void> _connectNotificationService() async {
    if (_currentUser == null) return;
    
    final success = await NotificationService.instance.connect(_currentUser!.username);
    if (success) {
      _log('🔔 Connected to notification service');
      
      // Subscribe to professor room status updates (for students)
      if (_currentUser?.isStudent == true) {
        _professorRoomStatusSubscription?.cancel();
        _professorRoomStatusSubscription = NotificationService.instance.professorRoomStatusUpdates.listen((notification) {
          _log('🔔 Professor room ${notification.roomName} is now ${notification.isOnline ? "ONLINE 🟢" : "OFFLINE 🔴"}');
          
          setState(() {
            _activeCallsStatus[notification.roomName] = notification.isOnline;
          });
        });
        _log('🔔 Subscribed to professor room status updates');
      }
    } else {
      _log('⚠️ Failed to connect to notification service');
    }
  }

  /// Load professor room data based on user role
  Future<void> _loadProfessorRooms() async {
    if (!_isAuthenticated) return;
    
    setState(() => _isLoadingProfessorRooms = true);
    
    try {
      // If user is a professor, load their own room
      if (_currentUser?.isProfessor == true || _currentUser?.role == 'admin') {
        final room = await _apiService.getProfessorRoomByUsername(_currentUser!.username);
        if (room != null) {
          setState(() {
            _myProfessorRoom = room;
            _channelController.text = room.roomName;
            _roomNameController.text = room.roomName;
          });
          _log('📚 Loaded my professor room: ${room.roomName}');
        }
      }
      
      // If user is a student, load all professor rooms and check active calls
      if (_currentUser?.isStudent == true) {
        final rooms = await _apiService.getProfessorRooms();
        setState(() => _allProfessorRooms = rooms);
        _log('📚 Loaded ${rooms.length} professor rooms');
        
        // Check active call status for each room
        await _checkActiveCallsStatus();
      }
    } catch (e) {
      _log('❌ Error loading professor rooms: $e');
    } finally {
      setState(() => _isLoadingProfessorRooms = false);
    }
  }

  /// Check active call status for all professor rooms (for students)
  Future<void> _checkActiveCallsStatus() async {
    final Map<String, bool> statusMap = {};
    
    for (final room in _allProfessorRooms) {
      try {
        final result = await _apiService.checkActiveCall(room.roomName);
        statusMap[room.roomName] = result.hasActiveCall;
      } catch (e) {
        statusMap[room.roomName] = false;
        _log('⚠️ Could not check call status for ${room.roomName}');
      }
    }
    
    setState(() => _activeCallsStatus = statusMap);
    
    final activeCount = statusMap.values.where((v) => v).length;
    if (activeCount > 0) {
      _log('🟢 $activeCount professor room(s) with active calls');
    }
  }

  @override
  void dispose() {
    _professorRoomStatusSubscription?.cancel();
    _tabController.dispose();
    _channelController.dispose();
    _uidController.dispose();
    _userIdController.dispose();
    _userNameController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs = '[$timestamp] $message\n$_logs';
    });
  }

  void _clearLogs() {
    setState(() {
      _logs = '';
    });
  }

  Future<void> _runAsync(String operation, Future<void> Function() action) async {
    setState(() => _isLoading = true);
    _log('Starting: $operation...');
    try {
      await action();
      _log('✅ $operation completed successfully');
    } catch (e) {
      _log('❌ $operation failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    // Disconnect from notification service
    await NotificationService.instance.disconnect();
    
    await widget.authService?.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginPage(authService: widget.authService!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Integrator Test'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.videocam), text: 'Video Call'),
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.folder), text: 'Ficheiros'),
            Tab(icon: Icon(Icons.token), text: 'Tokens'),
            Tab(icon: Icon(Icons.groups), text: 'Sessions'),
            Tab(icon: Icon(Icons.list), text: 'All Sessions'),
          ],
        ),
        actions: [
          if (_isAuthenticated) ...[
            // User info chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: Icon(
                  _getRoleIcon(_currentUser?.role ?? 'aluno'),
                  size: 18,
                ),
                label: Text(
                  _currentUser?.effectiveDisplayName ?? 'User',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: _getRoleColor(_currentUser?.role ?? 'aluno').withOpacity(0.2),
              ),
            ),
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // User info banner
          if (_isAuthenticated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: _getRoleColor(_currentUser?.role ?? 'aluno').withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getRoleIcon(_currentUser?.role ?? 'aluno'),
                    size: 16,
                    color: _getRoleColor(_currentUser?.role ?? 'aluno'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getRoleLabel(_currentUser?.role ?? 'aluno'),
                    style: TextStyle(
                      color: _getRoleColor(_currentUser?.role ?? 'aluno'),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_canStartVideoCall) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text(
                      'Can start video calls',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            flex: 2,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideoCallTab(),
                _buildChatTab(),
                _buildFilesTab(),
                _buildTokenTab(),
                _buildSessionTab(),
                _buildAllSessionsTab(),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildLogsPanel(),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'professor':
        return Icons.cast_for_education;
      case 'aluno':
      default:
        return Icons.school;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'professor':
        return Colors.orange;
      case 'aluno':
      default:
        return Colors.blue;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'professor':
        return 'Professor';
      case 'aluno':
      default:
        return 'Student';
    }
  }

  // ==================== VIDEO CALL TAB ====================
  Widget _buildVideoCallTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Video Call', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Vídeo chamada com áudio, screen share e whiteboard',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Professor view - only their own room
          if (_canStartVideoCall && _currentUser?.isProfessor == true) ...[
            if (_myProfessorRoom != null)
              _buildMyProfessorRoomSection()
            else if (_isLoadingProfessorRooms)
              const Center(child: CircularProgressIndicator())
            else
              _buildNoProfessorRoomMessage(),
          ],
          
          // Admin view - can use any channel
          if (_currentUser?.role == 'admin') ...[
            if (_myProfessorRoom != null) ...[
              _buildMyProfessorRoomSection(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Or use a custom channel:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
            ],
            _buildAdminCustomChannelSection(),
          ],
          
          // Student view - only professor rooms with active calls
          if (_isAuthenticated && _currentUser?.isStudent == true) ...[
            _buildProfessorRoomsListSection(),
          ],
          
          // Not authenticated view
          if (!_isAuthenticated) ...[
            _buildGuestVideoCallSection(),
          ],
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Funcionalidades:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.videocam, 'Vídeo em tempo real'),
                  _buildFeatureRow(Icons.mic, 'Áudio'),
                  _buildFeatureRow(Icons.screen_share, 'Screen Share'),
                  _buildFeatureRow(Icons.edit_note, 'Whiteboard colaborativo'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Message shown when professor doesn't have a room yet
  Widget _buildNoProfessorRoomMessage() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 48),
            const SizedBox(height: 12),
            Text(
              'No Room Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your professor room was not found. Please contact an administrator.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadProfessorRooms,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Admin section for custom channel access
  Widget _buildAdminCustomChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _channelController,
          decoration: const InputDecoration(
            labelText: 'Channel Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tag),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _userNameController,
          enabled: !_isAuthenticated,
          decoration: InputDecoration(
            labelText: 'Your Name',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.person),
            helperText: _isAuthenticated ? 'Using your account name' : null,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isLoading ? null : _startVideoCall,
          icon: const Icon(Icons.video_call),
          label: const Text('Start Video Call'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _joinVideoCall,
          icon: const Icon(Icons.login),
          label: const Text('Join Existing Call'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  /// Guest section for video calls (not authenticated)
  Widget _buildGuestVideoCallSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please login to access video call features.',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: _channelController,
          decoration: const InputDecoration(
            labelText: 'Channel Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.tag),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _userNameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isLoading ? null : _joinVideoCall,
          icon: const Icon(Icons.login),
          label: const Text('Join Video Call'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  // ==================== PROFESSOR ROOM WIDGETS ====================
  
  /// Section showing the professor's own room with edit options
  Widget _buildMyProfessorRoomSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.cast_for_education, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'My Professor Room',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showEditRoomNameDialog,
                  tooltip: 'Edit room name',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoadingProfessorRooms ? null : _loadProfessorRooms,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.meeting_room, size: 20),
                      const SizedBox(width: 8),
                      const Text('Room: ', style: TextStyle(fontWeight: FontWeight.w500)),
                      Expanded(
                        child: Text(
                          _myProfessorRoom!.roomName,
                          style: const TextStyle(fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (_myProfessorRoom!.description != null && _myProfessorRoom!.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.description, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_myProfessorRoom!.description!)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _startCallInMyRoom,
              icon: const Icon(Icons.video_call),
              label: const Text('Start Call in My Room'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section showing list of all professor rooms for students
  Widget _buildProfessorRoomsListSection() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Professor Rooms',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoadingProfessorRooms ? null : _loadProfessorRooms,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can only join a room when the professor has started a video call.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingProfessorRooms)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_allProfessorRooms.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No professor rooms available',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._allProfessorRooms.map((room) => _buildProfessorRoomTile(room)),
          ],
        ),
      ),
    );
  }

  /// A tile showing a professor room with join button (only enabled if call is active)
  Widget _buildProfessorRoomTile(ProfessorRoom room) {
    final isCallActive = _activeCallsStatus[room.roomName] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCallActive ? Colors.green.shade300 : Colors.grey.shade300,
          width: isCallActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: isCallActive ? Colors.green.shade100 : Colors.grey.shade100,
              child: Icon(
                Icons.cast_for_education, 
                color: isCallActive ? Colors.green.shade700 : Colors.grey.shade500,
              ),
            ),
            if (isCallActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(room.professorName)),
            if (isCallActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room: ${room.roomName}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            if (room.description != null && room.description!.isNotEmpty)
              Text(
                room.description!,
                style: const TextStyle(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (!isCallActive)
              Text(
                'Waiting for professor to start the call...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: isCallActive
            ? FilledButton(
                onPressed: () => _joinProfessorRoom(room),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Join'),
              )
            : OutlinedButton(
                onPressed: null,
                child: Text(
                  'Offline',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
      ),
    );
  }

  // ==================== PROFESSOR ROOM ACTIONS ====================
  
  /// Start a video call in the professor's own room
  Future<void> _startCallInMyRoom() async {
    if (_myProfessorRoom == null) return;
    
    final userName = _currentUser!.effectiveDisplayName;
    
    _log('🚀 Starting call in my room: ${_myProfessorRoom!.roomName}');
    
    // Opens in new tab on web, navigates in-app on mobile
    await openOrNavigateToVideoCall(
      context,
      channel: _myProfessorRoom!.roomName,
      user: userName,
      token: widget.authService?.token,
      isHost: true,
    );
  }

  /// Join a professor's room (for students)
  Future<void> _joinProfessorRoom(ProfessorRoom room) async {
    final userName = _isAuthenticated 
        ? _currentUser!.effectiveDisplayName 
        : _userNameController.text.trim();
    
    _log('🚀 Joining professor room: ${room.roomName} (${room.professorName})');
    
    // Opens in new tab on web, navigates in-app on mobile
    await openOrNavigateToVideoCall(
      context,
      channel: room.roomName,
      user: userName.isEmpty ? 'Guest' : userName,
      token: widget.authService?.token,
      isHost: false,
    );
  }

  /// Show dialog to edit the professor room name
  void _showEditRoomNameDialog() {
    if (_myProfessorRoom == null) return;
    
    _roomNameController.text = _myProfessorRoom!.roomName;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Room Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change your room name. It must be unique across all professor rooms.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roomNameController,
              decoration: const InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.meeting_room),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _updateRoomName();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Update the professor room name via API
  Future<void> _updateRoomName() async {
    if (_myProfessorRoom == null) return;
    
    final newName = _roomNameController.text.trim();
    if (newName.isEmpty || newName == _myProfessorRoom!.roomName) {
      return;
    }

    await _runAsync('Update room name', () async {
      // Check if name is available
      final availability = await _apiService.checkRoomNameAvailable(newName);
      if (!availability.isAvailable) {
        throw Exception('Room name "$newName" is already taken');
      }
      
      // Update the room name
      final updatedRoom = await _apiService.updateProfessorRoomName(
        professorId: _myProfessorRoom!.professorId,
        newRoomName: newName,
      );
      
      setState(() {
        _myProfessorRoom = updatedRoom;
        _channelController.text = updatedRoom.roomName;
      });
      
      _log('✅ Room name updated to: ${updatedRoom.roomName}');
    });
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _startVideoCall() async {
    final channel = _channelController.text.trim();
    final userName = _isAuthenticated 
        ? _currentUser!.effectiveDisplayName 
        : _userNameController.text.trim();
    
    if (channel.isEmpty) {
      _log('❌ Channel name is required');
      return;
    }

    if (!_canStartVideoCall) {
      _log('❌ Only professors and admins can start video calls');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only professors and admins can start video calls'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _log('🚀 Starting video call - Channel: $channel, User: $userName');
    
    // Opens in new tab on web, navigates in-app on mobile
    await openOrNavigateToVideoCall(
      context,
      channel: channel,
      user: userName.isEmpty ? 'Guest' : userName,
      token: widget.authService?.token,
      isHost: true,
    );
  }

  Future<void> _joinVideoCall() async {
    final channel = _channelController.text.trim();
    final userName = _isAuthenticated 
        ? _currentUser!.effectiveDisplayName 
        : _userNameController.text.trim();
    
    if (channel.isEmpty) {
      _log('❌ Channel name is required');
      return;
    }

    _log('🚀 Joining video call - Channel: $channel, User: $userName');
    
    // Opens in new tab on web, navigates in-app on mobile
    await openOrNavigateToVideoCall(
      context,
      channel: channel,
      user: userName.isEmpty ? 'Guest' : userName,
      token: widget.authService?.token,
      isHost: false,
    );
  }

  // ==================== CHAT TAB ====================
  Widget _buildChatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Chat Standalone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Sistema de chat independente com contactos, mensagens 1-to-1 e grupos',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _userIdController,
            enabled: !_isAuthenticated,
            decoration: InputDecoration(
              labelText: 'User ID',
              hintText: 'Ex: user123',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              helperText: _isAuthenticated ? 'Using your account username' : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _userNameController,
            enabled: !_isAuthenticated,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'Ex: João Silva',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.badge),
              helperText: _isAuthenticated ? 'Using your account name' : null,
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _openChatSystem,
            icon: const Icon(Icons.chat),
            label: const Text('Abrir Chat'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Funcionalidades:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Lista de contactos'),
                  Text('• Chat 1-to-1 (mensagens diretas)'),
                  Text('• Grupos de chat'),
                  Text('• Mensagens em tempo real via WebSockets'),
                  Text('• Histórico de mensagens'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChatSystem() {
    final userId = _isAuthenticated 
        ? _currentUser!.username 
        : _userIdController.text.trim();
    final displayName = _isAuthenticated 
        ? _currentUser!.effectiveDisplayName 
        : _userNameController.text.trim();

    if (userId.isEmpty) {
      _log('❌ User ID é obrigatório');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID é obrigatório')),
      );
      return;
    }

    _log('Opening chat system for user: $userId');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationsPage(
          userId: userId,
          displayName: displayName.isEmpty ? userId : displayName,
        ),
      ),
    );
  }

  // ==================== FILES TAB ====================
  Widget _buildFilesTab() {
    final userId = _isAuthenticated 
        ? _currentUser!.username 
        : _userIdController.text.trim();
    final displayName = _isAuthenticated 
        ? _currentUser!.effectiveDisplayName 
        : _userNameController.text.trim();

    if (userId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Insira um User ID na aba Chat primeiro',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return FilesPage(
      userId: userId,
      displayName: displayName.isEmpty ? userId : displayName,
    );
  }

  // ==================== TOKEN TAB ====================
  Widget _buildTokenTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Token Generation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          TextField(
            controller: _channelController,
            decoration: const InputDecoration(
              labelText: 'Channel Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _uidController,
            decoration: const InputDecoration(
              labelText: 'User ID (for RTC)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _generateRtcToken,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Generate RTC Token'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _isLoading ? null : _generateRtmToken,
                  icon: const Icon(Icons.message),
                  label: const Text('Generate RTM Token'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateRtcToken() async {
    await _runAsync('Generate RTC Token', () async {
      final result = await _apiService.fetchRtcToken(
        channelName: _channelController.text,
        uid: _uidController.text,
      );
      _log('RTC Token: ${result.token.substring(0, 30)}...');
      _log('Channel: ${result.channelName}, UID: ${result.uid}');
    });
  }

  Future<void> _generateRtmToken() async {
    await _runAsync('Generate RTM Token', () async {
      final result = await _apiService.fetchRtmToken(
        userId: _uidController.text,
      );
      _log('RTM Token: ${result.token.substring(0, 30)}...');
      _log('User ID: ${result.uid}');
    });
  }

  // ==================== SESSION TAB ====================
  Widget _buildSessionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Session Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          TextField(
            controller: _channelController,
            decoration: const InputDecoration(
              labelText: 'Channel Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _userIdController,
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _isLoading ? null : _createSession,
                icon: const Icon(Icons.add),
                label: const Text('Create'),
              ),
              FilledButton.tonalIcon(
                onPressed: _isLoading ? null : _joinSession,
                icon: const Icon(Icons.login),
                label: const Text('Join'),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _leaveSession,
                icon: const Icon(Icons.logout),
                label: const Text('Leave'),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _getSession,
                icon: const Icon(Icons.info),
                label: const Text('Get Info'),
              ),
              FilledButton.icon(
                onPressed: _isLoading ? null : _endSession,
                icon: const Icon(Icons.stop),
                label: const Text('End'),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createSession() async {
    await _runAsync('Create Session', () async {
      final result = await _apiService.createSession(
        channelName: _channelController.text,
        hostUserId: _userIdController.text,
      );
      _log('Session created: ${result.channelName}');
      _log('Host: ${result.hostUserId}, Users: ${result.users}');
      if (result.token != null) {
        _log('Token: ${result.token!.substring(0, 30)}...');
      }
    });
  }

  Future<void> _joinSession() async {
    await _runAsync('Join Session', () async {
      final result = await _apiService.joinSession(
        channelName: _channelController.text,
        userId: _userIdController.text,
      );
      _log('Joined session: ${result.channelName}');
      _log('Users in session: ${result.users}');
      if (result.token != null) {
        _log('Token: ${result.token!.substring(0, 30)}...');
      }
    });
  }

  Future<void> _leaveSession() async {
    await _runAsync('Leave Session', () async {
      final result = await _apiService.leaveSession(
        channelName: _channelController.text,
        userId: _userIdController.text,
      );
      _log('Left session: ${result.channelName}');
      if (result.message != null) {
        _log('Message: ${result.message}');
      } else {
        _log('Remaining users: ${result.users}');
      }
    });
  }

  Future<void> _getSession() async {
    await _runAsync('Get Session', () async {
      final result = await _apiService.getSession(_channelController.text);
      if (result == null) {
        _log('Session not found');
      } else {
        _log('Session: ${result.channelName}');
        _log('Host: ${result.hostUserId}');
        _log('Users: ${result.users}');
        _log('Created: ${result.createdAt}');
      }
    });
  }

  Future<void> _endSession() async {
    await _runAsync('End Session', () async {
      await _apiService.endSession(_channelController.text);
      _log('Session ended: ${_channelController.text}');
    });
  }

  // ==================== ALL SESSIONS TAB ====================
  Widget _buildAllSessionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text('All Active Sessions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              FilledButton.icon(
                onPressed: _isLoading ? null : _loadAllSessions,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _sessions.isEmpty
              ? const Center(
                  child: Text('No sessions. Tap Refresh to load.', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.videocam)),
                        title: Text(session.channelName),
                        subtitle: Text('Host: ${session.hostUserId ?? 'N/A'} • Users: ${session.users.length}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSessionFromList(session.channelName),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _loadAllSessions() async {
    await _runAsync('Load All Sessions', () async {
      final sessions = await _apiService.getAllSessions();
      setState(() {
        _sessions = sessions;
      });
      _log('Loaded ${sessions.length} sessions');
    });
  }

  Future<void> _deleteSessionFromList(String channelName) async {
    await _runAsync('End Session $channelName', () async {
      await _apiService.endSession(channelName);
      _log('Session ended: $channelName');
      await _loadAllSessions();
    });
  }

  // ==================== LOGS PANEL ====================
  Widget _buildLogsPanel() {
    return Container(
      height: 200,
      color: Colors.black87,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black54,
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 16),
                const SizedBox(width: 8),
                const Text('Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Text(
                _logs.isEmpty ? 'No logs yet...' : _logs,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
