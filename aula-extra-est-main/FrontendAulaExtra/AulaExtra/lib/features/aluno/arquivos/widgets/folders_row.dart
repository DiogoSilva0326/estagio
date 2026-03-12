import 'package:aula_extra/features/aluno/arquivos/widgets/folder_card.dart';
import 'package:flutter/material.dart';

class FoldersRow extends StatelessWidget {
  const FoldersRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: FolderCard(
            color: Color(0xFF2B7FFF),
            icon: Icons.functions_rounded,
            title: 'Matemática - João Silva',
            subtitle: '12 arquivos',
          ),
        ),
        SizedBox(width: 22.292),
        Expanded(
          child: FolderCard(
            color: Color(0xFF00C950),
            icon: Icons.science_rounded,
            title: 'Física - Maria Santos',
            subtitle: '8 arquivos',
          ),
        ),
        SizedBox(width: 22.292),
        Expanded(
          child: FolderCard(
            color: Color(0xFFFF6900),
            icon: Icons.language_rounded,
            title: 'Inglês - Pedro Costa',
            subtitle: '15 arquivos',
          ),
        ),
      ],
    );
  }
}
