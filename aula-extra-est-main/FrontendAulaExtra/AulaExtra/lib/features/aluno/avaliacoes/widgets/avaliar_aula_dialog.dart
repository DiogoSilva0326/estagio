import 'package:flutter/material.dart';

import 'package:aula_extra/core/data/student_evaluations/dtos/pending_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_evaluations/student_evaluations_service.dart';

class AvaliarAulaDialog extends StatefulWidget {
  const AvaliarAulaDialog({super.key});

  @override
  State<AvaliarAulaDialog> createState() => _AvaliarAulaDialogState();
}

class _AvaliarAulaDialogState extends State<AvaliarAulaDialog> {
  final StudentEvaluationsService _service = StudentEvaluationsService();

  bool _loading = true;
  bool _submitting = false;
  String? _loadError;
  List<PendingEvaluationDto> _pending = const [];
  String? _selectedLessonId;

  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final pending = await _service.getPending();
      if (!mounted) return;
      setState(() {
        _pending = pending;
        _selectedLessonId = pending.isNotEmpty ? pending.first.lessonId : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year.toString();
    return '$d/$m/$y';
  }

  String _lessonDropdownSubtitle(PendingEvaluationDto pending) {
    final subject = (pending.subject == null || pending.subject!.trim().isEmpty)
        ? null
        : pending.subject!.trim();
    final end = _formatDate(pending.lessonEnd ?? pending.lessonStart);

    if (subject != null && end.isNotEmpty) {
      return '$subject • $end';
    }
    if (end.isNotEmpty) {
      return end;
    }
    return subject ?? 'Sem data disponível';
  }

  Widget _buildDropdownLabel({
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101828),
            height: 22 / 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF667085),
            height: 16 / 12,
          ),
        ),
      ],
    );
  }

  PendingEvaluationDto? _selectedPending() {
    final id = _selectedLessonId;
    if (id == null) return null;
    for (final p in _pending) {
      if (p.lessonId == id) return p;
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final selectedLessonId = _selectedLessonId;
    if (selectedLessonId == null || selectedLessonId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma aula pendente para avaliar.')),
      );
      return;
    }

    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma nota de 1 a 5.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _service.submit(
        lessonId: selectedLessonId,
        rating: _rating,
        comments: _commentController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogHorizontalInset = screenWidth < 420 ? 12.0 : 24.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: dialogHorizontalInset,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 25, 18, 1),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avaliar Aula',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                    height: 28 / 20,
                  ),
                ),
                const SizedBox(height: 24),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_loadError != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _loadError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadPending,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                else if (_pending.isEmpty)
                  const Text('Não há aulas pendentes para avaliar.')
                else ...[
                  const Text(
                    'Professor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF364153),
                      height: 20 / 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedLessonId ?? 'pending'),
                    initialValue: _selectedLessonId,
                    isExpanded: true,
                    itemHeight: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    selectedItemBuilder: (context) => _pending
                        .map(
                          (p) => Align(
                            alignment: Alignment.centerLeft,
                            child: _buildDropdownLabel(
                              title: p.professorName,
                              subtitle: _lessonDropdownSubtitle(p),
                            ),
                          ),
                        )
                        .toList(growable: false),
                    items: _pending
                        .map((p) {
                          return DropdownMenuItem<String>(
                            value: p.lessonId,
                            child: _buildDropdownLabel(
                              title: p.professorName,
                              subtitle: _lessonDropdownSubtitle(p),
                            ),
                          );
                        })
                        .toList(growable: false),
                    onChanged: (v) => setState(() => _selectedLessonId = v),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final selected = _selectedPending();
                      if (selected == null) return const SizedBox.shrink();
                      final start = _formatDate(selected.lessonStart);
                      final end = _formatDate(selected.lessonEnd);
                      final date = (start.isNotEmpty && end.isNotEmpty)
                          ? '$start - $end'
                          : (end.isNotEmpty ? end : start);
                      if (date.isEmpty) return const SizedBox.shrink();
                      return Text(
                        'Aula: $date',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5565),
                          height: 20 / 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Nota',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF364153),
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++) ...[
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          onPressed: () => setState(() => _rating = i),
                          icon: Icon(
                            i <= _rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFFFB800),
                            size: 32,
                          ),
                        ),
                      ),
                      if (i != 5) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comentário',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF364153),
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 122),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: TextField(
                        controller: _commentController,
                        minLines: 5,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText:
                              'Compartilhe sua experiência com este explicador...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0x800A0A0A),
                            height: 24 / 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0A0A0A),
                          height: 24 / 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed:
                                (_loading ||
                                    _pending.isEmpty ||
                                    _loadError != null ||
                                    _submitting)
                                ? null
                                : _submit,
                            child: Text(
                              _submitting ? 'Enviando...' : 'Enviar Avaliação',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 24 / 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 112.828,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF364153),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 24 / 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
