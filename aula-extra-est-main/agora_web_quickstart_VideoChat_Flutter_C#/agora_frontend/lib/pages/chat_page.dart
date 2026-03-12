import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import '../providers/chat_provider.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController _userIdController;
  late TextEditingController _tokenController;
  late TextEditingController _peerIdController;
  late TextEditingController _messageController;
  late ScrollController _logsScrollController;
  Timer? _messagePollingTimer;
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _userIdController = TextEditingController();
    _tokenController = TextEditingController();
    _peerIdController = TextEditingController();
    _messageController = TextEditingController();
    _logsScrollController = ScrollController();
  }

  void _startMessagePolling() {
    _messagePollingTimer?.cancel();
    if (_autoRefresh) {
      _messagePollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        final chatProvider = context.read<ChatProvider>();
        if (chatProvider.isChatLoggedIn) {
          chatProvider.fetchMessages();
        }
      });
    }
    
    // Fetch messages immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      if (chatProvider.isChatLoggedIn) {
        chatProvider.fetchMessages();
      }
    });
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });
    if (_autoRefresh) {
      _startMessagePolling();
    } else {
      _messagePollingTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _messagePollingTimer?.cancel();
    _userIdController.dispose();
    _tokenController.dispose();
    _peerIdController.dispose();
    _messageController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logsScrollController.hasClients) {
        _logsScrollController.animateTo(
          _logsScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Chat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.sync : Icons.sync_disabled),
            tooltip: _autoRefresh ? 'Auto-refresh ON' : 'Auto-refresh OFF',
            onPressed: _toggleAutoRefresh,
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              if (chatProvider.isChatLoggedIn) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh messages',
                  onPressed: () => chatProvider.fetchMessages(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          _scrollToBottom();
          
          if (!chatProvider.isChatLoggedIn) {
            return _buildLoginScreen(chatProvider);
          } else {
            return _buildChatScreen(chatProvider);
          }
        },
      ),
    );
  }

  Widget _buildLoginScreen(ChatProvider chatProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Agora Chat Login',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _userIdController,
            onChanged: (value) => chatProvider.setUserId(value),
            decoration: InputDecoration(
              labelText: 'User ID',
              hintText: 'Enter your user ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tokenController,
            onChanged: (value) => chatProvider.setPassword(value),
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password (e.g., Pass_user_2026)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await chatProvider.register();
                    },
                    child: const Text('Register'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await chatProvider.login();
                      if (success) {
                        _startMessagePolling();
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Logs Section
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade900,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Logs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => chatProvider.clearLogs(),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: chatProvider.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _logsScrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: chatProvider.logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                chatProvider.logs[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen(ChatProvider chatProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Agora Chat Messages',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Welcome, ${chatProvider.userId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await chatProvider.logout();
                _messagePollingTimer?.cancel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _peerIdController,
            onChanged: (value) => chatProvider.setPeerId(value),
            decoration: InputDecoration(
              labelText: 'Peer userID',
              hintText: 'Enter the peer user ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Message',
              hintText: 'Input message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final success = await chatProvider
                    .sendMessage(_messageController.text);
                if (success) {
                  _messageController.clear();
                }
              },
              child: const Text('Send'),
            ),
          ),
          const SizedBox(height: 24),
          // Messages Section
          const Text(
            'Messages',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade900,
            ),
            child: chatProvider.messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatProvider.messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];
                      final isMe = msg.from == chatProvider.userId;
                      
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'Me → ${msg.to}' : '${msg.from} → Me',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade300,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (msg.body as ChatTextMessageBody).content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateTime.fromMillisecondsSinceEpoch(msg.serverTime).toString().substring(11, 19),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
          // Logs Section
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade900,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Logs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => chatProvider.clearLogs(),
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: chatProvider.logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _logsScrollController,
                          padding: const EdgeInsets.all(8),
                          itemCount: chatProvider.logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                chatProvider.logs[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
