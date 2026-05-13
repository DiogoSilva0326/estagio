import 'package:flutter/material.dart';

import '../models/avaliacao_item.dart';

class AvaliacaoActionButton extends StatelessWidget {
  const AvaliacaoActionButton({
    required this.action,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    super.key,
  });

  final AvaliacaoAction action;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.tooltip,
      child: Material(
        color: enabled ? action.backgroundColor : action.backgroundColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled && !isLoading ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 37.273,
            height: 37.273,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(action.iconColor),
                      ),
                    )
                  : Icon(action.icon, size: 20, color: action.iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
