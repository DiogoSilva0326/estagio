import 'package:aula_extra/features/professor/meus_anuncios/constants/meus_anuncios_professor_constants.dart';
import 'package:flutter/material.dart';

class MeusAnunciosStatCard extends StatelessWidget {
  const MeusAnunciosStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color, // <-- Adicionada
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? MeusAnunciosProfessorColors.accent;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MeusAnunciosProfessorColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MeusAnunciosProfessorColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1), // Fundo suave com a cor ativa
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: activeColor), // Ícone com a cor ativa
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: MeusAnunciosProfessorColors.title,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: MeusAnunciosProfessorColors.mutedText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}