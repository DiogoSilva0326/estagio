import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:flutter/material.dart';

class RecentFilesTableCard extends StatelessWidget {
  const RecentFilesTableCard({
    super.key,
    required this.files,
    required this.onDownloadTap,
    required this.onDeleteTap,
  });

  final List<ChatFileInfoDto> files;
  final ValueChanged<ChatFileInfoDto> onDownloadTap;
  final ValueChanged<ChatFileInfoDto> onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.393),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.292),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.393),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.393),
            blurRadius: 4.18,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.393),
            blurRadius: 2.786,
            spreadRadius: -1.393,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.9),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 990.662,
            child: Column(
              children: [
                const _TableHeaderRow(),
                for (int i = 0; i < files.length; i++)
                  _FileRow(
                    data: files[i],
                    hasBottomBorder: i != files.length - 1,
                    onDownloadTap: () => onDownloadTap(files[i]),
                    onDeleteTap: () => onDeleteTap(files[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.426,
      color: const Color(0xFFF9FAFB),
      child: const Row(
        children: [
          _HeaderCell(width: 397.978, text: 'NOME'),
          _HeaderCell(width: 127.221, text: 'TUTOR'),
          _HeaderCell(width: 111.699, text: 'SUBMISSÃO'),
          _HeaderCell(width: 154.465, text: 'TAMANHO'),
          _HeaderCell(width: 199.299, text: 'AÇÕES'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.text});

  final double width;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 33.44),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.719,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A5565),
          letterSpacing: 0.8359,
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.data,
    required this.hasBottomBorder,
    required this.onDownloadTap,
    required this.onDeleteTap,
  });

  final ChatFileInfoDto data;
  final bool hasBottomBorder;
  final VoidCallback onDownloadTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 129.572,
      decoration: BoxDecoration(
        border: Border(
          bottom: hasBottomBorder
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 1.393)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 397.978,
            child: Padding(
              padding: const EdgeInsets.only(left: 33.44),
              child: Row(
                children: [
                  Container(
                    width: 55.73,
                    height: 55.73,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(13.932),
                    ),
                    child: Center(
                      child: Icon(
                        _fileIconFor(data.contentType),
                        size: 27.865,
                        color: const Color(0xFF101828),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.719),
                  Expanded(
                    child: SizedBox(
                      height: 55.73,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22.292,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF101828),
                              height: 33.438 / 22.292,
                            ),
                          ),
                          Text(
                            _fileTypeLabel(data.contentType),
                            style: const TextStyle(
                              fontSize: 16.719,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6A7282),
                              height: 22.292 / 16.719,
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
          _BodyCell(width: 127.221, text: data.uploadedByDisplayName),
          _BodyCell(width: 111.699, text: _formatDate(data.createdAt)),
          _BodyCell(
            width: 154.465,
            text: _formatFileSize(data.fileSizeBytes),
            alignCenterVertically: true,
          ),
          SizedBox(
            width: 199.299,
            child: Padding(
              padding: const EdgeInsets.only(left: 33.44),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _DownloadButton(onTap: onDownloadTap),
                    const SizedBox(width: 8),
                    _DeleteButton(onTap: onDeleteTap),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _fileIconFor(String contentType) {
  final normalized = contentType.toLowerCase();
  if (normalized.contains('pdf')) return Icons.picture_as_pdf_rounded;
  if (normalized.contains('image')) return Icons.image_rounded;
  if (normalized.contains('presentation') ||
      normalized.contains('powerpoint')) {
    return Icons.slideshow_rounded;
  }
  if (normalized.contains('sheet') ||
      normalized.contains('excel') ||
      normalized.contains('csv')) {
    return Icons.table_chart_rounded;
  }
  if (normalized.contains('audio')) return Icons.audio_file_rounded;
  if (normalized.contains('video')) return Icons.video_file_rounded;
  return Icons.description_rounded;
}

String _fileTypeLabel(String contentType) {
  final normalized = contentType.toLowerCase();
  if (normalized.contains('pdf')) {
    return 'PDF';
  }
  if (normalized.contains('image')) {
    return 'Imagem';
  }
  if (normalized.contains('presentation') ||
      normalized.contains('powerpoint')) {
    return 'Apresentação';
  }
  if (normalized.contains('sheet') ||
      normalized.contains('excel') ||
      normalized.contains('csv')) {
    return 'Folha de cálculo';
  }
  if (normalized.contains('audio')) {
    return 'Áudio';
  }
  if (normalized.contains('video')) {
    return 'Vídeo';
  }
  if (normalized.contains('word') ||
      normalized.contains('document') ||
      normalized.contains('text')) {
    return 'Documento';
  }
  return 'Ficheiro';
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/$year\n$hour:$minute';
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

class _BodyCell extends StatelessWidget {
  const _BodyCell({
    required this.width,
    required this.text,
    this.alignCenterVertically = false,
  });

  final double width;
  final String text;
  final bool alignCenterVertically;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(left: 33.44),
        child: Align(
          alignment: alignCenterVertically
              ? Alignment.centerLeft
              : Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: alignCenterVertically ? 0 : 36.22),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 19.505,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A5565),
                height: 27.865 / 19.505,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.157,
      width: 132.424,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.932),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 22.292),
            child: Row(
              children: const [
                Icon(
                  Icons.download_rounded,
                  size: 22.292,
                  color: Color(0xFF364153),
                ),
                SizedBox(width: 16.719),
                Text(
                  'Baixar',
                  style: TextStyle(
                    fontSize: 19.505,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF364153),
                    height: 27.865 / 19.505,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.157,
      width: 50.157,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.932),
          onTap: onTap,
          child: const Center(
            child: Icon(
              Icons.delete_outline_rounded,
              size: 22.292,
              color: Color(0xFFB42318),
            ),
          ),
        ),
      ),
    );
  }
}
