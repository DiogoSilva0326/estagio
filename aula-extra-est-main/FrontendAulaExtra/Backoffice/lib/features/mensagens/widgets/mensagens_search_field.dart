import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class MensagensSearchField extends StatelessWidget {
  const MensagensSearchField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48.921,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 3.494,
            offset: Offset(0, 1.165),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintText: 'Pesquisar conversas...',
          hintStyle: TextStyle(
            color: Color(0x80101828),
            fontSize: 16.307,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.18,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18.637,
            color: AppColors.textMuted,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 46),
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15.143,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
