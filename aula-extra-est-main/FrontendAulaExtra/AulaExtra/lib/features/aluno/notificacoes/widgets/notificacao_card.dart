import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:flutter/material.dart';

class NotificacaoCard extends StatelessWidget {
  const NotificacaoCard({
    super.key,
    required this.item,
    required this.onMarkAsRead,
    this.onPrimaryAction,
    this.primaryActionLabel,
    this.isMobile = false,
  });

  final UserNotificationDto item;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionLabel;
  final bool isMobile;

  String _timeLabel() {
    final when = item.effectiveDate;
    if (when == null) {
      return 'Agora';
    }

    final diff = DateTime.now().difference(when.toLocal());
    if (diff.inMinutes <= 1) return 'Agora';
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return 'Há ${diff.inHours} hora${diff.inHours == 1 ? '' : 's'}';
    }
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
    return '${when.day.toString().padLeft(2, '0')}/${when.month.toString().padLeft(2, '0')}/${when.year}';
  }

  @override
  Widget build(BuildContext context) {
    final showMarkRead = item.unread && onMarkAsRead != null;
    final showPrimaryAction =
        item.unread &&
        onPrimaryAction != null &&
        (primaryActionLabel?.trim().isNotEmpty ?? false);
    final containerPadding = isMobile
        ? const EdgeInsets.fromLTRB(16, 16, 16, 16)
        : const EdgeInsets.fromLTRB(29.514, 29.514, 29.514, 29.514);
    final iconSize = isMobile ? 48.0 : 67.459;
    final iconRadius = isMobile ? 14.0 : 19.676;
    final iconGlyphSize = isMobile ? 24.0 : 33.73;
    final titleStyle = TextStyle(
      fontSize: isMobile ? 16 : 22.486,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF101828),
      height: isMobile ? 1.35 : 33.73 / 22.486,
    );
    final messageStyle = TextStyle(
      fontSize: isMobile ? 13 : 19.676,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF4A5565),
      height: isMobile ? 1.45 : 28.108 / 19.676,
    );
    final metadataStyle = TextStyle(
      fontSize: isMobile ? 12 : 16.865,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF6A7282),
      height: isMobile ? 1.35 : 22.486 / 16.865,
    );
    final actionStyle = TextStyle(
      fontSize: isMobile ? 12 : 16.865,
      fontWeight: isMobile ? FontWeight.w600 : FontWeight.w400,
      color: NotificacoesConstants.orange,
      height: isMobile ? 1.35 : 22.486 / 16.865,
    );

    return Container(
      width: double.infinity,
      padding: containerPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          isMobile
              ? NotificacoesConstants.mobileCardRadius
              : NotificacoesConstants.cardRadius,
        ),
        border: Border.all(
          color: item.unread
              ? const Color(0xFFFFD6A7)
              : const Color(0xFFF3F4F6),
          width: NotificacoesConstants.borderWidth,
        ),
        boxShadow: NotificacoesConstants.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: item.iconBackground,
              borderRadius: BorderRadius.circular(iconRadius),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: Colors.white, size: iconGlyphSize),
          ),
          SizedBox(width: isMobile ? 12 : 22.486),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(item.title, style: titleStyle)),
                    if (item.unread)
                      Container(
                        width: isMobile ? 10 : 11.243,
                        height: isMobile ? 10 : 11.243,
                        decoration: const BoxDecoration(
                          color: NotificacoesConstants.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 5.622),
                Text(item.displayMessage, style: messageStyle),
                SizedBox(height: isMobile ? 10 : 5.622),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(_timeLabel(), style: metadataStyle),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (showPrimaryAction)
                          InkWell(
                            onTap: onPrimaryAction,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                primaryActionLabel!,
                                style: actionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        if (showMarkRead)
                          InkWell(
                            onTap: onMarkAsRead,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Text(
                                'Marcar como lida',
                                style: actionStyle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
