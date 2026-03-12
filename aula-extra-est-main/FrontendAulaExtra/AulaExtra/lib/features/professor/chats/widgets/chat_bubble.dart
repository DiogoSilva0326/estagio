import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.timeLabel,
    required this.isMine,
    this.maxWidth,
  });

  final String text;
  final String timeLabel;
  final bool isMine;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth ?? (isMine ? 430.47 : 348.294)),
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
          Text(
            text,
            style: TextStyle(
              color: isMine ? Colors.white : ChatsProfessorColors.leftBubbleText,
              fontSize: ChatsProfessorFontSizes.message,
              fontWeight: FontWeight.w400,
              height: 24.053 / ChatsProfessorFontSizes.message,
            ),
          ),
          const SizedBox(height: 4.811),
          Text(
            timeLabel,
            style: TextStyle(
              color: isMine ? Colors.white.withValues(alpha: 0.8) : ChatsProfessorColors.mutedText,
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
