import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:flutter/material.dart';

class NotificacoesProfessorCancellationDialog extends StatelessWidget {
  const NotificacoesProfessorCancellationDialog({
    super.key,
    required this.item,
  });

  final UserNotificationDto item;

  @override
  Widget build(BuildContext context) {
    final student = item.studentName?.trim().isNotEmpty == true
        ? item.studentName!.trim()
        : 'Aluno';
    final justification = item.justification?.trim().isNotEmpty == true
        ? item.justification!.trim()
        : 'Sem justificação fornecida.';

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.feedback_outlined, color: Color(0xFFFF6B00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Justificação de $student',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O aluno cancelou a aula a menos de 24h e deixou o seguinte motivo:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Text(
              '“$justification”',
              style: const TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Color(0xFF344054),
              ),
            ),
          ),
          if (item.decisionMade) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.decision == 'Perdoada'
                    ? const Color(0xFFE6F4EA)
                    : const Color(0xFFFEE4E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    item.decision == 'Perdoada'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: item.decision == 'Perdoada'
                        ? const Color(0xFF00C950)
                        : const Color(0xFFF04438),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.decision == 'Perdoada'
                          ? 'Decisão: penalidade perdoada'
                          : 'Decisão: penalidade mantida',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.decision == 'Perdoada'
                            ? const Color(0xFF00C950)
                            : const Color(0xFFF04438),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              'O que pretendes fazer em relação à penalidade?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
      actions: item.decisionMade
          ? [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ]
          : [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF04438),
                  side: const BorderSide(color: Color(0xFFF04438)),
                ),
                child: const Text('Manter penalidade'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C950),
                ),
                child: const Text(
                  'Perdoar falta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
    );
  }
}
