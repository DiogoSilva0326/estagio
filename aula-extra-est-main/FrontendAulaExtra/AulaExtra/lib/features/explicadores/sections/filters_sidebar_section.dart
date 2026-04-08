import 'package:flutter/material.dart';

class FiltersSidebarSection extends StatelessWidget {
  const FiltersSidebarSection({
    super.key,
    required this.maxPrice,
    required this.onMaxPriceChanged,
    required this.levelOptions,
    required this.selectedLevelId,
    required this.onLevelChanged,
    required this.availability,
    required this.onAvailabilityChanged,
    required this.specializationOptions,
    required this.selectedSpecializationId,
    required this.onSpecializationChanged,
    required this.minRating,
    required this.onMinRatingChanged,
    required this.onClear,
    required this.onApply,
  });

  final double maxPrice;
  final ValueChanged<double> onMaxPriceChanged;
  final List<FilterOption> levelOptions;
  final String? selectedLevelId;
  final ValueChanged<String?> onLevelChanged;
  final Set<AvailabilityOption> availability;
  final ValueChanged<Set<AvailabilityOption>> onAvailabilityChanged;
  final List<FilterOption> specializationOptions;
  final String? selectedSpecializationId;
  final ValueChanged<String?> onSpecializationChanged;
  final double? minRating;
  final ValueChanged<double?> onMinRatingChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 344,
      padding: const EdgeInsets.only(
        left: 26.668,
        right: 44.447,
        top: 26.668,
        bottom: 26.668,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.111),
        borderRadius: BorderRadius.circular(17.408),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, size: 22.223, color: Color(0xFF0A0A0A)),
                  SizedBox(width: 8.889),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 26.668,
                      height: 35.557 / 26.668,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onClear,
                child: const Row(
                  children: [
                    Icon(Icons.refresh, size: 17.779, color: Color(0xFF6A7282)),
                    SizedBox(width: 6),
                    Text(
                      'Limpar',
                      style: TextStyle(
                        fontSize: 15.556,
                        height: 22.223 / 15.556,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Preço por hora'),
          const SizedBox(height: 13.334),
          Row(
            children: [
              const SizedBox(width: 10.851),
              Container(
                width: 47,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8.889, vertical: 4.445),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DC), width: 1.111),
                  borderRadius: BorderRadius.circular(4.445),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${maxPrice.round()}€',
                    style: const TextStyle(
                      fontSize: 17.779,
                      height: 26.668 / 17.779,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13.334),
          _PriceSlider(value: maxPrice, onChanged: onMaxPriceChanged),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Nível de Ensino'),
          const SizedBox(height: 13.334),
          _SingleSelectOptionList(
            options: levelOptions,
            selectedId: selectedLevelId,
            onChanged: onLevelChanged,
          ),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Disponibilidade'),
          const SizedBox(height: 13.334),
          _AvailabilityList(value: availability, onChanged: onAvailabilityChanged),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('País de Origem'),
          const SizedBox(height: 13.334),
          Container(
            height: 43.336,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DC), width: 1.111),
              borderRadius: BorderRadius.circular(11.112),
            ),
          ),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Especializações'),
          const SizedBox(height: 13.334),
          _SingleSelectOptionList(
            options: specializationOptions,
            selectedId: selectedSpecializationId,
            onChanged: onSpecializationChanged,
          ),
          const SizedBox(height: 26.668),
          const _Title('Avaliação Mínima'),
          const SizedBox(height: 13.334),
          _RatingList(value: minRating, onChanged: onMinRatingChanged),
          const SizedBox(height: 26.668),
          InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(11.112),
            child: Container(
              height: 53.336,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3B94EF), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(11.112),
              ),
              child: const Center(
                child: Text(
                  'Aplicar Filtros',
                  style: TextStyle(
                    fontSize: 17.779,
                    height: 26.668 / 17.779,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOption {
  const FilterOption({required this.id, required this.label});

  final String id;
  final String label;
}

enum AvailabilityOption { morning, afternoon, evening, weekend }

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1.111, width: double.infinity, color: const Color(0xFFE5E7EB));
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20.001,
        height: 30.002 / 20.001,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0A0A0A),
      ),
    );
  }
}

