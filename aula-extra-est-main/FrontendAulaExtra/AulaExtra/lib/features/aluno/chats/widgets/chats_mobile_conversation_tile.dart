import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_avatar.dart';
import 'package:flutter/material.dart';

class ChatsMobileConversationTile extends StatelessWidget {
  const ChatsMobileConversationTile({
    super.key,
    required this.initials,
    required this.avatarColor,
    this.photoUrl,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusBackgroundColor,
    required this.statusTextColor,
    this.onTap,
  });

  final String initials;
  final Color avatarColor;
  final String? photoUrl;
  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusBackgroundColor;
  final Color statusTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ChatsConstants.mobileCardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ChatsConstants.mobileSurfaceColor,
            borderRadius: BorderRadius.circular(
              ChatsConstants.mobileCardRadius,
            ),
            border: Border.all(color: ChatsConstants.mobileBorderColor),
            boxShadow: ChatsConstants.mobileShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChatsMobileAvatar(
                photoUrl: photoUrl,
                name: title,
                initials: initials,
                size: 52,
                backgroundColor: avatarColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ChatsConstants.mobileCardTitleStyle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLabel,
                            style: ChatsConstants.mobileStatusStyle.copyWith(
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ChatsConstants.mobileBodyStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: ChatsConstants.mobileMutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
