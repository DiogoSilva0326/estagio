import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/features/aluno/chats/widgets/chats_mobile_avatar.dart';
import 'package:flutter/material.dart';

class ChatsMobileConversationHeader extends StatelessWidget {
  const ChatsMobileConversationHeader({
    super.key,
    required this.name,
    required this.username,
    required this.photoUrl,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
    required this.onBackTap,
  });

  final String name;
  final String username;
  final String? photoUrl;
  final String initials;
  final Color avatarColor;
  final bool isOnline;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: ChatsConstants.mobileSurfaceColor,
        border: Border(
          bottom: BorderSide(color: ChatsConstants.mobileBorderColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          ChatsMobileAvatar(
            name: name,
            initials: initials,
            size: 48,
            photoUrl: photoUrl,
            backgroundColor: avatarColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ChatsConstants.mobileCardTitleStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Online · @$username' : '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ChatsConstants.mobileBodyStyle.copyWith(
                    color: isOnline
                        ? ChatsConstants.mobileSuccessColor
                        : ChatsConstants.mobileMutedColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
