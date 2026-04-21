import 'package:aula_extra/features/explicadores/constants/explicadores_mobile_layout.dart';
import 'package:aula_extra/features/explicadores/sections/filters_sidebar_section.dart';
import 'package:flutter/material.dart';

class ExplicadoresMobileFiltersSheet extends StatefulWidget {
  const ExplicadoresMobileFiltersSheet({
    super.key,
    required this.initialMaxPrice,
    required this.initialPriceText,
    required this.initialSelectedLevelId,
    required this.initialAvailability,
    required this.initialSelectedDisciplinaId,
    required this.initialMinRating,
    required this.levelOptions,
    required this.disciplinaOptions,
    required this.onApply,
  });

  final double? initialMaxPrice;
  final String initialPriceText;
  final String? initialSelectedLevelId;
  final Set<AvailabilityOption> initialAvailability;
  final String? initialSelectedDisciplinaId;
  final double? initialMinRating;
  final List<FilterOption> levelOptions;
  final List<FilterOption> disciplinaOptions;
  final void Function({
    String? selectedLevelId,
    Set<AvailabilityOption>? availability,
    String? selectedDisciplinaId,
    double? maxPrice,
    double? minRating,
    String? priceText,
  })
  onApply;

  @override
  State<ExplicadoresMobileFiltersSheet> createState() =>
      _ExplicadoresMobileFiltersSheetState();
}

