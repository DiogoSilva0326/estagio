import 'package:flutter/material.dart';

/// Video call page - currently a stub
/// TODO: Migrate main.dart's _VideoChatPageState logic here and use AgoraService
class VideoCallPageNew extends StatefulWidget {
  final String channelName;
  final String userName;

  const VideoCallPageNew({
    super.key,
    required this.channelName,
    required this.userName,
  });

  @override
  State<VideoCallPageNew> createState() => _VideoCallPageNewState();
}

class _VideoCallPageNewState extends State<VideoCallPageNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Text(
          'Video Call\nChannel: ${widget.channelName}\nUser: ${widget.userName}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
