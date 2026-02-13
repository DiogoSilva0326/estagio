import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../agoraAPI/services/token_service.dart';

class DirectMessageRtcPage extends StatefulWidget {
  const DirectMessageRtcPage({super.key});

  @override
  State<DirectMessageRtcPage> createState() => _DirectMessageRtcPageState();
}

class _DirectMessageRtcPageState extends State<DirectMessageRtcPage> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  final _nameController = TextEditingController(text: 'Guest');

  final _tokenService = TokenService();

  RtcEngineEx? _engine;
  int _localUid = 0;
  int? _dataStreamId;
  String _channel = 'messages';
  bool _joined = false;

  final _messages = <_DmMessage>[];
  final _userNames = <int, String>{};

  @override
  void initState() {
    super.initState();
    final defaultDm = dotenv.env['DM_CHANNEL']?.trim();
    if (defaultDm != null && defaultDm.isNotEmpty) {
      _channel = defaultDm;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _messageController.dispose();
    _nameController.dispose();
    _engine?.release();
    super.dispose();
  }

  String _requiredEnv(String key) {
    final v = dotenv.env[key];
    if (v == null || v.trim().isEmpty) {
      throw StateError('Missing env var: $key');
    }
    return v;
  }

  int _pickUid() {
    final r = Random();
    return 100000 + r.nextInt(900000);
  }

  Future<void> _connect() async {
    if (_joined) return;
    final appId = _requiredEnv('AGORA_APP_ID');
    final engine = createAgoraRtcEngineEx();
    await engine.initialize(RtcEngineContext(appId: appId));
    await engine.enableAudio();
    await engine.enableVideo();

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (conn, elapsed) async {
          // Channel join callback fired, but on web it may not be fully ready yet.
          // Add a significant delay before allowing sends.
          await Future.delayed(const Duration(seconds: 2));
          setState(() => _joined = true);
          await _ensureStream();
          // Broadcast name after stream is created
          await _broadcastName();
        },
        onStreamMessage: (conn, remoteUid, streamId, data, length, ts) {
          try {
            final decoded = jsonDecode(String.fromCharCodes(data));
            if (decoded is Map && decoded['type'] == 'chat') {
              final toUid = decoded['toUid'] as int?;
              final toName = decoded['toName'] as String?;
              final matchesMe = toUid == null && toName == null
                  ? true
                  : (toUid != null && toUid == _localUid) ||
                        (toName != null &&
                            toName == _nameController.text.trim());
              if (matchesMe || remoteUid == _localUid) {
                setState(() {
                  _messages.add(
                    _DmMessage(
                      fromUid: remoteUid,
                      fromName:
                          decoded['fromName'] as String? ?? 'User $remoteUid',
                      toUid: toUid,
                      toName: toName,
                      text: decoded['text'] as String? ?? '',
                      timestamp: DateTime.now(),
                    ),
                  );
                });
              }
            } else if (decoded is Map && decoded['type'] == 'name') {
              final name = decoded['name'] as String?;
              if (name != null) _userNames[remoteUid] = name;
            }
          } catch (_) {}
        },
      ),
    );

    _engine = engine;
    _localUid = _pickUid();
    final token = await _tokenService.fetchRtcToken(
      uid: _localUid,
      channelName: _channel,
    );

    await engine.joinChannelEx(
      token: token,
      connection: RtcConnection(channelId: _channel, localUid: _localUid),
      options: const ChannelMediaOptions(
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: false,
        autoSubscribeVideo: false,
      ),
    );
    // Extra safety: wait for callback to fire and stabilize
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _ensureStream() async {
    if (_dataStreamId != null || _engine == null) return;
    _dataStreamId = await _engine!.createDataStream(
      const DataStreamConfig(syncWithAudio: false, ordered: true),
    );
  }

  Future<void> _broadcastName() async {
    if (_engine == null || _dataStreamId == null) return;
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        final payload = jsonEncode({
          'type': 'name',
          'name': _nameController.text.trim(),
        });
        final bytes = Uint8List.fromList(payload.codeUnits);
        await _engine!.sendStreamMessage(
          streamId: _dataStreamId!,
          data: bytes,
          length: bytes.length,
        );
        return; // Success, exit
      } catch (e) {
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }
    // Failed after retries, silently ignore
  }

  Future<void> _send() async {
    if (_engine == null || _dataStreamId == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    int? toUid;
    String? toName;
    final recipient = _recipientController.text.trim();
    if (recipient.isNotEmpty) {
      final id = int.tryParse(recipient);
      if (id != null) {
        toUid = id;
      } else {
        // Try resolve by name
        final match = _userNames.entries.firstWhere(
          (e) => e.value.toLowerCase() == recipient.toLowerCase(),
          orElse: () => const MapEntry(-1, ''),
        );
        if (match.key != -1) {
          toUid = match.key;
        } else {
          toName = recipient;
        }
      }
    }

    final payload = jsonEncode({
      'type': 'chat',
      'text': text,
      if (toUid != null) 'toUid': toUid,
      if (toName != null) 'toName': toName,
      'fromUid': _localUid,
      'fromName': _nameController.text.trim(),
    });
    final bytes = Uint8List.fromList(payload.codeUnits);
    
    int attempts = 0;
    const maxAttempts = 3;
    String? lastError;
    
    while (attempts < maxAttempts) {
      try {
        await _engine!.sendStreamMessage(
          streamId: _dataStreamId!,
          data: bytes,
          length: bytes.length,
        );
        // Success! Add to local list and clear input
        setState(() {
          _messages.add(
            _DmMessage(
              fromUid: _localUid,
              fromName: _nameController.text.trim(),
              toUid: toUid,
              toName: toName,
              text: text,
              timestamp: DateTime.now(),
            ),
          );
          _messageController.clear();
        });
        return;
      } catch (e) {
        lastError = e.toString();
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    }
    
    // Failed after retries
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send after retries: $lastError')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Messages'),
        actions: [
          FilledButton.tonal(
            onPressed: _joined ? null : _connect,
            child: const Text('Connect'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _recipientController,
                    decoration: const InputDecoration(
                      labelText: 'Recipient (UID or name)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 160,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Channel',
                      hintText: _channel,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() => _channel = v.trim());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isMe = m.fromUid == _localUid;
                final toLabel = (m.toUid != null)
                    ? '#${m.toUid}'
                    : (m.toName != null ? '@${m.toName}' : 'all');
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.blueGrey.shade700
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${m.fromName} → $toLabel',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(m.text),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _joined ? _send : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DmMessage {
  final int fromUid;
  final String fromName;
  final int? toUid;
  final String? toName;
  final String text;
  final DateTime timestamp;

  _DmMessage({
    required this.fromUid,
    required this.fromName,
    required this.text,
    required this.timestamp,
    this.toUid,
    this.toName,
  });
}
