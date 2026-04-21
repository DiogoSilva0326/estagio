import 'package:flutter/material.dart';

import '../models/avaliacao_item.dart';

class AvaliacaoActionButton extends StatelessWidget {
  const AvaliacaoActionButton({
    required this.action,
    required this.onTap,
    super.key,
  });

  final AvaliacaoAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.tooltip,
      child: Material(
        color: action.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 37.273,
            height: 37.273,
            child: Icon(action.icon, size: 20, color: action.iconColor),
          ),
        ),
      ),
    );
  }
}
