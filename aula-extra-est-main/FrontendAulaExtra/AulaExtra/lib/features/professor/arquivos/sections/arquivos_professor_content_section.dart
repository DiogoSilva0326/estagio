import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/arquivos_mobile_intro.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_colors.dart';
import 'package:aula_extra/features/professor/arquivos/constants/arquivos_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivo_row.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_mobile_file_card.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_mobile_folder_card.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_mobile_search_upload.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_mobile_stats_card.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_search_field.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/arquivos_professor_upload_button.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/arquivos/widgets/pasta_tile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:aula_extra/core/config/teaching_roles_config.dart';

class ArquivosProfessorContentSection extends StatefulWidget {
  const ArquivosProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

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
      throw Exception('Não foi possível identificar o profissional.');
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

  Future<void> _shareFile(ChatFileInfoDto file) async {
    await Clipboard.setData(ClipboardData(text: file.downloadUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link de ${file.fileName} copiado.')),
    );
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

  List<_MobileFolderSummary> get _mobileFolders {
    const palette = <_MobileFolderPalette>[
      _MobileFolderPalette(color: Color(0xFF2B7FFF)),
      _MobileFolderPalette(color: Color(0xFF00C950)),
      _MobileFolderPalette(color: Color(0xFFFF6900)),
      _MobileFolderPalette(color: Color(0xFF7A5AF8)),
    ];

    return _folders
        .asMap()
        .entries
        .map((entry) {
          final paletteEntry = palette[entry.key % palette.length];
          return _MobileFolderSummary(
            name: entry.value.name,
            countLabel: '${entry.value.count} arquivos',
            color: paletteEntry.color,
          );
        })
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

  Widget _buildMobileContent() {
    final recentFiles = _filteredFiles.take(3).toList(growable: false);
    
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final isOrange = config.roleName == 'Explicador';

    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArquivosMobileIntro(
            title: 'Arquivos',
            subtitle: 'Gerencie documentos e materiais dos seus ${config.studentsLabel.toLowerCase().replaceAll('meus ', '')}',
          ),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: isOrange ? null : config.primaryColor,
              ),
            ),
            child: ArquivosProfessorMobileSearchUpload(
              onChanged: (value) => setState(() => _query = value),
              onUpload: _handleUpload,
              isUploading: _isUploading,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Pastas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
              height: 28 / 18,
            ),
          ),
          const SizedBox(height: 16),
          if (_mobileFolders.isEmpty)
            _buildEmptyMobileCard('Ainda não existem pastas disponíveis.')
          else
            Column(
              children: [
                for (var index = 0; index < _mobileFolders.length; index++) ...[
                  ArquivosProfessorMobileFolderCard(
                    color: _mobileFolders[index].color,
                    title: _mobileFolders[index].name,
                    subtitle: _mobileFolders[index].countLabel,
                    onTap: () =>
                        setState(() => _query = _mobileFolders[index].name),
                  ),
                  if (index != _mobileFolders.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          const SizedBox(height: 24),
          const Text(
            'Arquivos Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF101828),
              height: 28 / 18,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recentFiles.isEmpty)
            _buildEmptyMobileCard('Nenhum ficheiro encontrado.')
          else
            Column(
              children: [
                for (var index = 0; index < recentFiles.length; index++) ...[
                  ArquivosProfessorMobileFileCard(
                    fileName: recentFiles[index].fileName,
                    fileTypeLabel: _mobileFileTypeLabel(recentFiles[index]),
                    ownerLabel: recentFiles[index].uploadedByDisplayName,
                    dateLabel: _mobileDateLabel(recentFiles[index].createdAt),
                    sizeLabel: _formatFileSize(
                      recentFiles[index].fileSizeBytes,
                    ),
                    onDeleteTap: () => _deleteFile(recentFiles[index]),
                    onShareTap: () => _shareFile(recentFiles[index]),
                    onDownloadTap: () => _openFile(recentFiles[index]),
                  ),
                  if (index != recentFiles.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          const SizedBox(height: 16),
          ArquivosProfessorMobileStatsCard(
            firstLabel: 'Arquivos totais:',
            firstValue: _files.length.toString(),
            secondLabel: 'Ficheiros PDF:',
            secondValue: _pdfFileCount.toString(),
            thirdLabel: 'Armazenamento:',
            thirdValue: _formatStorageTotal(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMobileCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ArquivosProfessorColors.cardBorder),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          height: 20 / 14,
          color: ArquivosProfessorColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        widget.isMobile ||
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return _buildMobileContent();
    }

    return Container(
      color: ArquivosProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 54,
            right: 23.148,
            top: 46,
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

class _MobileFolderPalette {
  const _MobileFolderPalette({required this.color});

  final Color color;
}

class _MobileFolderSummary {
  const _MobileFolderSummary({
    required this.name,
    required this.countLabel,
    required this.color,
  });

  final String name;
  final String countLabel;
  final Color color;
}

Color _fileBackground(String contentType) {
  final normalized = contentType.toLowerCase();
  if (normalized.contains('pdf')) return ArquivosProfessorColors.fileTypeRedBg;
  if (normalized.contains('presentation') ||
      normalized.contains('powerpoint')) {
    return ArquivosProfessorColors.fileTypeOrangeBg;
  }
  if (normalized.contains('image')) {
    return ArquivosProfessorColors.fileTypeGreenBg;
  }
  return ArquivosProfessorColors.fileTypeBlueBg;
}

IconData _fileIcon(String contentType) {
  final normalized = contentType.toLowerCase();
  if (normalized.contains('pdf')) return Icons.picture_as_pdf_rounded;
  if (normalized.contains('presentation') ||
      normalized.contains('powerpoint')) {
    return Icons.slideshow_rounded;
  }
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

String _formatStorageTotalFromFiles(List<ChatFileInfoDto> files) {
  final totalBytes = files.fold<int>(
    0,
    (sum, file) => sum + file.fileSizeBytes,
  );
  if (totalBytes <= 0) return '0 B';
  return _formatFileSize(totalBytes);
}

extension on _ArquivosProfessorContentSectionState {
  int get _pdfFileCount =>
      _files.where((file) => _mobileFileTypeLabel(file) == 'PDF').length;

  String _formatStorageTotal() => _formatStorageTotalFromFiles(_files);

  String _mobileDateLabel(DateTime value) {
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
    return '${local.day.toString().padLeft(2, '0')} $month ${local.year}';
  }

  String _mobileFileTypeLabel(ChatFileInfoDto file) {
    final nameParts = file.fileName.split('.');
    final extension = nameParts.length > 1 ? nameParts.last.toUpperCase() : '';
    if (extension.isNotEmpty) return extension;
    if (file.contentType.contains('/')) {
      return file.contentType.split('/').last.toUpperCase();
    }
    return file.contentType.toUpperCase();
  }
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