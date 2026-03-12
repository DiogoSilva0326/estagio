import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_colors.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_layout.dart';
import 'package:aula_extra/features/professor/disponibilidade/widgets/disponibilidade_table.dart';
import 'package:aula_extra/features/professor/disponibilidade/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class DisponibilidadeProfessorContentSection extends StatefulWidget {
  const DisponibilidadeProfessorContentSection({
    super.key,
  });

  @override
  State<DisponibilidadeProfessorContentSection> createState() => _DisponibilidadeProfessorContentSectionState();
}

class _DisponibilidadeProfessorContentSectionState extends State<DisponibilidadeProfessorContentSection> {
  static const List<String> _days = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  late final List<String> _hours;
  late final List<List<bool>> _availability;

  @override
  void initState() {
    super.initState();
    _hours = List.generate(13, (index) => '${index + 8}:00');
    _availability = List.generate(_hours.length, (_) => List<bool>.filled(_days.length, false));
  }

  void _toggleCell(int hourIndex, int dayIndex) {
    setState(() {
      _availability[hourIndex][dayIndex] = !_availability[hourIndex][dayIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: DisponibilidadeProfessorColors.title,
      fontWeight: FontWeight.w800,
      fontSize: DisponibilidadeProfessorLayout.titleFontSize,
      height: DisponibilidadeProfessorLayout.titleLineHeight / DisponibilidadeProfessorLayout.titleFontSize,
    );

    return Container(
      color: DisponibilidadeProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: DisponibilidadeProfessorLayout.pageLeftPadding,
            right: DisponibilidadeProfessorLayout.pageRightPadding,
            top: DisponibilidadeProfessorLayout.pageTopPadding,
            bottom: 90,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(),
              const SizedBox(width: DisponibilidadeProfessorLayout.sidebarContentGap),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: DisponibilidadeProfessorLayout.contentPadding,
                    left: DisponibilidadeProfessorLayout.contentPadding,
                    right: DisponibilidadeProfessorLayout.contentPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: DisponibilidadeProfessorLayout.titleLineHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Disponibilidade', style: titleStyle),
                            const _SaveButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28.889),
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.all(DisponibilidadeProfessorLayout.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Marque seus horários disponíveis',
                                style: TextStyle(
                                  color: DisponibilidadeProfessorColors.title,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 28 / 20,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Clique nos horários para marcar/desmarcar sua disponibilidade',
                                style: TextStyle(
                                  color: DisponibilidadeProfessorColors.muted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              DisponibilidadeTable(
                                hours: _hours,
                                days: _days,
                                availability: _availability,
                                onCellToggle: _toggleCell,
                              ),
                              const SizedBox(height: 20),
                              const _Legend(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DisponibilidadeProfessorLayout.cardRadius),
        border: Border.all(color: DisponibilidadeProfessorColors.cardBorder),
      ),
      child: child,
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DisponibilidadeProfessorLayout.saveButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DisponibilidadeProfessorLayout.saveButtonRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DisponibilidadeProfessorColors.saveGradientTop,
              DisponibilidadeProfessorColors.saveGradientBottom,
            ],
          ),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(DisponibilidadeProfessorLayout.saveButtonRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                  size: DisponibilidadeProfessorLayout.saveButtonIconSize,
                ),
                const SizedBox(width: 10),
                Text(
                  'Salvar Alterações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DisponibilidadeProfessorLayout.saveButtonFontSize,
                    fontWeight: FontWeight.w600,
                    height: DisponibilidadeProfessorLayout.saveButtonLineHeight /
                        DisponibilidadeProfessorLayout.saveButtonFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      color: DisponibilidadeProfessorColors.text,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: DisponibilidadeProfessorColors.cardBorder,
            width: 1.19,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.77),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DisponibilidadeProfessorColors.saveGradientTop,
                    DisponibilidadeProfessorColors.saveGradientBottom,
                  ],
                ),
              ),
              child: const SizedBox(
                width: DisponibilidadeProfessorLayout.legendSquareSize,
                height: DisponibilidadeProfessorLayout.legendSquareSize,
              ),
            ),
            const SizedBox(width: 9.54),
            const Text('Disponível', style: labelStyle),
            const SizedBox(width: 28.61),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.77),
                border: Border.all(
                  color: DisponibilidadeProfessorColors.cellBorder,
                  width: DisponibilidadeProfessorLayout.tableCellBorderWidth,
                ),
              ),
              child: const SizedBox(
                width: DisponibilidadeProfessorLayout.legendSquareSize,
                height: DisponibilidadeProfessorLayout.legendSquareSize,
              ),
            ),
            const SizedBox(width: 9.54),
            const Text('Indisponível', style: labelStyle),
          ],
        ),
      ),
    );
  }
}
