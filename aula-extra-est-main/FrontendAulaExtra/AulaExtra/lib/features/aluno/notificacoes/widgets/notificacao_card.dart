import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_mock_data.dart';
import 'package:flutter/material.dart';

class NotificacaoCard extends StatelessWidget {
  const NotificacaoCard({
    super.key,
    required this.item,
    required this.onMarkAsRead,
  });

  final NotificacaoItem item;
  final VoidCallback? onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final showMarkRead = item.unread && onMarkAsRead != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(29.514, 29.514, 29.514, 29.514),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NotificacoesConstants.cardRadius),
        border: Border.all(
          color: item.unread ? const Color(0xFFFFD6A7) : const Color(0xFFF3F4F6),
          width: NotificacoesConstants.borderWidth,
        ),
        boxShadow: NotificacoesConstants.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 67.459,
            height: 67.459,
            decoration: BoxDecoration(
              color: item.iconBackground,
              borderRadius: BorderRadius.circular(19.676),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, color: Colors.white, size: 33.73),
          ),
          const SizedBox(width: 22.486),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22.486,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF101828),
                          height: 33.73 / 22.486,
                        ),
                      ),
                    ),
                    if (item.unread)
                      Container(
                        width: 11.243,
                        height: 11.243,
                        decoration: const BoxDecoration(
                          color: NotificacoesConstants.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5.622),
                Text(
                  item.message,
                  style: const TextStyle(
                    fontSize: 19.676,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A5565),
                    height: 28.108 / 19.676,
                  ),
                ),
                const SizedBox(height: 5.622),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.timeLabel,
                      style: const TextStyle(
                        fontSize: 16.865,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6A7282),
                        height: 22.486 / 16.865,
                      ),
                    ),
                    if (showMarkRead)
                      InkWell(
                        onTap: onMarkAsRead,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            'Marcar como lida',
                            style: TextStyle(
                              fontSize: 16.865,
                              fontWeight: FontWeight.w400,
                              color: NotificacoesConstants.orange,
                              height: 22.486 / 16.865,
                            ),
                          ),
                        ),
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
