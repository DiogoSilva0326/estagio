import 'package:aula_extra/features/professor/chats/constants/chats_professor_colors.dart';
import 'package:aula_extra/features/professor/chats/constants/chats_professor_font_sizes.dart';
import 'package:flutter/material.dart';

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ChatsProfessorColors.avatarGradientStart,
            ChatsProfessorColors.avatarGradientEnd,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: ChatsProfessorFontSizes.avatarInitials,
          fontWeight: FontWeight.w500,
          height: 28.864 / ChatsProfessorFontSizes.avatarInitials,
        ),
      ),
    );
  }
}
