import 'package:aula_extra/features/aluno/notificacoes/constants/notificacoes_constants.dart';
import 'package:flutter/material.dart';

class NotificacoesFilterPill extends StatelessWidget {
  const NotificacoesFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 59.027,
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            fontSize: 22.486,
            fontWeight: FontWeight.w400,
            height: 33.73 / 22.486,
            color: selected ? Colors.white : const Color(0xFF364153),
          ),
        ),
      ),
    );
  }
}
