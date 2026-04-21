import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:flutter/material.dart';

class ChatsMobileSearchBar extends StatelessWidget {
  const ChatsMobileSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ChatsConstants.mobileBorderColor),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: ChatsConstants.mobileMutedColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar conversa...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ChatsConstants.mobileMutedColor,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
