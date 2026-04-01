import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarcarAulaDialog extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;

  const MarcarAulaDialog({super.key, this.initialDate, this.initialTime});

  @override
  State<MarcarAulaDialog> createState() => _MarcarAulaDialogState();
}

class _MarcarAulaDialogState extends State<MarcarAulaDialog> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _alunoController = TextEditingController(); 
  
  DateTime? _dataSelecionada;
  // 💡 MUDANÇA: Separado em Início e Fim
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  List<Map<String, String>> _cursos = [];
  String? _cursoSelecionadoId;

  bool _isSubmitting = false;
  bool _isLoadingCursos = true;
  String? _myProfessorId;

  final Color primaryColor = const Color(0xFFFF6B00);
  final Color successColor = const Color(0xFF12B76A);

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.initialDate;
    _horaInicio = widget.initialTime;
    
    // Se abrir pela grelha, assume automaticamente que a aula dura 1 hora
    if (widget.initialTime != null) {
      int nextHour = (widget.initialTime!.hour + 1) % 24;
      _horaFim = TimeOfDay(hour: nextHour, minute: widget.initialTime!.minute);
    }
    
    _carregarDadosIniciais(); 
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      final respProf = await http.get(ApiConfig.uri('/api/Professors/me'), headers: {'Authorization': 'Bearer $token'});
      if (respProf.statusCode == 200) {
        final profData = jsonDecode(respProf.body);
        _myProfessorId = (profData['idProfessor'] ?? profData['IdProfessor'] ?? profData['id_professor'])?.toString();
      }

      final respCourses = await http.get(ApiConfig.uri('/api/Courses/courses'), headers: {'Authorization': 'Bearer $token'});
      
      if (respCourses.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(respCourses.body);
        List<dynamic> allCourses = [];
        
        if (decodedBody is List) {
          allCourses = decodedBody;
        } else if (decodedBody is Map && decodedBody.containsKey('data')) {
          allCourses = decodedBody['data'];
        } else if (decodedBody is Map && decodedBody.containsKey('items')) {
          allCourses = decodedBody['items'];
        }

        if (mounted) {
          setState(() {
            _cursos = allCourses.where((c) {
              final courseProfId = (c['idProfessor'] ?? c['IdProfessor'] ?? c['id_professor'] ?? c['Id_Professor'])?.toString();
              return courseProfId != null && courseProfId == _myProfessorId;
            }).map((c) {
              return {
                "id": (c['idCourse'] ?? c['IdCourse'] ?? c['id_course'] ?? c['Id_Course']).toString(),
                "nome": (c['name'] ?? c['Name'] ?? 'Sem Nome').toString(),
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Erro no Dialog: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCursos = false);
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: Colors.black)), child: child!);
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() => _dataSelecionada = picked);
    }
  }

  // 💡 MUDANÇA: Uma única função para Início e Fim
  Future<void> _selecionarHora(bool isInicio) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isInicio 
          ? (_horaInicio ?? const TimeOfDay(hour: 10, minute: 0)) 
          : (_horaFim ?? const TimeOfDay(hour: 11, minute: 0)),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: Colors.black)), child: child!);
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
          // Se o utilizador não tiver hora de fim, preenchemos automaticamente para +1 hora de distância
          if (_horaFim == null) {
             _horaFim = TimeOfDay(hour: (picked.hour + 1) % 24, minute: picked.minute);
          }
        } else {
          _horaFim = picked;
        }
      });
    }
  }

  void _mostrarErro(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red, duration: const Duration(seconds: 6)));
  }

  Future<void> _gravarAula() async {
    final titulo = _tituloController.text.trim();
    final usernameAluno = _alunoController.text.trim().toLowerCase(); 

    if (_cursoSelecionadoId == null || titulo.isEmpty || usernameAluno.isEmpty || _dataSelecionada == null || _horaInicio == null || _horaFim == null) {
      _mostrarErro('Preenche todos os campos!');
      return;
    }

    final startDt = DateTime(_dataSelecionada!.year, _dataSelecionada!.month, _dataSelecionada!.day, _horaInicio!.hour, _horaInicio!.minute);
    final endDt = DateTime(_dataSelecionada!.year, _dataSelecionada!.month, _dataSelecionada!.day, _horaFim!.hour, _horaFim!.minute);

    if (endDt.isBefore(startDt)) {
      _mostrarErro('A Hora de Fim tem de ser depois da Hora de Início!');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      // 1. Procurar Aluno (mantém-se igual)
      String? idAlunoEncontrado;
      final respUsers = await http.get(ApiConfig.uri('/api/Users'), headers: {'Authorization': 'Bearer $token'});
      if (respUsers.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(respUsers.body);
        List<dynamic> users = decodedBody is List ? decodedBody : (decodedBody['data'] ?? decodedBody['items'] ?? []);
        for (var u in users) {
          final apiUsername = (u['username'] ?? u['userName'] ?? '').toString().toLowerCase().trim();
          if (apiUsername == usernameAluno) {
            idAlunoEncontrado = (u['idUser'] ?? u['IdUser'] ?? u['id']).toString();
            break; 
          }
        }
      }

      if (idAlunoEncontrado == null) {
        _mostrarErro('Aluno não encontrado.');
        setState(() => _isSubmitting = false);
        return;
      }

      final String startStr = DateFormat("yyyy-MM-ddTHH:mm:ss").format(startDt);
      final String endStr = DateFormat("yyyy-MM-ddTHH:mm:ss").format(endDt);
      final int durationMinutes = endDt.difference(startDt).inMinutes;

      final respLesson = await http.post(
        ApiConfig.uri('/api/Lessons/lessons'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          "idProfessor": _myProfessorId,
          "idCourse": _cursoSelecionadoId, 
          "title": titulo,
          "scheduledStart": startStr, 
          "scheduledEnd": endStr,     
          "durationMinutes": durationMinutes,
          "status": "Scheduled"
        }),
      );

      if (respLesson.statusCode == 200 || respLesson.statusCode == 201) {
        final lessonData = jsonDecode(respLesson.body);
        final idLessonCriada = (lessonData['idLesson'] ?? lessonData['IdLesson']).toString();

        final respEnrollment = await http.post(
          ApiConfig.uri('/api/Lessons/enrollments'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            "idEnrollment": "00000000-0000-0000-0000-000000000000",
            "idLesson": idLessonCriada,
            "idUser": idAlunoEncontrado, 
            "status": "Active",
            "pricePaid": 0.0
          }),
        );

        if (respEnrollment.statusCode == 200 || respEnrollment.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula marcada com sucesso!'), backgroundColor: Colors.green));
            Navigator.pop(context, true); 
          }
        }
      }
    } catch (e) {
      _mostrarErro('Erro: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Marcar Nova Aula', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Curso / Disciplina:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
              child: _isLoadingCursos
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Seleciona a Disciplina'),
                        value: _cursoSelecionadoId,
                        items: _cursos.map((curso) {
                          return DropdownMenuItem<String>(
                            value: curso['id'],
                            child: Text(curso['nome']!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) => setState(() => _cursoSelecionadoId = newValue),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            const Text('Tópico / Assunto da Aula:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Ex: Preparação para o Teste',
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryColor, width: 2)),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Username do Aluno:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _alunoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Ex: joao.silva (ou email)',
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryColor, width: 2)),
              ),
            ),
            const SizedBox(height: 20),

            // 💡 DATA EM DESTAQUE
            const Text('Data da Aula:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selecionarData,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_dataSelecionada == null ? 'Escolher Data' : DateFormat('dd/MM/yyyy').format(_dataSelecionada!)),
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 💡 INÍCIO E FIM LADO A LADO
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hora Início:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selecionarHora(true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_horaInicio == null ? '--:--' : _horaInicio!.format(context)),
                              const Icon(Icons.access_time, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hora Fim:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selecionarHora(false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_horaFim == null ? '--:--' : _horaFim!.format(context)),
                              const Icon(Icons.access_time_filled, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: successColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: _isSubmitting ? null : _gravarAula,
          child: _isSubmitting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}