import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/features/professor/calendario/widgets/marcar_aula_dialog.dart';

// --- MODELOS DE DADOS PARA A AGENDA ---
class BlocoDisponibilidade {
  final int dayOfWeek; 
  final DateTime startTime;
  final DateTime endTime;

  BlocoDisponibilidade({required this.dayOfWeek, required this.startTime, required this.endTime});
}

class AulaMarcadaAgenda {
  final String idLesson;
  final String subject;
  final String studentName; 
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  
  AulaMarcadaAgenda({
    required this.idLesson, 
    required this.subject, 
    required this.studentName, 
    required this.startTime, 
    required this.endTime,
    required this.status,
  });
}

class AgendaRealProfessor extends StatefulWidget {
  const AgendaRealProfessor({super.key});

  @override
  State<AgendaRealProfessor> createState() => AgendaRealProfessorState();
}

class AgendaRealProfessorState extends State<AgendaRealProfessor> {
  late DateTime _segundaFeiraFoco;
  Key _calendarioKey = UniqueKey();

  bool _isLoading = true;
  String? _myProfessorId;

  final List<BlocoDisponibilidade> _blocosLivres = [];
  final List<AulaMarcadaAgenda> _aulasReais = [];

  final Color blockInactiveBorder = const Color(0xFFEAECF0);
  final Color textMain = const Color(0xFF101828);
  final Color textMuted = const Color(0xFF667085);

  final Color availableBg = const Color(0xFFFFF7ED);
  final Color availableBorder = const Color(0xFFFF6B00); 

  final Color lessonBg = const Color(0xFFECFDF3); 
  final Color lessonBorder = const Color(0xFF12B76A); 

  final Color pastBg = const Color(0xFFF2F4F7);
  final Color pastBorder = const Color(0xFFD0D5DD);
  final Color pastTextDark = const Color(0xFF667085);
  final Color pastTextLight = const Color(0xFF98A2B3);

  static const double hourHeight = 56.0;
  static const int startHour = 8;
  static const int endHour = 22; 
  static const int totalHours = endHour - startHour + 1;

  @override
  void initState() {
    super.initState();
    _resetParaSemanaAtual();
    _carregarDados();
  }

  Future<void> recarregarDados() async {
    await _carregarDados();
  }

  void _resetParaSemanaAtual() {
    DateTime agora = DateTime.now();
    _segundaFeiraFoco = agora.subtract(Duration(days: agora.weekday - 1));
    _segundaFeiraFoco = DateTime(_segundaFeiraFoco.year, _segundaFeiraFoco.month, _segundaFeiraFoco.day);
  }

  void _mudarSemana(int semanas) {
    setState(() {
      _segundaFeiraFoco = _segundaFeiraFoco.add(Duration(days: semanas * 7));
      _calendarioKey = UniqueKey();
    });
    _carregarDados();
  }

