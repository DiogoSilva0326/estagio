import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_colors.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_layout.dart';
import 'package:aula_extra/features/professor/disponibilidade/widgets/disponibilidade_professor_mobile_day_card.dart';
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HorarioPadraoProfessor extends StatefulWidget {
  const HorarioPadraoProfessor({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<HorarioPadraoProfessor> createState() => _HorarioPadraoProfessorState();
}

class _HorarioPadraoProfessorState extends State<HorarioPadraoProfessor> {
  static const List<String> _diasSemanaLabels = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo',
  ];
  static const double _slotHeight = 32;
  static const int _slotDurationMinutes = 30;

  final Set<String> _templateDisponibilidade = <String>{};
  final Map<String, List<String>> _blocosNaBD = <String, List<String>>{};
  final Map<int, String> _mapaIdsDias = <int, String>{};

  bool _isLoading = true;
  bool _isSaving = false;
  String? _myProfessorId;

  List<String> get _slots => List<String>.generate(48, (index) {
    final hour = (index ~/ 2).toString().padLeft(2, '0');
    final minute = index.isEven ? '00' : '30';
    return '$hour:$minute';
  }, growable: false);

  List<String> get _hourSlots => List<String>.generate(24, (index) {
    final hour = index.toString().padLeft(2, '0');
    return '$hour:00';
  }, growable: false);

  Object? _readJsonValue(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    return json[camelKey] ?? json[pascalKey];
  }

  String? _readJsonString(
    Map<String, dynamic> json,
    String camelKey,
    String pascalKey,
  ) {
    final value = _readJsonValue(json, camelKey, pascalKey);
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }

  int _normalizeBackendDayIndex(Object? rawDayIndex) {
    final parsed = rawDayIndex is num
        ? rawDayIndex.toInt()
        : int.tryParse(rawDayIndex?.toString() ?? '');
    if (parsed == null) return -1;
    if (parsed >= 0 && parsed <= 6) return parsed;
    if (parsed >= 1 && parsed <= 7) return parsed - 1;
    return -1;
  }

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

      final respProf = await http.get(
        ApiConfig.uri('/api/Professors/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (respProf.statusCode == 200) {
        final profData = jsonDecode(respProf.body) as Map<String, dynamic>;
        _myProfessorId = _readJsonString(
          profData,
          'idProfessor',
          'IdProfessor',
        );
      }

      try {
        final respDays = await http.get(
          ApiConfig.uri('/api/Schedule/days'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (respDays.statusCode == 200) {
          final daysData = jsonDecode(respDays.body) as List<dynamic>;
          for (final dynamic day in daysData) {
            if (day is! Map<String, dynamic>) continue;
            final dayIndex = _readJsonValue(day, 'dayIndex', 'DayIndex');
            final idDay = _readJsonString(day, 'idDay', 'IdDay');
            final normalizedDayIndex = _normalizeBackendDayIndex(dayIndex);
            if (normalizedDayIndex != -1 && idDay != null) {
              _mapaIdsDias[normalizedDayIndex] = idDay;
            }
          }
        }
      } catch (_) {}

      if (_myProfessorId != null) {
        await _carregarBlocos(token);
      }
    } catch (error) {
      debugPrint('Erro no setup: $error');
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

      if (response.statusCode != 200) return;

      final blocks = jsonDecode(response.body) as List<dynamic>;

      if (!mounted) return;
      setState(() {
        _blocosNaBD.clear();
        _templateDisponibilidade.clear();

        for (final dynamic block in blocks) {
          if (block is! Map<String, dynamic>) continue;
          final blockProfessorId = _readJsonString(
            block,
            'idProfessor',
            'IdProfessor',
          );
          if (blockProfessorId != _myProfessorId) continue;

          final startTimeRaw = _readJsonString(block, 'startTime', 'StartTime');
          if (startTimeRaw == null) continue;

          final blockId = _readJsonString(
            block,
            'idScheduleBlock',
            'IdScheduleBlock',
          );
          if (blockId == null) continue;

          final startTime = DateTime.parse(startTimeRaw).toLocal();
          final dayIdx = startTime.weekday - 1;
          final key = _buildSlotKey(dayIdx, _formatTime(startTime));

          _templateDisponibilidade.add(key);
          _blocosNaBD.putIfAbsent(key, () => <String>[]);
          _blocosNaBD[key]!.add(blockId);
        }
      });
    } catch (error) {
      debugPrint('Erro ao carregar blocos: $error');
    }
  }

  Future<void> _guardarHorarioFixo() async {
    if (_myProfessorId == null) return;

    setState(() => _isSaving = true);
    final token = await TokenStorage().loadToken() ?? '';
    final desiredSlots = Set<String>.from(_templateDisponibilidade);

    try {
      var createdCount = 0;
      final removidos = _blocosNaBD.keys
          .where((key) => !_templateDisponibilidade.contains(key))
          .toList(growable: false);

      for (final key in removidos) {
        final idsParaApagar = List<String>.from(
          _blocosNaBD[key] ?? const <String>[],
        );
        for (final id in idsParaApagar) {
          await http.delete(
            ApiConfig.uri('/api/Schedule/blocks/$id'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
        _blocosNaBD.remove(key);
      }

      final novos = _templateDisponibilidade
          .where((key) => !_blocosNaBD.containsKey(key))
          .toList(growable: false);

      for (final key in novos) {
        final slotInfo = _parseSlotKey(key);
        final idDayDaBD = _mapaIdsDias[slotInfo.dayIndex];

        final targetDate = _dateForCurrentWeek(slotInfo.dayIndex);
        final startLocal = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          slotInfo.hour,
          slotInfo.minute,
        );
        final endLocal = startLocal.add(
          const Duration(minutes: _slotDurationMinutes),
        );

        final response = await http.post(
          ApiConfig.uri('/api/Schedule/blocks'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'idProfessor': _myProfessorId,
            'idDay': idDayDaBD,
            'startTime': _formatApiDateTime(startLocal),
            'endTime': _formatApiDateTime(endLocal),
            'isAvailable': true,
            'defaultDurationMinutes': _slotDurationMinutes,
            'recurrenceRule': 'FREQ=WEEKLY',
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          createdCount += 1;
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final createdBlockId = _readJsonString(
            data,
            'idScheduleBlock',
            'IdScheduleBlock',
          );
          if (createdBlockId != null) {
            _blocosNaBD[key] = <String>[createdBlockId];
          }
        }
      }

      await _carregarBlocos(token);

      final missingSlots = desiredSlots.difference(_templateDisponibilidade);
      final hasVerificationMismatch = missingSlots.isNotEmpty;

      if (!mounted) return;
      if (hasVerificationMismatch) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              createdCount == 0
                  ? 'Não foi possível persistir os horários selecionados. Verifica os dados do professor e tenta novamente.'
                  : 'Alguns horários não ficaram persistidos corretamente. Tenta novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horário guardado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      debugPrint('Erro ao guardar: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível guardar o horário.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _buildSlotKey(int dayIdx, String time) => '$dayIdx-$time';

  _ParsedSlot _parseSlotKey(String key) {
    final parts = key.split('-');
    final timeParts = parts[1].split(':');
    return _ParsedSlot(
      dayIndex: int.parse(parts[0]),
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  DateTime _dateForCurrentWeek(int dayIdx) {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: dayIdx));
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatApiDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day'
        'T$hour:$minute:00';
  }

  void _toggleSlot(int dayIdx, String time) {
    final key = _buildSlotKey(dayIdx, time);
    setState(() {
      if (_templateDisponibilidade.contains(key)) {
        _templateDisponibilidade.remove(key);
      } else {
        _templateDisponibilidade.add(key);
      }
    });
  }

  bool _isHourSelected(int dayIdx, int hourIndex) {
    final hour = hourIndex.toString().padLeft(2, '0');
    final primaryKey = _buildSlotKey(dayIdx, '$hour:00');
    final secondaryKey = _buildSlotKey(dayIdx, '$hour:30');
    return _templateDisponibilidade.contains(primaryKey) ||
        _templateDisponibilidade.contains(secondaryKey);
  }

  void _toggleHourSlot(int dayIdx, int hourIndex) {
    final hour = hourIndex.toString().padLeft(2, '0');
    final primaryKey = _buildSlotKey(dayIdx, '$hour:00');
    final secondaryKey = _buildSlotKey(dayIdx, '$hour:30');
    final isSelected =
        _templateDisponibilidade.contains(primaryKey) ||
        _templateDisponibilidade.contains(secondaryKey);

    setState(() {
      if (isSelected) {
        _templateDisponibilidade.remove(primaryKey);
        _templateDisponibilidade.remove(secondaryKey);
      } else {
        _templateDisponibilidade.add(primaryKey);
        _templateDisponibilidade.add(secondaryKey);
      }
    });
  }

  void _clearDay(int dayIdx) {
    setState(() {
      for (var hourIndex = 0; hourIndex < 24; hourIndex++) {
        final hour = hourIndex.toString().padLeft(2, '0');
        _templateDisponibilidade.remove(_buildSlotKey(dayIdx, '$hour:00'));
        _templateDisponibilidade.remove(_buildSlotKey(dayIdx, '$hour:30'));
      }
    });
  }

  Widget _buildDesktopContent(TeachingRoleConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.disponibilidade.pageDescription,
          style: const TextStyle(
            color: DisponibilidadeProfessorColors.muted,
            fontSize: 16,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              DisponibilidadeProfessorLayout.cardRadius,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(16, 24, 40, 0.06),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: DisponibilidadeProfessorColors.cardBorder,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: DisponibilidadeProfessorLayout.tableHourColumnWidth,
                  ),
                  for (final dia in _diasSemanaLabels)
                    Expanded(
                      child: Center(
                        child: Text(
                          dia.substring(0, 3),
                          style: const TextStyle(
                            color: DisponibilidadeProfessorColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 620,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    itemCount: _slots.length,
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      final isHalfHour = slot.endsWith(':30');

                      return Padding(
                        padding: EdgeInsets.only(bottom: isHalfHour ? 4 : 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: DisponibilidadeProfessorLayout
                                  .tableHourColumnWidth,
                              child: Text(
                                slot,
                                style: TextStyle(
                                  color: isHalfHour
                                      ? const Color(0xFF98A2B3)
                                      : DisponibilidadeProfessorColors.muted,
                                  fontSize: isHalfHour ? 12 : 13,
                                  fontWeight: isHalfHour
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            for (int dayIdx = 0; dayIdx < 7; dayIdx++)
                              Expanded(child: _buildGridBlock(dayIdx, slot, config)), 
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSaveButton(config),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTopBar(TeachingRoleConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Text(
            'Disponibilidade',
            style: TextStyle(
              color: DisponibilidadeProfessorColors.title,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 36 / 30,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildSaveButton(config, isMobile: true),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: DisponibilidadeProfessorLayout.mobileLegendDotSize,
          height: DisponibilidadeProfessorLayout.mobileLegendDotSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: DisponibilidadeProfessorColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 18 / 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(TeachingRoleConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobileTopBar(config),
        const SizedBox(height: 16),
        const Text(
          'Marque os seus horários disponíveis. Cada bloco representa uma hora e pode limpar rapidamente um dia inteiro.',
          style: TextStyle(
            color: DisponibilidadeProfessorColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: DisponibilidadeProfessorLayout.mobileSectionGap),
        Column(
          children: List.generate(_diasSemanaLabels.length, (dayIdx) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: dayIdx == _diasSemanaLabels.length - 1 ? 0 : 14,
              ),
              child: DisponibilidadeProfessorMobileDayCard(
                dayLabel: _diasSemanaLabels[dayIdx],
                slots: _hourSlots,
                isSelected: (hourIndex) => _isHourSelected(dayIdx, hourIndex),
                onToggleSlot: (hourIndex) => _toggleHourSlot(dayIdx, hourIndex),
                onClearDay: () => _clearDay(dayIdx),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            _buildLegendItem(
              color: config.primaryColor, 
              label: 'Disponível',
            ),
            _buildLegendItem(
              color: const Color(0xFFD5D7DA),
              label: 'Indisponível',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.isMobile) {
      return _buildMobileContent(config);
    }

    return _buildDesktopContent(config);
  }

  Widget _buildGridBlock(int dayIdx, String time, TeachingRoleConfig config) {
    final key = _buildSlotKey(dayIdx, time);
    final isSelected = _templateDisponibilidade.contains(key);

    return GestureDetector(
      onTap: () => _toggleSlot(dayIdx, time),
      child: Container(
        height: _slotHeight,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? config.primaryColor.withOpacity(0.08) 
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(
            DisponibilidadeProfessorLayout.tableCellRadius,
          ),
          border: Border.all(
            color: isSelected
                ? config.primaryColor
                : DisponibilidadeProfessorColors.unavailableBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color: config.primaryColor, 
              )
            : null,
      ),
    );
  }

  Widget _buildSaveButton(TeachingRoleConfig config, {bool isMobile = false}) {
    final button = SizedBox(
      height: isMobile
          ? DisponibilidadeProfessorLayout.mobileSaveButtonHeight
          : DisponibilidadeProfessorLayout.saveButtonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: isMobile ? 10 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isMobile
                  ? DisponibilidadeProfessorLayout.mobileActionRadius
                  : DisponibilidadeProfessorLayout.saveButtonRadius,
            ),
          ),
        ),
        onPressed: _isSaving ? null : _guardarHorarioFixo,
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isMobile ? 'Salvar' : 'Guardar Horário Fixo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 13 : 16,
                  height: isMobile ? 18 / 13 : null,
                ),
              ),
      ),
    );

    if (isMobile) {
      return button;
    }

    return Align(alignment: Alignment.centerRight, child: button);
  }
}

class _ParsedSlot {
  const _ParsedSlot({
    required this.dayIndex,
    required this.hour,
    required this.minute,
  });

  final int dayIndex;
  final int hour;
  final int minute;
}