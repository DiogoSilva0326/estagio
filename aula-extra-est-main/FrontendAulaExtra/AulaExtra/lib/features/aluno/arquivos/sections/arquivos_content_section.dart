import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_mock_data.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/arquivos_mobile_folder_card.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/arquivos_mobile_intro.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/arquivos_mobile_recent_file_card.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/arquivos_mobile_search_upload.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/arquivos_mobile_stats_card.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/folders_row.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/recent_files_table_card.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/search_and_upload_row.dart';

class ArquivosContentSection extends StatefulWidget {
  const ArquivosContentSection({super.key});

  @override
  State<ArquivosContentSection> createState() => _ArquivosContentSectionState();
}

class _ArquivosContentSectionState extends State<ArquivosContentSection> {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024;

  final ChatFilesService _chatFilesService = ChatFilesService();
  final UsersService _usersService = UsersService();

  String _query = '';
  String? _username;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isUploading = false;
  List<ChatFileInfoDto> _files = const <ChatFileInfoDto>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFiles());
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = await _resolveUsername();
      final files = await _chatFilesService.getUserFiles(username: username);
      if (!mounted) return;
      setState(() {
        _username = username;
        _files = files;
        _isLoading = false;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isUploading = false;
      });
    }
  }

  Future<String> _resolveUsername() async {
    try {
      final user = context.read<UserProvider>();
      final providerUsername = user.account?.username?.trim();
      if (providerUsername != null && providerUsername.isNotEmpty) {
        return providerUsername;
      }
    } catch (_) {}

    final me = await _usersService.getMe();
    final username = me.username?.trim();
    if (username == null || username.isEmpty) {
      throw Exception('Não foi possível identificar o utilizador.');
    }
    return username;
  }

  Future<void> _handleUpload() async {
    final username = _username ?? await _resolveUsername();

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Não foi possível ler o ficheiro selecionado.');
      }
      if (bytes.length > _maxFileSizeBytes) {
        throw Exception('O ficheiro excede o limite de 5 MB.');
      }

      await _chatFilesService.uploadFile(
        bytes: bytes,
        fileName: file.name,
        contentType: _guessContentType(file.name),
        userId: username,
      );

      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isUploading = false;
      });
    }
  }

  Future<void> _openFile(ChatFileInfoDto file) async {
    final uri = Uri.tryParse(file.downloadUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Não foi possível abrir ${file.fileName}.';
      });
    }
  }

  Future<void> _deleteFile(ChatFileInfoDto file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar ficheiro'),
        content: Text(
          'Pretende apagar "${file.fileName}"? Esta ação remove o ficheiro do R2.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _chatFilesService.deleteFile(fileId: file.fileId);
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ChatFileInfoDto> get _filteredFiles {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _files;

    return _files
        .where((file) {
          return file.fileName.toLowerCase().contains(normalizedQuery) ||
              file.uploadedByDisplayName.toLowerCase().contains(
                normalizedQuery,
              ) ||
              file.contentType.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  List<_MobileFolderDisplayData> get _mobileFolders {
    if (_files.isEmpty) {
      return ArquivosMockData.folders
          .map(
            (folder) => _MobileFolderDisplayData(
              title: folder.title,
              subtitle: folder.subtitle,
              icon: folder.icon,
              color: folder.color,
            ),
          )
          .toList(growable: false);
    }

    const palette = <_FolderPaletteEntry>[
      _FolderPaletteEntry(
        color: Color(0xFF2B7FFF),
        icon: Icons.functions_rounded,
      ),
      _FolderPaletteEntry(
        color: Color(0xFF00C950),
        icon: Icons.science_rounded,
      ),
      _FolderPaletteEntry(
        color: Color(0xFFFF6900),
        icon: Icons.language_rounded,
      ),
      _FolderPaletteEntry(color: Color(0xFF7A5AF8), icon: Icons.folder_rounded),
    ];

    final counts = <String, int>{};
    for (final file in _filteredFiles) {
      final key = file.uploadedByDisplayName.trim().isEmpty
          ? 'Sem tutor'
          : file.uploadedByDisplayName.trim();
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }

    final entries = counts.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));

    return entries
        .take(3)
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final paletteEntry = palette[entry.key % palette.length];
          final folder = entry.value;
          return _MobileFolderDisplayData(
            title: folder.key,
            subtitle: '${folder.value} arquivos',
            icon: paletteEntry.icon,
            color: paletteEntry.color,
          );
        })
        .toList(growable: false);
  }

  String _formatDate(DateTime value) {
    const months = <String>[
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    final localValue = value.toLocal();
    return '${localValue.day.toString().padLeft(2, '0')} ${months[localValue.month - 1]} ${localValue.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '$bytes B';
  }

  String _formatStorageTotal() {
    final totalBytes = _files.fold<int>(
      0,
      (sum, file) => sum + file.fileSizeBytes,
    );
    if (totalBytes == 0) return '0 MB';
    return _formatFileSize(totalBytes);
  }

  String _fileTypeLabel(ChatFileInfoDto file) {
    final nameParts = file.fileName.split('.');
    final extension = nameParts.length > 1 ? nameParts.last.toUpperCase() : '';
    if (extension.isNotEmpty) return extension;
    if (file.contentType.contains('/')) {
      return file.contentType.split('/').last.toUpperCase();
    }
    return file.contentType.toUpperCase();
  }

  IconData _fileIcon(ChatFileInfoDto file) {
    final type = _fileTypeLabel(file);
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'DOC':
      case 'DOCX':
        return Icons.description_rounded;
      case 'PPT':
      case 'PPTX':
        return Icons.slideshow_rounded;
      case 'XLS':
      case 'XLSX':
        return Icons.table_chart_rounded;
      case 'PNG':
      case 'JPG':
      case 'JPEG':
      case 'WEBP':
      case 'GIF':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  int get _pdfCount =>
      _files.where((file) => _fileTypeLabel(file) == 'PDF').length;

  Widget _buildMobileContent() {
    final recentFiles = _filteredFiles.take(4).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ArquivosConstants.mobileHorizontalPadding,
        vertical: ArquivosConstants.mobileVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ArquivosMobileIntro(
            title: 'Arquivos',
            subtitle: 'Gerencie seus documentos e materiais de estudo',
          ),
          const SizedBox(height: ArquivosConstants.mobileSectionSpacing),
          ArquivosMobileSearchUpload(
            onChanged: (value) => setState(() => _query = value),
            onUpload: _handleUpload,
            isUploading: _isUploading,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: ArquivosConstants.mobileSectionSpacing),
          const Text(
            'Pastas',
            style: ArquivosConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 12),
          ..._mobileFolders.map(
            (folder) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ArquivosMobileFolderCard(
                color: folder.color,
                icon: folder.icon,
                title: folder.title,
                subtitle: folder.subtitle,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Arquivos Recentes',
            style: ArquivosConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recentFiles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ArquivosConstants.mobileSurfaceColor,
                borderRadius: BorderRadius.circular(
                  ArquivosConstants.mobileCardRadius,
                ),
                border: Border.all(color: ArquivosConstants.mobileBorderColor),
              ),
              child: const Text(
                'Nenhum arquivo encontrado.',
                style: ArquivosConstants.mobileBodyStyle,
              ),
            )
          else
            ...recentFiles.map(
              (file) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ArquivosMobileRecentFileCard(
                  file: file,
                  onDownloadTap: () => _openFile(file),
                  fileTypeLabel: _fileTypeLabel(file),
                  fileSizeLabel: _formatFileSize(file.fileSizeBytes),
                  formattedDate: _formatDate(file.createdAt),
                  fileIcon: _fileIcon(file),
                ),
              ),
            ),
          const SizedBox(height: 4),
          ArquivosMobileStatsCard(
            firstLabel: 'Total de arquivos',
            firstValue: '${_files.length}',
            secondLabel: 'Arquivos PDF',
            secondValue: '$_pdfCount',
            thirdLabel: 'Armazenamento usado',
            thirdValue: _formatStorageTotal(),
          ),
        ],
      ),
    );
  }

  String _guessContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return _buildMobileContent();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ArquivosConstants.horizontalPadding,
        vertical: ArquivosConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Arquivos', style: ArquivosConstants.titleStyle),
                const SizedBox(height: ArquivosConstants.gapSmall),
                const Text(
                  'Gerencie seus documentos e materiais de estudo',
                  style: ArquivosConstants.subtitleStyle,
                ),
                const SizedBox(height: ArquivosConstants.gapLarge),
                SearchAndUploadRow(
                  onChanged: (value) => setState(() => _query = value),
                  onUpload: _isUploading ? null : _handleUpload,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: ArquivosConstants.gapLarge),
                const Text(
                  'Pastas',
                  style: ArquivosConstants.sectionTitleStyle,
                ),
                const SizedBox(height: ArquivosConstants.gapSection),
                const FoldersRow(),
                const SizedBox(height: ArquivosConstants.gapLarge),
                const Text(
                  'Arquivos Recentes',
                  style: ArquivosConstants.sectionTitleStyle,
                ),
                const SizedBox(height: ArquivosConstants.gapSection),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  RecentFilesTableCard(
                    files: _filteredFiles,
                    onDownloadTap: _openFile,
                    onDeleteTap: _deleteFile,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileFolderDisplayData {
  const _MobileFolderDisplayData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _FolderPaletteEntry {
  const _FolderPaletteEntry({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}
