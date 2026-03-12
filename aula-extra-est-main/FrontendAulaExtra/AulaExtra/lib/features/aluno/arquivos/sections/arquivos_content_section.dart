import 'package:flutter/material.dart';

import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/folders_row.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/recent_files_table_card.dart';
import 'package:aula_extra/features/aluno/arquivos/widgets/search_and_upload_row.dart';

class ArquivosContentSection extends StatelessWidget {
  const ArquivosContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ArquivosConstants.horizontalPadding,
        vertical: ArquivosConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 4),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arquivos',
                  style: ArquivosConstants.titleStyle,
                ),
                const SizedBox(height: ArquivosConstants.gapSmall),
                const Text(
                  'Gerencie seus documentos e materiais de estudo',
                  style: ArquivosConstants.subtitleStyle,
                ),
                const SizedBox(height: ArquivosConstants.gapLarge),
                const SearchAndUploadRow(),
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
                const RecentFilesTableCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
