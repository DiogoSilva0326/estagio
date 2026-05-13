import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class ExplicadoresFilterChip extends StatelessWidget {
  const ExplicadoresFilterChip({
    required this.label,
    this.width,
    this.options = const <String>[],
    this.selectedValue,
    this.onSelected,
    super.key,
  });

  final String label;
  final double? width;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String>? onSelected;

  bool get _isInteractive => options.isNotEmpty && onSelected != null;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: 42.515,
      padding: const EdgeInsets.symmetric(horizontal: 20.52),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16.307),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.813,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3563,
              ),
            ),
          ),
          if (_isInteractive) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ],
      ),
    );

    if (!_isInteractive) {
      return content;
    }

    return PopupMenuButton<String>(
      tooltip: selectedValue ?? label,
      onSelected: onSelected,
      color: Colors.white,
      itemBuilder: (context) => options
          .map(
            (option) =>
                PopupMenuItem<String>(value: option, child: Text(option)),
          )
          .toList(growable: false),
      child: content,
    );
  }
}
