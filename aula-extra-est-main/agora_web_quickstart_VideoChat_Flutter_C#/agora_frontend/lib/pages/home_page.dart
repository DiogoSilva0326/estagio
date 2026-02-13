import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _channelController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final defaultChannel = dotenv.isInitialized ? (dotenv.env['DEFAULT_CHANNEL'] ?? '') : '';
    _channelController = TextEditingController(text: defaultChannel);
    _nameController = TextEditingController(text: 'Guest');
  }

  @override
  void dispose() {
    _channelController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _joinCall() {
    final channel = _channelController.text.trim();
    final name = _nameController.text.trim();

    if (channel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Channel name is required')),
      );
      return;
    }

    // Navigate to video call page with channel and name
    Navigator.of(context).pushNamed(
      '/video-call',
      arguments: {
        'channelName': channel,
        'userName': name,
      },
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings page coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Direct messages',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.of(context).pushNamed('/messages'),
          ),
          IconButton(
            tooltip: 'Chat',
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.of(context).pushNamed('/chat'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo/Header
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Video Chat',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'with Agora & Whiteboard',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Channel Name Input
            TextField(
              controller: _channelController,
              decoration: InputDecoration(
                labelText: 'Channel Name',
                hintText: 'Enter a channel name',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 20),

            // User Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your display name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 32),

            // Join Button
            FilledButton.icon(
              icon: const Icon(Icons.call),
              label: const Text('Join Call'),
              onPressed: _joinCall,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Chat Button
            FilledButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Open Chat'),
              onPressed: () => Navigator.of(context).pushNamed('/chat'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Settings Button
            OutlinedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
              onPressed: _openSettings,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.videocam, 'HD Video Calling'),
                    _buildFeatureItem(Icons.share, 'Screen Sharing'),
                    _buildFeatureItem(Icons.draw, 'Whiteboard'),
                    _buildFeatureItem(Icons.text_fields, 'Display Names'),
                    _buildFeatureItem(Icons.chat, 'Text Chat'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
