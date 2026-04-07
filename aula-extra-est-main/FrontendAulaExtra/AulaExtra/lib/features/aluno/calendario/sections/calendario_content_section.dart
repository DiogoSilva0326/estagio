import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:intl/intl.dart';

import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class AlunoAulaCardData {
  final String idLesson;
  final String subject;
  final String teacherName;
  final Color badgeColor;
  final String dateLabel;
  final String timeLabel;

  AlunoAulaCardData({
    required this.idLesson,
    required this.subject,
    required this.teacherName,
    required this.badgeColor,
    required this.dateLabel,
    required this.timeLabel,
  });
}

class CalendarioContentSection extends StatefulWidget {
  const CalendarioContentSection({super.key});

  @override
  State<CalendarioContentSection> createState() => _CalendarioContentSectionState();
}

class _CalendarioContentSectionState extends State<CalendarioContentSection> {
  final Key _listaAulasKey = UniqueKey();

  Future<List<AlunoAulaCardData>> _fetchAulasDoAlunoDaBD() async {
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
      final respUsers = await http.get(ApiConfig.uri('/api/Users'), headers: {'Authorization': 'Bearer $token'});
      final respProfessors = await http.get(ApiConfig.uri('/api/Professors'), headers: {'Authorization': 'Bearer $token'});

      List<dynamic> extractList(http.Response res) {
        if (res.statusCode != 200) return [];
        final body = jsonDecode(res.body);
        return body is List ? body : (body['data'] ?? body['items'] ?? []);
      }

      final enrollments = extractList(respEnrolls);
      final lessons = extractList(respLessons);
      final courses = extractList(respCourses);
      final users = extractList(respUsers);
      final professors = extractList(respProfessors);

      List<AlunoAulaCardData> aulasConvertidas = [];
      final agora = DateTime.now();

      final myEnrollments = enrollments.where((e) => 
        (e['idUser'] ?? e['IdUser'] ?? e['id_user']).toString() == myUserId
      ).toList();

      for (var enroll in myEnrollments) {
        final status = (enroll['status'] ?? enroll['Status'] ?? '').toString().toLowerCase();
        
        if (status == 'pending' || status == 'canceled') continue;
        
        final idLessonEnroll = (enroll['idLesson'] ?? enroll['IdLesson'] ?? enroll['id_lesson'])?.toString();

        final lessonMatch = lessons.where((l) => 
          (l['idLesson'] ?? l['IdLesson'] ?? l['id_lesson']).toString() == idLessonEnroll
        ).toList();

        if (lessonMatch.isNotEmpty) {
          final l = lessonMatch.first;
          final schedStart = l['scheduledStart'] ?? l['ScheduledStart'];
          final schedEnd = l['scheduledEnd'] ?? l['ScheduledEnd'];
          final idCourse = (l['idCourse'] ?? l['IdCourse'] ?? l['id_course'])?.toString();
          final idProfessor = (l['idProfessor'] ?? l['IdProfessor'] ?? l['id_professor'])?.toString();

          if (schedStart != null && schedEnd != null) {
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

            String professorName = "Professor Desconhecido";
            if (idProfessor != null) {
              final profMatch = professors.where((p) => (p['idProfessor'] ?? p['IdProfessor'] ?? p['id_professor']).toString() == idProfessor).toList();
              if (profMatch.isNotEmpty) {
                final profUserId = (profMatch.first['idUser'] ?? profMatch.first['IdUser'] ?? profMatch.first['id_user']).toString();
                final userMatch = users.where((u) => (u['idUser'] ?? u['IdUser'] ?? u['id_user'] ?? u['id']).toString() == profUserId).toList();
                if (userMatch.isNotEmpty) {
                  final u = userMatch.first;
                  final firstName = u['firstName'] ?? u['FirstName'];
                  final lastName = u['lastName'] ?? u['LastName'];
                  final username = u['username'] ?? u['UserName'];

                  if (firstName != null && lastName != null) {
                    professorName = "$firstName $lastName";
                  } else if (username != null) {
                    professorName = username.toString();
                  }
                }
              }
            }

            Color badgeColor = const Color(0xFF2B7FFF);
            final dLower = disciplina.toLowerCase();
            if (dLower.contains('física') || dLower.contains('biologia')) {
              badgeColor = const Color(0xFF00C950);
            } else if (dLower.contains('inglês') || dLower.contains('química')) {
              badgeColor = const Color(0xFFFF6900);
            }

            final mes = _traduzirMes(dtStart.month);
            String dateLabel = '📅 ${dtStart.day} $mes';
            
            if (dtStart.year == agora.year && dtStart.month == agora.month && dtStart.day == agora.day) {
              dateLabel = '📅 Hoje';
            } else if (dtStart.year == agora.year && dtStart.month == agora.month && dtStart.day == agora.day + 1) {
              dateLabel = '📅 Amanhã';
            }

            final timeLabel = '🕐 ${DateFormat('HH:mm').format(dtStart)} - ${DateFormat('HH:mm').format(dtEnd)}';

            aulasConvertidas.add(
              AlunoAulaCardData(
                idLesson: idLessonEnroll!,
                subject: disciplina,
                teacherName: professorName,
                badgeColor: badgeColor,
                dateLabel: dateLabel,
                timeLabel: timeLabel,
              )
            );
          }
        }
      }

      aulasConvertidas.sort((a, b) => a.dateLabel.compareTo(b.dateLabel));
      return aulasConvertidas;
    } catch (e) {
      debugPrint('Erro ao carregar próximas aulas do aluno: $e');
      return [];
    }
  }

  String _traduzirMes(int month) {
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[month - 1];
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
                const Text(
                  'Calendário',
                  style: CalendarioConstants.titleStyle,
                ),
                const SizedBox(height: 11.202),
                const Text(
                  'Organize suas aulas e compromissos',
                  style: CalendarioConstants.subtitleStyle,
                ),
                const SizedBox(height: 33.607),
                _CalendarTabs(
                  onWeeklyTap: () => Navigator.of(context).pushNamed(Routes.calendarioSemanal),
                ),
                const SizedBox(height: 22.404),
                
                FutureBuilder<List<AlunoAulaCardData>>(
                  key: _listaAulasKey,
                  future: _fetchAulasDoAlunoDaBD(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final aulas = snapshot.data ?? [];

                    if (aulas.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text(
                            "Ainda não tens aulas marcadas. Começa agora!",
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: aulas.map((aula) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 22.404),
                          child: _UpcomingLessonCard(
                            accentColor: aula.badgeColor,
                            subject: aula.subject,
                            teacherName: aula.teacherName,
                            dateLabel: aula.dateLabel,
                            timeLabel: aula.timeLabel,
                            primaryActionStyle: aula.dateLabel.contains('Hoje') 
                                ? _PrimaryActionStyle.enterClass 
                                : _PrimaryActionStyle.viewDetails,
                            primaryActionLabel: aula.dateLabel.contains('Hoje') 
                                ? 'Entrar na Aula' 
                                : 'Ver Detalhes',
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTabs extends StatelessWidget {
  const _CalendarTabs({required this.onWeeklyTap});

  final VoidCallback onWeeklyTap;

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
            _TabItem(
              width: 223.837,
              text: 'Próximas Aulas',
              selected: true,
              onTap: () {},
            ),
            const SizedBox(width: 22.404),
            _TabItem(
              width: 268.154,
              text: 'Calendário Semanal',
              selected: false,
              onTap: onWeeklyTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.width,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 70.014,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.404,
                  fontWeight: FontWeight.w500,
                  color: selected ? CalendarioConstants.activeTabColor : CalendarioConstants.inactiveTabColor,
                  height: 33.607 / 22.404,
                ),
              ),
            ),
            if (selected)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 2.801,
                  child: ColoredBox(color: CalendarioConstants.activeTabColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _PrimaryActionStyle {
  enterClass,
  viewDetails,
}

class _UpcomingLessonCard extends StatelessWidget {
  const _UpcomingLessonCard({
    required this.accentColor,
    required this.subject,
    required this.teacherName,
    required this.dateLabel,
    required this.timeLabel,
    required this.primaryActionStyle,
    required this.primaryActionLabel,
  });

  final Color accentColor;
  final String subject;
  final String teacherName;
  final String dateLabel;
  final String timeLabel;
  final _PrimaryActionStyle primaryActionStyle;
  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 254.851,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 35.007, vertical: 35.007),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
          border: Border.all(color: CalendarioConstants.cardBorderColor, width: CalendarioConstants.cardBorderWidth),
          boxShadow: CalendarioConstants.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 11.202,
              height: 89.618,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(23492794),
              ),
            ),
            const SizedBox(width: 22.404),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 25.205,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF101828),
                                height: 39.208 / 25.205,
                              ),
                            ),
                            Text(
                              'com $teacherName',
                              style: const TextStyle(
                                fontSize: 19.604,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4A5565),
                                height: 28.006 / 19.604,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11.202),
                  Row(
                    children: [
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 19.604,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5565),
                          height: 28.006 / 19.604,
                        ),
                      ),
                      const SizedBox(width: 33.607),
                      Flexible(
                        child: Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 19.604,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A5565),
                            height: 28.006 / 19.604,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _PrimaryActionButton(
                        style: primaryActionStyle,
                        label: primaryActionLabel,
                      ),
                      const SizedBox(width: 16.803),
                      const _SecondaryIconButton(),
                    ],
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.style,
    required this.label,
  });

  final _PrimaryActionStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      _PrimaryActionStyle.enterClass => SizedBox(
          width: 240.345,
          height: 56.011,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C950),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19.604),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 33.607,
                  top: (56.011 - 22.404) / 2,
                  child: Icon(Icons.play_arrow_rounded, size: 22.404, color: Colors.white),
                ),
                Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 22.404,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 33.607 / 22.404,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      _PrimaryActionStyle.viewDetails => _GradientButton(
          width: 193.359,
          height: 56.011,
          radius: 19.604,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22.404,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 33.607 / 22.404,
              ),
            ),
          ),
        ),
    };
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.width,
    required this.height,
    required this.radius,
    required this.child,
  });

  final double width;
  final double height;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF6B00),
                Color(0xFFFF9966),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(radius),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SecondaryIconButton extends StatelessWidget {
  const _SecondaryIconButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.014,
      height: 56.011,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFFFFC9C9), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19.604)),
        ),
        child: const Icon(Icons.close_rounded, size: 22.404, color: Color(0xFFFB2C36)),
      ),
    );
  }
}