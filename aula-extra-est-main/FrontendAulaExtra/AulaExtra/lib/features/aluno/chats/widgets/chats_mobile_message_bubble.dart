import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

class ChatsMobileMessageBubble extends StatelessWidget {
  const ChatsMobileMessageBubble({
    super.key,
    required this.text,
    required this.timeLabel,
    required this.isOutgoing,
    required this.isRead,
    required this.attachment,
    required this.onOpenAttachment,
  });

  final String text;
  final String timeLabel;
  final bool isOutgoing;
  final bool isRead;
  final RealtimeChatAttachment? attachment;
  final ValueChanged<String> onOpenAttachment;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final isStudent = userProvider.role == Role.student;
    
    final isOrange = isStudent || config.roleName == 'Explicador';

    final backgroundColor = isOutgoing
        ? (isOrange ? ChatsConstants.mobileBubbleOutgoingColor : config.primaryColor) 
        : ChatsConstants.mobileBubbleIncomingColor;
        
    final textColor = isOutgoing
        ? Colors.white
        : ChatsConstants.mobileTextColor;
        
    final secondaryColor = isOutgoing
        ? Colors.white.withOpacity(0.85)
        : ChatsConstants.mobileMutedColor;

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: isOutgoing
              ? null
              : Border.all(
                  color: ChatsConstants.mobileBubbleIncomingBorderColor,
                ),
          boxShadow: isOutgoing ? null : ChatsConstants.mobileShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (attachment != null)
              _AttachmentCard(
                attachment: attachment!,
                isOutgoing: isOutgoing,
                onTap: () => onOpenAttachment(attachment!.downloadUrl),
              ),
            if (attachment != null && text.trim().isNotEmpty)
              const SizedBox(height: 10),
            if (text.trim().isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 22 / 15,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: secondaryColor,
                  ),
                ),
                if (isOutgoing) ...[
                  const SizedBox(width: 6),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 14,
                    color: secondaryColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({
    required this.attachment,
    required this.isOutgoing,
    required this.onTap,
  });

  final RealtimeChatAttachment attachment;
  final bool isOutgoing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isOutgoing
        ? Colors.white
        : ChatsConstants.mobileTextColor;
    final secondary = isOutgoing
        ? Colors.white.withOpacity(0.8)
        : ChatsConstants.mobileMutedColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutgoing
              ? Colors.white.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOutgoing
                ? Colors.white.withOpacity(0.22)
                : ChatsConstants.mobileBorderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file_rounded, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(attachment.fileSize),
                    style: TextStyle(color: secondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.download_rounded, color: foreground),
          ],
        ),
      ),
    );
  }
}

String _formatFileSize(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  final decimals = size >= 10 || unitIndex == 0 ? 0 : 1;
  return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
}