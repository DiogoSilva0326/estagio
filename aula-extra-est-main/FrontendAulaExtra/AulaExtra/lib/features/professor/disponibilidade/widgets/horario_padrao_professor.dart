import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/disponibilidade_professor_constants.dart';

class HorarioPadraoProfessor extends StatefulWidget {
  const HorarioPadraoProfessor({super.key});

  @override
  State<HorarioPadraoProfessor> createState() => _HorarioPadraoProfessorState();
}

class _HorarioPadraoProfessorState extends State<HorarioPadraoProfessor> {
  static const List<String> _horas = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', 
    '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'
  ];
  
  static const List<String> _diasSemanaLabels = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];
  
  final Set<String> _templateDisponibilidade = {};
  final Map<String, List<String>> _blocosNaBD = {}; 
  final Map<int, String> _mapaIdsDias = {}; 

  bool _isLoading = true;
  bool _isSaving = false;
  String? _myProfessorId;

  @override
  void initState() {
    super.initState();
    _iniciarConfiguracao();
  }

  Future<void> _iniciarConfiguracao() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final token = await TokenStorage().loadToken() ?? '';
      
      final respProf = await http.get(ApiConfig.uri('/api/Professors/me'), headers: {'Authorization': 'Bearer $token'});
      if (respProf.statusCode == 200) {
        final profData = jsonDecode(respProf.body);
        _myProfessorId = (profData['idProfessor'] ?? profData['IdProfessor']).toString();
      }

      try {
        final respDays = await http.get(ApiConfig.uri('/api/Schedule/days'), headers: {'Authorization': 'Bearer $token'});
        if (respDays.statusCode == 200) {
          final List<dynamic> daysData = jsonDecode(respDays.body);
          for (var d in daysData) {
            _mapaIdsDias[d['dayIndex']] = d['idDay'].toString();
          }
        }
      } catch (_) { }

      if (_myProfessorId != null) {
        await _carregarBlocos(token);
      }
    } catch (e) {
      debugPrint('Erro no setup: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _carregarBlocos(String token) async {
    try {
      final response = await http.get(
        ApiConfig.uri('/api/Schedule/blocks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> blocks = jsonDecode(response.body);
        
        if (mounted) {
          setState(() {
            _blocosNaBD.clear();
            _templateDisponibilidade.clear();
            
            for (var b in blocks) {
              if (b['idProfessor'].toString() == _myProfessorId && b['startTime'] != null) {
                final dt = DateTime.parse(b['startTime']).toLocal();
                final dayIdx = dt.weekday - 1; 
                final timeKey = '${dt.hour.toString().padLeft(2, '0')}:00';
                final key = '$dayIdx-$timeKey';
                
                _templateDisponibilidade.add(key);
                
                if (!_blocosNaBD.containsKey(key)) {
                  _blocosNaBD[key] = [];
                }
                _blocosNaBD[key]!.add(b['idScheduleBlock'].toString());
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar blocos: $e');
    }
  }

  Future<void> _guardarHorarioFixo() async {
    if (_myProfessorId == null) return;
    
    setState(() => _isSaving = true);
    final token = await TokenStorage().loadToken() ?? '';

    try {
      // 1. Apagar os blocos que foram desmarcados
      final removidos = _blocosNaBD.keys.where((k) => !_templateDisponibilidade.contains(k)).toList();
      for (var key in removidos) {
        final idsParaApagar = _blocosNaBD[key]!;
        for (var id in idsParaApagar) {
          await http.delete(ApiConfig.uri('/api/Schedule/blocks/$id'), headers: {'Authorization': 'Bearer $token'});
        }
        _blocosNaBD.remove(key); 
      }

      final novos = _templateDisponibilidade.where((k) => !_blocosNaBD.containsKey(k)).toList();
      for (var key in novos) {
        final parts = key.split('-');
        final dayIdx = int.parse(parts[0]);
        final hour = int.parse(parts[1].substring(0, 2));

        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final targetDate = monday.add(Duration(days: dayIdx));
        
        final startLocal = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, 0);

        String? idDayDaBD;
        _mapaIdsDias.forEach((idx, uuid) { if(idx == dayIdx) idDayDaBD = uuid; });

        final String startStr = "${startLocal.year.toString().padLeft(4, '0')}-${startLocal.month.toString().padLeft(2, '0')}-${startLocal.day.toString().padLeft(2, '0')}T${startLocal.hour.toString().padLeft(2, '0')}:00:00";
        final String endStr = "${startLocal.year.toString().padLeft(4, '0')}-${startLocal.month.toString().padLeft(2, '0')}-${startLocal.day.toString().padLeft(2, '0')}T${(startLocal.hour + 1).toString().padLeft(2, '0')}:00:00";

        final response = await http.post(
          ApiConfig.uri('/api/Schedule/blocks'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
          body: jsonEncode({
            "idProfessor": _myProfessorId,
            "idDay": idDayDaBD,
            "startTime": startStr,
            "endTime": endStr,     
            "isAvailable": true,
            "defaultDurationMinutes": 60,
            "recurrenceRule": "FREQ=WEEKLY" 
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          _blocosNaBD[key] = [data['idScheduleBlock'].toString()];
        }
      }

      await _carregarBlocos(token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horário guardado com sucesso!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Erro ao guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Define aqui o teu horário semanal. Este é o calendário que os teus alunos vão ver no teu perfil.", 
          style: TextStyle(color: Color(0xFF667085), fontSize: 16)),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DisponibilidadeProfessorConstants.cardRadius),
            boxShadow: DisponibilidadeProfessorConstants.cardShadow,
            border: Border.all(color: DisponibilidadeProfessorConstants.blockInactiveBorder, width: DisponibilidadeProfessorConstants.cardBorderWidth),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 65),
                  for (var dia in _diasSemanaLabels)
                    Expanded(child: Center(child: Text(dia.substring(0,3), style: DisponibilidadeProfessorConstants.gridHeaderStyle))),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: _horas.length,
                  itemBuilder: (context, index) {
                    final hora = _horas[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 65, child: Text(hora, style: const TextStyle(color: Color(0xFF667085)))),
                          for (int dayIdx = 0; dayIdx < 7; dayIdx++)
                            Expanded(child: _buildGridBlock(dayIdx, hora)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridBlock(int dayIdx, String hora) {
    final key = '$dayIdx-$hora';
    final isSelected = _templateDisponibilidade.contains(key);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _templateDisponibilidade.remove(key);
          } else {
            _templateDisponibilidade.add(key);
          }
        });
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? DisponibilidadeProfessorConstants.blockActiveBg : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? DisponibilidadeProfessorConstants.blockActiveBorder : const Color(0xFFEAECF0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: isSelected ? Icon(Icons.check, size: 16, color: DisponibilidadeProfessorConstants.blockActiveBorder) : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: DisponibilidadeProfessorConstants.blockActiveBorder,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _isSaving ? null : _guardarHorarioFixo,
        child: _isSaving 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Guardar Horário Fixo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}