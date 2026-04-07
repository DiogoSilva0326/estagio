import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:flutter/material.dart';

import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_mock_data.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacao_card.dart';
import 'package:aula_extra/features/aluno/notificacoes/widgets/notificacoes_filter_pill.dart';

enum NotificacoesFiltro { todas, naoLidas, aulas, tarefas, mensagens }

class _TempNotif {
  final NotificacaoItem item;
  final DateTime date;
  final String? idEnrollment; 
  _TempNotif(this.item, this.date, {this.idEnrollment});
}

class NotificacoesContentSection extends StatefulWidget {
  const NotificacoesContentSection({super.key});

  @override
  State<NotificacoesContentSection> createState() => _NotificacoesContentSectionState();
}

class _NotificacoesContentSectionState extends State<NotificacoesContentSection> {
  List<_TempNotif> _itemsComMetadados = [];
  bool _isLoading = true;
  NotificacoesFiltro _filtro = NotificacoesFiltro.todas;
  String _meuNome = "O Aluno";

  @override
  void initState() {
    super.initState();
    _carregarNotificacoesDaAPI();
  }

  int get _unreadCount => _itemsComMetadados.where((e) => e.item.unread).length;

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

  Future<void> _carregarNotificacoesDaAPI() async {
    setState(() => _isLoading = true);
    try {
      final token = await TokenStorage().loadToken() ?? '';
      final myUserId = _extrairIdDoToken(token);
      final respMe = await http.get(ApiConfig.uri('/api/Users/me'), headers: {'Authorization': 'Bearer $token'});
      if (respMe.statusCode == 200) {
        final myData = jsonDecode(respMe.body);
        final fname = myData['firstName'] ?? myData['FirstName'] ?? '';
        final lname = myData['lastName'] ?? myData['LastName'] ?? '';
        if (fname.isNotEmpty || lname.isNotEmpty) {
          _meuNome = "$fname $lname".trim();
        } else {
          _meuNome = myData['username'] ?? myData['UserName'] ?? "Um aluno";
        }
      }

      final response = await http.get(
        ApiConfig.uri('/api/Communication/notifications'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(response.body);
        final notificacoesTemporarias = <_TempNotif>[];

        for (var n in dados) {
          final idUserNotif = (n['idUser'] ?? n['IdUser'])?.toString().toLowerCase();
          
          if (idUserNotif == myUserId.toLowerCase()) {
            final isUnread = !(n['wasRead'] ?? n['WasRead'] ?? true);
            final tipoString = (n['type'] ?? n['Type'])?.toString() ?? '';
            final rawMessage = (n['message'] ?? n['Message'])?.toString() ?? '';
            final createdAtStr = n['createdAt'] ?? n['CreatedAt'];
            final idNotif = (n['idNotification'] ?? n['IdNotification']).toString();
            
            DateTime dataCriacao = DateTime.now();
            if (createdAtStr != null) {
              dataCriacao = DateTime.parse(createdAtStr.toString()).toLocal();
            }

            String textoVisivel = rawMessage;
            String? idEnrollmentEscondido;

            if (tipoString == "Aula Pendente") {
              try {
                final dadosEscondidos = jsonDecode(rawMessage);
                textoVisivel = dadosEscondidos['text'] ?? rawMessage;
                idEnrollmentEscondido = dadosEscondidos['idEnrollment'];
              } catch (_) {}
            }

            NotificacaoTipo enumTipo = NotificacaoTipo.mensagem; 
            IconData icone = Icons.notifications_active_rounded;
            Color iconBg = const Color(0xFF2B7FFF); 

            final tLower = tipoString.toLowerCase();
            
            if (tLower.contains('aula') || tLower.contains('pendente')) {
              enumTipo = NotificacaoTipo.aula;
              icone = Icons.calendar_month_rounded;
              iconBg = const Color(0xFF00C950); 
            } else if (tLower.contains('tarefa')) {
              enumTipo = NotificacaoTipo.tarefa;
              icone = Icons.assignment_rounded;
              iconBg = const Color(0xFF2B7FFF); 
            } else if (tLower.contains('mensagem') || tLower.contains('chat')) {
              enumTipo = NotificacaoTipo.mensagem;
              icone = Icons.chat_bubble_rounded;
              iconBg = const Color(0xFFAD46FF); 
            } else if (tLower.contains('avalia')) {
              enumTipo = NotificacaoTipo.avaliacao;
              icone = Icons.star_rounded;
              iconBg = const Color(0xFFF0B100); 
            } else if (tLower.contains('pagamento')) {
              enumTipo = NotificacaoTipo.pagamento;
              icone = Icons.payments_rounded;
              iconBg = const Color(0xFFFF6900); 
            }

            final itemReal = NotificacaoItem(
              id: idNotif,
              unread: isUnread,
              tipo: enumTipo,
              title: tipoString.isEmpty ? 'Notificação' : tipoString,
              message: textoVisivel, 
              timeLabel: _calcularTempoAtras(dataCriacao),
              icon: icone,
              iconBackground: iconBg,
            );

            notificacoesTemporarias.add(_TempNotif(itemReal, dataCriacao, idEnrollment: idEnrollmentEscondido));
          }
        }

        notificacoesTemporarias.sort((a, b) => b.date.compareTo(a.date));

        if (mounted) {
          setState(() {
            _itemsComMetadados = notificacoesTemporarias;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro a carregar notificações: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _responderAula(String idEnrollment, String novoEstado, String idNotification) async {
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      final respGet = await http.get(ApiConfig.uri('/api/Lessons/enrollments/$idEnrollment'), headers: {'Authorization': 'Bearer $token'});
      if (respGet.statusCode != 200) throw Exception("Erro ao buscar a inscrição.");
      final dadosAntigos = jsonDecode(respGet.body);

      final idLesson = (dadosAntigos['idLesson'] ?? dadosAntigos['IdLesson']).toString();

      final respPut = await http.put(
        ApiConfig.uri('/api/Lessons/enrollments/$idEnrollment'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          "idEnrollment": idEnrollment,
          "idLesson": idLesson,
          "idUser": dadosAntigos['idUser'] ?? dadosAntigos['IdUser'],
          "status": novoEstado, 
          "pricePaid": dadosAntigos['pricePaid'] ?? dadosAntigos['PricePaid'] ?? 0.0,
          "createdAt": dadosAntigos['createdAt'] ?? dadosAntigos['CreatedAt']
        }),
      );

      if (respPut.statusCode != 200 && respPut.statusCode != 204) throw Exception("Erro ao atualizar o estado.");

      try {
        final respLesson = await http.get(ApiConfig.uri('/api/Lessons/lessons/$idLesson'), headers: {'Authorization': 'Bearer $token'});
        
        if (respLesson.statusCode == 200) {
          final lessonData = jsonDecode(respLesson.body);
          final idProf = (lessonData['idProfessor'] ?? lessonData['IdProfessor']).toString();
          final respProfs = await http.get(ApiConfig.uri('/api/Professors/professors'), headers: {'Authorization': 'Bearer $token'});
          
          if (respProfs.statusCode == 200) {
          
            List<dynamic> extractList(http.Response res) {
              final body = jsonDecode(res.body);
              return body is List ? body : (body['data'] ?? body['items'] ?? []);
            }
            
            final List proflist = extractList(respProfs);
            final match = proflist.where((p) => (p['idProfessor'] ?? p['IdProfessor'] ?? p['id_professor']).toString() == idProf).toList();
            
            if (match.isNotEmpty) {
              final idUserDoProfessor = (match.first['idUser'] ?? match.first['IdUser'] ?? match.first['id_user']).toString();
              
              final isAprovada = novoEstado == 'Active';
              final typeNotif = isAprovada ? "Aula Confirmada" : "Aula Recusada";
              final msgNotif = isAprovada 
                  ? "$_meuNome confirmou a presença na aula!" 
                  : "$_meuNome não pode comparecer e recusou a aula.";

              await http.post(
                ApiConfig.uri('/api/Communication/notifications'),
                headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                body: jsonEncode({
                  "IdUser": idUserDoProfessor, 
                  "Type": typeNotif,            
                  "Message": msgNotif, 
                  "WasRead": false,                  
                  "CreatedAt": DateTime.now().toUtc().toIso8601String(),
                  "UpdatedAt": DateTime.now().toUtc().toIso8601String()
                }),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Aviso: Falha ao notificar o professor: $e');
      }

      await _persistirNotificacaoLida(idNotification);

      if (novoEstado == 'Canceled') {
        await http.delete(ApiConfig.uri('/api/Communication/notifications/$idNotification'), headers: {'Authorization': 'Bearer $token'});
        
        setState(() {
          _itemsComMetadados.removeWhere((e) => e.item.id == idNotification);
        });
      } else {
        await _persistirNotificacaoLida(idNotification);
        
        setState(() {
          _itemsComMetadados = _itemsComMetadados.map((e) {
            if (e.item.id == idNotification) {
              return _TempNotif(e.item.copyWith(unread: false), e.date, idEnrollment: e.idEnrollment);
            }
            return e;
          }).toList();
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(novoEstado == 'Active' ? 'Aula confirmada!' : 'Aula recusada.'),
          backgroundColor: novoEstado == 'Active' ? Colors.green : Colors.orange,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _persistirNotificacaoLida(String idNotificacao) async {
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      final respGet = await http.get(
        ApiConfig.uri('/api/Communication/notifications/$idNotificacao'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respGet.statusCode == 200) {
        final n = jsonDecode(respGet.body);
        
        await http.put(
          ApiConfig.uri('/api/Communication/notifications/$idNotificacao'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            "IdNotification": idNotificacao,
            "IdUser": n['idUser'] ?? n['IdUser'],
            "Type": n['type'] ?? n['Type'],
            "Message": n['message'] ?? n['Message'],
            "WasRead": true,
            "UpdatedAt": DateTime.now().toUtc().toIso8601String(),
          }),
        );
      }
    } catch (e) {
      debugPrint('Erro ao persistir notificação como lida: $e');
    }
  }

  void _markAllAsRead() {
    setState(() {
      _itemsComMetadados = _itemsComMetadados.map((e) => _TempNotif(e.item.copyWith(unread: false), e.date, idEnrollment: e.idEnrollment)).toList();
    });
  }

  void _markAsRead(String id) {
    setState(() {
      _itemsComMetadados = _itemsComMetadados.map((e) => e.item.id == id ? _TempNotif(e.item.copyWith(unread: false), e.date, idEnrollment: e.idEnrollment) : e).toList();
    });
  }

  List<_TempNotif> get _filteredItems {
    return _itemsComMetadados.where((element) {
      return switch (_filtro) {
        NotificacoesFiltro.todas => true,
        NotificacoesFiltro.naoLidas => element.item.unread,
        NotificacoesFiltro.aulas => element.item.tipo == NotificacaoTipo.aula,
        NotificacoesFiltro.tarefas => element.item.tipo == NotificacaoTipo.tarefa,
        NotificacoesFiltro.mensagens => element.item.tipo == NotificacaoTipo.mensagem,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NotificacoesConstants.horizontalPadding, vertical: NotificacoesConstants.verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlunoMenuNav(selectedIndex: 9, notificationCount: _unreadCount),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Notificações', style: NotificacoesConstants.titleStyle),
                        SizedBox(height: 11.243),
                        Text('Fique por dentro de tudo que acontece', style: NotificacoesConstants.subtitleStyle),
                      ],
                    ),
                    InkWell(
                      onTap: _unreadCount == 0 ? null : _markAllAsRead,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Text('Marcar todas como lidas', style: NotificacoesConstants.actionLinkStyle),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 44),
                _UnreadSummaryCard(count: _unreadCount),
                const SizedBox(height: 33),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      NotificacoesFilterPill(label: 'Todas', selected: _filtro == NotificacoesFiltro.todas, onTap: () => setState(() => _filtro = NotificacoesFiltro.todas)),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(label: 'Não lidas', selected: _filtro == NotificacoesFiltro.naoLidas, onTap: () => setState(() => _filtro = NotificacoesFiltro.naoLidas)),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(label: 'Aulas', selected: _filtro == NotificacoesFiltro.aulas, onTap: () => setState(() => _filtro = NotificacoesFiltro.aulas)),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(label: 'Tarefas', selected: _filtro == NotificacoesFiltro.tarefas, onTap: () => setState(() => _filtro = NotificacoesFiltro.tarefas)),
                      const SizedBox(width: 16.865),
                      NotificacoesFilterPill(label: 'Mensagens', selected: _filtro == NotificacoesFiltro.mensagens, onTap: () => setState(() => _filtro = NotificacoesFiltro.mensagens)),
                    ],
                  ),
                ),
                const SizedBox(height: 33),

                if (_isLoading)
                  const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                else if (_filteredItems.isEmpty)
                  const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text("Sem notificações para mostrar.", style: TextStyle(color: Colors.grey, fontSize: 16))))
                else
                  ...List.generate(_filteredItems.length, (index) {
                    final wrapper = _filteredItems[index];
                    final item = wrapper.item;
                    final isPendingAula = item.title == "Aula Pendente" && wrapper.idEnrollment != null && item.unread;

                    return Padding(
                      padding: EdgeInsets.only(bottom: index == _filteredItems.length - 1 ? 0 : 16.865),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NotificacaoCard(
                            item: item,
                            onMarkAsRead: item.unread && !isPendingAula ? () => _markAsRead(item.id) : null,
                          ),
                          if (isPendingAula)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 90),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    onPressed: () => _responderAula(wrapper.idEnrollment!, 'Active', item.id),
                                    child: const Text("Aceitar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                    onPressed: () => _responderAula(wrapper.idEnrollment!, 'Canceled', item.id),
                                    child: const Text("Recusar"),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadSummaryCard extends StatelessWidget {
  const _UnreadSummaryCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35.135),
      decoration: BoxDecoration(
        gradient: NotificacoesConstants.unreadSummaryGradient,
        borderRadius: BorderRadius.circular(NotificacoesConstants.cardRadius),
        border: Border.all(color: NotificacoesConstants.unreadSummaryBorderColor, width: NotificacoesConstants.borderWidth),
      ),
      child: Row(
        children: [
          Container(
            width: 67.459, height: 67.459,
            decoration: const BoxDecoration(gradient: NotificacoesConstants.iconOrangeGradient, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 33.73),
          ),
          const SizedBox(width: 16.865),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: const TextStyle(fontSize: 33.73, fontWeight: FontWeight.w700, color: Color(0xFFCA3500))),
              const SizedBox(height: 2),
              const Text('Notificações não lidas', style: TextStyle(fontSize: 19.676, fontWeight: FontWeight.w400, color: Color(0xFFF54900))),
            ],
          ),
        ],
      ),
    );
  }
}