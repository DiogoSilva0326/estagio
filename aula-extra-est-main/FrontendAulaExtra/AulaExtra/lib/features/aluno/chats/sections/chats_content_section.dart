import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/aluno/chats/models/chat_bootstrap_args.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_card.dart';
import 'package:flutter/material.dart';

class ChatsContentSection extends StatelessWidget {
  const ChatsContentSection({super.key, this.initialChat});

  final ChatBootstrapArgs? initialChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ChatsConstants.horizontalPadding,
        vertical: ChatsConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 5),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 0),
                const Text('Chats', style: ChatsConstants.titleStyle),
                const SizedBox(height: 11.154),
                const Text(
                  'Converse com seus explicadores',
                  style: ChatsConstants.subtitleStyle,
                ),
                const SizedBox(height: 44.617),
                SizedBox(
                  height: 836.571,
                  width: double.infinity,
                  child: ChatsCard(initialChat: initialChat),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
