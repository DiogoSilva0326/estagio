import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:intl/intl.dart';

import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_layout.dart';
import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_mock_data.dart';
import 'package:aula_extra/features/professor/calendario/widgets/agenda_real_professor.dart';
import 'package:aula_extra/features/professor/calendario/widgets/aula_card.dart';
import 'package:aula_extra/features/professor/calendario/widgets/calendario_tabs.dart';
import 'package:aula_extra/features/professor/calendario/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/calendario/widgets/marcar_aula_dialog.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart'; 

class CalendarioProfessorContentSection extends StatefulWidget {
  const CalendarioProfessorContentSection({super.key});

  @override
  State<CalendarioProfessorContentSection> createState() => _CalendarioProfessorContentSectionState();
}

class _CalendarioProfessorContentSectionState extends State<CalendarioProfessorContentSection> {
  int _selectedTab = 0;
  final GlobalKey<AgendaRealProfessorState> _agendaKey = GlobalKey<AgendaRealProfessorState>();

  Key _listaAulasKey = UniqueKey(); 

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CalendarioProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(54, 90, 23.148, 90),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(selectedIndex: 1),
              const SizedBox(width: CalendarioProfessorLayout.sidebarContentGap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(CalendarioProfessorLayout.contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(), 
                      const SizedBox(height: CalendarioProfessorLayout.contentGap),
                      
                      CalendarioTabs(
                        selectedIndex: _selectedTab,
                        onChanged: (index) => setState(() => _selectedTab = index),
                      ),
                      const SizedBox(height: 37.813),
                      
                      IndexedStack(
                        index: _selectedTab,
                        children: [
                          _buildProximasAulasReais(key: _listaAulasKey),
                          AgendaRealProfessor(key: _agendaKey),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Calendário',
            style: TextStyle(color: CalendarioProfessorColors.title, fontWeight: FontWeight.bold, fontSize: 32),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => MarcarAulaDialog(
                  initialDate: DateTime.now(),
                  initialTime: TimeOfDay.now(),
                ),
              );
              
              if (result == true) {
                _agendaKey.currentState?.recarregarDados();
                setState(() {
                  _listaAulasKey = UniqueKey();
                });
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Marcar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ProfessorAulaCardData>> _fetchAulasDaBD() async {
    try {
      final token = await TokenStorage().loadToken() ?? '';

      String? myProfId;
      final respProf = await http.get(ApiConfig.uri('/api/Professors/me'), headers: {'Authorization': 'Bearer $token'});
      if (respProf.statusCode == 200) {
        final profData = jsonDecode(respProf.body);
        myProfId = (profData['idProfessor'] ?? profData['IdProfessor'] ?? profData['id_professor'])?.toString();
      }
      if (myProfId == null) return [];

      final respLessons = await http.get(ApiConfig.uri('/api/Lessons/lessons'), headers: {'Authorization': 'Bearer $token'});
      final respCourses = await http.get(ApiConfig.uri('/api/Courses/courses'), headers: {'Authorization': 'Bearer $token'});
      final respEnrolls = await http.get(ApiConfig.uri('/api/Lessons/enrollments'), headers: {'Authorization': 'Bearer $token'});
      final respUsers = await http.get(ApiConfig.uri('/api/Users'), headers: {'Authorization': 'Bearer $token'});

      if (respLessons.statusCode != 200) return [];

      List<dynamic> extractList(http.Response res) {
        if (res.statusCode != 200) return [];
        final body = jsonDecode(res.body);
        return body is List ? body : (body['data'] ?? body['items'] ?? []);
      }

      final lessons = extractList(respLessons);
      final courses = extractList(respCourses);
      final enrollments = extractList(respEnrolls);
      final users = extractList(respUsers);

      List<ProfessorAulaCardData> aulasConvertidas = [];
      final agora = DateTime.now();

      for (var l in lessons) {
        final apiProfId = (l['idProfessor'] ?? l['IdProfessor'] ?? l['id_professor'])?.toString();
        final schedStart = l['scheduledStart'] ?? l['ScheduledStart'];
        final schedEnd = l['scheduledEnd'] ?? l['ScheduledEnd'];
        final idLesson = (l['idLesson'] ?? l['IdLesson'] ?? l['id_lesson'])?.toString() ?? '';
        final idCourse = (l['idCourse'] ?? l['IdCourse'] ?? l['id_course'])?.toString();

        if (apiProfId == myProfId && schedStart != null && schedEnd != null) {
          final dtStart = DateTime.parse(schedStart.toString()).toLocal();
          final dtEnd = DateTime.parse(schedEnd.toString()).toLocal();

          if (dtStart.isBefore(agora.subtract(const Duration(days: 1)))) continue;

          String disciplina = "Aula";
          if (idCourse != null) {
            final courseMatch = courses.where((c) => (c['idCourse'] ?? c['IdCourse'] ?? c['id_course']).toString() == idCourse).toList();
            if (courseMatch.isNotEmpty) {
              disciplina = (courseMatch.first['name'] ?? courseMatch.first['Name']).toString();
            }
          }

          String studentName = "Aluno Desconhecido";
          String statusAtual = "scheduled";

          final enrollMatch = enrollments.where((e) => (e['idLesson'] ?? e['IdLesson'] ?? e['id_lesson']).toString() == idLesson).toList();
          
          if (enrollMatch.isEmpty) {
            continue; 
          }

          statusAtual = (enrollMatch.first['status'] ?? enrollMatch.first['Status'] ?? '').toString().toLowerCase();

          if (statusAtual == 'pending') continue;

          if (enrollMatch.isNotEmpty) {
            statusAtual = (enrollMatch.first['status'] ?? enrollMatch.first['Status'] ?? '').toString().toLowerCase();
            
            if (statusAtual == 'pending') continue; 

            final idUser = (enrollMatch.first['idUser'] ?? enrollMatch.first['IdUser'] ?? enrollMatch.first['id_user']).toString();
            final userMatch = users.where((u) => (u['idUser'] ?? u['IdUser'] ?? u['id_user'] ?? u['id']).toString() == idUser).toList();
            
            if (userMatch.isNotEmpty) {
              final u = userMatch.first;
              final firstName = u['firstName'] ?? u['FirstName'];
              final lastName = u['lastName'] ?? u['LastName'];
              final username = u['username'] ?? u['UserName'];

              if (firstName != null && lastName != null) {
                studentName = "$firstName $lastName";
              } else if (username != null) {
                studentName = username.toString();
              }
            }
          }

          if (statusAtual == 'canceled') {
            studentName = "$studentName (Aula Recusada)";
          }

          String iniciais = "A";
          final words = studentName.replaceAll('(Aula Recusada)', '').trim().split(' ');
          if (words.length > 1) {
            iniciais = '${words.first[0]}${words.last[0]}'.toUpperCase();
          } else if (words.isNotEmpty && words[0].isNotEmpty) {
            iniciais = words.first[0].toUpperCase();
          }

          Color badgeColor = CalendarioProfessorColors.badgeBlue;
          final dLower = disciplina.toLowerCase();
          
          if (dLower.contains('física') || dLower.contains('fisica') || dLower.contains('biologia')) {
            badgeColor = CalendarioProfessorColors.badgeGreen;
          } else if (dLower.contains('inglês') || dLower.contains('ingles') || dLower.contains('química')) {
            badgeColor = CalendarioProfessorColors.badgeOrange;
          } else if (dLower.contains('matemática') || dLower.contains('matematica')) {
            badgeColor = CalendarioProfessorColors.badgeBlue;
          }

          final diaSemana = _traduzirDiaSemana(dtStart.weekday);
          final mes = _traduzirMes(dtStart.month);
          final dataFormatada = '$diaSemana, ${dtStart.day} $mes';
          final horaFormatada = '${DateFormat('HH:mm').format(dtStart)} - ${DateFormat('HH:mm').format(dtEnd)}';

          aulasConvertidas.add(
            ProfessorAulaCardData(
              idLesson: idLesson,
              initials: iniciais,
              color: badgeColor,
              studentName: studentName,
              subject: disciplina,
              weekdayAndDate: dataFormatada,
              timeRange: horaFormatada, // 💡 Hora volta a ficar normal e bonita
            )
          );
        }
      }

      aulasConvertidas.sort((a, b) => a.timeRange.compareTo(b.timeRange));
      return aulasConvertidas;
    } catch (e) {
      debugPrint('Erro ao carregar próximas aulas: $e');
      return [];
    }
  }

  String _traduzirDiaSemana(int weekday) {
    switch (weekday) {
      case 1: return 'Segunda'; case 2: return 'Terça';
      case 3: return 'Quarta'; case 4: return 'Quinta';
      case 5: return 'Sexta'; case 6: return 'Sábado';
      case 7: return 'Domingo'; default: return '';
    }
  }

  String _traduzirMes(int month) {
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[month - 1];
  }

  Future<void> _cancelarAula(String idLesson, bool isAlreadyCanceled) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAlreadyCanceled ? 'Limpar Registo' : 'Cancelar Aula', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(isAlreadyCanceled 
            ? 'Queres apagar este registo de aula cancelada do teu histórico?' 
            : 'Tens a certeza que pretendes cancelar esta aula? Esta ação não pode ser revertida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isAlreadyCanceled ? 'Sim, Limpar' : 'Sim, Cancelar', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      final response = await http.delete(
        ApiConfig.uri('/api/Lessons/lessons/$idLesson'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isAlreadyCanceled ? 'Registo limpo com sucesso!' : 'Aula cancelada com sucesso!'), 
            backgroundColor: Colors.green
          ));
          setState(() {
            _listaAulasKey = UniqueKey();
          });
          _agendaKey.currentState?.recarregarDados();
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao executar: ${response.body}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildProximasAulasReais({required Key key}) {
    return FutureBuilder<List<ProfessorAulaCardData>>(
      key: key,
      future: _fetchAulasDaBD(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final aulas = snapshot.data ?? [];

        if (aulas.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
              child: Text(
                "Não tens aulas marcadas brevemente.",
                style: TextStyle(color: CalendarioProfessorColors.muted, fontSize: 16),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: aulas.length,
          separatorBuilder: (context, index) => const SizedBox(height: CalendarioProfessorLayout.listGap),
          itemBuilder: (context, index) {
            final aula = aulas[index];
            // 💡 A VERIFICAÇÃO AGORA É FEITA NO NOME DO ALUNO
            final isCanceled = aula.studentName.contains('(Recusada)');
            
            return AulaCard(
              data: aula, 
              onEnterTap: () {}, 
              onCancelTap: () => _cancelarAula(aula.idLesson, isCanceled),
            );
          },
        );
      },
    );
  }
}