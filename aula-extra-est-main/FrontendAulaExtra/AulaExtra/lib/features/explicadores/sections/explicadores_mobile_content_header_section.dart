import 'package:aula_extra/features/explicadores/constants/explicadores_mobile_layout.dart';
import 'package:aula_extra/features/explicadores/sections/main_content_header_section.dart';
import 'package:flutter/material.dart';

class ExplicadoresMobileContentHeaderSection extends StatelessWidget {
  const ExplicadoresMobileContentHeaderSection({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.disciplinaOptions,
    required this.selectedDisciplinaId,
    required this.onDisciplinaChanged,
    required this.onFiltersTap,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final List<DisciplinaOption> disciplinaOptions;
  final String? selectedDisciplinaId;
  final ValueChanged<String?> onDisciplinaChanged;
  final VoidCallback onFiltersTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ExplicadoresMobileLayout.pageHorizontalPadding,
        24,
        ExplicadoresMobileLayout.pageHorizontalPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ExplicadoresMobileLayout.surface,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(
                ExplicadoresMobileLayout.sectionCardRadius,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(15, 23, 42, 0.04),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _SearchInput(
                  controller: searchController,
                  onSubmitted: onSearchSubmitted,
                ),
                const SizedBox(height: 12),
                _Dropdown(
                  options: disciplinaOptions,
                  selectedId: selectedDisciplinaId,
                  onChanged: onDisciplinaChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Explore todos os nossos Apoios',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: ExplicadoresMobileLayout.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onFiltersTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ExplicadoresMobileLayout.accentOrange,
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    size: 24,
                    color: ExplicadoresMobileLayout.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF6A7282)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Procura por nome ou disciplina...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  height: 1.25,
                  color: Color(0xFF9AA4B2),
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                height: 1.25,
                color: ExplicadoresMobileLayout.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  final List<DisciplinaOption> options;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          isExpanded: true,
          icon: const Icon(
            Icons.expand_more_rounded,
            color: ExplicadoresMobileLayout.textPrimary,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String?>(
                  value: option.id,
                  child: Text(
                    option.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5565),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
