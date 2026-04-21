import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_avatar.dart';
import 'package:flutter/material.dart';

class ChatsProfessorMobileConversationTile extends StatelessWidget {
  const ChatsProfessorMobileConversationTile({
    super.key,
    required this.initials,
    required this.name,
    required this.timeLabel,
    required this.preview,
    this.unreadCount,
    this.selected = false,
    this.showDivider = true,
    this.onTap,
  });

  final String initials;
  final String name;
  final String timeLabel;
  final String preview;
  final int? unreadCount;
  final bool selected;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(17),
          bottom: Radius.circular(showDivider ? 0 : 17),
        ),
        child: Container(
          height: 86.6,
          padding: const EdgeInsets.symmetric(horizontal: 17.1),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF7ED) : Colors.white,
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  )
                : null,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(17),
              bottom: Radius.circular(showDivider ? 0 : 17),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox.shrink(),
                  ChatAvatar(initials: initials, size: 51.31),
                  if (unreadCount != null && unreadCount! > 0)
                    Positioned(
                      top: -4.28,
                      right: -4.28,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 21.38,
                          minHeight: 21.38,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(
                          color: ChatsProfessorColors.unreadBadgeBackground,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${unreadCount!}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.83,
                            fontWeight: FontWeight.w500,
                            height: 17.1 / 12.83,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12.83),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17.1,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF101828),
                              height: 25.65 / 17.1,
                            ),
                          ),
                        ),
                        if (timeLabel.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 12.83,
                              fontWeight: FontWeight.w400,
                              color: ChatsProfessorColors.mutedText,
                              height: 17.1 / 12.83,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4.28),
                    Text(
                      preview.trim().isEmpty ? 'Inicie a conversa...' : preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.97,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                        height: 21.38 / 14.97,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
