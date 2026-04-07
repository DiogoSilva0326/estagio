import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:intl/intl.dart';

import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

// --- MODELO PARA AULA SEMANAL ---
class AlunoAulaSemanalData {
  final String idLesson;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;

  AlunoAulaSemanalData({
    required this.idLesson,
    required this.subject,
    required this.startTime,
    required this.endTime,
  });
}

class CalendarioSemanalContentSection extends StatefulWidget {
  const CalendarioSemanalContentSection({super.key});

  @override
  State<CalendarioSemanalContentSection> createState() => _CalendarioSemanalContentSectionState();
}

class _CalendarioSemanalContentSectionState extends State<CalendarioSemanalContentSection> {
  late DateTime _startOfWeek;
  final Key _calendarioKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Encontrar a segunda-feira da semana atual
    final now = DateTime.now();
    _startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  }

  void _mudarSemana(int dias) {
    setState(() {
      _startOfWeek = _startOfWeek.add(Duration(days: dias));
    });
  }

  // --- API CALL (Vai buscar a semana inteira) ---
  Future<List<AlunoAulaSemanalData>> _fetchAulasDaSemana() async {
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      String? myUserId;
      final respUser = await http.get(ApiConfig.uri('/api/Users/me'), headers: {'Authorization': 'Bearer $token'});
      if (respUser.statusCode == 200) {
        final userData = jsonDecode(respUser.body);
        myUserId = (userData['idUser'] ?? userData['id_user'] ?? userData['id'])?.toString();
      }
      if (myUserId == null) return [];

      final respEnrolls = await http.get(ApiConfig.uri('/api/Lessons/enrollments'), headers: {'Authorization': 'Bearer $token'});
      final respLessons = await http.get(ApiConfig.uri('/api/Lessons/lessons'), headers: {'Authorization': 'Bearer $token'});
      final respCourses = await http.get(ApiConfig.uri('/api/Courses/courses'), headers: {'Authorization': 'Bearer $token'});

      List<dynamic> extractList(http.Response res) {
        if (res.statusCode != 200) return [];
        final body = jsonDecode(res.body);
        return body is List ? body : (body['data'] ?? body['items'] ?? []);
      }

      final enrollments = extractList(respEnrolls);
      final lessons = extractList(respLessons);
      final courses = extractList(respCourses);

      final endOfWeek = _startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
      List<AlunoAulaSemanalData> aulas = [];

      final myEnrollments = enrollments.where((e) => (e['idUser'] ?? e['IdUser'] ?? e['id_user']).toString() == myUserId).toList();

      for (var enroll in myEnrollments) {
        final status = (enroll['status'] ?? enroll['Status'] ?? '').toString().toLowerCase();

        if (status == 'pending' || status == 'canceled') continue;

        final idLessonEnroll = (enroll['idLesson'] ?? enroll['IdLesson'] ?? enroll['id_lesson'])?.toString();
        final lessonMatch = lessons.where((l) => (l['idLesson'] ?? l['IdLesson'] ?? l['id_lesson']).toString() == idLessonEnroll).toList();

        if (lessonMatch.isNotEmpty) {
          final l = lessonMatch.first;
          final schedStart = l['scheduledStart'] ?? l['ScheduledStart'];
          final schedEnd = l['scheduledEnd'] ?? l['ScheduledEnd'];
          final idCourse = (l['idCourse'] ?? l['IdCourse'] ?? l['id_course'])?.toString();

          if (schedStart != null && schedEnd != null) {
            final dtStart = DateTime.parse(schedStart.toString()).toLocal();
            final dtEnd = DateTime.parse(schedEnd.toString()).toLocal();

            // Filtrar para aparecer APENAS aulas da semana selecionada
            if (dtStart.isAfter(_startOfWeek.subtract(const Duration(seconds: 1))) && 
                dtStart.isBefore(endOfWeek)) {
              
              String disciplina = "Aula";
              if (idCourse != null) {
                final courseMatch = courses.where((c) => (c['idCourse'] ?? c['IdCourse'] ?? c['id_course']).toString() == idCourse).toList();
                if (courseMatch.isNotEmpty) {
                  disciplina = (courseMatch.first['name'] ?? courseMatch.first['Name']).toString();
                }
              }

              aulas.add(AlunoAulaSemanalData(
                idLesson: idLessonEnroll!,
                subject: disciplina,
                startTime: dtStart,
                endTime: dtEnd,
              ));
            }
          }
        }
      }
      return aulas;
    } catch (e) {
      debugPrint('Erro no calendário semanal: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalendarioConstants.horizontalPadding,
        vertical: CalendarioConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 2),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text('Calendário', style: CalendarioConstants.titleStyle),
                const SizedBox(height: 11.202),
                const Text('Organize suas aulas e compromissos', style: CalendarioConstants.subtitleStyle),
                const SizedBox(height: 33.607),
                _WeeklyTabs(onUpcomingTap: () => Navigator.of(context).pushNamed(Routes.calendario)),
                const SizedBox(height: 22.404),
                
                // --- FUTURE BUILDER DA SEMANA ---
                FutureBuilder<List<AlunoAulaSemanalData>>(
                  key: ValueKey(_startOfWeek), // Refaz a chamada quando mudamos de semana
                  future: _fetchAulasDaSemana(),
                  builder: (context, snapshot) {
                    final aulas = snapshot.data ?? [];
                    return _WeeklyCalendarCard(
                      startOfWeek: _startOfWeek,
                      aulas: aulas,
                      onPreviousWeek: () => _mudarSemana(-7),
                      onNextWeek: () => _mudarSemana(7),
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TABS E CARD (WIDGETS REUTILIZÁVEIS)
// ==========================================

class _WeeklyTabs extends StatelessWidget {
  const _WeeklyTabs({required this.onUpcomingTap});
  final VoidCallback onUpcomingTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CalendarioConstants.dividerColor, width: 1.4)),
      ),
      child: SizedBox(
        height: 71.414,
        child: Row(
          children: [
            InkWell(
              onTap: onUpcomingTap,
              child: SizedBox(
                width: 223.837,
                height: 70.014,
                child: const Center(
                  child: Text(
                    'Próximas Aulas',
                    style: TextStyle(
                      fontSize: 22.404,
                      fontWeight: FontWeight.w500,
                      color: CalendarioConstants.inactiveTabColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 22.404),
            SizedBox(
              width: 268.154,
              height: 70.014,
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Calendário Semanal',
                      style: TextStyle(
                        fontSize: 22.404,
                        fontWeight: FontWeight.w500,
                        color: CalendarioConstants.activeTabColor,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: SizedBox(
                      height: 2.801,
                      child: ColoredBox(color: CalendarioConstants.activeTabColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCalendarCard extends StatelessWidget {
  const _WeeklyCalendarCard({
    required this.startOfWeek,
    required this.aulas,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.isLoading,
  });

  final DateTime startOfWeek;
  final List<AlunoAulaSemanalData> aulas;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (viewportHeight - 320).clamp(420.0, 720.0);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
          border: Border.all(color: CalendarioConstants.cardBorderColor, width: CalendarioConstants.cardBorderWidth),
          boxShadow: CalendarioConstants.cardShadow,
        ),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _WeeklyCalendarGrid(
              startOfWeek: startOfWeek,
              aulas: aulas,
              onPreviousWeek: onPreviousWeek,
              onNextWeek: onNextWeek,
            ),
      ),
    );
  }
}

// ==========================================
// GRID COM A LÓGICA DE STACK E PIXEIS
// ==========================================

class _WeeklyCalendarGrid extends StatelessWidget {
  const _WeeklyCalendarGrid({
    required this.startOfWeek,
    required this.aulas,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final DateTime startOfWeek;
  final List<AlunoAulaSemanalData> aulas;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  static const _headerTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF101828));
  static const _subHeaderTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF6A7282));
  
  // Variáveis vitais para a Matemática da Stack
  static const double hourHeight = 56.0;
  static const int startHour = 8;
  static const int endHour = 19;
  static const int totalHours = endHour - startHour + 1;

  @override
  Widget build(BuildContext context) {
    // Gerar Cabeçalhos Dinâmicos (Segunda a Domingo)
    final days = List.generate(7, (index) {
      final dataDia = startOfWeek.add(Duration(days: index));
      final nomeDia = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][index];
      return (nomeDia, DateFormat('dd MMM').format(dataDia), dataDia);
    });

    final hours = List.generate(totalHours, (i) => startHour + i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- NAVEGAÇÃO DA SEMANA ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Semana: ${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM').format(startOfWeek.add(const Duration(days: 6)))}', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPreviousWeek),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNextWeek),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // --- CABEÇALHOS DOS DIAS ---
        Row(
          children: [
            const SizedBox(width: 52), // Espaço da coluna das horas
            ...days.map(
              (d) => Expanded(
                child: Column(
                  children: [
                    Text(d.$1, style: _headerTextStyle),
                    const SizedBox(height: 2),
                    Text(d.$2, style: _subHeaderTextStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // --- ÁREA DO CALENDÁRIO COM STACKS ---
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna das Horas (08:00, 09:00...)
                SizedBox(
                  width: 52,
                  child: Column(
                    children: hours.map((h) => SizedBox(
                      height: hourHeight,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${h.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6A7282), height: 1.2),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                
                // Colunas dos Dias (Seg a Dom)
                ...List.generate(7, (dayIndex) {
                  final dataDesteDia = days[dayIndex].$3;
                  
                  // Filtrar aulas exclusivas deste dia
                  final aulasDeHoje = aulas.where((a) => 
                    a.startTime.year == dataDesteDia.year &&
                    a.startTime.month == dataDesteDia.month &&
                    a.startTime.day == dataDesteDia.day
                  ).toList();

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      // Altura Total do Calendário
                      height: totalHours * hourHeight,
                      child: Stack(
                        children: [
                          // 1. Fundo: Linhas Horizontais
                          Column(
                            children: List.generate(totalHours, (index) => Container(
                              height: hourHeight,
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
                              ),
                            )),
                          ),

                          // 2. Frente: Aulas Posicionadas pela Matemática 
                          ...aulasDeHoje.map((aula) {
                            // Cálculo da Posição Y (Topo)
                            final double topOffset = ((aula.startTime.hour - startHour) * hourHeight) + 
                                                     ((aula.startTime.minute / 60) * hourHeight);
                            
                            // Cálculo da Altura do Bloco (Duração)
                            final int duracaoMinutos = aula.endTime.difference(aula.startTime).inMinutes;
                            final double blockHeight = (duracaoMinutos / 60) * hourHeight;

                            // Se a aula começa antes das 8h ou acaba depois das 19h, proteger layout:
                            if (topOffset < 0 || topOffset >= (totalHours * hourHeight)) return const SizedBox();

                            return Positioned(
                              top: topOffset,
                              left: 0,
                              right: 0,
                              height: blockHeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED), // Laranja clarinho
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFF6B00), width: 1), // Borda Laranja
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: SingleChildScrollView( // Protege de overflow em aulas curtas
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        aula.subject,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF101828)),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${DateFormat('HH:mm').format(aula.startTime)} - ${DateFormat('HH:mm').format(aula.endTime)}',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFFFF6B00), fontWeight: FontWeight.w500),
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}