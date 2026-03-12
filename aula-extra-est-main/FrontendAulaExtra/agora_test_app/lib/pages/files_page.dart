import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

/// Page to view all files shared with/by the user
class FilesPage extends StatefulWidget {
  const FilesPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  bool _loading = true;
  String? _error;

  // Group files by room
  Map<String, List<UserFileInfo>> _filesByRoom = {};
  List<UserFileInfo> _sentFiles = [];
  List<UserFileInfo> _receivedFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _apiService.getUserFiles(widget.userId);
      
      // Organize files
      final byRoom = <String, List<UserFileInfo>>{};
      final sent = <UserFileInfo>[];
      final received = <UserFileInfo>[];

      for (final file in result.files) {
        // Group by room
        final roomKey = file.roomId ?? 'sem_conversa';
        byRoom.putIfAbsent(roomKey, () => []).add(file);

        // Categorize by ownership
        if (file.isOwnFile) {
          sent.add(file);
        } else {
          received.add(file);
        }
      }

      setState(() {
        _filesByRoom = byRoom;
        _sentFiles = sent;
        _receivedFiles = received;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficheiros'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos', icon: Icon(Icons.folder)),
            Tab(text: 'Enviados', icon: Icon(Icons.upload)),
            Tab(text: 'Recebidos', icon: Icon(Icons.download)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erro: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFiles,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllFilesTab(),
                    _buildFilesList(_sentFiles, 'Nenhum ficheiro enviado'),
                    _buildFilesList(_receivedFiles, 'Nenhum ficheiro recebido'),
                  ],
                ),
    );
  }

  Widget _buildAllFilesTab() {
    if (_filesByRoom.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum ficheiro encontrado',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filesByRoom.length,
      itemBuilder: (context, index) {
        final roomId = _filesByRoom.keys.elementAt(index);
        final files = _filesByRoom[roomId]!;
        final roomName = _getRoomDisplayName(roomId);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: roomId.startsWith('dm_') ? Colors.green : Colors.blue,
              child: Icon(
                roomId.startsWith('dm_') ? Icons.person : Icons.group,
                color: Colors.white,
              ),
            ),
            title: Text(roomName),
            subtitle: Text('${files.length} ficheiro(s)'),
            children: files.map((file) => _buildFileItem(file)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildFilesList(List<UserFileInfo> files, String emptyMessage) {
    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: files.length,
      itemBuilder: (context, index) => _buildFileItem(files[index]),
    );
  }

  Widget _buildFileItem(UserFileInfo file) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _getFileColor(file).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getFileIcon(file),
          color: _getFileColor(file),
        ),
      ),
      title: Text(
        file.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${file.formattedSize} • ${_formatDate(file.createdAt)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            file.isOwnFile 
                ? 'Enviado por ti' 
                : 'Enviado por ${file.uploadedByDisplayName}',
            style: TextStyle(
              fontSize: 11,
              color: file.isOwnFile ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (file.isImage)
            IconButton(
              icon: const Icon(Icons.visibility, size: 20),
              onPressed: () => _previewFile(file),
              tooltip: 'Pré-visualizar',
            ),
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () => _downloadFile(file),
            tooltip: 'Download',
          ),
        ],
      ),
      onTap: () => _downloadFile(file),
    );
  }

  String _getRoomDisplayName(String roomId) {
    if (roomId == 'sem_conversa') return 'Sem conversa associada';
    
    if (roomId.startsWith('dm_')) {
      // Extract usernames from dm_user1_user2
      final parts = roomId.split('_');
      if (parts.length >= 3) {
        final otherUser = parts[1] == widget.userId ? parts[2] : parts[1];
        return 'Chat com $otherUser';
      }
    }
    
    // Group or other room
    return roomId;
  }

  IconData _getFileIcon(UserFileInfo file) {
    if (file.isImage) return Icons.image;
    if (file.isVideo) return Icons.video_file;
    if (file.isAudio) return Icons.audio_file;
    
    final ext = file.fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(UserFileInfo file) {
    if (file.isImage) return Colors.purple;
    if (file.isVideo) return Colors.red;
    if (file.isAudio) return Colors.orange;
    
    final ext = file.fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Hoje ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return 'Há ${diff.inDays} dias';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _previewFile(UserFileInfo file) async {
    if (!file.isImage) return;

    final url = _apiService.getFileDownloadUrl(file.fileId);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(file.fileName, overflow: TextOverflow.ellipsis),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Erro ao carregar imagem'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                onPressed: () {
                  Navigator.pop(context);
                  _downloadFile(file);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(UserFileInfo file) async {
    final url = _apiService.getFileDownloadUrl(file.fileId);
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o ficheiro')),
        );
      }
    }
  }
}
