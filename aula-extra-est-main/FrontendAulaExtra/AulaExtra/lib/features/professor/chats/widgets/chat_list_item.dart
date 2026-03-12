import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_avatar.dart';
import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.initials,
    required this.name,
    required this.timeLabel,
    required this.preview,
    this.unreadCount,
    this.selected = false,
    this.onTap,
  });

  final String initials;
  final String name;
  final String timeLabel;
  final String preview;
  final int? unreadCount;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? ChatsProfessorColors.chatListSelectedBackground
        : ChatsProfessorColors.cardBackground;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 97.416,
        padding: const EdgeInsets.only(left: 19.243, right: 19.243, bottom: 1.203),
        decoration: BoxDecoration(
          color: background,
          border: const Border(
            bottom: BorderSide(color: ChatsProfessorColors.divider, width: 1.203),
          ),
        ),
        child: Row(
          children: [
            ChatAvatar(initials: initials, size: 57.728),
            const SizedBox(width: 14.432),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ChatsProfessorColors.title,
                              fontSize: ChatsProfessorFontSizes.listName,
                              fontWeight: FontWeight.w500,
                              height: 28.864 / ChatsProfessorFontSizes.listName,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            color: ChatsProfessorColors.mutedText,
                            fontSize: ChatsProfessorFontSizes.listTime,
                            fontWeight: FontWeight.w500,
                            height: 19.243 / ChatsProfessorFontSizes.listTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.811),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ChatsProfessorColors.mutedText,
                              fontSize: ChatsProfessorFontSizes.listPreview,
                              fontWeight: FontWeight.w500,
                              height: 24.053 / ChatsProfessorFontSizes.listPreview,
                            ),
                          ),
                        ),
                        if (unreadCount != null && unreadCount! > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            height: 24.053,
                            constraints: const BoxConstraints(minWidth: 27.455),
                            padding: const EdgeInsets.symmetric(horizontal: 9.621, vertical: 2.405),
                            decoration: BoxDecoration(
                              color: ChatsProfessorColors.unreadBadgeBackground,
                              borderRadius: BorderRadius.circular(16.837),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${unreadCount!}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: ChatsProfessorFontSizes.badge,
                                fontWeight: FontWeight.w500,
                                height: 19.243 / ChatsProfessorFontSizes.badge,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