  List<DateTime> _getDatasDaSemanaExibida() {
    return List.generate(7, (i) => _segundaFeiraFoco.add(Duration(days: i)));
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      if (_myProfessorId == null) {
        final respProf = await http.get(ApiConfig.uri('/api/Professors/me'), headers: {'Authorization': 'Bearer $token'});
        if (respProf.statusCode == 200) {
          final profData = jsonDecode(respProf.body);
          _myProfessorId = (profData['idProfessor'] ?? profData['IdProfessor'] ?? profData['id_professor']).toString();
        }
      }

      if (_myProfessorId != null) {
        _blocosLivres.clear();
        _aulasReais.clear();

        final respBlocks = await http.get(ApiConfig.uri('/api/Schedule/blocks'), headers: {'Authorization': 'Bearer $token'});
        final respLessons = await http.get(ApiConfig.uri('/api/Lessons/lessons'), headers: {'Authorization': 'Bearer $token'});
        final respCourses = await http.get(ApiConfig.uri('/api/Courses/courses'), headers: {'Authorization': 'Bearer $token'});
        final respEnrolls = await http.get(ApiConfig.uri('/api/Lessons/enrollments'), headers: {'Authorization': 'Bearer $token'});
        final respUsers = await http.get(ApiConfig.uri('/api/Users'), headers: {'Authorization': 'Bearer $token'});

        List<dynamic> extractList(http.Response res) {
          if (res.statusCode != 200) return [];
          final body = jsonDecode(res.body);
          return body is List ? body : (body['data'] ?? body['items'] ?? []);
        }

        final blocks = extractList(respBlocks);
        final lessons = extractList(respLessons);
        final courses = extractList(respCourses);
        final enrollments = extractList(respEnrolls);
        final users = extractList(respUsers);

        for (var b in blocks) {
          final apiProfId = (b['idProfessor'] ?? b['IdProfessor'] ?? b['id_professor'])?.toString();
          final startTimeStr = b['startTime'] ?? b['StartTime'];
          final endTimeStr = b['endTime'] ?? b['EndTime'];
          
          if (apiProfId == _myProfessorId && startTimeStr != null && endTimeStr != null) {
            final dtStart = DateTime.parse(startTimeStr.toString()).toLocal();
            final dtEnd = DateTime.parse(endTimeStr.toString()).toLocal();
            
            _blocosLivres.add(BlocoDisponibilidade(
              dayOfWeek: dtStart.weekday - 1, 
              startTime: dtStart,
              endTime: dtEnd,
            ));
          }
        }

        final endOfWeek = _segundaFeiraFoco.add(const Duration(days: 6, hours: 23, minutes: 59));

        for (var l in lessons) {
          final apiProfId = (l['idProfessor'] ?? l['IdProfessor'] ?? l['id_professor'])?.toString();
          final schedStart = l['scheduledStart'] ?? l['ScheduledStart'];
          final schedEnd = l['scheduledEnd'] ?? l['ScheduledEnd'];
          final idLesson = (l['idLesson'] ?? l['IdLesson'] ?? l['id_lesson'])?.toString() ?? '';
          final idCourse = (l['idCourse'] ?? l['IdCourse'] ?? l['id_course'])?.toString();
          
          if (apiProfId == _myProfessorId && schedStart != null && schedEnd != null) {
            final dtStart = DateTime.parse(schedStart.toString()).toLocal();
            final dtEnd = DateTime.parse(schedEnd.toString()).toLocal();
            
            if (dtStart.isAfter(_segundaFeiraFoco.subtract(const Duration(seconds: 1))) && dtStart.isBefore(endOfWeek)) {
              
              String disciplina = "Aula";
              if (idCourse != null) {
                final courseMatch = courses.where((c) => (c['idCourse'] ?? c['IdCourse'] ?? c['id_course']).toString() == idCourse).toList();
                if (courseMatch.isNotEmpty) {
                  disciplina = (courseMatch.first['name'] ?? courseMatch.first['Name']).toString();
                }
              }

              String studentName = "Aluno Desconhecido";
              String enrollmentStatus = "Scheduled"; 

              final enrollMatch = enrollments.where((e) => (e['idLesson'] ?? e['IdLesson'] ?? e['id_lesson']).toString() == idLesson).toList();

              if (enrollMatch.isEmpty) {
                continue; 
              }

              if (enrollMatch.isNotEmpty) {
                enrollmentStatus = (enrollMatch.first['status'] ?? enrollMatch.first['Status'])?.toString().toLowerCase() ?? 'scheduled';

                if (enrollmentStatus == 'canceled') {
                  continue; 
                }

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

              _aulasReais.add(AulaMarcadaAgenda(
                idLesson: idLesson,
                subject: disciplina,
                studentName: studentName,
                startTime: dtStart,
                endTime: dtEnd,
                status: enrollmentStatus, 
              ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro a carregar agenda fluida: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<BlocoDisponibilidade> _calcularBlocosLaranjasVisiveis(
    DateTime dataDesteDia,
    List<BlocoDisponibilidade> templates,
    List<AulaMarcadaAgenda> aulasDeHoje,
  ) {
    List<BlocoDisponibilidade> blocosLivres = [];
    
    for (var t in templates) {
      final start = DateTime(dataDesteDia.year, dataDesteDia.month, dataDesteDia.day, t.startTime.hour, t.startTime.minute);
      final end = DateTime(dataDesteDia.year, dataDesteDia.month, dataDesteDia.day, t.endTime.hour, t.endTime.minute);
      blocosLivres.add(BlocoDisponibilidade(dayOfWeek: t.dayOfWeek, startTime: start, endTime: end));
    }

    List<BlocoDisponibilidade> resultadoFinal = [];
    for (var bloco in blocosLivres) {
      List<BlocoDisponibilidade> pedacos = [bloco];

      for (var aula in aulasDeHoje) {
        List<BlocoDisponibilidade> novosPedacos = [];
        for (var p in pedacos) {
          if (p.endTime.compareTo(aula.startTime) <= 0 || p.startTime.compareTo(aula.endTime) >= 0) {
            novosPedacos.add(p);
          } else {
            if (p.startTime.isBefore(aula.startTime)) {
              novosPedacos.add(BlocoDisponibilidade(
                dayOfWeek: p.dayOfWeek,
                startTime: p.startTime,
                endTime: aula.startTime,
              ));
            }
            if (p.endTime.isAfter(aula.endTime)) {
              novosPedacos.add(BlocoDisponibilidade(
                dayOfWeek: p.dayOfWeek,
                startTime: aula.endTime,
                endTime: p.endTime,
              ));
            }
          }
        }
        pedacos = novosPedacos; 
      }
      resultadoFinal.addAll(pedacos);
    }

    return resultadoFinal.where((p) => p.endTime.difference(p.startTime).inMinutes >= 30).toList();
  }

  @override
  Widget build(BuildContext context) {
    final datasDaSemana = _getDatasDaSemanaExibida();
    final String mesAnoLabel = DateFormat('MMMM yyyy', 'pt_BR').format(_segundaFeiraFoco);

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (viewportHeight - 320).clamp(500.0, 800.0);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.4),
        border: Border.all(color: blockInactiveBorder, width: 1.4),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), offset: Offset(0, 2), blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeader(mesAnoLabel),
          const SizedBox(height: 20),
          _buildDaysRow(datasDaSemana),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildGridFluido(datasDaSemana),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Semana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textMuted)),
            Text(label[0].toUpperCase() + label.substring(1), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textMain)),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {
                _resetParaSemanaAtual();
                _carregarDados();
              },
              child: Text('Hoje', style: TextStyle(color: availableBorder, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            _CircleNavButton(icon: Icons.chevron_left, onTap: () => _mudarSemana(-1)),
            const SizedBox(width: 12),
            _CircleNavButton(icon: Icons.chevron_right, onTap: () => _mudarSemana(1)),
          ],
        ),
      ],
    );
  }

  Widget _buildDaysRow(List<DateTime> datas) {
    const diasLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Row(
      children: [
        const SizedBox(width: 52), 
        ...List.generate(7, (i) {
          final isHoje = DateFormat('yyyy-MM-dd').format(datas[i]) == DateFormat('yyyy-MM-dd').format(DateTime.now());
          return Expanded(
            child: Column(
              children: [
                Text(diasLabels[i], style: TextStyle(fontWeight: FontWeight.w600, color: isHoje ? availableBorder : textMain, fontSize: 14)),
                const SizedBox(height: 4),
                Text(DateFormat('dd MMM').format(datas[i]), style: TextStyle(color: isHoje ? availableBorder : textMuted, fontSize: 12, fontWeight: isHoje ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGridFluido(List<DateTime> datas) {
    final hoursList = List.generate(totalHours, (i) => startHour + i);
    final agora = DateTime.now();

    return SingleChildScrollView(
      key: _calendarioKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: hoursList.map((h) => SizedBox(
                height: hourHeight,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '${h.toString().padLeft(2, '0')}:00',
                    style: TextStyle(fontSize: 12, color: textMuted, height: 1.2),
                  ),
                ),
              )).toList(),
            ),
          ),
          
          ...List.generate(7, (dayIndex) {
            final dataDesteDia = datas[dayIndex];
            
            final blocosDeHoje = _blocosLivres.where((b) => b.dayOfWeek == dayIndex).toList();
            final aulasDeHoje = _aulasReais.where((a) => 
              a.startTime.year == dataDesteDia.year &&
              a.startTime.month == dataDesteDia.month &&
              a.startTime.day == dataDesteDia.day
            ).toList();

            final blocosLaranjaVisiveis = _calcularBlocosLaranjasVisiveis(dataDesteDia, blocosDeHoje, aulasDeHoje);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                height: totalHours * hourHeight,
                child: Stack(
                  children: [
                    Column(
                      children: List.generate(totalHours, (index) => Container(
                        height: hourHeight,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: blockInactiveBorder, width: 1)),
                        ),
                      )),
                    ),

                    ...blocosLaranjaVisiveis.map((bloco) {
                      return _buildBlock(
                        bloco.startTime, 
                        bloco.endTime, 
                        availableBg, 
                        availableBorder, 
                        Center(child: Icon(Icons.check, size: 16, color: availableBorder)), 
                        onTap: () async {
                          final result = await showDialog(
                            context: context,
                            builder: (context) => MarcarAulaDialog(
                              initialDate: dataDesteDia, 
                              initialTime: TimeOfDay(hour: bloco.startTime.hour, minute: bloco.startTime.minute),
                            ),
                          );
                          if (result == true) _carregarDados();
                        }
                      );
                    }),

                    ...aulasDeHoje.map((aula) {
                      final isPast = aula.endTime.isBefore(agora);
                      final isPending = aula.status.toLowerCase() == 'pending';

                      Color bg = lessonBg;
                      Color border = lessonBorder;
                      Color titleColor = lessonBorder;
                      Color textColor = textMain;
                      Color timeColor = textMuted;

                      if (isPast) {
                        bg = pastBg;
                        border = pastBorder;
                        titleColor = pastTextDark;
                        textColor = pastTextLight;
                        timeColor = pastTextLight;
                      } else if (isPending) {
                        bg = const Color(0xFFFEF3F2);
                        border = const Color(0xFFF04438); 
                        titleColor = const Color(0xFFB42318); 
                      }

                      String labelDisciplina = isPending ? '${aula.subject} (Pendente)' : aula.subject;

                      return _buildBlock(
                        aula.startTime, 
                        aula.endTime, 
                        bg, 
                        border, 
                        SingleChildScrollView( 
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                labelDisciplina, 
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: titleColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                aula.studentName,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${DateFormat('HH:mm').format(aula.startTime)} - ${DateFormat('HH:mm').format(aula.endTime)}',
                                style: TextStyle(fontSize: 9, color: timeColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          final msg = isPast 
                            ? 'Esta aula já terminou.' 
                            : isPending 
                                ? 'Esta aula aguarda aprovação do aluno.'
                                : 'Já tens uma aula marcada para este horário.';
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        }
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBlock(DateTime start, DateTime end, Color bg, Color border, Widget content, {required VoidCallback onTap}) {
    final double topOffset = ((start.hour - startHour) * hourHeight) + ((start.minute / 60) * hourHeight);
    final int duracaoMinutos = end.difference(start).inMinutes;
    final double blockHeight = (duracaoMinutos / 60) * hourHeight;

    if (topOffset < 0 || topOffset >= (totalHours * hourHeight)) return const SizedBox();

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      height: blockHeight,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 4), 
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: border, width: 4)), 
          ),
          alignment: Alignment.topLeft, 
          padding: duracaoMinutos < 25 
              ? const EdgeInsets.symmetric(horizontal: 6, vertical: 0)
              : const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: content,
        ),
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFEAECF0))),
        child: Icon(icon, size: 20, color: const Color(0xFF667085)),
      ),
    );
  }
}