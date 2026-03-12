import 'package:flutter/material.dart';
import 'video_chat_page.dart';

/// Entry page for video calls when opened via a URL (web).
/// Reads query params and instantiates VideoChatPage accordingly.
class VideoCallEntryPage extends StatelessWidget {
  const VideoCallEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    debugPrint('VideoCallEntryPage - Full URI: $uri');
    debugPrint('VideoCallEntryPage - Path: ${uri.path}');
    debugPrint('VideoCallEntryPage - Query params: ${uri.queryParameters}');
    
    final params = uri.queryParameters;
    final channel = params['channel'] ?? '';
    final user = params['user'] ?? '';
    final token = params['token'];
    final isHostStr = params['host'] ?? 'false';
    final isHost = isHostStr.toLowerCase() == 'true';
    
    debugPrint('VideoCallEntryPage - channel: $channel, user: $user, isHost: $isHost');

    if (channel.isEmpty || user.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Missing channel or user in URL'),
              const SizedBox(height: 16),
              Text('URI: ${uri.toString()}', style: const TextStyle(fontSize: 12)),
              Text('Path: ${uri.path}', style: const TextStyle(fontSize: 12)),
              Text('Params: ${uri.queryParameters}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return VideoChatPage(
      channelName: channel,
      userName: user,
      authToken: token,
      isHost: isHost,
    );
  }
}
