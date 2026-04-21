import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:flutter/material.dart';

class NotificacoesFilterPill extends StatelessWidget {
  const NotificacoesFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isMobile = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final height = isMobile ? NotificacoesConstants.mobileFilterHeight : 59.027;
    final horizontalPadding = isMobile ? 18.0 : 24.0;
    final fontSize = isMobile
        ? NotificacoesConstants.mobileFilterFontSize
        : 22.486;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: selected ? null : Colors.white,
          gradient: selected ? NotificacoesConstants.iconOrangeGradient : null,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE5E7EB),
            width: NotificacoesConstants.borderWidth,
          ),
          boxShadow: selected ? NotificacoesConstants.pillShadow : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isMobile ? FontWeight.w500 : FontWeight.w400,
            height: 1.35,
            color: selected ? Colors.white : const Color(0xFF364153),
          ),
        ),
      ),
    );
  }
}
