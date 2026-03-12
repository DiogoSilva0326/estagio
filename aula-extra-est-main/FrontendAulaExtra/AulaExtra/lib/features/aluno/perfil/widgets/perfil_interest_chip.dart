import 'package:aula_extra/features/aluno/perfil/constants/perfil_constants.dart';
import 'package:flutter/material.dart';

class PerfilInterestChip extends StatelessWidget {
  const PerfilInterestChip({
    super.key,
    required this.label,
    this.onRemove,
    this.width,
  });

  final String label;
  final VoidCallback? onRemove;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: PerfilConstants.interestChipHeight,
      width: width,
      padding: const EdgeInsets.only(left: 22.247, right: 14, top: 0, bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        gradient: PerfilConstants.gradientOrange,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 19.466,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 27.809 / 19.466,
            ),
          ),
          const SizedBox(width: 12),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(9999),
              child: const SizedBox(
                width: 22.247,
                height: 22.247,
                child: Center(
                  child: Icon(Icons.close, size: 16.685, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
