import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/mensagem_thread.dart';
import '../widgets/mensagens_filter_chip.dart';
import '../widgets/mensagens_search_field.dart';
import '../widgets/mensagem_thread_tile.dart';

class MensagensConversationsSection extends StatelessWidget {
  const MensagensConversationsSection({
    required this.threads,
    required this.selectedType,
    required this.selectedThreadId,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSelectType,
    required this.onSelectThread,
    super.key,
  });

  final List<MensagemThread> threads;
  final MensagemThreadType? selectedType;
  final String? selectedThreadId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<MensagemThreadType?> onSelectType;
  final ValueChanged<MensagemThread> onSelectThread;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(27.955, 27.955, 27.955, 18.637),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MensagensSearchField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: 18.637),
                Wrap(
                  spacing: 9.318,
                  runSpacing: 9.318,
                  children: [
                    MensagensFilterChip(
                      label: 'Todas',
                      selected: selectedType == null,
                      onTap: () => onSelectType(null),
                    ),
                    MensagensFilterChip(
                      label: 'Aluno-Explicador',
                      selected:
                          selectedType == MensagemThreadType.alunoExplicador,
                      onTap: () =>
                          onSelectType(MensagemThreadType.alunoExplicador),
                    ),
                    MensagensFilterChip(
                      label: 'Suporte',
                      selected: selectedType == MensagemThreadType.suporte,
                      onTap: () => onSelectType(MensagemThreadType.suporte),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          if (threads.isEmpty)
            const Padding(
              padding: EdgeInsets.all(27.955),
              child: Text(
                'Sem conversas que correspondam aos filtros atuais.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15.143,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            for (final thread in threads)
              MensagemThreadTile(
                thread: thread,
                selected: thread.id == selectedThreadId,
                onTap: () => onSelectThread(thread),
              ),
        ],
      ),
    );
  }
}
