import 'package:aula_extra/features/aluno/arquivos/widgets/folder_card.dart';
import 'package:flutter/material.dart';
import 'package:aula_extra/features/aluno/arquivos/sections/arquivos_content_section.dart';

class FoldersRow extends StatelessWidget {
  const FoldersRow({
    super.key,
    required this.folders,
  });

  final List<MobileFolderDisplayData> folders;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: List.generate(folders.length, (index) {
          final folder = folders[index];
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < folders.length - 1 ? 24.0 : 0, 
              ),
              child: FolderCard(
                color: folder.color,
                icon: folder.icon,
                title: folder.title,
                subtitle: folder.subtitle,
              ),
            ),
          );
        }),
      ),
    );
  }
}