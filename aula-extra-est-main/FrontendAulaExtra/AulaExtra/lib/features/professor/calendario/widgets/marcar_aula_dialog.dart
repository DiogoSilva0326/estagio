import 'dart:convert';

import 'package:aula_extra/core/data/communication/contacts_service.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_service.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MarcarAulaDialog extends StatefulWidget {
  const MarcarAulaDialog({super.key, this.initialDate, this.initialTime});

  final DateTime? initialDate;
  final TimeOfDay? initialTime;

  @override
  State<MarcarAulaDialog> createState() => _MarcarAulaDialogState();
}

enum _MarcarAulaStep { schedule, student, subject, summary }

class _StudentOption {
  const _StudentOption({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.status,
  });

  final String userId;
  final String username;
  final String displayName;
  final String status;
}

class _SubjectOption {
  const _SubjectOption({
    required this.professorAdId,
    required this.disciplinaId,
    required this.courseId,
    required this.title,
    required this.tutoringTypeName,
    required this.sessionPrice,
    required this.statusLabel,
    this.subtitle,
    this.isAvailable = true,
  });

  final String professorAdId;
  final String disciplinaId;
  final String courseId;
  final String title;
  final String tutoringTypeName;
  final double sessionPrice;
  final String statusLabel;
  final String? subtitle;
  final bool isAvailable;
}

class _MarcarAulaDialogState extends State<MarcarAulaDialog> {
  final ContactsService _contactsService = ContactsService();
  final ProfessorsService _professorsService = ProfessorsService();
  final ProfessorAdsService _professorAdsService = ProfessorAdsService();

  static const _weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const _months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  final Color _primaryColor = const Color(0xFFFF6B00);
  final Color _successColor = const Color(0xFF12B76A);
  final Color _surfaceColor = const Color(0xFFF8FAFC);
  final Color _borderColor = const Color(0xFFE2E8F0);
  final Color _textMutedColor = const Color(0xFF64748B);

  _MarcarAulaStep _step = _MarcarAulaStep.schedule;

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<_StudentOption> _students = const <_StudentOption>[];
  List<_SubjectOption> _subjects = const <_SubjectOption>[];

  _StudentOption? _selectedStudent;
  _SubjectOption? _selectedSubject;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadingError;
  String? _myProfessorId;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _startTime = widget.initialTime;
    _endTime = widget.initialTime == null
        ? null
        : _addMinutes(widget.initialTime!, 60);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final token = await TokenStorage().loadToken() ?? '';
      if (token.trim().isEmpty) {
        throw Exception('Sessão expirada');
      }

      final professor = await _professorsService.getMyProfessor();
      final contacts = await _contactsService.getMyContacts();
      final meusAlunos = await _professorsService.fetchMeusAlunos();
      final adsData = await _professorAdsService.getMyData();

      final myProfessorId = professor?.idProfessor?.trim();

