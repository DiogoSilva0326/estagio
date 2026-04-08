import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../pages/video_chat_page.dart';

/// Opens a video call:
/// - On web: opens `/video_call` in a new browser tab
/// - On mobile/desktop: navigates inside the app using Navigator
Future<void> openOrNavigateToVideoCall(
  BuildContext context, {
  required String channel,
  required String user,
  String? token,
  bool isHost = false,
}) async {
  if (kIsWeb) {
    // Build URL with query parameters based on current host
    final currentUri = Uri.base;
    final queryParams = <String, String>{
      'channel': channel,
      'user': user,
      if (token != null) 'token': token,
      if (isHost) 'host': 'true',
    };

    final uri = Uri(
      scheme: currentUri.scheme,
      host: currentUri.host,
      port: currentUri.port,
      path: '/video_call',
      queryParameters: queryParams,
    );

    debugPrint('Opening video call in new tab: ${uri.toString()}');

    // Open in new browser tab
    await launchUrlString(
      uri.toString(),
      webOnlyWindowName: '_blank',
    );
    return;
  }

  // Mobile/desktop: navigate inside the app
  if (context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoChatPage(
          channelName: channel,
          userName: user,
          authToken: token,
          isHost: isHost,
        ),
      ),
    );
  }
}
