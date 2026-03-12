import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/video_call_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ .env loaded successfully');
    debugPrint('AGORA_APP_ID: ${dotenv.env['AGORA_APP_ID'] ?? 'NOT FOUND'}');
  } catch (e) {
    debugPrint('❌ Could not load .env file: $e');
  }
  
  runApp(const AgoraTestApp());
}

class AgoraTestApp extends StatefulWidget {
  const AgoraTestApp({super.key});

  @override
  State<AgoraTestApp> createState() => _AgoraTestAppState();
}

class _AgoraTestAppState extends State<AgoraTestApp> {
  late final AuthService _authService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5050';
    _authService = AuthService(baseUrl: apiUrl);
    await _authService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  /// Check if URL indicates video call page (web only)
  bool _isVideoCallRoute() {
    if (!kIsWeb) return false;
    final uri = Uri.base;
    final path = uri.path;
    debugPrint('_isVideoCallRoute - Full URI: $uri');
    debugPrint('_isVideoCallRoute - Path: $path');
    debugPrint('_isVideoCallRoute - Contains video_call: ${path.contains('video_call')}');
    return path.contains('video_call');
  }

  @override
  Widget build(BuildContext context) {
    // On web, if URL contains /video_call, show video call directly
    final isVideoCall = _isVideoCallRoute();
    
    return MaterialApp(
      title: 'Agora Integrator Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Show video call directly if URL matches, otherwise show home/login
      home: isVideoCall ? const VideoCallEntryPage() : _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing...'),
            ],
          ),
        ),
      );
    }

    // Check if user is authenticated
    if (_authService.isAuthenticated) {
      return HomePage(authService: _authService);
    }

    return LoginPage(authService: _authService);
  }
}

