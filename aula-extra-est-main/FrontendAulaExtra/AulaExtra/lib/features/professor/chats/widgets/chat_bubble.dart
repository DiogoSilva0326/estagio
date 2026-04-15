import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.timeLabel,
    required this.isMine,
    this.maxWidth,
    this.attachment,
    this.onAttachmentTap,
  });

  final String text;
  final String timeLabel;
  final bool isMine;
  final double? maxWidth;
  final RealtimeChatAttachment? attachment;
  final VoidCallback? onAttachmentTap;

  @override
  Widget build(BuildContext context) {
    final hasVisibleText =
        text.trim().isNotEmpty &&
        (attachment == null ||
            text.trim() != '[Ficheiro: ${attachment!.fileName}]');

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (isMine ? 430.47 : 348.294),
      ),
      padding: const EdgeInsets.only(left: 14.432, right: 14.432, top: 14.432),
      decoration: BoxDecoration(
        color: isMine ? null : ChatsProfessorColors.leftBubbleBackground,
        gradient: isMine
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ChatsProfessorColors.rightBubbleGradientStart,
                  ChatsProfessorColors.rightBubbleGradientEnd,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(14.432),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attachment != null)
            _AttachmentCard(
              attachment: attachment!,
              isMine: isMine,
              onTap: onAttachmentTap,
            ),
          if (attachment != null && hasVisibleText) const SizedBox(height: 10),
          if (hasVisibleText)
            Text(
              text,
              style: TextStyle(
                color: isMine
                    ? Colors.white
                    : ChatsProfessorColors.leftBubbleText,
                fontSize: ChatsProfessorFontSizes.message,
                fontWeight: FontWeight.w400,
                height: 24.053 / ChatsProfessorFontSizes.message,
              ),
            ),
          const SizedBox(height: 4.811),
          Text(
            timeLabel,
            style: TextStyle(
              color: isMine
                  ? Colors.white.withValues(alpha: 0.8)
                  : ChatsProfessorColors.mutedText,
              fontSize: ChatsProfessorFontSizes.messageTime,
              fontWeight: FontWeight.w400,
              height: 19.243 / ChatsProfessorFontSizes.messageTime,
            ),
          ),
          const SizedBox(height: 14.432),
        ],
      ),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({
    required this.attachment,
    required this.isMine,
    this.onTap,
  });

  final RealtimeChatAttachment attachment;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isMine
        ? Colors.white
        : ChatsProfessorColors.leftBubbleText;
    final secondary = isMine
        ? Colors.white.withValues(alpha: 0.8)
        : ChatsProfessorColors.mutedText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? Colors.white.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMine
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0xFFE5E7EB),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
