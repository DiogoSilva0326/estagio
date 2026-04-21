import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:flutter/material.dart';

class ChatsMobileComposer extends StatelessWidget {
  const ChatsMobileComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.isSendingFile,
    required this.onSend,
    required this.onPickFile,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final bool isSendingFile;
  final VoidCallback onSend;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: ChatsConstants.mobileComposerBackgroundColor,
          border: Border(
            top: BorderSide(color: ChatsConstants.mobileBorderColor),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: enabled && !isSendingFile ? onPickFile : null,
              icon: isSendingFile
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.attach_file_rounded),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: ChatsConstants.mobileComposerHintColor,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: ChatsConstants.mobileSoftSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 46,
              height: 46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ChatsConstants.orangeGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? onSend : null,
                    borderRadius: BorderRadius.circular(14),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
