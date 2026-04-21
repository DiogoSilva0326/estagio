import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:flutter/material.dart';

class ChatsMobileAvatar extends StatelessWidget {
  const ChatsMobileAvatar({
    super.key,
    required this.name,
    required this.initials,
    required this.size,
    this.photoUrl,
    this.backgroundColor = ChatsConstants.mobileAvatarFallbackColor,
  });

  final String name;
  final String initials;
  final double size;
  final String? photoUrl;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = photoUrl?.trim();
    final hasPhoto = normalizedUrl != null && normalizedUrl.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF2F4F7), width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _FallbackAvatar(
                  name: name,
                  initials: initials,
                  backgroundColor: backgroundColor,
                ),
              )
            : _FallbackAvatar(
                name: name,
                initials: initials,
                backgroundColor: backgroundColor,
              ),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({
    required this.name,
    required this.initials,
    required this.backgroundColor,
  });

  final String name;
  final String initials;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final text = initials.trim().isNotEmpty
        ? initials.trim().toUpperCase()
        : (name.isNotEmpty ? name.characters.first.toUpperCase() : '?');

    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: text.length > 1 ? 15 : 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
