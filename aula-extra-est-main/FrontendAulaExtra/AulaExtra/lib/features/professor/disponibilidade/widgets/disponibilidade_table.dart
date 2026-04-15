import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_colors.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_layout.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DisponibilidadeTable extends StatelessWidget {
  const DisponibilidadeTable({
    super.key,
    required this.hours,
    required this.days,
    required this.availability,
    required this.onCellToggle,
  });

  final List<String> hours;
  final List<String> days;
  final List<List<bool>> availability;
  final void Function(int hourIndex, int dayIndex) onCellToggle;

  @override
  Widget build(BuildContext context) {
    const headerFontSize = 16.69;
    const headerLineHeight = 23.84;

    final hourTextStyle = TextStyle(
      color: DisponibilidadeProfessorColors.muted,
      fontSize: headerFontSize,
      fontWeight: FontWeight.w400,
      height: headerLineHeight / headerFontSize,
    );

    final hourHeaderStyle = TextStyle(
      color: DisponibilidadeProfessorColors.muted,
      fontSize: headerFontSize,
      fontWeight: FontWeight.w500,
      height: headerLineHeight / headerFontSize,
    );

    final dayHeaderStyle = TextStyle(
      color: DisponibilidadeProfessorColors.text,
      fontSize: headerFontSize,
      fontWeight: FontWeight.w500,
      height: headerLineHeight / headerFontSize,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final hourWidth = DisponibilidadeProfessorLayout.tableHourColumnWidth;
        final gap = DisponibilidadeProfessorLayout.tableCellGap;
        final minCell = DisponibilidadeProfessorLayout.tableCellSize;

        final minContentWidth =
            hourWidth + (days.length - 1) * gap + days.length * minCell;
        final canStretch =
            availableWidth.isFinite && availableWidth > minContentWidth;

        final dayWidth = canStretch
            ? (availableWidth - hourWidth - (days.length - 1) * gap) /
                  days.length
            : minCell;

        final contentWidth =
            hourWidth + (days.length - 1) * gap + days.length * dayWidth;
        final effectiveWidth = availableWidth.isFinite
            ? math.max(availableWidth, contentWidth)
            : contentWidth;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                DisponibilidadeProfessorLayout.tableCellRadius,
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: DisponibilidadeProfessorColors.tableHeaderBackground,
                ),
                child: SizedBox(
                  height: DisponibilidadeProfessorLayout.tableHeaderHeight,
                  child: Row(
                    children: [
                      SizedBox(
                        width: hourWidth,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left:
                                DisponibilidadeProfessorLayout.tableHourPadding,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Hora', style: hourHeaderStyle),
                          ),
                        ),
                      ),
                      for (var i = 0; i < days.length; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        SizedBox(
                          width: dayWidth,
                          child: Center(
                            child: Text(
                              days[i],
                              textAlign: TextAlign.center,
                              style: dayHeaderStyle,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: gap),
            for (var hourIndex = 0; hourIndex < hours.length; hourIndex++) ...[
              SizedBox(
                height: DisponibilidadeProfessorLayout.tableRowHeight,
                child: Row(
                  children: [
                    SizedBox(
                      width: hourWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          DisponibilidadeProfessorLayout.tableHourPadding,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(hours[hourIndex], style: hourTextStyle),
                        ),
                      ),
                    ),
                    for (
                      var dayIndex = 0;
                      dayIndex < days.length;
                      dayIndex++
                    ) ...[
                      if (dayIndex > 0) SizedBox(width: gap),
                      _AvailabilityCell(
                        size: dayWidth,
                        selected: availability[hourIndex][dayIndex],
                        onTap: () => onCellToggle(hourIndex, dayIndex),
                      ),
                    ],
                  ],
                ),
              ),
              if (hourIndex != hours.length - 1) SizedBox(height: gap),
            ],
          ],
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(
            DisponibilidadeProfessorLayout.tableCellRadius,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: DisponibilidadeProfessorColors.cardBorder,
                width: 1.19,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: effectiveWidth, child: content),
            ),
          ),
        );
      },
    );
  }
}

class _AvailabilityCell extends StatelessWidget {
  const _AvailabilityCell({
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: DisponibilidadeProfessorLayout.tableCellSize,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          DisponibilidadeProfessorLayout.tableCellRadius,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              DisponibilidadeProfessorLayout.tableCellRadius,
            ),
            border: Border.all(
              width: DisponibilidadeProfessorLayout.tableCellBorderWidth,
              color: selected
                  ? DisponibilidadeProfessorColors.availableBorder
                  : DisponibilidadeProfessorColors.unavailableBorder,
            ),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DisponibilidadeProfessorColors.saveGradientTop,
                      DisponibilidadeProfessorColors.saveGradientBottom,
                    ],
                  )
                : null,
            color: selected ? null : Colors.white,
            boxShadow: selected
                ? [
                    const BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4.77,
                      offset: Offset(0, 2.38),
                      spreadRadius: -2.38,
                    ),
                    const BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 7.15,
                      offset: Offset(0, 4.77),
                      spreadRadius: -1.19,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
