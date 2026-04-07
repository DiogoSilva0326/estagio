import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/notificacoes/constants/notificacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/notificacoes/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class _NotificationData {
  const _NotificationData({
    required this.id,
    required this.isUnread,
    required this.iconBackground,
    required this.icon,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.date, 
  });

  final String id;
  final bool isUnread;
  final Color iconBackground;
  final IconData icon;
  final String title;
  final String message;
  final String timeAgo;
  final DateTime date;
}

class NotificacoesProfessorContentSection extends StatefulWidget {
  const NotificacoesProfessorContentSection({super.key});

  @override
  State<NotificacoesProfessorContentSection> createState() => _NotificacoesProfessorContentSectionState();
}

class _NotificacoesProfessorContentSectionState extends State<NotificacoesProfessorContentSection> {
  List<_NotificationData> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotificacoes();
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  String _extrairIdDoToken(String token) {
    try {
      final payloadBase64 = token.split('.')[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      return payloadMap['sub']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _calcularTempoAtras(DateTime data) {
    final diferenca = DateTime.now().difference(data);
    if (diferenca.inMinutes < 1) return 'Agora mesmo';
    if (diferenca.inMinutes < 60) return 'Há ${diferenca.inMinutes} min';
    if (diferenca.inHours < 24) return 'Há ${diferenca.inHours} horas';
    if (diferenca.inDays == 1) return 'Ontem';
    return 'Há ${diferenca.inDays} dias';
  }

  Future<void> _fetchNotificacoes() async {
    setState(() => _isLoading = true);
    try {
      final token = await TokenStorage().loadToken() ?? '';
      final myUserId = _extrairIdDoToken(token);

      final response = await http.get(
        ApiConfig.uri('/api/Communication/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        final notificacoesTemporarias = <_NotificationData>[];

        for (var n in dados) {
          final idUserNotif = (n['idUser'] ?? n['IdUser'])?.toString().toLowerCase();
          
          if (idUserNotif == myUserId.toLowerCase()) {
            final isUnread = !(n['wasRead'] ?? n['WasRead'] ?? true);
            final tipoString = (n['type'] ?? n['Type'])?.toString() ?? '';
            final msgString = (n['message'] ?? n['Message'])?.toString() ?? '';
            final createdAtStr = n['createdAt'] ?? n['CreatedAt'];
            final idNotif = (n['idNotification'] ?? n['IdNotification']).toString();
            
            DateTime dataCriacao = DateTime.now();
            if (createdAtStr != null) {
              dataCriacao = DateTime.parse(createdAtStr.toString()).toLocal();
            }

            IconData icone = Icons.notifications_active_rounded;
            Color iconBg = NotificacoesProfessorColors.iconBlueBg; 

            final tLower = tipoString.toLowerCase();
            
            // 💡 RECONHECE O ESTADO DA RESPOSTA E MUDA A COR!
            if (tLower.contains('confirmada')) {
              icone = Icons.check_circle_outline;
              iconBg = NotificacoesProfessorColors.iconGreenBg; 
            } else if (tLower.contains('recusada') || tLower.contains('cancelada')) {
              icone = Icons.cancel_outlined;
              iconBg = const Color(0xFFF04438); // Vermelho
            } else if (tLower.contains('pagamento')) {
              icone = Icons.payments_rounded;
              iconBg = NotificacoesProfessorColors.iconGreenBg; 
            } else if (tLower.contains('mensagem')) {
              icone = Icons.chat_bubble_outline_rounded;
              iconBg = NotificacoesProfessorColors.iconPurpleBg; 
            } else if (tLower.contains('avalia')) {
              icone = Icons.star_rounded;
              iconBg = NotificacoesProfessorColors.iconYellowBg; 
            }

            notificacoesTemporarias.add(_NotificationData(
              id: idNotif,
              isUnread: isUnread,
              iconBackground: iconBg,
              icon: icone,
              title: tipoString.isEmpty ? 'Notificação' : tipoString,
              message: msgString,
              timeAgo: _calcularTempoAtras(dataCriacao),
              date: dataCriacao,
            ));
          }
        }

        notificacoesTemporarias.sort((a, b) => b.date.compareTo(a.date));

        if (mounted) {
          setState(() {
            _notifications = notificacoesTemporarias;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro a carregar notificações: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _markAsRead(String id) async {
    // 1. Atualizar Visualmente
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return _NotificationData(id: n.id, isUnread: false, iconBackground: n.iconBackground, icon: n.icon, title: n.title, message: n.message, timeAgo: n.timeAgo, date: n.date);
        }
        return n;
      }).toList();
    });

    // 2. Persistir na Base de Dados
    try {
      final token = await TokenStorage().loadToken() ?? '';
      final respGet = await http.get(ApiConfig.uri('/api/Communication/notifications/$id'), headers: {'Authorization': 'Bearer $token'});
      if (respGet.statusCode == 200) {
        final n = jsonDecode(respGet.body);
        await http.put(
          ApiConfig.uri('/api/Communication/notifications/$id'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            "IdNotification": id,
            "IdUser": n['idUser'] ?? n['IdUser'],
            "Type": n['type'] ?? n['Type'],
            "Message": n['message'] ?? n['Message'],
            "WasRead": true,
            "UpdatedAt": DateTime.now().toUtc().toIso8601String(),
          }),
        );
      }
    } catch (e) {
      debugPrint('Erro a marcar lida: $e');
    }
  }

  void _markAllAsRead() {
    for (var n in _notifications) {
      if (n.isUnread) _markAsRead(n.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: NotificacoesProfessorColors.title,
      fontSize: NotificacoesProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height: NotificacoesProfessorLayout.titleLineHeight / NotificacoesProfessorLayout.titleFontSize,
    );

    final subtitleStyle = TextStyle(
      color: NotificacoesProfessorColors.subtitle,
      fontSize: NotificacoesProfessorLayout.subtitleFontSize,
      fontWeight: FontWeight.w400,
      height: NotificacoesProfessorLayout.subtitleLineHeight / NotificacoesProfessorLayout.subtitleFontSize,
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
              ProfessorMenuNav(notificationCount: _unreadCount, selectedIndex: 10),
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
                          _MarkAllAsReadButton(onTap: _unreadCount > 0 ? _markAllAsRead : null),
                        ],
                      ),
                      const SizedBox(height: 28.737),
                      
                      if (_isLoading)
                        const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                      else if (_notifications.isEmpty)
                        const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text("Sem notificações para mostrar.", style: TextStyle(color: Colors.grey, fontSize: 16))))
                      else
                        Column(
                          children: [
                            for (final notification in _notifications) ...[
                              _NotificationCard(
                                data: notification, 
                                onTap: notification.isUnread ? () => _markAsRead(notification.id) : null
                              ),
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
  const _MarkAllAsReadButton({this.onTap});
  final VoidCallback? onTap;

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
          onTap: onTap,
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
                  height: NotificacoesProfessorLayout.bodyLineHeight / NotificacoesProfessorLayout.bodyFontSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.data,
    this.onTap,
  });

  final _NotificationData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = data.isUnread ? NotificacoesProfessorColors.unreadBorder : NotificacoesProfessorColors.readBorder;
    final borderRadius = BorderRadius.circular(NotificacoesProfessorLayout.cardRadius);

    return InkWell(
      onTap: onTap, // Clicar na notificação marca-a como lida
      borderRadius: borderRadius,
      child: SizedBox(
        height: NotificacoesProfessorLayout.cardHeight,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: NotificacoesProfessorLayout.cardBorderWidth),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: NotificacoesProfessorLayout.shadowBlur1, offset: const Offset(0, 4.79)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: NotificacoesProfessorLayout.shadowBlur2, offset: const Offset(0, 2.395)),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              children: [
                if (data.isUnread)
                  Positioned(left: 0, top: 0, bottom: 0, child: Container(width: NotificacoesProfessorLayout.cardUnreadLeftBorderWidth, color: NotificacoesProfessorColors.unreadAccent)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(NotificacoesProfessorLayout.cardPaddingLeft, NotificacoesProfessorLayout.cardPaddingTop, NotificacoesProfessorLayout.cardPaddingRight, NotificacoesProfessorLayout.cardBorderWidth),
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
                                    style: const TextStyle(color: NotificacoesProfessorColors.title, fontSize: NotificacoesProfessorLayout.headingFontSize, fontWeight: FontWeight.w500, height: NotificacoesProfessorLayout.headingLineHeight / NotificacoesProfessorLayout.headingFontSize),
                                  ),
                                  const Spacer(),
                                  if (data.isUnread)
                                    Container(
                                      width: NotificacoesProfessorLayout.unreadDotSize, height: NotificacoesProfessorLayout.unreadDotSize,
                                      decoration: const BoxDecoration(color: NotificacoesProfessorColors.unreadAccent, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4.79),
                            SizedBox(
                              height: NotificacoesProfessorLayout.bodyLineHeight,
                              child: Text(
                                data.message,
                                style: const TextStyle(color: NotificacoesProfessorColors.subtitle, fontSize: NotificacoesProfessorLayout.bodyFontSize, fontWeight: FontWeight.w400, height: NotificacoesProfessorLayout.bodyLineHeight / NotificacoesProfessorLayout.bodyFontSize),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: NotificacoesProfessorLayout.timeLineHeight,
                              child: Text(
                                data.timeAgo,
                                style: const TextStyle(color: NotificacoesProfessorColors.timeText, fontSize: NotificacoesProfessorLayout.timeFontSize, fontWeight: FontWeight.w400, height: NotificacoesProfessorLayout.timeLineHeight / NotificacoesProfessorLayout.timeFontSize),
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
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.background, required this.icon});
  final Color background;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: NotificacoesProfessorLayout.iconCircleSize, height: NotificacoesProfessorLayout.iconCircleSize,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: NotificacoesProfessorLayout.iconSize, color: NotificacoesProfessorColors.title),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.isUnread});
  final bool isUnread;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: NotificacoesProfessorLayout.actionButtonSize, height: NotificacoesProfessorLayout.actionButtonSize,
      child: Center(
        child: Icon(isUnread ? Icons.more_horiz_rounded : Icons.more_vert_rounded, size: NotificacoesProfessorLayout.actionIconSize, color: NotificacoesProfessorColors.title),
      ),
    );
  }
}