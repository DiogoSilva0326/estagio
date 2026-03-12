import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class NotificacoesProfessorContentSection extends StatelessWidget {
  const NotificacoesProfessorContentSection({
    super.key,
  });

  static const int _unreadCount = 2;

  static const List<_NotificationData> _notifications = [
    _NotificationData(
      isUnread: true,
      iconBackground: NotificacoesProfessorColors.iconBlueBg,
      icon: Icons.calendar_month_rounded,
      title: 'Nova aula marcada',
      message: 'João Silva marcou uma aula de Matemática para amanhã às 14:30',
      timeAgo: '5 minutos atrás',
    ),
    _NotificationData(
      isUnread: true,
      iconBackground: NotificacoesProfessorColors.iconGreenBg,
      icon: Icons.payments_rounded,
      title: 'Pagamento recebido',
      message: 'Você recebeu 25€ pela aula com Maria Santos',
      timeAgo: '1 hora atrás',
    ),
    _NotificationData(
      isUnread: false,
      iconBackground: NotificacoesProfessorColors.iconPurpleBg,
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Nova mensagem',
      message: 'Pedro Costa enviou uma mensagem',
      timeAgo: '2 horas atrás',
    ),
    _NotificationData(
      isUnread: false,
      iconBackground: NotificacoesProfessorColors.iconYellowBg,
      icon: Icons.star_rounded,
      title: 'Nova avaliação',
      message: 'Ana Rodrigues deixou uma avaliação de 5 estrelas',
      timeAgo: '3 horas atrás',
    ),
    _NotificationData(
      isUnread: false,
      iconBackground: NotificacoesProfessorColors.iconBlueBg,
      icon: Icons.notifications_active_rounded,
      title: 'Lembrete de aula',
      message: 'Sua aula com Carlos Ferreira começa em 30 minutos',
      timeAgo: '5 horas atrás',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: NotificacoesProfessorColors.title,
      fontSize: NotificacoesProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height: NotificacoesProfessorLayout.titleLineHeight /
          NotificacoesProfessorLayout.titleFontSize,
    );

    final subtitleStyle = TextStyle(
      color: NotificacoesProfessorColors.subtitle,
      fontSize: NotificacoesProfessorLayout.subtitleFontSize,
      fontWeight: FontWeight.w400,
      height: NotificacoesProfessorLayout.subtitleLineHeight /
          NotificacoesProfessorLayout.subtitleFontSize,
    );

    return Container(
      color: NotificacoesProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: NotificacoesProfessorLayout.pageLeftPadding,
            right: NotificacoesProfessorLayout.pageRightPadding,
            top: NotificacoesProfessorLayout.pageTopPadding,
            bottom: NotificacoesProfessorLayout.pageBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(notificationCount: _unreadCount),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NotificacoesProfessorLayout.contentPadding,
                    NotificacoesProfessorLayout.contentPadding,
                    NotificacoesProfessorLayout.contentPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 420,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: NotificacoesProfessorLayout.titleLineHeight,
                                  child: Text('Notificações', style: titleStyle),
                                ),
                                SizedBox(
                                  height: NotificacoesProfessorLayout.subtitleLineHeight,
                                  child: Text(
                                    'Você tem $_unreadCount notificações não lidas',
                                    style: subtitleStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const _MarkAllAsReadButton(),
                        ],
                      ),
                      const SizedBox(height: 28.737),
                      Column(
                        children: [
                          for (final notification in _notifications) ...[
                            _NotificationCard(data: notification),
                            const SizedBox(height: NotificacoesProfessorLayout.cardsGap),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkAllAsReadButton extends StatelessWidget {
  const _MarkAllAsReadButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: NotificacoesProfessorLayout.markAllButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NotificacoesProfessorLayout.markAllButtonRadius),
          border: Border.all(
            color: NotificacoesProfessorColors.buttonBorder,
            width: NotificacoesProfessorLayout.markAllButtonBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(NotificacoesProfessorLayout.markAllButtonRadius),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.355),
            child: Center(
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(
                  color: NotificacoesProfessorColors.buttonText,
                  fontSize: NotificacoesProfessorLayout.bodyFontSize,
                  fontWeight: FontWeight.w500,
                  height: NotificacoesProfessorLayout.bodyLineHeight /
                      NotificacoesProfessorLayout.bodyFontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationData {
  const _NotificationData({
    required this.isUnread,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.message,
    required this.timeAgo,
  });

  final bool isUnread;
  final Color iconBackground;
  final IconData icon;
  final String title;
  final String message;
  final String timeAgo;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.data,
  });

  final _NotificationData data;

  @override
  Widget build(BuildContext context) {
    final borderColor = data.isUnread
        ? NotificacoesProfessorColors.unreadBorder
        : NotificacoesProfessorColors.readBorder;

    final borderRadius = BorderRadius.circular(NotificacoesProfessorLayout.cardRadius);

    return SizedBox(
      height: NotificacoesProfessorLayout.cardHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor,
            width: NotificacoesProfessorLayout.cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: NotificacoesProfessorLayout.shadowBlur1,
              offset: const Offset(0, 4.79),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: NotificacoesProfessorLayout.shadowBlur2,
              offset: const Offset(0, 2.395),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              if (data.isUnread)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: NotificacoesProfessorLayout.cardUnreadLeftBorderWidth,
                    color: NotificacoesProfessorColors.unreadAccent,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NotificacoesProfessorLayout.cardPaddingLeft,
                  NotificacoesProfessorLayout.cardPaddingTop,
                  NotificacoesProfessorLayout.cardPaddingRight,
                  NotificacoesProfessorLayout.cardBorderWidth,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IconCircle(background: data.iconBackground, icon: data.icon),
                    const SizedBox(width: NotificacoesProfessorLayout.rowGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: NotificacoesProfessorLayout.headingLineHeight,
                            child: Row(
                              children: [
                                Text(
                                  data.title,
                                  style: const TextStyle(
                                    color: NotificacoesProfessorColors.title,
                                    fontSize: NotificacoesProfessorLayout.headingFontSize,
                                    fontWeight: FontWeight.w500,
                                    height: NotificacoesProfessorLayout.headingLineHeight /
                                        NotificacoesProfessorLayout.headingFontSize,
                                  ),
                                ),
                                const Spacer(),
                                if (data.isUnread)
                                  Container(
                                    width: NotificacoesProfessorLayout.unreadDotSize,
                                    height: NotificacoesProfessorLayout.unreadDotSize,
                                    decoration: const BoxDecoration(
                                      color: NotificacoesProfessorColors.unreadAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4.79),
                          SizedBox(
                            height: NotificacoesProfessorLayout.bodyLineHeight,
                            child: Text(
                              data.message,
                              style: const TextStyle(
                                color: NotificacoesProfessorColors.subtitle,
                                fontSize: NotificacoesProfessorLayout.bodyFontSize,
                                fontWeight: FontWeight.w400,
                                height: NotificacoesProfessorLayout.bodyLineHeight /
                                    NotificacoesProfessorLayout.bodyFontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: NotificacoesProfessorLayout.timeLineHeight,
                            child: Text(
                              data.timeAgo,
                              style: const TextStyle(
                                color: NotificacoesProfessorColors.timeText,
                                fontSize: NotificacoesProfessorLayout.timeFontSize,
                                fontWeight: FontWeight.w400,
                                height: NotificacoesProfessorLayout.timeLineHeight /
                                    NotificacoesProfessorLayout.timeFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: NotificacoesProfessorLayout.rowGap),
                    _ActionButton(isUnread: data.isUnread),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.background,
    required this.icon,
  });

  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NotificacoesProfessorLayout.iconCircleSize,
      height: NotificacoesProfessorLayout.iconCircleSize,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: NotificacoesProfessorLayout.iconSize,
        color: NotificacoesProfessorColors.title,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isUnread,
  });

  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: NotificacoesProfessorLayout.actionButtonSize,
      height: NotificacoesProfessorLayout.actionButtonSize,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(NotificacoesProfessorLayout.actionButtonRadius),
        child: Center(
          child: Icon(
            isUnread ? Icons.more_horiz_rounded : Icons.more_vert_rounded,
            size: NotificacoesProfessorLayout.actionIconSize,
            color: NotificacoesProfessorColors.title,
          ),
        ),
      ),
    );
  }
}