class _PriceSlider extends StatelessWidget {
  const _PriceSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = value.clamp(5, 80).toDouble();
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 4,
        activeTrackColor: const Color(0xFFFC9039),
        inactiveTrackColor: const Color(0xFFE5E7EB),
        thumbColor: const Color(0xFFFC9039),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        min: 5,
        max: 80,
        divisions: 75,
        value: current,
        onChanged: onChanged,
      ),
    );
  }
}

class _SingleSelectOptionList extends StatelessWidget {
  const _SingleSelectOptionList({
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  final List<FilterOption> options;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((o) {
        final selected = o.id == selectedId;
        return _SelectableRow(
          label: o.label,
          selected: selected,
          onTap: () => onChanged(selected ? null : o.id),
        );
      }).toList(growable: false),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.889),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            _Dot(selected: selected),
            const SizedBox(width: 8.889),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15.556,
                height: 22.223 / 15.556,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityList extends StatelessWidget {
  const _AvailabilityList({required this.value, required this.onChanged});

  final Set<AvailabilityOption> value;
  final ValueChanged<Set<AvailabilityOption>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SelectableRow(
          label: 'Qualquer horário',
          selected: value.isEmpty,
          onTap: () => onChanged(<AvailabilityOption>{}),
        ),
        _SelectableRow(
          label: 'Manhãs',
          selected: value.contains(AvailabilityOption.morning),
          onTap: () {
            final next = {...value};
            next.contains(AvailabilityOption.morning)
                ? next.remove(AvailabilityOption.morning)
                : next.add(AvailabilityOption.morning);
            onChanged(next);
          },
        ),
        _SelectableRow(
          label: 'Tardes',
          selected: value.contains(AvailabilityOption.afternoon),
          onTap: () {
            final next = {...value};
            next.contains(AvailabilityOption.afternoon)
                ? next.remove(AvailabilityOption.afternoon)
                : next.add(AvailabilityOption.afternoon);
            onChanged(next);
          },
        ),
        _SelectableRow(
          label: 'Noites',
          selected: value.contains(AvailabilityOption.evening),
          onTap: () {
            final next = {...value};
            next.contains(AvailabilityOption.evening)
                ? next.remove(AvailabilityOption.evening)
                : next.add(AvailabilityOption.evening);
            onChanged(next);
          },
        ),
        _SelectableRow(
          label: 'Fins de semana',
          selected: value.contains(AvailabilityOption.weekend),
          onTap: () {
            final next = {...value};
            next.contains(AvailabilityOption.weekend)
                ? next.remove(AvailabilityOption.weekend)
                : next.add(AvailabilityOption.weekend);
            onChanged(next);
          },
        ),
      ],
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SelectableRow(
          label: '4.5+ estrelas',
          selected: value == 4.5,
          onTap: () => onChanged(value == 4.5 ? null : 4.5),
        ),
        _SelectableRow(
          label: '4+ estrelas',
          selected: value == 4.0,
          onTap: () => onChanged(value == 4.0 ? null : 4.0),
        ),
        _SelectableRow(
          label: '3.5+ estrelas',
          selected: value == 3.5,
          onTap: () => onChanged(value == 3.5 ? null : 3.5),
        ),
        _SelectableRow(
          label: 'Qualquer avaliação',
          selected: value == null,
          onTap: () => onChanged(null),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17.779,
      height: 17.779,
      child: Center(
        child: Container(
          width: 13.334,
          height: 13.334,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFC9039) : const Color(0xFF8F8F8F),
            border: Border.all(color: const Color(0xFF8F8F8F), width: selected ? 0.87 : 0),
            borderRadius: BorderRadius.circular(18642298),
          ),
        ),
      ),
    );
  }
}
