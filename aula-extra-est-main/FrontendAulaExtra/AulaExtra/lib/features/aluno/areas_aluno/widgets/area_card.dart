import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_details_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_mark_lesson_dialog.dart';
import 'package:flutter/material.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.area,
    this.onRemoveArea,
  });

  final AreaOverview area;
  final VoidCallback? onRemoveArea;

  static const _chipBg = Color(0xFFF3F4F6);
  static const _chipText = Color(0xFF4A5565);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 4), blurRadius: 12),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Image.asset(area.imageAsset, width: 48, height: 48, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      area.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Disciplinas / Serviços:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              if (area.selectedDisciplinaNames.isEmpty)
                const Text('Nenhum selecionado', style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Color(0xFF9CA3AF)))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: area.selectedDisciplinaNames.map((name) => Chip(
                    label: Text(name, style: const TextStyle(color: _chipText, fontSize: 13, fontWeight: FontWeight.w600)),
                    backgroundColor: _chipBg,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  )).toList(),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => showAreaDetailsDialog(context, area: area),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFC9039),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ver Detalhes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => showAreaMarkLessonDialog(context, area: area),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Marcar', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onRemoveArea != null)
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
              onPressed: onRemoveArea,
              splashRadius: 24,
            ),
          ),
      ],
    );
  }
}