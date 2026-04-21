import 'package:flutter/material.dart';

class ArquivosProfessorMobileFileCard extends StatelessWidget {
  const ArquivosProfessorMobileFileCard({
    super.key,
    required this.fileName,
    required this.fileTypeLabel,
    required this.ownerLabel,
    required this.dateLabel,
    required this.sizeLabel,
    required this.onShareTap,
    required this.onDownloadTap,
    this.onDeleteTap,
  });

  final String fileName;
  final String fileTypeLabel;
  final String ownerLabel;
  final String dateLabel;
  final String sizeLabel;
  final VoidCallback onShareTap;
  final VoidCallback onDownloadTap;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 0.69),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 20,
                color: Color(0xFF98A2B3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF101828),
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileTypeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6A7282),
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDeleteTap != null)
                InkWell(
                  onTap: onDeleteTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Color(0xFFFB2C36),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetaItem(label: 'Tutor:', value: ownerLabel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaItem(label: 'Data:', value: dateLabel),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MetaItem(label: 'Tamanho:', value: sizeLabel),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PrimaryActionButton(
                  icon: Icons.share_outlined,
                  label: 'Partilhar',
                  onTap: onShareTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PrimaryActionButton(
                  icon: Icons.download_rounded,
                  label: 'Baixar',
                  onTap: onDownloadTap,
                ),
              ),
            ],
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6A7282),
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF101828),
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFF6900),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 20 / 14,
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