class _ExplicadoresMobileFiltersSheetState
    extends State<ExplicadoresMobileFiltersSheet> {
  late final TextEditingController _priceController;
  late String? _selectedLevelId;
  late Set<AvailabilityOption> _availability;
  late String? _selectedDisciplinaId;
  late double? _maxPrice;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.initialPriceText);
    _selectedLevelId = widget.initialSelectedLevelId;
    _availability = {...widget.initialAvailability};
    _selectedDisciplinaId = widget.initialSelectedDisciplinaId;
    _maxPrice = widget.initialMaxPrice;
    _minRating = widget.initialMinRating;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _selectedLevelId = null;
      _availability = <AvailabilityOption>{};
      _selectedDisciplinaId = null;
      _maxPrice = null;
      _minRating = null;
      _priceController.clear();
    });
  }

  void _apply() {
    widget.onApply(
      selectedLevelId: _selectedLevelId,
      availability: _availability,
      selectedDisciplinaId: _selectedDisciplinaId,
      maxPrice: _maxPrice,
      minRating: _minRating,
      priceText: _priceController.text,
    );
    Navigator.of(context).pop();
  }

  void _onPriceChanged(String rawValue) {
    final normalized = rawValue.trim().replaceAll(',', '.');
    setState(() {
      if (normalized.isEmpty) {
        _maxPrice = null;
        return;
      }

      final parsed = double.tryParse(normalized);
      if (parsed != null && parsed > 0) {
        _maxPrice = parsed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: ExplicadoresMobileLayout.pageBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DC),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                        color: ExplicadoresMobileLayout.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      foregroundColor: ExplicadoresMobileLayout.textMuted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Limpar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ExplicadoresMobileLayout.border,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: ExplicadoresMobileLayout.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: ExplicadoresMobileLayout.border),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MobileFilterSection(
                      title: 'Disciplina',
                      child: _ChoiceWrap(
                        options: widget.disciplinaOptions,
                        selectedId: _selectedDisciplinaId,
                        onChanged: (id) {
                          setState(() {
                            _selectedDisciplinaId = _selectedDisciplinaId == id
                                ? null
                                : id;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _MobileFilterSection(
                      title: 'Nível de Ensino',
                      child: _ChoiceWrap(
                        options: widget.levelOptions,
                        selectedId: _selectedLevelId,
                        onChanged: (id) {
                          setState(() {
                            _selectedLevelId = _selectedLevelId == id
                                ? null
                                : id;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    _MobileFilterSection(
                      title: 'Disponibilidade',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _AvailabilityChip(
                            label: 'Qualquer horário',
                            selected: _availability.isEmpty,
                            onTap: () => setState(
                              () => _availability = <AvailabilityOption>{},
                            ),
                          ),
                          _AvailabilityChip(
                            label: 'Manhãs',
                            selected: _availability.contains(
                              AvailabilityOption.morning,
                            ),
                            onTap: () => setState(
                              () => _toggleAvailability(
                                AvailabilityOption.morning,
                              ),
                            ),
                          ),
                          _AvailabilityChip(
                            label: 'Tardes',
                            selected: _availability.contains(
                              AvailabilityOption.afternoon,
                            ),
                            onTap: () => setState(
                              () => _toggleAvailability(
                                AvailabilityOption.afternoon,
                              ),
                            ),
                          ),
                          _AvailabilityChip(
                            label: 'Noites',
                            selected: _availability.contains(
                              AvailabilityOption.evening,
                            ),
                            onTap: () => setState(
                              () => _toggleAvailability(
                                AvailabilityOption.evening,
                              ),
                            ),
                          ),
                          _AvailabilityChip(
                            label: 'Fins de semana',
                            selected: _availability.contains(
                              AvailabilityOption.weekend,
                            ),
                            onTap: () => setState(
                              () => _toggleAvailability(
                                AvailabilityOption.weekend,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _MobileFilterSection(
                      title: 'Preço máximo por hora',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: ExplicadoresMobileLayout.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.euro_rounded,
                                  size: 20,
                                  color: ExplicadoresMobileLayout.textMuted,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _priceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: _onPriceChanged,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Sem limite',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF9AA4B2),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          ExplicadoresMobileLayout.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              activeTrackColor:
                                  ExplicadoresMobileLayout.accentOrange,
                              inactiveTrackColor: const Color(0xFFE5E7EB),
                              thumbColor: ExplicadoresMobileLayout.accentOrange,
                              overlayShape: SliderComponentShape.noOverlay,
                            ),
                            child: Slider(
                              min: 5,
                              max: 80,
                              divisions: 75,
                              value: (_maxPrice ?? 80).clamp(5, 80).toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  _maxPrice = value;
                                  _priceController.text = value
                                      .round()
                                      .toString();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _MobileFilterSection(
                      title: 'Avaliação mínima',
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _RatingChip(
                            label: 'Qualquer',
                            selected: _minRating == null,
                            onTap: () => setState(() => _minRating = null),
                          ),
                          for (final rating in [5.0, 4.5, 4.0, 3.5])
                            _RatingChip(
                              label: rating.toStringAsFixed(
                                rating.truncateToDouble() == rating ? 0 : 1,
                              ),
                              selected: _minRating == rating,
                              onTap: () => setState(() => _minRating = rating),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: ExplicadoresMobileLayout.accentOrange,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Limpar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ExplicadoresMobileLayout.accentOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient:
                              ExplicadoresMobileLayout.primaryButtonGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Aplicar filtros',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAvailability(AvailabilityOption option) {
    final next = {..._availability};
    if (next.contains(option)) {
      next.remove(option);
    } else {
      next.add(option);
    }
    _availability = next;
  }
}

class _MobileFilterSection extends StatelessWidget {
  const _MobileFilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ExplicadoresMobileLayout.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: ExplicadoresMobileLayout.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  final List<FilterOption> options;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final option in options)
          _FilterChip(
            label: option.label,
            selected: option.id == selectedId,
            onTap: () => onChanged(option.id),
          ),
      ],
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FilterChip(label: label, selected: selected, onTap: onTap);
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF3E8) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? ExplicadoresMobileLayout.accentOrange
                : ExplicadoresMobileLayout.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != 'Qualquer') ...[
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: ExplicadoresMobileLayout.accentOrange,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected
                    ? ExplicadoresMobileLayout.accentOrange
                    : ExplicadoresMobileLayout.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF3E8) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? ExplicadoresMobileLayout.accentOrange
                : ExplicadoresMobileLayout.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w600,
            color: selected
                ? ExplicadoresMobileLayout.accentOrange
                : ExplicadoresMobileLayout.textSecondary,
          ),
        ),
      ),
    );
  }
}
