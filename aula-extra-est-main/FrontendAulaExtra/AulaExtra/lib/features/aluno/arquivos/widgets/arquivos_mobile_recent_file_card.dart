import 'package:aula_extra/core/data/communication/dtos/chat_file_info_dto.dart';
import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:flutter/material.dart';

class ArquivosMobileRecentFileCard extends StatelessWidget {
  const ArquivosMobileRecentFileCard({
    super.key,
    required this.file,
    required this.onDownloadTap,
    required this.fileTypeLabel,
    required this.fileSizeLabel,
    required this.formattedDate,
    required this.fileIcon,
  });

  final ChatFileInfoDto file;
  final VoidCallback onDownloadTap;
  final String fileTypeLabel;
  final String fileSizeLabel;
  final String formattedDate;
  final IconData fileIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArquivosConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(ArquivosConstants.mobileCardRadius),
        border: Border.all(color: ArquivosConstants.mobileBorderColor),
        boxShadow: ArquivosConstants.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                child: Icon(
                  fileIcon,
                  size: 20,
                  color: ArquivosConstants.mobileTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ArquivosConstants.mobileCardTitleStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileTypeLabel,
                      style: ArquivosConstants.mobileBodyStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetaItem(
                  label: 'Tutor',
                  value: file.uploadedByDisplayName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetaItem(label: 'Data', value: formattedDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetaItem(label: 'Tamanho', value: fileSizeLabel),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onDownloadTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: ArquivosConstants.mobileBorderColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.download_rounded,
                size: 16,
                color: ArquivosConstants.mobileTextColor,
              ),
              label: const Text(
                'Baixar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ArquivosConstants.mobileTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ArquivosConstants.mobileMetaLabelStyle),
        const SizedBox(height: 4),
        Text(value, style: ArquivosConstants.mobileMetaValueStyle),
      ],
    );
  }
}