      if (!mounted) return;
      setState(() {
        _myProfessorId = myProfessorId;
        _students = _buildStudentOptions(
          contacts: contacts,
          meusAlunos: meusAlunos,
        );
        _subjects = _buildSubjectOptions(ads: adsData.ads);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingError = error.toString();
        _isLoading = false;
      });
    }
  }

  List<_StudentOption> _buildStudentOptions({
    required List<ContactUserSummaryDto> contacts,
    required List<ProfessorAlunoDto> meusAlunos,
  }) {
    final studentsByUsername = <String, ProfessorAlunoDto>{
      for (final student in meusAlunos)
        if (student.username.trim().isNotEmpty)
          student.username.trim().toLowerCase(): student,
    };

    final acceptedStatuses = <String>{'accepted', 'active', 'connected'};

    final matchingContacts = contacts
        .where((contact) {
          final username = contact.username?.trim().toLowerCase();
          if (username == null || username.isEmpty) return false;
          return studentsByUsername.containsKey(username);
        })
        .toList(growable: false);

    final source = matchingContacts.isNotEmpty ? matchingContacts : contacts;

    final options = source
        .where((contact) => (contact.username ?? '').trim().isNotEmpty)
        .map((contact) {
          final username = contact.username!.trim();
          final normalized = username.toLowerCase();
          final student = studentsByUsername[normalized];
          final status = contact.status.trim().toLowerCase();
          final nameCandidate = contact.displayName?.trim();
          final studentName = student?.fullName.trim();
          final displayName =
              (nameCandidate != null && nameCandidate.isNotEmpty)
              ? nameCandidate
              : (studentName != null && studentName.isNotEmpty)
              ? studentName
              : username;

          return _StudentOption(
            userId: student?.id.trim().isNotEmpty == true
                ? student!.id.trim()
                : contact.contactUserId.trim(),
            username: username,
            displayName: displayName,
            status: acceptedStatuses.contains(status)
                ? 'Chat ativo'
                : 'Contacto',
          );
        })
        .where((student) => student.userId.isNotEmpty)
        .toList(growable: false);

    return options..sort(
      (left, right) => left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      ),
    );
  }

  List<_SubjectOption> _buildSubjectOptions({
    required List<ProfessorAdDto> ads,
  }) {
    final options = ads
        .map((ad) {
          final normalizedStatus = ad.status.trim().toLowerCase();
          final isAvailable =
              ad.idCourse.trim().isNotEmpty &&
              (normalizedStatus.isEmpty ||
                  normalizedStatus == 'published' ||
                  normalizedStatus == 'active');
          final title = (ad.disciplinaNome ?? ad.courseName).trim().isEmpty
              ? 'Explicação'
              : (ad.disciplinaNome ?? ad.courseName).trim();
          final tutoringTypeName = (ad.tutoringTypeName ?? '').trim().isEmpty
              ? 'Modalidade'
              : ad.tutoringTypeName!.trim();
          final subtitleParts = <String>[
            tutoringTypeName,
            if ((ad.levelOfEducation ?? '').trim().isNotEmpty)
              ad.levelOfEducation!.trim(),
          ];
          final price = ad.sessionPrice ?? 0;

          return _SubjectOption(
            professorAdId: ad.idProfessorAd,
            disciplinaId: ad.idDisciplina?.trim() ?? '',
            courseId: ad.idCourse,
            title: title,
            tutoringTypeName: tutoringTypeName,
            sessionPrice: price,
            statusLabel: isAvailable ? _formatCurrency(price) : 'Indisponível',
            subtitle: subtitleParts.join(' · '),
            isAvailable: isAvailable,
          );
        })
        .toList(growable: false);

    options.sort((left, right) {
      final titleCompare = left.title.toLowerCase().compareTo(
        right.title.toLowerCase(),
      );
      if (titleCompare != 0) return titleCompare;
      return left.tutoringTypeName.toLowerCase().compareTo(
        right.tutoringTypeName.toLowerCase(),
      );
    });

    return options;
  }

  TimeOfDay _addMinutes(TimeOfDay value, int minutesToAdd) {
    final totalMinutes = value.hour * 60 + value.minute + minutesToAdd;
    final safeMinutes = totalMinutes.clamp(0, (23 * 60) + 59);
    return TimeOfDay(hour: safeMinutes ~/ 60, minute: safeMinutes % 60);
  }

  DateTime? get _startDateTime {
    if (_selectedDate == null || _startTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  DateTime? get _endDateTime {
    if (_selectedDate == null || _endTime == null) return null;
    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  bool get _isScheduleValid {
    final start = _startDateTime;
    final end = _endDateTime;
    if (start == null || end == null) return false;
    return end.isAfter(start);
  }

  bool get _canGoNext {
    switch (_step) {
      case _MarcarAulaStep.schedule:
        return _selectedDate != null &&
            _startTime != null &&
            _endTime != null &&
            _isScheduleValid;
      case _MarcarAulaStep.student:
        return _selectedStudent != null;
      case _MarcarAulaStep.subject:
        return _selectedSubject != null && _selectedSubject!.isAvailable;
      case _MarcarAulaStep.summary:
        return true;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialValue = isStart
        ? (_startTime ?? const TimeOfDay(hour: 10, minute: 0))
        : (_endTime ??
              (_startTime != null
                  ? _addMinutes(_startTime!, 60)
                  : const TimeOfDay(hour: 11, minute: 0)));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialValue,
    );

    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
        _endTime ??= _addMinutes(picked, 60);
      } else {
        _endTime = picked;
      }
    });
  }

  String _formatDate(DateTime value) {
    return '${_weekdays[value.weekday - 1]}, ${value.day.toString().padLeft(2, '0')} ${_months[value.month - 1]} ${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatCurrency(double value) {
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '$text €';
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'AL';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFB2C36),
      ),
    );
  }

  Future<void> _saveLesson() async {
    if (_isSubmitting) return;
    if (_myProfessorId == null || _myProfessorId!.isEmpty) {
      _showError('Não foi possível identificar o professor.');
      return;
    }
    if (_selectedStudent == null ||
        _selectedSubject == null ||
        _startDateTime == null ||
        _endDateTime == null) {
      _showError('Faltam dados para criar a aula.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await TokenStorage().loadToken() ?? '';
      if (token.trim().isEmpty) {
        throw Exception('Sessão expirada');
      }

      final lessonTitle =
          'Explicação de ${_selectedSubject!.title} (${_selectedSubject!.tutoringTypeName})';
      final startStr = _startDateTime!.toIso8601String();
      final endStr = _endDateTime!.toIso8601String();

      final lessonResponse = await http.post(
        ApiConfig.uri('/api/Lessons/lessons'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idProfessor': _myProfessorId,
          'idCourse': _selectedSubject!.courseId,
          'title': lessonTitle,
          'scheduledStart': startStr,
          'scheduledEnd': endStr,
          'durationMinutes': _endDateTime!
              .difference(_startDateTime!)
              .inMinutes,
          'basePrice': _selectedSubject!.sessionPrice,
          'status': 'PendingPayment',
        }),
      );

      if (lessonResponse.statusCode < 200 || lessonResponse.statusCode >= 300) {
        throw Exception(
          'Não foi possível criar a aula (${lessonResponse.statusCode}).',
        );
      }

      final lessonData =
          jsonDecode(lessonResponse.body) as Map<String, dynamic>;
      final lessonId = (lessonData['idLesson'] ?? lessonData['IdLesson'])
          ?.toString();
      if (lessonId == null || lessonId.isEmpty) {
        throw Exception('A resposta da criação da aula é inválida.');
      }

      final enrollmentResponse = await http.post(
        ApiConfig.uri('/api/Lessons/enrollments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idEnrollment': '00000000-0000-0000-0000-000000000000',
          'idLesson': lessonId,
          'idUser': _selectedStudent!.userId,
          'status': 'PendingPayment',
          'pricePaid': 0.0,
        }),
      );

      if (enrollmentResponse.statusCode < 200 ||
          enrollmentResponse.statusCode >= 300) {
        await http.delete(
          ApiConfig.uri('/api/Lessons/lessons/$lessonId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        throw Exception(
          'A aula foi criada, mas não foi possível associar o aluno.',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pedido enviado com ${_formatCurrency(_selectedSubject!.sessionPrice)}. Fica pendente até o aluno pagar e confirmar.',
          ),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _goNext() {
    if (!_canGoNext) return;
    setState(() => _step = _MarcarAulaStep.values[_step.index + 1]);
  }

  void _goBack() {
    if (_step == _MarcarAulaStep.schedule) return;
    setState(() => _step = _MarcarAulaStep.values[_step.index - 1]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          if (_step != _MarcarAulaStep.schedule)
            IconButton(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (_step) {
                    _MarcarAulaStep.schedule => 'Criar Aula',
                    _MarcarAulaStep.student => 'Selecionar Aluno',
                    _MarcarAulaStep.subject => 'Selecionar Modalidade',
                    _MarcarAulaStep.summary => 'Resumo da Explicação',
                  },
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(switch (_step) {
                  _MarcarAulaStep.schedule =>
                    'Escolhe o dia e a hora da explicação.',
                  _MarcarAulaStep.student =>
                    'Seleciona o aluno que vai receber a aula.',
                  _MarcarAulaStep.subject =>
                    'Escolhe o anúncio com modalidade e preço.',
                  _MarcarAulaStep.summary =>
                    'Confirma o resumo e o valor antes de enviar ao aluno.',
                }, style: TextStyle(color: _textMutedColor, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        child: _isLoading
            ? const SizedBox(
                height: 380,
                child: Center(child: CircularProgressIndicator()),
              )
            : _loadingError != null
            ? SizedBox(
                height: 380,
                child: Center(
                  child: Text(_loadingError!, textAlign: TextAlign.center),
                ),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: switch (_step) {
                  _MarcarAulaStep.schedule => _buildScheduleStep(),
                  _MarcarAulaStep.student => _buildStudentStep(),
                  _MarcarAulaStep.subject => _buildSubjectStep(),
                  _MarcarAulaStep.summary => _buildSummaryStep(),
                },
              ),
      ),
      actions: _isLoading
          ? const []
          : [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              if (_step != _MarcarAulaStep.summary)
                ElevatedButton(
                  onPressed: _canGoNext ? _goNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar ao Aluno',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
            ],
    );
  }

  Widget _buildScheduleStep() {
    return SizedBox(
      key: const ValueKey('schedule-step'),
      height: 380,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: _SelectorTile(
                icon: Icons.event_outlined,
                label: 'Data',
                value: _selectedDate == null
                    ? 'Selecionar data'
                    : _formatDate(_selectedDate!),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(isStart: true),
                    borderRadius: BorderRadius.circular(16),
                    child: _SelectorTile(
                      icon: Icons.schedule_rounded,
                      label: 'Início',
                      value: _startTime == null
                          ? '--:--'
                          : _formatTime(_startTime!),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(isStart: false),
                    borderRadius: BorderRadius.circular(16),
                    child: _SelectorTile(
                      icon: Icons.schedule_rounded,
                      label: 'Fim',
                      value: _endTime == null
                          ? '--:--'
                          : _formatTime(_endTime!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _startTime != null && _endTime != null && !_isScheduleValid
                    ? 'A hora de fim tem de ser depois da hora de início.'
                    : 'A aula vai ser criada como pendente até o aluno pagar e confirmar.',
                style: TextStyle(
                  color:
                      _startTime != null &&
                          _endTime != null &&
                          !_isScheduleValid
                      ? const Color(0xFFFB2C36)
                      : _textMutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentStep() {
    return SizedBox(
      key: const ValueKey('student-step'),
      height: 380,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: _students.isEmpty
            ? Center(
                child: Text(
                  'Ainda não tens contactos de chat disponíveis para selecionar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textMutedColor),
                ),
              )
            : ListView.separated(
                itemCount: _students.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final isSelected = _selectedStudent?.userId == student.userId;
                  return _SelectableTile(
                    title: student.displayName,
                    subtitle: '@${student.username}',
                    badge: student.status,
                    initials: _initials(student.displayName),
                    selected: isSelected,
                    onTap: () => setState(() => _selectedStudent = student),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSubjectStep() {
    return SizedBox(
      key: const ValueKey('subject-step'),
      height: 380,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: _subjects.isEmpty
            ? Center(
                child: Text(
                  'Não foram encontrados anúncios publicados para marcar aulas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textMutedColor),
                ),
              )
            : ListView.separated(
                itemCount: _subjects.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final isSelected =
                      _selectedSubject?.professorAdId == subject.professorAdId;
                  return _SelectableTile(
                    title: subject.title,
                    subtitle:
                        subject.subtitle ??
                        'Modalidade disponível para marcação',
                    badge: subject.statusLabel,
                    initials: 'D',
                    selected: isSelected,
                    enabled: subject.isAvailable,
                    onTap: () => setState(() => _selectedSubject = subject),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SizedBox(
      key: const ValueKey('summary-step'),
      height: 380,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(
              icon: Icons.event_available_rounded,
              label: 'Data',
              value: _startDateTime == null
                  ? '-'
                  : _formatDate(_startDateTime!),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.schedule_rounded,
              label: 'Hora',
              value: _startTime == null || _endTime == null
                  ? '-'
                  : '${_formatTime(_startTime!)} - ${_formatTime(_endTime!)}',
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.person_outline_rounded,
              label: 'Aluno',
              value: _selectedStudent?.displayName ?? '-',
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.menu_book_rounded,
              label: 'Disciplina',
              value: _selectedSubject?.title ?? '-',
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.video_camera_front_outlined,
              label: 'Modalidade',
              value: _selectedSubject?.tutoringTypeName ?? '-',
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              icon: Icons.payments_outlined,
              label: 'Preço',
              value: _selectedSubject == null
                  ? '-'
                  : _formatCurrency(_selectedSubject!.sessionPrice),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Text(
                'Depois de enviares, o aluno recebe o resumo com o preço. A aula só fica confirmada nos calendários quando o aluno pagar e confirmar.',
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.initials,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String initials;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFFFF6B00)
        : enabled
        ? const Color(0xFFE2E8F0)
        : const Color(0xFFE5E7EB);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF1E8)
              : enabled
              ? Colors.white
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: selected
                  ? const Color(0xFFFF6B00)
                  : const Color(0xFFE2E8F0),
              child: Text(
                initials,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF101828),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? const Color(0xFF101828)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 18),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
