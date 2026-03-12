import 'package:flutter/material.dart';

import 'package:aula_extra/core/data/student_professor_evaluations/dtos/pending_professor_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/student_professor_evaluations_service.dart';

class AvaliarProfessorDialog extends StatefulWidget {
  const AvaliarProfessorDialog({super.key});

  @override
  State<AvaliarProfessorDialog> createState() => _AvaliarProfessorDialogState();
}

class _AvaliarProfessorDialogState extends State<AvaliarProfessorDialog> {
  final StudentProfessorEvaluationsService _service = StudentProfessorEvaluationsService();

  bool _loading = true;
  bool _submitting = false;
  String? _loadError;
  List<PendingProfessorEvaluationDto> _pending = const [];
  String? _selectedProfessorId;

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
        _selectedProfessorId = pending.isNotEmpty ? pending.first.professorId : null;
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

  PendingProfessorEvaluationDto? _selectedPending() {
    final id = _selectedProfessorId;
    if (id == null) return null;
    for (final p in _pending) {
      if (p.professorId == id) return p;
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final selectedProfessorId = _selectedProfessorId;
    if (selectedProfessorId == null || selectedProfessorId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum professor pendente para avaliar.')),
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
        professorId: selectedProfessorId,
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 25, 25, 1),
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
                const Text(
                  'Avaliar Professor',
                  style: TextStyle(
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
                  const Text('Não há professores pendentes para avaliar.')
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
                    key: ValueKey(_selectedProfessorId ?? 'pending'),
                    initialValue: _selectedProfessorId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _pending
                        .map(
                          (p) {
                            final end = _formatDate(p.lastLessonEnd ?? p.lastLessonStart);
                            final label = end.isEmpty ? p.professorName : '${p.professorName} • Última aula: $end';
                            return DropdownMenuItem<String>(
                              value: p.professorId,
                              child: Text(label, overflow: TextOverflow.ellipsis),
                            );
                          },
                        )
                        .toList(growable: false),
                    onChanged: (v) => setState(() => _selectedProfessorId = v),
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final selected = _selectedPending();
                      if (selected == null) return const SizedBox.shrink();
                      final start = _formatDate(selected.lastLessonStart);
                      final end = _formatDate(selected.lastLessonEnd);
                      final date = (start.isNotEmpty && end.isNotEmpty) ? '$start - $end' : (end.isNotEmpty ? end : start);
                      if (date.isEmpty) return const SizedBox.shrink();
                      return Text(
                        'Última aula: $date',
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
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          onPressed: () => setState(() => _rating = i),
                          icon: Icon(
                            i <= _rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFF6B00),
                            size: 24,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comentário (opcional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF364153),
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Escreva aqui...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: (_submitting || _loading) ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Enviar'),
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
