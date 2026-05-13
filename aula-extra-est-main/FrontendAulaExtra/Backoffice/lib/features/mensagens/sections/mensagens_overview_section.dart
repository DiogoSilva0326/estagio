import 'package:flutter/material.dart';

import '../models/mensagem_thread.dart';
import 'mensagens_chat_section.dart';
import 'mensagens_conversations_section.dart';
import 'mensagens_header_section.dart';

class MensagensOverviewSection extends StatelessWidget {
  const MensagensOverviewSection({
    required this.threads,
    required this.selectedType,
    required this.selectedThread,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSelectType,
    required this.onSelectThread,
    super.key,
  });

  final List<MensagemThread> threads;
  final MensagemThreadType? selectedType;
  final MensagemThread? selectedThread;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<MensagemThreadType?> onSelectType;
  final ValueChanged<MensagemThread> onSelectThread;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MensagensHeaderSection(),
        const SizedBox(height: 37.273),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 980) {
              return Column(
                children: [
                  MensagensConversationsSection(
                    threads: threads,
                    selectedType: selectedType,
                    selectedThreadId: selectedThread?.id,
                    searchController: searchController,
                    onSearchChanged: onSearchChanged,
                    onSelectType: onSelectType,
                    onSelectThread: onSelectThread,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 640,
                    child: MensagensChatSection(thread: selectedThread),
                  ),
                ],
              );
            }

            return SizedBox(
              height: 642,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 305,
                    child: MensagensConversationsSection(
                      threads: threads,
                      selectedType: selectedType,
                      selectedThreadId: selectedThread?.id,
                      searchController: searchController,
                      onSearchChanged: onSearchChanged,
                      onSelectType: onSelectType,
                      onSelectThread: onSelectThread,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: MensagensChatSection(thread: selectedThread)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
