import 'dart:math' as math;

import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:flutter/material.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({super.key, required this.availability});

  static const _dayWidth = 181.803;
  static const _radius = 10.908;
  static const List<String> _dayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  final List<PublicProfessorAvailabilityDto> availability;

  List<_MergedAvailabilityRange> _rangesForDay(int dayIndex) {
    final items =
        availability
            .where((item) => item.isAvailable)
            .where((item) => item.dayIndex == dayIndex)
            .where((item) => item.startTime != null)
            .toList(growable: false)
          ..sort((left, right) => left.startTime!.compareTo(right.startTime!));

    final ranges = <_MergedAvailabilityRange>[];
    for (final item in items) {
      final start = item.startTime!;
      final end =
          item.endTime ??
          start.add(Duration(minutes: item.defaultDurationMinutes ?? 30));

      if (ranges.isEmpty) {
        ranges.add(_MergedAvailabilityRange(start: start, end: end));
        continue;
      }

      final last = ranges.last;
      if (!start.isAfter(last.end)) {
        ranges[ranges.length - 1] = _MergedAvailabilityRange(
          start: last.start,
          end: end.isAfter(last.end) ? end : last.end,
        );
        continue;
      }

      final difference = start.difference(last.end).inMinutes;
      if (difference <= 0 || difference == 30) {
        ranges[ranges.length - 1] = _MergedAvailabilityRange(
          start: last.start,
          end: end.isAfter(last.end) ? end : last.end,
        );
      } else {
        ranges.add(_MergedAvailabilityRange(start: start, end: end));
      }
    }

    return ranges;
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatRange(_MergedAvailabilityRange range) {
    return '${_formatTime(range.start)} - ${_formatTime(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final dayRanges = List<List<_MergedAvailabilityRange>>.generate(
      7,
      _rangesForDay,
      growable: false,
    );
    final maxRows = dayRanges.fold<int>(
      0,
      (maxValue, item) => math.max(maxValue, item.length),
    );
    final visibleRows = math.max(maxRows, 1);
    final cardHeight =
        56 + (visibleRows * 34.906) + ((visibleRows - 1) * 4.363);

    Widget dayColumn(String day, List<_MergedAvailabilityRange> times) {
      return Container(
        width: _dayWidth,
        height: cardHeight,
        padding: const EdgeInsets.only(
          left: 14.181,
          right: 14.181,
          top: 14.181,
          bottom: 1.091,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.091),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 26.18,
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 17.453,
                    height: 26.18 / 17.453,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.727),
            if (times.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Sem horário',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ),
              )
            else
              for (final t in times) ...[
                Container(
                  height: 30.543,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(4.363),
                  ),
                  child: Center(
                    child: Text(
                      _formatRange(t),
                      style: const TextStyle(
                        fontSize: 14.2,
                        height: 21.817 / 14.2,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF008236),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4.363),
              ],
          ],
        ),
      );
    }

    if (availability.where((item) => item.isAvailable).isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.091),
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: const Text(
          'Este professor ainda não definiu horários de disponibilidade.',
          style: TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF6B7280)),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var dayIndex = 0; dayIndex < _dayLabels.length; dayIndex++) ...[
            dayColumn(_dayLabels[dayIndex], dayRanges[dayIndex]),
            if (dayIndex < _dayLabels.length - 1) const SizedBox(width: 17.09),
          ],
        ],
      ),
    );
  }
}

class _MergedAvailabilityRange {
  const _MergedAvailabilityRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
