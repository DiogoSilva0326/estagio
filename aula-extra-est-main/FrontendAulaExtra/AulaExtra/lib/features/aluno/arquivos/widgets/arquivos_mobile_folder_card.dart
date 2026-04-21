import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:flutter/material.dart';

class ArquivosMobileFolderCard extends StatelessWidget {
  const ArquivosMobileFolderCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ArquivosConstants.mobileCardTitleStyle,
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: ArquivosConstants.mobileBodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
