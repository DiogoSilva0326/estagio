import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:aula_extra/features/professor/calendario/widgets/marcar_aula_dialog.dart';

class AgendaRealProfessor extends StatefulWidget {
  const AgendaRealProfessor({super.key});

  @override
  // 💡 MUDANÇA TÉCNICA: Tiramos o underscore para poder usar o GlobalKey
  State<AgendaRealProfessor> createState() => AgendaRealProfessorState();
}

class AgendaRealProfessorState extends State<AgendaRealProfessor> {
  static const List<String> _horas = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', 
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'
  ];
  
  static const List<String> _diasSemanaLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  
  late DateTime _segundaFeiraFoco;

  // Laranja
  final Set<String> _templateDisponibilidade = {};

  // 💡 REVERTIDO: Voltou a ser um Set simples apenas para marcar a posição
  final Set<String> _aulasMarcadas = {}; 

  bool _isLoading = true;
  String? _myProfessorId;

  final Color blockInactiveBg = const Color(0xFFF9FAFB);
  final Color blockInactiveBorder = const Color(0xFFEAECF0);
  
  final Color availableBg = const Color(0xFFFFF7ED);
  final Color availableBorder = const Color(0xFFFF6B00); 

  final Color lessonBg = const Color(0xFFECFDF3); 
  final Color lessonBorder = const Color(0xFF12B76A); 
  
  final Color textMain = const Color(0xFF101828);
  final Color textMuted = const Color(0xFF667085);

  @override
  void initState() {
    super.initState();
    _resetParaSemanaAtual();
    _carregarDados();
  }

  // 💡 NOVO: Função pública que pode ser chamada de fora!
  Future<void> recarregarDados() async {
    await _carregarDados();
  }

  void _resetParaSemanaAtual() {
    DateTime agora = DateTime.now();
    _segundaFeiraFoco = agora.subtract(Duration(days: agora.weekday - 1));
    _segundaFeiraFoco = DateTime(_segundaFeiraFoco.year, _segundaFeiraFoco.month, _segundaFeiraFoco.day);
  }

  void _mudarSemana(int semanas) {
    setState(() => _segundaFeiraFoco = _segundaFeiraFoco.add(Duration(days: semanas * 7)));
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
          // BLINDADO: Lê de qualquer formato!
          _myProfessorId = (profData['idProfessor'] ?? profData['IdProfessor'] ?? profData['id_professor']).toString();
        }
      }

      if (_myProfessorId != null) {
        // 1. Carregar Blocos (Laranja)
        final respBlocks = await http.get(ApiConfig.uri('/api/Schedule/blocks'), headers: {'Authorization': 'Bearer $token'});
        if (respBlocks.statusCode == 200) {
          final dynamic decodedBlocks = jsonDecode(respBlocks.body);
          List<dynamic> blocks = decodedBlocks is List ? decodedBlocks : (decodedBlocks['data'] ?? decodedBlocks['items'] ?? []);
          
          _templateDisponibilidade.clear();
          for (var b in blocks) {
            final apiProfId = (b['idProfessor'] ?? b['IdProfessor'] ?? b['id_professor'])?.toString();
            final startTime = b['startTime'] ?? b['StartTime'];
            
            if (apiProfId == _myProfessorId && startTime != null) {
              final dt = DateTime.parse(startTime.toString()).toLocal();
              final dayIdx = dt.weekday - 1; 
              final timeKey = '${dt.hour.toString().padLeft(2, '0')}:00';
              _templateDisponibilidade.add('$dayIdx-$timeKey');
            }
          }
        }

        // 2. Carregar Aulas (Verde)
        final respLessons = await http.get(ApiConfig.uri('/api/Lessons/lessons'), headers: {'Authorization': 'Bearer $token'});
        if (respLessons.statusCode == 200) {
          final dynamic decodedLessons = jsonDecode(respLessons.body);
          List<dynamic> lessons = decodedLessons is List ? decodedLessons : (decodedLessons['data'] ?? decodedLessons['items'] ?? []);
          
          _aulasMarcadas.clear();
          for (var l in lessons) {
            // BLINDADO: Não falha se o C# mandar "IdProfessor" em vez de "idProfessor"
            final apiProfId = (l['idProfessor'] ?? l['IdProfessor'] ?? l['id_professor'])?.toString();
            final schedStart = l['scheduledStart'] ?? l['ScheduledStart'];
            
            if (apiProfId == _myProfessorId && schedStart != null) {
              final dt = DateTime.parse(schedStart.toString()).toLocal();
              final dateKey = DateFormat('yyyy-MM-dd').format(dt);
              final timeKey = '${dt.hour.toString().padLeft(2, '0')}:00';
              
              _aulasMarcadas.add('$dateKey-$timeKey');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro a carregar agenda: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final datasDaSemana = _getDatasDaSemanaExibida();
    final String mesAnoLabel = DateFormat('MMMM yyyy', 'pt_BR').format(_segundaFeiraFoco);

    return Container(
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
          _isLoading 
            ? const SizedBox(height: 500, child: Center(child: CircularProgressIndicator()))
            : _buildGrid(datasDaSemana),
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
    return Row(
      children: [
        const SizedBox(width: 65),
        ...List.generate(7, (i) {
          final isHoje = DateFormat('yyyy-MM-dd').format(datas[i]) == DateFormat('yyyy-MM-dd').format(DateTime.now());
          return Expanded(
            child: Column(
              children: [
                Text(_diasSemanaLabels[i], style: TextStyle(fontWeight: FontWeight.w600, color: isHoje ? availableBorder : textMain, fontSize: 16)),
                const SizedBox(height: 4),
                Text(DateFormat('dd MMM').format(datas[i]), style: TextStyle(color: isHoje ? availableBorder : textMuted, fontSize: 13, fontWeight: isHoje ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGrid(List<DateTime> datas) {
    return SizedBox(
      height: 500,
      child: ListView.builder(
        itemCount: _horas.length,
        itemBuilder: (context, index) {
          final hora = _horas[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 65, child: Text(hora, style: TextStyle(color: textMuted, fontSize: 14))),
                for (int dayIdx = 0; dayIdx < 7; dayIdx++)
                  Expanded(child: _buildCell(dayIdx, hora, datas[dayIdx])),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(int dayIdx, String hora, DateTime dataReal) {
    final dateKey = DateFormat('yyyy-MM-dd').format(dataReal);
    final lessonKey = '$dateKey-$hora';
    
    // 💡 VERIFICAÇÃO SIMPLES REVERTIDA
    final bool hasLesson = _aulasMarcadas.contains(lessonKey);

    final templateKey = '$dayIdx-$hora';
    final isAvailable = _templateDisponibilidade.contains(templateKey);

    Color bgColor = blockInactiveBg;
    Color borderColor = blockInactiveBorder;
    Widget? content;

    // 💡 VISUAL REVERTIDO (Apenas "Ocupado" e Ícone de Certo)
    if (hasLesson) {
      bgColor = lessonBg;
      borderColor = lessonBorder;
      content = Text('Ocupado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: lessonBorder));
    } else if (isAvailable) {
      bgColor = availableBg;
      borderColor = availableBorder;
      content = Icon(Icons.check, size: 16, color: availableBorder);
    }

    return GestureDetector(
      onTap: () async {
        if (isAvailable && !hasLesson) {
          final parts = hora.split(':');
          final timeOfDay = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          
          final result = await showDialog(
            context: context,
            builder: (context) => MarcarAulaDialog(
              initialDate: dataReal, 
              initialTime: timeOfDay,
            ),
          );
          
          if (result == true) {
            _carregarDados();
          }

        } else if (hasLesson) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Já tens uma aula marcada para este horário.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este horário não está definido como disponível.')));
        }
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: (hasLesson || isAvailable) ? 1.5 : 1),
        ),
        alignment: Alignment.center,
        child: content,
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