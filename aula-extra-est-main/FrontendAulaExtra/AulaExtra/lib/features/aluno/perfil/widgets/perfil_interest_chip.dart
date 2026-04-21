import 'package:aula_extra/features/aluno/perfil/constants/perfil_constants.dart';
import 'package:flutter/material.dart';

class PerfilInterestChip extends StatelessWidget {
  const PerfilInterestChip({
    super.key,
    required this.label,
    this.onRemove,
    this.width,
    this.isMobile = false,
  });

  final String label;
  final VoidCallback? onRemove;
  final double? width;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile
          ? PerfilConstants.mobileInterestChipHeight
          : PerfilConstants.interestChipHeight,
      width: width,
      padding: EdgeInsets.only(
        left: isMobile ? 14 : 22.247,
        right: isMobile ? 10 : 14,
        top: 0,
        bottom: 0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        gradient: PerfilConstants.gradientOrange,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 13 : 19.466,
              fontWeight: isMobile ? FontWeight.w500 : FontWeight.w400,
              color: Colors.white,
              height: isMobile ? 18 / 13 : 27.809 / 19.466,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          if (onRemove != null)
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(9999),
              child: SizedBox(
                width: isMobile ? 18 : 22.247,
                height: isMobile ? 18 : 22.247,
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: isMobile ? 14 : 16.685,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
