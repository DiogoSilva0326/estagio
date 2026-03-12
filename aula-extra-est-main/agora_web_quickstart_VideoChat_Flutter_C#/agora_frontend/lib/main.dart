import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'agoraAPI/agora_api.dart';
import 'pages/home_page.dart';
import 'pages/direct_message_rtc_page.dart';
import 'pages/chat_page.dart';
import 'providers/chat_provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const AgoraApp(),
    ),
  );
}

class AgoraApp extends StatelessWidget {
  const AgoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Video Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/video-call': (context) {
          final args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map<String, String>;
          return VideoChatPage(
            channelName: args['channelName'] ?? 'teste',
            userName: args['userName'] ?? 'Guest',
          );
        },
        '/messages': (context) => const DirectMessageRtcPage(),
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}
