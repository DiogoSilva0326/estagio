import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivo_row.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_search_field.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_upload_button.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/pasta_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArquivosProfessorContentSection extends StatefulWidget {
  const ArquivosProfessorContentSection({super.key});

  @override
  State<ArquivosProfessorContentSection> createState() =>
      _ArquivosProfessorContentSectionState();
}

class _ArquivosProfessorContentSectionState
    extends State<ArquivosProfessorContentSection> {
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
      throw Exception('Não foi possível identificar o professor.');
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

  List<_FolderSummary> get _folders {
    final counts = <String, int>{};
    for (final file in _files) {
      final key = file.uploadedByDisplayName.trim().isEmpty
          ? 'Sem nome'
          : file.uploadedByDisplayName.trim();
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }

    return counts.entries
        .map((entry) => _FolderSummary(name: entry.key, count: entry.value))
        .take(5)
        .toList(growable: false);
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
    return Container(
      color: ArquivosProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 54,
            right: 23.148,
            top: 90,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(
                selectedIndex: 3,
                notificationCount: 2,
                aulasEstaSemana: 8,
                ganhosPendentes: '150€',
                alunosAtivos: 12,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28.889, 28.889, 28.889, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 43.333,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Arquivos',
                              style: TextStyle(
                                color: ArquivosProfessorColors.title,
                                fontSize: ArquivosProfessorFontSizes.title,
                                fontWeight: FontWeight.w700,
                                height:
                                    43.333 / ArquivosProfessorFontSizes.title,
                              ),
                            ),
                            ArquivosProfessorUploadButton(
                              onTap: _isUploading ? () {} : _handleUpload,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28.889),
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20.463,
                            20.463,
                            20.463,
                            20.463,
                          ),
                          child: ArquivosProfessorSearchField(
                            onChanged: (value) =>
                                setState(() => _query = value),
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 28.889),
                      SizedBox(
                        height: 536.852,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 228.102,
                              child: _Card(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20.463,
                                    20.463,
                                    20.463,
                                    20.463,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pastas',
                                        style: TextStyle(
                                          color: ArquivosProfessorColors.title,
                                          fontSize: ArquivosProfessorFontSizes
                                              .sectionHeading,
                                          fontWeight: FontWeight.w500,
                                          height:
                                              32.5 /
                                              ArquivosProfessorFontSizes
                                                  .sectionHeading,
                                        ),
                                      ),
                                      const SizedBox(height: 19.259),
                                      for (
                                        int i = 0;
                                        i < _folders.length;
                                        i++
                                      ) ...[
                                        PastaTile(
                                          icon: Icons.person_rounded,
                                          name: _folders[i].name,
                                          countLabel:
                                              '${_folders[i].count} arquivos',
                                          onTap: () => setState(
                                            () => _query = _folders[i].name,
                                          ),
                                        ),
                                        if (i != _folders.length - 1)
                                          const SizedBox(height: 9.63),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 28.889),
                            Expanded(
                              child: _Card(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                        19.259,
                                        19.259,
                                        19.259,
                                        19.259,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: ArquivosProfessorColors
                                                .cardBorder,
                                            width: 1.204,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Todos os Arquivos',
                                        style: TextStyle(
                                          color: ArquivosProfessorColors.title,
                                          fontSize: ArquivosProfessorFontSizes
                                              .sectionHeading,
                                          fontWeight: FontWeight.w500,
                                          height:
                                              32.5 /
                                              ArquivosProfessorFontSizes
                                                  .sectionHeading,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: _isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  for (
                                                    int i = 0;
                                                    i < _filteredFiles.length;
                                                    i++
                                                  )
                                                    ArquivoRow(
                                                      leadingBackground:
                                                          _fileBackground(
                                                            _filteredFiles[i]
                                                                .contentType,
                                                          ),
                                                      leadingIcon: _fileIcon(
                                                        _filteredFiles[i]
                                                            .contentType,
                                                      ),
                                                      fileName:
                                                          _filteredFiles[i]
                                                              .fileName,
                                                      ownerLabel: _filteredFiles[i]
                                                          .uploadedByDisplayName,
                                                      sizeLabel:
                                                          _formatFileSize(
                                                            _filteredFiles[i]
                                                                .fileSizeBytes,
                                                          ),
                                                      dateLabel: _formatDate(
                                                        _filteredFiles[i]
                                                            .createdAt,
                                                      ),
                                                      onDownloadTap: () =>
                                                          _openFile(
                                                            _filteredFiles[i],
                                                          ),
                                                      onDeleteTap: () =>
                                                          _deleteFile(
                                                            _filteredFiles[i],
                                                          ),
                                                      showDivider:
                                                          i !=
                                                          _filteredFiles
                                                                  .length -
                                                              1,
                                                    ),
                                                  if (_filteredFiles.isEmpty)
                                                    const Padding(
                                                      padding: EdgeInsets.all(
                                                        24,
                                                      ),
                                                      child: Text(
                                                        'Nenhum ficheiro encontrado.',
                                                        style: TextStyle(
                                                          color:
                                                              ArquivosProfessorColors
                                                                  .textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderSummary {
  const _FolderSummary({required this.name, required this.count});

  final String name;
  final int count;
}

Color _fileBackground(String contentType) {
  final normalized = contentType.toLowerCase();
  if (normalized.contains('pdf')) return ArquivosProfessorColors.fileTypeRedBg;
  if (normalized.contains('presentation') ||
      normalized.contains('powerpoint')) {
    return ArquivosProfessorColors.fileTypeOrangeBg;
  }
  if (normalized.contains('image'))
    return ArquivosProfessorColors.fileTypeGreenBg;
  return ArquivosProfessorColors.fileTypeBlueBg;
}

IconData _fileIcon(String contentType) {
  final normalized = contentType.toLowerCase();
  if (normalized.contains('pdf')) return Icons.picture_as_pdf_rounded;
  if (normalized.contains('presentation') || normalized.contains('powerpoint'))
    return Icons.slideshow_rounded;
  if (normalized.contains('image')) return Icons.image_rounded;
  if (normalized.contains('audio')) return Icons.audio_file_rounded;
  if (normalized.contains('video')) return Icons.video_file_rounded;
  return Icons.description_rounded;
}

String _formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  final decimals = size >= 10 || unitIndex == 0 ? 0 : 1;
  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
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
  final local = value.toLocal();
  final month = months[(local.month - 1).clamp(0, months.length - 1)];
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day.toString().padLeft(2, '0')} $month ${local.year} • $hour:$minute';
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: ArquivosProfessorColors.cardBackground,
        borderRadius: BorderRadius.circular(19.259),
        border: Border.all(
          color: ArquivosProfessorColors.cardBorder,
          width: 1.204,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 4.815),
            blurRadius: 7.222,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 2.407),
            blurRadius: 4.815,
          ),
        ],
      ),
      child: child,
    );
  }
}
