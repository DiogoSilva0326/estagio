import 'package:flutter/material.dart';

class MainContentHeaderSection extends StatelessWidget {
  const MainContentHeaderSection({
    super.key,
    required this.searchController,
    required this.onSearchSubmitted,
    required this.disciplinaOptions,
    required this.selectedDisciplinaId,
    required this.onDisciplinaChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchSubmitted;
  final List<DisciplinaOption> disciplinaOptions;
  final String? selectedDisciplinaId;
  final ValueChanged<String?> onDisciplinaChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 63.83,
            child: Row(
              children: [
                Expanded(
                  child: _SearchInput(
                    controller: searchController,
                    onSubmitted: onSearchSubmitted,
                  ),
                ),
                const SizedBox(width: 20.426),
                SizedBox(
                  width: 355.532,
                  child: _Dropdown(
                    options: disciplinaOptions,
                    selectedId: selectedDisciplinaId,
                    onChanged: onDisciplinaChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.426),
          const Text(
            'Explore todos os nossos Explicadores',
            style: TextStyle(
              fontSize: 30.638,
              height: 40.851 / 30.638,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 63.83,
          padding: const EdgeInsets.only(left: 61.277, right: 20.426),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD1D5DC), width: 1.277),
            borderRadius: BorderRadius.circular(12.766),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                fontSize: 20.426,
                color: Color(0xFF0A0A0A),
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Procura por nome ou especialidade...',
                hintStyle: TextStyle(
                  fontSize: 20.426,
                  color: Color.fromRGBO(10, 10, 10, 0.5),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 20.43,
          top: 19.15,
          child: Icon(Icons.search, size: 25.532, color: Color(0xFF0A0A0A)),
        ),
      ],
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
      height: 63.83,
      padding: const EdgeInsets.only(left: 20.426, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DC), width: 1.277),
        borderRadius: BorderRadius.circular(12.766),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedId,
                isExpanded: true,
                icon: const Icon(Icons.expand_more, size: 25.532, color: Color(0xFF0A0A0A)),
                items: options
                    .map(
                      (o) => DropdownMenuItem<String?>(
                        value: o.id,
                        child: Center(
                          child: Text(
                            o.label,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 35.557 / 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8F8F8F),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisciplinaOption {
  const DisciplinaOption({required this.id, required this.label});

  final String? id;
  final String label;
}
