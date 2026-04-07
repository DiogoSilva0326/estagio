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
  int _currentStep = 0; // 0: Alunos, 1: Áreas, 2: Data/Hora, 3: Revisão

  bool _isLoadingDados = true;
  bool _isSubmitting = false;
  String? _myProfessorId;

  List<Map<String, dynamic>> _alunos = [];
  List<Map<String, dynamic>> _cursos = [];

  Map<String, dynamic>? _alunoSelecionado;
  Map<String, dynamic>? _cursoSelecionado;
  
  late DateTime _dataSelecionada;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFim;

  final Color primaryOrange = const Color(0xFFFF8A4C);
  final Color darkOrange = const Color(0xFFFF6B00);
  final Color textMain = const Color(0xFF101828);

  @override
  void initState() {
    super.initState();
    _dataSelecionada = widget.initialDate ?? DateTime.now();
    _horaInicio = widget.initialTime ?? const TimeOfDay(hour: 10, minute: 0);
    
    int nextHour = (_horaInicio.hour + 1) % 24;
    _horaFim = TimeOfDay(hour: nextHour, minute: _horaInicio.minute);
    
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      // 1. Obter o meu ID de Professor e ID de Utilizador
      String? myProfId;
      String? myUserId;

      final respProf = await http.get(ApiConfig.uri('/api/Professors/me'), headers: {'Authorization': 'Bearer $token'});
      if (respProf.statusCode == 200) {
        final profData = jsonDecode(respProf.body);
        myProfId = (profData['idProfessor'] ?? profData['IdProfessor'] ?? profData['id_professor'])?.toString();
        // A API de Professors/me deve devolver também o idUser, mas pelo sim pelo não, 
        // vamos descodificar do Token JWT (como fazes na página de Chats)
        try {
          final payloadBase64 = token.split('.')[1];
          final normalized = base64Url.normalize(payloadBase64);
          final payloadMap = jsonDecode(utf8.decode(base64Url.decode(normalized)));
          myUserId = payloadMap['sub']?.toString();
        } catch (_) {}
      }

      if (myProfId == null || myUserId == null) {
        throw Exception("Não foi possível identificar o Professor ou o User ID.");
      }
      _myProfessorId = myProfId;

      // 2. Carregar Cursos, Users e MENSAGENS!
      final respCourses = await http.get(ApiConfig.uri('/api/Courses/courses'), headers: {'Authorization': 'Bearer $token'});
      final respUsers = await http.get(ApiConfig.uri('/api/Users'), headers: {'Authorization': 'Bearer $token'});
      final respMessages = await http.get(ApiConfig.uri('/api/Communication/messages'), headers: {'Authorization': 'Bearer $token'});

      List<dynamic> extractList(http.Response res) {
        if (res.statusCode != 200) return [];
        final body = jsonDecode(res.body);
        return body is List ? body : (body['data'] ?? body['items'] ?? []);
      }

      final allCourses = extractList(respCourses);
      final allUsers = extractList(respUsers);
      final allMessages = extractList(respMessages);

      if (mounted) {
        setState(() {
          // A. Filtrar os cursos do Professor
          _cursos = allCourses.where((c) {
            final courseProfId = (c['idProfessor'] ?? c['IdProfessor'] ?? c['id_professor'])?.toString();
            return courseProfId == _myProfessorId;
          }).map((c) => {
            "id": (c['idCourse'] ?? c['IdCourse'] ?? c['id_course']).toString(),
            "nome": (c['name'] ?? c['Name'] ?? 'Sem Nome').toString(),
          }).toList();

          // B. Encontrar os IDs de todos os Utilizadores com quem tenho CHAT ABERTO
          Set<String> idAlunosComChat = {};
          
          for (var m in allMessages) {
            final sender = m['senderUserId']?.toString() ?? '';
            final receiver = m['receiverUserId']?.toString() ?? '';
            
            // Se eu for o remetente, o aluno é o recetor. Se eu for o recetor, o aluno é o remetente.
            if (sender == myUserId && receiver.isNotEmpty) {
              idAlunosComChat.add(receiver);
            } else if (receiver == myUserId && sender.isNotEmpty) {
              idAlunosComChat.add(sender);
            }
          }

          // C. Filtrar a lista total de Users para mostrar APENAS os alunos com chat
          _alunos = allUsers.where((u) {
            final idU = (u['idUser'] ?? u['IdUser'] ?? u['id']).toString();
            return idAlunosComChat.contains(idU); // 💡 FILTRO FINAL AQUI!
          }).map((u) {
            final firstName = u['firstName'] ?? u['FirstName'] ?? '';
            final lastName = u['lastName'] ?? u['LastName'] ?? '';
            final username = u['username'] ?? u['UserName'] ?? 'Utilizador';
            
            String nomeExibicao = (firstName.isNotEmpty || lastName.isNotEmpty) 
                ? '$firstName $lastName'.trim() 
                : username;

            return {
              "id": (u['idUser'] ?? u['IdUser'] ?? u['id']).toString(),
              "nome": nomeExibicao,
              "iniciais": nomeExibicao.isNotEmpty ? nomeExibicao[0].toUpperCase() : 'A',
            };
          }).toList();
          
          _isLoadingDados = false;
        });
      }
    } catch (e) {
      debugPrint('Erro no Wizard: $e');
      if (mounted) setState(() => _isLoadingDados = false);
    }
  }

  Future<void> _gravarAula() async {
    if (_cursoSelecionado == null || _alunoSelecionado == null) return;
    setState(() => _isSubmitting = true);

    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      final startDt = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day, _horaInicio.hour, _horaInicio.minute);
      final endDt = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day, _horaFim.hour, _horaFim.minute);

      final String startStr = DateFormat("yyyy-MM-ddTHH:mm:ss").format(startDt);
      final String endStr = DateFormat("yyyy-MM-ddTHH:mm:ss").format(endDt);
      final int durationMinutes = endDt.difference(startDt).inMinutes;
      final tituloAutomatico = "Aula de ${_cursoSelecionado!['nome']}";

      // 1. CRIAR A AULA (LESSON)
      final respLesson = await http.post(
        ApiConfig.uri('/api/Lessons/lessons'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          "idProfessor": _myProfessorId,
          "idCourse": _cursoSelecionado!['id'], 
          "title": tituloAutomatico,
          "scheduledStart": startStr, 
          "scheduledEnd": endStr,    
          "durationMinutes": durationMinutes,
          "status": "Pending" 
        }),
      );

      if (respLesson.statusCode == 200 || respLesson.statusCode == 201) {
        final lessonData = jsonDecode(respLesson.body);
        final idLessonCriada = (lessonData['idLesson'] ?? lessonData['IdLesson']).toString();

        // 2. CRIAR A INSCRIÇÃO (ENROLLMENT)
        final respEnrollment = await http.post(
          ApiConfig.uri('/api/Lessons/enrollments'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            "idEnrollment": "00000000-0000-0000-0000-000000000000",
            "idLesson": idLessonCriada,
            "idUser": _alunoSelecionado!['id'], 
            "status": "Pending", 
            "pricePaid": 0.0
          }),
        );

        if (respEnrollment.statusCode == 200 || respEnrollment.statusCode == 201) {
          final enrollmentData = jsonDecode(respEnrollment.body);
          final idEnrollmentCriado = (enrollmentData['idEnrollment'] ?? enrollmentData['IdEnrollment']).toString();
          
          // 3. CRIAR OS DADOS DA NOTIFICAÇÃO
          final startFormatted = DateFormat('dd/MM/yyyy HH:mm').format(startDt);
          final msgDescritiva = 'Foi marcada uma aula de ${_cursoSelecionado!['nome']} para $startFormatted. Por favor, confirma a tua disponibilidade!';
          
          final msgNotificacao = jsonEncode({
            "text": msgDescritiva,
            "idEnrollment": idEnrollmentCriado,
            "idLesson": idLessonCriada
          });

          // 4. ENVIAR NOTIFICAÇÃO AO ALUNO
          final respNotif = await http.post(
            ApiConfig.uri('/api/Communication/notifications'),
            headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
            body: jsonEncode({
              "IdUser": _alunoSelecionado!['id'],
              "Type": "Aula Pendente",            
              "Message": msgNotificacao, 
              "WasRead": false,                  
              "CreatedAt": DateTime.now().toUtc().toIso8601String(),
              "UpdatedAt": DateTime.now().toUtc().toIso8601String()
            }),
          );

          // 5. IMPRIMIR O RESULTADO DA NOTIFICAÇÃO NA CONSOLA DO VS CODE
          debugPrint('==== TESTE DE NOTIFICAÇÃO ====');
          debugPrint('STATUS CODE: ${respNotif.statusCode}');
          debugPrint('RESPOSTA: ${respNotif.body}');
          debugPrint('==============================');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aula marcada e notificação enviada ao aluno!'), backgroundColor: Colors.orange));
            Navigator.pop(context, true); 
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _nextStep() => setState(() => _currentStep++);
  void _previousStep() => setState(() => _currentStep--);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, 
      backgroundColor: const Color(0xFFF9FAFB),
      child: SizedBox(
        width: 700, 
        child: _isLoadingDados 
          ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStepContent(),
            ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildStepAlunos();
      case 1: return _buildStepAreas();
      case 2: return _buildStepDataHora(); // 💡 PASSO RECUPERADO
      case 3: return _buildStepRevisao();
      default: return const SizedBox();
    }
  }

  // ==========================================
  // PASSO 1: ALUNOS
  // ==========================================
  Widget _buildStepAlunos() {
    return Column(
      key: const ValueKey('step_alunos'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: primaryOrange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Marcar aula', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_alunos.length} alunos', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seus Alunos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
              const SizedBox(height: 16),
              Expanded(
                child: _alunos.isEmpty 
                  ? const Center(child: Text("Não tens alunos na tua lista de chats/aulas."))
                  : ListView.separated(
                      itemCount: _alunos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final aluno = _alunos[index];
                        return _buildStudentCard(aluno);
                      },
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFFF9FAFB),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar', style: TextStyle(color: Color(0xFF667085), fontSize: 16)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('Adicionar Aluno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> aluno) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blueAccent,
                child: Text(aluno['iniciais'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(aluno['nome'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textMain)),
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('Aluno', style: TextStyle(color: Color(0xFF667085), fontSize: 14)),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange, 
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    _alunoSelecionado = aluno;
                    _nextStep(); // -> Áreas
                  },
                  child: const Text('Marcar Aula', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ==========================================
  // PASSO 2: ÁREAS
  // ==========================================
  Widget _buildStepAreas() {
    return Column(
      key: const ValueKey('step_areas'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios, color: textMain, size: 20), onPressed: _previousStep),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Escolha uma Área', style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Selecione a disciplina que deseja lecionar', style: TextStyle(color: Color(0xFF667085), fontSize: 14)),
                    ],
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, color: Color(0xFF667085)), onPressed: () => Navigator.of(context).pop())
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          height: 350, 
          child: _cursos.isEmpty 
            ? const Center(child: Text("Não tens disciplinas associadas ao teu perfil."))
            : SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _cursos.map((c) => _buildAreaCard(c)).toList(),
                ),
              ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFFF9FAFB),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_cursoSelecionado?['nome'] ?? 'Nenhuma área selecionada', style: const TextStyle(color: Color(0xFF667085), fontSize: 16)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cursoSelecionado != null ? const Color(0xFFD0D5DD) : const Color(0xFFEAECF0),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _cursoSelecionado != null ? () => _nextStep() : null, // -> Data/Hora
                child: Text('Confirmar Seleção', style: TextStyle(color: _cursoSelecionado != null ? textMain : const Color(0xFF98A2B3), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAreaCard(Map<String, dynamic> curso) {
    bool isSelected = _cursoSelecionado != null && _cursoSelecionado!['id'] == curso['id'];
    IconData icone = Icons.book;
    final nomeLower = curso['nome'].toString().toLowerCase();
    if (nomeLower.contains('matemática')) icone = Icons.calculate;
    if (nomeLower.contains('física') || nomeLower.contains('química')) icone = Icons.science;
    if (nomeLower.contains('inglês') || nomeLower.contains('português')) icone = Icons.translate;

    return GestureDetector(
      onTap: () => setState(() => _cursoSelecionado = curso),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? darkOrange : const Color(0xFFEAECF0), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [const BoxShadow(color: Color.fromRGBO(255, 107, 0, 0.1), blurRadius: 8)] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
              child: Icon(icone, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(curso['nome'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textMain)),
                  const Text('Selecionar disciplina', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PASSO 3: DATA E HORA (O Passo que faltava!)
  // ==========================================
  Widget _buildStepDataHora() {
    return Column(
      key: const ValueKey('step_datahora'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios, color: textMain, size: 20), onPressed: _previousStep),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Definir Horário', style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Confirma ou ajusta a hora da aula', style: TextStyle(color: Color(0xFF667085), fontSize: 14)),
                    ],
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, color: Color(0xFF667085)), onPressed: () => Navigator.of(context).pop())
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data da Aula:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dataSelecionada,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _dataSelecionada = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                      const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora Início:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _horaInicio);
                            if (picked != null) setState(() { _horaInicio = picked; });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_horaInicio.format(context)),
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
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _horaFim);
                            if (picked != null) setState(() { _horaFim = picked; });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_horaFim.format(context)),
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
        Container(
          padding: const EdgeInsets.all(24),
          color: const Color(0xFFF9FAFB),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _nextStep, // -> Revisão
                child: const Text('Avançar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ==========================================
  // PASSO 4: REVISÃO (Bug visual resolvido!)
  // ==========================================
  Widget _buildStepRevisao() {
    final startStr = '${_horaInicio.hour.toString().padLeft(2, '0')}:${_horaInicio.minute.toString().padLeft(2, '0')}';
    final endStr = '${_horaFim.hour.toString().padLeft(2, '0')}:${_horaFim.minute.toString().padLeft(2, '0')}';
    
    final diasStr = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    final mesesStr = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final dataDescritiva = '${diasStr[_dataSelecionada.weekday - 1]}, ${_dataSelecionada.day} ${mesesStr[_dataSelecionada.month - 1]}';

    return Column(
      key: const ValueKey('step_revisao'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          color: primaryOrange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: _previousStep),
                  const SizedBox(width: 8),
                  const Text('Revisão da marcação', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop())
            ],
          ),
        ),

        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(40),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAECF0), width: 1.5),
              boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: Text(_alunoSelecionado?['iniciais'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                // 💡 CORREÇÃO DO OVERFLOW: Troquei a Row interna por Wrap para o texto não bater nos botões
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_alunoSelecionado?['nome'] ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textMain)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(20)),
                            child: Text(_cursoSelecionado?['nome'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          Text(dataDescritiva, style: const TextStyle(color: Color(0xFF667085), fontSize: 14)),
                          Text('$startStr - $endStr', style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  label: const Text('Cancelar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _gravarAula,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Enviar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}